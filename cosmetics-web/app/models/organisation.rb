class Organisation < ActiveHash::Base
  include ActiveHash::Associations

  field :id
  field :name
  field :path

  has_many :users, dependent: :nullify

  def self.load(*); end

  def self.all(options = {})
    self.load

    if options.has_key?(:conditions)
      where(options[:conditions])
    else
      @records ||= []
    end
  end
end
