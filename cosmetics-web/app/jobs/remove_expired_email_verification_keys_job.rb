class RemoveExpiredEmailVerificationKeysJob < ApplicationJob
  def perform
    EmailVerificationKey.where(
      "expires_at < :now",
          now: DateTime.current
    ).delete_all
  end
end
