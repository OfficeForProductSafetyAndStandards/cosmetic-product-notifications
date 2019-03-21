class Investigation::Allegation < Investigation
  validates :description, :hazard_type, :product_category, presence: true, on: :allegation_details
  validates :hazard_description, :hazard_type, :non_compliant_reason, presence: true, on: :unsafe

  # Elasticsearch index name must be declared in children and parent
  index_name [Rails.env, "investigations"].join("_")

  def self.model_name
    self.superclass.model_name
  end

  def title
    case_title
  end

  def case_type
    "allegation"
  end

private

  def create_audit_activity_for_case
    AuditActivity::Investigation::AddAllegation.from(self)
  end

  def case_title
    title = build_title_from_products || ""
    title << " – #{hazard_type}" if hazard_type.present?
    title << " (no product specified)" if products.empty?
    title.presence || "Untitled case"
  end

  def build_title_from_products
    return product_category.dup if products.empty?

    title_components = []
    title_components << "#{products.length} Products" if products.length > 1
    title_components << get_product_property_value_if_shared(:name)
    title_components << get_product_property_value_if_shared(:product_type)
    title_components.reject(&:blank?).join(", ")
  end

  def get_product_property_value_if_shared(property_name)
    first_product = products.first
    first_product[property_name] if products.drop(1).all? { |product| product[property_name] == first_product[property_name] }
  end
end
