//
//  CAPPluginCall+.swift
//  WillsubCapacitorSplashscreen
//
//  Created by Aparajita on 10/27/20.
//

import Capacitor

extension CAPPluginCall {
  /*
   * Given a dotted key path, get the last dict in the path.
   */
  private func getOptionDictDeepest(forKeyPath keyPath: String) -> [AnyHashable: Any]? {
    let keys = keyPath.split(separator: ".")

    var dict = options

    for key in keys[0..<keys.count - 1] {
      dict = dict?[String(key)] as? [AnyHashable: Any]
    }

    return dict
  }

  /*
   * Get the key from a key path.
   */
  private func getKey(fromKeyPath keyPath: String) -> String {
    let keys = keyPath.split(separator: ".")

    if let lastKey = keys.last {
      return String(lastKey)
    }

    return ""
  }

  /*
   * Get a single value from the call's options.
   *
   * If the last segment of the key path begins with "ios" or "android",
   * split the key at the prefix and see if a value exists in a nested object.
   * This allows options to be structured either as:
   *
   * {
   *   iosFoo: 'bar'
   * }
   *
   * or:
   *
   * {
   *   ios: {
   *     foo: 'bar'
   *   }
   * }
   */
  public func getOption(_ keyPath: String) -> Any? {
    guard let dict = getOptionDictDeepest(forKeyPath: keyPath) else {
      return nil
    }

    // See if the dict has the key. If so, return its value.
    let key = getKey(fromKeyPath: keyPath)

    if let value = dict[key] {
      return value
    }

    // If the key doesn't exist and begins with the platform prefix,
    // split the key and check for a platform dict.
    let prefix = "ios"

    guard key.hasPrefix(prefix),
          key.count > prefix.count,
          let platformDict = dict[prefix] as? [AnyHashable: Any] else {
      return nil
    }

    // If it is a dict, see if the suffix exists in it. If so, that's the value we're looking for.
    var suffix = key.dropFirst(prefix.count)
    suffix = suffix.prefix(1).lowercased() + suffix.dropFirst(1)

    return platformDict[String(suffix)]
  }

  public func getStringOption(_ keyPath: String, _ defaultValue: String? = nil) -> String? {
    return getOption(keyPath) as? String ?? defaultValue
  }

  public func getIntOption(_ keyPath: String, _ defaultValue: Int? = nil) -> Int? {
    return getOption(keyPath) as? Int ?? defaultValue
  }

  public func getDoubleOption(_ keyPath: String, _ defaultValue: Double? = nil) -> Double? {
    return getOption(keyPath) as? Double ?? defaultValue
  }

  public func getBoolOption(_ keyPath: String, _ defaultValue: Bool? = nil) -> Bool? {
    return getOption(keyPath) as? Bool ?? defaultValue
  }
}
