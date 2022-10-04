package com.aparajita.capacitor.splashscreen;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.animation.TimeInterpolator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.graphics.PixelFormat;
import android.graphics.Point;
import android.graphics.drawable.AnimatedVectorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.core.content.res.ResourcesCompat;
import androidx.core.splashscreen.SplashScreenViewProvider;
import com.aparajita.capacitor.logger.Logger;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;
import org.jetbrains.annotations.Contract;

@CapacitorPlugin(name = "SplashScreen")
public class SplashScreen extends Plugin {

  interface ColorUpdater {
    void update(Integer color);
  }

  public enum HookEventType {
    animateLaunch,
    animate
  }

  public enum ErrorType {
    NOT_FOUND("notFound"),
    NO_SPLASH("noSplash"),
    ALREADY_ACTIVE("alreadyActive"),
    HOOK_METHOD_NOT_FOUND("hookMethodNotFound"),
    HOOK_METHOD_FAILED("animateMethodFailed");

    private final String code;

    ErrorType(String code) {
      this.code = code;
    }

    public String getCode() {
      return this.code;
    }
  }

  private static long launchStartTime;
  private static int statusBarColor;
  private static int navigationBarColor;
  private Config config;
  private Context context;
  private Logger logger;
  private Resources.Theme launchTheme;
  private String source = Options.DEFAULT_SOURCE;
  private FrameLayout splashView;
  private Drawable splashIcon;
  private ImageView iconView;
  private long splashScreenDuration;
  private String splashScreenDrawablePath;
  private JSObject animateOptions;
  private HideOptions hideOptions;
  private Method eventHandler;
  private WindowManager windowManager;
  private AnimationCallbacks animateCallbacks;
  private boolean isActive = false;
  private boolean isHiding = false;
  private boolean isLaunchSplash = false;

  public static void initLaunchTime() {
    launchStartTime = new Date().getTime();
  }

  // Users can specify durations in seconds (< 10) or milliseconds (>= 10).
  // Android animation APIs expect millis, so we always convert to millis.
  public static int toMilliseconds(Double value) {
    return value >= Options.DURATION_MS_THRESHOLD
      ? value.intValue()
      : Double.valueOf(value * 1000.0).intValue();
  }

  private void postError(
    AnimationCallbacks callbacks,
    String message,
    ErrorType code
  ) {
    callbacks.error(message, code);
    isActive = false;
  }

  private boolean isAlreadyHiding(AnimationCallbacks callbacks) {
    if (isHiding) {
      callbacks.error(
        "A splash screen is already active",
        ErrorType.ALREADY_ACTIVE
      );
      return true;
    }

    return false;
  }

  @Override
  public void load() {
    context = getContext();
    config = new Config(this);
    logger = new Logger(this);

    // See if the splash screen event handler is defined,
    // if so we might as well cache it.
    try {
      eventHandler =
        getActivity()
          .getClass()
          .getMethod("onSplashScreenEvent", HookEventType.class, HashMap.class);
    } catch (NoSuchMethodException e) {
      logger.info("no onSplashScreenEvent() handler found");
    }

    showLaunchScreen();
  }

  @PluginMethod
  public void show(@NonNull PluginCall call) {
    show(call.getData(), makePluginCallbacks(call));
  }

  @PluginMethod
  public void hide(@NonNull PluginCall call) {
    hideOptions = new HideOptions(call.getData(), config);
    hide(makePluginCallbacks(call));
  }

  @PluginMethod
  public void animate(@NonNull PluginCall call) {
    animate(call.getData(), makePluginCallbacks(call));
  }

