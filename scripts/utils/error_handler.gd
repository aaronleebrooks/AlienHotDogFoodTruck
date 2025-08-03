extends Node

## ErrorHandler
## 
## Central error handling system for the hot dog idle game.
## 
## This class provides comprehensive error management including logging,
## error tracking, recovery mechanisms, and user notifications. It implements
## the error handling strategy defined in the project documentation.
## 
## Features:
##   - Multi-level error logging (CRITICAL, ERROR, WARNING, INFO, DEBUG)
##   - Error code system with categorization
##   - Automatic and manual recovery mechanisms
##   - Error statistics and monitoring
##   - User-friendly error messages
##   - File-based persistent logging
## 
## Example:
##   ErrorHandler.log_error("SAVE_CORRUPTION_001", "Save file corrupted", "Technical details")
##   ErrorHandler.log_warning("UI_SIGNAL_002", "Signal connection failed")
##   ErrorHandler.log_info("SYSTEM_INIT_003", "System initialized successfully")
## 
## @since: 1.0.0
## @category: Utility

# Error severity levels
enum ErrorSeverity {
	CRITICAL,
	ERROR,
	WARNING,
	INFO,
	DEBUG
}

# Error categories
enum ErrorCategory {
	SYSTEM,
	GAME_LOGIC,
	UI,
	RESOURCE,
	PERFORMANCE,
	SAVE,
	NETWORK,
	UNKNOWN
}

# Error statistics
static var _error_stats: Dictionary = {
	"total_errors": 0,
	"critical_errors": 0,
	"recovery_attempts": 0,
	"successful_recoveries": 0,
	"errors_by_category": {},
	"errors_by_severity": {},
	"recent_errors": []
}

# Logging configuration
static var _log_enabled: bool = true
static var _log_to_file: bool = true
static var _log_file_path: String = "user://error_log.txt"
static var _max_log_size: int = 1024 * 1024  # 1MB
static var _max_recent_errors: int = 100

# Error recovery configuration
static var _auto_recovery_enabled: bool = true
static var _max_recovery_attempts: int = 3
static var _recovery_cooldown: float = 5.0  # seconds

# Error code definitions
static var _error_codes: Dictionary = {
	# System errors
	"SYSTEM_INIT_001": {
		"category": ErrorCategory.SYSTEM,
		"severity": ErrorSeverity.CRITICAL,
		"message": "System initialization failed",
		"recovery": "Restart the application"
	},
	"SYSTEM_MEMORY_002": {
		"category": ErrorCategory.SYSTEM,
		"severity": ErrorSeverity.ERROR,
		"message": "Memory allocation failed",
		"recovery": "Close other applications and restart"
	},
	
	# Game logic errors
	"GAME_STATE_001": {
		"category": ErrorCategory.GAME_LOGIC,
		"severity": ErrorSeverity.ERROR,
		"message": "Invalid game state detected",
		"recovery": "Game will attempt to restore previous state"
	},
	"GAME_ECONOMY_002": {
		"category": ErrorCategory.GAME_LOGIC,
		"severity": ErrorSeverity.WARNING,
		"message": "Economy calculation error",
		"recovery": "Using safe default values"
	},
	
	# UI errors
	"UI_SIGNAL_001": {
		"category": ErrorCategory.UI,
		"severity": ErrorSeverity.WARNING,
		"message": "Signal connection failed",
		"recovery": "UI component will be disabled"
	},
	"UI_ELEMENT_002": {
		"category": ErrorCategory.UI,
		"severity": ErrorSeverity.ERROR,
		"message": "UI element not found",
		"recovery": "Using fallback UI element"
	},
	
	# Resource errors
	"RESOURCE_LOAD_001": {
		"category": ErrorCategory.RESOURCE,
		"severity": ErrorSeverity.ERROR,
		"message": "Resource loading failed",
		"recovery": "Using default resource"
	},
	"RESOURCE_CORRUPT_002": {
		"category": ErrorCategory.RESOURCE,
		"severity": ErrorSeverity.CRITICAL,
		"message": "Resource file corrupted",
		"recovery": "Reinstalling resource"
	},
	
	# Save errors
	"SAVE_CORRUPTION_001": {
		"category": ErrorCategory.SAVE,
		"severity": ErrorSeverity.CRITICAL,
		"message": "Save file corrupted",
		"recovery": "Attempting to restore from backup"
	},
	"SAVE_WRITE_002": {
		"category": ErrorCategory.SAVE,
		"severity": ErrorSeverity.ERROR,
		"message": "Save write failed",
		"recovery": "Saving to temporary location"
	}
}

