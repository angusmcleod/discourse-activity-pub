export default {
  "/ap/local/actor/1": {
    actor: {
      id: 1,
      handle: "@angus_ap@test.local",
      name: "Cat 1",
      username: "cat_1",
      local: true,
      domain: "test.local",
      url: "https://test.local/c/cat-1",
      can_admin: false,
      default_visibility: "public",
      post_object_type: "Note",
      publication_type: "first_post",
      model_type: "Category",
      model_id: 2,
      model: {
        id: 1,
        name: "Cat 1",
        slug: "cat-1",
      },
    }
  },
  "/ap/local/actor/2": {
    actor: {
      id: 2,
      handle: "@angus_ap@test.local",
      name: "Cat 2",
      username: "cat_2",
      local: true,
      domain: "test.local",
      url: "https://test.local/c/cat-2",
      can_admin: true,
      default_visibility: "public",
      post_object_type: "Note",
      publication_type: "first_post",
      model_type: "Category",
      model_id: 2,
      model: {
        id: 2,
        name: "Cat 2",
        slug: "cat-2",
      },
    }
  },
  "/ap/local/actor/3": {
    actor: {
      id: 3,
      handle: "@angus_ap@test.local",
      name: "Sub Cat 1",
      username: "sub_cat_1",
      local: true,
      domain: "test.local",
      url: "https://test.local/c/cat-1/sub-cat-1",
      can_admin: true,
      default_visibility: "public",
      post_object_type: "Note",
      publication_type: "first_post",
      model_type: "Category",
      model_id: 3,
      model: {
        id: 3,
        name: "Sub Cat 1",
        slug: "cat-1/sub-cat-1",
      },
    }
  },
};
