//
//  hideSplash.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

extension WSSplashScreen {
  func hideSplash(fadeOutDuration: Int) {
    hideSplash(fadeOutDuration: fadeOutDuration, isLaunchSplash: false, autoHides: false)
  }

  func hideSplash(fadeOutDuration: Int, isLaunchSplash: Bool, autoHides: Bool) {
    if !isVisible {
      return
    }

    if isLaunchSplash, autoHides {
      warn("The launch screen was automatically hidden after \(showDuration) ms.\n" +
           "We recommend you instead set WSSplashScreen.autoHide to false in capacitor.config.json\n" +
           "and call `WSSplashScreen.hide()` as soon as your web app is loaded.\n" +
           "See https://github.com/willsub/ws-capacitor-splashscreen for more info.")
    }

    let completion: (Bool) -> Void = { _ in self.tearDown() }

    DispatchQueue.main.async {
      UIView.transition(
        with: self.bridge.viewController.view,
        duration: TimeInterval(Double(fadeOutDuration) / 1000),
        options: .curveLinear,
        animations: {
          self.splashView?.alpha = 0

          if let spinner = self.spinner {
            spinner.alpha = 0
          }
        },
        completion: completion
      )
    }
  }

  /*
   * Clean up after the splash is hidden
   */
  func tearDown() {
    isVisible = false
    bridge.viewController.view.isUserInteractionEnabled = true
    splashView?.removeFromSuperview()
    spinner?.removeFromSuperview()
  }
}
