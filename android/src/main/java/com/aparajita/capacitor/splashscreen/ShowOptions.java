package com.aparajita.capacitor.splashscreen;

import androidx.annotation.NonNull;
import com.getcapacitor.JSObject;
import java.util.Locale;

public class ShowOptions {

  public String source;
  public int delay;
  public int fadeInDuration;
  public int showDuration;

  // NOTE: ShowOptions are not used at launch, all launch config is retrieved
  // from the launch theme.

  // Call to show()
  public ShowOptions(@NonNull JSObject options, @NonNull Config config) {
    source =
      config.getStringOption(Options.SOURCE, options, Options.DEFAULT_SOURCE);
    delay =
      SplashScreen.toMilliseconds(
        config.getDoubleOption(Options.DELAY, options, 0.0)
      );
    showDuration =
      SplashScreen.toMilliseconds(
        config.getDoubleOption(
          Options.SHOW_DURATION,
          options,
          Options.DEFAULT_SHOW_DURATION
        )
      );
    fadeInDuration =
      SplashScreen.toMilliseconds(
        config.getDoubleOption(
          Options.FADE_IN_DURATION,
          options,
          Options.DEFAULT_FADE_IN_DURATION
        )
      );
  }

  @NonNull
  @Override
  public String toString() {
    return String.format(
      Locale.getDefault(),
      "ShowOptions {\nsource = %s\ndelay = %d,\nshowDuration = %d,\nfadeInDuration = %d\n}",
      source,
      delay,
      showDuration,
      fadeInDuration
    );
  }
}
