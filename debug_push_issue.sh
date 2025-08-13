#!/bin/bash

echo "🔍 DEBUG PUSH NOTIFICATION ISSUE"
echo "================================"

echo ""
echo "📊 Bước 1: Kiểm tra device tokens trong database..."
ssh root@178.16.137.171 "docker exec synapse-db psql -U synapse -d synapse -c \"SELECT pushkey, app_id, profile_tag, kind FROM pushers WHERE app_id = 'io.sevenchat.sevenchat';\""

echo ""
echo "📊 Bước 2: Kiểm tra user sessions..."
ssh root@178.16.137.171 "docker exec synapse-db psql -U synapse -d synapse -c \"SELECT user_id, device_id, display_name FROM user_ips WHERE user_id LIKE '%lequan%' ORDER BY last_seen DESC LIMIT 5;\""

echo ""
echo "📊 Bước 3: Kiểm tra push adapter logs..."
ssh root@178.16.137.171 "docker logs matrix-push-adapter --tail=10"

echo ""
echo "📊 Bước 4: Kiểm tra Matrix server logs..."
ssh root@178.16.137.171 "docker logs synapse --tail=20 | grep -E '(pusher|setPusher|POST.*pusher)'"

echo ""
echo "📊 Bước 5: Test device token hiện tại..."
TOKEN="rL+EWYBHTUy8JAcG2Ha2RZ8Dt2PSmfbCLNKvyJ2lyH8="
cat > test_current_token.json << EOF
{
  "notification": {
    "devices": [
      {
        "app_id": "io.sevenchat.sevenchat",
        "pushkey": "$TOKEN",
        "data": {
          "default_payload": {
            "aps": {
              "alert": {
                "title": "🔍 Debug Test",
                "body": "Testing current device token - $(date)"
              },
              "sound": "default",
              "badge": 1,
              "mutable-content": 1
            }
          }
        },
        "tweaks": {
          "sound": "default"
        }
      }
    ]
  }
}
EOF

echo "🔍 Gửi test push notification..."
curl -X POST https://sevenchat.space/_matrix/push/v1/notify \
  -H "Content-Type: application/json" \
  -d @test_current_token.json

echo ""
echo "📊 Bước 6: Kiểm tra logs sau test..."
ssh root@178.16.137.171 "docker logs matrix-push-adapter --tail=5"

echo ""
echo "🎯 PHÂN TÍCH VẤN ĐỀ:"
echo "==================="
echo "1. Device token không hợp lệ với APNS"
echo "2. App có thể chưa đăng ký device token với Matrix server"
echo "3. Cần kiểm tra logs trong Console app trên Mac"
echo ""
echo "📋 HƯỚNG DẪN DEBUG:"
echo "=================="
echo "1. Mở Console app trên Mac"
echo "2. Kết nối iPhone"
echo "3. Tìm logs:"
echo "   - 🚨 [AppCoordinator] 🔧 FORCE: Triggering device token registration"
echo "   - 🚨 [AppCoordinator] 🎫 Received device token from APNS"
echo "   - 🚨 SUCCESS: Device token registered with Matrix server!"
echo "4. Nếu không thấy logs này, app chưa đăng ký device token"
echo ""
echo "🔧 GIẢI PHÁP:"
echo "============="
echo "1. Đảm bảo app đã đăng nhập"
echo "2. Đợi 10-30 giây sau khi đăng nhập"
echo "3. Kiểm tra notification permissions"
echo "4. Restart app nếu cần"
