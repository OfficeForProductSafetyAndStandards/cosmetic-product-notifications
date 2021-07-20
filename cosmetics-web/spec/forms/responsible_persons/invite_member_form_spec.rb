require "rails_helper"

RSpec.describe ResponsiblePersons::InviteMemberForm do
  subject(:form) do
    described_class.new(email: email,
                        name: name,
                        responsible_person: responsible_person)
  end

  let(:email) { "invited.user@example.com" }
  let(:name) { "Invited User" }
  let(:responsible_person) { build(:responsible_person) }

  describe "#valid?" do
    before { form.validate }

    context "when all the data is present" do
      it "is valid" do
        expect(form).to be_valid
      end

      it "has no error messages" do
        expect(form.errors).to be_empty
      end
    end

    context "when the name is blank" do
      let(:name) { "" }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages_for(:name)).to eq(["Name can not be blank"])
      end
    end

    context "when the email is blank" do
      let(:email) { "" }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages_for(:email)).to eq(["Enter your email address"])
      end
    end

    context "when the email format is wrong" do
      let(:email) { "email.address.wrongly.formatted" }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages_for(:email))
          .to eq(["Enter your email address in the correct format, like name@example.com"])
      end
    end

    context "when the email belongs to the responsible person" do
      before do
        user = build_stubbed(:submit_user, email: email)
        rpu = build_stubbed(:responsible_person_user, user: user, responsible_person: responsible_person)
        responsible_person.responsible_person_users << rpu
      end

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        form.validate
        expect(form.errors.full_messages_for(:email))
          .to eq(["This email address already belongs to member of this team"])
      end
    end

    context "when the email has already been invited to the responsible person" do
      before do
        create(:pending_responsible_person_user, responsible_person: responsible_person, email_address: email)
      end

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        form.validate
        expect(form.errors.full_messages_for(:email))
          .to eq(["This person has already been invited to this team"])
      end
    end

    context "when the email has been invited to a different responsible person" do
      before do
        different_rp = create(:responsible_person)
        create(:pending_responsible_person_user, responsible_person: different_rp, email_address: email)
      end

      it "is valid" do
        expect(form).to be_valid
      end

      it "has no error messages" do
        expect(form.errors).to be_empty
      end
    end
  end
end
