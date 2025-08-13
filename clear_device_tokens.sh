#!/bin/bash

echo "🗑️ Clear Old Device Tokens"
echo "=========================="

echo ""
echo "📊 Bước 1: Kiểm tra device tokens hiện tại..."
ssh root@178.16.137.171 "docker exec synapse python3 -c \"import psycopg2; conn = psycopg2.connect('postgresql://synapse:synapse@synapse-db/synapse'); cur = conn.cursor(); cur.execute('SELECT COUNT(*) FROM pushers WHERE app_id LIKE \\\"%sevenchat%\\\"'); result = cur.fetchone(); print('Current device tokens:', result[0]); conn.close()\""

echo ""
echo "📊 Bước 2: Xóa tất cả device tokens cũ..."
ssh root@178.16.137.171 "docker exec synapse python3 -c \"import psycopg2; conn = psycopg2.connect('postgresql://synapse:synapse@synapse-db/synapse'); cur = conn.cursor(); cur.execute('DELETE FROM pushers WHERE app_id LIKE \\\"%sevenchat%\\\"'); conn.commit(); print('Deleted', cur.rowcount, 'device tokens'); conn.close()\""

echo ""
echo "📊 Bước 3: Xác nhận đã xóa..."
ssh root@178.16.137.171 "docker exec synapse python3 -c \"import psycopg2; conn = psycopg2.connect('postgresql://synapse:synapse@synapse-db/synapse'); cur = conn.cursor(); cur.execute('SELECT COUNT(*) FROM pushers WHERE app_id LIKE \\\"%sevenchat%\\\"'); result = cur.fetchone(); print('Remaining device tokens:', result[0]); conn.close()\""

echo ""
echo "📊 Bước 4: Clear push adapter cache..."
ssh root@178.16.137.171 "docker restart matrix-push-adapter"

echo ""
echo "✅ DEVICE TOKENS CLEARED!"
echo ""
echo "📱 Bây giờ hãy:"
echo "   1. Xóa app khỏi iPhone"
echo "   2. Build app mới trong Xcode"
echo "   3. Cài đặt app mới lên iPhone"
echo "   4. Mở app và đăng nhập"
echo "   5. Kiểm tra device token mới trong logs"
echo ""
echo "🔍 Để kiểm tra device token mới:"
echo "   - Mở Console app trên Mac"
echo "   - Kết nối iPhone qua USB"
echo "   - Filter logs với 'SevenChat'"
echo "   - Tìm log: '🚨 DEVICE TOKEN FOR TESTING: [token]'"
