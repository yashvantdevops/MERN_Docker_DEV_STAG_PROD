/**
 * Created by Syed Afzal
 * MongoDB Connection Handler with Automatic Retry
 */
const mongoose = require("mongoose");

exports.connect = (app) => {
  // Mongoose recommended options (compatible across many versions)
  const options = {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    autoIndex: false, // Don't build indexes
    maxPoolSize: 10, // Maintain up to 10 socket connections
    serverSelectionTimeoutMS: 5000,
  };

  // Helpful default for simple dev via docker-compose: prefer service hostname used in docs
  const defaultUri = "mongodb://admin:dev_password@mongodb-dev:27017/mern_dev_db?authSource=admin";
  const mongoUri = process.env.MONGODB_URI || process.env.MONGO_URL || defaultUri;

  const connectWithRetry = () => {
    mongoose.Promise = global.Promise;
    console.log("[DB] Attempting MongoDB connection to:", mongoUri.split("@")[1] || mongoUri);
    mongoose
      .connect(mongoUri, options)
      .then(() => {
        console.log("[DB] ✓ MongoDB connected successfully");
        console.log("[DB] Database name:", mongoose.connection.name);
        console.log("[DB] Host:", mongoose.connection.host);
        app.emit("ready");
      })
      .catch((err) => {
        console.log("[DB] ✗ MongoDB connection failed, retrying in 2 seconds...");
        console.log("[DB] Error:", err && err.message ? err.message : err);
        setTimeout(connectWithRetry, 2000);
      });
  };

  connectWithRetry();
};
