# frozen_string_literal: true

RSpec.describe DiscourseActivityPub::AP::Actor do

  it { expect(described_class).to be < DiscourseActivityPub::AP::Object }

  describe "#update_stored_from_json" do
    let(:json) do
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        'id': "https://external.com/u/angus",
        'type': "Person",
        'inbox': "https://external.com/u/angus/inbox",
        'outbox': "https://external.com/u/angus/outbox",
        'preferredUsername': "angus",
        'name': "Angus McLeod"
      }.as_json
    end

    let!(:subject) { described_class.factory(json) }

    it "creates an actor" do
      subject.update_stored_from_json

      actor = DiscourseActivityPubActor.find_by(ap_id: json['id'])
      expect(actor.present?).to eq(true)
      expect(actor.domain).to eq("external.com")
      expect(actor.ap_type).to eq(json["type"])
      expect(actor.inbox).to eq(json["inbox"])
      expect(actor.outbox).to eq(json["outbox"])
      expect(actor.username).to eq(json["preferredUsername"])
      expect(actor.name).to eq(json["name"])
    end

    it "updates an actor if optional attributes have changed" do
      subject.update_stored_from_json

      json['name'] = "Bob McLeod"
      subject.json = json.with_indifferent_access
      subject.update_stored_from_json

      actor = DiscourseActivityPubActor.find_by(ap_id: json['id'])
      expect(actor.name).to eq("Bob McLeod")
    end

    it "creates a new actor if required attributes have changed" do
      subject.update_stored_from_json

      original_id = json['id']
      json['id'] = "https://external.com/u/bob"
      subject.json = json.with_indifferent_access
      subject.update_stored_from_json

      expect(DiscourseActivityPubActor.exists?(ap_id: original_id)).to eq(true)
      expect(DiscourseActivityPubActor.exists?(ap_id: json['id'])).to eq(true)
    end

    it "updates an actor if id has changed and id change is allowed" do
      subject.update_stored_from_json

      original_id = json['id']
      json['id'] = "https://external.com/u/bob"
      subject.json = json.with_indifferent_access
      subject.update_stored_from_json(actor_id: original_id, allow_id_change: true)

      expect(DiscourseActivityPubActor.exists?(ap_id: original_id)).to eq(false)
      expect(DiscourseActivityPubActor.exists?(ap_id: json['id'])).to eq(true)
    end

    it "logs a detailed error if validations fail" do
      orig_logger = Rails.logger
      Rails.logger = fake_logger = FakeLogger.new

      DiscourseActivityPubActor.stubs(:find_by).returns(nil)
      stored = Fabricate(:discourse_activity_pub_actor_person)

      actor = described_class.new
      actor.json = stored.ap.json
      actor.update_stored_from_json

      expect(fake_logger.errors.first).to eq(
        "[Discourse Activity Pub] update_stored_from_json failed to save actor. AR errors: Ap has already been taken. Actor JSON: #{JSON.generate(stored.ap.json)}"
      )

      Rails.logger = orig_logger
    end

    it "prevents concurrent updates" do
      orig_logger = Rails.logger
      Rails.logger = fake_logger = FakeLogger.new

      threads = 5.times.map do
        Thread.new do
          subject.update_stored_from_json
        end
      end
      threads.map(&:join)

      expect(fake_logger.errors.empty?).to eq(true)

      Rails.logger = orig_logger
    end
  end
end