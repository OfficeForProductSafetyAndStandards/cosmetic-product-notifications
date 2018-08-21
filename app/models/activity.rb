class Activity < ApplicationRecord
  default_scope { order(created_at: :desc) }
  belongs_to :investigation
  enum activity_type: [:email,
                       :purchase,
                       :call,
                       :interview,
                       :visit,
                       :test,
                       :notification,
                       :recall,
                       :research,
                       :other,

                       # automatic types. Add to the is_automatic method
                       :assign]

  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :source

  has_paper_trail
end
