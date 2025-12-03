const env = process.env.NODE_ENV || "development";

if (env === "development" || env === "test") {
  const config = require("./config.json");
  const envConfig = config[env];

  console.log("[CONFIG] Loading environment config for:", env);
  console.log("[CONFIG] Docker env vars take precedence over config.json defaults");

  // Only set variables that are NOT already provided (so docker --env-file wins)
  Object.keys(envConfig).forEach((key) => {
    if (typeof process.env[key] === "undefined" || process.env[key] === "") {
      process.env[key] = envConfig[key];
      console.log(`[CONFIG] Set ${key}=${envConfig[key]} (from config.json)`);
    } else {
      console.log(`[CONFIG] ${key} already set (from Docker env-file), skipping config.json`);
    }
  });
}
