package com.aparajita.capacitor.splashscreen;

import android.util.Log;
import java.util.HashMap;

public class Logger {

    enum LogLevel {
        off,
        error,
        warn,
        info,
        debug,
        trace
    }

    static HashMap<LogLevel, String> prefixes;

    static {
        prefixes = new HashMap<>();
        prefixes.put(LogLevel.error, "🔴");
        prefixes.put(LogLevel.warn, "🟠");
        prefixes.put(LogLevel.info, "🟢");
        prefixes.put(LogLevel.debug, "👉");
        prefixes.put(LogLevel.trace, "🔎");
    }

    LogLevel currentLevel = LogLevel.info;

    public void setLogLevel(LogLevel logLevel) {
        currentLevel = logLevel;
    }

    public void setLogLevel(String logLevel) {
        try {
            currentLevel = LogLevel.valueOf(logLevel.toLowerCase());
        } catch (IllegalArgumentException ex) {
            // ignore
        }
    }

    /**
     * Print a trace message to the log.
     */
    public void trace(String module, String... items) {
        print(LogLevel.trace, module, items);
    }

    /**
     * Print a debug message to the log.
     */
    public void debug(String module, String... items) {
        print(LogLevel.debug, module, items);
    }

    /**
     * Print an info message to the log.
     */
    public void info(String module, String... items) {
        print(LogLevel.info, module, items);
    }

    /**
     * Print a warning message to the log.
     */
    public void warn(String module, String... items) {
        print(LogLevel.warn, module, items);
    }

    /**
     * Print an error message to the log.
     */
    public void error(String module, String... items) {
        print(LogLevel.error, module, items);
    }

    /*
     * Print a message to the log.
     */
    private void print(LogLevel level, String module, String[] items) {
        if (!canLogAt(level)) {
            return;
        }

        StringBuilder message = new StringBuilder();

        for (int i = 0; i < items.length; i++) {
            if (i == 0) {
                message.append(items[0]);
            } else {
                message.append(" ").append(items[i]);
            }
        }

        String prefix = prefixes.get(level);
        String msg = String.format("%s [%s] %s", prefix, module, message);

        switch (level) {
            case info:
                Log.i(module, msg);
                break;
            case warn:
                Log.w(module, msg);
                break;
            case error:
                Log.e(module, msg);
                break;
            case trace:
                Log.v(module, msg);
                break;
        }
    }

    private boolean canLogAt(LogLevel level) {
        return this.currentLevel != LogLevel.off && this.currentLevel.compareTo(level) >= 0;
    }
}
