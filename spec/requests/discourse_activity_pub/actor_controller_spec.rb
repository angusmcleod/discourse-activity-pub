# frozen_string_literal: true

RSpec.describe DiscourseActivityPub::ActorController do
  let!(:actor1) { Fabricate(:discourse_activity_pub_actor_group) }
  let!(:actor2) { Fabricate(:discourse_activity_pub_actor_group, local: false, model: nil) }

  describe "#follow" do
    context "with activity pub enabled" do
      before do
        toggle_activity_pub(actor1.model)
      end

      context "with a normal user" do
        let(:user) { Fabricate(:user) }

        before do
          sign_in(user)
        end

        it "returns an unauthorized error" do
          post "/ap/actor/#{actor1.id}/follow"
          expect(response.status).to eq(403)
        end
      end

      context "with an admin user" do
        let(:admin) { Fabricate(:user, admin: true) }

        before do
          sign_in(admin)
        end

        context "with an invalid actor id" do
          it "returns a not found error" do
            post "/ap/actor/#{actor1.id + 50}/follow", params: { follow_actor_id: actor2.id }
            expect(response.status).to eq(404)
          end
        end

        context "with a valid actor id" do

          context "with an invalid follow actor id" do
            it "returns a not found error" do
              post "/ap/actor/#{actor1.id}/follow", params: { follow_actor_id: actor2.id + 50 }
              expect(response.status).to eq(404)
            end
          end

          context "with a valid follow actor id" do

            context "with an actor that cant follow other actors" do
              let!(:actor3) { Fabricate(:discourse_activity_pub_actor_service) }
              
              it "returns a not authorized error" do
                post "/ap/actor/#{actor3.id}/follow", params: { follow_actor_id: actor2.id }
                expect(response.status).to eq(401)
              end
            end

            context "with an actor that can follow other actors" do
              it "initiates a follow" do
                DiscourseActivityPub::FollowHandler.expects(:perform).with(actor1.id, actor2.id)
                post "/ap/actor/#{actor1.id}/follow", params: { follow_actor_id: actor2.id }
                expect(response.status).to eq(200)
              end
    
              it "returns a success when follow is enqueued" do
                DiscourseActivityPub::FollowHandler.expects(:perform).with(actor1.id, actor2.id).returns(true)
                post "/ap/actor/#{actor1.id}/follow", params: { follow_actor_id: actor2.id }
                expect(response.status).to eq(200)
                expect(response.parsed_body['success']).to eq('OK')
              end
    
              it "returns a failure when follow is not enqueued" do
                DiscourseActivityPub::FollowHandler.expects(:perform).with(actor1.id, actor2.id).returns(false)
                post "/ap/actor/#{actor1.id}/follow", params: { follow_actor_id: actor2.id }
                expect(response.status).to eq(200)
                expect(response.parsed_body['failed']).to eq('FAILED')
              end
            end
          end
        end
      end
    end
  end

  describe "#find_by_handle" do
    context "with activity pub enabled" do
      before do
        toggle_activity_pub(actor1.model)
      end

      context "with a normal user" do
        let(:user) { Fabricate(:user) }

        before do
          sign_in(user)
        end

        it "returns an unauthorized error" do
          get "/ap/actor/#{actor1.id}/find-by-handle"
          expect(response.status).to eq(403)
        end
      end

      context "with an admin user" do
        let(:admin) { Fabricate(:user, admin: true) }

        before do
          sign_in(admin)
        end

        context "with an invalid actor id" do
          it "returns a not found error" do
            get "/ap/actor/#{actor1.id + 50}/find-by-handle", params: { handle: actor2.handle }
            expect(response.status).to eq(404)
          end
        end

        context "with a valid actor id" do

          context "when the actor cant be found" do
            let!(:handle) { "wrong@handle.com" }

            it "returns failed json" do
              DiscourseActivityPubActor.expects(:find_by_handle).with(handle).returns(nil)
              get "/ap/actor/#{actor1.id}/find-by-handle", params: { handle: handle }
              expect(response.status).to eq(200)
              expect(response.parsed_body['failed']).to eq('FAILED')
            end
          end

          context "when the actor can be found" do
            let!(:handle) { actor2.handle }

            it "returns the actor" do
              DiscourseActivityPubActor.expects(:find_by_handle).with(handle).returns(actor2)
              get "/ap/actor/#{actor1.id}/find-by-handle", params: { handle: actor2.handle }
              expect(response.status).to eq(200)
              expect(response.parsed_body['actor']['id']).to eq(actor2.id)
            end
          end
        end
      end
    end
  end
end