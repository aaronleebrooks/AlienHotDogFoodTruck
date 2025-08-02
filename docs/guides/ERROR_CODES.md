# Error Codes Documentation

## Overview
This document provides comprehensive documentation for all error codes used in the hot dog idle game project. Error codes follow a standardized format and are categorized by system and severity.

## Error Code Format
```
[SYSTEM]_[CATEGORY]_[ERROR_TYPE]_[NUMBER]
```

**Components:**
- **SYSTEM**: The system where the error occurred (SAVE, UI, RESOURCE, etc.)
- **CATEGORY**: The type of error (CORRUPTION, SIGNAL, LOAD, etc.)
- **ERROR_TYPE**: Specific error description
- **NUMBER**: Sequential number for similar errors

## Error Categories

### System Errors (SYSTEM_*)
Critical errors that affect core system functionality.

#### SYSTEM_INIT_001
- **Severity**: CRITICAL
- **Description**: System initialization failed
- **Causes**: Missing dependencies, configuration errors, resource allocation failures
- **Recovery**: Restart the application
- **User Action**: Contact support if problem persists

#### SYSTEM_MEMORY_002
- **Severity**: ERROR
- **Description**: Memory allocation failed
- **Causes**: Insufficient system memory, memory leaks, excessive resource usage
- **Recovery**: Close other applications and restart
- **User Action**: Close unnecessary applications, restart game

### Game Logic Errors (GAME_*)
Errors in game mechanics and logic that affect gameplay.

#### GAME_STATE_001
- **Severity**: ERROR
- **Description**: Invalid game state detected
- **Causes**: Data corruption, logic errors, unexpected state transitions
- **Recovery**: Game will attempt to restore previous state
- **User Action**: Continue playing, report if issues persist

#### GAME_ECONOMY_002
- **Severity**: WARNING
- **Description**: Economy calculation error
- **Causes**: Invalid calculations, corrupted data, overflow conditions
- **Recovery**: Using safe default values
- **User Action**: Continue playing, values will be corrected

### UI Errors (UI_*)
Errors in user interface components and interactions.

#### UI_SIGNAL_001
- **Severity**: WARNING
- **Description**: UI signal connection failed
- **Causes**: Missing signal handlers, disconnected signals, timing issues
- **Recovery**: UI element disabled, functionality reduced
- **User Action**: Refresh UI or restart game if needed

#### UI_ELEMENT_002
- **Severity**: ERROR
- **Description**: Required UI element missing
- **Causes**: Scene loading failures, missing resources, initialization errors
- **Recovery**: Using fallback UI layout
- **User Action**: Restart game if UI is unusable

### Resource Errors (RESOURCE_*)
Errors related to asset and resource management.

#### RESOURCE_LOAD_001
- **Severity**: WARNING
- **Description**: Resource loading failed
- **Causes**: Missing files, corrupted assets, network issues
- **Recovery**: Using default resource
- **User Action**: Verify game files, reinstall if needed

#### RESOURCE_CORRUPT_002
- **Severity**: ERROR
- **Description**: Resource file corrupted
- **Causes**: File corruption, incomplete downloads, storage issues
- **Recovery**: Reinstalling resource files
- **User Action**: Verify game files, reinstall if needed

### Save System Errors (SAVE_*)
Errors related to save data and persistence.

#### SAVE_CORRUPTION_001
- **Severity**: CRITICAL
- **Description**: Save file corrupted
- **Causes**: File corruption, incomplete saves, storage issues
- **Recovery**: Loading backup save or starting new game
- **User Action**: Check storage space, backup saves if possible

#### SAVE_WRITE_002
- **Severity**: ERROR
- **Description**: Failed to save game
- **Causes**: Insufficient storage, permission issues, disk errors
- **Recovery**: Retrying save operation
- **User Action**: Check storage space, ensure write permissions

### Performance Errors (PERF_*)
Errors related to performance degradation.

#### PERF_FRAMERATE_001
- **Severity**: WARNING
- **Description**: Low frame rate detected
- **Causes**: High system load, graphics settings, hardware limitations
- **Recovery**: Reducing graphics quality
- **User Action**: Lower graphics settings, close other applications

#### PERF_MEMORY_002
- **Severity**: WARNING
- **Description**: High memory usage
- **Causes**: Memory leaks, excessive resource usage, system limitations
- **Recovery**: Clearing unused resources
- **User Action**: Restart game, close other applications

### Network Errors (NETWORK_*)
Errors related to network connectivity and online features.