  @NonNull
  @Contract("_ -> new")
  private AnimationCallbacks makePluginCallbacks(PluginCall call) {
    return new AnimationCallbacks() {
      @Override
      public void done() {
        animateOptions = null;
        call.resolve();
      }

      @Override
      public void error(String message, ErrorType code) {
        animateOptions = null;
        call.reject(message, code.getCode());
      }

      @Override
      public void showStatusBar(
        long delay,
        long duration,
        TimeInterpolator interpolator
      ) {
        SplashScreen.showStatusBar(
          getActivity(),
          getSplashScreenBackground(),
          delay,
          duration,
          interpolator
        );
      }

      @Override
      public void showNavigationBar(
        long delay,
        long duration,
        TimeInterpolator interpolator
      ) {
        SplashScreen.showNavigationBar(
          getActivity(),
          getSplashScreenBackground(),
          delay,
          duration,
          interpolator
        );
      }
    };
  }

  public void showLaunchScreen() {
    isLaunchSplash = true;
    isActive = false;
    isHiding = false;

    // This will be set if animate() is called
    animateCallbacks = null;

    // When we get here, the system has already shown the launch screen
    androidx.core.splashscreen.SplashScreen launchScreen = androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen(
      getActivity()
    );
    launchTheme = getActivity().getTheme();

    // Get the configured splash screen icon
    TypedArray attrs = launchTheme.obtainStyledAttributes(
      new int[] { R.attr.windowSplashScreenAnimatedIcon }
    );

    splashScreenDrawablePath = attrs.getString(0);
    attrs.recycle();

    splashScreenDuration =
      toMilliseconds(
        config.getDouble(Options.SHOW_DURATION, Options.DEFAULT_SHOW_DURATION)
      );
    Date showUntil = new Date();
    showUntil.setTime(showUntil.getTime() + splashScreenDuration);
    launchScreen.setKeepOnScreenCondition(() -> keepOnScreen(showUntil));

    // Save the theme's status bar and navigation bar colors,
    // then set them to transparent so there is no flicker when
    // the system launch screen starts to exit.
    AppCompatActivity activity = getActivity();
    statusBarColor = activity.getWindow().getStatusBarColor();
    navigationBarColor = activity.getWindow().getNavigationBarColor();
    int splashScreenBackground = getSplashScreenBackground();
    activity.getWindow().setStatusBarColor(splashScreenBackground);
    activity.getWindow().setNavigationBarColor(splashScreenBackground);

    launchScreen.setOnExitAnimationListener(viewProvider -> {
      if (animateCallbacks != null) {
        animateLaunchScreen(viewProvider);
      } else {
        fadeOutLaunchScreen(viewProvider);
      }
    });
  }

  private boolean keepOnScreen(Date showUntil) {
    // Keep the splash on screen until dismissed by the app and the show duration has elapsed
    boolean keepShowing = new Date().before(showUntil);
    return keepShowing || !isHiding;
  }

  private void fadeOutLaunchScreen(
    @NonNull SplashScreenViewProvider viewProvider
  ) {
    final ObjectAnimator fadeAnimator = ObjectAnimator.ofFloat(
      viewProvider.getView(),
      View.ALPHA,
      1f,
      0f
    );
    fadeAnimator.setInterpolator(new LinearInterpolator());
    fadeAnimator.setDuration(hideOptions.fadeOutDuration);

    fadeAnimator.addListener(
      new AnimatorListenerAdapter() {
        @Override
        public void onAnimationEnd(Animator animation) {
          removeLaunchScreen(viewProvider);
        }
      }
    );

    fadeAnimator.start();
    int splashScreenBackground = getSplashScreenBackground();
    showStatusBar(
      getActivity(),
      splashScreenBackground,
      0,
      hideOptions.fadeOutDuration,
      null
    );
    showNavigationBar(
      getActivity(),
      splashScreenBackground,
      0,
      hideOptions.fadeOutDuration,
      null
    );
  }

