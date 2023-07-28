# frozen_string_literal: true
module DiscourseActivityPub
  class UserHandler
    def initialize(actor: nil, user: nil)
      @actor = actor
      @user = user
    end

    def validate_actor
      # We only associated users with stored Persons
      actor&.ap.person?
    end

    def validate_user
      true
    end

    def user
      @user ||= actor&.model
    end

    def actor
      @actor ||= user&.activity_pub_actor
    end

    def create_user
      begin
        @user =
          User.create!(
            username: UserNameSuggester.suggest(actor.username.presence || actor.id),
            name: actor.name,
            staged: true,
            skip_email_validation: true
          )
      rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => error
        log_failure("find_or_create", e.message)
        raise ActiveRecord::Rollback
      end

      actor.update(model_id: user.id, model_type: 'User')
    end

    def update_user
      user.skip_email_validation = true
      update_avatar_from_icon
    end

    def build_actor
      attrs = {
        ap_type: DiscourseActivityPub::AP::Actor::Person.type,
        local: true,
        domain: nil,
        inbox: nil,
        outbox: nil
      }
      @actor = user.build_activity_pub_actor(attrs)
    end

    def update_actor
      actor.username = user.username
      actor.name = user.name if user.name
    end

    def update_or_create_user
      return nil unless validate_actor

      ActiveRecord::Base.transaction do
        create_user unless user
        update_user
      end

      user
    end

    def update_or_create_actor
      return nil unless validate_user

      ActiveRecord::Base.transaction do
        build_actor unless actor
        update_actor
        actor.save!
      end

      actor
    end

    def self.update_or_create_user(actor)
      new(actor: actor).update_or_create_user
    end

    def self.update_or_create_actor(user)
      new(user: user).update_or_create_actor
    end

    protected

    def update_avatar_from_icon
      if actor.icon_url
        icon_upload = Upload.find_by(user_id: user.id, origin: actor.icon_url)

        if !icon_upload
          UserAvatar.import_url_for_user(actor.icon_url, user)
        elsif user.uploaded_avatar_id != icon_upload.id
          user.update!(uploaded_avatar_id: icon_upload.id)
        end
      end
    end

    def log_failure(verb, message)
      return unless SiteSetting.activity_pub_verbose_logging

      prefix = "Failed to #{verb} user for #{actor.id}"
      Rails.logger.warn("[Discourse Activity Pub] #{prefix}: #{message}")
    end
  end
end