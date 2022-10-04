package com.aparajita.capacitor.splashscreen;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginConfig;
import org.json.JSONException;
import org.json.JSONObject;

public class Config {

  private final PluginConfig config;

  public Config(Plugin plugin) {
    this.config = plugin.getConfig();
  }

  /*
   * Get a value from global config with the given dotted key path.
   *
   * If the key path does not begin with "android", look first for "android.<keyPath>".
   * If that does not exist, look for "<keyPath>".
   *
   * If the first segment of the key path begins with "android",
   * split the key at the prefix and see if a value exists in an "android" object.
   *
   * This allows config to be structured either as:
   *
   * MyPlugin: {
   *   androidFoo: 'bar'
   * }
   *
   * or as:
   *
   * MyPlugin: {
   *   android: {
   *     foo: 'bar'
   *   }
   * }
   */
  public Object getConfigValue(
    String keyPath,
    Object defaultValue,
    Class<?> type
  ) {
    if (config == null) {
      return defaultValue;
    }

    try {
      if (!keyPath.startsWith("android")) {
        Object value = getTypedValue(config, "android." + keyPath, null, type);

        if (value != null) {
          return value;
        }

        return getTypedValue(config, keyPath, defaultValue, type);
      }

      final String prefix = "android";
      int len = prefix.length();

      if (keyPath.length() > len) {
        String firstLetter = keyPath.substring(len, len + 1).toLowerCase();
        String suffix = firstLetter + keyPath.substring(len + 1);
        Object value = getTypedValue(config, "android." + suffix, null, type);

        if (value != null) {
          return value;
        }
      }

      return getTypedValue(config, keyPath, defaultValue, type);
    } catch (Exception e) {
      // Ignore
    }

    return defaultValue;
  }

  private Object getTypedValue(
    PluginConfig config,
    String keyPath,
    Object defaultValue,
    Class<?> type
  ) {
    try {
      String key = getKeyFromKeyPath(keyPath);
      JSONObject object = getDeepestObject(config.getConfigJSON(), keyPath);
      return getTypedValue(object, key, defaultValue, type);
    } catch (Exception e) {
      return defaultValue;
    }
  }

  @Nullable
  private Object getTypedValue(
    JSONObject object,
    String keyPath,
    Object defaultValue,
    Class<?> type
  ) {
    try {
      String key = getKeyFromKeyPath(keyPath);
      object = getDeepestObject(object, keyPath);

      if (type == String.class) {
        return object.getString(key);
      }

      if (type == Integer.class) {
        return object.getInt(key);
      }

      if (type == Double.class) {
        return object.getDouble(key);
      }

      if (type == Float.class) {
        // No getFloat() in JSONObject
        return (float) object.getDouble(key);
      }

      if (type == Boolean.class) {
        return object.getBoolean(key);
      }

      return null;
    } catch (JSONException e) {
      return defaultValue;
    }
  }

  @Nullable
  private Object getTypedValue(
    JSONObject object,
    String keyPath,
    Class<?> type
  ) {
    return getTypedValue(object, keyPath, null, type);
  }

  public String getString(String keyPath) {
    return this.getString(keyPath, null);
  }

  public String getString(String keyPath, String defaultValue) {
    return (String) this.getConfigValue(keyPath, defaultValue, String.class);
  }

  public Integer getInt(String keyPath) {
    return this.getInt(keyPath, null);
  }

  public Integer getInt(String keyPath, Integer defaultValue) {
    return (Integer) this.getConfigValue(keyPath, defaultValue, Integer.class);
  }

  public Double getDouble(String keyPath) {
    return this.getDouble(keyPath, null);
  }

  public Double getDouble(String keyPath, Double defaultValue) {
    return (Double) this.getConfigValue(keyPath, defaultValue, Double.class);
  }

  public Float getFloat(String keyPath) {
    return this.getFloat(keyPath, null);
  }

  public Float getFloat(String keyPath, Float defaultValue) {
    return (Float) this.getConfigValue(keyPath, defaultValue, Float.class);
  }

  public Boolean getBoolean(String keyPath) {
    return this.getBoolean(keyPath, null);
  }

  public Boolean getBoolean(String keyPath, Boolean defaultValue) {
    return (Boolean) this.getConfigValue(keyPath, defaultValue, Boolean.class);
  }

