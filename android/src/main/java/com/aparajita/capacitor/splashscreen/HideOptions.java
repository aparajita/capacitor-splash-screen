package com.aparajita.capacitor.splashscreen;

import androidx.annotation.NonNull;
import com.getcapacitor.JSObject;
import java.util.Locale;

public class HideOptions {

  public int delay;
  public int fadeOutDuration;

  public HideOptions(@NonNull JSObject options, @NonNull Config config) {
    delay =
      SplashScreen.toMilliseconds(
        config.getDoubleOption(Options.DELAY, options, 0.0)
      );
    fadeOutDuration =
      SplashScreen.toMilliseconds(
        config.getDoubleOption(
          Options.FADE_OUT_DURATION,
          options,
          Options.DEFAULT_FADE_OUT_DURATION
        )
      );
  }

  @NonNull
  @Override
  public String toString() {
    return String.format(
      Locale.getDefault(),
      "HideOptions { delay = %d, fadeOutDuration = %d }",
      delay,
      fadeOutDuration
    );
  }
}
