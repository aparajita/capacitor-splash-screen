//
//  log.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension WSSplashScreen {
  // Log levels from lowest to highest. Log messages at or below the current log level
  // are displayed.
  enum LogLevel: Int {
    case off
    case error
    case warn
    case info
    case debug
  }

  func setLogLevel() {
    if let level = getConfigString(withKeyPath: "logLevel") {
      switch level {
      case "debug":
        logLevel = .debug

      case "info":
        logLevel = .info

      case "warn":
        logLevel = .warn

      case "error":
        logLevel = .error

      case "off":
        logLevel = .off

      default:
        logLevel = .info
      }
    }
  }

  private func canLog(withLevel level: LogLevel) -> Bool {
    return logLevel != .off && logLevel.rawValue >= level.rawValue
  }

  /*
   * Print a message to the log.
   */
  func log(_ prefix: String, _ items: [Any]) {
    let message = items.map { "\($0)" }.joined(separator: " ")
    CAPLog.print("\(prefix) [\(String(describing: WSSplashScreen.self))]", message)
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