  /**
   * Given a JSON object and key path, gets the deepest object in the path.
   *
   * @throws JSONException Thrown if any JSON errors
   */
  private static JSONObject getDeepestObject(
    JSONObject jsonObject,
    @NonNull String keyPath
  ) throws JSONException {
    String[] parts = keyPath.split("\\.");
    JSONObject object = jsonObject;

    // Search until the second to last part of the key
    for (int i = 0; i < parts.length - 1; i++) {
      String key = parts[i];
      object = object.getJSONObject(key);
    }

    return object;
  }

  /**
   * Get a value from a plugin call or global config
   */
  public Object getOptionValue(
    String keyPath,
    JSObject options,
    Object defaultValue,
    Class<?> type
  ) {
    if (options != null) {
      final Object value = getOption(keyPath, options, type);

      try {
        // If it exists, return it
        if (value != null) {
          return value;
        }
      } catch (ClassCastException e) {
        // ignore
      }

      return defaultValue;
    }

    return getConfigValue(keyPath, defaultValue, type);
  }

  /**
   * Get a single value from the call's options. Uses the same algorithm as getConfigValue().
   */
  public Object getOption(String keyPath, JSObject options, Class<?> type) {
    if (options == null) {
      return null;
    }

    JSONObject object = getOptionObjectDeepest(keyPath, options);

    if (!keyPath.startsWith("android")) {
      Object value = getTypedValue(object, "android." + keyPath, type);

      if (value != null) {
        return value;
      }

      return getTypedValue(object, keyPath, type);
    }

    int len = "android.".length();

    if (keyPath.length() > len) {
      String firstLetter = keyPath.substring(len, len + 1).toLowerCase();
      keyPath = firstLetter + keyPath.substring(len + 1);
      Object value = getTypedValue(object, keyPath, type);

      if (value != null) {
        return value;
      }
    }

    return getTypedValue(object, keyPath, type);
  }

  /**
   * Given a dotted key path, get the last JSObject in the path.
   */
  private JSObject getOptionObjectDeepest(
    @NonNull String keyPath,
    JSObject options
  ) {
    String[] keys = keyPath.split("\\.");
    JSObject object = options;

    for (int i = 0; i < keys.length - 1 && object != null; i++) {
      object = object.getJSObject(keys[i]);
    }

    return object;
  }

  private String getKeyFromKeyPath(@NonNull String keyPath) {
    String[] keys = keyPath.split("\\.");
    return keys[keys.length - 1];
  }

  public String getStringOption(String keyPath, JSObject options) {
    return getStringOption(keyPath, options, null);
  }

  public String getStringOption(
    String keyPath,
    JSObject options,
    String defaultValue
  ) {
    return (String) getOptionValue(
      keyPath,
      options,
      defaultValue,
      String.class
    );
  }

  public Integer getIntOption(String keyPath, JSObject options) {
    return getIntOption(keyPath, options, null);
  }

  public Integer getIntOption(
    String keyPath,
    JSObject options,
    Integer defaultValue
  ) {
    return (Integer) getOptionValue(
      keyPath,
      options,
      defaultValue,
      Integer.class
    );
  }

  public Double getDoubleOption(String keyPath, JSObject options) {
    return getDoubleOption(keyPath, options, null);
  }

  public Double getDoubleOption(
    String keyPath,
    JSObject options,
    Double defaultValue
  ) {
    return (Double) getOptionValue(
      keyPath,
      options,
      defaultValue,
      Double.class
    );
  }

  public Float getFloatOption(String keyPath, JSObject options) {
    return getFloatOption(keyPath, options, null);
  }

  public Float getFloatOption(
    String keyPath,
    JSObject options,
    Float defaultValue
  ) {
    return (Float) getOptionValue(keyPath, options, defaultValue, Float.class);
  }

  public Boolean getBooleanOption(String keyPath, JSObject options) {
    return getBooleanOption(keyPath, options, null);
  }

  public Boolean getBooleanOption(
    String keyPath,
    JSObject options,
    Boolean defaultValue
  ) {
    return (Boolean) getOptionValue(
      keyPath,
      options,
      defaultValue,
      Boolean.class
    );
  }
}
