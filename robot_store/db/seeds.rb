# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
Robot.create(
  [
    { price: rand(0.01..2).round(8), title: 'Robo #1', avatar: "/Robo_1.png"},
    { price: rand(0.01..2).round(8), title: 'Robo #2', avatar: "/Robo_2.png"},
    { price: rand(0.01..2).round(8), title: 'Robo #3', avatar: "/Robo_3.png"},
    { price: rand(0.01..2).round(8), title: 'Robo #4', avatar: "/Robo_4.png"},
    { price: rand(0.01..2).round(8), title: 'Robo #5', avatar: "/Robo_5.png"},
    { price: rand(0.01..2).round(8), title: 'Robo #6', avatar: "/Robo_6.png"},
  ]
)

