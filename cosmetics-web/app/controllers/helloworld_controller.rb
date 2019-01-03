class HelloworldController < ApplicationController
  def index
    TestJob.perform_later
    puts 'Testing!'
  end

  def send_email
    NotifyMailer.send_test_email('Recipient', 'user@example.com').deliver_later
  end
end
