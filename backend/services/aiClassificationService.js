const axios = require('axios');
const path = require("path");

class AIClassificationService {
  constructor() {
    this.aiServiceUrl = process.env.AI_SERVICE_URL || 'http://localhost:8000';
  }

  async classifyImage(imagePath, hint = null) {
    try {
      console.log(`[AI Service] Sending classification request for: ${imagePath} (Hint: ${hint})`);

      // Ensure absolute path for Python service
      const absolutePath = path.resolve(imagePath);

      const payload = {
        image_path: absolutePath
      };

      if (hint) {
        payload.hint = hint;
      }

      const response = await axios.post(`${this.aiServiceUrl}/classify`, payload);

      console.log('[AI Service] Response:', response.data);
      return response.data;
    } catch (error) {
      console.error('[AI Service] Classification failed:', error.message);
      // Fallback
      return {
        category: "unknown",
        confidence: 0.0,
        error: error.message
      };
    }
  }

  async isServiceAvailable() {
    try {
      await axios.get(`${this.aiServiceUrl}/health`);
      return true;
    } catch (error) {
      return false;
    }
  }

  async getServiceInfo() {
    try {
      const response = await axios.get(`${this.aiServiceUrl}/info`);
      return response.data;
    } catch (error) {
      return {
        name: "Civic Issue Classifier",
        status: "offline"
      };
    }
  }
}

module.exports = new AIClassificationService();
