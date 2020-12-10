# Splash Screen

This [Capacitor](https://capacitorjs.com) plugin provides complete control over native splash screens, both automatically at launch and via code.

## Features

* On iOS, both images and storyboards are supported.
* On Android, both images and layouts are supported.
* Seamless, automatic transition from an iOS app’s launch screen to an identical splash screen.
* Support for all native image sizing and placement modes.
* Complete control over timing: delay, fade in, duration, fade out.
* Specify time units in seconds or milliseconds.
* Control over the splash screen background, including alpha.
* Support for dark mode (iOS only).
* Hooks for user animation of a splash screen.

A demo which shows all of the features can be found [here](https://github.com/aparajita/ws-capacitor-splashscreen-demo).

## Installation

This will eventually be moved to the @capacitor org, until then you need to install from the repo.

```shell
git clone https://github.com/aparajita/ws-capacitor-splashscreen.git
cd ws-capacitor-splashscreen
pnpm install  # npm install, yarn
pnpm build    # npm run build, yarn build
```

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

## Custom animation

Splash Screen supports custom animation on both iOS and Android. The demo app contains custom animation on both platforms, which you can use as a template for your animation.

In general, to animate a splash screen, you need to do the following:

* Make sure that the `animated` option is true, either in the plugin config or in the options passed to the `show()` plugin method.
* Call the `show()` plugin method (unless it’s at launch, when that is done for you), and when that returns; 
* Call the `animate()` plugin method. You may pass arbitrary values to your animation code through the `animate()` options.

### Events

There are three animation events sent to your animation method. Of the three, you are only required to respond to the `animate` event.

* **beforeShow** — This event is sent after the splash screen and spinner views have been built, but just before they are faded in. If you need to create or modify views, this is the place to do it.
* **animate** — This event is sent when the `animate()` method is called, after any delay specified in the method options.
* **afterShow** — This event is sent after the animation is finished and the splash screen and spinner have been removed from their superview. If you created your own views, this is the place to remove them.

### Event handler

In order to receive animation events (and thus perform animation), you need to create an animation handler method in your app’s native code. On iOS, the event handler will look like this:

```swift
import Capacitor

enum EventType: String {
  case animate
  case beforeShow
  case afterShow
}

extension AppDelegate {
  @objc func onSplashScreenEvent(_ event: String, _ params: Any) {
    guard let params = params as? [String: Any],
          let eventType = EventType(rawValue: event) else {
      return
    }

    switch eventType {
    case .animate:
      animate(withParams: params)

    case .beforeShow:
      handleBeforeShow(params: params)

    case .afterShow:
      handleAfterShow(params: params)
    }
  }
}
```

On Android, the event handler will look like this:

```java
import java.util.HashMap;

public class SplashScreen {
    public void onSplashScreenEvent(String event, HashMap<String, Object> params) {
        switch (event) {
            case "beforeShow":
                onBeforeShow(params);
                break;

            case "afterShow":
                onAfterShow(params);
                break;

            case "animate":
                animate(params);
                break;
        }
    }
}
```

👉**IMPORTANT**❗️
The method names and signatures must be **exactly** as displayed above.

### Event parameters

Each event receives parameters from the plugin with context that you may need in performing your animation. All of the events receive the first four of the following parameters. The `done` parameter is only passod to the `animate` event.

| Param | Type (iOS / Android) | Description |
| :---- | :--- | :---------- |
| plugin | CAPPlugin<br>com.getcapacitor.Plugin | The SplashScreenPlugin instance which called the event handler |
| splashView | UIView<br>android.view.View | The view to be animated |
| spinnerView | UIActivityIndicatorView<br>android.widget.ProgressBar | If the `showSpinner` option is `true`, the spinner view |
| options | [AnyHashable: Any]?<br>com.getcapacitor.JSObject | Any options passed to the `animate()` plugin method |
| done | () -> Void<br>Runnable | A function you **must** call when the animation is completely finished |

As noted above, you **must** call the `done` callback when the animation is completely done, otherwise control will not be returned to the JavaScript runtime. In most cases you will do this in the animation completion function.
