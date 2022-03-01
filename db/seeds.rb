# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


if Rails.env.development?
  Slot.destroy_all
  UserEvent.destroy_all
  Event.destroy_all
  User.destroy_all
end

arno = User.create(username: "arno", email: "a@a.a", password: "123456", first_name: "Arno", last_name: "Debelle", company: "Meet")
oleg = User.create(username: "oleg", email: "b@b.b", password: "azerty", first_name: "Oleg", last_name: "Deru", company: "Meet")
sebastien = User.create(username: "sebastien", email: "c@c.c", password: "sebastien", first_name: "Sebastien", last_name: "Neyt", company: "Meet")
anis = User.create(username: "anis", email: "d@d.d", password: "password", first_name: "Anis", last_name: "Samimi", company: "Meet")

meeting1 = Event.create!(start_at: Time.now, end_at: Time.now + 10800, description: "Team meeting - project X", duration: 1800, user: arno)

UserEvent.create(event: meeting1, user: arno)
UserEvent.create(event: meeting1, user: oleg)
UserEvent.create(event: meeting1, user: sebastien)
UserEvent.create(event: meeting1, user: anis)

slot1 = Slot.create!(event: meeting1, start_at: Time.now, end_at: Time.now + 1800)
slot2 = Slot.create(event: meeting1, start_at: Time.now + 1800, end_at: Time.now + 3600)
slot3 = Slot.create(event: meeting1, start_at: Time.now + 3600, end_at: Time.now + 5400)

p User.last
p meeting1
p UserEvent.last
p Slot.last
