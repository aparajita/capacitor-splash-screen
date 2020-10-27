//
//  CAPConfig+.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/19/20.
//

import Foundation
import Capacitor

private let kIosConfigPrefix = "ios"
private let kAndroidConfigPrefix = "android"

extension CAPConfig {
  /*
   * Get a single value from the given dict, or from the global config if nil.
   */
  private func getValue(forKey key: String, inDict dict: [String: Any]? = nil) -> Any? {
    var value: Any?

    // Try the key as is first. If dict is not nil, check the dict. Otherwise check the top level config.
    if dict != nil {
      value = dict?[key]
    } else {
      value = getValue(key)
    }

    // If the key exists, return its value
    if value != nil {
      return value
    }

    // If the key does not exist and begins with "ios" or "android", try the prefix and see if it's a dict
    for prefix in [kIosConfigPrefix, kAndroidConfigPrefix] {
      guard key.hasPrefix(prefix) else {
        continue
      }

      // Try to get the prefix as an object
      guard let config = dict?[prefix] as? [String: Any] else {
        return nil
      }

      // If it is a dict, see if the suffix exists in it
      var suffix = key.dropFirst(prefix.count)
      suffix = suffix.prefix(1).lowercased() + suffix.dropFirst(1)

      if let value = config[String(suffix)] {
        return value
      }
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
  public func getConfigValue<T>(withKeyPath keyPath: String, ofType: T.Type) -> T? {
    // Currently CAPConfig.getValue() is broken, it doesn't properly parse dotted key paths.
    // So split the keyPath, and get the first key in the path. We can traverse from there.
    let keys = keyPath.split(separator: ".")

    guard let key = keys.first,
          let value = getValue(forKey: String(key)) else {
      return nil
    }

    // If the value is an object and there is more than one key in the path, keep traversing.
    // Otherwise return the value.
    guard var dict = value as? [String: Any],
          keys.count > 1 else {
      return value as? T
    }

    // All of the keys after the first and up to the last should be dictionaries
    for key in keys[1..<keys.count - 1] {
      if let value = getValue(forKey: String(key), inDict: dict) as? [String: Any] {
        dict = value
      } else {
        return nil
      }
    }

    // At this point the last key in keys should be in dict
    if let key = keys.last,
       let value = getValue(forKey: String(key), inDict: dict) {
      return value as? T
    }

    /*
      TODO: Use this code when the bug in CAPConfig.getConfigObjectDeepest() is fixed

    // Try the key path as is
    if let value = getValue(keyPath) as? T {
      return value
    }

    // If the key path does not exist and the last segment of the path begins with "ios" or "android",
    // split the last segment and try again.
    var keys = keyPath.split(separator: ".")

    if let lastKey = keys.last {
      for prefix in [kIosConfigPrefix, kAndroidConfigPrefix] {
        guard lastKey.hasPrefix(prefix) else {
          continue
        }

        var suffix = lastKey.dropFirst(prefix.count)
        suffix = suffix.prefix(1).lowercased() + suffix.dropFirst(1)
        keys[keys.count - 1] = prefix + "." + suffix
        let newKeyPath = keys.joined(separator: ".")

        if let value = getValue(newKeyPath) as? T {
          return value
        }
      }
    }
 */

    return nil
  }

  public func getConfigString(withKeyPath keyPath: String) -> String? {
    return getConfigValue(withKeyPath: keyPath, ofType: String.self)
  }

  public func getConfigInt(withKeyPath keyPath: String) -> Int? {
    return getConfigValue(withKeyPath: keyPath, ofType: Int.self)
  }

  public func getConfigDouble(withKeyPath keyPath: String) -> Double? {
    return getConfigValue(withKeyPath: keyPath, ofType: Double.self)
  }

  public func getConfigBool(withKeyPath keyPath: String) -> Bool? {
    return getConfigValue(withKeyPath: keyPath, ofType: Bool.self)
  }

  /*
   * Get a value from a plugin call, falling back to the global config.
   */
  public func getConfigValue<T>(
    withKeyPath key: String,
    pluginCall call: CAPPluginCall?,
    ofType: T.Type) -> T? {
    if let result = call?.get(key, T.self) {
      return result
    }

    return getConfigValue(withKeyPath: key, ofType: T.self)
  }

  public func getConfigString(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?) -> String? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: String.self)
  }

  public func getConfigInt(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?) -> Int? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: Int.self)
  }

  public func getConfigDouble(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?) -> Double? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: Double.self)
  }

  public func getConfigBool(withKeyPath keyPath: String, pluginCall call: CAPPluginCall?) -> Bool? {
    return getConfigValue(withKeyPath: keyPath, pluginCall: call, ofType: Bool.self)
  }
}
