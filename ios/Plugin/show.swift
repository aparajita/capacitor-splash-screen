//
//  show.swift
//  CapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension SplashScreen {
  func showLaunchScreen() {
    let options = ShowOptions(withPlugin: self)
    logger?.debug("showOnLaunch(): \(String(describing: options))")
    launchOptions = options
    show(withOptions: options, pluginCall: nil)
  }

  func show(withOptions options: ShowOptions, pluginCall call: CAPPluginCall?) {
    guard !isActive else {
      postError(call: call, message: "A splash screen is already active", code: ErrorType.alreadyActive)
      return
    }

    // We have to use the main thread to show something over the Ionic web view
    DispatchQueue.main.async {
      // For launch screens it will default to "*" because call is nil
      let source = Config.getString("source", inOptions: call?.options ?? [:]) ?? kDefaultSource
      self.buildView(forPluginCall: call, fromSource: source)

      // If buildView() failed, splashView will be nil
      guard let splashView = self.splashView else {
        let message = "No storyboard named \"\(source)\" found"

        if let call = call {
          call.reject(message, ErrorType.notFound.rawValue)
        } else {
          self.logger?.error(message)
        }

        return
      }

      guard let view = self.bridge?.viewController?.view else {
        return
      }

      self.isActive = true

      // Size the splash to the screen
      splashView.frame = view.frame

      /*
       * NOTE: iOS performs a short cross dissolve between the iOS launch screen and the
       * splashView, which is (hopefully) unnoticeable if they are both visible.
       */
      if self.isLaunchSplash {
        splashView.alpha = 1
      } else {
        splashView.alpha = 0
      }

      // Now add the splash to the container view
      view.addSubview(splashView)
      self.fadeInSplash(withOptions: options, pluginCall: call)
    }
  }

  func fadeInSplash(withOptions options: ShowOptions, pluginCall call: CAPPluginCall?) {
    // swiftlint doesn't like nested trailing closures, so we define this separately
    let onAnimationEnd: (Bool) -> Void = { _ in
      call?.resolve()
    }

    if isLaunchSplash {
      onAnimationEnd(true)
      return
    }

    UIView.animate(
      withDuration: options.fadeInDuration,
      delay: options.delay,
      options: [.overrideInheritedOptions, .curveLinear],
      animations: {
        self.splashView?.alpha = 1
      },
      completion: onAnimationEnd
    )
  }

  func animate(withCall call: CAPPluginCall, wait: Double) {
    animatePluginCall = call
    dispatchEvent(isLaunchSplash ? .animateLaunch : .animate, wait: wait, withCall: call)
  }
}
