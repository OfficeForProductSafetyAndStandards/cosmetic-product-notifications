require "rails_helper"

RSpec.shared_examples "a notification search result without ingredients" do
  it "does not render ingredients" do
    expect(response.body).not_to match(/Ingredients/)
  end
end

RSpec.shared_examples "a notification search result with ingredients and their exact percentages" do
  it "renders ingredients" do
    expect(response.body).to match(/Ingredients/)
  end

  it "renders ingredients with exact percentages" do
    expect(response.body).to match("10.0%&nbsp;<abbr>w/w</abbr>")
  end
end

RSpec.shared_examples "a notification search result with ingredients but without exact percentages" do
  it "renders ingredients" do
    expect(response.body).to match(/Ingredients/)
  end

  it "renders ingredients without exact percentages" do
    expect(response.body).not_to match("10%&nbsp;w/w")
  end
end

RSpec.shared_examples "a notification search result without any component technical details" do
  it "does not render acute poisoning info" do
    expect(response.body).not_to match(/Acute poisoning information/)
  end

  it "does not render poisonous ingredients" do
    expect(response.body).not_to match(/Contains poisonous ingredients/)
  end

  it "does not render pH" do
    expect(response.body).not_to match('<dt class="govuk-summary-list__key"><abbr title="Power of hydrogen">pH</abbr></dt>')
  end

  it "does not render nanomaterials" do
    expect(response.body).not_to match(/Nanomaterials/)
  end

  it "does not render physical form" do
    expect(response.body).not_to match(/Physical form/)
  end

  it "does not render component formulations" do
    expect(response.body).not_to match(/Formulation given as/)
    expect(response.body).not_to match(/Frame formulation/)
  end

  it "does not render trigger questions" do
    expect(response.body).not_to match(/<tr class="govuk-table__row trigger-question">/)
  end

  it "does not render still on the market" do
    expect(response.body).not_to match(/Still on the market/)
  end
end

RSpec.shared_examples "a notification search result with general component technical details" do
  it "renders component formulations" do
    expect(response.body).to match(/Formulation given as/)
    expect(response.body).to match(/Frame formulation/)
  end

  it "renders nanomaterials" do
    expect(response.body).to match(/Nanomaterials/)
  end

  it "renders physical form" do
    expect(response.body).to match(/Physical form/)
  end

  it "does not render acute poisoning info" do
    expect(response.body).not_to match(/Acute poisoning information/)
  end

  it "does not render poisonous ingredients" do
    expect(response.body).not_to match(/Contains poisonous ingredients/)
  end

  it "does not render trigger questions" do
    expect(response.body).not_to match(/<tr class="govuk-table__row trigger-question">/)
  end

  it "does not render still on the market" do
    expect(response.body).not_to match(/Still on the market/)
  end
end

RSpec.shared_examples "a notification search result with contact person overview" do
  it "renders contact person overview" do
    expect(response.body).to match(/Assigned contact/)
  end
end
