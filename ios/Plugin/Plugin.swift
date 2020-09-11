import Capacitor

@objc(WSSplashScreen)
public class WSSplashScreen: CAPPlugin {
  var splashView: UIView?
  var spinner = UIActivityIndicatorView()
  var showSpinner: Bool = false
  var call: CAPPluginCall?
  var hideTask: Any?
  var isVisible: Bool = false
  
  let kDefaultLaunchShowDuration = 3000
  let kDefaultLaunchAutoHide = true

  let kDefaultFadeInDuration = 200
  let kDefaultFadeOutDuration = 200
  let kDefaultShowDuration = 3000
  let kDefaultAutoHide = true

  public override func load() {
    let launchShowDuration = getConfigValue("launchShowDuration") as? Int ?? kDefaultLaunchShowDuration

    if (launchShowDuration == 0) {
      self.log("launchShowDuration = 0, splash screen disabled")
    } else {
      buildViews()
      showOnLaunch()
    }
  }

  func log(_ items: Any...) {
    let message = items.map { "\($0)" }.joined(separator: " ")
    CAPLog.print("[\(self.pluginId!)]", message)
  }

  // Show the splash screen
  @objc public func show(_ call: CAPPluginCall) {
    self.call = call

    if splashView == nil {
      call.error("No splash image or storyboard found")
      return
    }

    let showDuration = call.getInt("showDuration", kDefaultShowDuration)!
    let fadeInDuration = call.getInt("fadeInDuration", kDefaultFadeInDuration)!
    let fadeOutDuration = call.getInt("fadeOutDuration", kDefaultFadeOutDuration)!
    let autoHide = call.getBool("autoHide", kDefaultAutoHide)!
    let backgroundColor = getConfigValue("backgroundColor") as? String ?? nil
    let spinnerStyle = getConfigValue("iosSpinnerStyle") as? String ?? nil
    let spinnerColor = getConfigValue("spinnerColor") as? String ?? nil
    showSpinner = getConfigValue("showSpinner") as? Bool ?? false

    showSplash(showDuration: showDuration, fadeInDuration: fadeInDuration, fadeOutDuration: fadeOutDuration, autoHide: autoHide, backgroundColor: backgroundColor, spinnerStyle: spinnerStyle, spinnerColor: spinnerColor, completion: {
      call.success()
    }, isLaunchSplash: false)
  }

  // Hide the splash screen
  @objc public func hide(_ call: CAPPluginCall) {
    self.call = call
    let fadeDuration = call.getInt("fadeOutDuration", kDefaultFadeOutDuration)!
    hideSplash(fadeOutDuration: fadeDuration)
    call.success()
  }


