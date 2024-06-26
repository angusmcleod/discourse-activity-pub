# frozen_string_literal: true

module DiscourseActivityPub
  class AuthController < ApplicationController
    requires_plugin DiscourseActivityPub::PLUGIN_NAME

    include DiscourseActivityPub::EnabledVerification

    before_action :ensure_logged_in
    before_action :ensure_site_enabled

    def index
      redirect_to "/ap/auth/authorizations"
    end

    protected

    def render_auth_error(key, status)
      render_json_error(I18n.t("discourse_activity_pub.auth.error.#{key}"), status)
    end
  end
end
