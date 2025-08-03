extends "res://scripts/test/base_test_suite.gd"

## TestEconomySystemTests
## 
## Test suite for the Economy System.
## 
## This test suite verifies the functionality of the economy system
## including money management, transactions, and hot dog sales.
## 
## @since: 1.0.0
## @category: Testing

# Test utilities
var test_utils: Object
var mock_economy: Object

## _setup
## 
## Setup the test suite environment.
func _setup() -> void:
	"""Setup the test suite environment"""
	super._setup()
	suite_name = "TestEconomySystemTests"
	
	# Load test utilities
	test_utils = preload("res://scripts/test/test_utilities.gd").new()
	
	# Create mock economy system
	mock_economy = test_utils.create_mock_economy_system(100.0, 5.0)
	
	print("TestEconomySystemTests: Setup complete")

## _cleanup
## 
## Cleanup the test suite environment.
func _cleanup() -> void:
	"""Cleanup the test suite environment"""
	# Cleanup test objects
	if test_utils:
		test_utils.cleanup_test_objects([mock_economy])
	
	super._cleanup()
	print("TestEconomySystemTests: Cleanup complete")

## test_add_money
## 
## Test adding money to the economy.
func test_add_money() -> void:
	"""Test adding money to the economy"""
	_before_test("test_add_money")
	
	var initial_money = mock_economy.get_current_money()
	var add_amount = 50.0
	
	# Test adding money
	var success = mock_economy.add_money(add_amount, "Test bonus")
	
	# Verify success
	assert_true(success, "Adding money should succeed")
	
	# Verify money was added
	var new_money = mock_economy.get_current_money()
	assert_equal(initial_money + add_amount, new_money, "Money should be increased by the added amount")
	
	# Verify stats
	var stats = mock_economy.get_economy_stats()
	assert_equal(1, stats.transactions_count, "Transaction count should be incremented")
	assert_equal(add_amount, stats.total_earned, "Total earned should be updated")
	
	_after_test("test_add_money", true)

## test_spend_money
## 
## Test spending money from the economy.
func test_spend_money() -> void:
	"""Test spending money from the economy"""
	_before_test("test_spend_money")
	
	var initial_money = mock_economy.get_current_money()
	var spend_amount = 30.0
	
	# Test spending money
	var success = mock_economy.spend_money(spend_amount, "Test purchase")
	
	# Verify success
	assert_true(success, "Spending money should succeed when sufficient funds available")
	
	# Verify money was spent
	var new_money = mock_economy.get_current_money()
	assert_equal(initial_money - spend_amount, new_money, "Money should be decreased by the spent amount")
	
	# Verify stats
	var stats = mock_economy.get_economy_stats()
	assert_equal(1, stats.transactions_count, "Transaction count should be incremented")
	assert_equal(spend_amount, stats.total_spent, "Total spent should be updated")
	
	_after_test("test_spend_money", true)

## test_insufficient_funds
## 
## Test spending money when insufficient funds are available.
func test_insufficient_funds() -> void:
	"""Test spending money when insufficient funds are available"""
	_before_test("test_insufficient_funds")
	
	var initial_money = mock_economy.get_current_money()
	var spend_amount = initial_money + 100.0  # More than available
	
	# Test spending more than available
	var success = mock_economy.spend_money(spend_amount, "Expensive purchase")
	
	# Verify failure
	assert_false(success, "Spending money should fail when insufficient funds")
	
	# Verify money was not spent
	var new_money = mock_economy.get_current_money()
	assert_equal(initial_money, new_money, "Money should remain unchanged")
	
	# Verify stats were not updated
	var stats = mock_economy.get_economy_stats()
	assert_equal(0, stats.transactions_count, "Transaction count should not be incremented")
	assert_equal(0.0, stats.total_spent, "Total spent should not be updated")
	
	_after_test("test_insufficient_funds", true)

