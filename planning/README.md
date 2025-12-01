# ERPZen - Planning

Esta pasta contém todo o planejamento e scripts para a criação do ERPZen, um sistema ERP completo em microserviços baseado no conhecimento Odoo 18.

## 📁 Estrutura

```
planning/
├── ERPZen-Planning.md          # Documento completo de planejamento
├── scripts/                    # Scripts de automação
│   ├── 01-create-all-services.sh    # Criar todos os 30+ serviços
│   ├── 02-setup-structure.sh        # Configurar estrutura dos projetos
│   ├── 03-create-databases.sh       # Criar bancos de dados PostgreSQL
│   ├── 04-run-migrations.sh         # Executar migrações EF Core
│   ├── 05-build-all.sh              # Compilar e testar todos os projetos
│   └── 06-run-apps.sh               # Iniciar todas as aplicações
└── README.md                   # Este arquivo
```

## 🚀 Guia Rápido de Execução

### 1. Pré-requisitos

```bash
# Instalar ABP CLI
dotnet tool install -g Volo.Abp.Cli

# Verificar instalação
abp --version

# Instalar Docker Desktop
# Iniciar PostgreSQL, Redis e RabbitMQ
```

### 2. Criar Todos os Serviços

```bash
# Copiar scripts para pasta do projeto
cp -r planning /path/to/ERPZen/

cd ERPZen

# Tornar scripts executáveis
chmod +x scripts/*.sh

# Criar todos os 30+ microserviços
./scripts/01-create-all-services.sh
```

### 3. Configurar Estrutura

```bash
# Organizar projetos em categorias
./scripts/02-setup-structure.sh
```

### 4. Configurar Bancos de Dados

```bash
# Iniciar infraestrutura Docker
docker-compose -f infrastructure/docker/docker-compose.yml up -d

# Criar todos os bancos de dados
./scripts/03-create-databases.sh
```

### 5. Executar Migrações

```bash
# Aplicar migrations do Entity Framework
./scripts/04-run-migrations.sh
```

### 6. Compilar e Testar

```bash
# Compilar todos os projetos e executar testes
./scripts/05-build-all.sh
```

### 7. Iniciar Aplicações

```bash
# Iniciar todos os serviços e aplicações
./scripts/06-run-apps.sh
```

## 🏗️ Arquitetura do ERPZen

### Microserviços (30+)

#### 🏛️ Serviços Fundamentais
- **ERPZen.Admin** - Autenticação e Administração (Porta 7001)
- **ERPZen.Core** - Configurações e Entidades Base (Porta 7002)
- **ERPZen.Contatos** - Gestão de Contatos e Parceiros (Porta 7003)

#### 💼 Serviços de Negócio Essenciais
- **ERPZen.Financeiro** - Contabilidade e Finanças (Porta 7004)
- **ERPZen.Estoque** - Gestão de Estoque (Porta 7005)
- **ERPZen.Vendas** - Pedidos de Venda (Porta 7006)
- **ERPZen.Compras** - Requisições e Compras (Porta 7007)
- **ERPZen.CRM** - Gestão de Relacionamento (Porta 7008)
- **ERPZen.Producao** - Manufatura (MRP) (Porta 7009)
- **ERPZen.Projetos** - Gestão de Projetos (Porta 7010)
- **ERPZen.RH** - Recursos Humanos (Porta 7011)
- **ERPZen.Comunicacao** - Email e Mensagens (Porta 7012)

#### 📡 Comunicação e Colaboração
- **ERPZen.Website** - CMS e Gestão de Conteúdo (Porta 7013)
- **ERPZen.Marketing** - Automação de Marketing (Porta 7014)
- **ERPZen.Eventos** - Gestão de Eventos (Porta 7015)
- **ERPZen.Survey** - Pesquisas e Formulários (Porta 7016)
- **ERPZen.Helpdesk** - Suporte ao Cliente (Porta 7017)
- **ERPZen.Knowledge** - Base de Conhecimento (Porta 7018)

#### ⚙️ Operações e Qualidade
- **ERPZen.Qualidade** - Controle de Qualidade (Porta 7019)
- **ERPZen.Manutencao** - Manutenção de Equipamentos (Porta 7020)
- **ERPZen.Campo** - Shop Floor / Chão de Fábrica (Porta 7021)
- **ERPZen.Documents** - Gestão Documental (Porta 7022)
- **ERPZen.Timesheet** - Controle de Horas (Porta 7023)
- **ERPZen.Expenses** - Gestão de Despesas (Porta 7024)

