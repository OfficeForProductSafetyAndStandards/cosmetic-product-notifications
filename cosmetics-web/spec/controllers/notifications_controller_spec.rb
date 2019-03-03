require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do

  before do
    sign_in_as_member_of_responsible_person(create(:responsible_person))
  end

  after do
    sign_out
  end
end
