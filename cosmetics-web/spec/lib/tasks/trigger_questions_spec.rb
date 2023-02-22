require "rails_helper"
Rails.application.load_tasks

# rubocop:disable RSpec/DescribeClass
RSpec.describe "trigger_questions.rake" do
  describe "delete_orphaned" do
    subject(:task) { Rake::Task["trigger_questions:delete_orphaned"] }

    let!(:component) { create(:component) }
    let!(:trigger_question) { create(:trigger_question, component:) }
    let!(:trigger_question_element) { create(:trigger_question_element, trigger_question:) }

    before do
      allow($stdout).to receive(:puts) # Silences the output on rspec run and allow to assert over its calls.
      create(:trigger_question, :without_validations, component_id: nil)
      create(:trigger_question_element, :without_validations, trigger_question_id: nil)
    end

    after do
      # Rake tasks only run on the first invocation per suite. This re-enables the task for the next test.
      task.reenable
    end

    it "deletes the trigger question that is not associated with a component" do
      expect { task.invoke }.to change(TriggerQuestion, :count).from(2).to(1)
      expect(TriggerQuestion.last).to eq(trigger_question)
    end

    it "deletes the trigger question element that is not associated with a trigger question" do
      expect { task.invoke }.to change(TriggerQuestionElement, :count).from(2).to(1)
      expect(TriggerQuestionElement.last).to eq(trigger_question_element)
    end

    it "informs the user of the number of orphaned trigger questions and trigger question elements that were deleted" do
      task.invoke
      expect($stdout).to have_received(:puts)
                     .with("Deleting 1 orphaned trigger questions and 1 orphaned trigger question elements")
    end
  end
end
# rubocop:enable RSpec/DescribeClass
