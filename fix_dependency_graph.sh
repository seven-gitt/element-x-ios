#!/bin/bash

echo "🔧 Fix Xcode Dependency Graph Error"
echo "==================================="

echo ""
echo "📊 Bước 1: Clean tất cả cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SevenChat-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Developer/Xcode/UserData/IDEPreferencesController.xcuserstate

echo "✅ Cleaned all caches"

echo ""
echo "📊 Bước 2: Reset Package Dependencies..."
rm -rf .build
rm -rf *.xcodeproj/project.xcworkspace/xcuserdata
rm -rf *.xcodeproj/xcuserdata

echo "✅ Reset package dependencies"

echo ""
echo "📊 Bước 3: Kiểm tra workspace files..."
if [ -f "SevenChat.xcodeproj/project.xcworkspace/contents.xcworkspacedata" ]; then
    echo "✅ Workspace file exists"
    cat SevenChat.xcodeproj/project.xcworkspace/contents.xcworkspacedata
else
    echo "❌ Workspace file missing"
fi

echo ""
echo "📊 Bước 4: Reset Xcode state..."
defaults delete com.apple.dt.Xcode
defaults delete com.apple.dt.XCBuild

echo "✅ Reset Xcode preferences"

echo ""
echo "📊 Bước 5: Thử resolve dependencies..."
xcodebuild -resolvePackageDependencies

echo ""
echo "📊 Bước 6: Kiểm tra project configuration..."
echo "Project file:"
ls -la SevenChat.xcodeproj/

echo ""
echo "📋 HÃY THỬ CÁC BƯỚC SAU TRONG XCODE:"
echo ""
echo "1. **Quit Xcode hoàn toàn**"
echo "2. **Mở lại Xcode**"
echo "3. **File > Open Recent > SevenChat.xcodeproj**"
echo "4. **File > Packages > Reset Package Caches**"
echo "5. **File > Packages > Resolve Package Versions**"
echo "6. **Product > Clean Build Folder**"
echo "7. **Product > Build**"
echo ""
echo "Nếu vẫn lỗi, thử:"
echo "1. **File > Close Workspace**"
echo "2. **File > Open > SevenChat.xcodeproj**"
echo "3. **Đợi Xcode index hoàn thành**"
echo "4. **Build lại**"
echo ""
echo "🔍 Nếu vẫn lỗi, hãy thử:"
echo "1. **Restart Mac**"
echo "2. **Mở Xcode**"
echo "3. **Open project**"
echo "4. **Build**"
