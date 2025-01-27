# frozen_string_literal: true
RSpec.describe "integration cases" do
  def read_json(case_name, file_name)
    JSON.parse(
      File.open(
        File.join(
          File.expand_path("../..", __dir__),
          "spec",
          "fixtures",
          "integration",
          case_name,
          "#{file_name}.json",
        ),
      ).read,
    ).with_indifferent_access
  end

  describe "#case 1" do
    let!(:actor) { Fabricate(:discourse_activity_pub_actor_group) }
    let!(:remote_actor) do
      json = read_json("case_1", "group_actor")
      Fabricate(:discourse_activity_pub_actor_group, ap_id: json[:id], local: false)
    end
    let!(:follow) do
      Fabricate(:discourse_activity_pub_follow, follower: actor, followed: remote_actor)
    end

    before do
      toggle_activity_pub(actor.model, publication_type: "full_topic")
      Jobs.run_immediately!
      SiteSetting.activity_pub_require_signed_requests = false

      stub_object_request(read_json("case_1", "group_actor"))
      stub_object_request(read_json("case_1", "actor_1"))
      stub_object_request(read_json("case_1", "actor_2"))
      stub_object_request(read_json("case_1", "actor_3"))
      stub_object_request(read_json("case_1", "actor_4"))
      stub_object_request(read_json("case_1", "actor_5"))
      stub_object_request(read_json("case_1", "context_1"))
      stub_request(
        :get,
        "https://community.nodebb.org/assets/uploads/profile/uid-14929/14929-profileavatar-1619513263893.png",
      )

      post_to_inbox(actor, body: read_json("case_1", "received_1"))
      post_to_inbox(actor, body: read_json("case_1", "received_2"))
      post_to_inbox(actor, body: read_json("case_1", "received_3"))
      post_to_inbox(actor, body: read_json("case_1", "received_4"))
      post_to_inbox(actor, body: read_json("case_1", "received_5"))
      post_to_inbox(actor, body: read_json("case_1", "received_6"))
      post_to_inbox(actor, body: read_json("case_1", "received_7"))
      post_to_inbox(actor, body: read_json("case_1", "received_8"))
      post_to_inbox(actor, body: read_json("case_1", "received_9"))
      post_to_inbox(actor, body: read_json("case_1", "received_10"))
    end

    it "creates a single topic and post" do
      expect(DiscourseActivityPubObject.count).to eq(1)
      expect(Post.count).to eq(1)
      expect(Topic.count).to eq(1)
    end
  end
end
