package com.willsub.splashscreen;

import android.animation.Animator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.drawable.Animatable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Handler;
import android.view.*;
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import androidx.annotation.NonNull;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;

import com.getcapacitor.Logger;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;

/**
 * A Splash Screen service for showing and hiding a splash screen in the app.
 */
@SuppressLint("StaticFieldLeak")
public class Splash {
    public static final int DEFAULT_FADE_IN_DURATION = 200;
    public static final int DEFAULT_FADE_OUT_DURATION = 200;
    public static final int DEFAULT_SHOW_DURATION = 3000;
    public static final boolean DEFAULT_AUTO_HIDE = false;
    public static final boolean DEFAULT_ANIMATE = false;
    public static final boolean DEFAULT_SHOW_SPINNER = false;
    public static final boolean DEFAULT_FULLSCREEN_MODE = false;
    private static final HashMap<String, ImageView.ScaleType> displayModeMap;
    private static final HashMap<String, Integer> spinnerStyleMap;
    private static boolean isHiding = false;
    private static Drawable splashImage;
    private static View splashView;
    private static ProgressBar spinner;
    private static WindowManager wm;
    private static ShowOptions showOptions;
    private static boolean isVisible = false;
    private static boolean isFullscreen = DEFAULT_FULLSCREEN_MODE;

    static {
        // NOTE: The keys are lowercased, the values in the config are case-insensitive
        displayModeMap = new HashMap<>();
        displayModeMap.put("fill", ImageView.ScaleType.FIT_XY);
        displayModeMap.put("aspectfill", ImageView.ScaleType.CENTER_CROP);
        displayModeMap.put("fit", ImageView.ScaleType.FIT_CENTER);
        displayModeMap.put("fittop", ImageView.ScaleType.FIT_START);
        displayModeMap.put("fitbottom", ImageView.ScaleType.FIT_END);
        displayModeMap.put("center", ImageView.ScaleType.CENTER);
    }

    static {
        // NOTE: The keys are lowercased, the values in the config are case-insensitive
        spinnerStyleMap = new HashMap<>();
        spinnerStyleMap.put("horizontal", android.R.attr.progressBarStyleHorizontal);
        spinnerStyleMap.put("small", android.R.attr.progressBarStyleSmall);
        spinnerStyleMap.put("large", android.R.attr.progressBarStyleLarge);
        spinnerStyleMap.put("smallinverse", android.R.attr.progressBarStyleSmallInverse);
        spinnerStyleMap.put("inverse", android.R.attr.progressBarStyleInverse);
        spinnerStyleMap.put("largeinverse", android.R.attr.progressBarStyleLargeInverse);
    }

    private static int parseColor(String color) {
        // Color.parseColor() reads colors as ARGB instead of RGBA, which is the CSS standard. Brilliant!
        // So we have to move the alpha value if it exists. Also, if the color does not have a "#" prefix
        // (which is allowed on iOS), add it, because parseColor() expects it.
        if (color.length() > 1) {
            if (color.charAt(0) != '#') {
                color = "#" + color;
            }

            // If the length is 9, assume it's #RRGGBBAA
            if (color.length() == 9) {
                color = "#" + color.substring(7) + color.substring(1, 7);
            }
        }

        return Color.parseColor(color);
    }

    // The user may specify durations as milliseconds or seconds.
    // Android wants milliseconds for animation parameters, so for convenience we convert to that.
    private static int toMilliseconds(double value) {
        // Durations >= 20 are considered milliseconds, otherwise seconds.
        return value >= 20 ? (int) value : (int) (value * 1000);
    }

    @SuppressLint("UseCompatLoadingForDrawables")
    private static void buildViews(Context context, ShowOptions options, PluginCall call, Config config) {
        if (splashView == null) {
            boolean found;

            // Allow the default legacy behavior of using a resource called "Splash".
            String resource = "splash";

            // See if a resource was specified in the call or the config. This takes precedence.
            String configResource = config.getString("resource", call);

            if (configResource != null && !configResource.isEmpty()) {
                resource = configResource;
            }

            if (resource.equals("*")) {
                found = checkForLayout("launch_screen", context);
            } else {
                found = checkForImage(resource, context);

                if (!found) {
                    found = checkForLayout(resource, context);
                }
            }

            if (!found) {
                Logger.warn("No splash image or layout found");
            }
        }

        if (options.showSpinner) {
            makeSpinner(context, call, config);
        }
    }

