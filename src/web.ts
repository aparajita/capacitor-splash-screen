import {
  AppPlugin,
  AppState,
  Plugins,
  registerWebPlugin,
  WebPlugin,
} from '@capacitor/core';
import { native } from 'ws-capacitor-native-decorator';
import {
  WSSplashScreenAnimateOptions,
  WSSplashScreenAppStateOptions,
  WSSplashScreenDuration,
  WSSplashScreenHideOptions,
  WSSplashScreenPlugin,
  WSSplashScreenShowOptions,
} from './definitions';

// The threshold beyond which durations are considered milliseconds
const kDurationMsThreshold = 10;

export class WSSplashScreenWeb
  extends WebPlugin
  implements WSSplashScreenPlugin {
  private shouldListenToAppState = false;
  private listening = false;

  constructor() {
    super({
      name: 'WSSplashScreen',
      platforms: ['web', 'ios', 'android'],
    });
  }

  listenToAppState(listen: false): void;

  listenToAppState(listen: true, options: WSSplashScreenAppStateOptions): void;

  listenToAppState(listen: boolean, options?: WSSplashScreenAppStateOptions) {
    this.shouldListenToAppState = listen;

    if (listen && !this.listening) {
      this.listening = true;
      const app = Plugins.App as AppPlugin;

      app.addListener('appStateChange', async (state: AppState) => {
        if (this.shouldListenToAppState) {
          if (state.isActive) {
            await options?.onResume?.();
          } else {
            await options?.onSuspend?.();
          }
        }
      });
    }
  }

  show(options?: WSSplashScreenShowOptions): Promise<void> {
    return this.showHide('show', options);
  }

  hide(options?: WSSplashScreenShowOptions): Promise<void> {
    return this.showHide('hide', options);
  }

  animate(options?: WSSplashScreenAnimateOptions): Promise<void> {
    if (options && options.delay) {
      const { delay, ...opts } = options;

      return new Promise(resolve => {
        setTimeout(() => {
          this.nativeAnimate(opts).then(() => resolve());
        }, this.toMilliseconds(delay));
      });
    }

    return this.nativeAnimate(options);
  }

  @native()
  nativeAnimate(_options?: WSSplashScreenAnimateOptions): Promise<void> {
    return Promise.resolve();
  }

  @native()
  private nativeShow(_options?: WSSplashScreenShowOptions): Promise<void> {
    return Promise.resolve();
  }

  @native()
  private nativeHide(_options?: WSSplashScreenHideOptions): Promise<void> {
    return Promise.resolve();
  }

  private showHide(
    action: 'show' | 'hide',
    options?: WSSplashScreenShowOptions | WSSplashScreenHideOptions,
  ): Promise<void> {
    const method = action === 'show' ? this.nativeShow : this.nativeHide;
    let modifiedOptions:
      | WSSplashScreenShowOptions
      | WSSplashScreenHideOptions = {};
    let preDelay = this.toMilliseconds(options?.delay || 0);

    if (options) {
      // Copy the options as a generic hash so they can be modified, and remove the delay property
      let { delay, ...opts } = options as { [key: string]: any };

      // Convert durations to milliseconds
      Object.keys(opts)
        .filter(key => key.endsWith('Duration'))
        .forEach(key => {
          opts[key] = this.toMilliseconds(opts[key]);
        });

      modifiedOptions =
        action === 'show'
          ? (opts as WSSplashScreenShowOptions)
          : (opts as WSSplashScreenHideOptions);
    }

    // To prevent the native plugin from blocking the main thread (I'm looking at you, Android),
    // perform any pre-show/hide delay in the JS world.
    if (preDelay > 0) {
      return new Promise(resolve => {
        setTimeout(() => {
          method.call(this, modifiedOptions).then(() => resolve());
        }, this.toMilliseconds(preDelay));
      });
    }

    return method.call(this, modifiedOptions);
  }

  toMilliseconds(value: WSSplashScreenDuration): WSSplashScreenDuration {
    return value >= kDurationMsThreshold ? value : value * 1000;
  }
}

const WSSplashScreen = new WSSplashScreenWeb();

export { WSSplashScreen };

registerWebPlugin(WSSplashScreen);
