class InvestigationPresenter < SimpleDelegator
  def tabs
    [
      Tab.new("activity", "Activity", "investigations/tabs/activity"),
      Tab.new("contacts", "Contacts", "investigations/tabs/contacts"),
      Tab.new("attachments", "Attachments", "investigations/tabs/attachments"),
      Tab.new("products", "Products", "investigations/tabs/products"),
      Tab.new("businesses", "Businesses", "investigations/tabs/businesses"),
      Tab.new("related", "Related", "investigations/tabs/related"),
      Tab.new("full-detail", "Full detail", "investigations/tabs/details")
    ]
  end
end
