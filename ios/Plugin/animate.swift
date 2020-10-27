//
//  animate.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/25/20.
//

import Capacitor

extension WSSplashScreen {
  func animate(withCall call: CAPPluginCall?) {
    func resolve() {
      tearDown()
      call?.success()
    }

    DispatchQueue.main.async {
      let selector = Selector(("animateSplashScreen:"))

      if let delegate = UIApplication.shared.delegate, delegate.responds(to: selector) {
        var options: [AnyHashable: Any]

        if let call = call {
          options = call.options
        } else {
          options = [:]
        }

        delegate.perform(selector, with: [
          "plugin": self,
          "splashView": self.splashView as Any,
          "spinner": self.spinner as Any,
          "options": options as Any,
          "resolve": resolve
        ])
      } else {
        call?.reject("The method animateSplashScreen(_: Any) is not defined in the AppDelegate class",
                    ErrorType.animateMethodNotFound.rawValue)
      }
    }
  }
}
