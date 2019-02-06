require 'rails_helper'

RSpec.describe Notification, type: :model do
  before do
    notification = Notification.create
    notification.stub(:country_from_code)
      .with('country:NZ')
      .and_return('New Zealand')

    @image_upload = ImageUpload.create
  end

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

    it "returns an english country name from import_country_for_display" do
      notification = Notification.create
      notification.import_country = 'country:NZ'
      expect(notification.import_country_for_display).to eq('New Zealand')
    end
  end
end
