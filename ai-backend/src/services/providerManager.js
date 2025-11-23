import { createClient } from '@supabase/supabase-js';
import crypto from 'crypto';

class ProviderManager {
  constructor() {
    this.providers = [];
    this.prompt = {
      system: "你是一个商品识别专家。请识别图片中的商品信息，必须返回严格的JSON格式，不要包含其他文字说明。\n\n返回格式示例：\n{\"name\": \"可口可乐汽水\", \"category\": \"饮料\", \"expiryDate\": \"2025-12-31\"}\n\n说明：\n- name: 商品名称，尽量详细\n- category: 从以下分类中选择最合适的一个：食品、饮料、化妆品、药品、电子产品、证件、零食、日用品、宠物用品、其他\n- expiryDate: 如果图片中能看到保质期或生产日期，请推算并返回格式为YYYY-MM-DD的日期；如果看不到，返回null",
      categories: ["食品", "饮料", "化妆品", "药品", "电子产品", "证件", "零食", "日用品", "宠物用品", "其他"]
    };

    // Initialize Supabase client
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

    if (supabaseUrl && supabaseKey) {
      this.supabase = createClient(supabaseUrl, supabaseKey);
    } else {
      console.warn('⚠️ Supabase credentials missing. Dynamic configuration disabled.');
    }

    this.encryptionKey = process.env.ENCRYPTION_KEY || 'default-dev-key-32-bytes-long-!!';
  }

  async init() {
    if (!this.supabase) {
      console.log('⚠️ Using local fallback configuration');
      // Fallback to local config if Supabase is not configured
      // ... (keep local config logic or just return empty)
      return;
    }

    try {
      // Load providers
      const { data: providersData, error: providersError } = await this.supabase
        .from('ai_providers')
        .select('*')
        .eq('enabled', true)
        .order('priority', { ascending: true });

      if (providersError) throw providersError;

      this.providers = providersData.map(p => ({
        id: p.provider_id,
        type: 'openai', // Assuming all are openai-compatible for now
        priority: p.priority,
        enabled: p.enabled,
        config: {
          baseUrl: p.base_url,
          model: p.model,
          apiKey: this.decryptApiKey(p.api_key_encrypted),
          maxTokens: p.max_tokens,
          temperature: p.temperature
        }
      }));

      // Load system prompt
      const { data: promptData, error: promptError } = await this.supabase
        .from('ai_settings')
        .select('value')
        .eq('key', 'system_prompt')
        .single();

      if (!promptError && promptData) {
        this.prompt.system = promptData.value;
        console.log('✅ Loaded custom system prompt');
      }

      console.log(`✅ Loaded ${this.providers.length} enabled providers from Supabase`);
    } catch (error) {
      console.error('❌ Failed to load providers from Supabase:', error.message);
    }

    // Force add GLM-4V-Flash as top priority (User Request)
    this.providers.unshift({
      id: 'glm-4v',
      type: 'openai',
      priority: 0,
      enabled: true,
      config: {
        baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
        model: 'glm-4v-flash',
        apiKey: '13f446399a874cbb9611b65f66dd5727.u6rzajQUuHW8uZc3',
        maxTokens: 1000,
        temperature: 0.1
      }
    });
    console.log('✅ Added GLM-4V-Flash provider');

    // Override with optimized prompt for accurate multi-item and quantity detection
    this.prompt.system = `你是一个专业的商品识别助手。请仔细分析图片中的所有商品，并返回严格的JSON格式。

【重要】如果图片中有多个相同或不同的商品，请分别列出每一种，并准确统计数量。特别注意：
1. 仔细观察图片中所有可见的商品
2. 如果有多个相同的商品，quantity应该是总数（例如：看到2瓶相同的可乐，quantity就是2）
3. 不同的商品应该作为不同的items返回

返回格式：
{
  "items": [
    {
      "name": "商品名称",
      "category": "分类",
      "expiryDate": "YYYY-MM-DD或null",
      "productionDate": "YYYY-MM-DD或null", 
      "shelfLifeDays": 数字或null,
      "quantity": 数量
    }
  ]
}

字段说明：
- name: 商品的完整名称（品牌+品类，如"可口可乐汽水"），尽量准确识别瓶身上的文字
- category: 从以下选择：饮料、食品、乳制品、肉类、药品、化妆品、证件、电子产品、零食、日用品、宠物用品、其他
- expiryDate: 过期日期（格式YYYY-MM-DD），如果看不到则为null
- productionDate: 生产日期（格式YYYY-MM-DD），如果看不到则为null
- shelfLifeDays: 根据商品类型估算的保质期天数（饮料通常365天，食品根据类型判断），如果无法估算则为null
- quantity: 该商品的数量（请仔细数清楚图片中这种商品有几个）

示例：
如果图片中有2瓶可乐和1瓶雪碧，应返回：
{
  "items": [
    {"name": "可口可乐", "category": "饮料", "quantity": 2, "shelfLifeDays": 365, ...},
    {"name": "雪碧", "category": "饮料", "quantity": 1, "shelfLifeDays": 365, ...}
  ]
}`;
    console.log('✅ Loaded optimized system prompt for multi-item detection');
  }

