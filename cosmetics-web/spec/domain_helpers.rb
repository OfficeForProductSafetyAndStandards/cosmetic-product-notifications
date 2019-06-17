module DomainHelpers
  # rubocop:disable RSpec/AnyInstance
  def configure_requests_for_submit_domain
    allow_any_instance_of(DomainConstraint).to receive(:matches?).and_return(true)

    allow_any_instance_of(ApplicationController).to receive(:submit_domain?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:search_domain?).and_return(false)
  end

  def configure_requests_for_search_domain
    allow_any_instance_of(DomainConstraint).to receive(:matches?).and_return(true)

    allow_any_instance_of(ApplicationController).to receive(:submit_domain?).and_return(false)
    allow_any_instance_of(ApplicationController).to receive(:search_domain?).and_return(true)
  end

  def reset_domain_request_mocking
    allow_any_instance_of(DomainConstraint).to receive(:matches?).and_call_original

    allow_any_instance_of(ApplicationController).to receive(:submit_domain?).and_call_original
    allow_any_instance_of(ApplicationController).to receive(:search_domain?).and_call_original
  end
  # rubocop:enable RSpec/AnyInstance
end
