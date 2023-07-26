# frozen_string_literal: true

class DiscourseActivityPub::AP::ActivitiesController < DiscourseActivityPub::AP::ObjectsController
  before_action :ensure_activity_exists
  before_action :address_activity

  def show
    render json: @activity.ap.json
  end

  protected

  def ensure_activity_exists
    render_activity_pub_error("not_found", 404) unless @activity = DiscourseActivityPubActivity.find_by(ap_key: params[:key])
  end

  def address_activity
    @activity.address!
  end
end
