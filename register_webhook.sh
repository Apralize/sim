#!/bin/bash
# Script para registrar webhook manualmente en SIM Studio

WORKFLOW_ID="5d5129fb-d2b3-47f9-abc7-1235ff54b6d2"
BLOCK_ID="b31e03bf-da5e-478a-bc53-84ec19c3b668"
PATH="b31e03bf-da5e-478a-bc53-84ec19c3b668"

curl -v -X POST http://localhost:3001/api/webhooks \
  -H "Content-Type: application/json" \
  -d "{
    \"workflowId\": \"$WORKFLOW_ID\",
    \"blockId\": \"$BLOCK_ID\",
    \"path\": \"$PATH\",
    \"provider\": \"generic\",
    \"providerConfig\": {
      \"triggerId\": \"generic_webhook\",
      \"requireAuth\": false,
      \"token\": null,
      \"inputFormat\": [
        {\"name\": \"nombre\", \"type\": \"string\"},
        {\"name\": \"email\", \"type\": \"string\"},
        {\"name\": \"fecha\", \"type\": \"string\"},
        {\"name\": \"estado\", \"type\": \"string\"}
      ]
    }
  }"
