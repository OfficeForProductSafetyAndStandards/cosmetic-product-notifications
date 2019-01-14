require 'rails_helper'

RSpec.describe Validators::ManualNotificationValidator do
    describe "validate notification" do
        it "adds errors if external_reference added in 'empty' state" do
            notification = Notification.create

            notification.external_reference ='12345678'
            notification.save

            expect(
                notification.errors[:external_reference]
            ).to include('cannot be set at this stage')
        end
    end

    describe "validate notification" do
        it "adds errors if external_reference added in 'empty' state" do
            notification = Notification.create(
                :aasm_state => 'product_name_added',
                :product_name => 'Super Shampoo'
            )

            notification.product_name = nil
            notification.save

            expect(
                notification.errors[:product_name]
            ).to include('must not be empty')
        end
    end
end