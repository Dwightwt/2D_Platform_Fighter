## Initializes the database, which will be used for retrieving character stats.
extends Control

var database : SQLite

func _ready():
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	pass

func _process(delta):
	pass
