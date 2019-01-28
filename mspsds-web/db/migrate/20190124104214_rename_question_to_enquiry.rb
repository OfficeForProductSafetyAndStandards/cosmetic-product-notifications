class RenameQuestionToEnquiry < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        dir.up do
          execute "UPDATE investigations SET type = 'Investigation::Enquiry' WHERE type = 'Investigation::Question'"
          execute "UPDATE activities SET type = 'AuditActivity::Investigation::AddEnquiry' WHERE type = 'AuditActivity::Investigation::AddQuestion'"
        end

        dir.down do
          execute "UPDATE investigations SET type = 'Investigation::Question' WHERE type = 'Investigation::Enquiry'"
          execute "UPDATE activities SET type = 'AuditActivity::Investigation::AddQuestion' WHERE type = 'AuditActivity::Investigation::AddEnquiry'"
        end
      end
    end
  end
end
