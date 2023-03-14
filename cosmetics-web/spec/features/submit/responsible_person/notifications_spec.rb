require "rails_helper"

RSpec.describe "Viewing a notification", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:single_shade_notification) { create(:notification, responsible_person:) }
  let(:single_shade_component) { create(:exact_component, :completed, :with_exact_ingredients, notification: single_shade_notification) }
  let(:multi_shade_notification) { create(:notification, responsible_person:) }
  let(:multi_shade_component) { create(:exact_component, :completed, :with_multiple_shades, notification: multi_shade_notification) }
  let(:multi_shade_ingredient1) { create(:exact_ingredient, used_for_multiple_shades: true, component: multi_shade_component) }
  let(:multi_shade_ingredient2) { create(:exact_ingredient, exact_concentration: 20, used_for_multiple_shades: false, component: multi_shade_component) }

  before do
    single_shade_component
    multi_shade_ingredient1
    multi_shade_ingredient2
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  context "when viewing a single shade notification with exact concentrations" do
    let(:user) { responsible_person.responsible_person_users.first.user }

    it "displays the ingredient concentrations" do
      visit responsible_person_notification_path(responsible_person, single_shade_notification)

      expect(body).to have_css("dd", text: /10.0%\u00A0w\/w/)
      expect(body).not_to have_css("dd", text: /Maximum concentration: 10.0%\u00A0w\/w/)
    end
  end

  context "when viewing a multi shade notification with exact concentrations" do
    let(:user) { responsible_person.responsible_person_users.first.user }

    it "displays the ingredient concentrations with prefix where applicable" do
      visit responsible_person_notification_path(responsible_person, multi_shade_notification)

      expect(body).to have_css("dd", text: /Maximum concentration: 10.0%\u00A0w\/w/)
      expect(body).to have_css("dd", text: /20.0%\u00A0w\/w/)
      expect(body).not_to have_css("dd", text: /Maximum concentration: 20.0%\u00A0w\/w/)
    end
  end
end
