//
//  ShowSplash.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension WSSplashScreen {
  func showOnLaunch() {
    let options = ShowOptions(withPlugin: self, pluginCall: nil, isLaunchSplash: true)
    debug("show at launch:", options)
    showSplash(withOptions: options, pluginCall: nil, completion: {})
  }

  func showSplash(withOptions options: ShowOptions, pluginCall call: CAPPluginCall?, completion: @escaping () -> Void) {
    // If there's no view in which to place the splash screen, bail
    guard let splashView = self.splashView else {
      return
    }

    showDuration = options.showDuration

    // We have to use the main thread to show something over the Ionic web view
    DispatchQueue.main.async {
      guard let view = self.bridge?.viewController.view else {
        return
      }

      if let color = options.backgroundColor {
        if let backgroundColor = self.makeUIColor(fromHex: color) {
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
      splashView.alpha = options.isLaunchSplash ? 1 : 0

      // Now add the splash to the container view
      view.addSubview(splashView)

      // If there is a spinner, add it on top of the splash
      self.setupSpinner(inView: view, pluginCall: call)

      self.animateSplash(view, withOptions: options, pluginCall: call, completion: completion)
    }
  }

  func animateSplash(_ view: UIView, withOptions options: ShowOptions, pluginCall call: CAPPluginCall?, completion: @escaping () -> Void) {
    // swiftlint doesn't like nested trailing closures, so we define this separately
    let onAnimationEnd: (Bool) -> Void = { _ in
      self.isVisible = true

      if options.isLaunchSplash && options.autoHide {
        DispatchQueue.main.asyncAfter(
          deadline: DispatchTime.now() + (Double(options.showDuration) / 1000)
        ) {
          let hideOptions = HideOptions(plugin: self, call: call)
          self.hideSplash(withOptions: hideOptions, pluginCall: call, completion: completion)
        }
      } else {
        completion()
      }
    }

    UIView.animate(
      withDuration: Double(options.fadeInDuration) / 1000,
      delay: 0,
      options: [.overrideInheritedOptions, .showHideTransitionViews, .curveLinear],
      animations: {
        self.splashView?.alpha = 1
        self.spinner?.alpha = 1
      },
      completion: onAnimationEnd
    )
  }

  // swiftlint:disable cyclomatic_complexity
  func setupImageView(_ view: UIView, pluginCall call: CAPPluginCall?) {
    guard viewInfo.image != nil else {
      return
    }

    var contentMode: UIView.ContentMode = .scaleAspectFill

    if let mode = getConfigString(withKeyPath: "iosImageContentMode", pluginCall: call) {
      switch mode {
      case "fill":
        contentMode = .scaleToFill

      case "aspectFill":
        contentMode = .scaleAspectFill

      case "aspectFit":
        contentMode = .scaleAspectFit

      case "center":
        contentMode = .center

      case "top":
        contentMode = .top

      case "bottom":
        contentMode = .bottom

      case "left":
        contentMode = .left

      case "right":
        contentMode = .right

      case "topLeft":
        contentMode = .topLeft

      case "topRight":
        contentMode = .topRight

      case "bottomLeft":
        contentMode = .bottomLeft

      case "bottomRight":
        contentMode = .bottomRight

      default:
        contentMode = .scaleAspectFill
      }
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
       let uiColor = makeUIColor(fromHex: spinnerColor) {
      spinner.color = uiColor
    }

    view.addSubview(spinner)
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    spinner.startAnimating()
  }

  func makeUIColor(fromHex hex: String) -> UIColor? {
    if let uiColor = UIColor(fromHex: hex) {
      return uiColor
    }

    self.warn("Invalid hex color: \(hex)")
    return nil
  }
}
