require 'rails_helper'

RSpec.describe "products/edit", type: :view do
  before do
    @product = assign(:product, Product.create!(
                                  name: "MyString"
    ))
  end

  it "renders the edit product form" do
    render
  end
end
