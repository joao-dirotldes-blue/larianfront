# Comandos para Executar na VM

## ✅ Código já está no GitHub!
Repository: https://github.com/joao-dirotldes-blue/larianfront

## Comandos para copiar e colar na VM (como root):

### 1. Instalar Docker (Debian)
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### 2. Clonar e preparar projetos
```bash
cd /opt
git clone https://github.com/joao-dirotldes-blue/larianfront.git larian
cd larian
git clone https://github.com/sounuv/gufly-agency-front.git
git clone https://github.com/sounuv/gufly-seller-front.git
```

### 3. Executar deploy
```bash
cd deployment
chmod +x deploy.sh
./deploy.sh deploy
```

### 4. Verificar se está rodando
```bash
docker ps
curl http://localhost/health
```

## Troubleshooting

### Se Docker não instalar pelo script:
```bash
# Limpar tentativas anteriores
rm -f /etc/apt/sources.list.d/docker.list
rm -f /etc/apt/keyrings/docker.gpg

# Instalar manualmente
apt-get update
apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Ver logs se algo der errado:
```bash
cd /opt/larian/deployment
./deploy.sh logs
```

## URLs de Acesso (após deploy):
- http://34.68.64.59/agency
- http://34.68.64.59/seller

Após configurar DNS no Cloudflare:
- https://larian.app/agency
- https://larian.app/seller