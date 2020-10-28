//
//  Logger.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

class Logger {
  var level: LogLevel = .info

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
      level = .info
    }
  }

  private func canLog(withLevel level: LogLevel) -> Bool {
    return self.level != .off && self.level.rawValue >= level.rawValue
  }

  /*
   * Print a message to the log.
   */
  func log(_ prefix: String, _ items: [Any]) {
    let message = items.map { "\($0)" }.joined(separator: " ")
    CAPLog.print("\(prefix) [\(String(describing: WSSplashScreen.self))]", message)
  }

  /*
   * Print a trace message to the log.
   */
  func trace(_ items: Any...) {
    if canLog(withLevel: .trace) {
      log("🔎", items)
    }
  }

  /*
   * Print a debug message to the log.
   */
  func debug(_ items: Any...) {
    if canLog(withLevel: .debug) {
      log("👉", items)
    }
  }

  /*
   * Print an info message to the log.
   */
  func info(_ items: Any...) {
    if canLog(withLevel: .info) {
      log("🟢", items)
    }
  }

  /*
   * Print a warning message to the log.
   */
  func warn(_ items: Any...) {
    if canLog(withLevel: .warn) {
      log("🟠", items)
    }
  }

  /*
   * Print an error message to the log.
   */
  func error(_ items: Any...) {
    if canLog(withLevel: .error) {
      log("🔴", items)
    }
  }
}