  private void animateLaunchScreen(SplashScreenViewProvider viewProvider) {
    AppCompatActivity activity = getActivity();
    int splashScreenBackground = getSplashScreenBackground();

    AnimationCallbacks callbacks = new AnimationCallbacks() {
      private void cleanup() {
        removeLaunchScreen(viewProvider);

        // On API 31+ if we don't do this after removeLaunchScreen()
        // the navigation bar goes transparent.
        Window window = getActivity().getWindow();
        window.setStatusBarColor(statusBarColor);
        window.setNavigationBarColor(navigationBarColor);
      }

      @Override
      public void done() {
        cleanup();
        animateCallbacks.done();
      }

      @Override
      public void error(String message, ErrorType code) {
        cleanup();
        animateCallbacks.error(message, code);
      }

      @Override
      public void showStatusBar(
        long delay,
        long duration,
        TimeInterpolator interpolator
      ) {
        SplashScreen.showStatusBar(
          activity,
          splashScreenBackground,
          delay,
          duration,
          interpolator
        );
      }

      @Override
      public void showNavigationBar(
        long delay,
        long duration,
        TimeInterpolator interpolator
      ) {
        SplashScreen.showNavigationBar(
          activity,
          splashScreenBackground,
          delay,
          duration,
          interpolator
        );
      }
    };

    callHook(
      HookEventType.animateLaunch,
      animateOptions,
      callbacks,
      viewProvider.getView(),
      viewProvider.getIconView()
    );
  }

  private void removeLaunchScreen(
    @NonNull SplashScreenViewProvider viewProvider
  ) {
    isHiding = false;
    isLaunchSplash = false;
    isActive = false;
    viewProvider.remove();
  }

  public void show(JSObject callOptions, AnimationCallbacks callbacks) {
    if (isActive) {
      callbacks.error(
        "A splash screen is already active",
        ErrorType.ALREADY_ACTIVE
      );
      return;
    }

    isActive = true;
    ShowOptions showOptions = new ShowOptions(callOptions, config);
    logger.debug(showOptions.toString());

    source = callOptions.getString(Options.SOURCE);

    if (source == null) {
      source = Options.DEFAULT_SOURCE;
    }

    windowManager =
      (WindowManager) getActivity().getSystemService(Context.WINDOW_SERVICE);
    AtomicBoolean success = new AtomicBoolean(true);

    getActivity()
      .runOnUiThread(() -> {
        try {
          buildViews();
        } catch (Exception e) {
          String error = e.getMessage();

          if (error == null) {
            error = "";
          }

          String message = error.isEmpty()
            ? String.format(
              Locale.getDefault(),
              "No drawable named \"%s\" found",
              source
            )
            : error;
          logger.error(message);

          ErrorType code = error.isEmpty()
            ? ErrorType.NOT_FOUND
            : ErrorType.NO_SPLASH;
          postError(callbacks, message, code);
          success.set(false);
        }

        if (!success.get()) {
          return;
        }

        if (splashIcon instanceof AnimatedVectorDrawable) {
          ((AnimatedVectorDrawable) splashIcon).start();
        }

        final Animator.AnimatorListener listener = makeShowAnimationListener(
          callbacks
        );

        final Handler mainHandler = new Handler(getActivity().getMainLooper());

        mainHandler.postDelayed(
          makeRunner(showOptions, listener),
          showOptions.delay
        );
      });
  }

  public void animate(JSObject callOptions, AnimationCallbacks callbacks) {
    if (isAlreadyHiding(callbacks)) {
      return;
    }

    // If we're launching, just set the hiding flag to allow the splash screen to exit
    if (isLaunchSplash) {
      animateCallbacks = callbacks;
      animateOptions = callOptions;
      isHiding = true;
      return;
    }

    if (splashView == null) {
      postError(
        callbacks,
        "No splash screen view is available",
        ErrorType.NO_SPLASH
      );
      return;
    }

    // Animation needs to call this callback when done to resolve the plugin call
    AnimationCallbacks animateCallbacks = new AnimationCallbacks() {
      @Override
      public void done() {
        tearDown();
        callbacks.done();
      }

      @Override
      public void error(String message, ErrorType code) {
        postError(callbacks, message, code);
      }

      @Override
      public void showStatusBar(
        long delay,
        long duration,
        TimeInterpolator interpolator
      ) {
        SplashScreen.showStatusBar(
          getActivity(),
          getSplashScreenBackground(),
          delay,
          duration,
          interpolator
        );
      }

      @Override
      public void showNavigationBar(
        long delay,
        long duration,
        TimeInterpolator interpolator
      ) {
        SplashScreen.showNavigationBar(
          getActivity(),
          getSplashScreenBackground(),
          delay,
          duration,
          interpolator
        );
      }
    };

    callHook(
      HookEventType.animate,
      callOptions,
      animateCallbacks,
      splashView,
      iconView
    );
  }

