# Super Splash Screen

This [Capacitor](https://capacitorjs.com) plugin provides complete control over native splash screens.

## Features

* On iOS, both images and storyboards are supported.
* On Android, both images and layouts are supported.
* On iOS, seamless, automatic transition from the app’s launch screen to an identical splash screen.
* Support for all native image sizing and placement modes.
* Complete control over timing: delay, fade in, duration, fade out.
* Specify time units in seconds or milliseconds.
* Control over the splash screen background, including alpha.
* Support for dark mode (iOS only).
* Hooks for user animation of a splash screen.

## API

<docgen-index>

**Methods**
[show(...)](#show)
[hide(...)](#hide)
[animate(...)](#animate)


[Interfaces](#interfaces)

</docgen-index>

----
<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### show(...)

```typescript
show(options?: WSSplashScreenShowOptions | undefined) => Promise<void>
```

Show the splash screen.

| Param   | Type                                                               |
| :------ | :----------------------------------------------------------------- |
| options | <a href="#wssplashscreenshowoptions">WSSplashScreenShowOptions</a> |

--------------------


### hide(...)

```typescript
hide(options?: WSSplashScreenHideOptions | undefined) => Promise<void>
```

Hide the splash screen.

| Param   | Type                                                               |
| :------ | :----------------------------------------------------------------- |
| options | <a href="#wssplashscreenhideoptions">WSSplashScreenHideOptions</a> |

--------------------


### animate(...)

```typescript
animate(options?: WSSplashScreenAnimateOptions | undefined) => Promise<void>
```

Animate the splash screen. This is typically called when your app
is mounted. Note this will do nothing unless the animate option is true.

| Param   | Type                                                                     |
| :------ | :----------------------------------------------------------------------- |
| options | <a href="#wssplashscreenanimateoptions">WSSplashScreenAnimateOptions</a> |

--------------------


### Interfaces


#### WSSplashScreenShowOptions

| Prop                    | Type                                                                                                                                                                                                                                              | Description                                                                                                                                                                                                                                                                                                                                                          |
| :---------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| source                  | string                                                                                                                                                                                                                                            | The source of the splash screen. On iOS, it may be an image or storyboard with the given name. On Android, it may be any drawable or layout with the given name. If the name is "\*", on iOS the configured LaunchScreen storyboard in the app's project will be used, on Android the layout "launch_screen.xml" will be used if present. Default: '*'                |
| iosSource               | string                                                                                                                                                                                                                                            | If specified, this overrides source on iOS.                                                                                                                                                                                                                                                                                                                          |
| androidSource           | string                                                                                                                                                                                                                                            | If specified, this overrides source on Android.                                                                                                                                                                                                                                                                                                                      |
| delay                   | number                                                                                                                                                                                                                                            | How long to delay before showing the splash screen. Default: 0                                                                                                                                                                                                                                                                                                       |
| fadeInDuration          | number                                                                                                                                                                                                                                            | How long to fade in. Default: 200 ms NOTE: This does NOT come into play during launch on iOS.                                                                                                                                                                                                                                                                        |
| showDuration            | number                                                                                                                                                                                                                                            | How long to show the splash screen before fading out when autoHide is enabled. Default: 3 seconds                                                                                                                                                                                                                                                                    |
| fadeOutDuration         | number                                                                                                                                                                                                                                            | How long to fade out. Default: 200 ms                                                                                                                                                                                                                                                                                                                                |
| autoHide                | boolean                                                                                                                                                                                                                                           | Whether to auto hide the splash after showDuration. If false, you have to manually call hide() after your app is mounted. Default: false                                                                                                                                                                                                                             |
| animated                | boolean                                                                                                                                                                                                                                           | Whether to let your own native code animate the splash view after it is shown during launch or by calling show(). When this is true, showDuration, fadeOutDuration and autoHide are ignored. Default: false                                                                                                                                                          |
| startAlpha              | number                                                                                                                                                                                                                                            | The starting alpha value of the splash screen, from 0.0 (transparent) to 1.0 (opaque). If your app has a system launch screen which you are using as the splash screen by setting the source option to "*", you will usually want to set this to 1.0 so there is no visible transition from the system launch screen to your (identical) splash screen. Default: 0.0 |
| backgroundColor         | string                                                                                                                                                                                                                                            | The background color to apply to the splash screen view. Default: '' (transparent)                                                                                                                                                                                                                                                                                   |
| showSpinner             | boolean                                                                                                                                                                                                                                           | Whether to show a spinner centered in the splash screen. Default: false                                                                                                                                                                                                                                                                                              |
| spinnerColor            | string                                                                                                                                                                                                                                            | Spinner color. Default: '' (transparent)                                                                                                                                                                                                                                                                                                                             |
| iosSpinnerStyle         | "small" \| "large"                                                                                                                                                                                                                                | The spinner size on iOS.                                                                                                                                                                                                                                                                                                                                             |
| androidSpinnerStyle     | \|&nbsp;"small"<br>\|&nbsp;"large"<br>\|&nbsp;"smallInverse"<br>\|&nbsp;"medium"<br>\|&nbsp;"mediumInverse"<br>\|&nbsp;"largeInverse"<br>\|&nbsp;"horizontal"                                                                                     | The spinner size/style on Android.                                                                                                                                                                                                                                                                                                                                   |
| iosImageDisplayMode     | \|&nbsp;"top"<br>\|&nbsp;"center"<br>\|&nbsp;"bottom"<br>\|&nbsp;"fill"<br>\|&nbsp;"aspectFill"<br>\|&nbsp;"fit"<br>\|&nbsp;"left"<br>\|&nbsp;"right"<br>\|&nbsp;"topLeft"<br>\|&nbsp;"topRight"<br>\|&nbsp;"bottomLeft"<br>\|&nbsp;"bottomRight" | The mode used to place and scale an image splash screen. Ignored for storyboard-based splash screens.                                                                                                                                                                                                                                                                |
| androidImageDisplayMode | \|&nbsp;"center"<br>\|&nbsp;"fill"<br>\|&nbsp;"aspectFill"<br>\|&nbsp;"fit"<br>\|&nbsp;"fitTop"<br>\|&nbsp;"fitBottom"                                                                                                                            | The mode used to place and scale an image splash screen. Ignored for layout-based splash screens.                                                                                                                                                                                                                                                                    |
| androidFullscreen       | boolean                                                                                                                                                                                                                                           | If true, the splash will cover the status bar on Android.                                                                                                                                                                                                                                                                                                            |
| ios                     | <a href="#wssplashscreeniosshowoptions">WSSplashScreenIosShowOptions</a>                                                                                                                                                                          | iOS options may be placed in a subobject.                                                                                                                                                                                                                                                                                                                            |
| android                 | <a href="#wssplashscreenandroidshowoptions">WSSplashScreenAndroidShowOptions</a>                                                                                                                                                                  | Android options may be placed in a subobject.                                                                                                                                                                                                                                                                                                                        |

<br>

#### WSSplashScreenIosShowOptions

| Prop             | Type                                                                                                                                                                                                                                              | Description                                                                                |
| :--------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------- |
| source           | string                                                                                                                                                                                                                                            | See <a href="#wssplashscreenshowoptions">WSSplashScreenShowOptions.iosSource</a>           |
| spinnerStyle     | "small" \| "large"                                                                                                                                                                                                                                | See <a href="#wssplashscreenshowoptions">WSSplashScreenShowOptions.iosSpinnerStyle</a>     |
| imageDisplayMode | \|&nbsp;"top"<br>\|&nbsp;"center"<br>\|&nbsp;"bottom"<br>\|&nbsp;"fill"<br>\|&nbsp;"aspectFill"<br>\|&nbsp;"fit"<br>\|&nbsp;"left"<br>\|&nbsp;"right"<br>\|&nbsp;"topLeft"<br>\|&nbsp;"topRight"<br>\|&nbsp;"bottomLeft"<br>\|&nbsp;"bottomRight" | See <a href="#wssplashscreenshowoptions">WSSplashScreenShowOptions.iosImageDisplayMode</a> |

<br>

#### WSSplashScreenAndroidShowOptions

| Prop             | Type                                                                                                                                                          | Description                                                                                    |
| :--------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ | :--------------------------------------------------------------------------------------------- |
| source           | string                                                                                                                                                        | See <a href="#wssplashscreenshowoptions">WSSplashScreenShowOptions.androidSource</a>           |
| spinnerStyle     | \|&nbsp;"small"<br>\|&nbsp;"large"<br>\|&nbsp;"smallInverse"<br>\|&nbsp;"medium"<br>\|&nbsp;"mediumInverse"<br>\|&nbsp;"largeInverse"<br>\|&nbsp;"horizontal" | See <a href="#wssplashscreenshowoptions">WSSplashScreenShowOptions.androidSpinnerStyle</a>     |
| imageDisplayMode | \|&nbsp;"center"<br>\|&nbsp;"fill"<br>\|&nbsp;"aspectFill"<br>\|&nbsp;"fit"<br>\|&nbsp;"fitTop"<br>\|&nbsp;"fitBottom"                                        | See <a href="#wssplashscreenshowoptions">WSSplashScreenShowOptions.androidImageDisplayMode</a> |
| fullscreen       | boolean                                                                                                                                                       | See <a href="#wssplashscreenshowoptions">WSSplashScreenShowOptions.androidFullscreen</a>       |

<br>

#### WSSplashScreenHideOptions

| Prop            | Type   | Description                                  |
| :-------------- | :----- | :------------------------------------------- |
| delay           | number | How long to delay before hiding. Default: 0. |
| fadeOutDuration | number | How long to fade out. Default: 200 ms.       |

<br>

#### WSSplashScreenAnimateOptions

| Prop  | Type   | Description                                                  |
| :---- | :----- | :----------------------------------------------------------- |
| delay | number | How long to delay before starting the animation. Default: 0. |

</docgen-api>
