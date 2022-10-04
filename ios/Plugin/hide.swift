//
//  hide.swift
//  CapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension SplashScreen {
  func hide(withOptions options: HideOptions, pluginCall call: CAPPluginCall?) {
    // If we are in the process of hiding, don't do anything
    guard !isHiding else {
      call?.resolve()
      return
    }

    isHiding = true

    DispatchQueue.main.async {
      UIView.animate(
        withDuration: options.fadeOutDuration,
        delay: options.delay,
        options: [.curveLinear],
        animations: {
          self.splashView?.alpha = 0
        },
        completion: { _ in
          self.tearDown()
          call?.resolve()
        }
      )
    }
  }

  /*
   * Clean up after the splash is hidden
   */
  func tearDown() {
    isActive = false
    isHiding = false
    splashView?.removeFromSuperview()
  }
}
