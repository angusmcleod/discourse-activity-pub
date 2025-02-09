import { click, fillIn, render, triggerKeyEvent } from "@ember/test-helpers";
import hbs from "htmlbars-inline-precompile";
import { module, test } from "qunit";
import sinon from "sinon";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import pretender, { response } from "discourse/tests/helpers/create-pretender";
import { exists, query } from "discourse/tests/helpers/qunit-helpers";
import selectKit from "discourse/tests/helpers/select-kit-helper";

module(
  "Discourse Activity Pub | Component | activity-pub-authorize",
  function (hooks) {
    setupRenderingTest(hooks);

    const template = hbs`<ActivityPubAuthorize />`;

    test("verifies a domain", async function (assert) {
      let domain = "test.com";
      let authType = "discourse";
      let requests = 0;

      pretender.post("/ap/auth/verify.json", (request) => {
        ++requests;
        assert.strictEqual(
          request.requestBody,
          `domain=${domain}&auth_type=${authType}`,
          "it sets correct request parameters"
        );
        return response({ success: true });
      });

      await render(template);

      const authTypes = selectKit("#user_activity_pub_authorize_auth_type");
      await authTypes.expand();
      await authTypes.selectRowByValue("discourse");

      await fillIn("#user_activity_pub_authorize_domain", domain);
      await click("#user_activity_pub_authorize_verify_domain");

      assert.strictEqual(requests, 1, "performs one request");
      assert.strictEqual(
        query(".activity-pub-authorize-verified-domain span").textContent,
        domain,
        "displays the verified domain"
      );
      assert.ok(
        exists("#user_activity_pub_authorize_clear_domain"),
        "displays the clear verified domain button"
      );
      assert.ok(
        exists("#user_activity_pub_authorize_authorize_domain"),
        "displays the authorize domain button"
      );
    });

    test("pressing Enter in input triggers domain verification", async function (assert) {
      let domain = "test.com";
      let authType = "discourse";
      let requests = 0;

      pretender.post("/ap/auth/verify.json", (request) => {
        ++requests;
        assert.strictEqual(
          request.requestBody,
          `domain=${domain}&auth_type=${authType}`,
          "it sets correct request parameters"
        );
        return response({ success: true });
      });

      await render(template);

      const authTypes = selectKit("#user_activity_pub_authorize_auth_type");
      await authTypes.expand();
      await authTypes.selectRowByValue("discourse");

      await fillIn("#user_activity_pub_authorize_domain", domain);
      await triggerKeyEvent(
        "#user_activity_pub_authorize_domain",
        "keydown",
        "Enter"
      );

      assert.strictEqual(requests, 1, "performs one request");
    });

    test("clears a verified domain", async function (assert) {
      pretender.post("/ap/auth/verify.json", () => {
        return response({ success: true });
      });

      await render(template);

      const authTypes = selectKit("#user_activity_pub_authorize_auth_type");
      await authTypes.expand();
      await authTypes.selectRowByValue("discourse");

      await fillIn("#user_activity_pub_authorize_domain", "test.com");
      await click("#user_activity_pub_authorize_verify_domain");
      await click("#user_activity_pub_authorize_clear_domain");

      assert.ok(
        exists("#user_activity_pub_authorize_domain"),
        "displays the domain input"
      );
      assert.strictEqual(
        query("#user_activity_pub_authorize_domain").textContent,
        "",
        "the domain input is empty"
      );
      assert.ok(
        exists("#user_activity_pub_authorize_verify_domain"),
        "displays the verify domain button"
      );
    });

    test("authorizes a verified domain", async function (assert) {
      let authType = "discourse";

      pretender.post("/ap/auth/verify.json", () => {
        return response({ success: true });
      });

      const openStub = sinon.stub(window, "open").returns(null);

      await render(template);

      const authTypes = selectKit("#user_activity_pub_authorize_auth_type");
      await authTypes.expand();
      await authTypes.selectRowByValue("discourse");

      await fillIn("#user_activity_pub_authorize_domain", "test.com");
      await click("#user_activity_pub_authorize_verify_domain");
      await click("#user_activity_pub_authorize_authorize_domain");

      assert.true(
        openStub.calledWith(`/ap/auth/authorize/${authType}`, "_self"),
        "it loads the authorize route in the current tab"
      );
    });
  }
);
