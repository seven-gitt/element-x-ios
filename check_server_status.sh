#!/bin/bash

echo "🔍 QUICK SERVER STATUS CHECK"
echo "============================"

echo ""
echo "📊 Kiểm tra Matrix Synapse..."
ssh root@178.16.137.171 "docker ps | grep synapse"

echo ""
echo "📊 Kiểm tra Push Adapter..."
ssh root@178.16.137.171 "docker ps | grep push-adapter"

echo ""
echo "📊 Push Adapter Logs (last 10 lines):"
ssh root@178.16.137.171 "docker logs matrix-push-adapter --tail=10"

echo ""
echo "📊 Kiểm tra APNS certificates..."
ssh root@178.16.137.171 "ls -la /root/matrix-synapse/certificates/"

echo ""
echo "✅ Server status check completed!"
