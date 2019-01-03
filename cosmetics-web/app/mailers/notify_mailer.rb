class NotifyMailer < GovukNotifyRails::Mailer
  def send_test_email(name, email)
    set_template('c6124932-1be2-483e-8be8-66dda071375e')
    set_reference('Test email')

    set_personalisation(
      name: name,
      email: email,
    )

    mail(to: email)
    puts "Email sent to #{name} at #{email}"
  end
end
