# Guia de Configuração DNS no Cloudflare

## Informações da VM
- **IP da VM**: `34.68.64.59`
- **Domínio**: `larian.app`
- **Subpaths**: 
  - `/agency` - Agency Frontend
  - `/seller` - Seller Frontend

## Passos para Configurar o DNS no Cloudflare

### 1. Acessar o Painel do Cloudflare
1. Faça login em [https://dash.cloudflare.com](https://dash.cloudflare.com)
2. Selecione o domínio `larian.app`

### 2. Configurar Registros DNS

#### Registro A Principal
1. Clique em **DNS** no menu lateral
2. Clique em **Add Record**
3. Configure:
   - **Type**: `A`
   - **Name**: `@` (ou deixe vazio para root domain)
   - **IPv4 address**: `34.68.64.59`
   - **Proxy status**: ☁️ Proxied (laranja)
   - **TTL**: Auto
4. Clique em **Save**

#### Registro A para WWW
1. Clique em **Add Record** novamente
2. Configure:
   - **Type**: `A`
   - **Name**: `www`
   - **IPv4 address**: `34.68.64.59`
   - **Proxy status**: ☁️ Proxied (laranja)
   - **TTL**: Auto
3. Clique em **Save**

### 3. Configurações de SSL/TLS

1. No menu lateral, clique em **SSL/TLS**
2. Em **Overview**, selecione:
   - **SSL/TLS encryption mode**: `Full (strict)` (após configurar SSL na VM)
   - Inicialmente use `Flexible` se não tiver SSL configurado ainda

### 4. Configurar Page Rules (Opcional)

Para forçar HTTPS:
1. Vá em **Rules** → **Page Rules**
2. Clique em **Create Page Rule**
3. Configure:
   - **URL**: `http://larian.app/*`
   - **Settings**: `Always Use HTTPS`
4. Clique em **Save and Deploy**

### 5. Configurações de Performance

1. Em **Speed** → **Optimization**:
   - Ative **Auto Minify** para JavaScript, CSS e HTML
   - Ative **Brotli** compression

2. Em **Caching** → **Configuration**:
   - **Browser Cache TTL**: 4 hours
   - **Always Online**: Ativado

### 6. Verificar Propagação DNS

Após configurar, verifique a propagação:
```bash
# No terminal, teste o DNS
nslookup larian.app
dig larian.app

# Ou use ferramentas online
# https://www.whatsmydns.net/#A/larian.app
```

### 7. Tempo de Propagação

- As mudanças no Cloudflare são instantâneas quando usando proxy
- Se não usar proxy, pode levar até 48 horas para propagação completa
- Recomendado manter o proxy ativado (nuvem laranja) para:
  - SSL automático gratuito
  - Proteção contra DDoS
  - Cache global
  - Otimização de performance

## URLs Finais

Após a configuração, suas aplicações estarão acessíveis em:
- **Agency**: https://larian.app/agency
- **Seller**: https://larian.app/seller

## Troubleshooting

### Site não carrega
1. Verifique se os registros DNS estão corretos
2. Confirme que a VM está rodando e acessível
3. Teste acessando diretamente pelo IP: http://34.68.64.59

### Erro SSL
1. Mude temporariamente para SSL mode `Flexible`
2. Configure certificados na VM
3. Depois mude para `Full (strict)`

### Cache Issues
1. Purge cache no Cloudflare: **Caching** → **Configuration** → **Purge Everything**
2. Use modo desenvolvimento temporariamente: **Caching** → **Configuration** → **Development Mode**

## Segurança Adicional

### Firewall Rules
1. Em **Security** → **WAF**
2. Crie regras para:
   - Bloquear países específicos (se necessário)
   - Rate limiting
   - Bloquear bots maliciosos

### Headers de Segurança
1. Em **Rules** → **Transform Rules** → **Response Headers**
2. Adicione headers de segurança:
   - `X-Frame-Options: SAMEORIGIN`
   - `X-Content-Type-Options: nosniff`
   - `Strict-Transport-Security: max-age=31536000`