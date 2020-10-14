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

let kDefaultFadeInDuration = 200
let kDefaultFadeOutDuration = 200
let kDefaultShowDuration = 3000
let kDefaultAutoHide = true

@objc(WSSplashScreen)
public class WSSplashScreen: CAPPlugin {
  struct ShowOptions {
    var showDuration: Int
    var fadeInDuration: Int
    var fadeOutDuration: Int
    var autoHide: Bool
    var backgroundColor: String?
    var spinnerStyle: String?
    var spinnerColor: String?
    var showSpinner: Bool
    var isLaunchSplash: Bool

    init(plugin: WSSplashScreen, call: CAPPluginCall?, isLaunchSplash: Bool) {
      showDuration = call?.getInt("showDuration") ?? plugin.getConfigValue("showDuration") as? Int ?? kDefaultShowDuration
      fadeInDuration = call?.getInt("fadeInDuration") ?? kDefaultFadeInDuration
      fadeOutDuration = call?.getInt("fadeOutDuration") ?? kDefaultFadeOutDuration
      autoHide = call?.getBool("autoHide") ?? plugin.getConfigValue("autoHide") as? Bool ?? kDefaultAutoHide
      backgroundColor = call?.getString("backgroundColor") ?? plugin.getConfigValue("backgroundColor") as? String
      spinnerStyle = call?.getString("iosSpinnerStyle") ?? plugin.getConfigValue("ios.spinnerStyle") as? String
      spinnerColor = call?.getString("spinnerColor") ?? plugin.getConfigValue("spinnerColor") as? String
      showSpinner = call?.getBool("showSpinner") ?? false
      self.isLaunchSplash = isLaunchSplash
    }
  }

  struct ViewInfo {
    var imageName = ""
    var image: UIImage?
    var storyboardName = ""
  }

  var splashView: UIView?
  var showDuration: Int = 0
  var spinner: UIActivityIndicatorView?
  var showSpinner: Bool = false
  var hideTask: Any?
  var isVisible: Bool = false

  /*
   * Called when the plugin is loaded. Note the web view is not initialized yet,
   * but the bridge view controller is. We take this opportunity to show the
   * appropriate splash view in the bridge view controller.
   */
  override public func load() {
    showDuration = getConfigValue("showDuration") as? Int ?? kDefaultShowDuration

    if showDuration == 0 {
      info("showDuration = 0, splash screen disabled")
    } else {
      buildViews()
      showOnLaunch()
    }
  }

  /*
   * show() plugin call. Shows the splashscreen.
   */
  @objc public func show(_ call: CAPPluginCall) {
    guard splashView != nil else {
      return call.error("No splash screen")
    }

    let options = ShowOptions(plugin: self, call: call, isLaunchSplash: false)
    showSplash(options, completion: { call.success() })
  }

  /*
   * hide() plugin call. Hides the splash screen.
   */
  @objc public func hide(_ call: CAPPluginCall) {
    guard splashView != nil else {
      return call.error("No splash screen")
    }

    let fadeDuration = call.getInt("fadeOutDuration") ?? kDefaultFadeOutDuration
    hideSplash(fadeOutDuration: fadeDuration)
    call.success()
  }
}
