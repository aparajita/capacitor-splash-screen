//
//  hide.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension WSSplashScreen {
  func hideSplash(withOptions options: HideOptions, pluginCall call: CAPPluginCall?) {
    guard isVisible else {
      return
    }

    DispatchQueue.main.async {
      UIView.animate(
        withDuration: options.fadeOutDuration,
        delay: options.delay,
        options: [.curveLinear],
        animations: {
          self.splashView?.alpha = 0
          self.spinner?.alpha = 0
        },
        completion: { _ in
          self.tearDown()
          call?.success()
        }
      )
    }
  }

  /*
   * Clean up after the splash is hidden
   */
  func tearDown() {
    callAfterShowHook()
    isVisible = false
    splashView?.removeFromSuperview()
    spinner?.removeFromSuperview()
  }
}
