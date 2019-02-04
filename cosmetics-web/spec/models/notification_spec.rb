require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "updating product_name" do
    it "transitions state from empty to product_name_added" do
      notification = create(:notification)

      notification.product_name = 'Super Shampoo'
      notification.save

      expect(notification.state).to eq('product_name_added')
    end

    it "adds errors if product_name updated to be blank" do
      notification = create(:notification)

      notification.product_name = ''
      notification.save

      expect(notification.errors[:product_name]).to include('must not be blank')
    end
  end
end
