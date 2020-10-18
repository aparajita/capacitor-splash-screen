import Capacitor

/*
 * A better version of the built in Capacitor SplashScreen plugin. Why better?
 *
 * 1. The stock SplashScreen plugin only shows a static image called "Splash".
 *    For obvious reasons, being limited to pixel images is not ideal.
 *    This plugin allows you to specify an image of any name, or even better,
 *    use any view (storyboard on iOS) as the splash screen. This gives you
 *    the full capabilities of the native layout engine, and add code to make it dynamic.
 *
 * 2. On iOS, the launch screen is removed as soon as the app is initialized.
 *    This happens *before* the web view is drawn, which means a blank screen
 *    appears before the initial view is drawn. This plugin solves that
 *    problem by displaying a copy of the launch screen until it is hidden,
 *    thus filling the gap in time.
 */

fileprivate let kDefaultFadeInDuration = 200
fileprivate let kDefaultFadeOutDuration = 200
fileprivate let kDefaultShowDuration = 3000
fileprivate let kDefaultAutoHide = true

@objc(WSSplashScreen)
public class WSSplashScreen: CAPPlugin {
  enum ErrorType: String {
    case noSplash = "noSplash"
    case animateMethodNotFound = "animateMethodNotFound"
  }

  struct ShowOptions {
    var showDuration: Int
    var fadeInDuration: Int
    var fadeOutDuration: Int
    var autoHide: Bool
    var backgroundColor: String?
    var animate: Bool
    var showSpinner: Bool
    var isLaunchSplash: Bool

    init(withPlugin plugin: WSSplashScreen, pluginCall call: CAPPluginCall?, isLaunchSplash: Bool) {
      showDuration = plugin.getConfigInt(withKeyPath: "showDuration", pluginCall: call) ?? kDefaultShowDuration
      fadeInDuration = plugin.getConfigInt(withKeyPath: "fadeInDuration", pluginCall: call) ?? kDefaultFadeInDuration
      fadeOutDuration = plugin.getConfigInt(withKeyPath: "fadeOutDuration", pluginCall: call) ?? kDefaultFadeOutDuration
      backgroundColor = plugin.getConfigString(withKeyPath: "backgroundColor", pluginCall: call)
      autoHide = plugin.getConfigBool(withKeyPath: "autoHide", pluginCall: call) ?? kDefaultAutoHide
      animate = plugin.getConfigBool(withKeyPath: "animate", pluginCall: call) ?? false
      showSpinner = plugin.getConfigBool(withKeyPath: "showSpinner", pluginCall: call) ?? false
      self.isLaunchSplash = isLaunchSplash
    }
  }

  struct HideOptions {
    var delay: Int
    var fadeOutDuration: Int

    init(plugin: WSSplashScreen, call: CAPPluginCall?) {
      delay = plugin.getConfigInt(withKeyPath: "delay", pluginCall: call) ?? 0
      fadeOutDuration = plugin.getConfigInt(withKeyPath: "fadeOutDuration", pluginCall: call) ?? kDefaultFadeOutDuration
    }
  }

  struct ViewInfo {
    var imageName = ""
    var image: UIImage?
    var storyboardName = ""
  }

  var viewInfo = ViewInfo()
  var splashView: UIView?
  var showDuration: Int = 0
  var spinner: UIActivityIndicatorView?
  var imageContentMode: UIView.ContentMode = .scaleAspectFill
  var isVisible: Bool = false
  var logLevel = LogLevel.info

  /*
   * Called when the plugin is loaded. Note the web view is not initialized yet,
   * but the bridge view controller is. We take this opportunity to show the
   * appropriate splash view in the bridge view controller.
   */
  override public func load() {
    showDuration = getConfigInt(withKeyPath: "showDuration") ?? kDefaultShowDuration

    if showDuration == 0 {
      info("showDuration = 0, splash screen disabled")
    } else {
      setLogLevel()
      makeSplashView()
      showOnLaunch()
    }
  }

  /*
   * show() plugin call. Shows the splashscreen.
   */
  @objc public func show(_ call: CAPPluginCall) {
    guard splashView != nil else {
      return noSplashAvailable(forCall: call)
    }

    let options = ShowOptions(withPlugin: self, pluginCall: call, isLaunchSplash: false)
    debug("show():", options)
    showSplash(withOptions: options, pluginCall: call, completion: { call.success() })
  }

  /*
   * hide() plugin call. Hides the splash screen.
   */
  @objc public func hide(_ call: CAPPluginCall) {
    guard splashView != nil else {
      return noSplashAvailable(forCall: call)
    }

    let options = HideOptions(plugin: self, call: call)
    debug("hide():", options)
    hideSplash(withOptions: options, pluginCall: call, completion: { call.success() })
  }

  /*
   * animate() plugin call. Starts splash screen animation.
   */
  @objc public func animate(_ call: CAPPluginCall) {
    guard splashView != nil else {
      return noSplashAvailable(forCall: call)
    }

    guard let _ = getConfigBool(withKeyPath: "animate") else {
      return
    }

    DispatchQueue.main.async {
      let selector = Selector(("animateSplashScreen:"))

      if let delegate = UIApplication.shared.delegate, delegate.responds(to: selector) {
        delegate.perform(selector, with: [
          "plugin": self,
          "call": call,
          "splashView": self.splashView,
          "spinner": self.spinner
        ])
      } else {
        call.reject("The method animateSplashScreen(_: Any) is not defined in the AppDelegate class", ErrorType.animateMethodNotFound.rawValue)
      }
    }
  }

  private func noSplashAvailable(forCall call: CAPPluginCall) {
    call.reject("No splash screen view is available", ErrorType.noSplash.rawValue)
  }
}
