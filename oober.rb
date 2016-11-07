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
db.execute("DROP TABLE users")
db.execute("DROP TABLE drivers")
db.execute("DROP TABLE reviews")

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
		name VARCHAR(255),
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
	database.execute("INSERT INTO drivers (name, location) VALUES (?, ?)", [name, location])
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

	#dist * 5
end

# Write method that finds closest driver to user

def closest_driver(database, user_id) # user id is array index of table
	closest_distance = 999999
	closest_driver_id = nil
	current_location = database.execute("SELECT * FROM users")[user_id]["location"]
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







