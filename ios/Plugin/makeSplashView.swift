//
//  setupViews.swift
//  CapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension NSObject {
  func clone<T: NSObject>() throws -> T? {
    let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
  }
}

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
    if let name = CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), "UILaunchStoryboardName" as CFString),
       let storyboard = name as? String {
      return checkForStoryboard(named: storyboard)
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
      splashView = try? vcView.clone()

      if splashView != nil {
        logger?.info("Using storyboard \"\(viewInfo.source)\"")
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
        logger?.error(error)
      }
    }
  }
}
