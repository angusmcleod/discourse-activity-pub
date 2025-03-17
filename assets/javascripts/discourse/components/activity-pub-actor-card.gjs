import { i18n } from "discourse-i18n";
import ActivityPubActor from "./activity-pub-actor";
import ActivityPubActorModel from "./activity-pub-actor-model";
import ActivityPubFollowBtn from "./activity-pub-follow-btn";

const ActivityPubActorCard = <template>
  <div class="activity-pub-actor-card">
    <ActivityPubActor @actor={{@actor}} @hideImage={{true}} />
    <ActivityPubFollowBtn @actor={{@actor}} @type="follow" />
    <div class="activity-pub-actor-card-bottom">
      <ActivityPubActorModel @actor={{@actor}} />
      <div class="follower-count activity-pub-actor-metadata">
        {{i18n
          "discourse_activity_pub.about.actor.follower_count"
          count=@actor.follower_count
        }}
      </div>
    </div>
  </div>
</template>;

export default ActivityPubActorCard;
