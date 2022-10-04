#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(SplashScreen, "SplashScreen",
  CAP_PLUGIN_METHOD(show, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(hide, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(animate, CAPPluginReturnPromise);
)
