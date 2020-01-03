require "rails_helper"

RSpec.describe "Manual, pre-Brexit notifications", type: :feature do

  let(:responsible_person) { create(:responsible_person_with_user) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end


  # ----- Manual, Post-Brexit --------

  # scenario "Manual, post-Brexit, exact ingredients, single item, no nanomaterials" do
  #   # TODO
  # end

  # scenario "Manual, post-Brexit, ingredient ranges, single item, no nanomaterials" do
  #   # TODO
  # end

  # scenario "Manual, post-Brexit, frame formulation, single item, no nanomaterials" do
  #   # TODO
  # end

  # scenario "Manual, post-Brexit, frame formulation (with poisonous ingredients), single item, no nanomaterials" do
  #   # TODO
  # end

  # scenario "Manual, post-Brexit, frame formulation, multi-item, no nanomaterials" do
  #   # TODO
  # end

  # scenario "Manual, post-Brexit, frame formulation, single item, with nanomaterials" do
  #   # TODO
  # end

  # scenario "Manual, post-Brexit, frame formulation, multi-item, each with nanomaterials" do
  #   # TODO
  # end
end
