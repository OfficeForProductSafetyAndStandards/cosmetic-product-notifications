class PoisonCentres::NotificationsController < ApplicationController
  def index
    result = search_registered_notifications(10)
    @notifications = result.records
  end

  def show
    @notification = Notification.find_by reference_number: params[:reference_number]
    authorize @notification, policy_class: PoisonCentreNotificationPolicy
  end

private

  def authorize_user!
    raise Pundit::NotAuthorizedError unless poison_centre_or_msa_user?
  end

  def search_registered_notifications(page_size)
    query = ElasticsearchQuery.new(query_params[:q])
    Notification.full_search(query).paginate(page: params[:page], per_page: page_size)
  end

  def query_params
    params.permit(:q)
  end
end
