export default {
  "/ap/category/2/followers.json": {
    followers: [
      {
        name: "Angus",
        username: "angus_ap",
        local: true,
        domain: "test.local",
        url: "https://test.local/u/angus_ap",
        followed_at: "2013-02-08T23:14:40.018Z",
        icon_url: "/images/avatar.png",
        user: {
          username: "angus_local",
        },
      },
      {
        name: "Bob",
        username: "bob_ap",
        local: false,
        domain: "test.remote",
        url: "https://test.remote/u/bob_ap",
        followed_at: "2014-02-08T23:14:40.018Z",
        icon_url: "/images/avatar.png",
        user: {
          username: "bob_local",
        },
      },
    ],
    meta: {
      total: 2,
      load_more_url: "/ap/category/2/followers.json?page=1",
    },
  },
};
