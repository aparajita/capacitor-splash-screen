import { PluginResultError } from '@capacitor/core';

declare module '@capacitor/core' {
  interface PluginRegistry {
    WSSplashScreen: WSSplashScreenPlugin;
  }
}

/**
 * The mode used to place and scale an image splash screen.
 * Ignored for storyboard-based splash screens. Valid values are:
 *
 * fill - Scale the image to fill, not keeping the aspect ratio.
 *
 * aspectFill - Scale the image to fill, keeping the aspect ratio. Portions
 *   of the image may be offscreen as a result.
 *
 * fit - Scale and center the image, keeping the aspect ratio, such that
 *   it fills either the width or height of the containing view.
 *
 * center/top/bottom/left/right/topLeft/topRight/bottomLeft/bottomRight -
 *   Place the image in the given location without scaling.
 */
export type WSSplashScreenIosImageDisplayMode =
  | 'fill'
  | 'aspectFill'
  | 'fit'
  | 'center'
  | 'top'
  | 'bottom'
  | 'left'
  | 'right'
  | 'topLeft'
  | 'topRight'
  | 'bottomLeft'
  | 'bottomRight';

/**
 * Possible Android spinner styles. For more information,
 * see https://developer.android.com/reference/android/R.attr.html#progressBarStyle
 */
export type WSSplashScreenAndroidSpinnerStyle =
  | 'small'
  | 'smallInverse'
  | 'medium'
  | 'mediumInverse'
  | 'large'
  | 'largeInverse'
  | 'horizontal';

/**
 * The mode used to place and scale an image splash screen.
 * Ignored for layout-based splash screens. Valid values are:
 *
 * fill - Scale the image to fill, not keeping the aspect ratio.
 *
 * aspectFill - Scale the image to fill, keeping the aspect ratio.
 *   Portions of the image may be offscreen as a result.
 *
 * fit - Scale and center the image, keeping the aspect ratio, such that
 *   it fills either the width or height of the containing view.
 *
 * fitTop/fitBottom - Same as fit, but place the image
 *   at the top or bottom of the screen.
 */
export type WSSplashScreenAndroidImageDisplayMode =
  | 'fill'
  | 'aspectFill'
  | 'fit'
  | 'fitTop'
  | 'fitBottom'
  | 'center';

/**
 * Possible iOS spinner styles.
 */
export type WSSplashScreenIosSpinnerStyle = 'small' | 'large';

/**
 * Colors may be one of the following named colors or a hex color.
 * Hex colors are in CSS format: RGB, RRGGBB, or RRGGBBAA (case-insensitive)
 * with or without a leading '#'. An empty string is transparent.
 *
 * iOS:
 * 'systemBackground' is the standard system background, which adapts to dark mode
 * (i.e. white in light mode, black in dark mode).
 *
 * 'systemText' is the standard system text color, which adapts to dark mode.
 *
 * Dark mode support began with iOS 13. On prior versions, 'systemBackground'
 * is white and 'systemText' is black.
 *
 * Android:
 * Currently, 'systemBackground' == white, 'systemText' == black
 */
export type WSSplashScreenColor = 'systemBackground' | 'systemText' | string;

/**
 * In options objects, when you specify a duration, it can either
 * be in seconds or milliseconds. Any value >= 10 will be considered
 * milliseconds, any value < 10 will be considered seconds.
 */
export type WSSplashScreenDuration = number;

export interface WSSplashScreenIosShowOptions {
  /**
   * See WSSplashScreenOptions.iosSource
   */
  source?: string;

  /**
   * See WSSplashScreenShowOptions.iosSpinnerStyle
   */
  spinnerStyle?: WSSplashScreenIosSpinnerStyle;

  /**
   * See WSSplashScreenShowOptions.iosImageDisplayMode
   */
  imageDisplayMode?: WSSplashScreenIosImageDisplayMode;
}

export interface WSSplashScreenAndroidShowOptions {
  /**
   * See WSSplashScreenOptions.androidSource
   */
  source?: string;

  /**
   * See WSSplashScreenShowOptions.androidSpinnerStyle
   */
  spinnerStyle?: WSSplashScreenAndroidSpinnerStyle;

  /**
   * See WSSplashScreenShowOptions.androidImageDisplayMode
   */
  imageDisplayMode?: WSSplashScreenAndroidImageDisplayMode;

  /**
   * See WSSplashScreenShowOptions.androidFullscreen
   */
  fullscreen?: boolean;
}

export interface WSSplashScreenShowOptions {
  /**
   * The source of the splash screen. On iOS, it may be an image or
   * storyboard with the given name. On Android, it may be any drawable
   * or layout with the given name. If the name is "*", on iOS the configured
   * LaunchScreen storyboard in the app's project will be used,
   * on Android the layout "launch_screen.xml" will be used if present.
   * Default: '*'
   */
  source?: string;

  /**
   * If specified, this overrides source on iOS.
   */
  iosSource?: string;

  /**
   * If specified, this overrides source on Android.
   */
  androidSource?: string;

  /**
   * How long to delay before showing the splash screen.
   * Default: 0
   */
  delay?: WSSplashScreenDuration;