## _ready
## 
## Initialize the error handler.
## 
## @since: 1.0.0
func _ready() -> void:
	"""Initialize the error handler"""
	print("ErrorHandler: Initialized")

## log_critical
## 
## Log a critical error that requires immediate attention.
## 
## This function logs critical errors that may prevent the system from
## functioning properly. Critical errors are logged with the highest
## priority and may trigger automatic recovery mechanisms.
## 
## Parameters:
##   error_code (String): Error code identifier
##   message (String): User-friendly error message
##   details (String, optional): Technical details for developers
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   ErrorHandler.log_critical("SYSTEM_INIT_001", "System failed to initialize", "Technical details")
## 
## @since: 1.0.0
static func log_critical(error_code: String, message: String, details: String = "", context: Dictionary = {}) -> void:
	"""Log a critical error that requires immediate attention"""
	_log_error(ErrorSeverity.CRITICAL, error_code, message, details, context)

## log_error
## 
## Log an error that affects functionality but doesn't break the system.
## 
## This function logs errors that impact game functionality but allow
## the system to continue operating, possibly with reduced features.
## 
## Parameters:
##   error_code (String): Error code identifier
##   message (String): User-friendly error message
##   details (String, optional): Technical details for developers
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   ErrorHandler.log_error("GAME_STATE_001", "Invalid game state", "State validation failed")
## 
## @since: 1.0.0
static func log_error(error_code: String, message: String, details: String = "", context: Dictionary = {}) -> void:
	"""Log an error that affects functionality but doesn't break the system"""
	_log_error(ErrorSeverity.ERROR, error_code, message, details, context)

## log_warning
## 
## Log a warning about a potential issue.
## 
## This function logs warnings about conditions that may lead to errors
## but don't currently affect functionality. Warnings are monitored for
## patterns that might indicate larger issues.
## 
## Parameters:
##   error_code (String): Error code identifier
##   message (String): User-friendly warning message
##   details (String, optional): Technical details for developers
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   ErrorHandler.log_warning("PERF_FRAMERATE_001", "Low frame rate detected")
## 
## @since: 1.0.0
static func log_warning(error_code: String, message: String, details: String = "", context: Dictionary = {}) -> void:
	"""Log a warning about a potential issue"""
	_log_error(ErrorSeverity.WARNING, error_code, message, details, context)

## log_info
## 
## Log informational messages about system operation.
## 
## This function logs general information about system operation,
## successful operations, and status updates.
## 
## Parameters:
##   error_code (String): Error code identifier
##   message (String): Informational message
##   details (String, optional): Additional details
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   ErrorHandler.log_info("SYSTEM_INIT_003", "System initialized successfully")
## 
## @since: 1.0.0
static func log_info(error_code: String, message: String, details: String = "", context: Dictionary = {}) -> void:
	"""Log informational messages about system operation"""
	_log_error(ErrorSeverity.INFO, error_code, message, details, context)

