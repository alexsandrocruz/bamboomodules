#!/bin/bash

# ERPZen - Script de Execução de Migrações
# Executa as migrações do Entity Framework para todos os serviços

echo "🔄 Executando migrações do ERPZen..."
echo "=================================="

# Verificar se PostgreSQL está rodando
echo "🔍 Verificando conexão com PostgreSQL..."
if ! pg_isready -h localhost -p 5432 -U erpzen; then
    echo "❌ PostgreSQL não está acessível. Execute docker-compose up -d primeiro."
    exit 1
fi

echo "✅ PostgreSQL está conectado"

# Lista de serviços na ordem correta de dependência
declare -A services=(
    ["ERPZen.Admin"]="services/fundamental/ERPZen.Admin/src/ERPZen.Admin.HttpApi.Host/ERPZen.Admin.HttpApi.Host.csproj"
    ["ERPZen.Core"]="services/fundamental/ERPZen.Core/src/ERPZen.Core.HttpApi.Host/ERPZen.Core.HttpApi.Host.csproj"
    ["ERPZen.Contatos"]="services/fundamental/ERPZen.Contatos/src/ERPZen.Contatos.HttpApi.Host/ERPZen.Contatos.HttpApi.Host.csproj"
    ["ERPZen.Financeiro"]="services/business/ERPZen.Financeiro/src/ERPZen.Financeiro.HttpApi.Host/ERPZen.Financeiro.HttpApi.Host.csproj"
    ["ERPZen.Estoque"]="services/business/ERPZen.Estoque/src/ERPZen.Estoque.HttpApi.Host/ERPZen.Estoque.HttpApi.Host.csproj"
    ["ERPZen.Vendas"]="services/business/ERPZen.Vendas/src/ERPZen.Vendas.HttpApi.Host/ERPZen.Vendas.HttpApi.Host.csproj"
    ["ERPZen.Compras"]="services/business/ERPZen.Compras/src/ERPZen.Compras.HttpApi.Host/ERPZen.Compras.HttpApi.Host.csproj"
    ["ERPZen.CRM"]="services/business/ERPZen.CRM/src/ERPZen.CRM.HttpApi.Host/ERPZen.CRM.HttpApi.Host.csproj"
    ["ERPZen.Producao"]="services/business/ERPZen.Producao/src/ERPZen.Producao.HttpApi.Host/ERPZen.Producao.HttpApi.Host.csproj"
    ["ERPZen.Projetos"]="services/business/ERPZen.Projetos/src/ERPZen.Projetos.HttpApi.Host/ERPZen.Projetos.HttpApi.Host.csproj"
    ["ERPZen.RH"]="services/business/ERPZen.RH/src/ERPZen.RH.HttpApi.Host/ERPZen.RH.HttpApi.Host.csproj"
    ["ERPZen.Comunicacao"]="services/business/ERPZen.Comunicacao/src/ERPZen.Comunicacao.HttpApi.Host/ERPZen.Comunicacao.HttpApi.Host.csproj"
    ["ERPZen.Website"]="services/communication/ERPZen.Website/src/ERPZen.Website.HttpApi.Host/ERPZen.Website.HttpApi.Host.csproj"
    ["ERPZen.Marketing"]="services/communication/ERPZen.Marketing/src/ERPZen.Marketing.HttpApi.Host/ERPZen.Marketing.HttpApi.Host.csproj"
    ["ERPZen.Eventos"]="services/communication/ERPZen.Eventos/src/ERPZen.Eventos.HttpApi.Host/ERPZen.Eventos.HttpApi.Host.csproj"
    ["ERPZen.Survey"]="services/communication/ERPZen.Survey/src/ERPZen.Survey.HttpApi.Host/ERPZen.Survey.HttpApi.Host.csproj"
    ["ERPZen.Helpdesk"]="services/communication/ERPZen.Helpdesk/src/ERPZen.Helpdesk.HttpApi.Host/ERPZen.Helpdesk.HttpApi.Host.csproj"
    ["ERPZen.Knowledge"]="services/communication/ERPZen.Knowledge/src/ERPZen.Knowledge.HttpApi.Host/ERPZen.Knowledge.HttpApi.Host.csproj"
    ["ERPZen.Qualidade"]="services/operations/ERPZen.Qualidade/src/ERPZen.Qualidade.HttpApi.Host/ERPZen.Qualidade.HttpApi.Host.csproj"
    ["ERPZen.Manutencao"]="services/operations/ERPZen.Manutencao/src/ERPZen.Manutencao.HttpApi.Host/ERPZen.Manutencao.HttpApi.Host.csproj"
    ["ERPZen.Campo"]="services/operations/ERPZen.Campo/src/ERPZen.Campo.HttpApi.Host/ERPZen.Campo.HttpApi.Host.csproj"
    ["ERPZen.Documents"]="services/operations/ERPZen.Documents/src/ERPZen.Documents.HttpApi.Host/ERPZen.Documents.HttpApi.Host.csproj"
    ["ERPZen.Timesheet"]="services/operations/ERPZen.Timesheet/src/ERPZen.Timesheet.HttpApi.Host/ERPZen.Timesheet.HttpApi.Host.csproj"
    ["ERPZen.Expenses"]="services/operations/ERPZen.Expenses/src/ERPZen.Expenses.HttpApi.Host/ERPZen.Expenses.HttpApi.Host.csproj"
    ["ERPZen.Attendance"]="services/hr/ERPZen.Attendance/src/ERPZen.Attendance.HttpApi.Host/ERPZen.Attendance.HttpApi.Host.csproj"
    ["ERPZen.Leaves"]="services/hr/ERPZen.Leaves/src/ERPZen.Leaves.HttpApi.Host/ERPZen.Leaves.HttpApi.Host.csproj"
    ["ERPZen.Fleet"]="services/specialized/ERPZen.Fleet/src/ERPZen.Fleet.HttpApi.Host/ERPZen.Fleet.HttpApi.Host.csproj"
    ["ERPZen.Rental"]="services/specialized/ERPZen.Rental/src/ERPZen.Rental.HttpApi.Host/ERPZen.Rental.HttpApi.Host.csproj"
    ["ERPZen.Gateway"]="services/infrastructure/ERPZen.Gateway/src/ERPZen.Gateway.HttpApi.Host/ERPZen.Gateway.HttpApi.Host.csproj"
    ["ERPZen.Notifications"]="services/infrastructure/ERPZen.Notifications/src/ERPZen.Notifications.HttpApi.Host/ERPZen.Notifications.HttpApi.Host.csproj"
)

