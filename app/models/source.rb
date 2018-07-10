class Source < ApplicationRecord
  has_one :product, dependent: :destroy
  has_one :investigation, dependent: :destroy

  def show
    nil
  end
end