  /**
   * How long to fade in. Default: 200 ms
   *
   * NOTE: This does NOT come into play during launch on iOS.
   */
  fadeInDuration?: WSSplashScreenDuration;

  /**
   * How long to show the splash screen before fading out
   * when autoHide is enabled. Default: 3 seconds
   */
  showDuration?: WSSplashScreenDuration;

  /**
   * How long to fade out. Default: 200 ms
   */
  fadeOutDuration?: WSSplashScreenDuration;

  /**
   * Whether to auto hide the splash after showDuration. If false,
   * you have to manually call hide() after your app is mounted.
   * Default: false
   */
  autoHide?: boolean;

  /**
   * Whether to let your own native code animate the splash view after
   * it is shown during launch or by calling show(). When this is true,
   * showDuration, fadeOutDuration and autoHide are ignored. Default: false
   */
  animated?: boolean;

  /**
   * The starting alpha value of the splash screen, from 0.0 (transparent)
   * to 1.0 (opaque). If your app has a system launch screen which you are
   * using as the splash screen by setting the source option to "*",
   * you will usually want to set this to 1.0 so there is no visible
   * transition from the system launch screen to your (identical) splash screen.
   * Default: 0.0
   */
  startAlpha?: number;

  /**
   * The background color to apply to the splash screen view.
   * Default: '' (transparent)
   */
  backgroundColor?: WSSplashScreenColor;

  /**
   * Whether to show a spinner centered in the splash screen. Default: false
   */
  showSpinner?: boolean;

  /**
   * Spinner color. Default: '' (transparent)
   */
  spinnerColor?: WSSplashScreenColor;

  /**
   * The spinner size on iOS.
   */
  iosSpinnerStyle?: WSSplashScreenIosSpinnerStyle;

  /**
   * The spinner size/style on Android.
   */
  androidSpinnerStyle?: WSSplashScreenAndroidSpinnerStyle;

  /**
   * The mode used to place and scale an image splash screen.
   * Ignored for storyboard-based splash screens. Valid values are:
   */
  iosImageDisplayMode?: WSSplashScreenIosImageDisplayMode;

  /**
   * The mode used to place and scale an image splash screen.
   * Ignored for layout-based splash screens.
   */
  androidImageDisplayMode?: WSSplashScreenAndroidImageDisplayMode;

  /**
   * If true, the splash will cover the status bar on Android.
   */
  androidFullscreen?: boolean;

  /**
   * iOS options may be placed in a subobject.
   */
  ios?: WSSplashScreenIosShowOptions;

  /**
   * Android options may be placed in a subobject.
   */
  android?: WSSplashScreenAndroidShowOptions;
}

export interface WSSplashScreenHideOptions {
  /**
   * How long to delay before hiding. Default: 0.
   */
  delay?: WSSplashScreenDuration;

  /**
   * How long to fade out. Default: 200 ms.
   */
  fadeOutDuration?: WSSplashScreenDuration;
}

export interface WSSplashScreenAnimateOptions {
  /**
   * How to delay before starting the animation. Default: 0.
   */
  delay?: WSSplashScreenDuration;

  /**
   * Arbitrary options may be passed to your animation code
   */
  [key: string]: any;
}

export interface WSSplashScreenAppStateOptions {
  /**
   * The code to call on app suspend
   */
  onSuspend?: () => void;

  /**
   * The code to call on opp resume
   */
  onResume?: () => void;
}

/**
 * If a plugin call is rejected, the error will contain a string .code property
 * whose value will be one of these.
 */
export enum WSSplashScreenErrorType {
  /**
   * show() was called and no splash resource could be found
   */
  notFound = 'notFound',

  /**
   * hide() or animate() was called when show() rejected with 'notFound'.
   */
  noSplashScreen = 'noSplashScreen',

  /**
   * animate() was called but no animation method could be found in the app.
   */
  animateMethodNotFound = 'animateMethodNotFound',
}

/**
 * If an error occurs, the returned Error object has a .code property
 * which is the string name of a StorageErrorType.
 */
export interface PluginError extends PluginResultError {
  code: string;
}

export interface WSSplashScreenPlugin {
  /**
   * Show the splash screen.
   *
   * @throws {PluginError} See WSSplashScreenErrorType for possible errors
   */
  show(options?: WSSplashScreenShowOptions): Promise<void>;

  /**
   * Hide the splash screen.
   *
   * @throws {PluginError} See WSSplashScreenErrorType for possible errors
   */
  hide(options?: WSSplashScreenHideOptions): Promise<void>;

  /**
   * Animate the splash screen. This is typically called when your app
   * is mounted. Note this will do nothing unless the animate option is true.
   *
   * @throws {PluginError} See WSSplashScreenErrorType for possible errors
   */
  animate(options?: WSSplashScreenAnimateOptions): Promise<void>;
}

/**
 * Listen to changes in the app state and execute the relevant code.
 * This is a convenience to allow you to easily show a splash when
 * your app resumes.
 *
 * @param {boolean} listen
 * @param {WSSplashScreenAppStateOptions} options
 */
declare function listenToAppState(
  listen: true,
  options: WSSplashScreenAppStateOptions,
): void;

/**
 * Turn off listening to app state changes.
 *
 * @param {boolean} listen
 */
declare function listenToAppState(listen: false): void;
