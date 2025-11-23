import express from 'express';
import ProviderManager from '../services/providerManager.js';

const router = express.Router();
const providerManager = new ProviderManager();

// Initialize provider manager
await providerManager.init();

router.post('/', async (req, res) => {
    try {
        const { image } = req.body;

        if (!image) {
            return res.status(400).json({
                success: false,
                error: {
                    code: 'MISSING_IMAGE',
                    message: 'Image field is required'
                }
            });
        }

        // Validate base64 format (basic check)
        if (!image.match(/^[A-Za-z0-9+/=]+$/)) {
            return res.status(400).json({
                success: false,
                error: {
                    code: 'INVALID_IMAGE_FORMAT',
                    message: 'Image must be base64 encoded'
                }
            });
        }

        const result = await providerManager.recognizeWithFallback(image);
        res.json(result);

    } catch (error) {
        console.error('Recognition error:', error);

        res.status(500).json({
            success: false,
            error: {
                code: error.code || 'RECOGNITION_FAILED',
                message: error.message || '识别失败',
                details: error.details || {},
                attemptedProviders: error.attemptedProviders || []
            }
        });
    }
});

export default router;
