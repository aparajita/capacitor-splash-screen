//
//  BoundsObserver.swift
//  CapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

/*
 * KVO observer to watch changes to the main view's frame or bounds
 */
class BoundsObserver: NSObject {
  @objc var viewToObserve: UIView?
  var splash: SplashScreen?

  init(forSplash splash: SplashScreen) {
    super.init()
    self.splash = splash
    updateSplashBounds()

    if let view = splash.bridge?.viewController?.view {
      viewToObserve = view

      _ = observe(
        \.viewToObserve?.frame,
        options: [],
        changeHandler: { _, _ in self.updateSplashBounds() }
      )

      _ = observe(
        \.viewToObserve?.bounds,
        options: [],
        changeHandler: { _, _ in self.updateSplashBounds() }
      )
    }
  }

  /*
   * Update the bounds for the splash view
   */
  func updateSplashBounds() {
    if let splash = splash,
       let view = splash.splashView {
      // Size it to the main view so it resizes along with it.
      if let frame = splash.bridge?.viewController?.view.frame {
        view.frame = frame
      }

      view.contentMode = .scaleToFill
    }
  }
}
