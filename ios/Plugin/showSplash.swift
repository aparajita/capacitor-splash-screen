//
//  ShowSplash.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/13/20.
//

extension WSSplashScreen {
  func showOnLaunch() {
    let options = ShowOptions(plugin: self, call: nil, isLaunchSplash: true)
    showSplash(options, completion: {})
  }

  func showSplash(_ options: ShowOptions, completion: @escaping () -> Void) {
    // If there's no view in which to place the splash screen, bail
    guard let splashView = self.splashView, let view = self.bridge?.viewController.view else {
      return
    }

    showDuration = options.showDuration

    // We have to use the main thread to show something over the Ionic web view
    DispatchQueue.main.async {
      if let color = options.backgroundColor {
        splashView.backgroundColor = UIColor(fromHex: color)
      }

      splashView.isUserInteractionEnabled = false
      splashView.frame = view.frame
      view.addSubview(splashView)

      self.setupSpinner(view, options)
      self.showSplashViewWithTransition(view: view, options: options, completion: completion)
    }
  }

  func showSplashViewWithTransition(view: UIView, options: ShowOptions, completion: @escaping () -> Void) {
    view.isUserInteractionEnabled = false

    // swiftlint doesn't like nested trailing closures, so we define this separately
    let onTransitionEnd: (Bool) -> Void = { _ in
      self.isVisible = true

      if options.autoHide {
        self.hideTask = DispatchQueue.main.asyncAfter(
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

  func setupSpinner(_ view: UIView, _ options: ShowOptions) {
    guard let spinner = self.spinner else {
      return
    }

    if let spinnerStyle = options.spinnerStyle {
      switch spinnerStyle.lowercased() {
      case "small":
        spinner.style = .white
      default:
        spinner.style = .whiteLarge
      }
    }

    if let spinnerColor = options.spinnerColor {
      spinner.color = UIColor(fromHex: spinnerColor)
    }

    view.addSubview(spinner)
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}
