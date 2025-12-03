/**
 * Created by Syed Afzal
 */
require("./config/config");

const express = require("express");
const path = require("path");
const cookieParser = require("cookie-parser");
const bodyParser = require("body-parser");
const cors = require("cors");
const db = require("./db");

const app = express();

// Connection from db here
db.connect(app);

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

// Health check endpoint
app.get('/health', (req, res) => {
  try {
    const mongoose = require('mongoose');
    const state = mongoose && mongoose.connection ? mongoose.connection.readyState : null;
    // readyState: 0 = disconnected, 1 = connected, 2 = connecting, 3 = disconnecting
    const stateNames = ['disconnected', 'connected', 'connecting', 'disconnecting'];
    const stateName = stateNames[state] || 'unknown';
    
    const isHealthy = state === 1; // 1 = connected
    const statusCode = isHealthy ? 200 : 503;
    
    return res.status(statusCode).json({
      status: isHealthy ? 'healthy' : 'unhealthy',
      uptime: process.uptime(),
      mongodb: {
        state: state,
        status: stateName,
        connected: isHealthy
      },
      timestamp: new Date().toISOString(),
      version: '1.0.0'
    });
  } catch (e) {
    return res.status(503).json({
      status: 'unhealthy',
      error: e.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Adding routes
require("./routes")(app);

// Graceful shutdown
let server;

process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  if (server && typeof server.close === 'function') {
    server.close(() => {
      console.log('HTTP server closed');
      process.exit(0);
    });
  } else {
    process.exit(0);
  }
});

// Start server once DB signals ready
app.on("ready", () => {
  const PORT = parseInt(process.env.PORT, 10) || 5000;
  server = app.listen(PORT, () => {
    console.log("Server is up on port", PORT);
  });
});

module.exports = app;
