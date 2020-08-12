module DomainHelpers
  # rubocop:disable RSpec/AnyInstance
  def configure_requests_for_submit_domain
    Capybara.app_host = "http://#{ENV.fetch('SUBMIT_HOST')}" # For feature specs
    if defined? host!
      host! ENV.fetch("SUBMIT_HOST") # For request specs
    end
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:host).and_return(ENV.fetch("SUBMIT_HOST"))
  end

  def configure_requests_for_search_domain
    Capybara.app_host = "http://#{ENV.fetch('SEARCH_HOST')}" # For feature specs
    if defined? host!
      host! ENV.fetch("SEARCH_HOST") # For request specs
    end
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:host).and_return(ENV.fetch("SEARCH_HOST"))
  end

  def reset_domain_request_mocking
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:host).and_call_original
  end
  # rubocop:enable RSpec/AnyInstance
end
