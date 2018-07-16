class Source < ApplicationRecord
  belongs_to :sourceable, polymorphic: true

  def show
    nil
  end
end
