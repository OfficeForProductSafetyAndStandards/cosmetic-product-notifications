class CreateTriggerRuleAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :trigger_rule_answers do |t|
      t.integer :question
      t.string :answer

      t.timestamps
    end
  end
end
