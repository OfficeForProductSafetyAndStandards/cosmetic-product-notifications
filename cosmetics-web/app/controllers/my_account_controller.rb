class MyAccountController < ApplicationController
  # Sets the ActiveStorage::Current.url_options attribute, which the disk service uses to generate URLs.
  # Include this concern in custom controllers that call ActiveStorage::Blob#url, ActiveStorage::Variant#url,
  # or ActiveStorage::Preview#url so the disk service can generate URLs using the same host, protocol,
  # and port as the current request.
  include ActiveStorage::SetCurrent
  include ResponsiblePersonConcern

  before_action :get_responsible_person, except: :show, if: -> { submit_domain? }

  def show
    if current_user.type == "SubmitUser"
      set_responsible_person if @responsible_person.nil?
      redirect_to select_responsible_persons_path if @responsible_person.nil?
    end
  end

private

  def set_responsible_person
    @responsible_person = if current_responsible_person.present?
                            current_responsible_person
                          elsif current_user.responsible_persons.size == 1
                            current_user.responsible_persons.first
                          end
  end
end
