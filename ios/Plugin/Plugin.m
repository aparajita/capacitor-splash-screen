#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(WSSplashScreen, "WSSplashScreen",
  CAP_PLUGIN_METHOD(nativeAnimate, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(nativeShow, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(nativeHide, CAPPluginReturnPromise);
)
