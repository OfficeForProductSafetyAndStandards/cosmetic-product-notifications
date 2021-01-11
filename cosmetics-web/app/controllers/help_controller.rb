class HelpController < PubliclyAccessibleController
  skip_before_action :require_secondary_authentication

  def terms_and_conditions; end

  def privacy_notice; end

  def accessibility_statement; end
end
