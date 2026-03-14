#!/bin/bash
# Import the blog workflow into n8n
# Usage: ./scripts/setup-n8n.sh

N8N_URL="http://localhost:5678"
N8N_API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhYjk2NWRkYy0zMDlkLTRjODYtYTI1OC0wZDFmZGIxOWIxZTEiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiNjU4NTY0YTMtMWRjMi00YTllLTlmOTEtN2JjZDQ2NjYyNzhmIiwiaWF0IjoxNzcyNDMwNjU2fQ.huZOTMIN1u9mt1PQoC4hE6qOn1LOkSEzKAinmufFYpQ"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Checking n8n connectivity..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_URL/api/v1/workflows")

if [ "$STATUS" != "200" ]; then
  echo "Error: n8n is not reachable at $N8N_URL (HTTP $STATUS)"
  echo "Make sure n8n is running: n8n start"
  exit 1
fi

echo "n8n is running. Creating workflow..."
RESPONSE=$(curl -s -X POST "$N8N_URL/api/v1/workflows" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d @"$SCRIPT_DIR/n8n-workflow.json")

WORKFLOW_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$WORKFLOW_ID" ]; then
  echo "Error creating workflow. Response:"
  echo "$RESPONSE"
  exit 1
fi

echo "Workflow created with ID: $WORKFLOW_ID"
echo ""
echo "Next steps:"
echo "1. Open n8n at $N8N_URL"
echo "2. Go to the 'Ikigai Blog — Weekly Article Generator' workflow"
echo "3. Set up the 'Anthropic API Key' credential (HTTP Header Auth):"
echo "   - Header Name: x-api-key"
echo "   - Header Value: your Anthropic API key"
echo "4. Activate the workflow"
echo ""
echo "To test manually, click 'Execute Workflow' in n8n."
echo ""
echo "Approval webhook URL will be shown in the execution log when the"
echo "workflow runs. Click the approve/reject link to publish or discard."