# Total de serviços
total_services=${#services[@]}
current_service=0

# Função para executar migração de um serviço
run_migration() {
    local service_name=$1
    local project_path=$2

    current_service=$((current_service + 1))

    echo "📋 [$current_service/$total_services] Executando migração: $service_name"

    if [ ! -f "$project_path" ]; then
        echo "⚠️  Projeto não encontrado: $project_path"
        return 1
    fi

    # Mudar para o diretório do projeto
    local project_dir=$(dirname "$project_path")
    cd "$project_dir"

    # Extrair nome do projeto para context
    local context_name="${service_name/ERPZen./}DbContext"

    echo "   🗄️  Criando migration para $context_name..."

    # Criar migration
    dotnet ef migrations add InitialCreate \
        --startup-project "$project_path" \
        --project "../$(basename $(pwd))EntityFrameworkCore/$(basename $(pwd)).EntityFrameworkCore.csproj" \
        --context "$context_name"

    if [ $? -ne 0 ]; then
        echo "   ⚠️  Erro ao criar migration para $service_name (pode já existir)"
    fi

    echo "   🔧 Aplicando migration para $context_name..."

    # Aplicar migration
    dotnet ef database update \
        --startup-project "$project_path" \
        --project "../$(basename $(pwd))EntityFrameworkCore/$(basename $(pwd)).EntityFrameworkCore.csproj" \
        --context "$context_name"

    if [ $? -eq 0 ]; then
        echo "   ✅ Migration do $service_name aplicada com sucesso"
    else
        echo "   ❌ Erro ao aplicar migration do $service_name"
        return 1
    fi

    # Voltar ao diretório raiz
    cd - > /dev/null
}

# Executar migrações em ordem de dependência
for service_name in "${!services[@]}"; do
    run_migration "$service_name" "${services[$service_name]}"

    if [ $? -ne 0 ]; then
        echo "⚠️  Continuando com próximo serviço..."
    fi

    echo ""
done

# Verificar status final
echo "📊 Verificando status final dos bancos de dados..."
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
    "erpzen_gateway"
    "erpzen_notifications"
)

success_count=0
for db in "${databases[@]}"; do
    # Verificar se existe a tabela __EFMigrationsHistory
    table_count=$(PGPASSWORD=erpzen123 psql -h localhost -p 5432 -U erpzen -d $db -t -c "
        SELECT COUNT(*) FROM information_schema.tables
        WHERE table_name = '__EFMigrationsHistory';
    " | tr -d ' ')

    if [ "$table_count" -eq 1 ]; then
        echo "✅ $db - OK"
        success_count=$((success_count + 1))
    else
        echo "❌ $db - Migration não aplicada"
    fi
done

echo ""
echo "🎉 Processo de migração concluído!"
echo ""
echo "📊 Resumo:"
echo "   • $success_count/${#databases[@]} bancos de dados com migrações aplicadas"
echo "   • $total_services serviços processados"
echo ""
echo "🔍 Para verificar os serviços rodando:"
echo "   curl http://localhost:7000/health"
echo "   curl http://localhost:7001/health"
echo "   curl http://localhost:7002/health"
echo ""
echo "🌐 Acessar serviços:"
echo "   • API Gateway: http://localhost:7000"
echo "   • Admin Service: http://localhost:7001"
echo "   • Core Service: http://localhost:7002"
echo "   • Swagger UI: http://localhost:7001/swagger"
echo ""
echo "📝 Para criar dados de exemplo:"
echo "   ./scripts/05-seed-data.sh"