    @SuppressLint("UseCompatLoadingForDrawables")
    private static boolean checkForImage(String resourceName, Context context) {
        try {
            int imageId = getResourceId(context, resourceName, "drawable");
            splashImage = context.getResources().getDrawable(imageId, context.getTheme());
            splashView = new ImageView(context);
            return true;
        } catch (Resources.NotFoundException ex) {
            return false;
        }
    }

    private static boolean checkForLayout(String layoutName, Context context) {
        Activity activity = (Activity) context;
        int layoutId = getResourceId(context, layoutName, "layout");

        if (layoutId != 0) {
            // Inflate the layout and add it to the root view
            LayoutInflater inflator = activity.getLayoutInflater();
            ViewGroup root = new FrameLayout(context);
            root.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

            try {
                splashView = inflator.inflate(layoutId, root, false);
            } catch (InflateException ex) {
                return false;
            }
        }

        return layoutId != 0;
    }

    private static int getResourceId(Context context, String resourceName, String type) {
        return context.getResources().getIdentifier(resourceName, type, context.getPackageName());
    }

    private static void setBackgroundColor(Config config, PluginCall call) {
        // Clear any existing background color by setting it to transparent black
        splashView.setBackgroundColor(0);
        String backgroundColor = config.getString("backgroundColor", call);

        try {
            if (backgroundColor != null) {
                splashView.setBackgroundColor(parseColor(backgroundColor));
            }
        } catch (IllegalArgumentException ex) {
            Logger.debug("Background color '" + backgroundColor + "' not applied");
        }
    }

    private static void setScaleType(ImageView image, Config config, PluginCall call) {
        ImageView.ScaleType scaleType = displayModeMap.get("fit");
        String displayModeName = config.getString("androidImageDisplayMode", call);

        if (displayModeName != null) {
            ImageView.ScaleType mode = displayModeMap.get(displayModeName.toLowerCase());

            if (mode != null) {
                scaleType = mode;
            }
        }

        image.setScaleType(scaleType);
    }

    private static void startAnimation() {
        if (splashImage instanceof Animatable) {
            ((Animatable) splashImage).start();
        }

        if (splashImage instanceof LayerDrawable) {
            LayerDrawable layeredSplash = (LayerDrawable) splashImage;

            for (int i = 0; i < layeredSplash.getNumberOfLayers(); i++) {
                Drawable layerDrawable = layeredSplash.getDrawable(i);

                if (layerDrawable instanceof Animatable) {
                    ((Animatable) layerDrawable).start();
                }
            }
        }
    }

    private static void makeSpinner(Context context, PluginCall call, Config config) {
        String spinnerStyle = config.getString("androidSpinnerStyle", call);

        if (spinnerStyle != null) {
            Integer spinnerBarStyle = spinnerStyleMap.get(spinnerStyle);

            if (spinnerBarStyle == null) {
                spinnerBarStyle = android.R.attr.progressBarStyleLarge;
            }

            spinner = new ProgressBar(context, null, spinnerBarStyle);
        } else {
            spinner = new ProgressBar(context);
        }

        spinner.setIndeterminate(true);
        String spinnerColor = config.getString("spinnerColor", call);

        if (spinnerColor != null) {
            try {
                int[][] states = new int[][]{
                        new int[]{android.R.attr.state_enabled}, // enabled
                        new int[]{-android.R.attr.state_enabled}, // disabled
                        new int[]{-android.R.attr.state_checked}, // unchecked
                        new int[]{android.R.attr.state_pressed}  // pressed
                };
                int spinnerBarColor = parseColor(spinnerColor);
                int[] colors = new int[]{
                        spinnerBarColor,
                        spinnerBarColor,
                        spinnerBarColor,
                        spinnerBarColor
                };
                ColorStateList colorStateList = new ColorStateList(states, colors);
                spinner.setIndeterminateTintList(colorStateList);
            } catch (IllegalArgumentException ex) {
                Logger.debug("Spinner color '" + spinnerColor + "' not applied");
            }
        }
    }

