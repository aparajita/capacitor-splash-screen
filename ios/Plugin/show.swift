//
//  ShowSplash.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension WSSplashScreen {
  static let contentModeMap: [String: UIView.ContentMode] = [
    "fill": .scaleToFill,
    "aspectFill": .scaleAspectFill,
    "fit": .scaleAspectFit,
    "center": .center,
    "top": .top,
    "bottom": .bottom,
    "left": .left,
    "right": .right,
    "topLeft": .topLeft,
    "topRight": .topRight,
    "bottomLeft": .bottomLeft,
    "bottomRight": .bottomRight
  ]

  func showOnLaunch() {
    let options = ShowOptions(withPlugin: self, pluginCall: nil, isLaunchSplash: true)
    logger.debug("show at launch:", options)
    showSplash(withOptions: options, pluginCall: nil)
  }

  func showSplash(withOptions options: ShowOptions, pluginCall call: CAPPluginCall?) {
    // We have to use the main thread to show something over the Ionic web view
    DispatchQueue.main.async {
      self.buildViews(forPluginCall: call)

      // If buildViews() failed, splashView will be nil
      guard let splashView = self.splashView else {
        return
      }

      guard let view = self.bridge?.viewController.view else {
        return
      }

      // Remove any existing color
      splashView.backgroundColor = nil

      if let color = options.backgroundColor {
        if let backgroundColor = self.makeUIColor(fromString: color) {
          splashView.backgroundColor = backgroundColor
        }
      }

      // Size the splash to the screen
      splashView.frame = view.frame

      // If the splash is an image, set its scale/position now
      self.setupImageView(splashView, pluginCall: call)

      /*
       * NOTE: When we are showing the splash during launch, fadeInDuration does not actually
       * come into play, because the splashView alpha is already 1. If we set it to 0 before
       * the animation, after the iOS launch screen disappears there would be an empty screen
       * over which splashView would animate. Since this is unlikely to be the intended effect,
       * we leave the splashView alpha at 1, and then iOS performs a short cross dissolve
       * between the iOS launch screen and the splashView, which is invisible if they are identical.
       */
      if options.isLaunchSplash {
        splashView.alpha = 1
      } else {
        splashView.alpha = CGFloat(self.getConfigDouble(withKeyPath: "startAlpha", pluginCall: call) ?? 0.0)
      }

      // Now add the splash to the container view
      view.addSubview(splashView)

      // If there is a spinner, add it on top of the splash
      self.setupSpinner(inView: view, pluginCall: call)

      self.fadeInSplash(withOptions: options, pluginCall: call)
    }
  }

  func fadeInSplash(withOptions options: ShowOptions, pluginCall call: CAPPluginCall?) {
    // swiftlint doesn't like nested trailing closures, so we define this separately
    let onAnimationEnd: (Bool) -> Void = { _ in
      self.isVisible = true

      if options.autoHide {
        DispatchQueue.main.asyncAfter(
          deadline: DispatchTime.now() + options.showDuration
        ) {
          let hideOptions = HideOptions(plugin: self, call: call)
          self.hideSplash(withOptions: hideOptions, pluginCall: call)
        }
      } else {
        call?.success()
      }
    }

    callBeforeShowHook(withCall: call)

    UIView.animate(
      withDuration: options.fadeInDuration,
      delay: options.delay,
      options: [.overrideInheritedOptions, .curveLinear],
      animations: {
        self.splashView?.alpha = 1
        self.spinner?.alpha = 1
      },
      completion: onAnimationEnd
    )
  }

  func setupImageView(_ view: UIView, pluginCall call: CAPPluginCall?) {
    guard viewInfo.image != nil else {
      return
    }

    var contentMode: UIView.ContentMode = .scaleAspectFill

    if let configMode = getConfigString(withKeyPath: "iosImageDisplayMode", pluginCall: call),
       let mode = WSSplashScreen.contentModeMap[configMode] {
      contentMode = mode
    }

    view.contentMode = contentMode
  }

  func setupSpinner(inView view: UIView, pluginCall call: CAPPluginCall?) {
    guard let showSpinner = getConfigBool(withKeyPath: "showSpinner", pluginCall: call),
          showSpinner
    else {
      return
    }

    if self.spinner == nil {
      self.spinner = UIActivityIndicatorView()
    }

    guard let spinner = self.spinner else {
      return
    }

    // By default it's invisible, we want it to fade in with the splash view
    spinner.alpha = 0

    // We will use constraints to position it
    spinner.translatesAutoresizingMaskIntoConstraints = false

    if let spinnerStyle = getConfigString(withKeyPath: "iosSpinnerStyle", pluginCall: call) {
      switch spinnerStyle.lowercased() {
      case "small":
        spinner.style = .white
      default:
        spinner.style = .whiteLarge
      }
    }

    // Reset the color
    spinner.color = nil

    if let spinnerColor = getConfigString(withKeyPath: "spinnerColor", pluginCall: call),
       let uiColor = makeUIColor(fromString: spinnerColor) {
      spinner.color = uiColor
    }

    view.addSubview(spinner)
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    spinner.startAnimating()
  }

  func makeUIColor(fromString string: String) -> UIColor? {
    if !string.isEmpty {
      if let uiColor = UIColor.from(string: string) {
        return uiColor
      }

      logger.warn("Invalid color: \(string)")
    }

    return nil
  }
}
