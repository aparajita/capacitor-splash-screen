import { registerWebPlugin, WebPlugin } from '@capacitor/core'
import {
  WSSplashScreenHideOptions,
  WSSplashScreenPlugin,
  WSSplashScreenShowOptions
} from './definitions'

export class WSSplashScreenWeb extends WebPlugin implements WSSplashScreenPlugin {
  constructor() {
    super({
      name: 'WSSplashScreen',
      platforms: ['web']
    })
  }

  show(_options?: WSSplashScreenShowOptions, _callback?: Function): Promise<void> {
    return Promise.resolve()
  }

  hide(_options?: WSSplashScreenHideOptions, _callback?: Function): Promise<void> {
    return Promise.resolve()
  }
}

const WSSplashScreen = new WSSplashScreenWeb()

export { WSSplashScreen }

registerWebPlugin(WSSplashScreen)
