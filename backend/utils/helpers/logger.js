const path = require('path');
const { createSimpleLogger } = require('simple-node-logger');

// Define log file path
const logFilePath = path.join(__dirname, '../../logs/project.log');

// Create a simple logger instance
const log = createSimpleLogger({
  logFilePath: logFilePath,
  timestampFormat: 'YYYY-MM-DD HH:mm:ss',
  level: 'debug', // Set log level (optional)
});

module.exports = { log };
