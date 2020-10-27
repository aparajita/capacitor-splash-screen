package com.willsub.splashscreen;

import com.getcapacitor.CapConfig;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;

import org.json.JSONObject;

@SuppressWarnings("rawtypes")
public class Config {
    static final String IOS_CONFIG_PREFIX = "ios";
    static final String ANDROID_CONFIG_PREFIX = "android";
    static final String[] PLATFORM_PREFIXES = {IOS_CONFIG_PREFIX, ANDROID_CONFIG_PREFIX};

    private static Config instance = null;

    private final Plugin plugin;
    private final CapConfig config;

    private Config(Plugin plugin) {
        this.plugin = plugin;
        this.config = plugin.getBridge().getConfig();
    }

    public static Config getInstance(Plugin plugin) {
        if (instance == null) {
            instance = new Config(plugin);
        }

        return instance;
    }

    public Plugin getPlugin() {
        return plugin;
    }

    // Capacitor 2.0 CapConfig.getInt() can't return null for a missing item.
    // So we have to parse the key path ourselves.
    private Object getConfigValue(String keyPath) {
        String[] keys = keyPath.split("\\.");

        if (keys.length == 0) {
            return null;
        }

        // Get the top level from config
        JSONObject object = config.getObject(keys[0]);

        if (object == null) {
            return null;
        }

        // All keys up to the last should be objects
        for (int i = 1; i < keys.length - 1; i++) {
            object = (JSONObject) object.opt(keys[i]);

            if (object == null) {
                return null;
            }
        }

        // The last key should be the actual value
        return object.opt(keys[keys.length - 1]);
    }

    /*
     * Get a value from the global config.
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
    public <T> T getValue(String keyPath, Class type, T defaultValue) {
        if (config == null) {
            return defaultValue;
        }

        try {
            // Try the key path as is
            Object value = getConfigValue(keyPath);

            if (value != null) {
                @SuppressWarnings("unchecked")
                T result = (T) value;
                return result;
            }

            // If the key path does not exist and the last segment of the path begins with "ios" or "android",
            // split the last segment and try again.
            final String[] keys = keyPath.split("\\.");
            final String lastKey = keys[keys.length - 1];

            for (String prefix : PLATFORM_PREFIXES) {
                if (lastKey.startsWith(prefix)) {
                    String suffix = lastKey.substring(prefix.length());
                    suffix = suffix.substring(0, 1).toLowerCase() + suffix.substring(1);
                    keys[keys.length - 1] = prefix + "." + suffix;
                    StringBuilder newKeyPath = new StringBuilder(keys[0]);

                    for (int i = 1; i < keys.length; i++) {
                        newKeyPath.append(".").append(keys[i]);
                    }

                    value = getConfigValue(newKeyPath.toString());

                    if (value != null) {
                        @SuppressWarnings("unchecked")
                        T result = (T) value;
                        return result;
                    }

                    return defaultValue;
                }
            }
        } catch (Exception e) {
            // Do nothing
        }

        return defaultValue;
    }

    public String getString(String keyPath) {
        return this.getString(keyPath, (String) null);
    }

    public String getString(String keyPath, String defaultValue) {
        return this.getValue(keyPath, String.class, defaultValue);
    }

    public int getInt(String keyPath) {
        return this.getInt(keyPath, (Integer) null);
    }

    public int getInt(String keyPath, Integer defaultValue) {
        return this.getValue(keyPath, Integer.class, defaultValue);
    }

    public double getDouble(String keyPath) {
        return this.getDouble(keyPath, (Double) null);
    }

    public double getDouble(String keyPath, Double defaultValue) {
        return this.getValue(keyPath, Double.class, defaultValue);
    }

    public double getFloat(String keyPath) {
        return this.getFloat(keyPath, (Float) null);
    }

    public double getFloat(String keyPath, Float defaultValue) {
        return this.getValue(keyPath, Float.class, defaultValue);
    }

    public boolean getBoolean(String keyPath) {
        return this.getBoolean(keyPath, (Boolean) null);
    }

    public boolean getBoolean(String keyPath, Boolean defaultValue) {
        return this.getValue(keyPath, Boolean.class, defaultValue);
    }

    private Object getTypedValue(String keyPath, PluginCall call, Class type) {
        if (type == String.class) {
            return call.getString(keyPath, null);
        } else if (type == Integer.class) {
            return call.getInt(keyPath, null);
        } else if (type == Double.class) {
            return call.getDouble(keyPath, null);
        } else if (type == Float.class) {
            return call.getFloat(keyPath, null);
        } else if (type == Boolean.class) {
            return call.getBoolean(keyPath, null);
        }

        return null;
    }

    /*
     * Get a value from a plugin call, falling back to global config
     */
    public <T> T getValue(String keyPath, PluginCall pluginCall, Class type, T defaultValue) {
        if (pluginCall != null) {
            final Object value = getTypedValue(keyPath, pluginCall, type);

            try {
                if (value != null) {
                    @SuppressWarnings("unchecked") final T result = (T) value;
                    return result;
                }
            } catch (Exception e) {
                return defaultValue;
            }
        }

        keyPath = String.format("plugins.%s.%s", plugin.getPluginHandle().getId(), keyPath);
        return this.getValue(keyPath, type, defaultValue);
    }

    public String getString(String keyPath, PluginCall pluginCall) {
        return getString(keyPath, pluginCall, (String) null);
    }

    public String getString(String keyPath, PluginCall pluginCall, String defaultValue) {
        return getValue(keyPath, pluginCall, String.class, defaultValue);
    }

    public int getInt(String keyPath, PluginCall pluginCall) {
        return getInt(keyPath, pluginCall, (Integer) null);
    }

    public int getInt(String keyPath, PluginCall pluginCall, int defaultValue) {
        return getValue(keyPath, pluginCall, Integer.class, defaultValue);
    }

    public double getDouble(String keyPath, PluginCall pluginCall) {
        return getDouble(keyPath, pluginCall, (Double) null);
    }

    public double getDouble(String keyPath, PluginCall pluginCall, double defaultValue) {
        return getValue(keyPath, pluginCall, Double.class, defaultValue);
    }

    public double getFloat(String keyPath, PluginCall pluginCall) {
        return getFloat(keyPath, pluginCall, (Float) null);
    }

    public double getFloat(String keyPath, PluginCall pluginCall, float defaultValue) {
        return getValue(keyPath, pluginCall, Float.class, defaultValue);
    }

    public boolean getBoolean(String keyPath, PluginCall pluginCall) {
        return getBoolean(keyPath, pluginCall, (Boolean) null);
    }

    public boolean getBoolean(String keyPath, PluginCall pluginCall, Boolean defaultValue) {
        return getValue(keyPath, pluginCall, Boolean.class, defaultValue);
    }
}
