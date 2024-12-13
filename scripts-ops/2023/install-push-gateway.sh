#!/bin/bash
`useradd` -M -r -s /bin/false pushgateway
`which wget` -q https://github.com/prometheus/pushgateway/releases/download/v1.4.3/pushgateway-1.4.3.linux-amd64.tar.gz
tar xzvf pushgateway-1.4.3.linux-amd64.tar.gz -C /tmp
cp -pr /tmp/pushgateway-1.4.3.linux-amd64/pushgateway /usr/local/bin/
chown pushgateway:pushgateway /usr/local/bin/pushgateway


cat > /etc/systemd/system/pushgateway.service <<END

[Unit]
Description=Prometheus Pushgateway
Wants=network-online.target
After=network-online.target
[Service]
User=pushgateway
Group=pushgateway
Type=simple
ExecStart=/usr/local/bin/pushgateway
[Install]
WantedBy=multi-user.target

END
systemctl daemon-reload
systemctl start pushgateway
systemctl enable pushgateway

curl localhost:9091/metrics

