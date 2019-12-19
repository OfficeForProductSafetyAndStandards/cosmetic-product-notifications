require "rails_helper"

RSpec.describe "Notifications", type: :feature do

  # Key input variables:
  #
  # 1. Using a zip file vs answering questions manually
  # 2. Pre or Post Brexit
  # 3. Specifying exact ingredients, ingredient range or a frame formulation
  # 4. Multi-item product or single item product
  # 5. Contains nanomaterials or not
  # 6. Zip file: contains ingredients or ingredients missing


  # Dependent flows:
  #
  # 1.  Is a zip file required?
  # 2.  Is the user required to name each item?
  # 3.  Are details about how multi-items are used together required?
  # 4.  Are product images required?
  # 5.  Is an ingredient list upload required?
  # 6.  Is user required to select a frame formulation?
  # 7.  Are details about nanomaterials required?
  # 8.  Is the user required to answer questions about pH of items?
  # 9.  Is user required to say if product is for under-3s?
  # 10. Is user required to say if product is imported?
  # 11. Is user required to say if product contains a hair dye?


  # ---- ZIP file, pre-Brexit ------

  scenario "Using a zip file, pre-Brexit, exact ingredients, single item, no nanomaterials" do
    # TODO
  end

  scenario "Using a zip file, pre-Brexit, ingredient ranges, single item, no nanomaterials" do
    # TODO
  end

  scenario "Using a zip file, pre-Brexit, frame formulation, single item, no nanomaterials" do
    # TODO
  end

  scenario "Using a zip file, pre-Brexit, exact ingredients (missing), single item, no nanomaterials" do
    # TODO
  end

  scenario "Using a zip file, pre-Brexit, ingredient ranges (missing), single item, no nanomaterials" do
    # TODO
  end

  scenario "Using a zip file, pre-Brexit, exact ingredients, multi-item, no nanomaterials" do
    # TODO
  end

  scenario "Using a zip file, pre-Brexit, exact ingredients, single item, with nanomaterials" do
    # TODO
  end

  scenario "Using a zip file, pre-Brexit, exact ingredients, multi-item, each with nanomaterials" do
    # TODO
  end


  # ---- ZIP file, post-Brexit ------

   scenario "Using a zip file, post-Brexit" do
    # Not currently allowed: user sees a message prompting manual journey
  end



  # ----- Manual, Pre-Brexit ---------

  scenario "Manual, pre-Brexit, exact ingredients, single item, no nanomaterials" do
    # TODO
  end

  scenario "Manual, pre-Brexit, ingredient ranges, single item, no nanomaterials" do
    # TODO
  end

  scenario "Manual, pre-Brexit, frame formulation, single item, no nanomaterials" do
    # TODO
  end

  scenario "Manual, pre-Brexit, frame formulation, multi-item, no nanomaterials" do
    # TODO
  end

  scenario "Manual, pre-Brexit, frame formulation, single item, with nanomaterials" do
    # TODO
  end

  scenario "Manual, pre-Brexit, frame formulation, multi-item, each with nanomaterials" do
    # TODO
  end



  # ----- Manual, Post-Brexit --------

  scenario "Manual, post-Brexit, exact ingredients, single item, no nanomaterials" do
    # TODO
  end

  scenario "Manual, post-Brexit, ingredient ranges, single item, no nanomaterials" do
    # TODO
  end

  scenario "Manual, post-Brexit, frame formulation, single item, no nanomaterials" do
    # TODO
  end

  scenario "Manual, post-Brexit, frame formulation (with poisonous ingredients), single item, no nanomaterials" do
    # TODO
  end

  scenario "Manual, post-Brexit, frame formulation, multi-item, no nanomaterials" do
    # TODO
  end

  scenario "Manual, post-Brexit, frame formulation, single item, with nanomaterials" do
    # TODO
  end

  scenario "Manual, post-Brexit, frame formulation, multi-item, each with nanomaterials" do
    # TODO
  end


end
