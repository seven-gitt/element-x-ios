#!/bin/bash

echo "🚀 Quick Build Check"
echo "==================="

echo ""
echo "📊 Bước 1: Kiểm tra device..."
xcrun devicectl list devices | grep "00008130-000824510183001C"

echo ""
echo "📊 Bước 2: Build nhanh..."
xcodebuild -scheme SevenChat -configuration Release -destination 'platform=iOS,id=00008130-000824510183001C' build 2>&1 | grep -E "(BUILD SUCCEEDED|BUILD FAILED|error:|warning:)" | tail -10

echo ""
echo "📊 Bước 3: Kiểm tra app đã build..."
find ~/Library/Developer/Xcode/DerivedData -name "*.app" -path "*SevenChat*" -type d 2>/dev/null | head -5

echo ""
echo "✅ Hoàn thành kiểm tra build!"
