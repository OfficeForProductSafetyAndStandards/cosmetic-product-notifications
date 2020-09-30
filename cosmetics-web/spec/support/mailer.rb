# frozen_string_literal: true

class TestNotifyEmail
  attr_reader :recipient, :reference, :template, :personalization, :action_name

  def initialize(recipient:, reference:, template:, personalization:, action_name:)
    @recipient = recipient
    @reference = reference
    @template = template
    @personalization = personalization
    @action_name = action_name
  end

  def personalization_path(param)
    uri = URI(@personalization[param])
    [uri.path, uri.query].join("?")
  end

  def personalization_value(param)
    @personalization[param]
  end
end

RSpec.shared_context "with stubbed mailer", shared_context: :metadata do
  let!(:delivered_emails) { [] }
  # rubocop:disable RSpec/AnyInstance
  before do
    allow_any_instance_of(NotifyMailer).to receive(:mail) do |m, *args|
      delivered_emails << TestNotifyEmail.new(
        recipient: args.first[:to],
        reference: m.govuk_notify_reference,
        template: m.govuk_notify_template,
        personalization: m.govuk_notify_personalisation,
        action_name: m.action_name,
      )
    end
  end
  # rubocop:enable RSpec/AnyInstance
end

RSpec.configure do |rspec|
  rspec.include_context "with stubbed mailer", with_stubbed_mailer: true
end
