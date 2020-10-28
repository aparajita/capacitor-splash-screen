//
//  Logger.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

class Logger {
  // Log levels from lowest to highest. Log messages at or below the current log level
  // are displayed.
  enum LogLevel: Int {
    case off
    case error
    case warn
    case info
    case debug
    case trace
  }

  let tag = String(describing: WSSplashScreen.self)
  var level: LogLevel = .info
  var prefixes: [LogLevel: String] = [
    .error: "🔴",
    .warn: "🟠",
    .info: "🟢",
    .debug: "👉",
    .trace: "🔎"
  ]

  func setLogLevel(_ logLevel: String) {
    switch logLevel.lowercased() {
    case "trace":
      level = .trace

    case "debug":
      level = .debug

    case "info":
      level = .info

    case "warn":
      level = .warn

    case "error":
      level = .error

    case "off":
      level = .off

    default:
      // ignore
      break
    }
  }

  private func canLog(atLevel level: LogLevel) -> Bool {
    return self.level != .off && self.level.rawValue >= level.rawValue
  }

  /*
   * Print a message to the log.
   */
  private func print(withLevel level: LogLevel, items: [Any]) {
    if canLog(atLevel: level) {
      let prefix = prefixes[level] ?? "" // This will never actually fail
      let message = items.map { "\($0)" }.joined(separator: " ")
      CAPLog.print("\(prefix) [\(tag)]", message)
    }
  }

  /*
   * Print a trace message to the log.
   */
  func trace(_ items: Any...) {
    print(withLevel: .trace, items: items)
  }

  /*
   * Print a debug message to the log.
   */
  func debug(_ items: Any...) {
    print(withLevel: .debug, items: items)
  }

  /*
   * Print an info message to the log.
   */
  func info(_ items: Any...) {
    print(withLevel: .info, items: items)
  }

  /*
   * Print an info message to the log.
   */
  func log(_ items: Any...) {
    print(withLevel: .info, items: items)
  }

  /*
   * Print a warning message to the log.
   */
  func warn(_ items: Any...) {
    print(withLevel: .warn, items: items)
  }

  /*
   * Print an error message to the log.
   */
  func error(_ items: Any...) {
    print(withLevel: .error, items: items)
  }
}
