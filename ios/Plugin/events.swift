//
//  animate.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/25/20.
//

import Capacitor

private var animatePluginCall: CAPPluginCall?

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
    dispatchEvent(.afterShow)
  }

  func animate(withCall call: CAPPluginCall) {
    animatePluginCall = call
    dispatchEvent(.animate, withCall: call)
  }

  func dispatchEvent(_ event: EventType, withCall call: CAPPluginCall? = nil) {
    guard eventHandler != nil else {
      logger.warn("onSplashScreenEvent() was not found in the app delegate")
      return
    }

    func done() {
      tearDown()
      animatePluginCall?.resolve()
    }

    var delay = 0.0

    if let call = call {
      delay = WSSplashScreen.toSeconds(call.getDouble("delay") ?? 0)
    }

    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + delay) {
      if let delegate = UIApplication.shared.delegate,
         let eventHandler = self.eventHandler {
        var options: [AnyHashable: Any]?

        if let call = call {
          options = call.options
        }

        var params: [String: Any?] = [
          "plugin": self,
          "splashView": self.splashView as Any,
          "spinner": self.spinner as Any,
          "options": options as Any?
        ]

        if event == .animate {
          params["done"] = done
        }

        delegate.perform(eventHandler, with: event.rawValue, with: params)
      }
    }
  }
}
