require "rails_helper"

RSpec.describe SubmitUser, type: :model do
  describe ".confirm_by_token" do
    it "should return nil if no user is found" do
      expect(SubmitUser.confirm_by_token('foobar')).to be_nil
    end
  end
end
