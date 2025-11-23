# AI Recognition Backend

Backend service for the Expiry Tracker App's AI recognition feature.

## Features

- ✅ Multi-provider support (OpenAI, DeepSeek, Qwen, etc.)
- ✅ Automatic failover when one provider fails
- ✅ OpenAI-compatible API interface
- ✅ Easy configuration via JSON and environment variables

## Setup

1. Install dependencies:
```bash
cd ai-backend
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env
# Edit .env and add your API keys
```

3. Start the server:
```bash
npm start
# or for development with auto-reload
npm run dev
```

## API Usage

### POST /api/v1/recognize

**Request:**
```json
{
  "image": "base64_encoded_image_string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "name": "可口可乐汽水",
    "category": "饮料",
    "expiryDate": "2025-12-31",
    "confidence": 0.85,
    "provider": "openai-gpt4o"
  },
  "metadata": {
    "attemptedProviders": ["openai-gpt4o"],
    "processedAt": "2025-11-23T14:30:00Z"
  }
}
```

## Provider Configuration

Edit `src/config/providers.json` to:
- Add/remove providers
- Change priority order
- Enable/disable providers
- Adjust model parameters

## Deployment

### Vercel
```bash
vercel deploy
```

### Railway
```bash
railway up
```

### Docker
```bash
docker build -t ai-backend .
docker run -p 3000:3000 --env-file .env ai-backend
```
