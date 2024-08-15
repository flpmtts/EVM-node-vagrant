#!/bin/bash

# Atualiza o sistema
sudo apt-get update && sudo apt-get upgrade -y

# Instala o Snapd e o Geth via Snap
sudo apt-get install -y snapd
sudo snap install geth

# Aguarda até que a instalação do Geth via Snap seja concluída
while sudo snap changes | grep -q "Doing"; do
    echo "Aguardando a instalação do Snap ser concluída..."
    sleep 10
done

# Cria os diretórios necessários em /tmp para evitar problemas de permissão
mkdir -p /tmp/ethereum_private_network/geth
mkdir -p /tmp/ethereum_private_network/keystore

# Remove qualquer arquivo antigo de serviço para garantir uma criação limpa
sudo rm -f /etc/systemd/system/geth.service

# Cria o serviço Geth
sudo bash -c 'cat > /etc/systemd/system/geth.service <<EOF
[Unit]
Description=Ethereum Go Client (geth)
After=network.target

[Service]
ExecStart=/snap/bin/geth --datadir /tmp/ethereum_private_network --networkid 1234 --rpc --rpcaddr 0.0.0.0 --rpcport 8545 --rpcapi "eth,net,web3,personal" --nousb
User=vagrant
Restart=on-failure
Environment=HOME=/home/vagrant
WorkingDirectory=/tmp/ethereum_private_network

[Install]
WantedBy=multi-user.target
EOF'

# Recarrega o daemon do systemd para reconhecer o novo serviço
sudo systemctl daemon-reload

# Ativa e inicia o serviço Geth
sudo systemctl enable geth
sudo systemctl start geth

# Verifica o status do serviço Geth
sudo systemctl status geth --no-pager

