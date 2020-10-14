//
//  setupViews.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

extension WSSplashScreen {
  /*
   * Build the views used to display the splash screen.
   */
  func buildViews() {
    var viewInfo = ViewInfo()

    // First support the legacy behavior, an image called "Splash"
    var found = checkForSplashImage(&viewInfo)

    // Next check to see if the launch screen storyboard should be used
    if !found {
      found = checkForLaunchScreen(&viewInfo)
    }

    // Next look for a custom storyboard. Note that if specified,
    // it must exist or the app will crash.
    if !found {
      found = checkForCustomStoryboard(&viewInfo)
    }

    // Next try a custom image
    if !found {
      found = checkForCustomImage(&viewInfo)
    }

    if !viewInfo.storyboardName.isEmpty {
      makeStoryboardSplashView(viewInfo.storyboardName)
    } else if viewInfo.image != nil {
      makeImageSplashView(viewInfo)
    } else {
      warn("No splash image or storyboard specified")
    }

    guard splashView != nil else {
      return
    }

    // Observe for changes on frame and bounds to handle rotation resizing
    _ = BoundsObserver(self)
  }

  /*
   * Check for an image named "Splash".
   */
  func checkForSplashImage(_ info: inout ViewInfo) -> Bool {
    if let image = UIImage(named: "Splash") {
      info.imageName = "Splash"
      info.image = image
      return true
    }

    return false
  }

  /*
   * If the ios.useLaunchScreen plugin option is true, try to get the app's launch storyboard name.
   */
  func checkForLaunchScreen(_ info: inout ViewInfo) -> Bool {
    if getConfigValue("ios.useLaunchScreen") as? Bool ?? false {
      if let plist = Bundle.main.infoDictionary {
        if let launchStoryboardName = plist["UILaunchStoryboardName"] as? String {
          info.storyboardName = launchStoryboardName
          return true
        }
      }
    }

    return false
  }

  /*
   * Check for a non-empty ios.storyboard plugin option.
   */
  func checkForCustomStoryboard(_ info: inout ViewInfo) -> Bool {
    if let name = getConfigValue("ios.storyboard") as? String {
      info.storyboardName = name
      return true
    }

    return false
  }

  /*
   * Check for a non-empty ios.image plugin option. If it exists,
   * attempt to create the named image.
   */
  func checkForCustomImage(_ info: inout ViewInfo) -> Bool {
    if let name = getConfigValue("ios.image") as? String {
      if let image = UIImage(named: name) {
        info.imageName = name
        info.image = image
        return true
      }

      error("Unable to find the image \"\(name)\"")
    }

    return false
  }

  /*
   * If the showSpinner plugin option is true, create a spinner.
   */
  func checkForSpinner() {
    showSpinner = getConfigValue("showSpinner") as? Bool ?? false

    if showSpinner {
      spinner = UIActivityIndicatorView()

      guard let spin = spinner else {
        showSpinner = false
        return
      }

      spin.translatesAutoresizingMaskIntoConstraints = false
      spin.startAnimating()
    }
  }

  /*
   * Given a storyboard name, attempt to instantiate the storyboard, then clone
   * the top level view, which we will use as the splash view.
   *
   * WARNING! If the named storyboard does not exist, this will crash.
   */
  func makeStoryboardSplashView(_ name: String) {
    let storyboard = UIStoryboard(name: name, bundle: nil)
    let viewController = storyboard.instantiateInitialViewController()

    if let vcView = viewController?.view {
      // Clone the view
      let archive = NSKeyedArchiver.archivedData(withRootObject: vcView)
      splashView = NSKeyedUnarchiver.unarchiveObject(with: archive) as? UIView

      if splashView != nil {
        info("Using storyboard \"\(name)\"")
      } else {
        error("Unable to clone the \"\(name)\" storyboard view")
      }
    } else {
      error("Unable to instantiate the \"\(name)\" storyboard view controller")
    }
  }

  /*
   * Given an image, use it as the basis for the splash view.
   * If the backgroundColor plugin option is set, use that as the background color
   * of the splash view.
   */
  func makeImageSplashView(_ info: ViewInfo) {
    splashView = UIImageView(image: info.image)
    self.info("Using image \"\(info.imageName)\"")

    if let backgroundColor = getConfigValue("backgroundColor") as? String, let view = splashView {
      view.backgroundColor = UIColor(fromHex: backgroundColor)
    }
  }
}