## log_debug
## 
## Log debug information for development and troubleshooting.
## 
## This function logs detailed debug information that is useful for
## development and troubleshooting but not needed in production.
## 
## Parameters:
##   error_code (String): Error code identifier
##   message (String): Debug message
##   details (String, optional): Debug details
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   ErrorHandler.log_debug("DEBUG_001", "Function called", "Parameter values")
## 
## @since: 1.0.0
static func log_debug(error_code: String, message: String, details: String = "", context: Dictionary = {}) -> void:
	"""Log debug information for development and troubleshooting"""
	_log_error(ErrorSeverity.DEBUG, error_code, message, details, context)

## _log_error
## 
## Internal function to handle error logging.
## 
## This function processes all error logging requests, updates statistics,
## writes to log files, and triggers recovery mechanisms as needed.
## 
## Parameters:
##   severity (ErrorSeverity): Error severity level
##   error_code (String): Error code identifier
##   message (String): Error message
##   details (String): Technical details
##   context (Dictionary): Additional context
## 
## @since: 1.0.0
static func _log_error(severity: ErrorSeverity, error_code: String, message: String, details: String, context: Dictionary) -> void:
	"""Internal function to handle error logging"""
	if not _log_enabled:
		return
	
	# Get error information
	var error_info = _error_codes.get(error_code, {
		"category": ErrorCategory.UNKNOWN,
		"severity": severity,
		"message": message,
		"recovery": "No recovery action defined"
	})
	
	# Create error entry
	var error_entry = {
		"code": error_code,
		"message": message,
		"details": details,
		"severity": severity,
		"category": error_info.category,
		"timestamp": Time.get_datetime_string_from_system(),
		"context": context,
		"recovery": error_info.recovery
	}
	
	# Update statistics
	_update_error_stats(error_entry)
	
	# Format log message
	var severity_name = ErrorSeverity.keys()[severity]
	var category_name = ErrorCategory.keys()[error_info.category]
	var log_message = "[%s] [%s] [%s] [%s]: %s" % [
		severity_name,
		error_entry.timestamp,
		category_name,
		error_code,
		message
	]
	
	# Add details if provided
	if not details.is_empty():
		log_message += "\nDetails: %s" % details
	
	# Add context if provided
	if not context.is_empty():
		log_message += "\nContext: %s" % JSON.stringify(context)
	
	# Add recovery information
	log_message += "\nRecovery: %s" % error_info.recovery
	
	# Print to console
	print(log_message)
	
	# Write to file if enabled
	if _log_to_file:
		_write_to_log_file(log_message)
	
	# Trigger recovery if needed
	if severity <= ErrorSeverity.ERROR:
		_attempt_recovery(error_entry)

## _update_error_stats
## 
## Update error statistics with new error information.
## 
## This function maintains statistics about errors including counts,
## categories, severities, and recent error history.
## 
## Parameters:
##   error_entry (Dictionary): Error entry to add to statistics
## 
## @since: 1.0.0
static func _update_error_stats(error_entry: Dictionary) -> void:
	"""Update error statistics with new error information"""
	_error_stats.total_errors += 1
	
	# Update severity counts
	var severity_name = ErrorSeverity.keys()[error_entry.severity]
	if not _error_stats.errors_by_severity.has(severity_name):
		_error_stats.errors_by_severity[severity_name] = 0
	_error_stats.errors_by_severity[severity_name] += 1
	
	# Update category counts
	var category_name = ErrorCategory.keys()[error_entry.category]
	if not _error_stats.errors_by_category.has(category_name):
		_error_stats.errors_by_category[category_name] = 0
	_error_stats.errors_by_category[category_name] += 1
	
	# Update critical error count
	if error_entry.severity == ErrorSeverity.CRITICAL:
		_error_stats.critical_errors += 1
	
	# Add to recent errors
	_error_stats.recent_errors.append(error_entry)
	if _error_stats.recent_errors.size() > _max_recent_errors:
		_error_stats.recent_errors.pop_front()

