#cloud-config
package_update: true
package_upgrade: false
packages:
  - epel-release
  - wireguard-tools
  - firewalld

chpasswd:
  expire: false

ssh_pwauth: true

write_files:
  - path: /etc/wireguard/wg0.conf
    permissions: '0600'
    owner: root:root
    content: |
      ${indent(6, wireguard_config)}

users:
  - name: admin
    groups: wheel
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: ${server.password}

runcmd:
  - sleep 5
  - echo "nameserver 8.8.8.8" > /etc/resolv.conf
  - systemctl start firewalld
  - firewall-cmd --permanent --add-masquerade
  - firewall-cmd --permanent --add-port=51820/udp
  - systemctl reload firewalld

  - sysctl -w net.ipv4.ip_forward=1
  - echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

  - EXTERNAL_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
  - |
    for i in $(seq 1 10); do
      ping -c1 dynv6.com && break
      echo "Waiting for dynv6.com DNS resolution... attempt $i"
      sleep 2
    done
  - curl -v "https://dynv6.com/api/update?hostname=${server.dns.host}&ipv4=$EXTERNAL_IP&token=${server.dns.token}"
  - systemctl start wg-quick@wg0

final_message: "✅ cloud-init done"
