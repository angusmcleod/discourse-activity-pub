# frozen_string_literal: true
module DiscourseActivityPub
  module AP
    module BaseConcern
      extend ActiveSupport::Concern

      included do
        before_validation :ensure_ap_type
        before_validation :ensure_ap_key
        before_validation :ensure_ap_id

        validates :ap_type, presence: true
        validates :ap_key, uniqueness: true, allow_nil: true # foreign objects don't have keys
        validates :ap_id, uniqueness: true, presence: true
      end

      def ap
        @ap ||= DiscourseActivityPub::AP::Object.get_klass(ap_type)&.new(stored: self)
      end

      def _model
        self.respond_to?(:model) ? self.model : self.actor.model
      end

      def ensure_ap_type
        self.ap_type = DiscourseActivityPub::Model.ap_type(_model) if !self.ap_type
      end

      def ensure_ap_key
        self.ap_key = SecureRandom.hex(16) if !self.ap_key && self.local
      end

      def ensure_ap_id
        self.ap_id = DiscourseActivityPub::JsonLd.json_ld_id(ap.base_type, ap_key) if !self.ap_id && ap
      end
    end
  end
end