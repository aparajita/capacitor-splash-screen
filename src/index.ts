import { registerPlugin } from '@capacitor/core'
import type { SplashScreenPlugin } from './definitions'
import info from './info.json'

console.log(`loaded ${info.name} v${info.version}`)

// eslint-disable-next-line @typescript-eslint/naming-convention
const proxy = registerPlugin<SplashScreenPlugin>('SplashScreen', {
  web: async () =>
    import('./base').then((module) => new module.SplashScreenBase()),
  ios: async () =>
    import('./native').then((module) => new module.SplashScreen(proxy)),
  android: async () =>
    import('./native').then((module) => new module.SplashScreen(proxy))
})

export * from './definitions'
export * from './utils'
export { proxy as SplashScreen }
