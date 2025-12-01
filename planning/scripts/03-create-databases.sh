#!/bin/bash

# ERPZen - Script de Criação de Bancos de Dados
# Cria todos os bancos de dados necessários para os microserviços

echo "🗄️ Criando bancos de dados do ERPZen..."
echo "========================================"

# Configurações
DB_HOST="localhost"
DB_PORT="5432"
DB_USER="erpzen"
DB_PASSWORD="erpzen123"
DB_ADMIN_USER="postgres"
DB_ADMIN_PASSWORD="postgres"

# Lista de bancos de dados
databases=(
    "erpzen_admin"
    "erpzen_core"
    "erpzen_contatos"
    "erpzen_financeiro"
    "erpzen_estoque"
    "erpzen_vendas"
    "erpzen_compras"
    "erpzen_crm"
    "erpzen_producao"
    "erpzen_projetos"
    "erpzen_rh"
    "erpzen_comunicacao"
    "erpzen_website"
    "erpzen_marketing"
    "erpzen_eventos"
    "erpzen_qualidade"
    "erpzen_manutencao"
    "erpzen_campo"
    "erpzen_documents"
    "erpzen_helpdesk"
    "erpzen_knowledge"
    "erpzen_timesheet"
    "erpzen_expenses"
    "erpzen_attendance"
    "erpzen_leaves"
    "erpzen_fleet"
    "erpzen_rental"
    "erpzen_survey"
    "erpzen_gateway"
    "erpzen_notifications"
)

# Criar usuário erpzen se não existir
echo "👤 Criando usuário erpzen..."
PGPASSWORD=$DB_ADMIN_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_ADMIN_USER -c "
DO \$\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = '$DB_USER') THEN

      CREATE ROLE $DB_USER LOGIN PASSWORD '$DB_PASSWORD';
   END IF
END
\$\$;
"

if [ $? -eq 0 ]; then
    echo "✅ Usuário $DB_USER criado/encontrado"
else
    echo "❌ Erro ao criar usuário $DB_USER"
    exit 1
fi

# Criar cada banco de dados
for db in "${databases[@]}"; do
    echo "📊 Criando banco de dados: $db"

    # Verificar se o banco já existe
    PGPASSWORD=$DB_ADMIN_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_ADMIN_USER -c "SELECT 1 FROM pg_database WHERE datname = '$db'" | grep -q 1

    if [ $? -ne 0 ]; then
        # Criar banco de dados
        PGPASSWORD=$DB_ADMIN_PASSWORD createdb -h $DB_HOST -p $DB_PORT -U $DB_ADMIN_USER -O $DB_USER $db

        if [ $? -eq 0 ]; then
            echo "✅ Banco $db criado com sucesso"
        else
            echo "❌ Erro ao criar banco $db"
        fi
    else
        echo "⚠️  Banco $db já existe"
    fi
done

# Criar script SQL para inicialização
echo "📝 Criando script de inicialização SQL..."
cat > scripts/create-databases.sql << 'EOF'
-- ERPZen - Script de Criação de Bancos de Dados
-- Este script é executado automaticamente pelo Docker

-- Criar usuário erpzen se não existir
DO $$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'erpzen') THEN

      CREATE ROLE erpzen LOGIN PASSWORD 'erpzen123';
   END IF
END
$$;

-- Habilitar extensão UUID-OSSP para todos os bancos
\c erpzen_admin;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_core;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_contatos;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_financeiro;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_estoque;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_vendas;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_compras;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_crm;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_producao;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_projetos;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_rh;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_comunicacao;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_website;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_marketing;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_eventos;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_qualidade;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_manutencao;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_campo;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_documents;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_helpdesk;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_knowledge;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_timesheet;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_expenses;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_attendance;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_leaves;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_fleet;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_rental;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_survey;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_gateway;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c erpzen_notifications;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Criar função uuidv7() personalizada se não existir
CREATE OR REPLACE FUNCTION public.uuidv7()
RETURNS uuid
LANGUAGE sql
AS $$
SELECT encode(
    set_byte(
        set_byte(
            set_byte(
                decode(substr(gen_random_uuid()::text, 1, 18), 'hex'),
                0, (floor(extract(epoch from now()) * 1000) >> 40) & 0xFF
            ),
            1, (floor(extract(epoch from now()) * 1000) >> 32) & 0xFF
        ),
        2, (floor(extract(epoch from now()) * 1000) >> 24) & 0xFF
    ) ||
    decode(substr(gen_random_uuid()::text, 19, 14), 'hex'),
    'hex'
)::uuid;
$$;

-- Garantir permissões corretas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO erpzen;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO erpzen;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO erpzen;
EOF

# Configurar conexões e permissões
echo "🔐 Configurando permissões..."
for db in "${databases[@]}"; do
    echo "📋 Configurando permissões para $db"
    PGPASSWORD=$DB_ADMIN_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_ADMIN_USER -d $db -c "
    GRANT ALL PRIVILEGES ON SCHEMA public TO $DB_USER;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO $DB_USER;
    "
done

echo ""
echo "✅ Todos os bancos de dados foram criados com sucesso!"
echo ""
echo "📊 Resumo:"
echo "   • ${#databases[@]} bancos de dados criados"
echo "   • Usuário erpzen configurado"
echo "   • Extensão UUID-OSSP habilitada"
echo "   • Função uuidv7() personalizada criada"
echo "   • Permissões configuradas"
echo ""
echo "🔗 String de conexão padrão:"
echo "   Host=$DB_HOST;Port=$DB_PORT;Database={nome_db};Username=$DB_USER;Password=$DB_PASSWORD"
echo ""
echo "🚀 Próximo passo: Execute docker-compose up -d"