#!/bin/bash

`which useradd` -M -r -s /bin/false node_exporter
`which wget` -q https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz --directory-prefix=/tmp
tar xzvf /tmp/node_exporter-1.4.0.linux-amd64.tar.gz -C /tmp
cp -pr /tmp/node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

cat > /etc/systemd/system/node_exporter.service <<END

[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target

END

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

echo "Checking metrics..."
curl localhost:9100/metrics

echo "node_exporter installed sucessfully, enjoy!"
