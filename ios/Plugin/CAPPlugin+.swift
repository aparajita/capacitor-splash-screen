//
//  CAPConfig+.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/14/20.
//

import Capacitor

extension CAPPlugin {
  public func getConfigValue<T>(_ keyPath: String, _ ofType: T.Type) -> T? {
    let parts = keyPath.split(separator: ".")

    guard let config = bridge?.config,
          parts.count > 0,
          let pluginId = self.pluginId,
          let pluginConfig = config.getValue("plugins") as? [String: Any?],
          var dict = pluginConfig[pluginId] as? [String: Any?]
    else {
      return nil
    }

    // All keys up to the last should be dictionaries
    for key in parts[0..<parts.count - 1] {
      if let value = dict[String(key)] as? [String: Any?] {
        dict = value
      } else {
        return nil
      }
    }

    // At this point the last key in parts should be in dict
    if let key = parts.last,
       let value = dict[String(key)] {
      return value as? T
    }

    return nil
  }

  public func getConfigString(_ keyPath: String) -> String? {
    return getConfigValue(keyPath, String.self)
  }

  public func getConfigInt(_ keyPath: String) -> Int? {
    return getConfigValue(keyPath, Int.self)
  }

  public func getConfigDouble(_ keyPath: String) -> Double? {
    return getConfigValue(keyPath, Double.self)
  }

  public func getConfigBool(_ keyPath: String) -> Bool? {
    return getConfigValue(keyPath, Bool.self)
  }

  public func getConfigValue<T>(_ key: String, _ call: CAPPluginCall?, _ ofType: T.Type) -> T? {
    return call?.get(key, T.self) ?? getConfigValue(key, T.self)
  }

  public func getConfigString(_ keyPath: String, _ call: CAPPluginCall?) -> String? {
    return getConfigValue(keyPath, call, String.self)
  }

  public func getConfigInt(_ keyPath: String, _ call: CAPPluginCall?) -> Int? {
    return getConfigValue(keyPath, call, Int.self)
  }

  public func getConfigDouble(_ keyPath: String, _ call: CAPPluginCall?) -> Double? {
    return getConfigValue(keyPath, call, Double.self)
  }

  public func getConfigBool(_ keyPath: String, _ call: CAPPluginCall?) -> Bool? {
    return getConfigValue(keyPath, call, Bool.self)
  }
}
