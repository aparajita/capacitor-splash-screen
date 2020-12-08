package com.aparajita.capacitor.splashscreen;

import android.animation.Animator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.drawable.Animatable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Handler;
import android.view.Gravity;
import android.view.InflateException;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import androidx.annotation.NonNull;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;

@NativePlugin
public class WSSplashScreen extends Plugin {

    private static final Integer DEFAULT_FADE_IN_DURATION = 200;
    private static final Integer DEFAULT_FADE_OUT_DURATION = 200;
    private static final Integer DEFAULT_SHOW_DURATION = 3000;
    private static final Boolean DEFAULT_AUTO_HIDE = false;
    private static final Boolean DEFAULT_ANIMATED = false;
    private static final Boolean DEFAULT_SHOW_SPINNER = false;
    private static final Boolean DEFAULT_FULLSCREEN_MODE = false;
    private static final String SOURCE_OPTION = "source";
    private static final String DELAY_OPTION = "delay";
    private static final String FADE_IN_OPTION = "fadeInDuration";
    private static final String DURATION_OPTION = "showDuration";
    private static final String FADE_OUT_OPTION = "fadeOutDuration";
    private static final String AUTO_HIDE_OPTION = "autoHide";
    private static final String ANIMATED_OPTION = "animated";
    private static final String START_ALPHA_OPTION = "startAlpha";
    private static final String BACKGROUND_OPTION = "backgroundColor";
    private static final String SHOW_SPINNER_OPTION = "showSpinner";
    private static final String SPINNER_COLOR_OPTION = "spinnerColor";
    private static final String SPINNER_STYLE_OPTION = "androidSpinnerStyle";
    private static final String FULLSCREEN_OPTION = "androidFullscreen";
    private static final String IMAGE_MODE_OPTION = "androidImageDisplayMode";
    private static final String logTag = "Splash";
    private static final HashMap<String, ImageView.ScaleType> displayModeMap;
    private static final HashMap<String, Integer> spinnerStyleMap;

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
        spinnerStyleMap.put("small", android.R.attr.progressBarStyleSmall);
        spinnerStyleMap.put("smallinverse", android.R.attr.progressBarStyleSmallInverse);
        spinnerStyleMap.put("medium", android.R.attr.progressBarStyle);
        spinnerStyleMap.put("mediuminverse", android.R.attr.progressBarStyleInverse);
        spinnerStyleMap.put("large", android.R.attr.progressBarStyleLarge);
        spinnerStyleMap.put("largeinverse", android.R.attr.progressBarStyleLargeInverse);
        spinnerStyleMap.put("horizontal", android.R.attr.progressBarStyleHorizontal);
    }

    private final Logger logger = new Logger();
    private final String tag = getLogTag();
    private Config config;
    private String lastSource = "";
    private View splashView;
    private Drawable splashImage;
    private ProgressBar spinner;
    private Method eventHandler;
    private WindowManager wm;
    private ShowOptions showOptions;
    private boolean isHiding = false;
    private boolean isVisible = false;
    private boolean isFullscreen = DEFAULT_FULLSCREEN_MODE;

    private boolean isDarkMode() {
        int mode = getContext().getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK;
        return mode == Configuration.UI_MODE_NIGHT_YES;
    }

    @Override
    public void load() {
        config = Config.getInstance(this);
        logger.setLogLevel(Logger.LogLevel.info);

        // See if the splash screen event handler is defined, if so we might as well cache it
        try {
            eventHandler = getActivity().getClass().getMethod("onSplashScreenEvent", String.class, HashMap.class);
        } catch (NoSuchMethodException e) {
            // ignore
        }

        showOnLaunch(config);
    }

    public Config getConfig() {
        return config;
    }

    @PluginMethod
    public void nativeShow(final PluginCall call) {
        ShowOptions options = new ShowOptions(this, call, false);
        logger.debug(tag, options.toString());
        show(call, options, config);
    }

    @PluginMethod
    public void nativeHide(PluginCall call) {
        if (splashView == null) {
            call.reject("No splash screen view is available", ErrorType.NO_SPLASH.getCode());
            return;
        }

        // If autoHide is on, don't do anything
        if (!getAutoHide()) {
            HideOptions options = new HideOptions(this, call);
            hide(getContext(), call, options);
        }
    }

    @PluginMethod
    public void nativeAnimate(PluginCall call) {
        if (splashView == null) {
            call.reject("No splash screen view is available", ErrorType.NO_SPLASH.getCode());
            return;
        }

        callHook(HookEventType.animate, call);
    }

    public void showOnLaunch(final Config config) {
        int showDuration = config.getIntOption(DURATION_OPTION, null, DEFAULT_SHOW_DURATION);

        if (showDuration == 0) {
            logger.info(logTag, "showDuration = 0, splash screen disabled");
        } else {
            ShowOptions options = new ShowOptions(this, null, true);
            logger.debug(logTag, options.toString());
            show(null, options, config);
        }
    }

    public void show(final PluginCall call, final ShowOptions options, final Config config) {
        showOptions = options;

        Activity activity = getActivity();
        wm = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);

        // If the splash is in the midst of hiding, wait for that to finish
        if (activity.isFinishing()) {
            return;
        }

        // If the splash is already visible, return to the caller
        if (isVisible) {
            if (call != null) {
                call.resolve();
            }

            return;
        }

        buildViews(activity, options, call, config);
        configureSplashView(call, config);

        if (splashView != null) {
            final Animator.AnimatorListener listener = makeShowAnimationListener(activity, options, call);
            final Handler mainHandler = new Handler(activity.getMainLooper());
            mainHandler.post(makeRunner(activity, call, options, listener));
        }
    }

    private int parseColor(String color) {
        if (color.isEmpty()) {
            return 0;
        }

        switch (color) {
            case "systemBackground":
                // TODO: Get the background from the app theme
                return 0xffffffff; // white
            case "systemText":
                // TODO: Get the text color from the app theme
                return 0xff000000; // black
        }

        // Color.parseColor() reads colors as ARGB instead of RGBA, which is the CSS standard. Brilliant!
        // So we have to move the alpha value if it exists. Also, if the color does not have a "#" prefix
        // (which is allowed on iOS), add it, because parseColor() expects it.
        if (color.length() > 1) {
            if (color.charAt(0) == '#') {
                color = color.substring(1);
            }

            switch (color.length()) {
                // If the length is 3 or 4, assume it's RGB[A], convert to RRGGBB[AA]
                case 3:
                case 4:
                    StringBuilder rgb = new StringBuilder();

                    for (int i = 0; i < color.length(); i++) {
                        String ch = color.substring(i, i + 1);
                        rgb.append(ch).append(ch);
                    }

                    color = rgb.toString();
                    break;
            }

            if (color.length() == 8) {
                // If the length is 8, assume it's RRGGBBAA
                color = color.substring(6) + color.substring(0, 6);
            }

            color = "#" + color;
        }

        return Color.parseColor(color);
    }

    private void buildViews(Context context, ShowOptions options, PluginCall call, Config config) {
        // Allow the default legacy behavior of using a resource called "Splash".
        String source = "splash";

        // See if the user specified a source, that takes precedence
        String sourceOption = config.getStringOption(SOURCE_OPTION, call);

        if (sourceOption != null && !sourceOption.isEmpty()) {
            source = sourceOption;
        }

        boolean found = false;
        String error = "";

        // If the splash source has not changed, no need to rebuild it
        if (!source.equals(lastSource)) {
            lastSource = source;
            splashView = null;

            try {
                if (source.equals("*")) {
                    checkForLayout("launch_screen", context);
                } else {
                    found = checkForImage(source, context);

                    if (!found) {
                        checkForLayout(source, context);
                    }
                }
            } catch (Exception e) {
                error = e.getMessage();
            }
        }

        if (splashView == null) {
            String message = error.isEmpty() ? String.format("No splash image or layout named \"%s\" found", source) : error;

            if (call != null) {
                ErrorType code = error.isEmpty() ? ErrorType.NOT_FOUND : ErrorType.NO_SPLASH;
                call.reject(message, code.getCode());
                return;
            }

            logger.warn(logTag, message);
        }

        if (options.showSpinner) {
            makeSpinner(context, call, config);
        }
    }

    @SuppressLint("UseCompatLoadingForDrawables")
    private boolean checkForImage(String resourceName, Context context) {
        try {
            int imageId = getResourceId(context, resourceName, "drawable");
            splashImage = context.getResources().getDrawable(imageId, context.getTheme());
            splashView = new ImageView(context);
            logger.info(logTag, "Using image \"" + resourceName + "\"");
            return true;
        } catch (Resources.NotFoundException ex) {
            return false;
        }
    }

    private void checkForLayout(String layoutName, Context context) throws InflateException {
        Activity activity = (Activity) context;
        int layoutId = getResourceId(context, layoutName, "layout");

        if (layoutId != 0) {
            // Inflate the layout and add it to the root view
            LayoutInflater inflator = activity.getLayoutInflater();
            ViewGroup root = new FrameLayout(context);
            root.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            splashView = inflator.inflate(layoutId, root, false);
            logger.info(logTag, "Using layout \"" + layoutName + "\"");
        }
    }

    private int getResourceId(Context context, String resourceName, String type) {
        return context.getResources().getIdentifier(resourceName, type, context.getPackageName());
    }

    private void setBackgroundColor(Config config, PluginCall call) {
        // Clear any existing background color by setting it to transparent black
        splashView.setBackgroundColor(0);
        String backgroundColor = config.getStringOption(BACKGROUND_OPTION, call);

        try {
            if (backgroundColor != null) {
                splashView.setBackgroundColor(parseColor(backgroundColor));
            }
        } catch (IllegalArgumentException ex) {
            logger.debug(logTag, "Background color '" + backgroundColor + "' not applied");
        }
    }

    private void setScaleType(ImageView image, Config config, PluginCall call) {
        ImageView.ScaleType scaleType = displayModeMap.get("fit");
        String displayModeName = config.getStringOption(IMAGE_MODE_OPTION, call);

        if (displayModeName != null) {
            ImageView.ScaleType mode = displayModeMap.get(displayModeName.toLowerCase());

            if (mode != null) {
                scaleType = mode;
            }
        }

        image.setScaleType(scaleType);
    }

    private void startAnimation() {
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

    private void makeSpinner(Context context, PluginCall call, Config config) {
        String spinnerStyle = config.getStringOption(SPINNER_STYLE_OPTION, call);

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
        String spinnerColor = config.getStringOption(SPINNER_COLOR_OPTION, call);

        if (spinnerColor != null) {
            try {
                int[][] states = new int[][] {
                    new int[] { android.R.attr.state_enabled }, // enabled
                    new int[] { -android.R.attr.state_enabled }, // disabled
                    new int[] { -android.R.attr.state_checked }, // unchecked
                    new int[] { android.R.attr.state_pressed } // pressed
                };
                int spinnerBarColor = parseColor(spinnerColor);
                int[] colors = new int[] { spinnerBarColor, spinnerBarColor, spinnerBarColor, spinnerBarColor };
                ColorStateList colorStateList = new ColorStateList(states, colors);
                spinner.setIndeterminateTintList(colorStateList);
            } catch (IllegalArgumentException ex) {
                logger.debug(logTag, "Spinner color '" + spinnerColor + "' not applied");
            }
        }
    }

    private void configureSplashView(PluginCall call, Config config) {
        if (splashView == null) {
            return;
        }

        splashView.setFitsSystemWindows(true);

        // Make sure the splash does not move if the status bar appears/disappears
        splashView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
        setBackgroundColor(config, call);

        if (splashView instanceof ImageView) {
            ImageView image = (ImageView) splashView;

            // Stops flickers dead in their tracks
            // https://stackoverflow.com/a/21847579/32140
            image.setDrawingCacheEnabled(true);
            image.setImageDrawable(splashImage);
            setScaleType(image, config, call);
            startAnimation();
        }

        isFullscreen = config.getBooleanOption(FULLSCREEN_OPTION, call, DEFAULT_FULLSCREEN_MODE);
    }

    private Runnable makeRunner(
        final Activity activity,
        PluginCall call,
        final ShowOptions options,
        final Animator.AnimatorListener listener
    ) {
        return () -> {
            WindowManager.LayoutParams params = new WindowManager.LayoutParams();
            params.flags = activity.getWindow().getAttributes().flags;
            params.gravity = Gravity.CENTER;

            // Required to enable the view to actually fade
            params.format = PixelFormat.TRANSLUCENT;

            if (!fadeInSplashView(params, activity, call, options, listener)) {
                return;
            }

            if (spinner != null && options.showSpinner) {
                fadeInSpinner(params, options);
            }
        };
    }

    private boolean fadeInSplashView(
        WindowManager.LayoutParams params,
        Activity activity,
        PluginCall call,
        ShowOptions options,
        Animator.AnimatorListener listener
    ) {
        try {
            addSplashView(activity, splashView, params);
        } catch (IllegalStateException | IllegalArgumentException ex) {
            logger.error(logTag, "Could not add splash view");
            return false;
        }

        splashView.setAlpha(options.startAlpha);
        callBeforeShowHook(call);
        splashView.setVisibility(View.VISIBLE);
        splashView.animate().alpha(1f).setInterpolator(new LinearInterpolator()).setDuration(options.fadeInDuration).setListener(listener);

        return true;
    }

    private void callBeforeShowHook(PluginCall call) {
        callHook(HookEventType.beforeShow, call);
    }

    private void fadeInSpinner(WindowManager.LayoutParams params, ShowOptions options) {
        params.height = WindowManager.LayoutParams.WRAP_CONTENT;
        params.width = WindowManager.LayoutParams.WRAP_CONTENT;

        // We add the spinner to the window manager because otherwise it won't be centered
        // unless we make Herculean efforts to figure out the type of content view container
        // and place it accordingly. No thanks! Use a layout with a spinner, that's much better.
        wm.addView(spinner, params);
        spinner.setAlpha(options.startAlpha);
        spinner.setVisibility(View.VISIBLE);

        spinner.animate().alpha(1f).setInterpolator(new LinearInterpolator()).setDuration(options.fadeInDuration);
    }

    private Animator.AnimatorListener makeShowAnimationListener(final Activity activity, final ShowOptions options, final PluginCall call) {
        Plugin plugin = this;

        return new Animator.AnimatorListener() {
            @Override
            public void onAnimationEnd(Animator animator) {
                isVisible = true;

                // If the splash is animated, return immediately after fading in
                long delay = options.animated ? 0 : options.showDuration;

                new Handler()
                .postDelayed(
                        () -> {
                            if (options.autoHide) {
                                HideOptions hideOptions = new HideOptions(plugin, call);
                                hide(activity, call, hideOptions);
                            }

                            if (call != null) {
                                call.resolve();
                            }
                        },
                        delay
                    );
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
    public void hide(Context context, final PluginCall call, final HideOptions options) {
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
                    call.resolve();
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
            public void onAnimationStart(Animator animator) {}

            @Override
            public void onAnimationRepeat(Animator animator) {}
        };

        Handler mainHandler = new Handler(context.getMainLooper());

        mainHandler.postDelayed(
            () -> {
                if (spinner != null) {
                    spinner.animate().alpha(0).setInterpolator(new LinearInterpolator()).setDuration(options.fadeOutDuration);
                }

                splashView
                    .animate()
                    .alpha(0)
                    .setInterpolator(new LinearInterpolator())
                    .setDuration(options.fadeOutDuration)
                    .setListener(listener);
            },
            options.delay
        );
    }

    public void callHook(HookEventType eventType, PluginCall call) {
        if (eventHandler == null) {
            return;
        }

        Activity activity = getActivity();
        Handler mainHandler = new Handler(activity.getMainLooper());
        int delay = call != null ? call.getInt(DELAY_OPTION, 0) : 0;

        mainHandler.postDelayed(
            () -> {
                try {
                    HashMap<String, Object> params = makeHookParams(eventType, call);
                    eventHandler.invoke(activity, eventType.name(), params);
                } catch (IllegalAccessException | InvocationTargetException ex) {
                    if (call != null) {
                        call.reject("The call to onSplashScreenEvent() failed", ErrorType.HOOK_METHOD_FAILED.name());
                    }
                }
            },
            delay
        );
    }

    private HashMap<String, Object> makeHookParams(HookEventType eventType, PluginCall call) {
        // Animation needs to call this callback when done to resolve the plugin call
        class DoneCallback implements Runnable {

            final PluginCall call;

            DoneCallback(PluginCall call) {
                this.call = call;
            }

            @Override
            public void run() {
                tearDown();

                if (this.call != null) {
                    this.call.resolve();
                }
            }
        }

        HashMap<String, Object> params = new HashMap<>();
        params.put("plugin", this);
        params.put("splashView", splashView);
        params.put("spinner", spinner);

        if (call != null) {
            params.put("options", call.getData());
        }

        if (eventType == HookEventType.animate) {
            params.put("done", new DoneCallback(call));
        }

        return params;
    }

    private void addSplashView(Activity activity, View view, ViewGroup.LayoutParams params) {
        // If we are in fullscreen mode, adding the view to the WindowManager will cover
        // the status bar, which is then fullscreen. When we are not in fullscreen mode,
        // We need to use addContentView() to ensure it does not cover the status bar.
        if (isFullscreen) {
            wm.addView(view, params);
        } else {
            activity.getWindow().addContentView(view, params);
        }
    }

    private void removeView(View view) {
        if (isFullscreen) {
            wm.removeView(view);
        } else {
            ViewGroup parent = (ViewGroup) view.getParent();

            if (parent != null) {
                parent.removeView(view);
            }
        }
    }

    private void tearDown() {
        if (spinner != null) {
            spinner.setVisibility(View.GONE);

            if (showOptions.showSpinner) {
                wm.removeView(spinner);
            }

            spinner = null;
        }

        if (splashView != null) {
            splashView.setVisibility(View.GONE);
            removeView(splashView);
        }

        isHiding = false;
        isVisible = false;
        callAfterShowHook();
    }

    private void callAfterShowHook() {
        callHook(HookEventType.afterShow, null);
    }

    public void onPause() {
        // Don't remove the splash, we may want it to be there when we resume
    }

    public void onDestroy() {
        tearDown();
    }

    public void noSplashAvailable(PluginCall call) {
        call.reject("No splash screen view is available", ErrorType.NO_SPLASH.name());
    }

    public boolean getAutoHide() {
        return showOptions.autoHide;
    }

    enum HookEventType {
        beforeShow,
        afterShow,
        animate
    }

    public enum ErrorType {
        NOT_FOUND("notFound"),
        NO_SPLASH("noSplash"),
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

    public interface Completion {}

    public interface SplashListener {
        void completed();

        void error();
    }

    public static class ShowOptions {

        public float startAlpha;
        public int fadeInDuration;
        public int showDuration;
        public int fadeOutDuration;
        public boolean autoHide;
        public String backgroundColor;
        public boolean animated;
        public boolean showSpinner;
        public boolean isLaunchSplash;

        public ShowOptions(Plugin plugin, PluginCall call, Boolean isLaunchSplash) {
            Config config = Config.getInstance(plugin);
            startAlpha = config.getFloatOption(START_ALPHA_OPTION, call, 0f);
            fadeInDuration = config.getIntOption(FADE_IN_OPTION, call, DEFAULT_FADE_IN_DURATION);
            showDuration = config.getIntOption(DURATION_OPTION, call, DEFAULT_SHOW_DURATION);
            fadeOutDuration = config.getIntOption(FADE_OUT_OPTION, call, DEFAULT_FADE_OUT_DURATION);
            backgroundColor = config.getStringOption(BACKGROUND_OPTION, call);
            animated = config.getBooleanOption(ANIMATED_OPTION, call, DEFAULT_ANIMATED);

            // If the splash is marked as animated, it's up to the dev to hide the splash
            if (animated) {
                autoHide = false;
            } else {
                autoHide = config.getBooleanOption(AUTO_HIDE_OPTION, call, DEFAULT_AUTO_HIDE);
            }

            showSpinner = config.getBooleanOption(SHOW_SPINNER_OPTION, call, DEFAULT_SHOW_SPINNER);
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
                isLaunchSplash
            );
        }
    }

    public static class HideOptions {

        public int delay;
        public int fadeOutDuration;

        public HideOptions(Plugin plugin, PluginCall call) {
            Config config = Config.getInstance(plugin);
            delay = config.getIntOption(DELAY_OPTION, call, 0);
            fadeOutDuration = config.getIntOption(FADE_OUT_OPTION, call, DEFAULT_FADE_OUT_DURATION);
        }

        @SuppressLint("DefaultLocale")
        @NonNull
        @Override
        public String toString() {
            return String.format("HideOptions { delay = %d, fadeOutDuration = %d }", delay, fadeOutDuration);
        }
    }
}
