#!/bin/bash

# Script para corrigir o build com base paths corretos

echo "Fixing build configuration..."

# Para Agency
cd /opt/larian/gufly-agency-front

# Criar vite.config.ts com base path
cat > vite.config.ts << 'EOF'
import path from 'path';
import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react-swc';
import { defineConfig } from 'vite';

export default defineConfig(() => ({
  base: '/agency/',
  server: {
    host: '::',
    port: 8080,
  },
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    emptyOutDir: true,
  },
}));
EOF

echo "Agency vite.config.ts created"

# Para Seller
cd /opt/larian/gufly-seller-front

# Criar vite.config.ts com base path
cat > vite.config.ts << 'EOF'
import path from 'path';
import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react-swc';
import { defineConfig } from 'vite';

export default defineConfig(() => ({
  base: '/seller/',
  server: {
    host: '::',
    port: 8080,
  },
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    emptyOutDir: true,
  },
}));
EOF

echo "Seller vite.config.ts created"

# Rebuild
cd /opt/larian/deployment
docker compose down
docker system prune -a -f
./deploy.sh deploy