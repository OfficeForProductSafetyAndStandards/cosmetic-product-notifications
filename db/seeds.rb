# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
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