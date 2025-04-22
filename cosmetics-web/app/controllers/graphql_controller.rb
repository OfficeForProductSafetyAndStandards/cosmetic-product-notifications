# frozen_string_literal: true

class GraphqlController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :require_secondary_authentication
  skip_before_action :authorize_user!

  before_action :auth_api_key!
  before_action :verify_request_origin!
  before_action :ensure_graphql_enabled

  def execute
    Rails.logger.debug "GraphQL request parameters: #{params.to_json}"

    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    context = { current_user: }

    result = CosmeticsSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name,
    )

    Rails.logger.debug "GraphQL response result: #{result.to_json}"
    render json: result
  rescue StandardError => e
    handle_error_in_development(e)
  end

private

  def introspection_query?
    query_string = params[:query] || request.raw_post
    query_string.include?("__schema") || query_string.include?("__type")
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      variables_param.present? ? JSON.parse(variables_param) : {}
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(err)
    logger.error err.message
    logger.error err.backtrace.join("\n")
    render json: { errors: [{ message: err.message, backtrace: err.backtrace }] }, status: :internal_server_error
  end

  def secondary_authentication_user
    return nil if introspection_query?

    @secondary_authentication_user ||= User.find_by(id: session[:secondary_authentication_user_id] || user_id_for_secondary_authentication)
  end

  def auth_api_key!
    api_key = request.headers["X-API-KEY"]
    @current_api_key = ApiKey.find_by(key: api_key)

    unless @current_api_key
      render json: { error: "Unauthorized: Invalid API key" }, status: :unauthorized
      return false
    end

    true
  end

  def verify_request_origin!
    return true if Rails.env.test? || @current_api_key.present?

    origin = request.headers["Origin"]

    return true if origin.blank?

    if origin_allowed?(origin) || ip_allowed?(request.remote_ip)
      return true
    end

    render json: { error: "Unauthorized: Invalid origin" }, status: :forbidden
    false
  end

  def origin_allowed?(origin)
    return false if origin.blank?

    origin_host = begin
      URI.parse(origin).host
    rescue URI::InvalidURIError
      return false
    end

    return false if origin_host.blank?

    allowed_domains.include?(origin_host)
  end

  def allowed_domains
    @allowed_domains ||= begin
      domains = [URI.parse(ENV.fetch("APPLICATION_HOST", "http://localhost:3000")).host]

      if ENV["ALLOWED_GRAPHQL_ORIGINS"].present?
        domains.concat(ENV["ALLOWED_GRAPHQL_ORIGINS"].split(",").map(&:strip))
      end

      domains.uniq.compact
    end
  end

  def ip_allowed?(ip)
    return false if ip.blank?

    allowed_ips.any? do |allowed_ip|
      ip_matches?(ip, allowed_ip)
    end
  end

  def allowed_ips
    @allowed_ips ||= begin
      ips = []

      if ENV["ALLOWED_GRAPHQL_IPS"].present?
        ips.concat(ENV["ALLOWED_GRAPHQL_IPS"].split(",").map(&:strip))
      end

      ips.uniq.compact
    end
  end

  def ip_matches?(request_ip, allowed_ip)
    if allowed_ip.include?("/")
      require "ipaddr"
      begin
        cidr = IPAddr.new(allowed_ip)
        cidr.include?(request_ip)
      rescue IPAddr::InvalidAddressError
        Rails.logger.error("Invalid CIDR notation in allowed IPs: #{allowed_ip}")
        false
      end
    else
      request_ip == allowed_ip
    end
  end

  def ensure_graphql_enabled
    return if Rails.env.test? || feature_flag_enabled?

    render json: { error: "GraphQL is disabled" }, status: :forbidden
  end

  def feature_flag_enabled?
    Flipper.enabled?(:graphql)
  rescue StandardError
    false
  end
end
