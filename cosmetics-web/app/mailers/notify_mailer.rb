class NotifyMailer < GovukNotifyRails::Mailer
  def self.get_mailer(user)
    return SubmitNotifyMailer if user.is_a? SubmitUser
    return SearchNotifyMailer if user.is_a? SearchUser

    raise "No Mailer for #{user.class}"
  end

  def reset_password_instructions(user, token)
    set_host(user)
    set_template(self.class::TEMPLATES[:reset_password_instruction])
    set_reference("Password reset")
    reset_url = if user.is_a? SubmitUser
                  edit_submit_user_password_url(reset_password_token: token, host: @host)
                elsif user.is_a? SearchUser
                  edit_search_user_password_url(reset_password_token: token, host: @host)
                end
    set_personalisation(
      name: user.name,
      edit_user_password_url_token: reset_url,
    )

    mail(to: user.email)
  end

  def account_locked(user, tokens)
    set_host(user)
    set_template(self.class::TEMPLATES[:account_locked])

    personalization = {
      name: user.name,
      edit_user_password_url_token: edit_submit_user_password_url(reset_password_token: tokens[:reset_password_token], host: @host),
      unlock_user_url_token: submit_user_unlock_url(unlock_token: tokens[:unlock_token], host: @host),
    }
    set_personalisation(personalization)
    mail(to: user.email)
  end

  def new_email_verification_email(user)
    set_host(user)
    set_template(self.class::TEMPLATES[:verify_new_email])
    set_reference("Send email confirmation code")

    set_personalisation(
      name: user.name,
      verify_email_url: confirm_my_account_email_url(confirmation_token: user.new_email_confirmation_token, host: @host),
    )

    mail(to: user.new_email)
    Sidekiq.logger.info "Confirmation email send"
  end

  def update_email_address_notification_email(user, old_email)
    set_host(user)
    set_template(self.class::TEMPLATES[:update_email_notification])
    set_reference("Email address updated on Submit Cosmetic Product Notifications")

    set_personalisation(
      name: user.name,
      old_email_address: old_email,
      new_email_address: user.email,
    )

    mail(to: old_email)
    Sidekiq.logger.info "Confirmation email send"
  end

private

  def set_host(user)
    if user.is_a? SubmitUser
      @host = ENV["SUBMIT_HOST"]
    end
    if user.is_a? SearchUser
      @host = ENV["SEARCH_HOST"]
    end
  end

  def submit_host
    ENV["SUBMIT_HOST"]
  end
end
