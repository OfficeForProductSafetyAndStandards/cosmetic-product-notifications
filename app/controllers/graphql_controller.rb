# frozen_string_literal: true

class GraphqlController < ApplicationController
  # Skip CSRF protection for GraphQL requests
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  skip_before_action :require_secondary_authentication
  skip_before_action :authorize_user!
  before_action :auth_api_key!

  def execute
    Rails.logger.debug "GraphQL request parameters: #{params.to_json}"
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user:,
    }
    result = CosmeticsSchema.execute(query, variables:, context:, operation_name:)
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
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
