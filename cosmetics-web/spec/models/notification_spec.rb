require 'rails_helper'

RSpec.describe Notification, type: :model do
    describe "updating product_name" do
        it "transitions aasm_state from empty to product_name_added" do
            notification = Notification.create

            notification.product_name = 'Super Shampoo'
            notification.save

            expect(notification.aasm_state).to eq('product_name_added')
        end
    end
end
