extends Node

## Simple GameManager autoload for basic game state management

# Basic game state
var is_game_running: bool = false
var game_time: float = 0.0

# Simple signals
signal game_started
signal game_paused
signal game_resumed

func _ready() -> void:
	"""Initialize the GameManager"""
	print("GameManager: Initialized")

func _process(delta: float) -> void:
	"""Update game time when running"""
	if is_game_running:
		game_time += delta

func start_game() -> void:
	"""Start the game"""
	is_game_running = true
	game_time = 0.0
	game_started.emit()
	print("GameManager: Game started")

func pause_game() -> void:
	"""Pause the game"""
	is_game_running = false
	game_paused.emit()
	print("GameManager: Game paused")

func resume_game() -> void:
	"""Resume the game"""
	is_game_running = true
	game_resumed.emit()
	print("GameManager: Game resumed")

func get_game_time() -> float:
	"""Get current game time"""
	return game_time 