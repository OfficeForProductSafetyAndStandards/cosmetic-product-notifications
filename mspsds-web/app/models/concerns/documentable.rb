module Documentable
  def document_types
    %i[correspondence_originator
       correspondence_business
       correspondence_other
       tech_specs
       test_results
       risk_assessment
       other]
  end
end
