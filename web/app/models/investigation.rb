class Investigation < ApplicationRecord
  include Searchable
  include Documentable

  index_name [Rails.env, "investigations"].join("_")

  settings do
    mappings do
      indexes :status, type: :keyword
    end
  end

  default_scope { order(updated_at: :desc) }

  has_many :investigation_products, dependent: :destroy
  has_many :products, through: :investigation_products

  has_many :investigation_businesses, dependent: :destroy
  has_many :businesses, through: :investigation_businesses

  has_many :activities, dependent: :destroy
  belongs_to_active_hash :assignee, class_name: "User", optional: true

  has_many_attached :documents
  has_many_attached :images

  has_one :source, as: :sourceable, dependent: :destroy
  has_one :reporter, dependent: :destroy

  accepts_nested_attributes_for :products
  accepts_nested_attributes_for :businesses
  accepts_nested_attributes_for :source
  accepts_nested_attributes_for :investigation_products, allow_destroy: true
  accepts_nested_attributes_for :investigation_businesses, allow_destroy: true

  has_paper_trail

  enum risk_level: %i[low medium serious severe], _suffix: true

  enum sensitivity: %i[low medium high], _suffix: true

  enum types: %i[case policy_question legislation_question testing_question enforcement_question other_question], _suffix: true

  def as_indexed_json(*)
    as_json.merge(status: status.downcase)
  end

  def status
    is_closed? ? "Closed" : "Open"
  end

  def is_question
    object_type == Investigation.types[:question]
  end

  def is_case
    object_type == Investigation.types[:case]
  end

  def pretty_type
    case object_type
    when types[:policy_question]..types[:other_question]
      "question"
    when types[:case]
      "case"
    end
  end
end

Investigation.import force: true # for auto sync model with elastic search
