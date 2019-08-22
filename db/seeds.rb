# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

feed = Feed.where(name: "Dan Carlin's Hardcore History", url: 'https://www.dancarlin.com/dchh-feedburner.xml').first_or_initialize
url = feed.url
xml = HTTParty.get(url).body
content = Feedjira::Feed.parse_with Feedjira::Parser::ITunesRSS, xml
debugger
# Only works with code below the debugger
puts 'Script Finished'