    private static void configureSplashView(PluginCall call, Config config) {
        if (splashView == null) {
            return;
        }

        splashView.setFitsSystemWindows(true);
        setBackgroundColor(config, call);
        isFullscreen = config.getBoolean("androidFullscreen", call, DEFAULT_FULLSCREEN_MODE);

        if (splashView instanceof ImageView) {
            ImageView image = (ImageView) splashView;

            // Stops flickers dead in their tracks
            // https://stackoverflow.com/a/21847579/32140
            image.setDrawingCacheEnabled(true);
            image.setImageDrawable(splashImage);
            setScaleType(image, config, call);
            startAnimation();
        }
    }

    /*
     * Show the splash screen on launch without fading in
     */
    public static void showOnLaunch(final Plugin plugin, final Config config) {
        ShowOptions options = new ShowOptions(plugin, null, true);
        Logger.debug(options.toString());
        show(plugin, null, options, config);
    }

    /*
     * Show the splash screen
     */
    public static void show(final Plugin plugin, final PluginCall call, final ShowOptions options, final Config config) {
        // Save the autoHide flag so we can check it in a hide() call
        showOptions = options;

        Activity activity = plugin.getActivity();
        wm = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);

        // If the splash is in the midst of hiding, wait for that to finish
        if (activity.isFinishing()) {
            return;
        }

        // If the splash is already visible, return to the caller
        if (isVisible) {
            if (call != null) {
                call.success();
            }

            return;
        }

        buildViews(activity, options, call, config);
        configureSplashView(call, config);

