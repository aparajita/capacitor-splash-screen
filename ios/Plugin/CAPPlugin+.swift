//
//  CAPConfig+.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/14/20.
//

import Capacitor

extension CAPPlugin {
  public func getConfigValue(withKeyPath key: String, pluginCall call: CAPPluginCall?) -> Any? {
    if let result = call?.getOption(key) {
      return result
    }

    guard let pluginId = self.pluginId else {
      return nil
    }

    let keyPath = "plugins.\(pluginId).\(key)"
    return bridge?.config.getConfigValue(withKeyPath: keyPath)
  }

  public func getConfigString(withKeyPath keyPath: String, pluginCall call: CAPPluginCall? = nil) -> String? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call) as? String
  }

  public func getConfigInt(withKeyPath keyPath: String, pluginCall call: CAPPluginCall? = nil) -> Int? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call) as? Int
  }

  public func getConfigDouble(withKeyPath keyPath: String, pluginCall call: CAPPluginCall? = nil) -> Double? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call) as? Double
  }

  public func getConfigBool(withKeyPath keyPath: String, pluginCall call: CAPPluginCall? = nil) -> Bool? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call) as? Bool
  }
}
