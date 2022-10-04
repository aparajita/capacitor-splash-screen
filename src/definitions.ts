/// <reference types="@capacitor/cli" />

import type {
  PluginResultError,
  PluginListenerHandle,
  WebPlugin
} from '@capacitor/core'
// eslint-disable-next-line import/no-unassigned-import

/**
 * In options objects, when you specify a duration, it can either
 * be in seconds or milliseconds. Any value >= 10 will be considered
 * milliseconds, any value < 10 will be considered seconds.
 */
export type SplashScreenDuration = number

declare module '@capacitor/cli' {
  export interface PluginsConfig {
    // eslint-disable-next-line @typescript-eslint/naming-convention
    SplashScreen?: {
      /**
       * Capacitor config is only used for launch screens, not programmatic
       * splash screens. If the same `showDuration` value is used on both
       * iOS and Android, you may specify the value at the top level of the
       * SplashScreen plugin configuration.
       *
       * @since 2.0.0
       * @default 700 (milliseconds)
       */
      showDuration?: SplashScreenDuration

      /**
       * If `showDuration` should be different on iOS and Android,
       * you can specify the value for each platform.
       *
       * @since 2.0.0
       */
      ios?: {
        showDuration?: SplashScreenDuration
      }

      /**
       * If `showDuration` should be different on iOS and Android,
       * you can specify the value for each platform.
       *
       * @since 2.0.0
       */
      android?: {
        showDuration?: SplashScreenDuration
      }

      /**
       * This plugin has its own logger, which can be configured here.
       * See the Logger plugin for more information on the configuration options.
       * https://github.com/aparajita/capacitor-logger
       *
       * @since 2.0.0
       * @default { level: 'info', useSyslog: false }
       */
      logger?: {
        level?: 'debug' | 'info' | 'warn' | 'error' | 'silent'
        useSyslog?: boolean
      }
    }
  }
}

export interface SplashScreenShowOpts {
  /**
   * The source of the splash screen. Does not apply to launch screens.
   * On iOS, it may be a storyboard with the given name. On Android, it may
   * be any vector drawable with the given name. If the name is "*", on iOS
   * the configured LaunchScreen storyboard in the app's project will be used,
   * on Android the value of the `windowSplashScreenAnimatedIcon` item
   * in the launch theme will be used.
   *
   * @since 2.0.0
   * @default '*'
   */
  source?: string

  /**
   * How long to delay before showing the splash screen.
   * Does not apply to launch screens.
   *
   * @since 2.0.0
   * @default 0
   */
  delay?: SplashScreenDuration

  /**
   * How long to fade in. Does not apply to launch screens.
   *
   * @since 2.0.0
   * @default 200 (milliseconds)
   */
  fadeInDuration?: SplashScreenDuration

  /**
   * Launch: The minimum time to show the splash screen.
   * If `animate()` or `hide()` is called before this time elapses,
   * the screen will remain until the duration is finished.
   *
   * `show()`: How long to show the splash screen after fade in
   * and before fade out.
   *
   * @since 2.0.0
   * @default 700 (milliseconds)
   */
  showDuration?: SplashScreenDuration
}

/**
 * Show options may be specified separately for iOS and Android.
 */
export interface SplashScreenShowOptions extends SplashScreenShowOpts {
  ios?: SplashScreenShowOpts
  android?: SplashScreenShowOpts
}

export interface SplashScreenHideOpts {
  /**
   * How long to delay before hiding.
   *
   * @since 2.0.0
   * @default 0
   */
  delay?: SplashScreenDuration

  /**
   * How long to fade out.
   *
   * @since 2.0.0
   * @default 300 (milliseconds)
   */
  fadeOutDuration?: SplashScreenDuration
}

/**
 * Hide options may be specified separately for iOS and Android.
 */
export interface SplashScreenHideOptions extends SplashScreenHideOpts {
  ios?: SplashScreenHideOpts
  android?: SplashScreenHideOpts
}

export interface SplashScreenAnimateOpts {
  /**
   * How long to delay before starting the animation.
   *
   * @since 2.0.0
   * @default 0
   */
  delay?: SplashScreenDuration

  /**
   * How long animation should take when calling `animate`.
   *
   * @since 2.0.0
   * @default 500 (milliseconds)
   */
  animationDuration?: SplashScreenDuration

