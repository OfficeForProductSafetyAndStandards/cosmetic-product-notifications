require "rails_helper"

RSpec.describe "Notifications files", :with_stubbed_antivirus, :with_stubbed_notify, type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:submit_user) { create(:submit_user) }

  before do
    configure_requests_for_submit_domain
    create(:responsible_person_user, user: submit_user, responsible_person: responsible_person)

    sign_in submit_user
  end

  after do
    sign_out(:submit_user)
  end

  describe "POST /notification_files" do
    context "when user is using JS upload" do
      let(:file_ids) { %w[id1 id2] }
      let(:file_names) { ["file1.zip", "file2.zip"] }
      let(:params) do
        {
          uploaded_files: file_ids,
          uploaded_files_names: file_names,
        }
      end

      it "processes upload using DirectUploadHandler" do
        handler = double
        expect(DirectUploadHandler).to receive(:new).with(file_ids, file_names, responsible_person.id, submit_user.id) { handler }
        expect(handler).to receive(:call)

        post "/responsible_persons/#{responsible_person.id}/notification_files", params: params
      end
    end
  end
end
