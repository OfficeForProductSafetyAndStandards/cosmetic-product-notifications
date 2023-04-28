class HelpController < PubliclyAccessibleController
  skip_before_action :require_secondary_authentication

  def terms_and_conditions; end

  def privacy_notice; end

  def accessibility_statement; end

  def cookies_policy; end

  def csv
    return redirect_to "/404" unless %w[exact exact-with-multiple-shades range].include?(params[:csv_file_type])
  end

  def npis_tables; end
end
