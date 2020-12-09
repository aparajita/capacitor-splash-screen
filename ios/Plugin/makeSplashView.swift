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
  func buildViews(forPluginCall call: CAPPluginCall?) {
    var found = false

    // Check for a source. The order of precedence is:
    //   - iOS-specific
    //   - cross-platform
    //   - default
    var source = ""

    // Check call first
    if let call = call {
      source = call.getStringOption("iosSource") ?? call.getStringOption("source") ?? ""
    }

    // If the source is not in the call, check config, then fall back to the default
    if source.isEmpty {
      source = getConfigString(withKeyPath: "iosSource") ?? getConfigString(withKeyPath: "source") ?? "Splash"
    }

    // If the source has not changed, the splashView should already be built
    guard source != self.source else {
      return
    }

    self.source = source
    splashView = nil
    viewInfo = ViewInfo()

    // If the source name is "*", use the iOS launch screen
    if source == "*" {
      found = checkForLaunchScreen()

    } else {
      found = checkForImage(named: source)

      if !found {
        found = checkForStoryboard(named: source)
      }
    }

    if !found {
      let message = "No image or storyboard named \"\(source)\" found"

      if let call = call {
        return call.reject(message, ErrorType.notFound.rawValue)
      } else {
        logger.error(message)
      }
    }

    if viewInfo.storyboard != nil {
      makeStoryboardSplashView(withCall: call)

    } else if viewInfo.image != nil {
      makeImageSplashView()
    }

    guard splashView != nil else {
      return
    }

    // Observe for changes on frame and bounds to handle rotation resizing
    _ = BoundsObserver(forSplash: self)
  }

  func getSourceOption(named name: String, call: CAPPluginCall?) -> String {
    if let sourceOption = getConfigString(withKeyPath: name, pluginCall: call),
       !sourceOption.isEmpty {
      return sourceOption
    }

    return ""
  }

  /*
   * Check for an image with the given name.
   */
  func checkForImage(named name: String) -> Bool {
    if let image = UIImage(named: name) {
      viewInfo.source = name
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
      viewInfo.source = name
      viewInfo.storyboard = storyboard
      return true
    }

    return false
  }

  /*
   * Given a storyboard name, attempt to instantiate the storyboard, then clone
   * the top level view, which we will use as the splash view.
   */
  func makeStoryboardSplashView(withCall call: CAPPluginCall?) {
    // Technically this should never be nil, but it's an optional so we have to unwrap it
    guard let storyboard = viewInfo.storyboard else {
      return
    }

    let viewController = storyboard.instantiateInitialViewController()
    var error = ""

    if let vcView = viewController?.view {
      // Clone the view
      let archive = NSKeyedArchiver.archivedData(withRootObject: vcView)
      splashView = NSKeyedUnarchiver.unarchiveObject(with: archive) as? UIView

      if splashView != nil {
        logger.info("Using storyboard \"\(viewInfo.source)\"")
      } else {
        error = "Unable to clone the \"\(viewInfo.source)\" storyboard view"
      }

    } else {
      error = "Unable to instantiate the \"\(viewInfo.source)\" storyboard view controller"
    }

    if !error.isEmpty {
      if let call = call {
        call.reject(error, ErrorType.noSplash.rawValue)
      } else {
        logger.error(error)
      }
    }
  }

  /*
   * Given an image, use it as the basis for the splash view.
   * If the backgroundColor plugin option is set, use that as the background color
   * of the splash view.
   */
  func makeImageSplashView() {
    splashView = UIImageView(image: viewInfo.image)
    logger.info("Using image \"\(viewInfo.source)\"")
  }
}
