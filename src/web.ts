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
  WSSplashScreenPlugin,
  WSSplashScreenShowOptions,
} from './definitions';

let shouldListenToAppState = false;
let listening = false;

export class WSSplashScreenWeb
  extends WebPlugin
  implements WSSplashScreenPlugin {
  constructor() {
    super({
      name: 'WSSplashScreen',
      platforms: ['web'],
    });
  }

  show(_options?: WSSplashScreenShowOptions): Promise<void> {
    return Promise.resolve();
  }

  hide(_options?: WSSplashScreenShowOptions): Promise<void> {
    return Promise.resolve();
  }

  animate(_options?: WSSplashScreenAnimateOptions): Promise<void> {
    return Promise.resolve();
  }
}

function listenToAppState(listen: false): void;

/**
 * Listen to changes in the app state and execute the relevant code.
 * This is a convenience to allow you to easily show a splash when
 * your app resumes.
 *
 * @param {boolean} listen - true to start listening, false to stop listening
 * @param {WSSplashScreenAppStateOptions} options - if listen is true, the code to execute when the app state changes
 */
function listenToAppState(
  listen: true,
  options: WSSplashScreenAppStateOptions,
): void;

function listenToAppState(
  listen: boolean,
  options?: WSSplashScreenAppStateOptions,
) {
  shouldListenToAppState = listen;

  if (listen && !listening) {
    listening = true;
    const app = Plugins.App as AppPlugin;

    app.addListener('appStateChange', async (state: AppState) => {
      if (shouldListenToAppState && options) {
        if (state.isActive) {
          await options.onResume?.();
        } else {
          await options.onSuspend?.();
        }
      }
    });
  }
}

export { listenToAppState };

const WSSplashScreen = new WSSplashScreenWeb();

export { WSSplashScreen };

registerWebPlugin(WSSplashScreen);
