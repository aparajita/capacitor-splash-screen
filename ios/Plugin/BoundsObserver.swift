//
//  BoundsObserver.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

/*
 * KVO observer to watch changes to the main view's frame or bounds
 */
class BoundsObserver: NSObject {
  @objc var viewToObserve: UIView?
  var splash: WSSplashScreen?

  init(forSplash splash: WSSplashScreen) {
    super.init()
    self.splash = splash
    updateSplashBounds()

    if let view = splash.bridge?.viewController.view {
      viewToObserve = view

      _ = observe(
        \.viewToObserve?.frame,
        options: [],
        changeHandler: { (_, _) in self.updateSplashBounds() }
      )

      _ = observe(
        \.viewToObserve?.bounds,
        options: [],
        changeHandler: { (_, _) in self.updateSplashBounds() }
      )
    }
  }

  /*
   * Update the bounds for the splash view
   */
  func updateSplashBounds() {
    if let splash = self.splash,
       let view = splash.splashView {

      if view is UIImageView {
        // If the splash screen is an image, resize it according to the content mode.
        view.frame = UIScreen.main.bounds
        view.contentMode = splash.imageContentMode

      } else {
        // If the splash screen is from a storyboard, size it to the
        // main view so it resizes along with it.
        if let frame = splash.bridge?.viewController.view.frame {
          view.frame = frame
        }

        view.contentMode = .scaleToFill
      }
    }
  }
}
