class TriggerQuestion < ApplicationRecord
  PH_QUESTION = "please_indicate_the_ph".freeze

  belongs_to :component

  has_many :trigger_question_elements, -> { order(answer_order: :asc, element_order: :asc) }, dependent: :destroy, inverse_of: :trigger_question
  accepts_nested_attributes_for :trigger_question_elements

  validates :applicable, inclusion: { in: [true, false] }, on: :update

  # TODO: remove this after executing the rake task cleaning up orphaned trigger questions
  after_find do |trigger_question|
    if trigger_question.component_id.nil? && Rails.env.production?
      Sentry.capture_message "Orphaned TriggerQuestion has been loaded from DB. ID: #{trigger_question.id}"
    end
  end

  def ph_question?
    question == PH_QUESTION
  end
end