## test_sell_hot_dog
## 
## Test selling a hot dog.
func test_sell_hot_dog() -> void:
	"""Test selling a hot dog"""
	_before_test("test_sell_hot_dog")
	
	var initial_money = mock_economy.get_current_money()
	var hot_dog_price = mock_economy.hot_dog_price
	
	# Test selling hot dog
	var success = mock_economy.sell_hot_dog()
	
	# Verify success
	assert_true(success, "Selling hot dog should succeed")
	
	# Verify money was added
	var new_money = mock_economy.get_current_money()
	assert_equal(initial_money + hot_dog_price, new_money, "Money should be increased by hot dog price")
	
	# Verify stats
	var stats = mock_economy.get_economy_stats()
	assert_equal(1, stats.transactions_count, "Transaction count should be incremented")
	assert_equal(hot_dog_price, stats.total_earned, "Total earned should be updated")
	
	_after_test("test_sell_hot_dog", true)

## test_can_afford
## 
## Test checking if a purchase can be afforded.
func test_can_afford() -> void:
	"""Test checking if a purchase can be afforded"""
	_before_test("test_can_afford")
	
	var current_money = mock_economy.get_current_money()
	
	# Test affordable purchase
	var can_afford_small = mock_economy.can_afford(current_money * 0.5)
	assert_true(can_afford_small, "Should be able to afford purchase less than current money")
	
	# Test exact amount
	var can_afford_exact = mock_economy.can_afford(current_money)
	assert_true(can_afford_exact, "Should be able to afford purchase equal to current money")
	
	# Test unaffordable purchase
	var can_afford_large = mock_economy.can_afford(current_money + 100.0)
	assert_false(can_afford_large, "Should not be able to afford purchase greater than current money")
	
	_after_test("test_can_afford", true)

## test_economy_stats
## 
## Test getting economy statistics.
func test_economy_stats() -> void:
	"""Test getting economy statistics"""
	_before_test("test_economy_stats")
	
	# Get initial stats
	var initial_stats = mock_economy.get_economy_stats()
	
	# Verify initial stats
	assert_equal(100.0, initial_stats.current_money, "Initial money should be 100.0")
	assert_equal(0.0, initial_stats.total_earned, "Initial total earned should be 0.0")
	assert_equal(0.0, initial_stats.total_spent, "Initial total spent should be 0.0")
	assert_equal(0, initial_stats.transactions_count, "Initial transaction count should be 0")
	assert_equal(5.0, initial_stats.hot_dog_price, "Hot dog price should be 5.0")
	assert_equal(100.0, initial_stats.starting_money, "Starting money should be 100.0")
	
	# Perform some transactions
	mock_economy.add_money(50.0, "Bonus")
	mock_economy.spend_money(25.0, "Purchase")
	
	# Get updated stats
	var updated_stats = mock_economy.get_economy_stats()
	
	# Verify updated stats
	assert_equal(125.0, updated_stats.current_money, "Current money should be updated")
	assert_equal(50.0, updated_stats.total_earned, "Total earned should be updated")
	assert_equal(25.0, updated_stats.total_spent, "Total spent should be updated")
	assert_equal(2, updated_stats.transactions_count, "Transaction count should be updated")
	
	_after_test("test_economy_stats", true)

## test_negative_amounts
## 
## Test handling of negative amounts.
func test_negative_amounts() -> void:
	"""Test handling of negative amounts"""
	_before_test("test_negative_amounts")
	
	var initial_money = mock_economy.get_current_money()
	var initial_stats = mock_economy.get_economy_stats()
	
	# Test adding negative amount
	var add_success = mock_economy.add_money(-10.0, "Negative bonus")
	assert_false(add_success, "Adding negative amount should fail")
	
	# Test spending negative amount
	var spend_success = mock_economy.spend_money(-10.0, "Negative purchase")
	assert_false(spend_success, "Spending negative amount should fail")
	
	# Verify nothing changed
	var new_money = mock_economy.get_current_money()
	assert_equal(initial_money, new_money, "Money should remain unchanged")
	
	var new_stats = mock_economy.get_economy_stats()
	assert_equal(initial_stats.transactions_count, new_stats.transactions_count, "Transaction count should remain unchanged")
	
	_after_test("test_negative_amounts", true) 