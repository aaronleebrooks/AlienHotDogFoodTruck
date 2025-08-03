extends Node

## PerformanceMonitor
## 
## Global singleton for monitoring game performance.
## 
## This autoload provides performance monitoring capabilities including
## FPS tracking, memory usage, frame time analysis, and performance alerts.
## 
## @since: 1.0.0

# Performance tracking
var _fps_history: Array[float] = []
var _frame_time_history: Array[float] = []
var _memory_history: Array[int] = []
var _max_history_size: int = 300  # 5 seconds at 60fps

# Performance thresholds
var _fps_threshold_low: float = 30.0
var _fps_threshold_critical: float = 15.0
var _memory_threshold_mb: float = 512.0
var _frame_time_threshold_ms: float = 33.0  # 30fps equivalent

# Monitoring state
var _is_monitoring: bool = false
var _last_frame_time: float = 0.0
var _performance_alerts: Array[String] = []

# Signals
signal fps_updated(fps: float)
signal memory_updated(memory_mb: float)
signal frame_time_updated(frame_time_ms: float)
signal performance_alert(alert: String, severity: String)
signal performance_report_generated(report: Dictionary)

## _ready
## 
## Initialize the performance monitor.
## 
## @since: 1.0.0
func _ready() -> void:
	"""Initialize the performance monitor"""
	print("PerformanceMonitor: Initialized")
	start_monitoring()

## start_monitoring
## 
## Start performance monitoring.
## 
## @since: 1.0.0
func start_monitoring() -> void:
	"""Start performance monitoring"""
	_is_monitoring = true
	_last_frame_time = Time.get_ticks_msec()

## stop_monitoring
## 
## Stop performance monitoring.
## 
## @since: 1.0.0
func stop_monitoring() -> void:
	"""Stop performance monitoring"""
	_is_monitoring = false

## _process
## 
## Process frame for performance monitoring.
## 
## @since: 1.0.0
func _process(_delta: float) -> void:
	"""Process frame for performance monitoring"""
	if not _is_monitoring:
		return
	
	# Calculate frame time
	var current_time = Time.get_ticks_msec()
	var frame_time = current_time - _last_frame_time
	_last_frame_time = current_time
	
	# Calculate FPS
	var fps = 1000.0 / frame_time if frame_time > 0 else 0.0
	
	# Get memory usage
	var memory_usage = OS.get_static_memory_usage()
	var memory_mb = memory_usage / 1024.0 / 1024.0
	
	# Store history
	_add_to_history(_fps_history, fps)
	_add_to_history(_frame_time_history, frame_time)
	_add_to_history(_memory_history, memory_usage)
	
	# Emit signals
	fps_updated.emit(fps)
	memory_updated.emit(memory_mb)
	frame_time_updated.emit(frame_time)
	
	# Check for performance issues
	_check_performance_issues(fps, frame_time, memory_mb)

## get_current_fps
## 
## Get the current FPS.
## 
## Returns:
##   float: Current FPS
## 
## @since: 1.0.0
func get_current_fps() -> float:
	"""Get the current FPS"""
	if _fps_history.is_empty():
		return 0.0
	return _fps_history[-1]

## get_average_fps
## 
## Get the average FPS over the history period.
## 
## Returns:
##   float: Average FPS
## 
## @since: 1.0.0
func get_average_fps() -> float:
	"""Get the average FPS over the history period"""
	if _fps_history.is_empty():
		return 0.0
	
	var sum = 0.0
	for fps in _fps_history:
		sum += fps
	return sum / _fps_history.size()

## get_current_memory_usage
## 
## Get the current memory usage in MB.
## 
## Returns:
##   float: Current memory usage in MB
## 
## @since: 1.0.0
func get_current_memory_usage() -> float:
	"""Get the current memory usage in MB"""
	if _memory_history.is_empty():
		return 0.0
	return _memory_history[-1] / 1024.0 / 1024.0

