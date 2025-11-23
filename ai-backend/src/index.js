import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import recognizeRouter from './routes/recognize.js';
import adminRouter from './routes/admin.js';

const app = express();
const port = process.env.PORT || 3000;

// Security: Rate Limiting
// 1. General limiter for all requests
const globalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: 'Too many requests, please try again later.' }
});

// 2. Stricter limiter for AI recognition (Expensive!)
const aiLimiter = rateLimit({
    windowMs: 1 * 60 * 1000, // 1 minute
    max: 10, // Limit each IP to 10 requests per minute
    message: { error: 'Rate limit exceeded for AI recognition.' }
});

// 3. Login limiter
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // Limit each IP to 5 login attempts per windowMs
    message: { error: 'Too many login attempts, please try again later.' }
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' })); // Increase limit for base64 images
app.use(express.static('public')); // Serve static files from public directory
app.use(globalLimiter); // Apply global limiter

// Security: App API Key Verification Middleware
const verifyAppKey = (req, res, next) => {
    const apiKey = req.headers['x-api-key'];
    const validKey = process.env.APP_API_KEY;

    // If no key configured on server, warn but allow (or block? safer to block)
    if (!validKey) {
        console.warn('⚠️ APP_API_KEY not set in .env. Allowing request but security is compromised.');
        return next();
    }

    if (!apiKey || apiKey !== validKey) {
        return res.status(401).json({ error: 'Invalid or missing App API Key' });
    }

    next();
};

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
// Apply stricter rate limit and API key check to recognition API
app.use('/api/v1/recognize', aiLimiter, verifyAppKey, recognizeRouter);

// Admin routes (Auth handled inside router)
app.use('/api/admin', adminRouter);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: {
            code: 'NOT_FOUND',
            message: 'Endpoint not found'
        }
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({
        success: false,
        error: {
            code: 'INTERNAL_ERROR',
            message: err.message || 'Internal server error'
        }
    });
});

app.listen(port, () => {
    console.log(`🚀 AI Backend running on port ${port}`);
    console.log(`📝 Health check: http://localhost:${port}/health`);
    console.log(`🔍 Recognition API: http://localhost:${port}/api/v1/recognize`);
});
