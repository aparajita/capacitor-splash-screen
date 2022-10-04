import { SplashScreenBase } from './base'
import type { SplashScreenPlugin } from './definitions'

// eslint-disable-next-line import/prefer-default-export
export class SplashScreen extends SplashScreenBase {
  constructor(capProxy: SplashScreenPlugin) {
    super()
    this.show = capProxy.show
    this.hide = capProxy.hide
    this.animate = capProxy.animate
  }
}
