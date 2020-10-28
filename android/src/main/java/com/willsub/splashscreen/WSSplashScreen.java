package com.willsub.splashscreen;

import com.getcapacitor.*;

@NativePlugin()
public class WSSplashScreen extends Plugin {
    private Config config;

    @Override
    public void load() {
        config = Config.getInstance(this);
        // TODO setLogLevel()
        Splash.showOnLaunch(this, config);
    }

    public Config getConfig() {
        return config;
    }

    @PluginMethod()
    public void show(final PluginCall call) {
        Splash.ShowOptions options = new Splash.ShowOptions(this, call, false);
        Logger.debug(options.toString());
        Splash.show(this, call, options, config);
    }

    @PluginMethod()
    public void hide(PluginCall call) {
        // If autoHide is on, don't do anything
        if (!Splash.getAutoHide()) {
            Splash.HideOptions options = new Splash.HideOptions(this, call);
            Splash.hide(getContext(), call, options);
        }
    }

    @PluginMethod()
    public void animate(PluginCall call) {
        Splash.animate(getActivity(), this, call);
    }
}
