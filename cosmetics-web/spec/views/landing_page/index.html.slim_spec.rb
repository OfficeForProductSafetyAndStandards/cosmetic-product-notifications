require 'rails_helper'

RSpec.describe "landing_page/index.html.slim", type: :view do
  it "displays the landing page title" do
    render
    expect(rendered).to match(/Register cosmetics products/)
  end
end
