#!/bin/bash

echo "🔍 KIỂM TRA DEVICE TOKEN ĐĂNG KÝ"
echo "================================"

echo ""
echo "📊 Kiểm tra device tokens trong database..."
ssh root@178.16.137.171 "docker exec synapse-db psql -U synapse -d synapse -c \"SELECT pushkey, app_id, profile_tag, kind FROM pushers WHERE app_id = 'io.sevenchat.sevenchat';\""

echo ""
echo "📊 Kiểm tra push adapter logs (last 10 lines)..."
ssh root@178.16.137.171 "docker logs matrix-push-adapter --tail=10"

echo ""
echo "📊 Kiểm tra Matrix Synapse logs (last 5 lines)..."
ssh root@178.16.137.171 "docker logs synapse --tail=5 | grep -i pusher"

echo ""
echo "🎯 KẾT QUẢ:"
echo "==========="
echo "Nếu có device token trong database: ✅ Đã đăng ký thành công"
echo "Nếu không có device token: ❌ Chưa đăng ký - cần đăng nhập app"
echo ""
echo "📋 HƯỚNG DẪN TIẾP THEO:"
echo "========================"
echo "1. Nếu chưa có token: Đăng nhập app và đợi 10-30 giây"
echo "2. Nếu đã có token: Gửi tin nhắn thật để test"
echo "3. Chạy lại script này để kiểm tra: ./check_device_token_registration.sh"
