class AddTriggerRulesToComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :trigger_questions do |t|
      t.string :question

      t.timestamps
    end

    add_reference :trigger_questions, :component, foreign_key: true, index: false
    add_index :trigger_questions, :component_id, algorithm: :concurrently

    create_table :trigger_question_elements do |t|
      t.integer :answer_order
      t.string :answer
      t.integer :element_order
      t.string :element

      t.timestamps
    end

    add_reference :trigger_question_elements, :trigger_question, foreign_key: true, index: false
    add_index :trigger_question_elements, :trigger_question_id, algorithm: :concurrently
  end
end
