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

  describe "GET #index" do
    before do
      sign_in_as_poison_centre_user
    end

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

      it "orders ingredients by name from last to first" do
        expect(response.body).to match(/Aqua.*NaCl.*Sodium/m)
      end
    end

    context "without sorting parameter" do
      before do
        get poison_centre_ingredients_path
      end

      include_examples "unique ingredient names"

      it "orders ingredients by name from last to first" do
        expect(response.body).to match(/Aqua.*NaCl.*Sodium/m)
      end
    end
  end
end