  /**
   * Arbitrary options may be passed to your animation code.
   *
   * @since 2.0.0
   * @default {}
   */
  [key: string]: unknown
}

/**
 * Animate options may be specified separately for iOS and Android.
 */
export interface SplashScreenAnimateOptions extends SplashScreenAnimateOpts {
  ios?: SplashScreenAnimateOpts
  android?: SplashScreenAnimateOpts
}

export interface SplashScreenAppStateListeners {
  /**
   * The code to call on app suspend.
   *
   * @since 2.0.0
   */
  onSuspend?: () => void

  /**
   * The code to call on opp resume.
   *
   * @since 2.0.0
   */
  onResume?: () => void
}

/**
 * If a plugin call is rejected, the error will contain a string .code property
 * whose value will be one of these.
 */
export enum SplashScreenErrorType {
  /**
   * show() was called and no splash resource could be found
   *
   * @since 1.0.0
   */
  notFound = 'notFound',

  /**
   * hide() or animate() was called when show() rejected with 'notFound'.
   *
   * @since 1.0.0
   */
  noSplashScreen = 'noSplashScreen',

  /**
   * show() was called when a splash screen is already active
   *
   * @since 2.0.0
   */
  alreadyActive = 'alreadyActive',

  /**
   * animate() was called but no animation method could be found in the app.
   *
   * @since 1.0.0
   */
  animateMethodNotFound = 'animateMethodNotFound',

  /**
   * animate() was called but the animation method threw an error.
   */
  animateMethodFailed = 'animateMethodFailed'
}

/**
 * If an error occurs, the returned Error object has a .code property
 * which is the string name of a StorageErrorType.
 *
 * @since 1.0.0
 */
export interface PluginError extends PluginResultError {
  code: string
}

/* eslint-disable @typescript-eslint/no-unused-vars */

/**
 * Convert a duration in either seconds or milliseconds
 * into milliseconds. A duration >= kDurationMillisecondThreshold (10)
 * is considered to be milliseconds. A duration less than
 * that is considered to be seconds.
 *
 * @since 2.0.0
 */
declare function durationToMs(duration: number): number

/**
 * Convert a duration in either seconds or milliseconds
 * into seconds. A duration >= kDurationMillisecondThreshold (10)
 * is considered to be milliseconds. A duration less than
 * that is considered to be seconds.
 *
 * @since 2.0.0
 */
declare function durationToSeconds(duration: number): number

/* eslint-enable */

export interface SplashScreenPlugin extends WebPlugin {
  /**
   * Show the splash screen. Does not apply to launch screens.
   *
   * NOTE: On Android, the size of the splash screen icon may not exactly
   * match the actual launch screen icon size. I was not able to determine
   * the algorithm used by Android to determine the size of the splash
   * screen icon.
   *
   * @native
   * @throws {PluginError} See `SplashScreenErrorType` for possible errors
   */
  show: (options?: SplashScreenShowOptions) => Promise<void>

  /**
   * Hide the splash screen. You must call `hide()` or `animate()` to
   * remove a launch screen, typically after your app is fully mounted.
   *
   * @native
   * @throws {PluginError} See `SplashScreenErrorType` for possible errors
   */
  hide: (options?: SplashScreenHideOptions) => Promise<void>

  /**
   * Animate the splash screen. You must call `hide()` or `animate()` to
   * remove a launch screen, typically after your app is fully mounted.
   *
   * @native
   * @throws {PluginError} See `SplashScreenErrorType` for possible errors
   */
  animate: (options?: SplashScreenAnimateOptions) => Promise<void>

  /**
   * Listen to changes in the app state and execute
   * the relevant code. This is a convenience to allow you to easily
   * show a splash when your app resumes. Be sure to save the result
   * of this call somewhere. When you no longer need to listen to
   * the app state (e.g. when a component unmounts), be sure to call
   * the `remove()` method on the returned `PluginListenerHandle`.
   *
   * NOTE: This cannot be reliably used on Android, as the app may be
   * paused before the listener is called.
   *
   * @since 2.0.0
   */
  listenToAppState: (
    options?: SplashScreenAppStateListeners
  ) => Promise<PluginListenerHandle>
}
