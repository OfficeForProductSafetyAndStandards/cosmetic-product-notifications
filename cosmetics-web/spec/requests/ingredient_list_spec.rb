require "rails_helper"

RSpec.describe "Ingredient list", type: :request do
  include RSpecHtmlMatchers

  let(:ingredient1) { create(:exact_ingredient, inci_name: "NaCl", created_at: 2.days.ago) }
  let(:ingredient2) { create(:exact_ingredient, inci_name: "Aqua", created_at: 1.week.ago) }
  let(:ingredient3) { create(:exact_ingredient, inci_name: "Sodium", created_at: 2.weeks.ago) }
  let(:ingredient4) { create(:exact_ingredient, inci_name: "Aqua", created_at: 3.weeks.ago) }

  before do
    ingredient1
    ingredient2
    ingredient3
    ingredient4
  end

  context "when signed in as a Poison Centre user" do
    before do
      sign_in_as_poison_centre_user
    end

    describe "GET #index" do
      RSpec.shared_examples "unique ingredient names" do
        it "returns unique ingredient names" do
          within("ul.govuk-list--bullet li") do
            expect(response.body).to have_tag("a.govuk-link", count: 3)
                                 .and have_tag("a.govuk-link", text: "Aqua", count: 1)
                                 .and have_tag("a.govuk-link", text: "Sodium", count: 1)
                                 .and have_tag("a.govuk-link", text: "NaCl", count: 1)
          end
        end
      end

      context "when sorting by date" do
        before do
          get poison_centre_ingredients_path(sort_by: "date")
        end

        include_examples "unique ingredient names"

        it "orders ingredients from last to first added" do
          expect(response.body).to match(/NaCl.*Sodium.*Aqua/m)
        end
      end

      context "when sorting by name_desc" do
        before do
          get poison_centre_ingredients_path(sort_by: "name_desc")
        end

        include_examples "unique ingredient names"

        it "orders ingredients by name from last to first" do
          expect(response.body).to match(/Sodium.*NaCl.*Aqua/m)
        end
      end

      context "when sorting by name_asc" do
        before do
          get poison_centre_ingredients_path(sort_by: "name_asc")
        end

        include_examples "unique ingredient names"

        it "orders ingredients by name from first to last" do
          expect(response.body).to match(/Aqua.*NaCl.*Sodium/m)
        end
      end

      context "without sorting parameter" do
        before do
          get poison_centre_ingredients_path
        end

        include_examples "unique ingredient names"

        it "orders ingredients by name from first to last" do
          expect(response.body).to match(/Aqua.*NaCl.*Sodium/m)
        end
      end
    end

    describe "GET #responsible_persons" do
      let(:notification5) { create(:notification, responsible_person: ingredient4.component.responsible_person) }
      let(:component5) { create(:exact_component, notification: notification5) }
      let(:ingredient5) { create(:exact_ingredient, inci_name: "Aqua", component: component5, created_at: 3.weeks.ago) }

      before do
        ingredient5
      end

      context "when sorting by most_notifications" do
        before do
          get poison_centre_ingredients_responsible_persons_path(ingredient_inci_name: "Aqua", sort_by: "most_notifications")
        end

        it "orders responsible persons from most to least notifications" do
          expect(response.body).to match(/#{ingredient4.component.responsible_person.name}.*#{ingredient2.component.responsible_person.name}/m)
        end
      end

      context "when sorting by name_desc" do
        before do
          get poison_centre_ingredients_responsible_persons_path(ingredient_inci_name: "Aqua", sort_by: "name_desc")
        end

        it "orders responsible persons by name from last to first" do
          expect(response.body).to match(/#{ingredient4.component.responsible_person.name}.*#{ingredient2.component.responsible_person.name}/m)
        end
      end

      context "when sorting by name_asc" do
        before do
          get poison_centre_ingredients_responsible_persons_path(ingredient_inci_name: "Aqua", sort_by: "name_asc")
        end

        it "orders responsible persons by name from first to last" do
          expect(response.body).to match(/#{ingredient2.component.responsible_person.name}.*#{ingredient4.component.responsible_person.name}/m)
        end
      end

      context "without sorting parameter" do
        before do
          get poison_centre_ingredients_responsible_persons_path(ingredient_inci_name: "Aqua")
        end

        it "orders responsible persons by name from first to last" do
          expect(response.body).to match(/#{ingredient2.component.responsible_person.name}.*#{ingredient4.component.responsible_person.name}/m)
        end
      end

      context "without ingredient name" do
        before do
          get poison_centre_ingredients_responsible_persons_path(ingredient_inci_name: "")
        end

        it "redirects to the ingredients list page" do
          expect(response).to redirect_to("/ingredients-list")
        end
      end
    end

    describe "GET #responsible_person_notifications" do
      let(:notification5) { create(:notification, product_name: "ZZZ", responsible_person: ingredient4.component.responsible_person) }
      let(:component5) { create(:exact_component, notification: notification5) }
      let(:ingredient5) { create(:exact_ingredient, inci_name: "Aqua", component: component5, created_at: 3.weeks.ago) }

      before do
        ingredient5
      end

      context "when sorting by date" do
        before do
          get poison_centre_ingredients_responsible_person_notifications_path(responsible_person_id: ingredient5.component.responsible_person.id, ingredient_inci_name: "Aqua", sort_by: "date")
        end

        it "orders notifications from last to first added" do
          expect(response.body).to match(/#{ingredient5.component.notification.product_name}.*#{ingredient4.component.notification.product_name}/m)
        end
      end

      context "when sorting by name_desc" do
        before do
          get poison_centre_ingredients_responsible_person_notifications_path(responsible_person_id: ingredient5.component.responsible_person.id, ingredient_inci_name: "Aqua", sort_by: "name_desc")
        end

        it "orders notifications by product name from last to first" do
          expect(response.body).to match(/#{ingredient5.component.notification.product_name}.*#{ingredient4.component.notification.product_name}/m)
        end
      end

      context "when sorting by name_asc" do
        before do
          get poison_centre_ingredients_responsible_person_notifications_path(responsible_person_id: ingredient5.component.responsible_person.id, ingredient_inci_name: "Aqua", sort_by: "name_asc")
        end

        it "orders notifications by product name from first to last" do
          expect(response.body).to match(/#{ingredient4.component.notification.product_name}.*#{ingredient5.component.notification.product_name}/m)
        end
      end

      context "without sorting parameter" do
        before do
          get poison_centre_ingredients_responsible_person_notifications_path(responsible_person_id: ingredient5.component.responsible_person.id, ingredient_inci_name: "Aqua")
        end

        it "orders notifications by product name from first to last" do
          expect(response.body).to match(/#{ingredient4.component.notification.product_name}.*#{ingredient5.component.notification.product_name}/m)
        end
      end

      context "without ingredient name" do
        before do
          get poison_centre_ingredients_responsible_person_notifications_path(responsible_person_id: ingredient5.component.responsible_person.id, ingredient_inci_name: "")
        end

        it "redirects to the ingredients list page" do
          expect(response).to redirect_to("/ingredients-list")
        end
      end
    end
  end

  context "when signed in as an OPSS General user" do
    before do
      sign_in_as_opss_general_user
    end

    describe "GET #index" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_path
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end

    describe "GET #responsible_persons" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_responsible_persons_path(ingredient_inci_name: "Aqua")
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end

    describe "GET #responsible_person_notifications" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_responsible_person_notifications_path(responsible_person_id: ingredient2.component.responsible_person.id, ingredient_inci_name: "Aqua")
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end
  end

  context "when signed in as an OPSS Enforcement user" do
    before do
      sign_in_as_opss_enforcement_user
    end

    describe "GET #index" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_path
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end

    describe "GET #responsible_persons" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_responsible_persons_path(ingredient_inci_name: "Aqua")
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end

    describe "GET #responsible_person_notifications" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_responsible_person_notifications_path(responsible_person_id: ingredient2.component.responsible_person.id, ingredient_inci_name: "Aqua")
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end
  end

  context "when signed in as an OPSS Science user" do
    before do
      sign_in_as_opss_science_user
    end

    describe "GET #index" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_path
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end

    describe "GET #responsible_persons" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_responsible_persons_path(ingredient_inci_name: "Aqua")
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end

    describe "GET #responsible_person_notifications" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_responsible_person_notifications_path(responsible_person_id: ingredient2.component.responsible_person.id, ingredient_inci_name: "Aqua")
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end
  end

  context "when signed in as a Trading Standards user" do
    before do
      sign_in_as_trading_standards_user
    end

    describe "GET #index" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_path
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end

    describe "GET #responsible_persons" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_responsible_persons_path(ingredient_inci_name: "Aqua")
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end

    describe "GET #responsible_person_notifications" do
      context "when visiting the page" do
        before do
          get poison_centre_ingredients_responsible_person_notifications_path(responsible_person_id: ingredient2.component.responsible_person.id, ingredient_inci_name: "Aqua")
        end

        it "redirects to the root page" do
          expect(response).to redirect_to("/")
        end
      end
    end
  end
end
