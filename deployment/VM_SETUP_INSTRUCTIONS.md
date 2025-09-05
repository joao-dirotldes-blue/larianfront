# Instruções de Setup da VM para Produção

## Informações da VM
- **IP**: `34.68.64.59`
- **Sistema Operacional Recomendado**: Ubuntu 22.04 LTS
- **Requisitos Mínimos**: 2 vCPUs, 4GB RAM, 20GB SSD

## 1. Conectar na VM via SSH

```bash
ssh root@34.68.64.59
# ou
ssh seu-usuario@34.68.64.59
```

## 2. Atualizar o Sistema

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git vim
```

## 3. Instalar Docker

```bash
# Remover versões antigas
sudo apt-get remove docker docker-engine docker.io containerd runc

# Instalar dependências
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Adicionar chave GPG oficial do Docker
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Adicionar repositório (para DEBIAN)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Testar instalação
docker --version
docker compose version
```

## 4. Configurar Firewall

```bash
# Instalar UFW se não estiver instalado
sudo apt install -y ufw

# Configurar regras básicas
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Permitir SSH (IMPORTANTE: não bloquear SSH!)
sudo ufw allow 22/tcp

# Permitir HTTP e HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Ativar firewall
sudo ufw --force enable

# Verificar status
sudo ufw status
```

## 5. Clonar Repositórios e Deploy

```bash
# Criar diretório de trabalho
mkdir -p /opt/larian
cd /opt/larian

# Clonar repositórios
git clone https://github.com/sounuv/gufly-agency-front.git
git clone https://github.com/sounuv/gufly-seller-front.git

# Copiar arquivos de deployment
# Você precisa fazer upload dos arquivos da pasta deployment para a VM
# Use SCP do seu computador local:
```

No seu computador local, execute:
```bash
# Fazer upload da pasta deployment
cd "/Users/diroteldes/Documents/Larian NOVO Front"
scp -r deployment/ root@34.68.64.59:/opt/larian/
```

## 6. Configurar e Executar o Deploy

Na VM:
```bash
cd /opt/larian/deployment

# Tornar script executável
chmod +x deploy.sh

# Editar arquivo de environment se necessário
nano .env.production

# Executar deploy
./deploy.sh deploy
```

## 7. Configurar SSL com Let's Encrypt

```bash
# Depois do deploy inicial funcionar
cd /opt/larian/deployment
./deploy.sh ssl
```

## 8. Configurar Auto-start no Boot

```bash
# Criar serviço systemd
sudo nano /etc/systemd/system/larian-app.service
```

Adicione o conteúdo:
```ini
[Unit]
Description=Larian App Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/larian/deployment
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

```bash
# Ativar serviço
sudo systemctl enable larian-app.service
sudo systemctl start larian-app.service
sudo systemctl status larian-app.service
```

## 9. Configurar Backups Automáticos (Opcional)

```bash
# Criar script de backup
sudo nano /opt/larian/backup.sh
```

Adicione:
```bash
#!/bin/bash
BACKUP_DIR="/backups/larian"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup dos volumes Docker
docker run --rm \
  -v larian-nginx-cache:/data \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/nginx-cache-$DATE.tar.gz -C /data .

# Manter apenas últimos 7 backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

```bash
# Tornar executável
chmod +x /opt/larian/backup.sh

# Adicionar ao crontab para rodar diariamente às 3AM
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/larian/backup.sh") | crontab -
```

## 10. Monitoramento e Logs

### Ver logs em tempo real
```bash
cd /opt/larian/deployment
./deploy.sh logs
```

### Ver logs de um serviço específico
```bash
./deploy.sh logs nginx
./deploy.sh logs agency
./deploy.sh logs seller
```

### Monitorar recursos do Docker
```bash
docker stats
```

### Verificar espaço em disco
```bash
df -h
du -sh /var/lib/docker/
```

## 11. Comandos Úteis de Manutenção

```bash
# Reiniciar aplicações
cd /opt/larian/deployment
./deploy.sh restart

# Parar aplicações
./deploy.sh stop

# Atualizar código e fazer redeploy
./deploy.sh update

# Limpar recursos não utilizados do Docker
./deploy.sh cleanup

# Verificar status dos containers
docker ps -a

# Ver uso de recursos
docker system df

# Logs do sistema
journalctl -u docker -f
```

## 12. Troubleshooting

### Problema: Containers não iniciam
```bash
# Verificar logs
docker compose logs -f

# Verificar se portas estão em uso
sudo netstat -tulpn | grep -E ':(80|443)'

# Reiniciar Docker
sudo systemctl restart docker
```

### Problema: Falta de espaço
```bash
# Limpar imagens não usadas
docker system prune -af

# Limpar logs
sudo truncate -s 0 /var/lib/docker/containers/*/*-json.log
```

### Problema: Performance lenta
```bash
# Verificar uso de CPU/Memória
top
htop

# Verificar I/O do disco
iotop

# Ajustar limites do Docker se necessário
sudo nano /etc/docker/daemon.json
```

## 13. Segurança Adicional

### Configurar fail2ban
```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Desabilitar root SSH (após configurar usuário)
```bash
sudo nano /etc/ssh/sshd_config
# Definir: PermitRootLogin no
sudo systemctl restart sshd
```

### Configurar atualizações automáticas de segurança
```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

## URLs de Acesso

Após completar o setup:
- **Agency**: http://34.68.64.59/agency ou https://larian.app/agency
- **Seller**: http://34.68.64.59/seller ou https://larian.app/seller

## Suporte

Em caso de problemas:
1. Verificar logs: `./deploy.sh logs`
2. Verificar status do Docker: `docker ps -a`
3. Verificar conectividade: `curl -I http://localhost/health`
4. Verificar DNS: `nslookup larian.app`