        if (splashView != null) {
            final Animator.AnimatorListener listener = makeShowAnimationListener(activity, options, plugin, call);
            final Handler mainHandler = new Handler(activity.getMainLooper());
            mainHandler.post(makeRunner(activity, options, listener));
        }
    }

    private static Runnable makeRunner(
            final Activity activity,
            final ShowOptions options,
            final Animator.AnimatorListener listener) {
        return () -> {
            WindowManager.LayoutParams params = new WindowManager.LayoutParams();
            params.flags = activity.getWindow().getAttributes().flags;
            params.gravity = Gravity.CENTER;

            // Required to enable the view to actually fade
            params.format = PixelFormat.TRANSLUCENT;

            if (!fadeSplashViewIn(params, activity, options, listener)) {
                return;
            }

            if (spinner != null && options.showSpinner) {
                fadeSpinnerIn(params, options);
            }
        };
    }

    private static boolean fadeSplashViewIn(WindowManager.LayoutParams params, Activity activity, ShowOptions options, Animator.AnimatorListener listener) {
        try {
            addSplashView(activity, splashView, params);
        } catch (IllegalStateException | IllegalArgumentException ex) {
            Logger.error("Could not add splash view");
            return false;
        }

        splashView.setAlpha(0f);
        splashView.setVisibility(View.VISIBLE);

        splashView.animate()
                .alpha(1f)
                .setInterpolator(new LinearInterpolator())
                .setDuration(options.fadeInDuration)
                .setListener(listener);

        return true;
    }

    private static void fadeSpinnerIn(WindowManager.LayoutParams params, ShowOptions options) {
        params.height = WindowManager.LayoutParams.WRAP_CONTENT;
        params.width = WindowManager.LayoutParams.WRAP_CONTENT;

        wm.addView(spinner, params);
        spinner.setAlpha(0f);
        spinner.setVisibility(View.VISIBLE);

        spinner.animate()
                .alpha(1f)
                .setInterpolator(new LinearInterpolator())
                .setDuration(options.fadeInDuration);
    }

    private static Animator.AnimatorListener makeShowAnimationListener(
            final Activity activity,
            final ShowOptions options,
            final Plugin plugin,
            final PluginCall call
    ) {
        return new Animator.AnimatorListener() {
            @Override
            public void onAnimationEnd(Animator animator) {
                isVisible = true;

                // If the splash is animated, return immediately after fading in
                long delay = options.animated ? 0 : options.showDuration;

                new Handler().postDelayed(() -> {
                    if (options.autoHide) {
                        // Warn the user if the launch splash was hidden automatically,
                        // which means they could be experiencing an app
                        // that feels slower than it actually is.
                        if (options.isLaunchSplash) {
                            String pluginId = plugin.getPluginHandle().getId();
                            Logger.debug("The splash screen was automatically hidden after " + options.showDuration + " ms." +
                                    " We recommend that you call " + pluginId + ".hide() as soon as your web app is loaded instead." +
                                    " Read more at https://capacitorjs.com/docs/apis/splash-screen#hiding-the-splash-screen");
                        }

                        HideOptions hideOptions = new HideOptions(plugin, call);
                        Splash.hide(activity, call, hideOptions);
                    }

                    if (call != null) {
                        call.success();
                    }
                }, delay);

            }

            @Override
            public void onAnimationCancel(Animator animator) {
            }

            @Override
            public void onAnimationRepeat(Animator animator) {
            }

            @Override
            public void onAnimationStart(Animator animator) {
            }
        };
    }

    /**
     * Hide the splash screen with the given options
     */
    public static void hide(Context context, final PluginCall call, final HideOptions options) {
        // If we're already hiding or autoHide is on, do nothing
        if (isHiding) {
            return;
        }

        // If the splashView has not been created, complain and return, there is nothing to hide
        if (splashView == null) {
            noSplashAvailable(call);
            return;
        }

        isHiding = true;

        final Animator.AnimatorListener listener = new Animator.AnimatorListener() {
            private void done() {
                tearDown();

                if (call != null) {
                    call.success();
                }
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
            }

            @Override
            public void onAnimationRepeat(Animator animator) {
            }
        };

        Handler mainHandler = new Handler(context.getMainLooper());

        mainHandler.postDelayed(() -> {
            if (spinner != null) {
                spinner.animate()
                        .alpha(0)
                        .setInterpolator(new LinearInterpolator())
                        .setDuration(options.fadeOutDuration);
            }

            splashView.animate()
                    .alpha(0)
                    .setInterpolator(new LinearInterpolator())
                    .setDuration(options.fadeOutDuration)
                    .setListener(listener);
        }, options.delay);
    }

    public static void animate(Activity activity, Plugin plugin, PluginCall call) {
        class Resolver implements Runnable {
            final PluginCall call;

            Resolver(PluginCall call) {
                this.call = call;
            }

            @Override
            public void run() {
                Splash.tearDown();

                if (call != null) {
                    call.success();
                }
            }
        }

        Handler mainHandler = new Handler(activity.getMainLooper());
        int delay = toMilliseconds(call.getDouble("delay", 0.0));

        mainHandler.postDelayed(() -> {
            try {
                Method method = activity.getClass().getMethod("animateSplashScreen", HashMap.class);
                HashMap<String, Object> params = new HashMap<>();
                params.put("plugin", plugin);
                params.put("splashView", splashView);
                params.put("spinner", spinner);
                params.put("options", call.getData());
                params.put("resolve", new Resolver(call));
                method.invoke(activity, params);

            } catch (NoSuchMethodException ex) {
                call.reject("The method animateSplashScreen(Object) is not defined in the main activity class",
                        Splash.ErrorType.ANIMATE_METHOD_NOT_FOUND.name());

            } catch (IllegalAccessException | InvocationTargetException ex) {
                call.reject("The call to animateSplashScreen(Object) failed",
                        Splash.ErrorType.ANIMATE_METHOD_NOT_FOUND.name());
            }
        }, delay);
    }

    private static void addSplashView(Activity activity, View view, ViewGroup.LayoutParams params) {
        // If we are in fullscreen mode, adding the view to the WindowManager will cover
        // the status bar, which is then fullscreen. When we are not in fullscreen mode,
        // We need to use addContentView() to ensure it does not cover the status bar.
        if (isFullscreen) {
            wm.addView(view, params);
        } else {
            activity.getWindow().addContentView(view, params);
        }
    }

    private static void removeView(View view) {
        if (isFullscreen) {
            wm.removeView(view);
        } else {
            ViewGroup parent = (ViewGroup) view.getParent();

            if (parent != null) {
                parent.removeView(view);
            }
        }
    }

    private static void tearDown() {
        if (spinner != null) {
            spinner.setVisibility(View.GONE);

            if (showOptions.showSpinner) {
                wm.removeView(spinner);
            }
        }

        if (splashView != null) {
            splashView.setVisibility(View.GONE);
            removeView(splashView);
        }

        isHiding = false;
        isVisible = false;
    }

    public static void onPause() {
        // Don't remove the splash, we may want it to be there when we resume
    }

    public static void onDestroy() {
        tearDown();
    }

    public static void noSplashAvailable(PluginCall call) {
        call.reject("No splash screen view is available", Splash.ErrorType.NO_SPLASH.name());
    }

    public static boolean getAutoHide() {
        return showOptions.autoHide;
    }

    public enum ErrorType {
        NO_SPLASH("noSplash"),
        ANIMATE_METHOD_NOT_FOUND("animateMethodNotFound"),
        ANIMATE_METHOD_FAILED("animateMethodFailed");

        private final String code;

        ErrorType(String code) {
            this.code = code;
        }

        public String getCode() {
            return this.code;
        }
    }

    public interface Completion {

    }

    public interface SplashListener {
        void completed();

        void error();
    }

    public static class ShowOptions {
        public int showDuration;
        public int fadeInDuration;
        public int fadeOutDuration;
        public boolean autoHide;
        public String backgroundColor;
        public boolean animated;
        public boolean showSpinner;
        public boolean isLaunchSplash;

        public ShowOptions(Plugin plugin, PluginCall call, Boolean isLaunchSplash) {
            Config config = Config.getInstance(plugin);
            showDuration = toMilliseconds(config.getDouble("showDuration", call, DEFAULT_SHOW_DURATION));
            fadeInDuration = toMilliseconds(config.getDouble("fadeInDuration", call, DEFAULT_FADE_IN_DURATION));
            fadeOutDuration = toMilliseconds(config.getDouble("fadeOutDuration", call, DEFAULT_FADE_OUT_DURATION));
            backgroundColor = config.getString("backgroundColor", call);
            animated = config.getBoolean("animate", call, DEFAULT_ANIMATE);

            // If the splash is marked as animated, it's up to the dev to hide the splash
            if (animated) {
                autoHide = false;
            } else {
                autoHide = config.getBoolean("autoHide", call, DEFAULT_AUTO_HIDE);
            }

            showSpinner = config.getBoolean("showSpinner", call, DEFAULT_SHOW_SPINNER);
            this.isLaunchSplash = isLaunchSplash;
        }

        @SuppressLint("DefaultLocale")
        @NonNull
        @Override
        public String toString() {
            return String.format(
                    "ShowOptions {\nshowDuration = %d,\nfadeInDuration = %d,\nfadeOutDuration = %d,\nbackgroundColor = %s,\nanimated = %b,\nautoHide = %b,\nshowSpinner = %b,\nisLaunchSplash = %b }",
                    showDuration,
                    fadeInDuration,
                    fadeOutDuration,
                    backgroundColor,
                    animated,
                    autoHide,
                    showSpinner,
                    isLaunchSplash);
        }
    }

    public static class HideOptions {
        public int delay;
        public int fadeOutDuration;

        public HideOptions(Plugin plugin, PluginCall call) {
            Config config = Config.getInstance(plugin);
            delay = toMilliseconds(config.getDouble("delay", call, 0));
            fadeOutDuration = toMilliseconds(config.getDouble("fadeOutDuration", call, DEFAULT_FADE_OUT_DURATION));
        }

        @SuppressLint("DefaultLocale")
        @NonNull
        @Override
        public String toString() {
            return String.format("HideOptions { delay = %d, fadeOutDuration = %d }", delay, fadeOutDuration);
        }
    }
}
