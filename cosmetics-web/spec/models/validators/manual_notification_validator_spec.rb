require 'rails_helper'

RSpec.describe Validators::ManualNotificationValidator do
  describe "validate notification" do
    it "adds errors if external_reference added in 'empty' state" do
      notification = Notification.create

      notification.external_reference = '12345678'
      notification.save

      check_error(:external_reference, "cannot be set at this stage")
    end
  end

  describe "validate notification" do
    it "adds errors if product_name removed in product_name_added_state" do
      notification = Notification.create(aasm_state: 'product_name_added', product_name: 'Super Shampoo')

      notification.product_name = nil
      notification.save

      check_error(:product_name, "must not be empty")
    end
  end

    private

  def check_error(attribute, error)
    expect(
      notification.errors[attribute]
    ).to include(error)
  end
end
