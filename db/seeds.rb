# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
def create_activity_type_if_not_exist(activity_type)
    if ActivityType.where(name: activity_type).first.nil?
        ActivityType.create(name: activity_type)
        puts "Activity type #{activity_type} created"
    else
        puts "Activity type #{activity_type} already exists"
    end
end

puts "Creating admin..."
if User.where(email: ENV["ADMIN_EMAIL"]).first.nil?
    user = User.create(
        email: ENV["ADMIN_EMAIL"],
        password: ENV["ADMIN_PASSWORD"],
        password_confirmation: ENV["ADMIN_PASSWORD"]
    )
    
    user.add_role(:user)
    user.add_role(:admin)
    user.save!
    puts "Admin created"
else
    puts "User with email #{ENV["ADMIN_EMAIL"]} already exists"
end

puts "Creating activity types..."
create_activity_type_if_not_exist "email"
create_activity_type_if_not_exist "purchase"
create_activity_type_if_not_exist "call"
create_activity_type_if_not_exist "interview"
create_activity_type_if_not_exist "visit"
create_activity_type_if_not_exist "test"
create_activity_type_if_not_exist "notification"
create_activity_type_if_not_exist "recall"
create_activity_type_if_not_exist "research"
