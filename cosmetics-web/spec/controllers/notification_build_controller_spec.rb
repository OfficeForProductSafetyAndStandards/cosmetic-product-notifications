require 'rails_helper'

RSpec.describe NotificationBuildController, type: :controller do
  let(:notification) { create(:notification) }
  let(:file) { fixture_file_upload('/testImage.png', 'image/png') }
  let(:text_file) { fixture_file_upload('/testText.txt', 'application/text') }

  before do
    sign_in_as_member_of_responsible_person(create(:responsible_person))
  end

  after do
    sign_out
  end

  describe "GET #new" do
    it "redirects to the first step of the manual web form" do
      get(:new, params: { notification_id: notification.reference_number })
      expect(response).to redirect_to(
        notification_build_path(notification.reference_number, "add_product_name")
)
    end
  end

  describe "GET #show" do
    it "assigns the correct notification" do
      get(:show, params: { notification_id: notification.reference_number, id: 'add_product_name' })
      expect(assigns(:notification)).to eq(notification)
    end

    it "renders the step template" do
      get(:show, params: { notification_id: notification.reference_number, id: 'add_product_name' })
      expect(response).to render_template(:add_product_name)
    end

    it "redirects to the check your answers page on finish" do
      get(:show, params: { notification_id: notification.reference_number, id: 'wicked_finish' })
      expect(response).to redirect_to(edit_notification_path(notification))
    end
  end

  describe "POST #update" do
    it "assigns the correct notification" do
      post(:update, params: { notification_id: notification.reference_number, id: 'add_product_name',
                  notification: { product_name: 'Super Shampoo' } })
      expect(assigns(:notification)).to eq(notification)
    end

    it "updates notification parameters if present" do
      post(:update, params: { notification_id: notification.reference_number, id: 'add_product_name',
                    notification: { product_name: 'Super Shampoo' } })
      expect(notification.reload.product_name).to eq('Super Shampoo')
    end

    it "creates a component if single_or_multi_component set to single" do
      post(:update, params: { notification_id: notification.reference_number, id: 'single_or_multi_component',
                    single_or_multi_component: "single" })
      expect(notification.components).to have(1).item
    end

    # TODO COSBETA-10 Update this test
    it "throws an exception if single_or_multi_component set to multiple" do
      post(:update, params: { notification_id: notification.reference_number, id: 'single_or_multi_component',
                  single_or_multi_component: "multiple" })
      expect(notification.components).to have(1).item
    end

    it "adds errors if single_or_multi_component is empty" do
      post(:update, params: { notification_id: notification.reference_number, id: 'single_or_multi_component',
                              single_or_multi_component: nil })
      expect(assigns(:notification).errors[:components]).to include('Must not be nil')
    end

    it "redirects to add_import_country step if is_imported set to true" do
      post(:update, params: { notification_id: notification.reference_number, id: 'is_imported',
                              is_imported: "true" })
      expect(response).to redirect_to(notification_build_path(notification, :add_import_country))
    end

    it "skips add_import_country step if is_imported set to false" do
      post(:update, params: { notification_id: notification.reference_number, id: 'is_imported',
                              is_imported: "false" })
      expect(response).to redirect_to(notification_build_path(notification, :single_or_multi_component))
    end

    it "adds an error if user doesn't pick a radio option for is_imported" do
      post(:update, params: { notification_id: notification.reference_number, id: 'is_imported',
                              is_imported: nil })
      expect(assigns(:notification).errors[:import_country]).to include('Must not be nil')
    end

    it "adds an error if user submits import_country with a blank value" do
      post(:update, params: { notification_id: notification.reference_number, id: 'add_import_country',
                    notification: { import_country: '' } })
      expect(assigns(:notification).errors[:import_country]).to include('Must not be blank')
    end

    it "continues to next step if user submits import_country with a valid value" do
      post(:update, params: { notification_id: notification.reference_number, id: 'add_import_country',
                    notification: { import_country: 'France' } })
      expect(response).to redirect_to(notification_build_path(notification, :single_or_multi_component))
    end

    it "adds image files to a notification in the add_product_image step" do
      post(:update, params: { notification_id: notification.reference_number, id: 'add_product_image',
                    image_upload: [file] })
      expect(assigns[:notification].image_uploads.first.file.filename).to eq('testImage.png')
    end

    it "adds errors if user does not upload images in the add_product_image step" do
      post(:update, params: { notification_id: notification.reference_number, id: 'add_product_image',
        image_upload: [] })
      expect(assigns[:notification].errors[:image_uploads]).to include('You must upload at least one product image')
    end

    it "adds errors if the user uploads an incorrect file type as a label image" do
      post(:update, params: { notification_id: notification.reference_number, id: 'add_product_image',
        image_upload: [text_file] })
      expect(assigns[:notification].image_uploads.first.errors[:file])
        .to include("must be one of image/jpeg, application/pdf, image/png, image/svg+xml")
    end
  end
end
