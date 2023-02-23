# UnusedCodeAlerting
# This class seems unused. Delete it if all methods are unused.
class Organisation < ActiveHash::Base
  include ActiveHash::Associations

  field :id
  field :name
  field :path

  has_many :users, dependent: :nullify

  def self.load(*)
    UnusedCodeAlerting.alert
  end

  def self.all(options = {})
    UnusedCodeAlerting.alert
    self.load

    if options.key?(:conditions)
      where(options[:conditions])
    else
      @records ||= []
    end
  end
end
