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

private let kDefaultFadeInDuration = 0.2
private let kDefaultFadeOutDuration = 0.2
private let kDefaultShowDuration = 3.0
private let kDefaultAutoHide = true

/*
 * iOS animation methods usually want seconds for durations.
 * Convert milliseconds to seconds if necessary.
 */
private func toSeconds(_ value: Double) -> Double {
  // We consider any values >= 20 to be milliseconds
  return value >= 20 ? value / 1000 : value
}

@objc(WSSplashScreen)
public class WSSplashScreen: CAPPlugin {
  enum ErrorType: String {
    case noSplash
    case animateMethodNotFound
  }

  struct ShowOptions {
    var showDuration: Double
    var fadeInDuration: Double
    var fadeOutDuration: Double
    var autoHide: Bool
    var backgroundColor: String?
    var animated: Bool
    var showSpinner: Bool
    var isLaunchSplash: Bool

    init(withPlugin plugin: WSSplashScreen, pluginCall call: CAPPluginCall?, isLaunchSplash: Bool) {
      showDuration = toSeconds(plugin.getConfigDouble(withKeyPath: "showDuration", pluginCall: call) ?? kDefaultShowDuration)
      fadeInDuration = toSeconds(plugin.getConfigDouble(withKeyPath: "fadeInDuration", pluginCall: call) ?? kDefaultFadeInDuration)
      fadeOutDuration = toSeconds(plugin.getConfigDouble(withKeyPath: "fadeOutDuration", pluginCall: call) ?? kDefaultFadeOutDuration)
      backgroundColor = plugin.getConfigString(withKeyPath: "backgroundColor", pluginCall: call)
      animated = plugin.getConfigBool(withKeyPath: "animated", pluginCall: call) ?? false

      // If the splash is marked as animated, it's up to the dev to hide the splash
      if animated {
        autoHide = false
      } else {
        autoHide = plugin.getConfigBool(withKeyPath: "autoHide", pluginCall: call) ?? kDefaultAutoHide
      }
      
      showSpinner = plugin.getConfigBool(withKeyPath: "showSpinner", pluginCall: call) ?? false
      self.isLaunchSplash = isLaunchSplash
    }
  }

  struct HideOptions {
    var delay: Double
    var fadeOutDuration: Double

    init(plugin: WSSplashScreen, call: CAPPluginCall?) {
      delay = toSeconds(plugin.getConfigDouble(withKeyPath: "delay", pluginCall: call) ?? 0)
      fadeOutDuration = toSeconds(
        plugin.getConfigDouble(withKeyPath: "fadeOutDuration", pluginCall: call) ?? kDefaultFadeOutDuration)
    }
  }

  struct ViewInfo {
    var resourceName = ""
    var image: UIImage?
    var storyboard: UIStoryboard?
  }

  var viewInfo = ViewInfo()
  var splashView: UIView?
  var showDuration: Double = 0
  var spinner: UIActivityIndicatorView?
  var imageContentMode: UIView.ContentMode = .scaleAspectFill
  var isVisible: Bool = false
  var logger = Logger()

  /*
   * Called when the plugin is loaded. Note the web view is not initialized yet,
   * but the bridge view controller is. We take this opportunity to show the
   * appropriate splash view in the bridge view controller.
   */
  override public func load() {
    showDuration = getConfigDouble(withKeyPath: "showDuration") ?? kDefaultShowDuration

    if showDuration == 0 {
      logger.warn("showDuration = 0, splash screen disabled")
    } else {
      logger.setLogLevel(getConfigString(withKeyPath: "logLevel") ?? "info")
      showOnLaunch()
    }
  }

  /*
   * show() plugin call. Shows the splashscreen.
   */
  @objc public func show(_ call: CAPPluginCall) {
    let options = ShowOptions(withPlugin: self, pluginCall: call, isLaunchSplash: false)
    logger.debug("show():", options)
    showSplash(withOptions: options, pluginCall: call)
  }

  /*
   * hide() plugin call. Hides the splash screen.
   */
  @objc public func hide(_ call: CAPPluginCall) {
    guard splashView != nil else {
      return noSplashAvailable(forCall: call)
    }

    let options = HideOptions(plugin: self, call: call)
    logger.debug("hide():", options)
    hideSplash(withOptions: options, pluginCall: call)
  }

  /*
   * animate() plugin call. Starts splash screen animation.
   */
  @objc public func animate(_ call: CAPPluginCall) {
    guard splashView != nil else {
      return noSplashAvailable(forCall: call)
    }

    guard let animated = getConfigBool(withKeyPath: "animated"),
          animated else {
      return
    }

    animate(withCall: call)
  }

  public func noSplashAvailable(forCall call: CAPPluginCall?) {
    if let call = call {
      call.reject("No splash screen view is available", ErrorType.noSplash.rawValue)
    }
  }
}
