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
LOCATIONS = "abcdefghijklmnopqrstuvwxyz"
