class CreateContactPerson < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    create_table :contact_persons do |t|
      t.string :name
      t.string :email_address
      t.string :phone_number

      t.timestamps
    end

    add_reference :contact_persons, :responsible_person, foreign_key: true, index: false
    add_index :contact_persons, :responsible_person_id, algorithm: :concurrently

    ResponsiblePerson.all.each do |responsible_person|
      responsible_person.contact_persons.create(
        email_address: responsible_person.email_address,
        phone_number: responsible_person.phone_number,
        name: responsible_person.name,
      )
    end
  end

  def down
    ResponsiblePerson.all.each do |responsible_person|
      contact_person = responsible_person.contact_persons.first
      responsible_person.update(
        email_address: contact_person.email_address,
        phone_number: contact_person.phone_number,
      )
    end

    drop_table :contact_persons
  end
end
