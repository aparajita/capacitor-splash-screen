//
//  hide.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension WSSplashScreen {
  func hideSplash(withOptions options: HideOptions, pluginCall call: CAPPluginCall?, completion: @escaping () -> Void) {
    guard isVisible else {
      return
    }

    DispatchQueue.main.async {
      UIView.animate(
        withDuration: Double(options.fadeOutDuration) / 1000,
        delay: Double(options.delay) / 1000,
        options: [.curveLinear],
        animations: {
          self.splashView?.alpha = 0
          self.spinner?.alpha = 0
        },
        completion: { _ in
          self.tearDown()
          completion()
        }
      )
    }
  }

  /*
   * Clean up after the splash is hidden
   */
  func tearDown() {
    isVisible = false
    splashView?.removeFromSuperview()
    spinner?.removeFromSuperview()
  }
}
