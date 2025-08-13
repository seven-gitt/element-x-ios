#!/bin/bash

echo "🔧 FIX SERVER FOR PRODUCTION APNS"
echo "=================================="

echo ""
echo "📊 Bước 1: Xóa tất cả device tokens cũ..."
ssh root@178.16.137.171 "docker exec synapse-db psql -U synapse -d synapse -c \"DELETE FROM pushers WHERE app_id = 'io.sevenchat.sevenchat';\""

echo ""
echo "📊 Bước 2: Kiểm tra APNS certificates..."
ssh root@178.16.137.171 "ls -la /root/matrix-synapse/certificates/ | grep -E '(prod|apns)'"

echo ""
echo "📊 Bước 3: Kiểm tra push adapter configuration..."
ssh root@178.16.137.171 "docker exec matrix-push-adapter cat /app/app.py | grep -A 5 -B 5 'APNS_BUNDLE_ID'"

echo ""
echo "📊 Bước 4: Restart push adapter để đảm bảo Production APNS..."
ssh root@178.16.137.171 "docker restart matrix-push-adapter"

echo ""
echo "📊 Bước 5: Kiểm tra push adapter logs..."
ssh root@178.16.137.171 "docker logs matrix-push-adapter --tail=10"

echo ""
echo "📋 HƯỚNG DẪN TIẾP THEO:"
echo "========================"
echo "1. Build app với Ad Hoc Distribution"
echo "2. Cài app lên iPhone"
echo "3. Đăng nhập vào tài khoản"
echo "4. Đợi app đăng ký device token mới"
echo "5. Gửi tin nhắn thật để test"
echo ""
echo "🔍 Kiểm tra sau khi đăng nhập:"
echo "ssh root@178.16.137.171 \"docker exec synapse-db psql -U synapse -d synapse -c \\\"SELECT pushkey, app_id, profile_tag, kind FROM pushers WHERE app_id = 'io.sevenchat.sevenchat';\\\"\""
echo ""
echo "✅ Hoàn thành fix server!"
