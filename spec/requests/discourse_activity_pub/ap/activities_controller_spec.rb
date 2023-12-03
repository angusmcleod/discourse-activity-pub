# frozen_string_literal: true

RSpec.describe DiscourseActivityPub::AP::ActivitiesController do
  let!(:activity) { Fabricate(:discourse_activity_pub_activity_create) }

  it { expect(described_class).to be < DiscourseActivityPub::AP::ObjectsController }

  before do
    SiteSetting.activity_pub_require_signed_requests = false
  end

  context "without a valid activity" do
    it "returns a not found error" do
      get_object(activity, url: "/ap/activity/56")
      expect(response.status).to eq(404)
      expect(response.parsed_body).to eq(activity_request_error("not_found"))
    end
  end

  context "without an available base model" do
    fab!(:staff_category) do
      Fabricate(:category).tap do |staff_category|
        staff_category.set_permissions(staff: :full)
        staff_category.save!
      end
    end

    before do
      activity.base_object.model.topic.update(category: staff_category)
    end

    it "returns a not available error" do
      get_object(activity)
      expect(response.status).to eq(401)
      expect(response.parsed_body).to eq(activity_request_error("not_available"))
    end
  end

  describe "with an available base model" do
    before do
      category = activity.ap.composition? ?
        activity.base_object.model.topic.category :
        activity.object.model
      toggle_activity_pub(category)
    end

    it "returns activity json" do
      get_object(activity)
      expect(response.status).to eq(200)
      expect(response.parsed_body).to eq(activity.ap.json)
    end

    context "with publishing disabled" do
      before do
        SiteSetting.login_required = true
      end

      context "with a composition activity" do
        it "returns a not available error" do
          get_object(activity)
          expect(response.status).to eq(401)
          expect(response.parsed_body).to eq(activity_request_error("not_available"))
        end
      end

      context "with a follow actiivty" do
        let!(:activity) { Fabricate(:discourse_activity_pub_activity_follow) }

        it "returns activity json" do
          get_object(activity)
          expect(response.status).to eq(200)
          expect(response.parsed_body).to eq(activity.ap.json)
        end
      end

      context "with a response actiivty" do
        let!(:activity) { Fabricate(:discourse_activity_pub_activity_follow) }

        it "returns activity json" do
          get_object(activity)
          expect(response.status).to eq(200)
          expect(response.parsed_body).to eq(activity.ap.json)
        end
      end
    end
  end
end