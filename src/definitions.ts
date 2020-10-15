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
   * How long to show the splash screen when autoHide is enabled (in ms)
   * Default is 3000 ms.
   */
  'showDuration'?: number

  /**
   * How long (in ms) to fade in. Default is 200 ms.
   */
  'fadeInDuration'?: number

  /**
   * How long (in ms) to fade out. Default is 200 ms.
   */
  'fadeOutDuration'?: number

  /**
   * Whether to auto hide the splash after showDuration. Default is false,
   * which means you have to manually call hide() after your app is mounted.
   */
  'autoHide'?: boolean

  /**
   * The background color to apply to the splash screen view.
   * It may be in RGB (6 case-insensitive hex digits) or RGBA
   * (8 case-insensitive hex digits) format, with or without
   * a leading '#'.
   */
  'backgroundColor'?: string

  /**
   * Whether to show a spinner centered in the splash screen.
   */
  'showSpinner'?: boolean

  /**
   * On iOS, the spinner size. Anything other than "small" is large.
   */
  'ios.spinnerStyle'?: boolean

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
  'ios.imageContentMode'?: WSSplashScreenImageContentMode
}

export interface WSSplashScreenHideOptions {
  /**
   * How long (in ms) to fade out. Default is 200ms.
   */
  fadeOutDuration?: number
}

export interface WSSplashScreenIosOptions {
  /**
   * The size of the spinner.
   */
  spinnerSize?: 'small' | 'large'

  /**
   * Whether the iOS launch screen storyboard should be used as
   * the splash screen. Default is false.
   */
  useLaunchScreen?: boolean

  /**
   * The name of a custom storyboard to use as the splash screen.
   * This is only used if iosUseLaunchScreen is true. If this is specified,
   * the named storyboard must exist or the app will crash.
   */
  storyboard?: string

  /**
   * The name of an image resource to use as the splash screen. This will
   * only be used if iosUseLaunchScreen is false and iosStoryboard is empty.
   */
  image?: string
}

/**
 * Global options defined in capacitor.config.json.plugins.WSSplashScreen
 */
export interface WSSplashScreenOptions {
  /**
   * The background color of the splash screen. Should be either 6 or 8
   * hex digits with an optional leading "#". If 6 digits, it's RGB.
   * If 8 digits, it's RGBA.
   */
  backgroundColor?: string

  /**
   * Whether to show a spinner centered in the splash screen. Default is false.
   */
  showSpinner?: boolean

  /**
   * The color of the spinner. Should be either 6 or 8
   * hex digits with an optional leading "#". If 6 digits, it's RGB.
   * If 8 digits, it's RGBA.
   */
  spinnerColor?: string

  ios?: WSSplashScreenIosOptions
}

export interface WSSplashScreenPlugin {
  /**
   * Show the splash screen
   */
  show(options?: WSSplashScreenShowOptions, callback?: Function): Promise<void>

  /**
   * Hide the splash screen
   */
  hide(options?: WSSplashScreenHideOptions, callback?: Function): Promise<void>
}