#### 👥 RH Expandido
- **ERPZen.Attendance** - Controle de Ponto (Porta 7025)
- **ERPZen.Leaves** - Gestão de Férias e Ausências (Porta 7026)

#### 🚗 Serviços Especializados
- **ERPZen.Fleet** - Gestão de Frota (Porta 7027)
- **ERPZen.Rental** - Gestão de Locação (Porta 7028)

#### 🌐 Infraestrutura
- **ERPZen.Gateway** - API Gateway (Porta 7000)
- **ERPZen.Notifications** - Central de Notificações (Porta 7030)

#### 📱 Aplicações Cliente
- **ERPZen.Web** - Aplicação Web (Porta 7031)
- **ERPZen.Mobile** - API Mobile (Porta 7032)

### Tecnologias

- **Backend**: .NET 8.0 + ABP Framework + Entity Framework Core
- **Banco de Dados**: PostgreSQL 16 com extensão UUID
- **Cache**: Redis 7
- **Mensageria**: RabbitMQ
- **Containerização**: Docker + Docker Compose
- **Frontend**: React 19 + TypeScript + Vite + TailwindCSS

## 📊 Bancos de Dados

Cada serviço tem seu próprio banco de dados PostgreSQL:

```sql
-- Exemplo de string de conexão
Host=localhost;Port=5432;Database=erpzen_contatos;Username=erpzen;Password=erpzen123
```

Lista completa de bancos:
- `erpzen_admin` - Autenticação e perfis
- `erpzen_core` - Configurações e entidades base
- `erpzen_contatos` - Gestão de contatos
- `erpzen_financeiro` - Contabilidade e finanças
- `erpzen_estoque` - Gestão de estoque e produtos
- `erpzen_vendas` - Pedidos e vendas
- `erpzen_compras` - Requisições e compras
- `erpzen_crm` - Leads e oportunidades
- ... e mais 22 bancos especializados

## 🔧 Comandos Úteis

### Desenvolvimento

```bash
# Compilar projeto específico
dotnet build services/fundamental/ERPZen.Admin

# Executar testes específicos
dotnet test services/fundamental/ERPZen.Admin/src/ERPZen.Admin.Domain.Tests

# Iniciar serviço específico
dotnet run --project services/fundamental/ERPZen.Admin/src/ERPZen.Admin.HttpApi.Host

# Ver logs de serviço específico
./scripts/view-logs.sh Admin-Service
```

### Docker

```bash
# Ver containers rodando
docker ps

# Ver logs de container específico
docker logs erpzen-admin

# Parar infraestrutura
docker-compose -f infrastructure/docker/docker-compose.yml down
```

### Banco de Dados

```bash
# Conectar ao PostgreSQL
psql -h localhost -p 5432 -U erpzen -d erpzen_admin

# Ver tabelas
\dt

# Ver migrations
SELECT * FROM __EFMigrationsHistory;
```

## 🚨 Troubleshooting

### Problemas Comuns

1. **Portas já em uso**
   ```bash
   # Ver quais processos estão usando as portas
   lsof -i :7001

   # Matar processo específico
   kill -9 <PID>
   ```

2. **Banco de dados não conecta**
   ```bash
   # Verificar se PostgreSQL está rodando
   docker ps | grep postgres

   # Ver logs do PostgreSQL
   docker logs erpzen-postgres
   ```

3. **Migrações falham**
   ```bash
   # Limpar e recriar banco
   dropdb -h localhost -p 5432 -U erpzen erpzen_admin
   createdb -h localhost -p 5432 -U erpzen erpzen_admin
   ```

4. **Serviços não iniciam**
   ```bash
   # Ver logs específicos
   ./scripts/view-logs.sh Admin-Service

   # Parar todos e reiniciar
   ./scripts/stop-apps.sh
   ./scripts/06-run-apps.sh
   ```

## 📚 Documentação Adicional

- [Planejamento Completo](ERPZen-Planning.md) - Detalhes de arquitetura e entidades
- [API Reference](../docs/api.md) - Documentação das APIs
- [Deploy Guide](../docs/deploy.md) - Guia de deploy em produção
- [Development Guide](../docs/development.md) - Guia de desenvolvimento

## 🤝 Contribuição

1. Fork o projeto
2. Crie branch para sua feature
3. Faça commit das mudanças
4. Abra Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT.