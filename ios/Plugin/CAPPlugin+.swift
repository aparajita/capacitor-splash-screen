//
//  CAPConfig+.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/14/20.
//

import Capacitor

extension CAPPlugin {
  public func getConfigValue<T>(
    withKeyPath key: String,
    pluginCall call: CAPPluginCall?,
    ofType: T.Type) -> T? {
    if let result = call?.get(key, T.self) {
      return result
    }

    guard let pluginId = self.pluginId else {
      return nil
    }

    let keyPath = "plugins.\(pluginId).\(key)"
    return bridge?.config.getConfigValue(withKeyPath: keyPath, ofType: T.self)
  }

  public func getConfigString(withKeyPath keyPath: String, pluginCall call: CAPPluginCall? = nil) -> String? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: String.self)
  }

  public func getConfigInt(withKeyPath keyPath: String, pluginCall call: CAPPluginCall? = nil) -> Int? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: Int.self)
  }

  public func getConfigDouble(withKeyPath keyPath: String, pluginCall call: CAPPluginCall? = nil) -> Double? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: Double.self)
  }

  public func getConfigBool(withKeyPath keyPath: String, pluginCall call: CAPPluginCall? = nil) -> Bool? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: Bool.self)
  }
}
