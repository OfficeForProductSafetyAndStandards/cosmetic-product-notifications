class AuditActivity::Investigation < AuditActivity
    private_class_method def self.from(investigation)
       self.create(
           source: UserSource.new(user: current_user),
           investigation: investigation,
           title: "Case created",
       )
   end
end
