#!/bin/bash

echo "🔧 FIX TỰ ĐỘNG ĐĂNG KÝ DEVICE TOKEN"
echo "===================================="

echo ""
echo "📊 Bước 1: Xóa device token cũ khỏi database..."
ssh root@178.16.137.171 "docker exec synapse-db psql -U synapse -d synapse -c \"DELETE FROM pushers WHERE app_id = 'io.sevenchat.sevenchat';\""

echo ""
echo "📊 Bước 2: Kiểm tra database đã sạch..."
ssh root@178.16.137.171 "docker exec synapse-db psql -U synapse -d synapse -c \"SELECT COUNT(*) FROM pushers WHERE app_id = 'io.sevenchat.sevenchat';\""

echo ""
echo "📊 Bước 3: Kiểm tra push adapter logs..."
ssh root@178.16.137.171 "docker logs matrix-push-adapter --tail=5"

echo ""
echo "📋 HƯỚNG DẪN FIX:"
echo "=================="
echo "1. Mở app SevenChat trên iPhone"
echo "2. Đăng nhập vào tài khoản"
echo "3. Đợi 10-30 giây để app tự động đăng ký device token mới"
echo "4. Kiểm tra logs trong Console app:"
echo "   - Tìm: 🚨 [AppCoordinator] 🔧 Auto-registering device token"
echo "   - Tìm: 🚨 SUCCESS: Device token registered with Matrix server!"
echo "5. Gửi tin nhắn thật từ tài khoản khác"
echo "6. Kiểm tra notification và badge count"
echo ""

echo "🔍 Kiểm tra sau khi đăng nhập:"
echo "=============================="
echo "Sau khi bạn đăng nhập app, chạy lệnh sau để kiểm tra:"
echo ""
echo "ssh root@178.16.137.171 \"docker exec synapse-db psql -U synapse -d synapse -c \\\"SELECT pushkey, app_id, profile_tag, kind FROM pushers WHERE app_id = 'io.sevenchat.sevenchat';\\\"\""
echo ""

echo "✅ Hoàn thành setup fix!"
