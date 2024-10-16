class GenerateRecoveryCodes
  include Interactor

  delegate :user, to: :context

  def call
    context.fail!(error: "No user supplied") unless user

    generate_recovery_codes_for_user
  end

private

  def generate_recovery_codes_for_user
    Rails.logger.info "User #{user.email} has unused recovery codes which will be invalidated" if user.secondary_authentication_recovery_codes.present?

    user.secondary_authentication_recovery_codes_generated_at = Time.zone.now
    user.secondary_authentication_recovery_codes = Array.new(10) { rand(10_000_000..99_999_999) }
    user.secondary_authentication_recovery_codes_used = []
    user.last_recovery_code_at = nil
    user.save(validate: false)
  end
end
