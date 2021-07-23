# Base Form class to inherit from.
class Form
  include ActiveModel::Model
  include ActiveModel::Attributes

  def [](field)
    public_send(field.to_sym)
  end
end
