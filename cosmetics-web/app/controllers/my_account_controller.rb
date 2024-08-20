class MyAccountController < ApplicationController
  # Sets the ActiveStorage::Current.url_options attribute, which the disk service uses to generate URLs.
  # Include this concern in custom controllers that call ActiveStorage::Blob#url, ActiveStorage::Variant#url,
  # or ActiveStorage::Preview#url so the disk service can generate URLs using the same host, protocol,
  # and port as the current request.
  include ActiveStorage::SetCurrent
  include ResponsiblePersonConcern

  before_action :set_responsible_person, :validate_responsible_person, except: :show, if: -> { submit_domain? }

  def show
    if should_redirect?
      redirect_to select_responsible_persons_path
    else
      set_responsible_person
    end
  end

private

  def should_redirect?
    current_user.type == "SubmitUser" && session[:current_responsible_person].nil? && session[:current_responsible_person_id].nil? && @responsible_person.nil?
  end

  def set_responsible_person
    @responsible_person = if current_responsible_person.present?
                            current_responsible_person
                          elsif current_user.responsible_persons.size == 1
                            current_user.responsible_persons.first
                          end

    session[:current_responsible_person] = @responsible_person
  end
end
