#!/bin/bash
`useradd` -M -r -s /bin/false alertmanager
`which wget` -q https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
tar xzvf alertmanager-0.24.0.linux-amd64.tar.gz -C /tmp
cp -pr /tmp/alertmanager-0.24.0.linux-amd64/{alertmanager,amtool} /usr/local/bin
cp -pr /tmp/alertmanager-0.24.0.linux-amd64/alertmanager.yml /etc/alertmanager/
mkdir -p /var/lib/alertmanager
chown alertmanager:alertmanager /var/lib/alertmanager
mkdir -p /etc/amtool 

cat > /etc/amtool/config.yml <<END
alertmanager.url: http://localhost:9093
END


cat > /etc/systemd/system/alertmanager.service <<END

[Unit]
Description=Prometheus Alertmanager
Start and enable the alertmanager service:
Verify the service is running and you can reach it:
You can also access Alertmanager in a web browser at http://
<PROMETHEUS_SERVER_PUBLIC_IP>:9093.
Verify amtool is able to connect to Alertmanager and retrieve the current
configuration:
Configure Prometheus to Connect to Alertmanager
Edit the Prometheus config:
Wants=network-online.target
After=network-online.target
[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
 --config.file /etc/alertmanager/alertmanager.yml \
 --storage.path /var/lib/alertmanager/
[Install]
WantedBy=multi-user.target

END
systemctl daemon-reload
systemctl enable alertmanager
systemctl start alertmanager

curl localhost:9093
amtool config show

