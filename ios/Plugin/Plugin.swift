import AparajitaCapacitorLogger
import Capacitor

let kSourceOption = "source"
let kDefaultSource = "*"
let kDelayOption = "delay"
let kFadeInDurationOption = "fadeInDuration"
let kDefaultFadeInDuration = 0.2
let kShowDurationOption = "showDuration"
let kDefaultShowDuration = 0.7
let kAnimationDurationOption = "animationDuration"
let kDefaultAnimationDuration = 0.5
let kFadeOutDurationOption = "fadeOutDuration"
let kDefaultFadeOutDuration = 0.3
let kDurationMillisecondThreshold = 10.0

@objc(SplashScreen)
public class SplashScreen: CAPPlugin {
  public enum ErrorType: String {
    case notFound
    case noSplash
    case alreadyActive
    case animateMethodNotFound
    case animateMethodFailed
  }

  struct ShowOptions {
    var source: String
    var delay: Double
    var fadeInDuration: Double
    var showDuration: Double

    // Launch
    init(withPlugin plugin: CAPPlugin) {
      source = kDefaultSource
      delay = 0.0
      fadeInDuration = 0.0
      showDuration = toSeconds(
        Config.getDouble(kShowDurationOption, forPlugin: plugin)
          ?? kDefaultShowDuration
      )
    }

    // Call to show()
    init(withPluginCall call: CAPPluginCall) {
      source = Config.getString(kSourceOption, inOptions: call.options) ?? kDefaultSource
      delay = toSeconds(Config.getDouble(kDelayOption, inOptions: call.options) ?? 0)
      showDuration = toSeconds(
        Config.getDouble(kShowDurationOption, inOptions: call.options)
          ?? kDefaultShowDuration
      )
      fadeInDuration = toSeconds(
        Config.getDouble(kFadeInDurationOption, inOptions: call.options)
          ?? kDefaultFadeInDuration
      )
    }
  }

  struct HideOptions {
    var delay: Double
    var fadeOutDuration: Double

    init(call: CAPPluginCall) {
      delay = toSeconds(Config.getDouble(kDelayOption, inOptions: call.options) ?? 0)
      fadeOutDuration = toSeconds(
        Config.getDouble(kFadeOutDurationOption, inOptions: call.options)
          ?? kDefaultFadeOutDuration
      )
    }
  }

  struct ViewInfo {
    var source = ""
    var storyboard: UIStoryboard?
  }

  static var launchTime: Date?
  var isLaunchSplash = true
  var launchOptions: ShowOptions?
  var source = ""
  var viewInfo = ViewInfo()
  var splashView: UIView?
  var isActive: Bool = false
  var isHiding: Bool = false
  var logger: Logger?
  var eventHandler: Selector?
  var animatePluginCall: CAPPluginCall?

  public static func initLaunchTime() {
    launchTime = Date()
  }

  /*
   * iOS animation methods usually want seconds for durations.
   * Durations passed in to the plugin >= 10 are considered milliseconds, otherwise seconds.
   */
  public static func toSeconds(_ value: Double) -> Double {
    value >= kDurationMillisecondThreshold ? value / 1000 : value
  }

  func postError(call: CAPPluginCall?, message: String, code: ErrorType) {
    call?.reject(message, code.rawValue)
    isActive = false
  }

  override public func load() {
    var options = Logger.Options()

    if let loggerConfig = getConfig().getObject("logger") {
      if let configLevel = loggerConfig["level"] as? String,
         let level = Logger.LogLevel[configLevel] {
        options.level = level
      }

      if let useSyslog = loggerConfig["useSyslog"] as? Bool {
        options.useSyslog = useSyslog
      }
    }

    logger = Logger(withPlugin: self, options: options)
    logger?.info("native plugin loaded")

    let selector = Selector(("onSplashScreenEvent::"))

    if let delegate = UIApplication.shared.delegate, delegate.responds(to: selector) {
      eventHandler = selector
    }

    showLaunchScreen()
  }

  /*
   * show() plugin call
   */
  @objc public func show(_ call: CAPPluginCall) {
    isLaunchSplash = false
    let options = ShowOptions(withPluginCall: call)
    logger?.debug("show(): \(options)")
    show(withOptions: options, pluginCall: call)
  }

  /*
   * hide() plugin call
   */
  @objc public func hide(_ call: CAPPluginCall) {
    guard splashView != nil else {
      return noSplashAvailable(forCall: call)
    }

    var options = HideOptions(call: call)
    options.delay += waitForLaunchShowDuration()
    logger?.debug("hide(): \(options)")
    hide(withOptions: options, pluginCall: call)
  }

  /*
   * animate() plugin call
   */
  @objc public func animate(_ call: CAPPluginCall) {
    guard splashView != nil else {
      return noSplashAvailable(forCall: call)
    }

    animate(withCall: call, wait: waitForLaunchShowDuration())
  }

  func waitForLaunchShowDuration() -> Double {
    if isLaunchSplash,
       let options = launchOptions,
       let launchStart = SplashScreen.launchTime {
      // We want launch screens to be visible at least for the showDuration
      let timeSinceLaunch = Date().timeIntervalSince(launchStart)
      return max(options.showDuration - timeSinceLaunch, 0)
    }

    return 0
  }

  func noSplashAvailable(forCall call: CAPPluginCall?) {
    postError(call: call, message: "No splash screen view is available", code: ErrorType.noSplash)
  }
}
