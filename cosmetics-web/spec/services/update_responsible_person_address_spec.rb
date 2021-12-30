require "rails_helper"

RSpec.describe UpdateResponsiblePersonAddress, :with_stubbed_mailer do # rubocop:todo RSpec/MultipleMemoizedHelpers
  let(:original_address) do
    {
      address_line_1: "Original street",
      address_line_2: "",
      city: "Original city",
      county: "",
      postal_code: "M11 7PE",
    }
  end

  let(:new_address) do
    {
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
           **original_address)
  end

  before do
    travel_to time_service_was_called
  end

  after do
    travel_back
  end

  it "fails when no user is provided" do
    result = described_class.call(responsible_person: responsible_person, address: new_address)
    expect(result).to be_failure
    expect(result.error).to eq "No user provided"
  end

  it "fails when no responsible person is provided" do
    result = described_class.call(user: user, address: new_address)
    expect(result).to be_failure
    expect(result.error).to eq "No responsible person provided"
  end

  it "fails when no address is provided" do
    result = described_class.call(user: user, responsible_person: responsible_person)
    expect(result).to be_failure
    expect(result.error).to eq "No address provided"
  end

  it "fails when given user does not belong to responsible person" do
    other_user = create(:submit_user)
    result = described_class.call(user: other_user, responsible_person: responsible_person, address: new_address)
    expect(result).to be_failure
    expect(result.error).to eq "User does not belong to responsible person"
  end

  it "fails when fields not belonging to the RP address are provided" do
    new_address[:foo] = "bar"
    result = described_class.call(user: user, responsible_person: responsible_person, address: new_address)
    expect(result).to be_failure
    expect(result.error).to eq "Address contains unknown fields"
  end

  # rubocop:todo RSpec/MultipleMemoizedHelpers
  context "when the provided address is the same as the original address" do
    let!(:result) do
      described_class.call(user: user, responsible_person: responsible_person, address: original_address)
    end

    it "succeeds" do
      expect(result).to be_success
    end

    it "does not change the responsible person address values" do
      expect(responsible_person.reload).to have_attributes(original_address)
    end

    it "does not send any email" do
      expect(delivered_emails).to be_empty
    end

    it "does not record the original address for the responsible person" do
      expect(responsible_person.reload.address_logs).to be_empty
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  context "when the provided address is different from the original one" do # rubocop:todo RSpec/MultipleMemoizedHelpers
    context "without any exception" do # rubocop:todo RSpec/MultipleMemoizedHelpers
      let!(:result) do
        described_class.call(user: user, responsible_person: responsible_person, address: new_address)
      end

      it "succeeds" do
        expect(result).to be_success
      end

      it "update the responsible person address values" do
        expect(responsible_person.reload).to have_attributes(new_address)
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
          line_1: original_address[:address_line_1],
          line_2: original_address[:address_line_2],
          city: original_address[:city],
          county: original_address[:county],
          postal_code: original_address[:postal_code],
          start_date: responsible_person.created_at,
          end_date: time_service_was_called,
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    # rubocop:todo RSpec/MultipleMemoizedHelpers
    context "with an exception while attempting to archive the previous address" do
      let(:address_log_stub) { instance_double(ResponsiblePersonAddressLog) }
      let(:result) do
        described_class.call(user: user, responsible_person: responsible_person, address: new_address)
      end

      before do
        allow(ResponsiblePersonAddressLog).to receive(:new).and_return(address_log_stub)
        allow(address_log_stub).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        result
      end

      it "fails" do
        expect(result).to be_failure
      end

      it "does not keep the Responsible Person address update" do
        expect(responsible_person.reload).to have_attributes(original_address)
      end

      it "no emails are sent" do
        expect(delivered_emails).to be_empty
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
