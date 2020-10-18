//
//  CAPConfig+.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/14/20.
//

import Capacitor

fileprivate let kIosConfigPrefix = "ios"
fileprivate let kAndroidConfigPrefix = "android"

extension CAPPlugin {
  public func getConfigValue<T>(withKeyPath keyPath: String, ofType: T.Type, defaultValue: T? = nil) -> T? {
    guard let config = bridge?.config,
          let pluginId = self.pluginId,
          let pluginConfig = config.getValue("plugins") as? [String: Any?],
          var dict = pluginConfig[pluginId] as? [String: Any?]
    else {
      return nil
    }

    var modifiedKeyPath = keyPath

    // If the keyPath begins with "ios" or "android", first try it as is
    if keyPath.hasPrefix(kIosConfigPrefix) || keyPath.hasPrefix(kAndroidConfigPrefix) {
      if let value = dict[keyPath] {
        return value as? T ?? defaultValue
      }

      // If it doesn't exist as is, split it into prefix.suffix
      let configPrefix = keyPath.hasPrefix(kIosConfigPrefix) ? kIosConfigPrefix : kAndroidConfigPrefix
      let prefix = keyPath.prefix(configPrefix.count)
      var suffix = keyPath.dropFirst(prefix.count)
      suffix = suffix.prefix(1).lowercased() + suffix.dropFirst(1)
      modifiedKeyPath = prefix + "." + suffix
    }

    let keys = modifiedKeyPath.split(separator: ".")

    // All keys up to the last should be dictionaries
    for key in keys[0..<keys.count - 1] {
      if let value = dict[String(key)] as? [String: Any?] {
        dict = value
      } else {
        return nil
      }
    }

    // At this point the last key in keys should be in dict
    if let key = keys.last,
       let value = dict[String(key)] {
      return value as? T ?? defaultValue
    }

    return nil
  }

  public func getConfigString(withKeyPath keyPath: String, defaultValue: String? = nil) -> String? {
    return getConfigValue(withKeyPath: keyPath, ofType: String.self, defaultValue: defaultValue)
  }

  public func getConfigInt(withKeyPath keyPath: String, defaultValue: Int? = nil) -> Int? {
    return getConfigValue(withKeyPath: keyPath, ofType: Int.self, defaultValue: defaultValue)
  }

  public func getConfigDouble(withKeyPath keyPath: String, defaultValue: Double? = nil) -> Double? {
    return getConfigValue(withKeyPath: keyPath, ofType: Double.self, defaultValue: defaultValue)
  }

  public func getConfigBool(withKeyPath keyPath: String, defaultValue: Bool? = nil) -> Bool? {
    return getConfigValue(withKeyPath: keyPath, ofType: Bool.self, defaultValue: defaultValue)
  }

  public func getConfigValue<T>(
    withKeyPath key: String,
    pluginCall call: CAPPluginCall?,
    ofType: T.Type,
    defaultValue: T? = nil) -> T? {
    if let result = call?.get(key, T.self, defaultValue) {
      return result
    }

    return getConfigValue(withKeyPath: key, ofType: T.self, defaultValue: defaultValue)
  }

  public func getConfigString(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?, defaultValue: String? = nil) -> String? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: String.self, defaultValue: defaultValue)
  }

  public func getConfigInt(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?, defaultValue: Int? = nil) -> Int? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: Int.self, defaultValue: defaultValue)
  }

  public func getConfigDouble(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?, defaultValue: Double? = nil) -> Double? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: Double.self, defaultValue: defaultValue)
  }

  public func getConfigBool(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?, defaultValue: Bool? = nil) -> Bool? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: Bool.self, defaultValue: defaultValue)
  }
}
