require "rails_helper"

RSpec.describe ResponsiblePersons::DetailsForm do
  subject(:form) do
    described_class.new(user: user,
                        name: name,
                        address_line_1: address_line_1,
                        address_line_2: address_line_2,
                        city: city,
                        county: county,
                        postal_code: postal_code)
  end

  let(:user) { build_stubbed(:submit_user) }
  let(:name) { "Resp person name" }
  let(:address_line_1) { "Random street" }
  let(:address_line_2) { "Random street second line" }
  let(:city) { "London" }
  let(:county) { "London" }
  let(:postal_code) { "EC1 2PE" }

  describe "#valid?" do
    context "when the name is blank" do
      let(:name) { "" }

      before { form.validate }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages_for(:name)).to eq(["Name can not be blank"])
      end
    end

    context "when the name is the same as another RP name where the user belongs to" do
      let(:user) { create(:submit_user) }

      before do
        rp = create(:responsible_person, :with_a_contact_person, name: name)
        create(:responsible_person_user, responsible_person: rp, user: user)
        form.validate
      end

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages).to eq(["You are already associated with #{name}"])
      end
    end

    context "when the name is the same with casing and leading/trailing spacing differences as another RP name where the user belongs to" do
      let(:user) { create(:submit_user) }
      let(:name) { " RESP Person Name " }

      before do
        rp = create(:responsible_person, :with_a_contact_person, name: "resp person name")
        create(:responsible_person_user, responsible_person: rp, user: user)
        form.validate
      end

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages).to eq(["You are already associated with #{name.strip}"])
      end
    end

    context "when the name is the same as another RP name where the user has an active invitation for" do
      let(:user) { create(:submit_user) }

      before do
        rp = create(:responsible_person, :with_a_contact_person, name: name)
        create(:pending_responsible_person_user, responsible_person: rp, email_address: user.email)
        form.validate
      end

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages)
          .to eq(["You have already been invited to join #{name}. Check your email inbox for your invite"])
      end
    end

    context "when the name is the same with casing and leading/trailing spacing differences as another RP name where the user has an active invitation for" do
      let(:user) { create(:submit_user) }
      let(:name) { " RESP Person Name " }

      before do
        rp = create(:responsible_person, :with_a_contact_person, name: "resp person name")
        create(:pending_responsible_person_user, responsible_person: rp, email_address: user.email)
        form.validate
      end

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages)
          .to eq(["You have already been invited to join #{name.strip}. Check your email inbox for your invite"])
      end
    end

    context "when the name is the same as another RP name where the user has an expired invitation for" do
      let(:user) { create(:submit_user) }

      before do
        rp = create(:responsible_person, :with_a_contact_person, name: name)
        create(:pending_responsible_person_user, :expired, responsible_person: rp, email_address: user.email)
        form.validate
      end

      it "is is valid" do
        expect(form).to be_valid
      end

      it "does not populate an error message" do
        expect(form.errors.full_messages).to be_empty
      end
    end

    context "when the first address line is blank" do
      let(:address_line_1) { "" }

      before { form.validate }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages).to eq(["Building and street can not be blank"])
      end
    end

    context "when the second address line is blank" do
      let(:address_line_2) { "" }

      before { form.validate }

      it "is is valid" do
        expect(form).to be_valid
      end

      it "does not populate an error message" do
        expect(form.errors.full_messages).to be_empty
      end
    end

    context "when the city is blank" do
      let(:city) { "" }

      before { form.validate }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages).to eq(["Town or city can not be blank"])
      end
    end

    context "when the county is blank" do
      let(:county) { "" }

      before { form.validate }

      it "is is valid" do
        expect(form).to be_valid
      end

      it "does not populate an error message" do
        expect(form.errors.full_messages).to be_empty
      end
    end

    context "when the postal code is blank" do
      let(:postal_code) { "" }

      before { form.validate }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages).to eq(["Postcode can not be blank"])
      end
    end

    context "when the postal code does not belong to UK" do
      let(:postal_code) { "JJJJJ" }

      before { form.validate }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages).to eq(["Enter a UK postcode"])
      end
    end

    context "when the postal code does contains leading/trailing spaces" do
      let(:postal_code) { " EC1 2PE " }

      before { form.validate }

      it "is is valid" do
        expect(form).to be_valid
      end

      it "does not populate an error message" do
        expect(form.errors.full_messages).to be_empty
      end

      it "strips the leading/trailing spaces" do
        expect(form.postal_code).to eq postal_code.strip
      end
    end
  end
end