  decryptApiKey(encrypted) {
    if (!encrypted) return '';
    try {
      const [ivHex, encryptedHex] = encrypted.split(':');
      if (!ivHex || !encryptedHex) return encrypted; // Return as-is if not in format

      const iv = Buffer.from(ivHex, 'hex');
      const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(this.encryptionKey), iv);
      let decrypted = decipher.update(encryptedHex, 'hex', 'utf8');
      decrypted += decipher.final('utf8');
      return decrypted;
    } catch (e) {
      console.error('Decryption failed:', e.message);
      return '';
    }
  }

  async recognizeWithFallback(imageBase64) {
    // Reload providers periodically or on error? For now, just use cached.
    // Maybe reload if list is empty?
    if (this.providers.length === 0) {
      await this.init();
    }

    const errors = {};
    const attemptedProviders = [];

    for (const provider of this.providers) {
      if (!provider.config.apiKey) {
        console.log(`⚠️ Skipping ${provider.id}: No API key configured`);
        continue;
      }

      try {
        console.log(`🔍 Trying provider: ${provider.id}`);
        attemptedProviders.push(provider.id);

        const startTime = Date.now();
        const result = await this.callProvider(provider, imageBase64);
        const duration = Date.now() - startTime;

        // Log success
        this.logRequest(provider.id, true, null, duration);

        console.log(`✅ Success with ${provider.id}`);
        return {
          success: true,
          data: {
            ...result,
            provider: provider.id
          },
          metadata: {
            attemptedProviders,
            processedAt: new Date().toISOString()
          }
        };
      } catch (error) {
        console.error(`❌ ${provider.id} failed:`, error.message);
        errors[provider.id] = error.message;

        // Log failure
        this.logRequest(provider.id, false, error.message, 0);
      }
    }

    throw {
      code: 'ALL_PROVIDERS_FAILED',
      message: '所有AI服务商均识别失败',
      details: errors,
      attemptedProviders
    };
  }

  async logRequest(providerId, success, errorMessage, responseTime) {
    if (!this.supabase) return;

    try {
      await this.supabase.from('ai_provider_logs').insert({
        provider_id: providerId,
        success,
        error_message: errorMessage,
        response_time_ms: responseTime
      });
    } catch (e) {
      console.error('Failed to log request:', e.message);
    }
  }

  async callProvider(provider, imageBase64) {
    const response = await fetch(`${provider.config.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${provider.config.apiKey}`
      },
      body: JSON.stringify({
        model: provider.config.model,
        messages: [
          {
            role: 'system',
            content: this.prompt.system
          },
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: '请识别这个商品'
              },
              {
                type: 'image_url',
                image_url: {
                  url: `data:image/jpeg;base64,${imageBase64}`
                }
              }
            ]
          }
        ],
        max_tokens: provider.config.maxTokens,
        temperature: provider.config.temperature
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`API Error (${response.status}): ${errorText}`);
    }

    const data = await response.json();

    if (!data.choices || !data.choices[0]) {
      throw new Error('Invalid API response format');
    }

    return this.parseAIResponse(data.choices[0].message.content);
  }

  parseAIResponse(content) {
    console.log('AI Response:', content);

    // Try to extract JSON from response
    const jsonMatch = content.match(/\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}/);
    if (jsonMatch) {
      try {
        const parsed = JSON.parse(jsonMatch[0]);

        // Normalize response to items array
        let items = [];
        if (parsed.items && Array.isArray(parsed.items)) {
          items = parsed.items;
        } else if (parsed.name) {
          // Single item response fallback
          items = [parsed];
        }

        // Process each item
        const processedItems = items.map(item => {
          // Calculate expiry date from shelf life if missing
          let expiryDate = item.expiryDate;
          if (!expiryDate && item.shelfLifeDays) {
            const days = parseInt(item.shelfLifeDays);
            if (!isNaN(days)) {
              const date = new Date();
              date.setDate(date.getDate() + days);
              expiryDate = date.toISOString().split('T')[0];
            }
          }

          return {
            name: item.name || 'Unknown',
            category: item.category || '其他',
            expiryDate: expiryDate || null,
            productionDate: item.productionDate || null,
            shelfLifeDays: item.shelfLifeDays || null,
            quantity: item.quantity || 1
          };
        });

        return {
          items: processedItems,
          confidence: 0.85
        };
      } catch (e) {
        console.error('JSON parse error:', e);
      }
    }

    throw new Error('无法解析AI响应为有效JSON');
  }
}

export default ProviderManager;
