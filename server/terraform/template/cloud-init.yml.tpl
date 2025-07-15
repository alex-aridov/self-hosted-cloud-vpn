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

runcmd:
  - sleep 5
  - echo "nameserver 8.8.8.8" > /etc/resolv.conf
  - systemctl start firewalld
  - firewall-cmd --permanent --add-masquerade
  - firewall-cmd --permanent --add-port=51820/udp
  - systemctl reload firewalld

  - sysctl -w net.ipv4.ip_forward=1
  - echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

  - systemctl start wg-quick@wg0

final_message: "✅ cloud-init done"
