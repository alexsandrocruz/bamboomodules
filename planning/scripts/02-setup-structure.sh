#!/bin/bash

# ERPZen - Script de Configuração da Estrutura
# Este script configura a estrutura dos projetos após a criação

echo "⚙️ Configurando estrutura do ERPZen..."
echo "======================================"

cd ERPZen

# Mover projetos para estrutura organizada
echo "📂 Organizando estrutura dos projetos..."

# Criar subdiretórios em services
mkdir -p services/{fundamental,business,communication,operations,hr,specialized,infrastructure}

# Mover serviços para categorias apropriadas
echo "🔄 Movendo serviços para categorias..."

# Serviços Fundamentais
mv services/ERPZen.Admin services/fundamental/
mv services/ERPZen.Core services/fundamental/
mv services/ERPZen.Contatos services/fundamental/

# Serviços de Negócio
mv services/ERPZen.Financeiro services/business/
mv services/ERPZen.Estoque services/business/
mv services/ERPZen.Vendas services/business/
mv services/ERPZen.Compras services/business/
mv services/ERPZen.CRM services/business/
mv services/ERPZen.Producao services/business/
mv services/ERPZen.Projetos services/business/
mv services/ERPZen.RH services/business/
mv services/ERPZen.Comunicacao services/business/

# Serviços de Comunicação e Colaboração
mv services/ERPZen.Website services/communication/
mv services/ERPZen.Marketing services/communication/
mv services/ERPZen.Eventos services/communication/
mv services/ERPZen.Survey services/communication/
mv services/ERPZen.Helpdesk services/communication/
mv services/ERPZen.Knowledge services/communication/

# Serviços Operacionais
mv services/ERPZen.Qualidade services/operations/
mv services/ERPZen.Manutencao services/operations/
mv services/ERPZen.Campo services/operations/
mv services/ERPZen.Documents services/operations/
mv services/ERPZen.Timesheet services/operations/
mv services/ERPZen.Expenses services/operations/

# Serviços de RH Expandidos
mv services/ERPZen.Attendance services/hr/
mv services/ERPZen.Leaves services/hr/

# Serviços Especializados
mv services/ERPZen.Fleet services/specialized/
mv services/ERPZen.Rental services/specialized/

# Serviços de Infraestrutura
mv services/ERPZen.Gateway services/infrastructure/
mv services/ERPZen.Notifications services/infrastructure/

# Mover aplicações
echo "📱 Organizando aplicações..."
mv apps/ERPZen.Web apps/
mv apps/ERPZen.Mobile apps/

# Criar shared modules
echo "📦 Criando módulos compartilhados..."
mkdir -p shared/{kernel,utils,contracts,dtos}

# Criar arquivos de solução
echo "📄 Criando arquivos de solução .sln..."

# Solução principal
echo "📝 Criando ERPZen.sln..."
dotnet new sln -n ERPZen

# Soluções por categoria
echo "📝 Criando soluções por categoria..."

# Business Solutions
dotnet new sln -n ERPZen.Business -o services/business
dotnet new sln -n ERPZen.Communication -o services/communication
dotnet new sln -n ERPZen.Operations -o services/operations
dotnet new sln -n ERPZen.HR -o services/hr
dotnet new sln -n ERPZen.Specialized -o services/specialized
dotnet new sln -n ERPZen.Infrastructure -o services/infrastructure

# Adicionar projetos às soluções
echo "🔗 Adicionando projetos às soluções..."

echo "   ➕ Adicionando serviços fundamentais..."
find services/fundamental -name "*.csproj" -exec dotnet sln add {} \;

