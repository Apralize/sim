#!/usr/bin/env python3
"""
Script para registrar webhook manualmente en SIM Studio BD
"""
import requests
import json

WORKFLOW_ID = "5d5129fb-d2b3-47f9-abc7-1235ff54b6d2"
BLOCK_ID = "b31e03bf-da5e-478a-bc53-84ec19c3b668"
PATH = "b31e03bf-da5e-478a-bc53-84ec19c3b668"

webhook_data = {
    "workflowId": WORKFLOW_ID,
    "blockId": BLOCK_ID,
    "path": PATH,
    "provider": "generic",
    "providerConfig": {
        "triggerId": "generic_webhook",
        "requireAuth": False,
        "token": None,
        "inputFormat": [
            {"name": "nombre", "type": "string"},
            {"name": "email", "type": "string"},
            {"name": "fecha", "type": "string"},
            {"name": "estado", "type": "string"}
        ]
    }
}

print("=" * 60)
print("Registrando webhook en SIM Studio BD...")
print("=" * 60)
print(f"Workflow ID: {WORKFLOW_ID}")
print(f"Block ID: {BLOCK_ID}")
print(f"Path: {PATH}")
print("=" * 60)

try:
    response = requests.post(
        "http://localhost:3001/api/webhooks",
        headers={"Content-Type": "application/json"},
        json=webhook_data
    )
    
    print(f"\nStatus Code: {response.status_code}")
    print(f"Response: {response.text}")
    
    if response.status_code in [200, 201]:
        print("\n✅ Webhook registrado exitosamente!")
        data = response.json()
        if "webhook" in data:
            print(f"Webhook ID: {data['webhook'].get('id', 'N/A')}")
    else:
        print(f"\n❌ Error al registrar webhook: {response.status_code}")
        
except Exception as e:
    print(f"\n❌ Error: {str(e)}")