  private long getRemainingShowTime(long startTime) {
    long timeSinceStart = new Date().getTime() - startTime;
    return Math.max(splashScreenDuration - timeSinceStart, 0);
  }

  @Override
  public void handleOnDestroy() {
    tearDown();
  }

  private void buildViews() {
    // We are simulating what the Android framework does when it creates a splash screen
    splashView = new FrameLayout(context);
    splashView.setPadding(0, 0, 0, 0);
    splashView.setLayoutParams(
      new FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
      )
    );

    // Let the splashView go under the status and navigation bars
    splashView.setFitsSystemWindows(false);

    // Allow the content to go under the status/navigation bars
    // and make sure the splash does not move if the status bar appears/disappears
    splashView.setSystemUiVisibility(
      View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
    );
    splashView.setBackgroundColor(getSplashScreenBackground());

    String iconName;

    if (source.equals(Options.DEFAULT_SOURCE)) {
      // R.attr.windowSplashScreenAnimatedIcon returns a full path,
      // but getIdentifier() expects a resource name.
      iconName = getLaunchScreenName(splashScreenDrawablePath);
    } else {
      iconName = source;
    }

    int iconId = getSplashIconId(iconName);
    splashIcon =
      ResourcesCompat.getDrawable(
        context.getResources(),
        iconId,
        context.getTheme()
      );
    iconView = new AppCompatImageView(context);
    iconView.setImageDrawable(splashIcon);
    iconView.setScaleType(ImageView.ScaleType.FIT_CENTER);

    // I can't quite figure out the sizing algorithm for the splash icon.
    // Closest I can get is 70% of the screen width for screen sizes above 1024,
    // 80% of the width for screen sizes below 1024.
    Point size = new Point();
    getActivity().getWindowManager().getDefaultDisplay().getRealSize(size);
    int factor = size.x >= 1024 ? 7 : 8;

    FrameLayout.LayoutParams iconParams = new FrameLayout.LayoutParams(
      size.x * factor / 10,
      size.x * factor / 10
    );
    iconParams.gravity = Gravity.CENTER;
    iconView.setLayoutParams(iconParams);

