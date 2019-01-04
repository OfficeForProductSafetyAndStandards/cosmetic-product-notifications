class AddTriggerRuleAnswersToComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    add_reference :trigger_rule_answers, :component, index: false, foreign_key: true
    add_index :trigger_rule_answers, :component_id, algorithm: :concurrently
  end
end
