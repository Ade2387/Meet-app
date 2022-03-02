# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'open-uri'

if Rails.env.development?
  puts "Destroying Data Base"
  Slot.destroy_all
  UserEvent.destroy_all
  Event.destroy_all
  User.destroy_all
end

puts "Generating Seeds"

file = URI.open('https://avatars.githubusercontent.com/u/92763640?v=4')
arno = User.new(username: "arno", email: "arno@gmail.com", password: "password", first_name: "Arno", last_name: "Debelle", company: "Meet")
arno.photo.attach(io: file, filename: 'arno.jpeg', content_type: 'image/jpeg')
arno.save!

file = URI.open('https://avatars.githubusercontent.com/u/95923023?v=4')
oleg = User.new(username: "oleg", email: "oleg@gmail.com", password: "password", first_name: "Oleg", last_name: "Deru", company: "Meet")
oleg.photo.attach(io: file, filename: 'oleg.jpeg', content_type: 'image/jpeg')
oleg.save

file = URI.open('https://avatars.githubusercontent.com/u/96817348?v=4')
sebastien = User.new(username: "sebastien", email: "sebastien@gmail.com", password: "password", first_name: "Sebastien", last_name: "Neyt", company: "Meet")
sebastien.photo.attach(io: file, filename: 'sebastien.jpeg', content_type: 'image/jpeg')
sebastien.save

file = URI.open('https://avatars.githubusercontent.com/u/97437632?v=4')
anis = User.new(username: "anis", email: "anis@gmail.com", password: "password", first_name: "Anis", last_name: "Samimi", company: "Meet")
anis.photo.attach(io: file, filename: 'anis.jpeg', content_type: 'image/jpeg')
anis.save

meeting1 = Event.create!(start_time: Time.now, end_time: Time.now + 10800, name: "Team meeting", description: "project X", duration: 1800, user: arno)

UserEvent.create(event: meeting1, user: arno)
UserEvent.create(event: meeting1, user: oleg)
UserEvent.create(event: meeting1, user: sebastien)
UserEvent.create(event: meeting1, user: anis)

slot1 = Slot.create!(event: meeting1, start_time: Time.now, end_time: Time.now + 1800)
slot2 = Slot.create(event: meeting1, start_time: Time.now + 1800, end_time: Time.now + 3600)
slot3 = Slot.create(event: meeting1, start_time: Time.now + 3600, end_time: Time.now + 5400)

puts "Seeds Generated!"
