/**
 * Helper to standardize API responses
 */
const serverResponse = {
  /**
   * Send a successful response
   * @param {Object} res - Express response object
   * @param {Object} message - Response code and message object
   * @param {Object} data - Optional data to send
   */
  sendSuccess: (res, message, data = null) => {
    const responseMessage = {
      code: message.code || 200,
      success: message.success,
      message: message.message,
    };
    if (data) {
      responseMessage.data = data;
    }
    return res.status(responseMessage.code).json(responseMessage);
  },

  /**
   * Send an error response
   * @param {Object} res - Express response object
   * @param {Object} error - Error code and message object
   */
  sendError: (res, error) => {
    const responseMessage = {
      code: error.code || 500,
      success: false,
      message: error.message || "Something unexpected happened",
    };
    return res.status(responseMessage.code).json(responseMessage);
  },
};

module.exports = serverResponse;
