#!/bin/bash

SERVER="root@sg.tvlt.cn"
REMOTE_DIR="/root/expiry-ai-backend"

echo "🚀 Starting deployment to $SERVER..."

# 1. Create remote directory
ssh $SERVER "mkdir -p $REMOTE_DIR"

# 2. Sync files (excluding node_modules and git)
echo "📦 Syncing files..."
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude '.DS_Store' ./ $SERVER:$REMOTE_DIR

# 3. Build and restart Docker containers
echo "🔄 Rebuilding and restarting containers..."
ssh $SERVER "cd $REMOTE_DIR && docker compose down && docker compose up -d --build"

echo "✅ Deployment complete!"
echo "📡 Backend should be running at http://sg.tvlt.cn:7777"
