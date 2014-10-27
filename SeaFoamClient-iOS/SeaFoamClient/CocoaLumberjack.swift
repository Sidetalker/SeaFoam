// Created by Ullrich Schäfer on 16/08/14.
// Updated to Swift 1.1 by Stan Serebryakov on 22/10/14

struct LogFlag : RawOptionSetType {
    var value: UInt = 0
    var rawValue: UInt {
        get { return value }
        set { value = newValue }
    }
    init(rawValue value: UInt) { rawValue = value }
    init(nilLiteral: ()) {}
    
    static var Error:    LogFlag { return self(rawValue: 0b00001) }
    static var Warn:     LogFlag { return self(rawValue: 0b00010) }
    static var Info:     LogFlag { return self(rawValue: 0b00100) }
    static var Debug:    LogFlag { return self(rawValue: 0b01000) }
    static var Verbose:  LogFlag { return self(rawValue: 0b10000) }
    static var allZeros: LogFlag { return self(rawValue: 0b00000) }
}

func ==(lhs: LogFlag, rhs: LogFlag) -> Bool { return lhs.rawValue == rhs.rawValue }


struct LogLevel : RawOptionSetType {
    var value: UInt = 0
    var rawValue: UInt {
        get { return value }
        set { value = newValue }
    }
    init(rawValue value: UInt) { rawValue = value }
    init(nilLiteral: ()) {}
    
    static var Off:      LogLevel { return self(rawValue: 0b00000000) }
    static var Error:    LogLevel { return self(rawValue: 0b00000001) }
    static var Warn:     LogLevel { return self(rawValue: 0b00000011) }
    static var Info:     LogLevel { return self(rawValue: 0b00000111) }
    static var Debug:    LogLevel { return self(rawValue: 0b00001111) }
    static var Verbose:  LogLevel { return self(rawValue: 0b00011111) }
    static var All:      LogLevel { return self(rawValue: 0b11111111) }
    static var allZeros: LogLevel { return self(rawValue: 0b00000000) }
}

func ==(lhs: LogLevel, rhs: LogLevel) -> Bool { return lhs.rawValue == rhs.rawValue }


extension DDLog {
    
    private struct State {
        static var logLevel: LogLevel = .Error
        static var logAsync: Bool = true
    }
    
    class var logLevel: LogLevel {
        get { return State.logLevel }
        set { State.logLevel = newValue }
    }
    
    class var logAsync: Bool {
        get { return (self.logLevel != .Error) && State.logAsync }
        set { State.logAsync = newValue }
    }
    
    class func logError(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
        log(.Error, message: message, function: function, file: file, line: line)
    }
    class func logWarn(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
        log(.Warn,  message: message, function: function, file: file, line: line)
    }
    class func logInfo(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
        log(.Info,  message: message, function: function, file: file, line: line)
    }
    class func logDebug(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
        log(.Debug, message: message, function: function, file: file, line: line)
    }
    class func logVerbose(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
        log(.Verbose, message: message, function: function, file: file, line: line)
    }
    
    private class func log(flag: LogFlag, message: String, function: String = __FUNCTION__, file: String = __FILE__,
        line: Int32 = __LINE__) {
//            let level = DDLogLevel(rawValue: self.logLevel.rawValue)
            let level = DDLogLevel.All
            let async: Bool = DDLog.logAsync
            
            if flag.rawValue != 0 {
                DDLog.log(async, message: DDLogMessage(logMsg: message, level: level, flag: DDLogFlag(flag.rawValue),
                    context: 0, file: file, function: function, line: line, tag: nil, options: 0))
            }
    }
}

// Not possible due to http://openradar.appspot.com/radar?id=5773154781757440
//let logError = DDLog.logError
//let logWarn  = DDLog.logWarn
//let logInfo  = DDLog.logInfo
//let logDebug = DDLog.logDebug

func logError(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    DDLog.logError(message, function: function, file: file, line: line)
}

func logWarn(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    DDLog.logWarn(message, function: function, file: file, line: line)
}

func logInfo(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    DDLog.logInfo(message, function: function, file: file, line: line)
}

func logDebug(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    DDLog.logDebug(message, function: function, file: file, line: line)
}

func logVerbose(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) {
    DDLog.logVerbose(message, function: function, file: file, line: line)
}