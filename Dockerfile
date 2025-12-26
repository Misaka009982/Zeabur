FROM eceasy/cli-proxy-api-plus:latest
LABEL "language"="docker"

RUN apk add --no-cache openssh-server openssh-client

RUN mkdir -p /run/sshd /root/.ssh && chmod 700 /root/.ssh

RUN cat > /etc/ssh/sshd_config << 'EOF'
Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTH
LogLevel INFO
PermitRootLogin yes
StrictModes yes
MaxAuthTries 6
MaxSessions 10
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2
HostbasedAuthentication no
IgnoreRhosts yes
PasswordAuthentication yes
PermitEmptyPasswords no
AllowAgentForwarding yes
AllowTcpForwarding yes
GatewayPorts yes
X11Forwarding yes
X11UseLocalhost no
PermitTTY yes
ClientAliveInterval 0
ClientAliveCountMax 3
EOF

RUN ssh-keygen -A

ENV SSH_PASSWORD=password
ENV SSH_PUBLIC_KEY=
ENV TZ=Asia/Shanghai

EXPOSE 22 8317

RUN printf '#!/bin/sh\necho "root:${SSH_PASSWORD}" | chpasswd\n/usr/sbin/sshd\nexec /CLIProxyAPI/CLIProxyAPIPlus --config /data/config.yaml\n' > /start.sh && chmod +x /start.sh

CMD ["/start.sh"]
