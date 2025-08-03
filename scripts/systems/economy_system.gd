extends Node

## EconomySystem
## 
## Economy system for managing money and transactions.
## 
## This system handles all financial operations including money management,
## transactions, and economic statistics.
## 
## Features:
##   - Money management (add, spend, check affordability)
##   - Transaction tracking and history
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
## This function sets up the economy system and initializes starting money.
## 
## @since: 1.0.0
func _ready() -> void:
	"""Initialize the economy system when the node is ready"""
	print("EconomySystem: Initializing economy system")
	
	# Set starting money
	current_money = starting_money
	print("EconomySystem: Starting money: $%.2f" % current_money)
	
	# Emit initial money value to update UI
	call_deferred("_emit_initial_money")

## add_money
## 
## Add money to the current balance.
## 
## Parameters:
##   amount (float): Amount of money to add
##   description (String): Description of the transaction
## 
## Returns:
##   bool: True if money was added successfully
## 
## @since: 1.0.0
func add_money(amount: float, description: String = "") -> bool:
	"""Add money to the current balance"""
	if amount <= 0:
		return false
	
	var old_money = current_money
	current_money += amount
	total_earned += amount
	transactions_count += 1
	
	money_changed.emit(current_money, amount)
	transaction_completed.emit(amount, "income", description)
	
	print("EconomySystem: Added $%.2f. New balance: $%.2f" % [amount, current_money])
	return true

## spend_money
## 
## Spend money from the current balance.
## 
## Parameters:
##   amount (float): Amount of money to spend
##   description (String): Description of the transaction
## 
## Returns:
##   bool: True if money was spent successfully, false if insufficient funds
## 
## @since: 1.0.0
func spend_money(amount: float, description: String = "") -> bool:
	"""Spend money from the current balance"""
	if amount <= 0:
		return false
	
	if current_money < amount:
		insufficient_funds.emit(amount, current_money)
		print("EconomySystem: Insufficient funds. Required: $%.2f, Available: $%.2f" % [amount, current_money])
		return false
	
	var old_money = current_money
	current_money -= amount
	total_spent += amount
	transactions_count += 1
	
	money_changed.emit(current_money, -amount)
	transaction_completed.emit(amount, "expense", description)
	
	print("EconomySystem: Spent $%.2f. New balance: $%.2f" % [amount, current_money])
	return true

## sell_hot_dog
## 
## Sell a hot dog and add money to the balance.
## 
## Returns:
##   bool: True if hot dog was sold successfully
## 
## @since: 1.0.0
func sell_hot_dog() -> bool:
	"""Sell a hot dog and add money to the balance"""
	return add_money(hot_dog_price, "Hot dog sale")

## get_current_money
## 
## Get the current money balance.
## 
## Returns:
##   float: Current money balance
## 
## @since: 1.0.0
func get_current_money() -> float:
	"""Get the current money balance"""
	return current_money

## can_afford
## 
## Check if the current balance can afford a purchase.
## 
## Parameters:
##   amount (float): Amount to check affordability for
## 
## Returns:
##   bool: True if the purchase can be afforded
## 
## @since: 1.0.0
func can_afford(amount: float) -> bool:
	"""Check if the current balance can afford a purchase"""
	return current_money >= amount

## get_economy_stats
## 
## Get economy statistics.
## 
## Returns:
##   Dictionary: Economy statistics including current money, totals, etc.
## 
## @since: 1.0.0
func get_economy_stats() -> Dictionary:
	"""Get economy statistics"""
	return {
		"current_money": current_money,
		"total_earned": total_earned,
		"total_spent": total_spent,
		"transactions_count": transactions_count,
		"hot_dog_price": hot_dog_price,
		"starting_money": starting_money
	}

## set_current_money
## 
## Set the current money balance (for save/load).
## 
## Parameters:
##   amount (float): New money balance
## 
## @since: 1.0.0
func set_current_money(amount: float) -> void:
	"""Set the current money balance (for save/load)"""
	var old_money = current_money
	current_money = amount
	money_changed.emit(current_money, current_money - old_money)
	print("EconomySystem: Money set to $%.2f" % amount)

## set_total_earned
## 
## Set the total earned amount (for save/load).
## 
## Parameters:
##   amount (float): New total earned amount
## 
## @since: 1.0.0
func set_total_earned(amount: float) -> void:
	"""Set the total earned amount (for save/load)"""
	total_earned = amount
	print("EconomySystem: Total earned set to $%.2f" % amount)

## set_total_spent
## 
## Set the total spent amount (for save/load).
## 
## Parameters:
##   amount (float): New total spent amount
## 
## @since: 1.0.0
func set_total_spent(amount: float) -> void:
	"""Set the total spent amount (for save/load)"""
	total_spent = amount
	print("EconomySystem: Total spent set to $%.2f" % amount)

## _emit_initial_money
## 
## Emit the initial money value to update UI.
## 
## @since: 1.0.0
func _emit_initial_money() -> void:
	"""Emit the initial money value to update UI"""
	money_changed.emit(current_money, 0.0)
	print("EconomySystem: Emitted initial money: $%.2f" % current_money) 