# frozen_string_literal: true

=begin
AP is the interface between Discourse and ActivityPub. All incoming ActivityPub content
is first handled by AP, see app/controllers/discourse_activity_pub/ap/*. All outgoing
ActivityPub content is modelled and serialized by AP. See lib/discourse_activity_pub/ap/*
and app/serializers/discourse_activity_pub/ap/*. The AP class structure reflects
the data model in https://www.w3.org/TR/activitypub and related specifications.
=end

module DiscourseActivityPub
  module AP
    cattr_accessor(:logger) { ::Logger.new("#{Rails.root}/log/activity_pub.log") }

    # Necessary for zeitwerk
    SUPPORTED_OBJECTS = {
      object: %i[article note tombstone document image],
      activity: %i[accept announce create delete follow like reject undo update],
      actor: %i[application group organization person service],
      collection: %i[ordered_collection ordered_collection_page collection_page],
      link: %i[],
    }
  end
end
