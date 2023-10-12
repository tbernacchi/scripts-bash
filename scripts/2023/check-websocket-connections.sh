#!/bin/bash 
curl -s -i -N \
  --http1.1 \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Host: $FQDN" \
  -k https://$FQDN/v3/subscribe
