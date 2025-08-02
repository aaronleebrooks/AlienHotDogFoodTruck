extends BaseSystem

## EconomySystem
## 
## Enhanced economy system for managing money and transactions with lifecycle management.
## 
## This system handles all financial operations including money management,
## transactions, and economic statistics with advanced features including
## performance monitoring and dependency management.
## 
## Features:
##   - Money management (add, spend, check affordability)
##   - Transaction tracking and history
##   - Performance monitoring for financial operations
##   - Economic statistics and reporting
##   - Hot dog sales integration
##   - Save/load support for game state
## 
## Example:
##   economy_system.add_money(100.0, "Bonus")
##   economy_system.spend_money(50.0, "Upgrade")
##   var stats = economy_system.get_economy_stats()
## 
## @since: 1.0.0
## @category: System

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

## _ready
## 
## Initialize the economy system when the node is ready.
## 
## This function sets up the system name and connects to the enhanced
## BaseSystem lifecycle.
## 
## @since: 1.0.0
func _ready() -> void:
	"""Initialize the economy system when the node is ready"""
	# Set system name for BaseSystem
	system_name = "EconomySystem"
	
	# Call parent initialization
	super._ready()

## _initialize_system
## 
## System-specific initialization logic.
## 
## This function performs economy-specific initialization including
## setting starting money and emitting initial values.
## 
## Returns:
##   bool: True if initialization was successful, false otherwise
## 
## @since: 1.0.0
func _initialize_system() -> bool:
	"""System-specific initialization logic"""
	print("EconomySystem: Initializing economy system")
	
	# Set starting money
	current_money = starting_money
	print("EconomySystem: Starting money: $%.2f" % current_money)
	
	# Emit initial money value to update UI
	call_deferred("_emit_initial_money")
	
	return true

## _pause_system
## 
## System-specific pause logic.
## 
## This function pauses economy operations while preserving the current state.
## 
## Returns:
##   bool: True if pause was successful, false otherwise
## 
## @since: 1.0.0
func _pause_system() -> bool:
	"""System-specific pause logic"""
	print("EconomySystem: Pausing economy system")
	return true

## _resume_system
## 
## System-specific resume logic.
## 
## This function resumes economy operations from the paused state.
## 
## Returns:
##   bool: True if resume was successful, false otherwise
## 
## @since: 1.0.0
func _resume_system() -> bool:
	"""System-specific resume logic"""
	print("EconomySystem: Resuming economy system")
	return true

## _shutdown_system
## 
## System-specific shutdown logic.
## 
## This function performs economy-specific cleanup.
## 
## Returns:
##   bool: True if shutdown was successful, false otherwise
## 
## @since: 1.0.0
func _shutdown_system() -> bool:
	"""System-specific shutdown logic"""
	print("EconomySystem: Shutting down economy system")
	return true

## add_money
## 
## Add money to the economy.
## 
## This function adds money to the current balance and tracks the transaction.
## It includes performance tracking for the operation.
## 
## Parameters:
##   amount (float): Amount of money to add
##   description (String, optional): Description of the transaction
## 
## @since: 1.0.0
func add_money(amount: float, description: String = "") -> void:
	"""Add money to the economy"""
	if amount > 0 and is_system_ready():
		track_operation("add_money", func():
			current_money += amount
			total_earned += amount
			transactions_count += 1
			
			money_changed.emit(current_money, amount)
			transaction_completed.emit(amount, "income", description)
			print("EconomySystem: Added $%.2f. New total: $%.2f" % [amount, current_money])
		)

## spend_money
## 
## Spend money from the economy.
## 
## This function spends money from the current balance if sufficient funds
## are available. It includes performance tracking for the operation.
## 
## Parameters:
##   amount (float): Amount of money to spend
##   description (String, optional): Description of the transaction
## 
## Returns:
##   bool: True if money was spent successfully, false otherwise
## 
## @since: 1.0.0
func spend_money(amount: float, description: String = "") -> bool:
	"""Spend money from the economy"""
	if amount <= 0 or not is_system_ready():
		return false
		
	if current_money >= amount:
		return track_operation("spend_money", func():
			current_money -= amount
			total_spent += amount
			transactions_count += 1
			
			money_changed.emit(current_money, -amount)
			transaction_completed.emit(amount, "expense", description)
			print("EconomySystem: Spent $%.2f. New total: $%.2f" % [amount, current_money])
			return true
		)
	else:
		insufficient_funds.emit(amount, current_money)
		print("EconomySystem: Insufficient funds. Required: $%.2f, Available: $%.2f" % [amount, current_money])
		return false

## can_afford
## 
## Check if we can afford a purchase.
## 
## Parameters:
##   amount (float): Amount to check affordability for
## 
## Returns:
##   bool: True if we can afford the amount, false otherwise
## 
## @since: 1.0.0
func can_afford(amount: float) -> bool:
	"""Check if we can afford a purchase"""
	return current_money >= amount and is_system_ready()

## sell_hot_dog
## 
## Sell a hot dog.
## 
## This function adds money for a hot dog sale. It includes performance tracking.
## 
## @since: 1.0.0
func sell_hot_dog() -> void:
	"""Sell a hot dog"""
	track_operation("sell_hot_dog", func():
		add_money(hot_dog_price, "Hot dog sale")
	)

## get_current_money
## 
## Get current money amount.
## 
## Returns:
##   float: Current money balance
## 
## @since: 1.0.0
func get_current_money() -> float:
	"""Get current money amount"""
	return current_money

## set_current_money
## 
## Set current money amount (for save/load).
## 
## Parameters:
##   amount (float): New money amount
## 
## @since: 1.0.0
func set_current_money(amount: float) -> void:
	"""Set current money amount (for save/load)"""
	var old_money = current_money
	current_money = amount
	print("EconomySystem: Money set to $%.2f (was $%.2f)" % [amount, old_money])
	# Don't emit money_changed signal to avoid UI updates during load

## get_economy_stats
## 
## Get current economy statistics.
## 
## Returns:
##   Dictionary: Economy statistics including money, earnings, and transactions
## 
## @since: 1.0.0
func get_economy_stats() -> Dictionary:
	"""Get current economy statistics"""
	return {
		"current_money": current_money,
		"total_earned": total_earned,
		"total_spent": total_spent,
		"transactions_count": transactions_count,
		"hot_dog_price": hot_dog_price
	}

## _emit_initial_money
## 
## Emit initial money value to update UI.
## 
## This function is called after system initialization to ensure
## the UI displays the correct starting money amount.
## 
## @since: 1.0.0
func _emit_initial_money() -> void:
	"""Emit initial money value to update UI"""
	if is_system_ready():
		money_changed.emit(current_money, 0.0)
		print("EconomySystem: Emitted initial money: $%.2f" % current_money) 