# Larian App Deployment

Este repositório contém os arquivos de deployment para os projetos Gufly Agency e Gufly Seller.

## Estrutura

```
deployment/
├── Dockerfile.agency      # Dockerfile para Agency Frontend
├── Dockerfile.seller      # Dockerfile para Seller Frontend
├── docker-compose.yml     # Orquestração dos containers
├── nginx.conf            # Configuração do Nginx (proxy reverso)
├── nginx-agency.conf     # Config específica do Agency
├── nginx-seller.conf     # Config específica do Seller
├── .env.production       # Variáveis de ambiente
├── deploy.sh            # Script de deployment
├── CLOUDFLARE_DNS_SETUP.md  # Guia de configuração DNS
└── VM_SETUP_INSTRUCTIONS.md # Instruções de setup da VM
```

## Quick Start na VM

### 1. Clonar este repositório na VM

```bash
cd /opt
git clone https://github.com/SEU_USUARIO/larian-deployment.git larian
cd larian
```

### 2. Clonar os projetos frontend

```bash
git clone https://github.com/sounuv/gufly-agency-front.git
git clone https://github.com/sounuv/gufly-seller-front.git
```

### 3. Instalar Docker (Debian/Ubuntu)

```bash
# Para Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

### 4. Executar deploy

```bash
cd deployment
chmod +x deploy.sh
./deploy.sh deploy
```

## URLs de Acesso

- **Agency**: https://larian.app/agency
- **Seller**: https://larian.app/seller

## Comandos Úteis

- `./deploy.sh deploy` - Deploy inicial
- `./deploy.sh logs` - Ver logs
- `./deploy.sh restart` - Reiniciar serviços
- `./deploy.sh stop` - Parar serviços
- `./deploy.sh update` - Atualizar e redesplegar

## Configuração DNS

Ver arquivo `deployment/CLOUDFLARE_DNS_SETUP.md` para instruções detalhadas.

## VM Setup

Ver arquivo `deployment/VM_SETUP_INSTRUCTIONS.md` para setup completo da VM.