package com.aparajita.capacitor.splashscreen;

import com.getcapacitor.CapConfig;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This is a more flexible version of the CapConfig class. The main difference is it allows
 * platform-specific options to be placed in a platform subobject without the platform prefix.
 */
public class Config {

    static final String PLATFORM_CONFIG_PREFIX = "android";

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

    /**
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
    public Object getConfigValue(String keyPath, Object defaultValue, Class<?> type) {
        if (config == null) {
            return defaultValue;
        }

        try {
            // If the path is not full, make it full now
            if (!keyPath.startsWith("plugins.")) {
                keyPath = "plugins." + plugin.getPluginHandle().getId() + "." + keyPath;
            }

            // Try the key path as is
            JSONObject object = getConfigObjectDeepest(keyPath);

            if (object == null) {
                return null;
            }

            String key = getKeyFromKeyPath(keyPath);
            Object value = getTypedValue(object, key, type);

            if (value != null) {
                return value;
            }

            // If the key path does not exist and the last key begins with "android",
            // split the last key and try again.
            final String prefix = PLATFORM_CONFIG_PREFIX;
            int len = prefix.length();

            if (key.startsWith(prefix) && key.length() > prefix.length()) {
                JSONObject platformObject = ((JSONObject) object).getJSONObject(prefix);
                String firstLetter = key.substring(len, len + 1).toLowerCase();
                String suffix = firstLetter + key.substring(len + 1);
                value = getTypedValue(platformObject, suffix, type);

                if (value != null) {
                    return value;
                }
            }
        } catch (Exception e) {
            // Ignore
        }

        return defaultValue;
    }

    private JSONObject getConfigObjectDeepest(String keyPath) {
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
            object = object.optJSONObject(keys[i]);

            if (object == null) {
                return null;
            }
        }

        return object;
    }

    private Object getTypedValue(JSONObject object, String key, Class<?> type) {
        if (type == String.class) {
            try {
                return object.getString(key);
            } catch (JSONException e) {
                return null;
            }
        }

        if (type == Integer.class) {
            try {
                return object.getInt(key);
            } catch (JSONException e) {
                return null;
            }
        }

        if (type == Double.class) {
            try {
                return (Double) object.getDouble(key);
            } catch (JSONException e) {
                return null;
            }
        }

        if (type == Float.class) {
            try {
                double result = object.getDouble(key);
                return (Float) (float) result;
            } catch (JSONException e) {
                return null;
            }
        }

        if (type == Boolean.class) {
            try {
                return object.getBoolean(key);
            } catch (JSONException e) {
                return null;
            }
        }

        return null;
    }

    public String getString(String keyPath) {
        return this.getString(keyPath, (String) null);
    }

    public String getString(String keyPath, String defaultValue) {
        return (String) this.getConfigValue(keyPath, defaultValue, String.class);
    }

    public Integer getInt(String keyPath) {
        return this.getInt(keyPath, (Integer) null);
    }

    public Integer getInt(String keyPath, Integer defaultValue) {
        return (Integer) this.getConfigValue(keyPath, defaultValue, Integer.class);
    }

    public Double getDouble(String keyPath) {
        return this.getDouble(keyPath, (Double) null);
    }

    public Double getDouble(String keyPath, Double defaultValue) {
        return (Double) this.getConfigValue(keyPath, defaultValue, Double.class);
    }

    public Float getFloat(String keyPath) {
        return this.getFloat(keyPath, (Float) null);
    }

    public Float getFloat(String keyPath, Float defaultValue) {
        return (Float) this.getConfigValue(keyPath, defaultValue, Float.class);
    }

    public Boolean getBoolean(String keyPath) {
        return this.getBoolean(keyPath, (Boolean) null);
    }

    public Boolean getBoolean(String keyPath, Boolean defaultValue) {
        return (Boolean) this.getConfigValue(keyPath, defaultValue, Boolean.class);
    }

    /**
     * Get a value from a plugin call, falling back to global config
     */
    public Object getOptionValue(String keyPath, PluginCall pluginCall, Object defaultValue, Class<?> type) {
        if (pluginCall != null) {
            // First try the plugin call's options
            final Object value = getOption(keyPath, pluginCall, type);

            try {
                // If it exists, return it
                if (value != null) {
                    return value;
                }
            } catch (ClassCastException e) {
                return defaultValue;
            }
        }

        // If the value can't be found in the call's options, try global config
        return this.getConfigValue(keyPath, defaultValue, type);
    }

    /**
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
    public Object getOption(String keyPath, PluginCall call, Class<?> type) {
        JSObject object = getOptionObjectDeepest(keyPath, call);

        if (object == null) {
            return null;
        }

        // See if the object has the key. If so, return its value.
        String key = getKeyFromKeyPath(keyPath);
        Object value = getTypedValue(object, key, type);

        if (value != null) {
            return value;
        }

        // If the key doesn't exist and begins with the platform prefix,
        // split the key and check for a platform object.
        String prefix = "android";
        int len = prefix.length();

        if (key.startsWith(prefix) && key.length() > len) {
            JSObject platformObject = object.getJSObject(prefix);

            if (platformObject != null) {
                String firstLetter = key.substring(len, len + 1).toLowerCase();
                String suffix = firstLetter + key.substring(len + 1);
                return getTypedValue(platformObject, suffix, type);
            }
        }

        return null;
    }

    /**
     * Given a dotted key path, get the last JSObject in the path.
     */
    private JSObject getOptionObjectDeepest(String keyPath, PluginCall call) {
        String[] keys = keyPath.split("\\.");
        JSObject object = call.getData();

        for (int i = 0; i < keys.length - 1 && object != null; i++) {
            object = object.getJSObject(keys[i]);
        }

        return object;
    }

    private String getKeyFromKeyPath(String keyPath) {
        String[] keys = keyPath.split("\\.");
        return keys[keys.length - 1];
    }

    public String getStringOption(String keyPath, PluginCall pluginCall) {
        return getStringOption(keyPath, pluginCall, (String) null);
    }

    public String getStringOption(String keyPath, PluginCall pluginCall, String defaultValue) {
        return (String) getOptionValue(keyPath, pluginCall, defaultValue, String.class);
    }

    public Integer getIntOption(String keyPath, PluginCall pluginCall) {
        return getIntOption(keyPath, pluginCall, (Integer) null);
    }

    public Integer getIntOption(String keyPath, PluginCall pluginCall, Integer defaultValue) {
        return (Integer) getOptionValue(keyPath, pluginCall, defaultValue, Integer.class);
    }

    public Double getDoubleOption(String keyPath, PluginCall pluginCall) {
        return getDoubleOption(keyPath, pluginCall, (Double) null);
    }

    public Double getDoubleOption(String keyPath, PluginCall pluginCall, Double defaultValue) {
        return (Double) getOptionValue(keyPath, pluginCall, defaultValue, Double.class);
    }

    public Float getFloatOption(String keyPath, PluginCall pluginCall) {
        return getFloatOption(keyPath, pluginCall, (Float) null);
    }

    public Float getFloatOption(String keyPath, PluginCall pluginCall, float defaultValue) {
        return (Float) getOptionValue(keyPath, pluginCall, defaultValue, Float.class);
    }

    public Boolean getBooleanOption(String keyPath, PluginCall pluginCall) {
        return getBooleanOption(keyPath, pluginCall, (Boolean) null);
    }

    public Boolean getBooleanOption(String keyPath, PluginCall pluginCall, Boolean defaultValue) {
        return (Boolean) getOptionValue(keyPath, pluginCall, defaultValue, Boolean.class);
    }
}
