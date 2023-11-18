# frozen_string_literal: true

class DiscourseActivityPub::AP::InboxesController < DiscourseActivityPub::AP::ActorsController
  def create
    @json = validate_json_ld(request.body.read)

    if @json
      ensure_json_addressed_to_actor
      process_json
      head 202
    else
      render_activity_pub_error("json_not_valid", 422)
    end
  end

  protected

  def rate_limit
    limit = SiteSetting.activity_pub_rate_limit_post_to_inbox_per_minute
    RateLimiter.new(nil, "activity-pub-inbox-post-min-#{request.remote_ip}", limit, 1.minute).performed!
  end

  # TODO: Remove this once full addressing support is added.
  # See DiscourseActivityPub::AP::Activity.add_handler(:activity, :target) in plugin.rb.
  def ensure_json_addressed_to_actor
    unless @json['to']&.include?(@actor.ap_id)
      @json['to'] ||= []
      @json['to'] << @actor.ap_id
    end
  end

  def process_json
    Jobs.enqueue(:discourse_activity_pub_process, json: @json)
  end
end
