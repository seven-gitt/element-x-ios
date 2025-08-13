#!/usr/bin/env python3
"""
Matrix Push Adapter for SevenChat - Fixed Version
Converts Matrix push requests to APNS notifications without duplicate detection
"""

from flask import Flask, request, jsonify
import requests
import json
from datetime import datetime
import jwt
import time
import httpx

app = Flask(__name__)

# APNS Configuration
APNS_KEY_ID = "3457U7NB83"  # Key ID for Push Notification
APNS_TEAM_ID = "C828KUUV54"  # Your Team ID
APNS_BUNDLE_ID = "io.sevenchat.sevenchat"

@app.route('/_matrix/push/v1/notify', methods=['POST'])
def matrix_push_notify():
    """Handle Matrix push notification requests"""
    try:
        data = request.get_json()
        print(f"🔥 RECEIVED PUSH REQUEST: {data}", flush=True)

        # Extract Matrix notification data
        notification = data.get('notification', {})
        devices = notification.get('devices', [])

        results = []

        for device in devices:
            # Extract device info
            pushkey = device.get('pushkey', '')  # This is APNS device token
            app_id = device.get('app_id', '')
            
            print(f"📱 DEVICE: pushkey={pushkey[:20]}..., app_id={app_id}", flush=True)

            # Skip if not SevenChat (accept both bundle IDs)
            if not (app_id.startswith('io.sevenchat.sevenchat')):
                print(f"❌ SKIPPING non-SevenChat app: {app_id}", flush=True)
                continue
                
            print(f"✅ PROCESSING SevenChat app: {app_id}", flush=True)

            # Send to APNS with auto environment detection
            print(f"🚀 SENDING TO APNS: device={pushkey[:20]}..., notification_id={notification.get('id', 'unknown')}", flush=True)
            success = send_to_apns_with_auto_detect(pushkey, notification)
            print(f"📊 APNS RESULT: {'SUCCESS' if success else 'FAILED'}", flush=True)
            
            if not success:
                results.append({
                    "pushkey": pushkey,
                    "reason": "failed_to_deliver"
                })

        return jsonify({
            "rejected": results
        })

    except Exception as e:
        print(f"Error handling Matrix push: {e}")
        return jsonify({"error": str(e)}), 500

def send_to_apns_with_auto_detect(device_token, notification):
    """Send notification to APNS with automatic environment detection"""
    
    # Read APNS auth key (P8 format)
    try:
        with open('/certificates/apns-auth-key.p8', 'r') as f:
            private_key = f.read()
    except Exception as e:
        print(f"❌ Error reading APNS key: {e}")
        return False

    # Create JWT token
    try:
        payload = {
            'iss': APNS_TEAM_ID,
            'iat': int(time.time())
        }
        headers = {
            'kid': APNS_KEY_ID,
            'alg': 'ES256'
        }
        jwt_token = jwt.encode(payload, private_key, algorithm='ES256', headers=headers)
    except Exception as e:
        print(f"❌ Error creating JWT: {e}")
        return False

    # Try both environments: Production first, then Sandbox
    environments = [
        ("production", "https://api.push.apple.com/3/device/"),
        ("sandbox", "https://api.sandbox.push.apple.com/3/device/")
    ]

    for env_name, base_url in environments:
        apns_url = f"{base_url}{device_token}"
        
        # Create APNS payload
        apns_payload = {
            "aps": {
                "alert": {
                    "title": "SevenChat",
                    "body": "Bạn có tin nhắn mới"
                },
                "sound": "default",
                "badge": 1,
                "mutable-content": 1
            }
        }

        try:
            with httpx.Client(http2=True) as client:
                response = client.post(
                    apns_url,
                    headers={
                        'Authorization': f'Bearer {jwt_token}',
                        'Content-Type': 'application/json',
                        'apns-topic': APNS_BUNDLE_ID,
                        'apns-push-type': 'alert'
                    },
                    json=apns_payload,
                    timeout=30
                )

            print(f"APNS {env_name} Response: {response.status_code} - {response.text}")
            
            if response.status_code == 200:
                print(f"✅ SUCCESS: Notification sent via {env_name} APNS")
                return True
            elif response.status_code == 400:
                error_data = response.json()
                if error_data.get("reason") == "BadDeviceToken":
                    print(f"⚠️ BadDeviceToken in {env_name}, trying next environment...")
                    continue
                else:
                    print(f"❌ APNS {env_name} error: {error_data}")
                    return False
            else:
                print(f"❌ APNS {env_name} unexpected status: {response.status_code}")
                continue

        except Exception as e:
            print(f"❌ Error sending to APNS {env_name}: {e}")
            continue

    print("❌ Failed to send notification to both environments")
    return False

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "ok",
        "service": "Matrix Push Adapter (Fixed Version)",
        "timestamp": datetime.now().isoformat(),
        "apns_key_id": APNS_KEY_ID,
        "bundle_id": APNS_BUNDLE_ID
    })

@app.route('/', methods=['GET'])
def info():
    """Info endpoint"""
    return jsonify({
        "service": "Matrix Push Adapter",
        "version": "2.0",
        "description": "Fixed version without duplicate detection"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6000, debug=False)
