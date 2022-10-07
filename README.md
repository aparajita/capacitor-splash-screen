<div class="markdown-body">

# capacitor-splash-screen&nbsp;&nbsp;[![npm version](https://badge.fury.io/js/@aparajita%2Fcapacitor-splash-screen.svg)](https://badge.fury.io/js/@aparajita%2Fcapacitor-splash-screen)

This [Capacitor 4](https://capacitorjs.com) plugin is a replacement for the official [Splash Screen plugin](https://capacitorjs.com/docs/apis/splash-screen) and provides complete control over native splash screens, both automatically at launch and via code.

👉 **NOTE:** This plugin does not work with Capacitor < 4.

[About](#about)<br>[Features](#features)<br>
[Installation](#installation)<br>
[Launch screen configuration](#launch-screen-configuration)<br>[Usage](#usage)<br>
[Custom animation](#custom-animation)<br>[API](#api)

## About

iOS and Android already provide launch screens, so why do we need this plugin?

System launch screens by default are removed as soon as the first frame is drawn by the application being launched. In the case of an Capacitor app, that occurs when the layout with the web view is drawn. But there is a finite (and often noticeable) delay between the time when the web view is drawn and the time when the app is fully mounted and drawn within the web view.

To prevent the user from seeing a flash of a blank screen after the system launch screen disappears, this plugin allows you to extend the time the system launch screen is displayed until after the app is fully mounted and drawn. In addition, you can modify the fade out duration or alternatively you can provide your own custom code to animate the launch screen using the hooks provided by this plugin.

### Changes from v1.x

Whereas v1.x of this plugin supported multiple formats, this version only supports the formats supported by system launch screens. On iOS, that means storyboards; on Android that means vector drawables (or animated vector drawables on Android 12+). The reason for this is to provide an absolutely seamless transition from the system splash screen to your application.

Starting with Android 12, Android provides a backward-compatible API for configuring and presenting splash screens, and it **always** shows its own splash screen if you do not customize it. Such being the case, the best approach is to work with the splash screen API to customize the splash screen.

## Features

- Silky smooth, seamless transitions from the system splash screen to your app.
- Full set of hooks for implementing custom animation. 🚀
- Full support for localization. 🇺🇸🇧🇷
- Full support for dark mode. 🌗
- Full support for Android 12+ splash screens.
- Splash screen [workshop app](https://github.com/aparajita/capacitor-splash-screen-demo) lets you test splash screens and tweak timing parameters. 👀
- Complete control over timing when testing splash screens: delay, fade in, duration, fade out. ⏱
- Specify time units in seconds or milliseconds. ⌛

## Installation

```shell
pnpm add @aparajita/capacitor-splash-screen @aparajita/capacitor-logger  # npm install, yarn add
```

## Launch screen configuration

There are two types of splash screens: launch and programmatic. Configuration and usage differs depending on the type of splash screen and on the platform. When referring to Capacitor configuration, this document will assume you are using `capacitor.config.ts`.

There is a fair bit of config you have to get right to support all possible splash screen features (such as dark mode and localization) on both platforms. I have done my best to document it all below, but if you get confused, refer to the [workshop app](https://github.com/aparajita/capacitor-splash-screen-demo), which implements all of these features.

### iOS

- Create a launch screen storyboard and set it as the launch screen as you normally would.

- In your app’s `AppDelegate.swift`, add a call to `SplashScreen.initLaunchTime()`:

```swift
import AparajitaCapacitorSplashScreen

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // ==> Add this line
    SplashScreen.initLaunchTime()
    return true
  }
```

### Android

For a launch splash screen in Android, do the following:

- In Android Studio, create or import a vector drawable to be the splash screen.
- Edit your app’s `res/values/styles.xml` file to use this template:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools">
    <!-- Base application theme -->
    <style name="AppTheme" parent="Theme.AppCompat.DayNight.DarkActionBar">
        <!-- Customize your theme here. -->
        <item name="colorPrimary">@color/colorPrimary</item>
        <item name="colorPrimaryDark">@color/colorPrimaryDark</item>
        <item name="colorAccent">@color/colorAccent</item>
    </style>

    <!-- This style MUST appear with this name -->
    <style name="AppTheme.NoActionBar" parent="Theme.AppCompat.DayNight.NoActionBar">
        <!-- This is the standard Ionic config -->
        <item name="windowActionBar">false</item>
        <item name="windowNoTitle">true</item>
        <item name="android:background">@null</item>

        <!-- OPTIONAL: Set the status and/or navigation bar color -->
        <item name="android:statusBarColor">@android:color/holo_blue_dark</item>
        <item name="android:navigationBarColor">@android:color/holo_green_dark</item>
    </style>

    <!-- This style MUST appear with this name -->
  	<style name="AppTheme.NoActionBarLaunch" parent="Theme.SplashScreen">
        // Set this to the single background color of the splash screen.
        // If you want to change the background color in dark mode, create
        // a night version of the color.
        <item name="windowSplashScreenBackground">@color/systemBackground</item>

        // Set this to a VectorDrawable. On API 31+ it may animated,
        // in which case it will be animated during launch.
        // See https://developer.android.com/guide/topics/ui/splash-screen
        // for info on size limits.
        <item name="windowSplashScreenAnimatedIcon">@drawable/launchscreen</item>

        // Set this if the parent="Theme.SplashScreen.IconBackground".
        <item name="android:windowSplashScreenIconBackgroundColor" tools:targetApi="31">@null</item>

        // If you want a branding image to appear at the bottom, set it here.
        <item name="android:windowSplashScreenBrandingImage" tools:targetApi="31">@null</item>

        // Set the main app theme here (required).
        <item name="postSplashScreenTheme">@style/AppTheme.NoActionBar</item>
    </style>
</resources>
```

- Change `windowSplashScreenAnimatedIcon` to match the name of your splash screen drawable.
- Change the other parameters according to your preferences.
- In your app’s `AndroidManifest.xml`, set the `android:theme` attribute of the application activity to `"@style/AppTheme.NoActionBarLaunch"`.
- In your app’s `MainActivity.java`, add a call to `SplashScreen.initLaunchTime()`:

```java
import com.aparajita.capacitor.splashscreen.SplashScreen;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {

  @Override
  public void onCreate(Bundle savedInstanceState) {
    SplashScreen.initLaunchTime();
    super.onCreate(savedInstanceState);
  }
}

```

### All platforms

Because there is an indeterminate amount of time between when the system launch screen appears and your app is loaded and starts running, it is impossible to predict exactly how long a splash screen should remain visible in order to provide a smooth transition to your app’s UI. At the same time, you want to avoid showing the splash screen for too long, because the user may think the app has frozen.

This plugin addresses this problem in two ways:

- In the native code of your app, you **must** call [`initLaunchTime`](#initlaunchtime) as soon as the app is fully loaded, as shown above. This is potentially several hundred milliseconds before this plugin is loaded, which is a significant amount of time from a user perspective.

- You may set a `showDuration` configuration option that specifies the **minimum** amount of time the launch screen should remain visible. When you call [`hide`](#hide) or [`animate`](#animate), the plugin will wait until the minimum duration has elapsed before hiding or animating the splash screen. This ensures that if the app is loaded quickly, the splash screen won’t just flash and disappear (unless that is what you want!).

```typescript
const config: CapacitorConfig = {
  plugins: {
    SplashScreen: {
      showDuration: 1 // 1 second
    }
  }
}
```

#### Logger configuration

This plugin uses a custom logger. You can set the logger level and whether or not to log to the system console on iOS. See the `level` and `useSyslog` options in the configuration section of [`@aparajita/capacitor-logger`](https://github.com/aparajita/capacitor-logger/blob/d605d0f7de5f850967caab0b71a3305ed1c3dc8f/README.md#configuration).

```typescript
const config: CapacitorConfig = {
  plugins: {
    SplashScreen: {
      logger: {
        level: 'debug',
        useSyslog: true
      }
    }
  }
}
```

## Localization

This plugin supports localization of the launch screen using standard system localization mechanisms. For an example of localized launch screens on iOS and Android, see the [workshop app](https://github.com/aparajita/capacitor-splash-screen-demo).

### iOS

On iOS, Apple recommends against including text in your launch storyboard, since launch screens are cached by the system. You can, however, configure your app to use separate storyboards for different languages:

- Create a new storyboard for each language you want to support.
- Create a text file called `InfoPlist.strings` (capitalization is important) in the root of your app’s source code directory. This file should contain a single line:

```text
// Set the name to the name of the base language launch storyboard.
"UILaunchStoryboardName" = "LaunchScreen.storyboard";
```

- Add the file to your Xcode project, making sure to assign it to the app target.
- Select the file in the navigator.
- Open the Inspector panel and click the `Localize…` button.
- Select the language this file is for and click `Localize`.
- Select the project in the navigator, then the project in the main editor, and click the `Info` tab.
- Add whatever languages you want to support to the `Localizations` list. For each language, check `InfoPlist.strings` in the dialog that appears.
- In the `InfoPlist.strings` file created for each language, change the value of `UILaunchStoryboardName` to the name of the storyboard for that language.

### Android

On Android, you can use the standard Android localization mechanisms to provide different launch screens for different languages. See the [Android documentation](https://developer.android.com/guide/topics/resources/localization) for more information.

## Usage

How you show and hide splash screens differs depending on how they are used.

### Launch screens

You do not have to do anything to show launch screens, they are displayed automatically when the app is launched.

Once your app is fully mounted, call [`hide`](#hide) to fade out the launch screen, or [`animate`](#animate) to animate the launch screen. If you use `animate`, your custom animation code is responsible for hiding the splash screen.

Both `hide` and `animate` take a `delay` option. `delay` **may** be necessary because:

1. Capacitor creates the web view.
1. The web view loads your app.
1. Your app is mounted in the DOM, but has not yet been rendered.
1. You call `hide()` or `animate()`.
1. The web view renders the content generated by your app.

When you call `hide()` or `animate()`, the web view may not have been fully rendered. If you hide too quickly, there will be a flash of the web view’s background color just before it renders. That’s why a small delay may be necessary.

### Programmatic splash screens

This plugin also allows you to show splash screens programmatically. This is useful if you want to show a splash screen [on app suspend/resume](#showing-a-splash-screen-on-app-suspendresume) or to test and tweak the timing of a launch screen.

To show a programmatic splash screen, call [`show`](#show), passing [`SplashScreenShowOptions`](#splashscreenshowoptions) to configure the splash screen.

If you want to hide or animate the splash screen after some amount of time, you need to call [`hide`](#hide) or [`animate`](#animate) manually within `setTimeout`. For example:

```typescript
await SplashScreen.show(showOptions)

setTimeout(() => {
  SplashScreen.hide(hideOptions).catch(showErrorAlert)
}, duration)
```

### Showing a splash screen on app suspend/resume

You may wish to show a splash screen every time the app suspends for security purposes, or you may wish to show a splash screen on resume for branding purposes. This plugin provides a convenience function to make that easy to do.

👉 **NOTE:** Although this technique _technically_ works on Android, I advise against it, as the suspend callback is not reliably called before the app becomes inactive on different Android versions, and you will not get the intended effect.

```typescript
// Vue code
import { Capacitor } from '@capacitor/core'
import { onMounted, onUnmounted } from 'vue'

let listenerHandle: PluginListenerHandle

onMounted(async () => {
  if (Capacitor.getPlatform() === 'ios') {
    const onSuspend = (): void => {
      // We want to show the splash screen when we suspend
      // so it will already be there on resume.
      SplashScreen.show({
        source: 'LaunchScreen_hi',
        delay: 0,
        showDuration: 100
      }).catch(console.error)
    }

    const onResume = (): void => {
      SplashScreen.hide({
        delay: 300,
        fadeOutDuration: 300
      }).catch(console.error)
    }

    listenerHandle = await SplashScreen.listenToAppState({
      onSuspend,
      onResume
    })
  }
})

onUnmounted(async () => {
  if (listenerHandle) {
    await listenerHandle.remove()
  }
})
```

The trick we are playing here is to show the splash screen as the app is suspended, so that when the app is resumed, the splash screen is already visible, and then we just need to hide it. 😎

## Custom animation

This plugin provides hooks for custom animation on both iOS and Android. The [workshop app](https://github.com/aparajita/capacitor-splash-screen-demo) contains a complete example of custom animation on both platforms, which you can use as a template for your animation.

👉 **NOTE:** Your custom animation code is responsible for hiding the splash screen.

Once you have implemented your custom animation code, performing the animation is just a matter of calling [`animate()`](#animate) instead of `hide()`.

### Events

There are two possible animation events sent to your animation method. Of those, you are only required to respond to the `animateLaunch` event.

- **animateLaunch** — Sent when the `animate()` method is called for a launch screen, after any delay specified in the animate options.

- **animate** — Sent when the `animate()` method is called after calling `show()`, and after any delay specified in the animate options.

### Event handler

In order to receive animation events (and thus perform animation), you need to create an animation handler method in your app’s native code. On iOS, a minimal event handler will look like this:

```swift
import AparajitaCapacitorSplashScreen

private let kDefaultDuration: Double = 0.7 // seconds

extension AppDelegate {
  @objc func onSplashScreenEvent(_ event: String, _ params: [AnyHashable: Any]) {
    animate(withParams: params)
  }

  private func animate(withParams params: [AnyHashable: Any]) {
    guard let view = params["splashView"] as? UIView,
          let options = params["options"] as? [AnyHashable: Any],
          let callbacks = params["callbacks"] as? SplashScreen.AnimationCallbacks else {
      return
    }

    let animationDuration = SplashScreen.toSeconds(Config.getDouble("animationDuration", inOptions: options) ?? kDefaultDuration)

    UIView.animateKeyframes(
      withDuration: animationDuration,
      delay: 0,
      options: [],
      animations: {
        self.performAnimation(forView: view)
      },
      completion: { _ in
        self.finishAnimation(forView: view, done: done)
      }
    )
  }

  private func performAnimation(forView view: UIView) {
    // Your animation code goes here
  }

  private func finishAnimation(
    forView view: UIView,
    callbacks: SplashScreen.AnimationCallbacks)
  {
    // Your cleanup code goes here

    // Make sure to call the done callback so control returns to the app
    callbacks.done()
  }
}
```

On Android, a minimal event handler will look like this:

```java
public class SplashScreenAnimator {

  static final long DEFAULT_ANIMATION_DURATION = 500;

  public void onSplashScreenEvent(
    SplashScreen.HookEventType event,
    HashMap<String, Object> params
  ) {
    animate(params);
  }

  private void animate(HashMap<String, Object> params) {
    AnimationCallbacks callbacks = null;
    View splashView = null;
    View iconView = null;
    long duration = DEFAULT_ANIMATION_DURATION;

    try {
      splashView = (View) params.get("splashView");
      iconView = (View) params.get("iconView");
      callbacks = (AnimationCallbacks) params.get("callbacks");
      JSObject options = (JSObject) params.get("options");
      Config config = (Config) params.get("config");

      if (options != null && config != null) {
        duration =
          SplashScreen.toMilliseconds(
            config.getDoubleOption(
              "animationDuration",
              options,
              DEFAULT_ANIMATION_DURATION
            )
          );
      }
    } catch (Exception ex) {
      // Handle it below
    }

    if (splashView == null || iconView == null) {
      if (callbacks != null) {
        callbacks.error(
          "Null splash or icon view",
          SplashScreen.ErrorType.NO_SPLASH
        );
      }

      return;
    }
    // Your animation code goes here. Be sure to call
    // callbacks.done() when the animation finishes or
    // is cancelled.
  }
}

```

To dispatch to the event handler on Android, your app’s `MainActivity` must implement `onSplashScreenEvent()`:

```java
public class MainActivity extends BridgeActivity {

  private final SplashScreenAnimator animator = new SplashScreenAnimator();

  @Override
  public void onCreate(Bundle savedInstanceState) {
    SplashScreen.initLaunchTime();
    super.onCreate(savedInstanceState);
  }

  public void onSplashScreenEvent(
    SplashScreen.HookEventType event,
    HashMap<String, Object> params
  ) {
    animator.onSplashScreenEvent(event, params);
  }
}

```

👉 **IMPORTANT**❗️
The `onSplashScreenEvent` method name and signature must be **exactly** as displayed above.

### Event parameters

Each event receives parameters from the plugin with context that you may need in performing your animation.

| Param      | Type (iOS / Android)                                  | Description                                                                                                            |
| :--------- | :---------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------- |
| source     | String                                                | The `source` option passed to `show()`, defaults to "\*"                                                               |
| splashView | UIView<br>android.view.View                           | iOS: The storyboard’s main view controller view<br>Android: A full screen `FrameLayout` which contains the `iconView`. |
| iconView   | [unused]<br>View                                      | The splash icon                                                                                                        |
| plugin     | CAPPlugin<br>com.getcapacitor.Plugin                  | The `SplashScreen` instance which called the event handler                                                             |
| options    | [AnyHashable: Any]<br>com.getcapacitor.JSObject       | Options passed to the `animate()` plugin method                                                                        |
| callbacks  | SplashScreen.AnimationCallbacks<br>AnimationCallbacks | Contains `done` and `error` functions, one of which you **must** call when the animation is completely finished        |

As noted above, you **must** call either the `done` or `error` callback when the animation is completely done, otherwise control will not be returned to the JavaScript runtime. In most cases you will do this in the animation completion function.

### Android-only event parameters

The following parameters are only passed on Android:

| Param    | Type              | Description                      |
| :------- | :---------------- | :------------------------------- |
| iconView | View              | The splash icon                  |
| config   | Config instance   | Use to get values from `options` |
| activity | AppCompatActivity | The current activity             |

### Android-specific animation

When a splash screen is shown on Android, the status bar and navigation bar colors are smoothly animated from their current color to the background color of the splash screen, which effectively hides them. When your splash screen animation is fading out, you need to show the status and navigation bars (if they were visible in your app).

The `callbacks` parameter on Android contains two extra methods:

```java
void showStatusBar(long delay, long duration, TimeInterpolator interpolator);

void showNavigationBar(
  long delay,
  long duration,
  TimeInterpolator interpolator
);
```

Calling these methods will smoothly transition the relevant background color from the splash screen background color to the bar’s previous color. If `interpolator` is `null`, it defaults to `LinearInterpolator`.

For an example of how to use these callbacks, see [SplashScreenAnimator.java](https://github.com/aparajita/capacitor-splash-screen-demo/blob/main/android/app/src/main/java/com/aparajita/capacitor/splashscreendemo/SplashScreenAnimator.java) in the [workshop app](https://github.com/aparajita/capacitor-splash-screen-demo).

#### Why no immersive mode?

There are a few reasons why this plugin does not support immersive mode:

- The new system splash screens in Android 12+ do not use immersive mode, they set the status and navigation bar backgrounds to the splash screen background. This plugin endeavors to be as consistent with the system splash screen as possible.
- Immersive mode slides the status and navigation bars offscreen, but if the user taps the screen before the splash screen is hidden they will reappear.
- On some versions of Android, when immersive mode is entered a system dialog appears advising the user to tap the screen to show the status and navigation bars. This is not something you want to happen during your app launch.

### Accessing animation options

This plugin provides a custom Config class that allows you to use different option values for each platform when passing options to `show`, `hide` and `animate`. For example, you may want a different `animationDuration` on each platform:

```typescript
SplashScreen.animate({
  ios: {
    animationDuration: 500
  },
  android: {
    animationDuration: 700
  }
})
```

In your custom animation code, if you want to get values from the options passed to `animate`, use the custom config class to retrieve those values, as shown in the event handler examples above. In brief, to retrieve a value of `<type>` (String, Double, etc.) from the options passed in the animation params, do the following on iOS:

```text
let value = Config.get<type>(<key>, inOptions: options) ?? <default>
```

and this in Android:

```text
<type> value = config.get<type>Option(<key>, options, <default>);
```

So to retrieve the string value "foo" with a default of "bar", you would do this on iOS:

```swift
let foo = Config.getString("foo", inOptions: options) ?? "bar"
```

and this in Android:

```java
String foo = config.getStringOption("foo", options, "bar");
```

## API

<docgen-index>

- [`show(...)`](#show)
- [`hide(...)`](#hide)
- [`animate(...)`](#animate)
- [`listenToAppState(...)`](#listentoappstate)
- [Interfaces](#interfaces)
- [Type Aliases](#type-aliases)

</docgen-index>

---

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### show(...)

```typescript
show(options?: SplashScreenShowOptions) => Promise<void>
```

Show the splash screen. Does not apply to launch screens.<br><br>NOTE: On Android, the size of the splash screen icon may not exactly match the actual launch screen icon size. I was not able to determine the algorithm used by Android to determine the size of the splash screen icon.

| Param   | Type                                                           |
| :------ | :------------------------------------------------------------- |
| options | <a href="#splashscreenshowoptions">SplashScreenShowOptions</a> |

---

### hide(...)

```typescript
hide(options?: SplashScreenHideOptions) => Promise<void>
```

Hide the splash screen. You must call `hide()` or `animate()` to remove a launch screen, typically after your app is fully mounted.

| Param   | Type                                                           |
| :------ | :------------------------------------------------------------- |
| options | <a href="#splashscreenhideoptions">SplashScreenHideOptions</a> |

---

### animate(...)

```typescript
animate(options?: SplashScreenAnimateOptions) => Promise<void>
```

Animate the splash screen. You must call `hide()` or `animate()` to remove a launch screen, typically after your app is fully mounted.

| Param   | Type                                                                 |
| :------ | :------------------------------------------------------------------- |
| options | <a href="#splashscreenanimateoptions">SplashScreenAnimateOptions</a> |

---

### listenToAppState(...)

```typescript
listenToAppState(options?: SplashScreenAppStateListeners) => Promise<PluginListenerHandle>
```

Listen to changes in the app state and execute the relevant code. This is a convenience to allow you to easily show a splash when your app resumes. Be sure to save the result of this call somewhere. When you no longer need to listen to the app state (e.g. when a component unmounts), be sure to call the `remove()` method on the returned <a href="#pluginlistenerhandle">`PluginListenerHandle`</a>.<br><br>NOTE: This cannot be reliably used on Android, as the app may be paused before the listener is called.

| Param   | Type                                                                       |
| :------ | :------------------------------------------------------------------------- |
| options | <a href="#splashscreenappstatelisteners">SplashScreenAppStateListeners</a> |

**Returns:** Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;

---

### Interfaces

#### SplashScreenShowOptions

Show options may be specified separately for iOS and Android.

| Prop    | Type                                                     |
| :------ | :------------------------------------------------------- |
| ios     | <a href="#splashscreenshowopts">SplashScreenShowOpts</a> |
| android | <a href="#splashscreenshowopts">SplashScreenShowOpts</a> |

#### SplashScreenShowOpts

| Prop           | Type                                                     | Description                                                                                                                                                                                                                                                                                                                                                                                     |
| :------------- | :------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| source         | string                                                   | The source of the splash screen. Does not apply to launch screens. On iOS, it may be a storyboard with the given name. On Android, it may be any vector drawable with the given name. If the name is "\*", on iOS the configured LaunchScreen storyboard in the app's project will be used, on Android the value of the `windowSplashScreenAnimatedIcon` item in the launch theme will be used. |
| delay          | <a href="#splashscreenduration">SplashScreenDuration</a> | How long to delay before showing the splash screen. Does not apply to launch screens.                                                                                                                                                                                                                                                                                                           |
| fadeInDuration | <a href="#splashscreenduration">SplashScreenDuration</a> | How long to fade in. Does not apply to launch screens.                                                                                                                                                                                                                                                                                                                                          |
| showDuration   | <a href="#splashscreenduration">SplashScreenDuration</a> | Launch: The minimum time to show the splash screen. If `animate()` or `hide()` is called before this time elapses, the screen will remain until the duration is finished.<br><br>`show()`: How long to show the splash screen after fade in and before fade out.                                                                                                                                |

#### SplashScreenHideOptions

Hide options may be specified separately for iOS and Android.

| Prop    | Type                                                     |
| :------ | :------------------------------------------------------- |
| ios     | <a href="#splashscreenhideopts">SplashScreenHideOpts</a> |
| android | <a href="#splashscreenhideopts">SplashScreenHideOpts</a> |

#### SplashScreenHideOpts

| Prop            | Type                                                     | Description                      |
| :-------------- | :------------------------------------------------------- | :------------------------------- |
| delay           | <a href="#splashscreenduration">SplashScreenDuration</a> | How long to delay before hiding. |
| fadeOutDuration | <a href="#splashscreenduration">SplashScreenDuration</a> | How long to fade out.            |

#### SplashScreenAnimateOptions

Animate options may be specified separately for iOS and Android.

| Prop    | Type                                                           |
| :------ | :------------------------------------------------------------- |
| ios     | <a href="#splashscreenanimateopts">SplashScreenAnimateOpts</a> |
| android | <a href="#splashscreenanimateopts">SplashScreenAnimateOpts</a> |

#### SplashScreenAnimateOpts

| Prop              | Type                                                     | Description                                            |
| :---------------- | :------------------------------------------------------- | :----------------------------------------------------- |
| delay             | <a href="#splashscreenduration">SplashScreenDuration</a> | How long to delay before starting the animation.       |
| animationDuration | <a href="#splashscreenduration">SplashScreenDuration</a> | How long animation should take when calling `animate`. |

#### PluginListenerHandle

| Method     | Signature                    |
| :--------- | :--------------------------- |
| **remove** | () =&gt; Promise&lt;void&gt; |

#### SplashScreenAppStateListeners

### Type Aliases

#### SplashScreenDuration

In options objects, when you specify a duration, it can either be in seconds or milliseconds. Any value &gt;= 10 will be considered milliseconds, any value &lt; 10 will be considered seconds.

<code>number</code>

</docgen-api>
</div>
