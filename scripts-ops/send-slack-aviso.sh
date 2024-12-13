#!/bin/sh

# Endpoint do canal do slack sd-noc-tabajara
SLACK_NOC_API="https://hooks.slack.com/services/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"

MSG=`cat /usr/local/bin/send-slack/message.txt`
JSON_SLACK="/usr/local/bin/send-slack/message.json"

export http_proxy=http://proxy.tabajara.intranet:3130
export https_proxy=https://proxy.tabajara.intranet:3130

cat > $JSON_SLACK <<END
{
 "channel": "#general",
 "username": "webhookbot",
 "text": "$MSG",
 "icon_emoji": ":biohazard_sign:"
}
END

curl -X POST -H 'Content-Type: data-urlencode' -d@$JSON_SLACK $SLACK_NOC_API

