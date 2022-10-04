import type { StateChangeListener } from '@capacitor/app'
import { App } from '@capacitor/app'
import type { PluginListenerHandle } from '@capacitor/core'
import { WebPlugin } from '@capacitor/core'
import type {
  SplashScreenAnimateOptions,
  SplashScreenAppStateListeners,
  SplashScreenPlugin,
  SplashScreenShowOptions
} from './definitions'

// eslint-disable-next-line import/prefer-default-export
export class SplashScreenBase extends WebPlugin implements SplashScreenPlugin {
  // @native
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  async show(options?: SplashScreenShowOptions): Promise<void> {
    return Promise.resolve()
  }

  // @native
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  async hide(options?: SplashScreenShowOptions): Promise<void> {
    return Promise.resolve()
  }

  // @native
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  async animate(options?: SplashScreenAnimateOptions): Promise<void> {
    return Promise.resolve()
  }

  async listenToAppState(
    options?: SplashScreenAppStateListeners
  ): Promise<PluginListenerHandle> {
    const listener: StateChangeListener = ({ isActive }) => {
      if (options) {
        if (isActive) {
          options.onResume?.()
        } else {
          options.onSuspend?.()
        }
      }
    }

    return App.addListener('appStateChange', listener)
  }
}
