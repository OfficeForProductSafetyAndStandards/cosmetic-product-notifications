require "rails_helper"

RSpec.describe CategoryHelper, type: :helper do
  describe "#get_category_name" do
    it "returns the name for a valid category symbol" do
      expect(helper.get_category_name(:face_mask)).to eq("Face mask")
    end

    it "returns the name for a valid category string" do
      expect(helper.get_category_name("face_mask")).to eq("Face mask")
    end

    it "returns nil for an invalid category" do
      expect(helper.get_category_name(:invalid_category)).to be_nil
    end

    it "handles nil input gracefully" do
      expect(helper.get_category_name(nil)).to be_nil
    end
  end

  describe "#full_category_display_name" do
    let(:component) do
      instance_double(Component,
                      display_root_category: "Hair and scalp products",
                      display_sub_category: "Shampoo",
                      display_sub_sub_category: "Anti-dandruff")
    end

    it "returns the full category hierarchy as a string" do
      expected = "Hair and scalp products, Shampoo, Anti-dandruff"
      expect(helper.full_category_display_name(component)).to eq(expected)
    end
  end

  describe "#get_main_categories" do
    before do
      parent_categories = {}
      allow(Component).to receive_messages(get_parent_of_categories: parent_categories, categories: {
        skin_products: "Skin products",
        hair_and_scalp_products: "Hair and scalp products",
        nail_and_cuticle_products: "Nail and cuticle products",
        face_mask: "Face mask",
        shampoo: "Shampoo",
      })
      # Set up parent relationships
      parent_categories[:face_mask] = :skin_products
      parent_categories[:shampoo] = :hair_and_scalp_products
    end

    it "returns only the top-level categories" do
      expected = %i[skin_products hair_and_scalp_products nail_and_cuticle_products]
      expect(helper.get_main_categories).to match_array(expected)
    end
  end

  describe "#get_sub_categories" do
    let(:parent_of_categories) do
      {
        face_mask: :skin_products,
        eye_contour_products: :skin_products,
        shampoo: :hair_and_scalp_products,
        hair_conditioner: :hair_and_scalp_products,
      }
    end

    before do
      allow(Component).to receive(:get_parent_of_categories).and_return(parent_of_categories)
    end

    it "returns sub-categories for a valid category" do
      expect(helper.get_sub_categories(:skin_products)).to match_array(%i[face_mask eye_contour_products])
    end

    it "returns an empty array for a category with no sub-categories" do
      expect(helper.get_sub_categories(:oral_hygiene_products)).to eq([])
    end

    it "returns an empty array for nil input" do
      expect(helper.get_sub_categories(nil)).to eq([])
    end

    it "handles string input by converting to symbol" do
      expect(helper.get_sub_categories("skin_products")).to match_array(%i[face_mask eye_contour_products])
    end
  end

  describe "#has_sub_categories" do
    before do
      allow(helper).to receive(:get_sub_categories).with(:skin_products).and_return(%i[face_mask eye_contour_products])
      allow(helper).to receive(:get_sub_categories).with(:face_mask).and_return([])
      allow(helper).to receive(:get_sub_categories).with(nil).and_return([])
    end

    it "returns true when a category has sub-categories" do
      expect(helper.has_sub_categories(:skin_products)).to be true
    end

    it "returns false when a category has no sub-categories" do
      expect(helper.has_sub_categories(:face_mask)).to be false
    end

    it "returns false for nil input" do
      expect(helper.has_sub_categories(nil)).to be false
    end
  end
end
