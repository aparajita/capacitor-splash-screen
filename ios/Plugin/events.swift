//
//  animate.swift
//  CapacitorSplashscreen
//
//  Created by Aparajita on 10/25/20.
//

import Capacitor

public extension SplashScreen {
  enum EventType: String {
    case animate
    case animateLaunch
  }

  struct AnimationCallbacks {
    public let done: () -> Void
    public let error: (String, ErrorType) -> Void
  }

  internal func dispatchEvent(_ event: EventType, wait: Double = 0, withCall call: CAPPluginCall? = nil) {
    guard eventHandler != nil else {
      logger?.warn("onSplashScreenEvent() was not found in the app delegate")
      return
    }

    func done() {
      tearDown()
      animatePluginCall?.resolve()
    }

    func error(_ message: String, code: ErrorType) {
      tearDown()
      animatePluginCall?.reject(message, code.rawValue)
    }

    let callbacks = AnimationCallbacks(done: done, error: error)
    var options: Config.CallOptions = [:]
    var delay = 0.0

    if let call = call {
      options = call.options

      // Apply any delay before the animation
      if let startDelay = Config.getDouble(kDelayOption, inOptions: options) {
        delay = SplashScreen.toSeconds(startDelay)
        options.removeValue(forKey: kDelayOption)
      }
    }

    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + delay + wait) {
        if let delegate = UIApplication.shared.delegate,
           let eventHandler = self.eventHandler {
          let params: [String: Any?] = [
            "source": self.source,
            "splashView": self.splashView,
            "plugin": self,
            "options": options,
            "callbacks": callbacks
          ]

          delegate.perform(eventHandler, with: event.rawValue, with: params)
        }
      }
  }
}
