//
//  log.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension WSSplashScreen {
  /*
   * Print a message to the log.
   */
  func log(_ prefix: String, _ items: [Any]) {
    let message = items.map { "\($0)" }.joined(separator: " ")
    CAPLog.print("\(prefix) [\(String(describing: WSSplashScreen.self))]", message)
  }

  /*
   * Print an info message to the log.
   */
  func info(_ items: Any...) {
    log("🟢", items)
  }

  /*
   * Print a warning message to the log.
   */
  func warn(_ items: Any...) {
    log("🟠", items)
  }

  /*
   * Print an error message to the log.
   */
  func error(_ items: Any...) {
    log("🔴", items)
  }
}