    splashView.addView(iconView);
  }

  private int getSplashScreenBackground() {
    // Get the configured splash screen background color
    TypedArray attrs = launchTheme.obtainStyledAttributes(
      new int[] { R.attr.windowSplashScreenBackground }
    );

    int background = attrs.getInt(0, 0);
    attrs.recycle();

    return background;
  }

  private String getLaunchScreenName(String launchScreenPath)
    throws Resources.NotFoundException {
    if (launchScreenPath != null) {
      File file = new File(launchScreenPath);
      String name = file.getName();
      return name.substring(0, name.lastIndexOf('.'));
    } else {
      throw new Resources.NotFoundException(
        "No windowSplashScreenAnimatedIcon attribute found in launch theme"
      );
    }
  }

  private int getSplashIconId(String iconName) {
    int iconId = context
      .getResources()
      .getIdentifier(iconName, "drawable", context.getPackageName());

    if (iconId == 0) {
      throw new Resources.NotFoundException(
        String.format("No drawable named \"%s\" found", iconName)
      );
    }

    return iconId;
  }

  private Runnable makeRunner(
    final ShowOptions showOptions,
    final Animator.AnimatorListener listener
  ) {
    return () -> {
      WindowManager.LayoutParams params = new WindowManager.LayoutParams();
      params.flags = getActivity().getWindow().getAttributes().flags;
      params.gravity = Gravity.CENTER;

      // Required to enable the view to actually fade
      params.format = PixelFormat.TRANSLUCENT;
      fadeInSplashView(params, showOptions, listener);
    };
  }

  private void fadeInSplashView(
    WindowManager.LayoutParams params,
    ShowOptions showOptions,
    Animator.AnimatorListener listener
  ) {
    try {
      addSplashView(splashView, params);
    } catch (IllegalStateException | IllegalArgumentException ex) {
      logger.error("Could not add splash view");
    }

    splashView.setAlpha(0f);
    splashView.setVisibility(View.VISIBLE);
    splashView
      .animate()
      .alpha(1f)
      .setInterpolator(new LinearInterpolator())
      .setDuration(showOptions.fadeInDuration)
      .setListener(listener);

    hideStatusBar(
      getActivity(),
      getSplashScreenBackground(),
      0,
      showOptions.fadeInDuration,
      null
    );
    hideNavigationBar(
      getActivity(),
      getSplashScreenBackground(),
      0,
      showOptions.fadeInDuration,
      null
    );
  }

  public static void hideStatusBar(
    AppCompatActivity activity,
    int endColor,
    long delay,
    long duration,
    TimeInterpolator interpolator
  ) {
    ValueAnimator animation = ValueAnimator.ofArgb(statusBarColor, endColor);
    ColorUpdater updater = color ->
      activity.getWindow().setStatusBarColor(color);
    showHide(animation, delay, duration, interpolator, updater);
  }

  public static void showStatusBar(
    AppCompatActivity activity,
    int startColor,
    long delay,
    long duration,
    TimeInterpolator interpolator
  ) {
    ValueAnimator animation = ValueAnimator.ofArgb(startColor, statusBarColor);
    ColorUpdater updater = color ->
      activity.getWindow().setStatusBarColor(color);
    showHide(animation, delay, duration, interpolator, updater);
  }

  public static void hideNavigationBar(
    AppCompatActivity activity,
    int endColor,
    long delay,
    long duration,
    TimeInterpolator interpolator
  ) {
    ValueAnimator animation = ValueAnimator.ofArgb(
      navigationBarColor,
      endColor
    );
    ColorUpdater updater = color ->
      activity.getWindow().setNavigationBarColor(color);
    showHide(animation, delay, duration, interpolator, updater);
  }

  public static void showNavigationBar(
    AppCompatActivity activity,
    int startColor,
    long delay,
    long duration,
    TimeInterpolator interpolator
  ) {
    ValueAnimator animation = ValueAnimator.ofArgb(
      startColor,
      navigationBarColor
    );
    ColorUpdater updater = color ->
      activity.getWindow().setNavigationBarColor(color);
    showHide(animation, delay, duration, interpolator, updater);
  }

  private static void showHide(
    ValueAnimator animation,
    long delay,
    long duration,
    TimeInterpolator interpolator,
    ColorUpdater updater
  ) {
    animation.setInterpolator(interpolator);
    animation.setStartDelay(delay);
    animation.setDuration(duration);
    animation.addUpdateListener(animator ->
      updater.update((int) animator.getAnimatedValue())
    );
    animation.start();
  }

  private Animator.AnimatorListener makeShowAnimationListener(
    AnimationCallbacks callbacks
  ) {
    return new Animator.AnimatorListener() {
      @Override
      public void onAnimationEnd(Animator animator) {
        callbacks.done();
      }

      @Override
      public void onAnimationCancel(Animator animator) {}

      @Override
      public void onAnimationRepeat(Animator animator) {}

      @Override
      public void onAnimationStart(Animator animator) {}
    };
  }

  /**
   * Hide the splash screen with the given options
   */
  public void hide(AnimationCallbacks callbacks) {
    // If we're already hiding, do nothing
    if (isAlreadyHiding(callbacks)) {
      return;
    }

    isHiding = true;

    // If we are launching, setting isHiding is all we need, there is nothing more to do
    if (isLaunchSplash) {
      callbacks.done();
      return;
    }

    // If the splashView has not been created, complain and return, there is nothing to hide
    if (splashView == null) {
      postError(
        callbacks,
        "No splash screen view is available",
        ErrorType.NO_SPLASH
      );

      return;
    }

    int delay = hideOptions.delay;
    int fadeOutDuration = hideOptions.fadeOutDuration;

    final Animator.AnimatorListener listener = new Animator.AnimatorListener() {
      private void done() {
        tearDown();
        callbacks.done();
      }

      @Override
      public void onAnimationEnd(Animator animator) {
        this.done();
      }

      @Override
      public void onAnimationCancel(Animator animator) {
        this.done();
      }

      @Override
      public void onAnimationStart(Animator animator) {
        showStatusBar(
          getActivity(),
          getSplashScreenBackground(),
          0,
          fadeOutDuration,
          null
        );
        showNavigationBar(
          getActivity(),
          getSplashScreenBackground(),
          0,
          fadeOutDuration,
          null
        );
      }

      @Override
      public void onAnimationRepeat(Animator animator) {}
    };

    Handler mainHandler = new Handler(context.getMainLooper());
    mainHandler.postDelayed(
      () ->
        splashView
          .animate()
          .alpha(0)
          .setInterpolator(new LinearInterpolator())
          .setDuration(fadeOutDuration)
          .setListener(listener),
      delay
    );
  }

  public void callHook(
    HookEventType eventType,
    JSObject callOptions,
    AnimationCallbacks callbacks,
    View splashView,
    View iconView
  ) {
    if (eventHandler == null) {
      if (eventType == HookEventType.animate) {
        callbacks.done();
      }

      return;
    }

    int delay = toMilliseconds(callOptions.optDouble(Options.DELAY, .0));
    callOptions.remove(Options.DELAY);

    Handler mainHandler = new Handler(getActivity().getMainLooper());
    mainHandler.postDelayed(
      () -> doCallHook(eventType, callOptions, callbacks, splashView, iconView),
      delay + getRemainingShowTime(launchStartTime)
    );
  }

  private void doCallHook(
    HookEventType eventType,
    JSObject callOptions,
    AnimationCallbacks callbacks,
    View splashView,
    View iconView
  ) {
    try {
      HashMap<String, Object> params = makeHookParams(
        callOptions,
        callbacks,
        splashView,
        iconView
      );

      eventHandler.invoke(getActivity(), eventType, params);
    } catch (IllegalAccessException | InvocationTargetException ex) {
      postError(
        callbacks,
        "The call to onSplashScreenEvent() failed",
        ErrorType.HOOK_METHOD_NOT_FOUND
      );
    } catch (Exception ex) {
      postError(callbacks, ex.getMessage(), ErrorType.HOOK_METHOD_FAILED);
    }
  }

  private HashMap<String, Object> makeHookParams(
    JSObject callOptions,
    AnimationCallbacks callbacks,
    View splashView,
    View iconView
  ) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("source", source);
    params.put("splashView", splashView);
    params.put("iconView", iconView);
    params.put("plugin", this);
    params.put("options", callOptions);
    params.put("config", config);
    params.put("callbacks", callbacks);
    params.put("activity", getActivity());
    return params;
  }

  private void addSplashView(View view, ViewGroup.LayoutParams params) {
    // Resize the layout to the entire screen size
    Point size = new Point();
    getActivity().getWindowManager().getDefaultDisplay().getRealSize(size);
    params.height = size.y;
    windowManager.addView(view, params);
  }

  private void removeView(View view) {
    windowManager.removeView(view);
  }

  public void tearDown() {
    if (splashView != null) {
      splashView.setVisibility(View.GONE);
      removeView(splashView);
      splashView = null;
      iconView = null;
      splashIcon = null;
    }

    isHiding = false;
    isActive = false;
  }
}
