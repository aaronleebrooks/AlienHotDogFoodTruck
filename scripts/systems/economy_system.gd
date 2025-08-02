extends BaseSystem

## Economy system for managing money and transactions

# Economy settings
@export var starting_money: float = 100.0
@export var hot_dog_price: float = 5.0

# Economy state
var current_money: float = 0.0
var total_earned: float = 0.0
var total_spent: float = 0.0
var transactions_count: int = 0

# Node references
@onready var transaction_history: Node = $TransactionHistory
@onready var economy_stats: Node = $EconomyStats

# Signals
signal money_changed(new_amount: float, change: float)
signal transaction_completed(amount: float, type: String, description: String)
signal insufficient_funds(required: float, available: float)

func _ready() -> void:
	"""Initialize the economy system"""
	# Set system name for BaseSystem
	system_name = "EconomySystem"
	
	# Call parent initialization
	super._ready()
	
	# Set starting money
	current_money = starting_money
	print("EconomySystem: Starting money: $%.2f" % current_money)
	
	# Emit initial money value to update UI
	call_deferred("_emit_initial_money")

func _initialize_system() -> void:
	"""Override BaseSystem initialization"""
	print("EconomySystem: Initializing economy system")
	# Call parent initialization
	super._initialize_system()

func add_money(amount: float, description: String = "") -> void:
	"""Add money to the economy"""
	if amount > 0 and is_system_ready():
		current_money += amount
		total_earned += amount
		transactions_count += 1
		
		money_changed.emit(current_money, amount)
		transaction_completed.emit(amount, "income", description)
		print("EconomySystem: Added $%.2f. New total: $%.2f" % [amount, current_money])

func spend_money(amount: float, description: String = "") -> bool:
	"""Spend money from the economy"""
	if amount <= 0 or not is_system_ready():
		return false
		
	if current_money >= amount:
		current_money -= amount
		total_spent += amount
		transactions_count += 1
		
		money_changed.emit(current_money, -amount)
		transaction_completed.emit(amount, "expense", description)
		print("EconomySystem: Spent $%.2f. New total: $%.2f" % [amount, current_money])
		return true
	else:
		insufficient_funds.emit(amount, current_money)
		print("EconomySystem: Insufficient funds. Required: $%.2f, Available: $%.2f" % [amount, current_money])
		return false

func can_afford(amount: float) -> bool:
	"""Check if we can afford a purchase"""
	return current_money >= amount and is_system_ready()

func sell_hot_dog() -> void:
	"""Sell a hot dog"""
	add_money(hot_dog_price, "Hot dog sale")

func get_current_money() -> float:
	"""Get current money amount"""
	return current_money

func set_current_money(amount: float) -> void:
	"""Set current money amount (for save/load)"""
	var old_money = current_money
	current_money = amount
	print("EconomySystem: Money set to $%.2f (was $%.2f)" % [amount, old_money])
	# Don't emit money_changed signal to avoid UI updates during load

func get_economy_stats() -> Dictionary:
	"""Get current economy statistics"""
	return {
		"current_money": current_money,
		"total_earned": total_earned,
		"total_spent": total_spent,
		"transactions_count": transactions_count,
		"hot_dog_price": hot_dog_price
	}

func _emit_initial_money() -> void:
	"""Emit initial money value to update UI"""
	if is_system_ready():
		money_changed.emit(current_money, 0.0)
		print("EconomySystem: Emitted initial money: $%.2f" % current_money)

func cleanup() -> void:
	"""Override BaseSystem cleanup"""
	print("EconomySystem: Cleaning up economy system")
	# Call parent cleanup
	super.cleanup()

func _exit_tree() -> void:
	"""Clean up when system is removed"""
	cleanup() 