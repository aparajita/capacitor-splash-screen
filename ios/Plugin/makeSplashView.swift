//
//  makeSplashView.swift
//  CapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension SplashScreen {
  /*
   * Build the views used to display the splash screen.
   * If an error occurs, the error message is returned.
   */
  func buildView(forPluginCall call: CAPPluginCall?, fromSource source: String) {
    // If the source has not changed, the splashView should already be built
    guard source != self.source else {
      return
    }

    self.source = source
    var found = false
    splashView = nil
    viewInfo = ViewInfo()

    // If the source name is "*", use the iOS launch screen
    if source == "*" {
      found = checkForLaunchScreen()
    } else {
      found = checkForStoryboard(named: source)
    }

    guard found else {
      return
    }

    if viewInfo.storyboard != nil {
      makeStoryboardSplashView(withCall: call)
    }

    guard splashView != nil else {
      return
    }

    // Observe for changes on frame and bounds to handle rotation resizing
    _ = BoundsObserver(forSplash: self)
  }

  /*
   * Try to get the app's launch storyboard.
   */
  func checkForLaunchScreen() -> Bool {
    if let name = Bundle.main.infoDictionary?["UILaunchStoryboardName"] as? String {
      let storyboardName = name.replacingOccurrences(of: ".storyboard", with: "")

      if let storyboard = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() {
        viewInfo.source = storyboardName
        viewInfo.storyboard = storyboard
        return true
      }
    }

    return false
  }

  /*
   * Check for a storyboard with the given name.
   */
  func checkForStoryboard(named name: String) -> Bool {
    if let storyboard = Storyboard.getNamed(name) {
      viewInfo.source = name
      viewInfo.storyboard = storyboard.instantiateInitialViewController()
      return true
    }

    return false
  }

  func makeStoryboardSplashView(withCall call: CAPPluginCall?) {
    var error = ""

    if let storyboard = viewInfo.storyboard {
      if let vcView = storyboard.view {
        splashView = vcView

        if splashView != nil {
          logger?.info("Using storyboard \"\(viewInfo.source)\"")

          // If this is a launch screen, set the webview background to the launch screen
          // background so that there is not a flash of white color.
          if isLaunchSplash {
            parentView?.backgroundColor = splashView?.backgroundColor
          }
        } else {
          error = "Unable to get the \"\(viewInfo.source)\" storyboard view"
        }
      }
    } else {
      error = "Unable to instantiate the \"\(viewInfo.source)\" storyboard view controller"
    }

    if !error.isEmpty {
      if let call = call {
        call.reject(error, ErrorType.noSplash.rawValue)
      } else {
        logger?.error(error)
      }
    }
  }
}
