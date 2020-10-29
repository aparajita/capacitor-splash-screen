//
//  animate.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/25/20.
//

import Capacitor

extension WSSplashScreen {
  enum EventType: String {
    case beforeShow
    case afterShow
    case animate
  }

  func callBeforeShowHook(withCall call: CAPPluginCall?) {
    dispatchEvent(.beforeShow, withCall: call)
  }

  func callAfterShowHook() {
    dispatchEvent(.afterShow, withCall: nil)
  }

  func animate(withCall call: CAPPluginCall?) {
    dispatchEvent(.animate, withCall: call)
  }

  func dispatchEvent(_ event: EventType, withCall call: CAPPluginCall?) {
    guard eventHandler != nil else {
      logger.warn("onSplashScreenEvent() was not found in the app delegate")
      return
    }

    func resolve() {
      tearDown()
      call?.success()
    }

    DispatchQueue.main.async {
      if let delegate = UIApplication.shared.delegate,
         let eventHandler = self.eventHandler {
        var options: [AnyHashable: Any]?

        if let call = call {
          options = call.options
        }

        let params: [String: Any?] = [
          "plugin": self,
          "splashView": self.splashView as Any,
          "spinner": self.spinner as Any,
          "options": options as Any?,
          "resolve": resolve
        ]

        delegate.perform(eventHandler, with: event.rawValue, with: params)
      }
    }
  }
}
