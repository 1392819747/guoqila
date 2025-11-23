import express from 'express';
import { createClient } from '@supabase/supabase-js';
import crypto from 'crypto';

const router = express.Router();

// Initialize Supabase client
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;
const encryptionKey = process.env.ENCRYPTION_KEY;

const supabase = (supabaseUrl && supabaseKey)
    ? createClient(supabaseUrl, supabaseKey)
    : null;

// Middleware to check for admin authentication (simple password for now)
const adminAuth = (req, res, next) => {
    const authHeader = req.headers.authorization;
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin'; // Default to 'admin' if not set

    if (authHeader === `Bearer ${adminPassword}`) {
        next();
    } else {
        res.status(401).json({ error: 'Unauthorized' });
    }
};

router.use(adminAuth);

function encryptApiKey(apiKey) {
    if (!apiKey || !encryptionKey) return null;
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(encryptionKey), iv);
    let encrypted = cipher.update(apiKey, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return iv.toString('hex') + ':' + encrypted;
}

// POST /api/admin/login - Verify password
router.post('/login', (req, res) => {
    // If we reached here, adminAuth passed, so password is correct
    res.json({ success: true, token: 'admin' }); // Token is just a placeholder, we use the password as bearer
});

// GET /api/admin/providers
router.get('/providers', async (req, res) => {
    if (!supabase) return res.status(500).json({ error: 'Supabase not configured' });

    const { data, error } = await supabase
        .from('ai_providers')
        .select('id, name, provider_id, base_url, model, priority, enabled, created_at')
        .order('priority');

    if (error) return res.status(500).json({ error: error.message });
    res.json(data);
});

// POST /api/admin/providers
router.post('/providers', async (req, res) => {
    if (!supabase) return res.status(500).json({ error: 'Supabase not configured' });

    const { name, provider_id, base_url, model, api_key, priority } = req.body;

    if (!name || !provider_id || !base_url || !model || !api_key) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const { data, error } = await supabase
        .from('ai_providers')
        .insert({
            name,
            provider_id,
            base_url,
            model,
            api_key_encrypted: encryptApiKey(api_key),
            priority: priority || 10,
            enabled: true
        })
        .select()
        .single();

    if (error) return res.status(500).json({ error: error.message });
    res.json(data);
});

// DELETE /api/admin/providers/:id
router.delete('/providers/:id', async (req, res) => {
    if (!supabase) return res.status(500).json({ error: 'Supabase not configured' });

    const { error } = await supabase
        .from('ai_providers')
        .delete()
        .eq('id', req.params.id);

    if (error) return res.status(500).json({ error: error.message });
    res.json({ success: true });
});

// POST /api/admin/providers/:id/detect-models
router.post('/providers/:id/detect-models', async (req, res) => {
    if (!supabase) return res.status(500).json({ error: 'Supabase not configured' });

    try {
        // 1. Get provider config
        const { data: provider, error } = await supabase
            .from('ai_providers')
            .select('*')
            .eq('id', req.params.id)
            .single();

        if (error || !provider) {
            return res.status(404).json({ error: 'Provider not found' });
        }

        // Decrypt API key
        const apiKey = decryptApiKey(provider.api_key_encrypted);
        if (!apiKey) {
            return res.status(500).json({ error: 'Could not decrypt API key' });
        }

        // 2. Fetch models from provider
        console.log(`Fetching models from ${provider.base_url}/models...`);
        const response = await fetch(`${provider.base_url}/models`, {
            headers: {
                'Authorization': `Bearer ${apiKey}`
            }
        });

        if (!response.ok) {
            const text = await response.text();
            return res.status(response.status).json({ error: `Provider API error: ${text}` });
        }

        const data = await response.json();
        const models = data.data || [];

        // 3. Select best model
        // Priority: Vision models > GPT-4 > Claude 3 > Gemini > Others
        const keywords = ['vision', 'gpt-4o', 'claude-3', 'gemini', 'grok'];
        let bestModel = null;

        for (const keyword of keywords) {
            const match = models.find(m => m.id.toLowerCase().includes(keyword));
            if (match) {
                bestModel = match.id;
                break;
            }
        }

        // Fallback to first model if no specific keyword matched
        if (!bestModel && models.length > 0) {
            bestModel = models[0].id;
        }

        if (!bestModel) {
            return res.status(400).json({ error: 'No suitable models found' });
        }

        // 4. Update provider
        const { error: updateError } = await supabase
            .from('ai_providers')
            .update({ model: bestModel })
            .eq('id', req.params.id);

        if (updateError) {
            return res.status(500).json({ error: updateError.message });
        }

        res.json({
            success: true,
            models: models.map(m => m.id),
            selected_model: bestModel,
            message: `Updated model to ${bestModel}`
        });

    } catch (e) {
        console.error('Auto-detect error:', e);
        res.status(500).json({ error: e.message });
    }
});

function decryptApiKey(encrypted) {
    if (!encrypted || !encryptionKey) return null;
    try {
        const [ivHex, encryptedHex] = encrypted.split(':');
        const iv = Buffer.from(ivHex, 'hex');
        const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(encryptionKey), iv);
        let decrypted = decipher.update(encryptedHex, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    } catch (e) {
        console.error('Decryption failed:', e);
        return null;
    }
}

// GET /api/admin/settings
router.get('/settings', async (req, res) => {
    if (!supabase) return res.status(500).json({ error: 'Supabase not configured' });

    const { data, error } = await supabase
        .from('ai_settings')
        .select('*');

    if (error) return res.status(500).json({ error: error.message });

    // Convert array to object for easier frontend consumption
    const settings = {};
    data.forEach(item => {
        settings[item.key] = item.value;
    });

    res.json(settings);
});

// PUT /api/admin/settings/:key
router.put('/settings/:key', async (req, res) => {
    if (!supabase) return res.status(500).json({ error: 'Supabase not configured' });

    const { value } = req.body;
    if (value === undefined) {
        return res.status(400).json({ error: 'Value is required' });
    }

    const { data, error } = await supabase
        .from('ai_settings')
        .upsert({
            key: req.params.key,
            value: value,
            updated_at: new Date()
        })
        .select()
        .single();

    if (error) return res.status(500).json({ error: error.message });
    res.json(data);
});

export default router;
