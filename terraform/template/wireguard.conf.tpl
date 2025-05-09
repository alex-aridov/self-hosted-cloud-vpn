[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = ${server.private_key}

%{ for peer in peers ~}
[Peer]
PublicKey = ${peer.public_key}
AllowedIPs = ${peer.allowed_ips}

%{ endfor ~}