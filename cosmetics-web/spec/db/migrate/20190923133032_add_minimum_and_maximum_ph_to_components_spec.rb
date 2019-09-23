require 'rails_helper'
require Rails.root.join('db', 'migrate', '20190923133032_add_minimum_and_maximum_ph_to_components.rb')

RSpec.describe AddMinimumAndMaximumPhToComponents do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
  let(:previous_version) { 20190614185308 }
  let(:current_version) { 20190923133032 }

  around do |example|
    # Silence migrations output in specs report.
    ActiveRecord::Migration.suppress_messages do
      example.run

      Component.reset_column_information
      TriggerQuestion.reset_column_information
      TriggerQuestionElement.reset_column_information
    end
  end

  describe "#up" do
    before do
      ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
    end

    context 'when there is a component with a PH answer' do
      let!(:component) { create(:component) }

      before do
        trigger_question = create(:trigger_question,
                                  component_id: component.id,
                                  question: 'please_indicate_the_ph')

        create(:trigger_question_element,
               trigger_question: trigger_question,
               answer: '2.3')

        ActiveRecord::Migrator.new(:up, migrations, current_version).migrate

        # Reload component from the database
        component.reload
      end

      it 'updates the component with a minimum pH' do
        expect(component.minimum_ph).to be 2.3
      end

      it 'updates the component with a maximum pH' do
        expect(component.maximum_ph).to be 2.3
      end
    end

    context 'when there is a component with a PH empty string answer' do
      let!(:component) { create(:component) }

      before do
        trigger_question = create(:trigger_question,
                                  component_id: component.id,
                                  question: 'please_indicate_the_ph')

        create(:trigger_question_element,
               trigger_question: trigger_question,
               answer: '')

        ActiveRecord::Migrator.new(:up, migrations, current_version).migrate

        # Reload component from the database
        component.reload
      end

      it 'updates the component with a minimum pH' do
        expect(component.minimum_ph).to be_nil
      end

      it 'updates the component with a maximum pH' do
        expect(component.maximum_ph).to be_nil
      end
    end
  end

  describe "#down" do
    context "when there is a component with no PH range" do
      let!(:component) { create(:component, minimum_ph: nil, maximum_ph: nil) }
      let(:trigger_questions_count) { TriggerQuestion.where(component_id: component.id).count }

      before do
        ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
      end

      it "does not create a trigger questions for the component" do
        expect(trigger_questions_count).to be 0
      end
    end

    context "when there is a component with an equal min and max PH" do
      let!(:component) { create(:component, minimum_ph: 3.2, maximum_ph: 3.2) }

      let(:trigger_questions_count) { TriggerQuestion.where(component_id: component.id).count }
      let(:trigger_question) { TriggerQuestion.find_by(component_id: component.id) }
      let(:trigger_question_element) { TriggerQuestionElement.find_by(trigger_question_id: trigger_question.id) }

      before do
        ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
      end

      it "creates a single trigger question for the component" do
        expect(trigger_questions_count).to be 1
      end

      it "creates a trigger question with the question 'please_indicate_the_ph'" do
        expect(trigger_question.question).to eq 'please_indicate_the_ph'
      end

      it "creates a trigger question with applicable being true" do
        expect(trigger_question.applicable).to be true
      end

      it "creates a trigger question element with the answer '3.2'" do
        expect(trigger_question_element.answer).to eq '3.2'
      end

      it "creates a trigger question element with the element 'ph'" do
        expect(trigger_question_element.element).to eq 'ph'
      end
    end

    context "when there is a component with min and max PH that’s different" do
      before { create(:component, minimum_ph: 3.2, maximum_ph: 3.4) }

      it "raises an error" do
        expect {
          ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
        }.to raise_error(StandardError)
      end
    end
  end
end
