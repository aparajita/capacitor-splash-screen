declare module '@capacitor/core' {
  interface PluginRegistry {
    WSSplashScreen: WSSplashScreenPlugin
  }
}

export type WSSplashScreenImageContentMode =
  | 'fill'
  | 'aspectFill'
  | 'aspectFit'
  | 'center'
  | 'top'
  | 'bottom'
  | 'left'
  | 'right'
  | 'topLeft'
  | 'topRight'
  | 'bottomLeft'
  | 'bottomRight'

export interface WSSplashScreenShowOptions {
  /**
   * How long to show the splash screen (in ms) when autoHide is enabled.
   * Default is 3000 ms.
   */
  showDuration?: number

  /**
   * How long (in ms) to fade in. Default is 200 ms.
   *
   * NOTE: This does NOT come into play on iOS during launch.
   */
  fadeInDuration?: number

  /**
   * How long (in ms) to fade out. Default is 200 ms.
   */
  fadeOutDuration?: number

  /**
   * Whether to auto hide the splash after showDuration. Default is true.
   * If false, you have to manually call hide() after your app is mounted.
   */
  autoHide?: boolean

  /**
   * Whether to let your own native code animate the splash view after
   * it is shown during launch or by calling show(). When this is true,
   * showDuration, fadeOutDuration and autoHide are ignored.
   */
  animate?: boolean

  /**
   * The background color to apply to the splash screen view.
   * It may be in RGB (6 case-insensitive hex digits) or RGBA
   * (8 case-insensitive hex digits) format, with or without
   * a leading '#'.
   */
  backgroundColor?: string

  /**
   * Whether to show a spinner centered in the splash screen.
   */
  showSpinner?: boolean

  /**
   * Spinner color. Color format is same as for backgroundColor.
   */
  spinnerColor?: string

  /**
   * On iOS, the spinner size.
   */
  iosSpinnerStyle?: 'small' | 'large'

  /**
   * On iOS, the mode used to place and scale an image splash screen.
   * Ignored for storyboard-based splash screens. Valid values are:
   *
   * fill - Scale the image to fill, not keeping the aspect ratio.
   *
   * aspectFill - Scale the image to fill, keeping the aspect ratio. Portions
   *   of the image may be offscreen as a result.
   *
   * aspectFit - Scale the image, keeping the aspect ratio, such that it
   *   fills either the width or height of the containing view.
   *
   * center/top/bottom/left/right/topLeft/topRight/bottomLeft/bottomRight -
   *   Place the image in the given location without scaling.
   */
  iosImageContentMode?: WSSplashScreenImageContentMode
}

export interface WSSplashScreenHideOptions {
  /**
   * How long (in ms) to delay before hiding. Default is 0.
   */
  delay?: number

  /**
   * How long (in ms) to fade out. Default is 200ms.
   */
  fadeOutDuration?: number
}

export enum WSSplashScreenErrorType {
  noSplashScreen,
  animateMethodNotFound
}

export interface WSSplashScreenPlugin {
  /**
   * Show the splash screen
   */
  show(options?: WSSplashScreenShowOptions): Promise<void>

  /**
   * Hide the splash screen
   */
  hide(options?: WSSplashScreenHideOptions): Promise<void>

  /**
   * Animate the splash screen. This is typically called when your app
   * is mounted. Note this will do nothing unless the animate option is true.
   *
   * @throws {Error} If animateSplashScreen() is not defined in your native
   *   application code.
   */
  animate(): Promise<void>
}
