class AuditActivity::Product::Base < AuditActivity::Base
  belongs_to :product

  private_class_method def self.from(product, investigation, title)
    activity = self.new(
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: title,
      product: product
    )
    activity.notify_relevant_users
    activity.save
  end
end