echo "   ➕ Adicionando serviços de negócio..."
cd services/business
dotnet sln add */src/*/*.csproj
cd ../..

echo "   ➕ Adicionando serviços de comunicação..."
cd services/communication
dotnet sln add */src/*/*.csproj
cd ../..

echo "   ➕ Adicionando serviços operacionais..."
cd services/operations
dotnet sln add */src/*/*.csproj
cd ../..

echo "   ➕ Adicionando serviços de RH..."
cd services/hr
dotnet sln add */src/*/*.csproj
cd ../..

echo "   ➕ Adicionando serviços especializados..."
cd services/specialized
dotnet sln add */src/*/*.csproj
cd ../..

echo "   ➕ Adicionando serviços de infraestrutura..."
cd services/infrastructure
dotnet sln add */src/*/*.csproj
cd ../..

echo "   ➕ Adicionando aplicações..."
find apps -name "*.csproj" -exec dotnet sln add {} \;

# Criar arquivos de configuração
echo "⚙️ Criando arquivos de configuração..."

# .gitignore
echo "📝 Criando .gitignore..."
cat > .gitignore << 'EOF'
# .NET
bin/
obj/
*.user
*.suo
*.cache
*.dll
*.exe
*.pdb

# Rider
.idea/

# VS Code
.vscode/

# Docker
.dockerignore

# Secrets
appsettings*.secrets.json
.secrets/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs/
*.log

# Database
*.db
*.sqlite

# Temp
tmp/
temp/

# OS
.DS_Store
Thumbs.db
EOF

# README.md
echo "📝 Criando README.md..."
cat > README.md << 'EOF'
# ERPZen

Sistema ERP completo em microserviços baseado no conhecimento Odoo 18, desenvolvido com ABP Framework e .NET 8.0.

## 🏗️ Arquitetura

- **30+ Microserviços** especializados por domínio
- **ABP Framework** para desenvolvimento rápido
- **PostgreSQL** para persistência
- **Redis** para cache distribuído
- **RabbitMQ** para eventos
- **Docker** para containerização

## 🚀 Início Rápido

### Pré-requisitos
- .NET 8.0 SDK
- Docker Desktop
- Node.js 18+
- PostgreSQL 16+
- Redis 7+

### Executar Localmente
```bash
# Criar estrutura completa
chmod +x scripts/01-create-all-services.sh
./scripts/01-create-all-services.sh

# Configurar estrutura
chmod +x scripts/02-setup-structure.sh
./scripts/02-setup-structure.sh

# Iniciar infraestrutura
docker-compose up -d

# Executar migrações
./scripts/03-run-migrations.sh
```

### Portos
- **7000** - API Gateway
- **7001** - Admin/Auth
- **7002** - Core
- **7003-7030** - Serviços de Negócio
- **7031** - Web Frontend
- **7032** - Mobile API

## 📚 Documentação

- [Planejamento](planning/ERPZen-Planning.md)
- [Arquitetura](docs/architecture.md)
- [API Reference](docs/api.md)
- [Deploy Guide](docs/deploy.md)

## 🛠️ Desenvolvimento

### Estrutura de Projetos
```
services/
├── fundamental/     # Admin, Core, Contatos
├── business/        # Financeiro, Estoque, Vendas, etc.
├── communication/   # CRM, Marketing, Website, etc.
├── operations/      # Qualidade, Manutenção, Produção, etc.
├── hr/             # RH, Attendance, Leaves, etc.
├── specialized/    # Fleet, Rental, Survey
└── infrastructure/ # Gateway, Notifications
```

### Scripts Úteis
- `scripts/01-create-all-services.sh` - Criar todos os serviços
- `scripts/02-setup-structure.sh` - Configurar estrutura
- `scripts/03-run-migrations.sh` - Executar migrações
- `scripts/04-run-tests.sh` - Executar testes
- `scripts/05-build-all.sh` - Compilar todos os projetos
EOF

# Criar scripts de Docker
echo "🐳 Criando configurações Docker..."

mkdir -p infrastructure/{docker,k8s,monitoring}

# Docker Compose base
echo "📝 Criando docker-compose.yml..."
cat > infrastructure/docker/docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Infraestrutura Base
  postgres:
    image: postgres:16-alpine
    container_name: erpzen-postgres
    environment:
      POSTGRES_DB: erpzen
      POSTGRES_USER: erpzen
      POSTGRES_PASSWORD: erpzen123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/create-databases.sql:/docker-entrypoint-initdb.d/create-databases.sql
    networks:
      - erpzen-network

  redis:
    image: redis:7-alpine
    container_name: erpzen-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - erpzen-network

  rabbitmq:
    image: rabbitmq:3-management-alpine
    container_name: erpzen-rabbitmq
    environment:
      RABBITMQ_DEFAULT_USER: erpzen
      RABBITMQ_DEFAULT_PASS: erpzen123
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - erpzen-network

  # Serviços Fundamentais
  admin-service:
    build:
      context: ../../services/fundamental/ERPZen.Admin
      dockerfile: Dockerfile
    container_name: erpzen-admin
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__Default=Host=postgres;Port=5432;Database=erpzen_admin;Username=erpzen;Password=erpzen123
      - Redis__Configuration=redis:6379
      - RabbitMQ__HostName=rabbitmq
      - RabbitMQ__UserName=erpzen
      - RabbitMQ__Password=erpzen123
    ports:
      - "7001:80"
    depends_on:
      - postgres
      - redis
      - rabbitmq
    networks:
      - erpzen-network

  core-service:
    build:
      context: ../../services/fundamental/ERPZen.Core
      dockerfile: Dockerfile
    container_name: erpzen-core
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__Default=Host=postgres;Port=5432;Database=erpzen_core;Username=erpzen;Password=erpzen123
      - Redis__Configuration=redis:6379
      - RabbitMQ__HostName=rabbitmq
      - RabbitMQ__UserName=erpzen
      - RabbitMQ__Password=erpzen123
    ports:
      - "7002:80"
    depends_on:
      - postgres
      - redis
      - rabbitmq
      - admin-service
    networks:
      - erpzen-network

  contatos-service:
    build:
      context: ../../services/fundamental/ERPZen.Contatos
      dockerfile: Dockerfile
    container_name: erpzen-contatos
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__Default=Host=postgres;Port=5432;Database=erpzen_contatos;Username=erpzen;Password=erpzen123
      - Redis__Configuration=redis:6379
      - RabbitMQ__HostName=rabbitmq
      - RabbitMQ__UserName=erpzen
      - RabbitMQ__Password=erpzen123
    ports:
      - "7003:80"
    depends_on:
      - postgres
      - redis
      - rabbitmq
      - core-service
    networks:
      - erpzen-network

  # API Gateway
  api-gateway:
    build:
      context: ../../services/infrastructure/ERPZen.Gateway
      dockerfile: Dockerfile
    container_name: erpzen-gateway
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
    ports:
      - "7000:80"
    depends_on:
      - admin-service
      - core-service
      - contatos-service
    networks:
      - erpzen-network

volumes:
  postgres_data:
  redis_data:
  rabbitmq_data:

networks:
  erpzen-network:
    driver: bridge
EOF

echo "✅ Estrutura configurada com sucesso!"
echo ""
echo "📁 Estrutura criada:"
echo "   services/ - 30+ microserviços organizados por categoria"
echo "   apps/ - Aplicações cliente"
echo "   shared/ - Módulos compartilhados"
echo "   infrastructure/ - Docker, K8s, Monitoramento"
echo ""
echo "🔧 Próximos passos:"
echo "   1. Execute: chmod +x scripts/03-create-databases.sh"
echo "   2. Execute: scripts/03-create-databases.sh"
echo "   3. Execute: docker-compose -f infrastructure/docker/docker-compose.yml up -d"
echo "   4. Execute: chmod +x scripts/04-run-migrations.sh"
echo "   5. Execute: scripts/04-run-migrations.sh"