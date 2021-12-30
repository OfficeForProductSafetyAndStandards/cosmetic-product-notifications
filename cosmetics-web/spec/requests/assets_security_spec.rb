require "rails_helper"

RSpec.describe "Asset security", type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }

  let(:notification) { create(:notification, responsible_person: responsible_person) }
  let(:image_upload) { create(:image_upload, filename: "fooFile", notification: notification) }
  let(:signed_id) { image_upload.file.signed_id }

  before do
    image_upload
  end

  context "when using generic active storage urls" do
    context "when using blobs redirect controller" do
      # /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                                 active_storage/blobs/redirect#show
      # /rails/active_storage/blobs/:signed_id/*filename(.:format)                                          active_storage/blobs/redirect#show
      let(:redirect_url) { rails_blob_path(image_upload.file) }

      it "redirects" do
        get redirect_url

        expect(response).to redirect_to("/")
      end
    end

    context "when using representations redirect controller" do
      # /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format)   active_storage/representations/redirect#show
      # /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)            active_storage/representations/redirect#show
      let(:redirect_url) { rails_blob_representation_path(signed_id, filename: "fooFile", variation_key: "fooVariation") }

      it "redirects" do
        get redirect_url

        expect(response).to redirect_to("/")
      end
    end
  end

  context "when using representations proxy controller" do # rubocop:todo RSpec/MultipleMemoizedHelpers
    # /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)      active_storage/representations/proxy#show
    let(:image_upload) do
      create(:image_upload,
             file: Rack::Test::UploadedFile.new("spec/fixtures/files/testImage.png", "image/png"),
             notification: notification)
    end
    let(:image_variant) { image_upload.file.variant(resize_to_limit: [100, 100]) }
    let(:asset_url) do
      rails_blob_representation_proxy_path(image_variant.blob.signed_id,
                                           filename: image_variant.blob.filename,
                                           variation_key: image_variant.variation.key)
    end

    context "when user is submit user" do # rubocop:todo RSpec/MultipleMemoizedHelpers
      let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }

      let(:submitted_nanomaterial_notification) { create(:nanomaterial_notification, :submitted, responsible_person: responsible_person) }

      before do
        configure_requests_for_submit_domain
      end

      context "when user is not logged in" do # rubocop:todo RSpec/MultipleMemoizedHelpers
        it "raises exception" do
          expect {
            get asset_url
          }.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      # rubocop:todo RSpec/MultipleMemoizedHelpers
      context "when logged as responsible person that is notification owner" do
        before do
          sign_in_as_member_of_responsible_person(responsible_person)
        end

        after do
          sign_out(:submit_user)
        end

        it "returns file" do
          get asset_url
          expect(response.content_type).to eq("image/png")
          expect(response.status).to eq(200)
        end
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers

      context "when logged as different responsible person" do # rubocop:todo RSpec/MultipleMemoizedHelpers
        before do
          sign_in_as_member_of_responsible_person(other_responsible_person)
        end

        after do
          sign_out(:submit_user)
        end

        it "raises authorization error" do
          expect {
            get asset_url
          }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end

    context "when user is search user" do # rubocop:todo RSpec/MultipleMemoizedHelpers
      let(:search_user) { create(:poison_centre_user) }

      before do
        configure_requests_for_search_domain
      end

      context "when user is not logged in" do # rubocop:todo RSpec/MultipleMemoizedHelpers
        it "redirects" do
          expect {
            get asset_url
          }.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "when user is logged in" do # rubocop:todo RSpec/MultipleMemoizedHelpers
        before do
          sign_in search_user
        end

        after do
          sign_out(:search_user)
        end

        it "returns file" do
          get asset_url
          expect(response.content_type).to eq("image/png")
          expect(response.status).to eq(200)
        end
      end
    end
  end

  context "when using blob asset proxy" do
    let(:asset_url) { rails_storage_proxy_path(image_upload.file) }

    context "when user is submit user" do # rubocop:todo RSpec/MultipleMemoizedHelpers
      let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }

      let(:submitted_nanomaterial_notification) { create(:nanomaterial_notification, :submitted, responsible_person: responsible_person) }

      before do
        configure_requests_for_submit_domain
      end

      context "when user is not logged in" do # rubocop:todo RSpec/MultipleMemoizedHelpers
        it "raises exception" do
          expect {
            get asset_url
          }.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      # rubocop:todo RSpec/MultipleMemoizedHelpers
      context "when logged as responsible person that is notification owner" do
        before do
          sign_in_as_member_of_responsible_person(responsible_person)
        end

        after do
          sign_out(:submit_user)
        end

        it "returns file" do
          get asset_url
          expect(response.content_type).to eq("image/png")
          expect(response.status).to eq(200)
        end
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers

      context "when logged as different responsible person" do # rubocop:todo RSpec/MultipleMemoizedHelpers
        before do
          sign_in_as_member_of_responsible_person(other_responsible_person)
        end

        after do
          sign_out(:submit_user)
        end

        it "raises authorization error" do
          expect {
            get asset_url
          }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end

    context "when user is search user" do # rubocop:todo RSpec/MultipleMemoizedHelpers
      let(:search_user) { create(:poison_centre_user) }

      before do
        configure_requests_for_search_domain
      end

      context "when user is not logged in" do # rubocop:todo RSpec/MultipleMemoizedHelpers
        it "redirects" do
          expect {
            get asset_url
          }.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      context "when user is logged in" do # rubocop:todo RSpec/MultipleMemoizedHelpers
        before do
          sign_in search_user
        end

        after do
          sign_out(:search_user)
        end

        it "returns file" do
          get asset_url
          expect(response.content_type).to eq("image/png")
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
