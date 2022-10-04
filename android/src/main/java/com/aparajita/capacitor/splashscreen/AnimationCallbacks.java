package com.aparajita.capacitor.splashscreen;

import android.animation.TimeInterpolator;

public interface AnimationCallbacks {
  void done();

  void error(String message, SplashScreen.ErrorType code);

  void showStatusBar(long delay, long duration, TimeInterpolator interpolator);

  void showNavigationBar(
    long delay,
    long duration,
    TimeInterpolator interpolator
  );
}