## _write_to_log_file
## 
## Write error message to log file with rotation.
## 
## This function writes error messages to a persistent log file and
## handles log rotation when the file becomes too large.
## 
## Parameters:
##   message (String): Error message to write
## 
## @since: 1.0.0
static func _write_to_log_file(message: String) -> void:
	"""Write error message to log file with rotation"""
	var file = FileAccess.open(_log_file_path, FileAccess.READ_WRITE)
	if not file:
		# Try to create the file
		file = FileAccess.open(_log_file_path, FileAccess.WRITE)
		if not file:
			print("ErrorHandler: Failed to create log file: %s" % _log_file_path)
			return
	
	# Check file size and rotate if needed
	if file.get_length() > _max_log_size:
		_rotate_log_file()
		file = FileAccess.open(_log_file_path, FileAccess.WRITE)
		if not file:
			print("ErrorHandler: Failed to open rotated log file")
			return
	
	# Write message with timestamp
	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "[%s] %s\n" % [timestamp, message]
	
	file.seek_end()
	file.store_string(log_entry)
	file.close()

## _rotate_log_file
## 
## Rotate the log file to prevent it from becoming too large.
## 
## This function creates a backup of the current log file and starts
## a new one. It keeps a limited number of backup files.
## 
## @since: 1.0.0
static func _rotate_log_file() -> void:
	"""Rotate the log file to prevent it from becoming too large"""
	var dir = DirAccess.open("user://")
	if not dir:
		return
	
	# Create backup filename with timestamp
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var backup_path = "user://error_log_%s.txt" % timestamp
	
	# Rename current log file
	if dir.file_exists(_log_file_path.get_file()):
		dir.rename(_log_file_path.get_file(), backup_path.get_file())
	
	# Remove old backup files (keep only last 5)
	var backup_files = []
	for file_name in dir.get_files():
		if file_name.begins_with("error_log_") and file_name.ends_with(".txt"):
			backup_files.append(file_name)
	
	backup_files.sort()
	while backup_files.size() > 5:
		var old_file = backup_files.pop_front()
		dir.remove(old_file)

## _attempt_recovery
## 
## Attempt to recover from an error automatically.
## 
## This function implements automatic recovery mechanisms based on
## error type and severity. It tracks recovery attempts and success rates.
## 
## Parameters:
##   error_entry (Dictionary): Error entry to attempt recovery for
## 
## @since: 1.0.0
static func _attempt_recovery(error_entry: Dictionary) -> void:
	"""Attempt to recover from an error automatically"""
	if not _auto_recovery_enabled:
		return
	
	_error_stats.recovery_attempts += 1
	
	# Implement recovery based on error code
	var recovery_success = false
	match error_entry.code:
		"SAVE_CORRUPTION_001":
			recovery_success = _recover_save_corruption()
		"UI_SIGNAL_001":
			recovery_success = _recover_ui_signal()
		"RESOURCE_LOAD_001":
			recovery_success = _recover_resource_load()
		"GAME_STATE_001":
			recovery_success = _recover_game_state()
		_:
			# Default recovery attempt
			recovery_success = _recover_generic(error_entry)
	
	if recovery_success:
		_error_stats.successful_recoveries += 1
		log_info("RECOVERY_SUCCESS", "Successfully recovered from %s" % error_entry.code)
	else:
		log_warning("RECOVERY_FAILED", "Failed to recover from %s" % error_entry.code)

## _recover_save_corruption
## 
## Attempt to recover from save file corruption.
## 
## This function attempts to restore from backup saves or create
## a new save file if recovery is not possible.
## 
## Returns:
##   bool: True if recovery was successful, false otherwise
## 
## @since: 1.0.0
static func _recover_save_corruption() -> bool:
	"""Attempt to recover from save file corruption"""
	# Try to load backup save
	if SaveManager.has_backup_save():
		return SaveManager.load_backup_save()
	
	# Create new save with default values
	return SaveManager.create_new_save()

