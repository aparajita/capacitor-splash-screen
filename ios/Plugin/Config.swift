//
//  Ccnfig.swift
//  CapacitorSplashScreen
//
//  Created by Aparajita on 7/5/22.
//

import Capacitor
import Foundation

public enum Config {
  public typealias CallOptions = [AnyHashable: Any]

  private static func getConfigValue(_ keyPath: String, forPlugin plugin: CAPPlugin) -> Any? {
    if let config = plugin.bridge?.config.getPluginConfig(plugin.pluginName).getConfigJSON() {
      return config[keyPath: KeyPath(stringLiteral: keyPath)]
    }

    return nil
  }

  /*
   * Get a value from global config with the given dotted key path.
   *
   * If the key path does not begin with "ios", look first for "ios.<keyPath>".
   * If that does not exist, look for "<keyPath>".
   *
   * If the first segment of the key path begins with "ios",
   * split the key at the prefix and see if a value exists in an "ios" object.
   *
   * This allows config to be structured either as:
   *
   * MyPlugin: {
   *   iosFoo: 'bar'
   * }
   *
   * or as:
   *
   * MyPlugin: {
   *   ios: {
   *     foo: 'bar'
   *   }
   * }
   */
  public static func getValue(_ keyPath: String, forPlugin plugin: CAPPlugin) -> Any? {
    if !keyPath.hasPrefix("ios") {
      if let value = getConfigValue("ios.\(keyPath)", forPlugin: plugin) {
        return value
      }

      return getConfigValue(keyPath, forPlugin: plugin)
    }

    if keyPath.count > "ios".count {
      var suffix = keyPath.dropFirst("ios".count)
      suffix = suffix.prefix(1).lowercased() + suffix.dropFirst(1)

      if let value = getConfigValue("ios.\(suffix)", forPlugin: plugin) {
        return value
      }
    }

    return getConfigValue(keyPath, forPlugin: plugin)
  }

  public static func getString(_ keyPath: String, forPlugin plugin: CAPPlugin) -> String? {
    getValue(keyPath, forPlugin: plugin) as? String
  }

  public static func getInt(_ keyPath: String, forPlugin plugin: CAPPlugin) -> Int? {
    getValue(keyPath, forPlugin: plugin) as? Int
  }

  public static func getDouble(_ keyPath: String, forPlugin plugin: CAPPlugin) -> Double? {
    getValue(keyPath, forPlugin: plugin) as? Double
  }

  public static func getBool(_ keyPath: String, forPlugin plugin: CAPPlugin) -> Bool? {
    getValue(keyPath, forPlugin: plugin) as? Bool
  }

  /*
   * Get a value from a plugin call, falling back to the global config.
   */
  public static func getValue(
    _ key: String,
    inOptions options: CallOptions?,
    orPlugin plugin: CAPPlugin
  ) -> Any? {
    if let result = getOption(key, inOptions: options) {
      return result
    }

    return getValue(key, forPlugin: plugin)
  }

  public static func getString(
    _ keyPath: String,
    inOptions options: CallOptions?,
    orPlugin plugin: CAPPlugin
  ) -> String? {
    getValue(keyPath, inOptions: options, orPlugin: plugin) as? String
  }

  public static func getInt(
    _ keyPath: String,
    inOptions options: CallOptions?,
    orPlugin plugin: CAPPlugin
  ) -> Int? {
    getValue(keyPath, inOptions: options, orPlugin: plugin) as? Int
  }

  public static func getDouble(
    _ keyPath: String,
    inOptions options: CallOptions?,
    orPlugin plugin: CAPPlugin
  ) -> Double? {
    getValue(keyPath, inOptions: options, orPlugin: plugin) as? Double
  }

  public static func getBool(
    _ keyPath: String,
    inOptions options: CallOptions?,
    orPlugin plugin: CAPPlugin
  ) -> Bool? {
    getValue(keyPath, inOptions: options, orPlugin: plugin) as? Bool
  }

  /*
   * Given a dotted key path, get the last dict in the path.
   */
  private static func getOptionDictDeepest(
    forKeyPath keyPath: String,
    inOptions options: CallOptions?
  ) -> CallOptions? {
    let keys = keyPath.split(separator: ".")
    var dict = options

    for key in keys[0 ..< keys.count - 1] {
      dict = dict?[String(key)] as? CallOptions
    }

    return dict
  }

  /*
   * Get the key from a key path.
   */
  private static func getKey(fromKeyPath keyPath: String) -> String {
    let keys = keyPath.split(separator: ".")

    if let lastKey = keys.last {
      return String(lastKey)
    }

    return ""
  }

  private static func getOptionValue(_ keyPath: String, inOptions options: CallOptions) -> Any? {
    guard let dict = getOptionDictDeepest(forKeyPath: keyPath, inOptions: options) else {
      return nil
    }

    let key = getKey(fromKeyPath: keyPath)
    return dict[key]
  }

  /*
   * Get a single value from the call's options. Uses the same algorithm as getValue().
   */
  public static func getOption(_ keyPath: String, inOptions options: CallOptions?) -> Any? {
    guard let options = options else {
      return nil
    }

    if !keyPath.hasPrefix("ios") {
      if let value = getOptionValue("ios.\(keyPath)", inOptions: options) {
        return value
      }

      return getOptionValue(keyPath, inOptions: options)
    }

    if keyPath.count > "ios".count {
      var suffix = keyPath.dropFirst("ios".count)
      suffix = suffix.prefix(1).lowercased() + suffix.dropFirst(1)

      if let value = getOptionValue("ios.\(suffix)", inOptions: options) {
        return value
      }
    }

    return getOptionValue(keyPath, inOptions: options)
  }

  public static func getString(
    _ keyPath: String,
    inOptions options: CallOptions
  ) -> String? {
    getOption(keyPath, inOptions: options) as? String
  }

  public static func getInt(_ keyPath: String, inOptions options: CallOptions) -> Int? {
    getOption(keyPath, inOptions: options) as? Int
  }

  public static func getDouble(
    _ keyPath: String,
    inOptions options: CallOptions?
  ) -> Double? {
    getOption(keyPath, inOptions: options) as? Double
  }

  public static func getBool(_ keyPath: String, inOptions options: CallOptions?) -> Bool? {
    getOption(keyPath, inOptions: options) as? Bool
  }
}
