# Oober! A totally original idea that allows users to find drivers near them to get where they want quick.
	# I swear this will revolutionize the taxi business
	# In this scenario there are 26 locations, named after letters in the alphabet.
	# Conveniently, each location is 5 miles away from the next and they are all lined up in a perfect circle, so that "a"
	# is 5 miles from "b", 10 miles from "c", and "z" is 5 miles from "a". And yes, there is only one road (offroading
	# not currently supported).
	# There will be databases of users and drivers, and the locations of users and drivers will be updated after a
	# trip has been completed. There will also be a database of reviews containing ratings, and price and distance of a trip.

require 'sqlite3'
require 'faker'
LOCATIONS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split('')

# Create database
db = SQLite3::Database.new("oober.db")

# For testing, wipe tables each time. Comment out when done
# db.execute("DROP TABLE users")
# db.execute("DROP TABLE drivers")
# db.execute("DROP TABLE reviews")

# Create table of users
create_users_table = <<-SQL
	CREATE TABLE IF NOT EXISTS users (
		id INTEGER PRIMARY KEY,
		name VARCHAR(255),
		location VARCHAR(255)
	)
SQL

db.execute(create_users_table)

# Create table of drivers
create_drivers_table = <<-SQL
	CREATE TABLE IF NOT EXISTS drivers (
		id INTEGER PRIMARY KEY,
		driver_name VARCHAR(255),
		location VARCHAR(255)
	)
SQL

db.execute(create_drivers_table)

# Create table of reviews
create_reviews_table = <<-SQL
	CREATE TABLE IF NOT EXISTS reviews (
		id INTEGER PRIMARY KEY,
		stars INT,
		price INT,
		distance INT,
		user_id INT,
		driver_id INT,
		FOREIGN KEY (user_id) REFERENCES users(id),
		FOREIGN KEY (driver_id) REFERENCES drivers(id)
	)
SQL

db.execute(create_reviews_table)
db.results_as_hash = true

# ----- 

# Populate Users and Drivers with 5 examples. Random name and location

def create_user(database, name, location)
	database.execute("INSERT INTO users (name, location) VALUES (?, ?)", [name, location])
end

5.times do
	create_user(db, Faker::Name.name, LOCATIONS.sample)
end

def create_driver(database, name, location)
	database.execute("INSERT INTO drivers (driver_name, location) VALUES (?, ?)", [name, location])
end

5.times do
	create_driver(db, Faker::Name.name, LOCATIONS.sample)
end

# -----

# Write method that takes two locations and finds shortest distance between them. Each letter is 5 miles apart

def distance(location1, location2)
	a = LOCATIONS.index(location1)
	b = LOCATIONS.index(location2)

	if (b - a).abs > 13
		dist = 26 - (b - a).abs
	elsif (b - a).abs < 13
		dist = (b - a).abs
	else
		dist = 13
	end

	dist * 5
end

# Write method that finds closest driver to user

def closest_driver(database, user_id) # user id is NOT array index of users table, it is id of user
	closest_distance = 999999
	closest_driver_id = nil
	current_location = database.execute("SELECT * FROM users")[user_id - 1]["location"]
	drivers_hash = database.execute("SELECT * FROM drivers")
	drivers_hash.each do |driver|
		driver_location = driver["location"]
		if distance(current_location, driver_location) < closest_distance
			closest_distance = distance(current_location, driver_location)
			closest_driver_id = driver["id"]
		end
	end
	closest_driver_id
end

# Write method that calls oober. Accepts user_id and destination. Updates user and driver location, writes review

def call_oober(database, user_id, destination)
	# update locations
	driver_id = closest_driver(database, user_id)
	distance_traveled = distance(database.execute("SELECT * FROM users")[user_id - 1]["location"], destination)

	user_update_cmd = <<-SQL
		UPDATE users SET location=? WHERE id=?
	SQL
	database.execute(user_update_cmd, [destination, user_id])
	driver_update_cmd = <<-SQL
		UPDATE drivers SET location=? WHERE id=?
	SQL
	database.execute(driver_update_cmd, [destination, driver_id])

	# write review
	fare = distance_traveled * 3
	rating = rand(6)
	add_review_cmd = <<-SQL
		INSERT INTO reviews (stars, price, distance, user_id, driver_id) VALUES (?, ?, ?, ?, ?)
	SQL
	database.execute(add_review_cmd, [rating, fare, distance_traveled, user_id, driver_id])

end

# Displays

def print_users(database)
	puts "Clients: \n\n"
	user_array = database.execute("SELECT * FROM users")
	user_array.each do |user|
		puts "ID: #{user["id"]}"
		puts "Name: #{user["name"]}"
		puts "Location: #{user["location"]}"
	end
end

def print_drivers(database)
	puts "Drivers: \n\n"
	driver_array = database.execute("SELECT * FROM drivers")
	driver_array.each do |driver|
		puts "ID: #{driver["id"]}"
		puts "Name: #{driver["driver_name"]}"
		puts "Location: #{driver["location"]}"
	end
end

def print_reviews(database)
	puts "Reviews: \n\n"
	review_cmd = <<-SQL
		SELECT * FROM reviews
		JOIN users ON reviews.user_id = users.id
		JOIN drivers ON reviews.driver_id = drivers.id
	SQL
	review_array = database.execute(review_cmd)
	review_array.each do |review|
		puts "Client: #{review["name"]}"
		puts "Driver: #{review["driver_name"]}"
		puts "Rating: #{review["stars"]}"
		puts "Distance traveled: #{review["distance"]} miles"
		puts "Cost: $#{review["price"]}.00\n\n"
	end
end

# User Interface

puts "Hello! Welcome to Oober"
puts "These are our current clients \n\n"
print_users(db)
puts ""
puts ".. And our drivers\n\n"
print_drivers(db)
puts ""
loop do
	puts "Please enter the ID number of the client who is requesting an Oober, or 'exit' to quit"
	id = gets.to_i
	break if id == 'exit'.to_i
	puts "Great! And where are will they be going today? (All locations are letters of the alphabet)"
	destination = gets.chomp.upcase
	puts ""
	call_oober(db, id, destination)
	print_reviews(db)
	puts ""
end












