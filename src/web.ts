import {
  AppPlugin,
  AppState,
  Plugins,
  registerWebPlugin,
  WebPlugin,
} from '@capacitor/core';
import {
  WSSplashScreenAnimateOptions,
  WSSplashScreenAppStateOptions,
  WSSplashScreenHideOptions,
  WSSplashScreenPlugin,
  WSSplashScreenShowOptions,
} from './definitions';

export class WSSplashScreenWeb
  extends WebPlugin
  implements WSSplashScreenPlugin {
  private static shouldListenToAppState = false;
  private static listening = false;

  constructor() {
    super({
      name: 'WSSplashScreen',
      platforms: ['web'],
    });
  }

  static listenToAppState(listen: false): void;

  static listenToAppState(
    listen: true,
    options: WSSplashScreenAppStateOptions,
  ): void;

  static listenToAppState(
    listen: boolean,
    options?: WSSplashScreenAppStateOptions,
  ) {
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

  static hideOnAppLoaded(options?: WSSplashScreenHideOptions) {
    const splashscreen = Plugins.WSSplashScreen as WSSplashScreenWeb;
    this.onAppLoaded(splashscreen.hide, options);
  }

  static animateOnAppLoaded(options?: WSSplashScreenAnimateOptions) {
    const splashscreen = Plugins.WSSplashScreen as WSSplashScreenWeb;
    this.onAppLoaded(splashscreen.animate, options);
  }

  private static onAppLoaded(
    action: (
      options?: WSSplashScreenShowOptions | WSSplashScreenAnimateOptions,
    ) => void,
    options?: WSSplashScreenShowOptions | WSSplashScreenAnimateOptions,
  ) {
    document.addEventListener('DOMContentLoaded', async () => {
      try {
        await action(options);
      } catch (e) {
        console.error(e.message);
      }
    });
  }

  show(_options?: WSSplashScreenShowOptions): Promise<void> {
    return Promise.resolve();
  }

  hide(_options?: WSSplashScreenHideOptions): Promise<void> {
    return Promise.resolve();
  }

  animate(_options?: WSSplashScreenAnimateOptions): Promise<void> {
    return Promise.resolve();
  }
}

const WSSplashScreen = new WSSplashScreenWeb();

export { WSSplashScreen };

registerWebPlugin(WSSplashScreen);
