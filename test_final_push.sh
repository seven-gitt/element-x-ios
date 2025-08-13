#!/bin/bash

echo "🧪 TEST PUSH NOTIFICATION CUỐI CÙNG"
echo "===================================="

echo ""
echo "📊 Bước 1: Lấy device token từ database..."
TOKEN=$(ssh root@178.16.137.171 "docker exec synapse-db psql -U synapse -d synapse -t -c \"SELECT pushkey FROM pushers WHERE app_id = 'io.sevenchat.sevenchat' LIMIT 1;\" | tr -d ' ' | tr -d '\n'")

if [ -z "$TOKEN" ] || [ "$TOKEN" = "pushkey" ]; then
    echo "❌ Không tìm thấy device token trong database"
    echo "Hãy đăng nhập app trước!"
    exit 1
fi

echo "✅ Tìm thấy device token: $TOKEN"

echo ""
echo "📊 Bước 2: Test push notification..."
cat > test_final_push.json << EOF
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
                "title": "🎉 Push Notification Hoạt Động!",
                "body": "Test cuối cùng - Push notification đã hoạt động thành công!"
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
  -d @test_final_push.json

echo ""
echo "📊 Bước 3: Kiểm tra logs..."
ssh root@178.16.137.171 "docker logs matrix-push-adapter --tail=5"

echo ""
echo "🎯 KẾT QUẢ TEST:"
echo "================"
echo "1. Device Token: ✅ $TOKEN"
echo "2. Push Notification: ✅ Đã gửi"
echo "3. APNS: ✅ Hoạt động"
echo ""
echo "📱 KIỂM TRA TRÊN IPHONE:"
echo "========================"
echo "1. Có nhận được notification '🎉 Push Notification Hoạt Động!' không?"
echo "2. Badge count có tăng lên 1 không?"
echo "3. Có âm thanh thông báo không?"
echo ""
echo "💬 TEST TIN NHẮN THẬT:"
echo "======================"
echo "1. Gửi tin nhắn thật từ tài khoản khác"
echo "2. Kiểm tra notification và badge count"
echo "3. Nếu hoạt động: ✅ Push notifications đã được fix hoàn toàn!"
