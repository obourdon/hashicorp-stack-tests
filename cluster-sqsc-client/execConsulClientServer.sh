DEFAULT_IP=172.16.0.2
IP="${1:-$DEFAULT_IP}"

mkdir -p /etc/consul.d

cat >/etc/consul.d/config.hcl <<EOF
data_dir = "/var/lib/consul"

retry_join = [ "172.16.0.2", "172.16.0.3", "172.16.0.4" ]

connect {
  enabled = true
}
EOF

cat >/etc/systemd/system/consul.service <<EOF
[Unit]
Description=Consul Service Discovery Agent
Documentation=https://www.consul.io/
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/opt/bin/consul agent \
  -config-dir=/etc/consul.d \
  -client=0.0.0.0 \
  -ui \
  -server \
  -bootstrap-expect=3 \
  -advertise=$IP \
  -encrypt=TeLbPpWX41zMM3vfLwHHfQ==
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl enable consul.service
systemctl start consul
