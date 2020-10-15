//
//  ShowSplash.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

import Capacitor

extension WSSplashScreen {
  func showOnLaunch() {
    let options = ShowOptions(plugin: self, call: nil, isLaunchSplash: true)
    showSplash(call: nil, options: options, completion: {})
  }

  func showSplash(call: CAPPluginCall?, options: ShowOptions, completion: @escaping () -> Void) {
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

      if let color = options.backgroundColor,
         let backgroundColor = UIColor(fromHex: color) {
        splashView.backgroundColor = backgroundColor
      }

      self.setupImageView(splashView, call)
      splashView.isUserInteractionEnabled = false
      splashView.frame = view.frame
      view.addSubview(splashView)

      self.setupSpinner(view, call)
      self.showSplashViewWithTransition(view: view, options: options, completion: completion)
    }
  }

  func showSplashViewWithTransition(view: UIView, options: ShowOptions, completion: @escaping () -> Void) {
    view.isUserInteractionEnabled = false

    // swiftlint doesn't like nested trailing closures, so we define this separately
    let onTransitionEnd: (Bool) -> Void = { _ in
      self.isVisible = true

      if options.autoHide {
        DispatchQueue.main.asyncAfter(
          deadline: DispatchTime.now() + (Double(options.showDuration) / 1000)
        ) {
          self.hideSplash(
            fadeOutDuration: options.fadeOutDuration,
            isLaunchSplash: options.isLaunchSplash,
            autoHides: options.autoHide
          )
          completion()
        }
      } else {
        completion()
      }
    }

    UIView.transition(
      with: view,
      duration: TimeInterval(Double(options.fadeInDuration) / 1000),
      options: .curveLinear,
      animations: {
        if let splashView = self.splashView {
          splashView.alpha = 1
        }

        if let spinner = self.spinner {
          spinner.alpha = 1
        }
      },
      completion: onTransitionEnd
    )
  }

  // swiftlint:disable cyclomatic_complexity
  func setupImageView(_ view: UIView, _ call: CAPPluginCall?) {
    guard viewInfo.image != nil else {
      return
    }

    if let mode = getConfigString("ios.imageContentMode", call) {
      var contentMode: UIView.ContentMode

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

      view.contentMode = contentMode
    }
  }

  func setupSpinner(_ view: UIView, _ call: CAPPluginCall?) {
    guard let spinner = self.spinner else {
      return
    }

    let spinnerStyle = getConfigString("ios.spinnerStyle", call)
    let spinnerColor = getConfigString("spinnerColor", call)

    if let style = spinnerStyle {
      switch style.lowercased() {
      case "small":
        spinner.style = .white
      default:
        spinner.style = .whiteLarge
      }
    }

    if let color = spinnerColor,
       let uiColor = UIColor(fromHex: color) {
      spinner.color = uiColor
    }

    view.addSubview(spinner)
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}
