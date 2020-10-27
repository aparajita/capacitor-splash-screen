//
//  setupViews.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension WSSplashScreen {
  /*
   * Build the views used to display the splash screen.
   */
  func buildViews(forPluginCall pluginCall: CAPPluginCall?) {
    var found = false

    // Allow the default legacy behavior of using a resource called "Splash".
    var resource = "Splash"

    // See if a resource was specified in the call or the config. This takes precedence.
    if let resourceName = getConfigString(withKeyPath: "resource", pluginCall: pluginCall) {
      resource = resourceName
    }

    if !resource.isEmpty {
      // If the resource name is "*", use the iOS launch screen
      if resource == "*" {
        found = checkForLaunchScreen()
      } else {
        found = checkForImage(named: resource)

        if !found {
          found = checkForStoryboard(named: resource)
        }
      }
    }

    if viewInfo.storyboard != nil {
      makeStoryboardSplashView()

    } else if viewInfo.image != nil {
      makeImageSplashView()

    } else {
      warn("No splash image or storyboard found")
    }

    guard splashView != nil else {
      return
    }

    // Observe for changes on frame and bounds to handle rotation resizing
    _ = BoundsObserver(forSplash: self)
  }

  /*
   * Check for an image with the given name.
   */
  func checkForImage(named name: String) -> Bool {
    if let image = UIImage(named: name) {
      viewInfo.resourceName = name
      viewInfo.image = image
      return true
    }

    return false
  }

  /*
   * Try to get the app's launch storyboard.
   */
  func checkForLaunchScreen() -> Bool {
    if let plist = Bundle.main.infoDictionary,
       let name = plist["UILaunchStoryboardName"] as? String {
      return checkForStoryboard(named: name)
    }

    return false
  }

  /*
   * Check for a storyboard with the given name.
   */
  func checkForStoryboard(named name: String) -> Bool {
    if let storyboard = Storyboard.getNamed(name) {
      viewInfo.resourceName = name
      viewInfo.storyboard = storyboard
      return true
    }

    return false
  }

  /*
   * Given a storyboard name, attempt to instantiate the storyboard, then clone
   * the top level view, which we will use as the splash view.
   *
   * WARNING! If the named storyboard does not exist, this will crash.
   */
  func makeStoryboardSplashView() {
    guard let storyboard = viewInfo.storyboard else {
      return
    }

    let viewController = storyboard.instantiateInitialViewController()

    if let vcView = viewController?.view {
      // Clone the view
      let archive = NSKeyedArchiver.archivedData(withRootObject: vcView)
      splashView = NSKeyedUnarchiver.unarchiveObject(with: archive) as? UIView

      if splashView != nil {
        info("Using storyboard \"\(viewInfo.resourceName)\"")
      } else {
        error("Unable to clone the \"\(viewInfo.resourceName)\" storyboard view")
      }

    } else {
      error("Unable to instantiate the \"\(viewInfo.resourceName)\" storyboard view controller")
    }
  }

  /*
   * Given an image, use it as the basis for the splash view.
   * If the backgroundColor plugin option is set, use that as the background color
   * of the splash view.
   */
  func makeImageSplashView() {
    splashView = UIImageView(image: viewInfo.image)
    self.info("Using image \"\(viewInfo.resourceName)\"")
  }
}
