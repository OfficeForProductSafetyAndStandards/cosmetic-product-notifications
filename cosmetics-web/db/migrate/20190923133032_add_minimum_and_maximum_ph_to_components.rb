class AddMinimumAndMaximumPhToComponents < ActiveRecord::Migration[5.2]
  def change
    # rubocop:disable Metrics/BlockLength
    safety_assured do
      change_table :components, bulk: true do |table|
        table.float :minimum_ph
        table.float :maximum_ph
      end

      reversible do |dir|
        dir.up do
          # Copy single PH values from `TriggerQuestionElement` to both the
          # new `minimum_ph` and `maximum_ph` columns on the `Component`.
          #
          # Then delete the corresponding records from `TriggerQuestionElement`
          # and `TriggerQuestion`.
          TriggerQuestionElement
            .select("trigger_questions.*, trigger_question_elements.*")
            .joins(:trigger_question).where(
              trigger_questions: {
                question: 'please_indicate_the_ph'
              }
            ).find_each do |ph_question_answer|
            Component.where(id: ph_question_answer.component_id).update_all(
              minimum_ph: ph_question_answer.answer,
              maximum_ph: ph_question_answer.answer
            )

            TriggerQuestionElement.find(ph_question_answer.id).delete
            TriggerQuestion.find(ph_question_answer.trigger_question_id).delete
          end
        end

        dir.down do
          # Copy PH ranges from any `Component`s which have them to
          # new `TriggerQuestionElement` and `TriggerQuestion` records
          # associated with the component.
          #
          # Note: this fails if any components have a PH range where the minimum
          # and maximum PH values are different.
          Component.where.not(minimum_ph: nil).find_each do |component|
            if component.minimum_ph != component.maximum_ph
              raise ActiveRecord::IrreversibleMigration, "Cannot convert PH range #{component.minimum_ph} - #{component.maximum_ph} to a single PH value."
            end

            trigger_question = TriggerQuestion.new(
              component_id: component.id,
              question: 'please_indicate_the_ph',
              applicable: true
            )

            trigger_question.save!

            trigger_question.trigger_question_elements.create!(
              answer: component.minimum_ph,
              answer_order: 0,
              element_order: 0,
              element: 'ph'
            )
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
