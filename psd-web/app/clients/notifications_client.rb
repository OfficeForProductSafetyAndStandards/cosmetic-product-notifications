class NotificationsClient
  include Singleton

  def initialize
    @client = Notifications::Client.new(ENV["NOTIFY_API_KEY"])
    super
  end

  def generate_template_preview(id, options = {})
    @client.generate_template_preview(id, options)
  end
end