#### NETWORK_CONNECTION_001
- **Severity**: WARNING
- **Description**: Network connection lost
- **Causes**: Internet issues, server problems, firewall blocking
- **Recovery**: Retrying connection
- **User Action**: Check internet connection, try again later

#### NETWORK_TIMEOUT_002
- **Severity**: WARNING
- **Description**: Network request timeout
- **Causes**: Slow connection, server overload, network congestion
- **Recovery**: Retrying with longer timeout
- **User Action**: Check internet connection, try again later

## Error Severity Levels

### CRITICAL
- **Impact**: System cannot function
- **User Experience**: Game crashes or becomes unusable
- **Recovery**: Requires immediate attention
- **Examples**: SYSTEM_INIT_001, SAVE_CORRUPTION_001

### ERROR
- **Impact**: Functionality significantly affected
- **User Experience**: Game continues but with reduced features
- **Recovery**: Automatic recovery attempted
- **Examples**: GAME_STATE_001, UI_ELEMENT_002

### WARNING
- **Impact**: Minor functionality issues
- **User Experience**: Game continues normally with minor issues
- **Recovery**: Automatic recovery or user action
- **Examples**: UI_SIGNAL_001, PERF_FRAMERATE_001

### INFO
- **Impact**: Informational only
- **User Experience**: No impact on gameplay
- **Recovery**: No action needed
- **Examples**: System status updates, successful operations

### DEBUG
- **Impact**: Development information only
- **User Experience**: Not visible to users
- **Recovery**: Not applicable
- **Examples**: Function calls, variable states

## Error Recovery Strategies

### Automatic Recovery
Errors that can be resolved automatically without user intervention:
- **UI_SIGNAL_001**: Reconnect signals automatically
- **RESOURCE_LOAD_001**: Use fallback resources
- **PERF_FRAMERATE_001**: Reduce graphics quality

### User-Guided Recovery
Errors requiring user decision or action:
- **SAVE_CORRUPTION_001**: Choose backup save or start new game
- **SYSTEM_INIT_001**: Restart application
- **NETWORK_CONNECTION_001**: Check connection and retry

### System Recovery
Critical errors requiring system-level intervention:
- **SYSTEM_MEMORY_002**: Clear memory and restart
- **GAME_STATE_001**: Restore from backup state
- **SAVE_CORRUPTION_001**: Emergency save restoration

## Error Reporting

### What Gets Reported
- Error code and description
- Timestamp and context
- System information
- Recovery attempts and results
- User actions taken

### What Doesn't Get Reported
- Personal user data
- Save file contents
- Network credentials
- System passwords

### Reporting Format
```json
{
  "error_code": "SAVE_CORRUPTION_001",
  "timestamp": "2024-01-01T12:00:00Z",
  "severity": "CRITICAL",
  "description": "Save file corrupted",
  "context": {
    "file_path": "user://save_game.dat",
    "file_size": 1024,
    "system_info": {
      "platform": "Windows",
      "version": "10.0.22631"
    }
  },
  "recovery_attempts": [
    {
      "method": "restore_backup",
      "success": false,
      "reason": "No backup available"
    }
  ],
  "user_actions": [
    {
      "action": "restart_game",
      "timestamp": "2024-01-01T12:05:00Z"
    }
  ]
}
```

## Best Practices

### For Developers
1. **Use Standardized Codes**: Always use the defined error code format
2. **Provide Clear Descriptions**: Make error messages user-friendly
3. **Include Recovery Information**: Tell users what they can do
4. **Log Context**: Include relevant system and error context
5. **Test Recovery**: Ensure recovery mechanisms work

### For Users
1. **Read Error Messages**: Understand what the error means
2. **Follow Recovery Steps**: Try the suggested solutions
3. **Report Persistent Issues**: Contact support if problems continue
4. **Backup Saves**: Regularly backup important game data
5. **Check System Requirements**: Ensure hardware meets minimum specs

## Error Code Registry

### Adding New Error Codes
1. **Choose Category**: Select appropriate system category
2. **Define Format**: Follow the standard naming convention
3. **Document**: Add to this documentation
4. **Implement**: Add to ErrorHandler and ErrorRecovery systems
5. **Test**: Verify error handling and recovery

### Error Code Maintenance
- **Regular Review**: Periodically review and update error codes
- **Usage Analysis**: Track which errors occur most frequently
- **Recovery Optimization**: Improve recovery success rates
- **Documentation Updates**: Keep documentation current

## Conclusion

This error code system provides a comprehensive framework for identifying, categorizing, and resolving errors in the hot dog idle game. By following these standards, we ensure consistent error handling and provide users with clear guidance for resolving issues.

For questions or suggestions about error codes, please refer to the development team or update this documentation as needed. 