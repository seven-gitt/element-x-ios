#!/bin/bash

echo "🔍 COMPLETE PUSH NOTIFICATION DEBUG"
echo "=================================="

echo ""
echo "📱 BƯỚC 1: Kiểm tra device token mới"
echo "------------------------------------"
echo "1. Mở Console app trên Mac"
echo "2. Kết nối iPhone"
echo "3. Tìm log: 🚨 DEVICE TOKEN FOR TESTING: [TOKEN]"
echo "4. Copy device token và paste vào đây:"
read -p "Device Token: " DEVICE_TOKEN

if [ -z "$DEVICE_TOKEN" ]; then
    echo "❌ Chưa có device token. Hãy cài app và lấy token trước!"
    exit 1
fi

echo ""
echo "📊 BƯỚC 2: Kiểm tra server status"
echo "--------------------------------"
echo "Kiểm tra Matrix server và push adapter..."

ssh root@178.16.137.171 << 'EOF'
echo "🔍 Matrix Synapse Status:"
docker ps | grep synapse

echo ""
echo "🔍 Push Adapter Status:"
docker ps | grep push-adapter

echo ""
echo "🔍 Push Adapter Logs (last 20 lines):"
docker logs matrix-push-adapter --tail=20

echo ""
echo "🔍 Synapse Logs (last 10 lines):"
docker logs matrix-synapse --tail=10
EOF

echo ""
echo "📊 BƯỚC 3: Kiểm tra device token trong database"
echo "----------------------------------------------"
ssh root@178.16.137.171 << EOF
echo "🔍 Tìm device token trong database:"
docker exec -it matrix-synapse psql -U synapse -d synapse -c "SELECT pushkey, app_id, profile_tag, kind, data FROM pushers WHERE pushkey LIKE '%$DEVICE_TOKEN%' OR pushkey LIKE '%$(echo $DEVICE_TOKEN | base64)%';"

echo ""
echo "🔍 Tất cả device tokens hiện tại:"
docker exec -it matrix-synapse psql -U synapse -d synapse -c "SELECT pushkey, app_id, profile_tag, kind FROM pushers WHERE app_id = 'io.sevenchat.sevenchat';"
EOF

echo ""
echo "📊 BƯỚC 4: Test push notification trực tiếp"
echo "-------------------------------------------"
cat > test_push_new_token.json << EOF
{
  "notification": {
    "devices": [
      {
        "app_id": "io.sevenchat.sevenchat",
        "pushkey": "$DEVICE_TOKEN",
        "data": {
          "default_payload": {
            "aps": {
              "alert": {
                "title": "🧪 Test Push - New Token",
                "body": "Testing new device token - $(date)"
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
  -d @test_push_new_token.json

echo ""
echo "📊 BƯỚC 5: Kiểm tra APNS certificates"
echo "------------------------------------"
ssh root@178.16.137.171 << 'EOF'
echo "🔍 APNS Certificates:"
ls -la /root/matrix-synapse/certificates/

echo ""
echo "🔍 Push Adapter APNS Config:"
docker exec -it matrix-push-adapter cat /app/app.py | grep -A 10 -B 5 "APNS"
EOF

echo ""
echo "📊 BƯỚC 6: Kiểm tra app settings"
echo "-------------------------------"
echo "🔍 App Settings trong code:"
grep -r "pusherAppID\|pushGatewayNotifyEndpoint" ElementX/Sources/Application/Settings/ || echo "Không tìm thấy app settings"

echo ""
echo "📊 BƯỚC 7: Kiểm tra entitlements"
echo "-------------------------------"
echo "🔍 Entitlements:"
cat ElementX/SupportingFiles/ElementX.entitlements

echo ""
echo "📊 BƯỚC 8: Kiểm tra build configuration"
echo "--------------------------------------"
echo "🔍 Build Scheme:"
cat SevenChat.xcodeproj/xcshareddata/xcschemes/SevenChat.xcscheme | grep -A 5 -B 5 "buildConfiguration"

echo ""
echo "🎯 KẾT QUẢ DEBUG:"
echo "================="
echo "1. Device Token: $DEVICE_TOKEN"
echo "2. Server Status: ✅ Kiểm tra logs trên"
echo "3. Database: ✅ Kiểm tra tokens trên"
echo "4. Test Push: ✅ Đã gửi test notification"
echo "5. APNS: ✅ Kiểm tra certificates trên"
echo "6. App Config: ✅ Kiểm tra settings trên"
echo "7. Entitlements: ✅ Kiểm tra file trên"
echo "8. Build Config: ✅ Kiểm tra scheme trên"

echo ""
echo "📋 HƯỚNG DẪN TIẾP THEO:"
echo "======================="
echo "1. Kiểm tra iPhone có nhận được test notification không"
echo "2. Nếu không nhận được, kiểm tra logs trên server"
echo "3. Gửi tin nhắn thật trong app để test"
echo "4. Kiểm tra badge count có tăng không"
echo ""
echo "Hãy cho tôi biết kết quả từng bước!"
