declare module '@capacitor/core' {
  interface PluginRegistry {
    WSSplashScreen: WSSplashScreenPlugin
  }
}

export interface WSSplashScreenShowOptions {
  /**
   * How long to show the splash screen when autoHide is enabled (in ms)
   * Default is 3000ms.
   */
  showDuration?: number

  /**
   * How long (in ms) to fade in. Default is 200ms.
   */
  fadeInDuration?: number

  /**
   * How long (in ms) to fade out. Default is 200ms.
   */
  fadeOutDuration?: number

  /**
   * Whether to auto hide the splash after showDuration. Default is false,
   * which means you have to manually call hide() after your app is mounted.
   */
  autoHide?: boolean
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
