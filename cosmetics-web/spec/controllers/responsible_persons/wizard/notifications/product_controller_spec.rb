require "rails_helper"

RSpec.describe ResponsiblePersons::Wizard::Notifications::ProductController, :with_stubbed_antivirus, type: :controller do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:notification) { create(:notification, responsible_person: responsible_person) }
  let(:image_file) { fixture_file_upload("testImage.png", "image/png") }
  let(:text_file) { fixture_file_upload("testText.txt", "application/text") }

  let(:params) do
    {
      responsible_person_id: responsible_person.id,
      notification_reference_number: notification.reference_number,
    }
  end

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #new" do
    it "redirects to the first step of the notification submission process" do
      get(:new, params: params)
      expect(response).to redirect_to(responsible_person_notification_product_path(responsible_person, notification, :add_product_name))
    end

    it "does not allow the user to create a notification for a Responsible Person they not belong to" do
      expect {
        get(:new, params: other_responsible_person_params)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET #show" do
    it "assigns the correct notification" do
      get(:show, params: params.merge(id: :add_product_name))
      expect(assigns(:notification)).to eq(notification)
    end

    it "renders the step template" do
      get(:show, params: params.merge(id: :add_product_name))
      expect(response).to render_template(:add_product_name)
    end

    it "does not allow the user to view a notification for a Responsible Person they not belong to" do
      expect {
        get(:show, params: other_responsible_person_params.merge(id: :add_product_name))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    context "when the notification is already submitted" do
      subject(:request) { get(:show, params: params.merge({ id: "add_internal_reference" })) }

      let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

      it "redirects to the notifications page" do
        expect(request).to redirect_to(responsible_person_notification_path(responsible_person, notification))
      end
    end
  end

  describe "POST #update" do
    it "assigns the correct notification" do
      post(:update, params: params.merge(id: :add_product_name, notification: { product_name: "Super Shampoo" }))
      expect(assigns(:notification)).to eq(notification)
    end

    it "updates notification parameters if present" do
      post(:update, params: params.merge(id: :add_product_name, notification: { product_name: "Super Shampoo" }))
      expect(notification.reload.product_name).to eq("Super Shampoo")
    end

    it "creates a component if single_or_multi_component set to single" do
      post(:update, params: params.merge(id: :single_or_multi_component, single_or_multi_component_form: { single_or_multi_component: "single" }))
      Notification.find(notification.id).components
      expect(Notification.find(notification.id).components).to have(1).item
    end

    it "creates components if single_or_multi_component set to multiple" do
      post(:update, params: params.merge(id: :single_or_multi_component, single_or_multi_component_form: { single_or_multi_component: "multiple", components_count: 3 }))
      expect(Notification.find(notification.id).components).to have(3).item
    end

    it "adds errors if single_or_multi_component is empty" do
      post(:update, params: params.merge(id: :single_or_multi_component, single_or_multi_component_form: { single_or_multi_component: nil }))
      expect(assigns(:single_or_multi_component_form).errors[:single_or_multi_component]).to eql(["Select yes if the product is a multi-item kit, no if its single item"])
    end

    it "continues to next step if user submits under_three_years with a valid value" do
      post(:update, params: params.merge(id: :for_children_under_three, notification: { under_three_years: "true" }))
      expect(response).to redirect_to(responsible_person_notification_product_path(responsible_person, notification, :contains_nanomaterials))
    end

    it "adds image files to a notification in the add_product_image step" do
      post(:update, params: params.merge(id: :add_product_image, image_upload: [image_file]))
      expect(assigns[:notification].image_uploads.first.file.filename).to eq("testImage.png")
    end

    it "adds errors if user does not upload images in the add_product_image step" do
      post(:update, params: params.merge(id: :add_product_image, image_upload: []))
      expect(assigns[:notification].errors[:image_uploads]).to include("Select an image")
    end

    it "adds errors if the user uploads an incorrect file type as a label image" do
      post(:update, params: params.merge(id: :add_product_image, image_upload: [text_file]))
      expect(assigns[:notification].image_uploads.first.errors[:file])
        .to include("must be one of image/jpeg, application/pdf, image/png")
    end

    it "adds error if user doesn't select radio option on add_internal_reference page" do
      post(:update, params: params.merge(id: :add_internal_reference, notification: {}))
      expect(assigns[:notification].errors[:add_internal_reference]).to eql(["Select yes to add an internal reference"])
    end

    it "adds error if user selects add internal reference but doesn't add one on add_internal_reference page" do
      post(:update, params: params.merge(id: :add_internal_reference, notification: { add_internal_reference: "yes" }))
      expect(assigns[:notification].errors[:industry_reference]).to eql(["Enter an internal reference"])
    end

    it "stores internal reference if user adds internal reference" do
      post(:update, params: params.merge(id: :add_internal_reference,
                                         notification: { add_internal_reference: "yes", industry_reference: "12345678" }))
      expect(assigns[:notification].industry_reference).to eq("12345678")
    end

    it "does not allow the user to update a notification for a Responsible Person they not belong to" do
      expect {
        post(:update, params: other_responsible_person_params.merge(id: :add_product_name, notification: { product_name: "Super Shampoo" }))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    context "when the notification is already submitted" do
      subject(:request) { post(:update, params: params.merge(id: :add_product_name, notification: { product_name: "Super Shampoo" })) }

      let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

      it "redirects to the notifications page" do
        expect(request).to redirect_to(responsible_person_notification_path(responsible_person, notification))
      end
    end
  end

private

  def other_responsible_person_params
    other_responsible_person = create(:responsible_person)
    other_notification = create(:notification, components: [create(:component)], responsible_person: other_responsible_person)

    {
      responsible_person_id: other_responsible_person.id,
      notification_reference_number: other_notification.reference_number,
    }
  end
end
