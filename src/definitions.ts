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

export type WSSplashScreenIosSpinnerStyle = 'small' | 'large';

export type WSSplashScreenAndroidSpinnerStyle =
  | 'small'
  | 'large'
  | 'horizontal'
  | 'smallInverse'
  | 'inverse'
  | 'largeInverse';

/**
 * In options objects, when you specify a duration, it can either
 * be in seconds or milliseconds. Any value >= 20 will be considered
 * milliseconds, any value < 20 will be considered seconds.
 */
export type WSSplashScreenDuration = number;

export interface WSSplashScreenIosShowOptions {
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
   * or layout with the given name. On iOS, the default is "Splash",
   * on Android "splash". If the name is "*", on iOS the configured
   * LaunchScreen storyboard in the app's project will be used,
   * on Android the layout "launch_screen.xml" will be used if present.
   */
  source?: string;

  /**
   * How long to delay before showing the splash screen.
   * Default is 0.
   */
  delay?: WSSplashScreenDuration;

  /**
   * How long to fade in. Default is 200 ms.
   *
   * NOTE: This does NOT come into play during launch on iOS.
   */
  fadeInDuration?: WSSplashScreenDuration;

  /**
   * How long to show the splash screen before fading out
   * when autoHide is enabled. Default is 3 seconds.
   */
  showDuration?: WSSplashScreenDuration;

  /**
   * How long to fade out. Default is 200 ms.
   */
  fadeOutDuration?: WSSplashScreenDuration;

  /**
   * Whether to auto hide the splash after showDuration. Default is false.
   * If false, you have to manually call hide() after your app is mounted.
   */
  autoHide?: boolean;

  /**
   * Whether to let your own native code animate the splash view after
   * it is shown during launch or by calling show(). When this is true,
   * showDuration, fadeOutDuration and autoHide are ignored. Default is false.
   */
  animated?: boolean;

  /**
   * The background color to apply to the splash screen view.
   * It may be in RGB (6 case-insensitive hex digits) or RGBA
   * (8 case-insensitive hex digits) format, with or without
   * a leading '#'.
   */
  backgroundColor?: string;

  /**
   * Whether to show a spinner centered in the splash screen. Default is false.
   */
  showSpinner?: boolean;

  /**
   * Spinner color. Color format is same as for backgroundColor.
   */
  spinnerColor?: string;

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
   * How long to delay before hiding. Default is 0.
   */
  delay?: WSSplashScreenDuration;

  /**
   * How long to fade out. Default is 200 ms.
   */
  fadeOutDuration?: WSSplashScreenDuration;
}

export interface WSSplashScreenAnimateOptions {
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
 * If a plugin call is rejected, the error code will be one of these.
 */
export enum WSSplashScreenErrorType {
  noSplashScreen = 'noSplashScreen',
  animateMethodNotFound = 'animateMethodNotFound',
}

export interface WSSplashScreenPlugin {
  /**
   * Show the splash screen
   */
  show(options?: WSSplashScreenShowOptions): Promise<void>;

  /**
   * Hide the splash screen
   */
  hide(options?: WSSplashScreenHideOptions): Promise<void>;

  /**
   * Animate the splash screen. This is typically called when your app
   * is mounted. Note this will do nothing unless the animate option is true.
   *
   * @throws {Error} If animateSplashScreen() is not defined in your native
   *   application code.
   */
  animate(): Promise<void>;
}
