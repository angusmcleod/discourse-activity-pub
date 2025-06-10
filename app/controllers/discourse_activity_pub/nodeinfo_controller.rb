# frozen_string_literal: true

module DiscourseActivityPub
  class NodeinfoController < ApplicationController
    requires_plugin DiscourseActivityPub::PLUGIN_NAME

    include DiscourseActivityPub::EnabledVerification

    skip_before_action :preload_json, :redirect_to_login_if_required, :check_xhr

    before_action :ensure_site_enabled
    before_action :rate_limit, only: [:show]
    before_action :find_nodeinfo, only: [:show]

    def index
      discourse_expires_in 1.minute
      render json: Nodeinfo.index, content_type: "application/jrd+json"
    end

    def show
      discourse_expires_in 1.minute
      render_serialized(@nodeinfo, NodeinfoSerializer, root: false)
    end

    protected

    def rate_limit
      RateLimiter.new(
        nil,
        "activity-pub-nodeinfo-min-#{request.remote_ip}",
        SiteSetting.activity_pub_rate_limit_nodeinfo_per_minute.to_i,
        1.minute,
      ).performed!
    end

    def find_nodeinfo
      @nodeinfo = Nodeinfo.new(params[:version])
      raise Discourse::NotFound unless @nodeinfo.supported_version?
    end
  end
end
