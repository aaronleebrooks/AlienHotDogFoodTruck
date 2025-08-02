extends Control

## Simple test script for GameManager autoload

@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var pause_button: Button = $VBoxContainer/PauseButton
@onready var resume_button: Button = $VBoxContainer/ResumeButton

func _ready() -> void:
	"""Setup test UI"""
	print("TestGameManager: Setup complete")
	
	# Connect buttons
	start_button.pressed.connect(_on_start_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	
	# Connect GameManager signals
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)

func _process(_delta: float) -> void:
	"""Update time display"""
	time_label.text = "Time: %.1fs" % GameManager.get_game_time()

func _on_start_pressed() -> void:
	GameManager.start_game()

func _on_pause_pressed() -> void:
	GameManager.pause_game()

func _on_resume_pressed() -> void:
	GameManager.resume_game()

func _on_game_started() -> void:
	print("Test: Game started")

func _on_game_paused() -> void:
	print("Test: Game paused")

func _on_game_resumed() -> void:
	print("Test: Game resumed") 