## get_performance_report
## 
## Generate a comprehensive performance report.
## 
## Returns:
##   Dictionary: Performance report with various metrics
## 
## @since: 1.0.0
func get_performance_report() -> Dictionary:
	"""Generate a comprehensive performance report"""
	var report = {
		"current_fps": get_current_fps(),
		"average_fps": get_average_fps(),
		"current_memory_mb": get_current_memory_usage(),
		"current_frame_time_ms": _frame_time_history[-1] if not _frame_time_history.is_empty() else 0.0,
		"average_frame_time_ms": _get_average(_frame_time_history),
		"min_fps": _get_min(_fps_history),
		"max_fps": _get_max(_fps_history),
		"min_memory_mb": _get_min(_memory_history) / 1024.0 / 1024.0 if not _memory_history.is_empty() else 0.0,
		"max_memory_mb": _get_max(_memory_history) / 1024.0 / 1024.0 if not _memory_history.is_empty() else 0.0,
		"alerts": _performance_alerts.duplicate(),
		"monitoring_active": _is_monitoring,
		"history_size": _fps_history.size()
	}
	
	performance_report_generated.emit(report)
	return report

## clear_alerts
## 
## Clear all performance alerts.
## 
## @since: 1.0.0
func clear_alerts() -> void:
	"""Clear all performance alerts"""
	_performance_alerts.clear()

## _add_to_history
## 
## Add a value to a history array, maintaining size limit.
## 
## Parameters:
##   history (Array): The history array to add to
##   value: The value to add
## 
## @since: 1.0.0
func _add_to_history(history: Array, value) -> void:
	"""Add a value to a history array, maintaining size limit"""
	history.append(value)
	if history.size() > _max_history_size:
		history.pop_front()

## _check_performance_issues
## 
## Check for performance issues and generate alerts.
## 
## Parameters:
##   fps (float): Current FPS
##   frame_time (float): Current frame time in ms
##   memory_mb (float): Current memory usage in MB
## 
## @since: 1.0.0
func _check_performance_issues(fps: float, frame_time: float, memory_mb: float) -> void:
	"""Check for performance issues and generate alerts"""
	# Check FPS
	if fps < _fps_threshold_critical:
		_add_alert("Critical FPS drop: %.1f FPS" % fps, "critical")
	elif fps < _fps_threshold_low:
		_add_alert("Low FPS detected: %.1f FPS" % fps, "warning")
	
	# Check frame time
	if frame_time > _frame_time_threshold_ms:
		_add_alert("High frame time: %.1f ms" % frame_time, "warning")
	
	# Check memory usage
	if memory_mb > _memory_threshold_mb:
		_add_alert("High memory usage: %.1f MB" % memory_mb, "warning")

## _add_alert
## 
## Add a performance alert.
## 
## Parameters:
##   message (String): Alert message
##   severity (String): Alert severity (warning, critical)
## 
## @since: 1.0.0
func _add_alert(message: String, severity: String) -> void:
	"""Add a performance alert"""
	var alert = "[%s] %s" % [severity.to_upper(), message]
	_performance_alerts.append(alert)
	performance_alert.emit(alert, severity)

## _get_average
## 
## Calculate the average of an array of numbers.
## 
## Parameters:
##   array (Array): Array of numbers
## 
## Returns:
##   float: Average value
## 
## @since: 1.0.0
func _get_average(array: Array) -> float:
	"""Calculate the average of an array of numbers"""
	if array.is_empty():
		return 0.0
	
	var sum = 0.0
	for value in array:
		sum += value
	return sum / array.size()

## _get_min
## 
## Get the minimum value from an array.
## 
## Parameters:
##   array (Array): Array of numbers
## 
## Returns:
##   float: Minimum value
## 
## @since: 1.0.0
func _get_min(array: Array) -> float:
	"""Get the minimum value from an array"""
	if array.is_empty():
		return 0.0
	
	var min_value = array[0]
	for value in array:
		if value < min_value:
			min_value = value
	return min_value

## _get_max
## 
## Get the maximum value from an array.
## 
## Parameters:
##   array (Array): Array of numbers
## 
## Returns:
##   float: Maximum value
## 
## @since: 1.0.0
func _get_max(array: Array) -> float:
	"""Get the maximum value from an array"""
	if array.is_empty():
		return 0.0
	
	var max_value = array[0]
	for value in array:
		if value > max_value:
			max_value = value
	return max_value 