//
//  CAPConfig+.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/19/20.
//

import Foundation
import Capacitor

extension CAPConfig {
  /*
   * Get a single value from the given dict.
   */
  private func getValue(forKey key: String, inDict dict: [String: Any]) -> Any? {
    // If the key exists at the top level of dict, return its value.
    if let value = dict[key] {
      return value
    }

    // If the key does not exist and begins with "ios", try the prefix and see if it's a dict.
    // If it doesn't exist or isn't a dict, the search fails.
    let prefix = "ios"

    guard key.hasPrefix(prefix),
          key.count > prefix.count,
          let platformDict = dict[prefix] as? [String: Any] else {
      return nil
    }

    // If it is a dict, see if the suffix exists in it
    var suffix = key.dropFirst(prefix.count)
    suffix = suffix.prefix(1).lowercased() + suffix.dropFirst(1)

    if let value = platformDict[String(suffix)] {
      return value
    }

    return nil
  }

  /*
   * Get a value from global config with the given dotted key path.
   *
   * If the last segment of the key path begins with "ios" or "android",
   * split the key at the prefix and see if a value exists in a nested object.
   * This allows config to be structured either as:
   *
   * "MyPlugin": {
   *   "iosFoo": "bar"
   * }
   *
   * or as:
   *
   * "MyPlugin": {
   *   "ios": {
   *     "foo": "bar"
   *   }
   * }
   */
  public func getConfigValue(withKeyPath keyPath: String) -> Any? {
    // Currently CAPConfig.getValue() is broken, it doesn't properly parse dotted key paths.
    // So split the keyPath, and get the first key in the path. We can traverse from there.
    //
    // TODO: When the bug in CAPConfig.getConfigObjectDeepest() is fixed, I won't have to traverse myself.

    let keys = keyPath.split(separator: ".")

    guard let firstKey = keys.first else {
      return nil
    }

    // Try to get the first key as is. If it doesn't exist the search fails.
    guard let value = getValue(String(firstKey)) else {
      return nil
    }

    // If the value of the first key is an object and there is more than one key in the path,
    // keep traversing. Otherwise return the value.
    guard var dict = value as? [String: Any],
          keys.count > 1 else {
      return value
    }

    // All of the keys after the first and up to the last should be dictionaries
    for key in keys[1..<keys.count - 1] {
      if let value = dict[String(key)] as? [String: Any] {
        dict = value
      } else {
        return nil
      }
    }

    // At this point the last key in keys should be in dict
    if let key = keys.last,
       let value = getValue(forKey: String(key), inDict: dict) {
      return value
    }

    return nil
  }

  public func getConfigString(withKeyPath keyPath: String) -> String? {
    return getConfigValue(withKeyPath: keyPath) as? String
  }

  public func getConfigInt(withKeyPath keyPath: String) -> Int? {
    return getConfigValue(withKeyPath: keyPath) as? Int
  }

  public func getConfigDouble(withKeyPath keyPath: String) -> Double? {
    return getConfigValue(withKeyPath: keyPath) as? Double
  }

  public func getConfigBool(withKeyPath keyPath: String) -> Bool? {
    return getConfigValue(withKeyPath: keyPath) as? Bool
  }

  /*
   * Get a value from a plugin call, falling back to the global config.
   */
  public func getConfigValue(withKeyPath key: String, pluginCall call: CAPPluginCall?) -> Any? {
    if let result = call?.getOption(key) {
      return result
    }

    return getConfigValue(withKeyPath: key)
  }

  public func getConfigString(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?) -> String? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call) as? String
  }

  public func getConfigInt(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?) -> Int? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call) as? Int
  }

  public func getConfigDouble(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?) -> Double? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call) as? Double
  }

  public func getConfigBool(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?) -> Bool? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call) as? Bool
  }
}