  func buildViews() {
    var imageName = ""
    var image: UIImage?
    var storyboardName = ""

    // First support the legacy behavior, an image called "Splash"
    if let img = UIImage(named: "Splash") {
      imageName = "Splash"
      image = img
    }
      // Next check to see if the launch screen storyboard should be used
    else if getConfigValue("iosUseLaunchScreen") as? Bool ?? false {
      if let plist = Bundle.main.infoDictionary {
        if let launchStoryboardName = plist["UILaunchStoryboardName"] as? String {
          storyboardName = launchStoryboardName
        }
      }
    }
      // Next look for a custom storyboard. Note that if specified,
      // it must exist or the app will crash.
    else if let name = getConfigValue("iosStoryboard") as? String {
      storyboardName = name
    }
      // Next try a custom image
    else if let name = getConfigValue("iosImage") as? String {
      if let img = UIImage(named: name) {
        imageName = name
        image = img
      } else {
        self.log("Unable to find the image \"\(name)\"")
      }
    }
    else {
      self.log("No image or storyboard specified")
    }

    if !storyboardName.isEmpty {
      // Use the top level view of a storyboard for the splash screen
      let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
      let vc = storyboard.instantiateInitialViewController()

      if let vcView = vc?.view {
        splashView = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: vcView))! as? UIView
        self.log("Using storyboard \"\(storyboardName)\"")
      } else {
        self.log("Unable to instantiate the \"\(storyboardName)\" storyboard view")
      }
    } else if !imageName.isEmpty {
      splashView = UIImageView(image: image)
      self.log("Using image \"\(imageName)\"")

      if let backgroundColor = getConfigValue("backgroundColor") as? String {
        splashView?.backgroundColor = UIColor(fromHex: backgroundColor)
      }
    }

    if splashView != nil {
      updateSplashBounds()

      // Observe for changes on frame and bounds to handle rotation resizing
      let parentView = bridge.viewController.view
      parentView?.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
      parentView?.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
    }

    showSpinner = getConfigValue("showSpinner") as? Bool ?? false

    if showSpinner {
      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.startAnimating()
    }
  }

  func tearDown() {
    isVisible = false
    bridge.viewController.view.isUserInteractionEnabled = true
    splashView?.removeFromSuperview()

    if showSpinner {
      spinner.removeFromSuperview()
    }
  }

  // Update the bounds for the splash view. This will also be called when
  // the parent view observers fire.
  func updateSplashBounds() {
    if splashView != nil {
      if splashView is UIImageView {
        // If the splash screen is an image, we want it to fill
        // the entire screen but keep its aspect ratio.
        splashView!.frame = UIScreen.main.bounds
        splashView!.contentMode = .scaleAspectFill
      } else {
        // If the splash screen is from a storyboard, size it to the
        // main view so it resizes along with it.
        splashView!.frame = bridge.viewController.view.frame
        splashView!.contentMode = .scaleToFill
      }
    }
  }

  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change _: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    updateSplashBounds()
  }

  func showOnLaunch() {
    let launchShowDuration = getConfigValue("launchShowDuration") as? Int ?? kDefaultLaunchShowDuration
    let launchAutoHide = getConfigValue("launchAutoHide") as? Bool ?? kDefaultLaunchAutoHide
    let launchBackgroundColor = getConfigValue("backgroundColor") as? String ?? nil
    let launchSpinnerStyle = getConfigValue("iosSpinnerStyle") as? String ?? nil
    let launchSpinnerColor = getConfigValue("spinnerColor") as? String ?? nil

    // If launchShowDuration is zero, the splash screen is disabled
    if launchShowDuration == 0 {
      return
    }

    let view = bridge.viewController.view

    // If there is no view in which to show the splash screen, bail
    if view == nil {
      return
    }

    if splashView != nil {
      splashView!.isUserInteractionEnabled = false
      splashView!.frame = view!.frame
      view!.addSubview(splashView!)
    }

    if showSpinner {
      view!.addSubview(spinner)
      spinner.centerXAnchor.constraint(equalTo: view!.centerXAnchor).isActive = true
      spinner.centerYAnchor.constraint(equalTo: view!.centerYAnchor).isActive = true
    }

    showSplash(showDuration: launchShowDuration, fadeInDuration: 0, fadeOutDuration: kDefaultFadeOutDuration, autoHide: launchAutoHide, backgroundColor: launchBackgroundColor, spinnerStyle: launchSpinnerStyle, spinnerColor: launchSpinnerColor, completion: {
    }, isLaunchSplash: true)
  }

  func showSplash(showDuration: Int, fadeInDuration: Int, fadeOutDuration: Int, autoHide: Bool, backgroundColor: String?, spinnerStyle: String?, spinnerColor: String?, completion: @escaping () -> Void, isLaunchSplash: Bool) {
    DispatchQueue.main.async {
      if backgroundColor != nil {
        self.splashView?.backgroundColor = UIColor(fromHex: backgroundColor!)
      }

      let view = self.bridge.viewController.view

      // If there's no view in which to place the splash screen, bail
      if view == nil {
        return
      }

      if self.showSpinner {
        if spinnerStyle != nil {
          switch spinnerStyle!.lowercased() {
          case "small":
            self.spinner.style = .white
          default:
            self.spinner.style = .whiteLarge
          }
        }

        if spinnerColor != nil {
          self.spinner.color = UIColor(fromHex: spinnerColor!)
        }
      }

      if !isLaunchSplash {
        if self.splashView != nil {
          view!.addSubview(self.splashView!)
        }

        if self.showSpinner {
          view!.addSubview(self.spinner)
          self.spinner.centerXAnchor.constraint(equalTo: view!.centerXAnchor).isActive = true
          self.spinner.centerYAnchor.constraint(equalTo: view!.centerYAnchor).isActive = true
        }
      }

      view!.isUserInteractionEnabled = false

      UIView.transition(with: view!, duration: TimeInterval(Double(fadeInDuration) / 1000), options: .curveLinear, animations: {
        self.splashView?.alpha = 1

        if self.showSpinner {
          self.spinner.alpha = 1
        }
      }) { (finished: Bool) in
        self.isVisible = true

        if autoHide {
          self.hideTask = DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + (Double(showDuration) / 1000)
          ) {
            self.hideSplash(fadeOutDuration: fadeOutDuration, isLaunchSplash: isLaunchSplash)
            completion()
          }
        } else {
          completion()
        }
      }
    }
  }

  func hideSplash(fadeOutDuration: Int) {
    hideSplash(fadeOutDuration: fadeOutDuration, isLaunchSplash: false)
  }

  func hideSplash(fadeOutDuration: Int, isLaunchSplash: Bool) {
    if isLaunchSplash, isVisible {
      self.log("SplashScreen.hideSplash: SplashScreen was automatically hidden after default timeout. " +
        "You should call `SplashScreen.hide()` as soon as your web app is loaded (or increase the timeout). " +
        "Read more at https://capacitorjs.com/docs/apis/splash-screen#hiding-the-splash-screen")
    }

    if !isVisible {
      return
    }

    DispatchQueue.main.async {
      UIView.transition(with: self.bridge.viewController.view!, duration: TimeInterval(Double(fadeOutDuration) / 1000), options: .curveLinear, animations: {
        self.splashView?.alpha = 0

        if self.showSpinner {
          self.spinner.alpha = 0
        }
      }) { (finished: Bool) in
        self.tearDown()
      }
    }
  }
}
