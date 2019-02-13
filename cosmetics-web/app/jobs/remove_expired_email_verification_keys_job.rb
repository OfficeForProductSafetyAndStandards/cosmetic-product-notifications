class RemoveExpiredEmailVerificationKeysJob < ApplicationJob
  def perform
      EmailVerificationKey.where(
          "expires_at < :now",
          {
            now: DateTime.now
          }
      ).delete_all
  end
end
  