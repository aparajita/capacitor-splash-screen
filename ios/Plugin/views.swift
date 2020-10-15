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
    // First support the legacy behavior, an image called "Splash"
    var found = checkForSplashImage()

    // Next check to see if the launch screen storyboard should be used
    if !found {
      found = checkForLaunchScreen()
    }

    // Next look for a custom storyboard. Note that if specified,
    // it must exist or the app will crash.
    if !found {
      found = checkForCustomStoryboard()
    }

    // Next try a custom image
    if !found {
      found = checkForCustomImage()
    }

    if !viewInfo.storyboardName.isEmpty {
      makeStoryboardSplashView()
    } else if viewInfo.image != nil {
      makeImageSplashView()
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
  func checkForSplashImage() -> Bool {
    if let image = UIImage(named: "Splash") {
      viewInfo.imageName = "Splash"
      viewInfo.image = image
      return true
    }

    return false
  }

  /*
   * If the ios.useLaunchScreen plugin option is true, try to get the app's launch storyboard name.
   */
  func checkForLaunchScreen() -> Bool {
    if getConfigBool("ios.useLaunchScreen") ?? false,
       let plist = Bundle.main.infoDictionary,
       let launchStoryboardName = plist["UILaunchStoryboardName"] as? String
    {
      viewInfo.storyboardName = launchStoryboardName
      return true
    }

    return false
  }

  /*
   * Check for a non-empty ios.storyboard plugin option.
   */
  func checkForCustomStoryboard() -> Bool {
    if let name = getConfigString("ios.storyboard") {
      viewInfo.storyboardName = name
      return true
    }

    return false
  }

  /*
   * Check for a non-empty ios.image plugin option. If it exists,
   * attempt to create the named image.
   */
  func checkForCustomImage() -> Bool {
    if let name = getConfigString("image") {
      if let image = UIImage(named: name) {
        viewInfo.imageName = name
        viewInfo.image = image
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
    let showSpinner = getConfigBool("showSpinner") ?? false

    if showSpinner {
      spinner = UIActivityIndicatorView()

      guard let spin = spinner else {
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
  func makeStoryboardSplashView() {
    let storyboard = UIStoryboard(name: viewInfo.storyboardName, bundle: nil)
    let viewController = storyboard.instantiateInitialViewController()

    if let vcView = viewController?.view {
      // Clone the view
      let archive = NSKeyedArchiver.archivedData(withRootObject: vcView)
      splashView = NSKeyedUnarchiver.unarchiveObject(with: archive) as? UIView

      if splashView != nil {
        info("Using storyboard \"\(viewInfo.storyboardName)\"")
      } else {
        error("Unable to clone the \"\(viewInfo.storyboardName)\" storyboard view")
      }
    } else {
      error("Unable to instantiate the \"\(viewInfo.storyboardName)\" storyboard view controller")
    }
  }

  /*
   * Given an image, use it as the basis for the splash view.
   * If the backgroundColor plugin option is set, use that as the background color
   * of the splash view.
   */
  func makeImageSplashView() {
    splashView = UIImageView(image: viewInfo.image)
    self.info("Using image \"\(viewInfo.imageName)\"")
  }
}