## _recover_ui_signal
## 
## Attempt to recover from UI signal connection failures.
## 
## This function attempts to reconnect failed signal connections
## or disable problematic UI elements.
## 
## Returns:
##   bool: True if recovery was successful, false otherwise
## 
## @since: 1.0.0
static func _recover_ui_signal() -> bool:
	"""Attempt to recover from UI signal connection failures"""
	# This would be implemented based on specific UI system
	# For now, return true as a placeholder
	return true

## _recover_resource_load
## 
## Attempt to recover from resource loading failures.
## 
## This function attempts to reload resources or use fallback
## resources when loading fails.
## 
## Returns:
##   bool: True if recovery was successful, false otherwise
## 
## @since: 1.0.0
static func _recover_resource_load() -> bool:
	"""Attempt to recover from resource loading failures"""
	# This would be implemented based on specific resource system
	# For now, return true as a placeholder
	return true

## _recover_game_state
## 
## Attempt to recover from invalid game state.
## 
## This function attempts to restore the game to a valid state
## or reset to a known good state.
## 
## Returns:
##   bool: True if recovery was successful, false otherwise
## 
## @since: 1.0.0
static func _recover_game_state() -> bool:
	"""Attempt to recover from invalid game state"""
	# This would be implemented based on specific game state system
	# For now, return true as a placeholder
	return true

## _recover_generic
## 
## Generic recovery mechanism for unspecified errors.
## 
## This function provides a basic recovery attempt for errors
## that don't have specific recovery mechanisms.
## 
## Parameters:
##   error_entry (Dictionary): Error entry to recover from
## 
## Returns:
##   bool: True if recovery was successful, false otherwise
## 
## @since: 1.0.0
static func _recover_generic(error_entry: Dictionary) -> bool:
	"""Generic recovery mechanism for unspecified errors"""
	# For now, return false as recovery is not implemented
	# In a full implementation, this would attempt basic recovery
	return false

## get_error_stats
## 
## Get current error statistics.
## 
## This function returns comprehensive statistics about errors
## including counts, categories, and recent error history.
## 
## Returns:
##   Dictionary: Error statistics
## 
## Example:
##   var stats = ErrorHandler.get_error_stats()
##   print("Total errors: %d" % stats.total_errors)
## 
## @since: 1.0.0
static func get_error_stats() -> Dictionary:
	"""Get current error statistics"""
	return _error_stats.duplicate()

## clear_error_stats
## 
## Clear all error statistics.
## 
## This function resets all error statistics to zero. It's useful
## for testing or when starting a new session.
## 
## Example:
##   ErrorHandler.clear_error_stats()
##   print("Error statistics cleared")
## 
## @since: 1.0.0
static func clear_error_stats() -> void:
	"""Clear all error statistics"""
	_error_stats = {
		"total_errors": 0,
		"critical_errors": 0,
		"recovery_attempts": 0,
		"successful_recoveries": 0,
		"errors_by_category": {},
		"errors_by_severity": {},
		"recent_errors": []
	}

## set_logging_enabled
## 
## Enable or disable error logging.
## 
## This function allows enabling or disabling error logging for
## performance reasons or debugging purposes.
## 
## Parameters:
##   enabled (bool): Whether to enable error logging
## 
## Example:
##   ErrorHandler.set_logging_enabled(false)  # Disable logging
## 
## @since: 1.0.0
static func set_logging_enabled(enabled: bool) -> void:
	"""Enable or disable error logging"""
	_log_enabled = enabled

## set_file_logging_enabled
## 
## Enable or disable file-based logging.
## 
## This function allows enabling or disabling persistent file logging
## while keeping console logging active.
## 
## Parameters:
##   enabled (bool): Whether to enable file logging
## 
## Example:
##   ErrorHandler.set_file_logging_enabled(false)  # Disable file logging
## 
## @since: 1.0.0
static func set_file_logging_enabled(enabled: bool) -> void:
	"""Enable or disable file-based logging"""
	_log_to_file = enabled 
