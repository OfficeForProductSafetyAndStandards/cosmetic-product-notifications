require "rails_helper"

RSpec.describe UpdateResponsiblePersonDetails, :with_stubbed_mailer do
  let(:original_details) do
    {
      account_type: "individual",
      address_line_1: "Original street",
      address_line_2: "",
      city: "Original city",
      county: "",
      postal_code: "M11 7PE",
    }
  end

  let(:new_details) do
    {
      account_type: "business",
      address_line_1: "Office building",
      address_line_2: "Fake St",
      city: "FooBar City",
      county: "Greater FooBar",
      postal_code: "AB12 3CD",
    }
  end

  let(:user) { create(:submit_user) }
  let(:second_member) { create(:submit_user) }
  let(:third_member) { create(:submit_user) }
  let(:time_service_was_called) { Time.zone.local(2021, 11, 9) }
  let(:responsible_person) do
    create(:responsible_person,
           users: [user, second_member, third_member],
           created_at: Time.zone.local(2021, 11, 6),
           **original_details)
  end

  before do
    travel_to time_service_was_called
  end

  after do
    travel_back
  end

  it "fails when no user is provided" do
    result = described_class.call(responsible_person: responsible_person, details: new_details)
    expect(result).to be_failure
    expect(result.error).to eq "No user provided"
  end

  it "fails when no responsible person is provided" do
    result = described_class.call(user: user, details: new_details)
    expect(result).to be_failure
    expect(result.error).to eq "No Responsible Person provided"
  end

  it "fails when no details are provided" do
    result = described_class.call(user: user, responsible_person: responsible_person)
    expect(result).to be_failure
    expect(result.error).to eq "No details provided"
  end

  it "fails when given user does not belong to responsible person" do
    other_user = create(:submit_user)
    result = described_class.call(user: other_user, responsible_person: responsible_person, details: new_details)
    expect(result).to be_failure
    expect(result.error).to eq "User does not belong to Responsible Person"
  end

  it "fails when not allowed fields are provided" do
    new_details[:name] = "foobar"
    result = described_class.call(user: user, responsible_person: responsible_person, details: new_details)
    expect(result).to be_failure
    expect(result.error).to eq "Details contain invalid attributes"
  end

  context "when the provided details are the same as the original ones" do
    let!(:result) do
      described_class.call(user: user, responsible_person: responsible_person, details: original_details)
    end

    it "succeeds" do
      expect(result).to be_success
    end

    it "marks the result as unchanged" do
      expect(result.changed).to eq false
    end

    it "does not change the responsible person address values" do
      expect(responsible_person.reload).to have_attributes(original_details)
    end

    it "does not send any email" do
      expect(delivered_emails).to be_empty
    end

    it "does not record the original address for the responsible person" do
      expect(responsible_person.reload.address_logs).to be_empty
    end
  end

  context "when the business type has changed but the address has not" do
    let!(:result) do
      described_class.call(user: user,
                           responsible_person: responsible_person,
                           details: original_details.merge(account_type: "business"))
    end

    it "succeeds" do
      expect(result).to be_success
    end

    it "marks the result as changed" do
      expect(result.changed).to eq true
    end

    it "changes the responsible person business type in DB but not the address" do
      expect(responsible_person.reload).to have_attributes(original_details.merge(account_type: "business"))
    end

    it "does not send any email" do
      expect(delivered_emails).to be_empty
    end

    it "does not record the original address for the responsible person" do
      expect(responsible_person.reload.address_logs).to be_empty
    end
  end

  context "when the provided address is different from the original one" do
    context "without any exception" do
      let!(:result) do
        described_class.call(user: user, responsible_person: responsible_person, details: new_details)
      end

      it "succeeds" do
        expect(result).to be_success
      end

      it "marks the result as changed" do
        expect(result.changed).to eq true
      end

      it "update the responsible person address values" do
        expect(responsible_person.reload).to have_attributes(new_details)
      end

      it "does send an email to all the responsible person members" do
        expect(delivered_emails.size).to eq 3
      end

      # rubocop:disable RSpec/ExampleLength
      it "the user who made the edits receives a confirmation email" do
        confirmation_email = delivered_emails.find { |email| email.recipient == user.email }
        expect(confirmation_email).to have_attributes(
          reference: "Send Responsible Person address change confirmation",
          template: SubmitNotifyMailer::TEMPLATES[:responsible_person_address_change_for_author],
          personalization: {
            name: user.name,
            name_of_responsible_person: responsible_person.name,
            old_rp_address: "Original street, Original city, M11 7PE",
            new_rp_address: "Office building, Fake St, FooBar City, Greater FooBar, AB12 3CD",
          },
        )
      end

      it "other members of the responsible person receive an alert email" do
        [second_member, third_member].each do |member|
          alert_email = delivered_emails.find { |email| email.recipient == member.email }
          expect(alert_email).to have_attributes(
            reference: "Send Responsible Person address change alert",
            template: SubmitNotifyMailer::TEMPLATES[:responsible_person_address_change_for_others],
            personalization: {
              name: member.name,
              name_of_person_who_changed_rp_address: user.name,
              name_of_responsible_person: responsible_person.name,
              old_rp_address: "Original street, Original city, M11 7PE",
              new_rp_address: "Office building, Fake St, FooBar City, Greater FooBar, AB12 3CD",
            },
          )
        end
      end

      it "records the original address for the responsible person" do
        expect(responsible_person.address_logs.size).to eq 1
        expect(responsible_person.address_logs.first).to have_attributes(
          line_1: original_details[:address_line_1],
          line_2: original_details[:address_line_2],
          city: original_details[:city],
          county: original_details[:county],
          postal_code: original_details[:postal_code],
          start_date: responsible_person.created_at,
          end_date: time_service_was_called,
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context "with an exception while attempting to archive the previous address" do
      let(:address_log_stub) do
        instance_double(ResponsiblePersonAddressLog,
                        line_1: nil,
                        line_2: nil,
                        city: nil,
                        county: nil,
                        postal_code: nil,
                        start_date: nil,
                        end_date: nil)
      end
      let(:result) do
        described_class.call(user: user, responsible_person: responsible_person, details: new_details)
      end

      before do
        allow(ResponsiblePersonAddressLog).to receive(:new).and_return(address_log_stub)
        allow(address_log_stub).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        result
      end

      it "fails" do
        expect(result).to be_failure
      end

      it "reverts the Responsible Person details change" do
        expect(responsible_person.reload).to have_attributes(original_details)
      end

      it "no emails are sent" do
        expect(delivered_emails).to be_empty
      end
    end
  end
end
