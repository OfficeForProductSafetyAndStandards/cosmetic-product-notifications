module DomainHelpers
  # rubocop:disable RSpec/AnyInstance
  def configure_requests_for_submit_domain
    configure_request_for_domain("SUBMIT_HOST")
  end

  def configure_requests_for_search_domain
    configure_request_for_domain("SEARCH_HOST")
  end

  def configure_request_for_domain(domain_env_reference)
    Capybara.app_host = "http://#{ENV.fetch(domain_env_reference)}" # For feature specs
    if defined? host!
      host! ENV.fetch(domain_env_reference) # For request specs
    end
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:host).and_return(ENV.fetch(domain_env_reference))
    allow(ApplicationController).to receive(:default_url_options).and_return(
      host: ENV.fetch(domain_env_reference),
      port: 80,
    )
  end

  def reset_domain_request_mocking
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:host).and_call_original
  end
  # rubocop:enable RSpec/AnyInstance
end
