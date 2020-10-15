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
    var showDuration = kDefaultShowDuration
    var fadeInDuration = kDefaultFadeInDuration
    var fadeOutDuration = kDefaultFadeOutDuration
    var autoHide = kDefaultAutoHide
    var backgroundColor: String?
    var showSpinner = false
    var isLaunchSplash: Bool

    init(plugin: WSSplashScreen, call: CAPPluginCall?, isLaunchSplash: Bool) {
      self.isLaunchSplash = isLaunchSplash
      showDuration = plugin.getConfigInt("showDuration", call) ?? kDefaultShowDuration
      fadeInDuration = plugin.getConfigInt("fadeInDuration", call) ?? kDefaultFadeInDuration
      fadeOutDuration = plugin.getConfigInt("fadeOutDuration", call) ?? kDefaultFadeOutDuration
      autoHide = plugin.getConfigBool("autoHide", call) ?? kDefaultAutoHide
      backgroundColor = plugin.getConfigString("backgroundColor", call)
      showSpinner = plugin.getConfigBool("showSpinner", call) ?? false
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

  /*
   * Called when the plugin is loaded. Note the web view is not initialized yet,
   * but the bridge view controller is. We take this opportunity to show the
   * appropriate splash view in the bridge view controller.
   */
  override public func load() {
    showDuration = getConfigInt("showDuration") ?? kDefaultShowDuration

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
    showSplash(call: call, options: options, completion: { call.success() })
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
