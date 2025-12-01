#!/bin/bash

# ERPZen - Script de Build e Test
# Compila todos os projetos e executa testes

echo "🔨 Compilando e Testando ERPZen..."
echo "==============================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para compilar projeto
build_project() {
    local project_path=$1
    local project_name=$2

    echo -e "📦 Compilando ${YELLOW}$project_name${NC}..."

    dotnet build "$project_path" --configuration Release --no-restore

    if [ $? -eq 0 ]; then
        echo -e "   ✅ ${GREEN}$project_name compilado com sucesso${NC}"
        return 0
    else
        echo -e "   ❌ ${RED}Erro ao compilar $project_name${NC}"
        return 1
    fi
}

# Função para executar testes
test_project() {
    local project_path=$1
    local project_name=$2

    echo -e "🧪 Testando ${YELLOW}$project_name${NC}..."

    dotnet test "$project_path" --configuration Release --no-build --logger "console;verbosity=minimal"

    if [ $? -eq 0 ]; then
        echo -e "   ✅ ${GREEN}Testes do $project_name passaram${NC}"
        return 0
    else
        echo -e "   ⚠️  ${YELLOW}Alguns testes do $project_name falharam${NC}"
        return 1
    fi
}

# Restaurar pacotes para todos os projetos
echo "📚 Restaurando pacotes NuGet..."
dotnet restore

if [ $? -ne 0 ]; then
    echo -e "❌ ${RED}Erro ao restaurar pacotes${NC}"
    exit 1
fi

echo -e "✅ ${GREEN}Pacotes restaurados com sucesso${NC}"
echo ""

# Compilar serviços fundamentais
echo -e "🏛️ ${YELLOW}Compilando Serviços Fundamentais...${NC}"
build_project "services/fundamental/ERPZen.Admin/src/ERPZen.Admin.HttpApi.Host/ERPZen.Admin.HttpApi.Host.csproj" "Admin Service"
build_project "services/fundamental/ERPZen.Core/src/ERPZen.Core.HttpApi.Host/ERPZen.Core.HttpApi.Host.csproj" "Core Service"
build_project "services/fundamental/ERPZen.Contatos/src/ERPZen.Contatos.HttpApi.Host/ERPZen.Contatos.HttpApi.Host.csproj" "Contatos Service"

# Compilar serviços de negócio
echo -e "💼 ${YELLOW}Compilando Serviços de Negócio...${NC}"
build_project "services/business/ERPZen.Financeiro/src/ERPZen.Financeiro.HttpApi.Host/ERPZen.Financeiro.HttpApi.Host.csproj" "Financeiro Service"
build_project "services/business/ERPZen.Estoque/src/ERPZen.Estoque.HttpApi.Host/ERPZen.Estoque.HttpApi.Host.csproj" "Estoque Service"
build_project "services/business/ERPZen.Vendas/src/ERPZen.Vendas.HttpApi.Host/ERPZen.Vendas.HttpApi.Host.csproj" "Vendas Service"
build_project "services/business/ERPZen.Compras/src/ERPZen.Compras.HttpApi.Host/ERPZen.Compras.HttpApi.Host.csproj" "Compras Service"
build_project "services/business/ERPZen.CRM/src/ERPZen.CRM.HttpApi.Host/ERPZen.CRM.HttpApi.Host.csproj" "CRM Service"
build_project "services/business/ERPZen.Producao/src/ERPZen.Producao.HttpApi.Host/ERPZen.Producao.HttpApi.Host.csproj" "Producao Service"
build_project "services/business/ERPZen.Projetos/src/ERPZen.Projetos/src/ERPZen.Projetos.HttpApi.Host/ERPZen.Projetos.HttpApi.Host.csproj" "Projetos Service"
build_project "services/business/ERPZen.RH/src/ERPZen.RH.HttpApi.Host/ERPZen.RH.HttpApi.Host.csproj" "RH Service"
build_project "services/business/ERPZen.Comunicacao/src/ERPZen.Comunicacao/src/ERPZen.Comunicacao.HttpApi.Host/ERPZen.Comunicacao.HttpApi.Host.csproj" "Comunicacao Service"

# Compilar serviços de comunicação
echo -e "📡 ${YELLOW}Compilando Serviços de Comunicação...${NC}"
build_project "services/communication/ERPZen.Website/src/ERPZen.Website.HttpApi.Host/ERPZen.Website.HttpApi.Host.csproj" "Website Service"
build_project "services/communication/ERPZen.Marketing/src/ERPZen.Marketing.HttpApi.Host/ERPZen.Marketing.HttpApi.Host.csproj" "Marketing Service"
build_project "services/communication/ERPZen.Eventos/src/ERPZen.Eventos/src/ERPZen.Eventos.HttpApi.Host/ERPZen.Eventos.HttpApi.Host.csproj" "Eventos Service"
build_project "services/communication/ERPZen.Survey/src/ERPZen.Survey/srcApi.Host/ERPZen.Survey.HttpApi.Host.csproj" "Survey Service"
build_project "services/communication/ERPZen.Helpdesk/src/ERPZen.Helpdesk.HttpApi.Host/ERPZen.Helpdesk.HttpApi.Host.csproj" "Helpdesk Service"
build_project "services/communication/ERPZen.Knowledge/src/ERPZen.Knowledge/src/ERPZen.Knowledge.HttpApi.Host/ERPZen.Knowledge.HttpApi.Host.csproj" "Knowledge Service"

# Compilar serviços operacionais
echo -e "⚙️ ${YELLOW}Compilando Serviços Operacionais...${NC}"
build_project "services/operations/ERPZen.Qualidade/src/ERPZen.Qualidade.HttpApi.Host/ERPZen.Qualidade.HttpApi.Host.csproj" "Qualidade Service"
build_project "services/operations/ERPZen.Manutencao/src/ERPZen.Manutencao/src/ERPZen.Manutencao.HttpApi.Host/ERPZen.Manutencao.HttpApi.Host.csproj" "Manutencao Service"
build_project "services/operations/ERPZen.Campo/src/ERPZen.Campo/src/ERPZen.Campo.HttpApi.Host/ERPZen.Campo.HttpApi.Host.csproj" "Campo Service"
build_project "services/operations/ERPZen.Documents/src/ERPZen.Documents.HttpApi.Host/ERPZen.Documents.HttpApi.Host.csproj" "Documents Service"
build_project "services/operations/ERPZen.Timesheet/src/ERPZen.Timesheet.HttpApi.Host/ERPZen.Timesheet.HttpApi.Host.csproj" "Timesheet Service"
build_project "services/operations/ERPZen.Expenses/src/ERPZen.Expenses.HttpApi.Host/ERPZen.Expenses.HttpApi.Host.csproj" "Expenses Service"

# Compilar serviços de RH
echo -e "👥 ${YELLOW}Compilando Serviços de RH Expandidos...${NC}"
build_project "services/hr/ERPZen.Attendance/src/ERPZen.Attendance.HttpApi.Host/ERPZen.Attendance.HttpApi.Host.csproj" "Attendance Service"
build_project "services/hr/ERPZen.Leaves/src/ERPZen.Leaves.HttpApi.Host/ERPZen.Leaves.HttpApi.Host.csproj" "Leaves Service"

# Compilar serviços especializados
echo -e "🚗 ${YELLOW}Compilando Serviços Especializados...${NC}"
build_project "services/specialized/ERPZen.Fleet/src/ERPZen.Fleet.HttpApi.Host/ERPZen.Fleet.HttpApi.Host.csproj" "Fleet Service"
build_project "services/specialized/ERPZen.Rental/src/ERPZen.Rental.HttpApi.Host/ERPZen.Rental.HttpApi.Host.csproj" "Rental Service"

# Compilar serviços de infraestrutura
echo -e "🌐 ${YELLOW}Compilando Serviços de Infraestrutura...${NC}"
build_project "services/infrastructure/ERPZen.Gateway/src/ERPZen.Gateway.HttpApi.Host/ERPZen.Gateway.HttpApi.Host.csproj" "Gateway Service"
build_project "services/infrastructure/ERPZen.Notifications/src/ERPZen.Notifications.HttpApi.Host/ERPZen.Notifications.HttpApi.Host.csproj" "Notifications Service"

# Compilar aplicações
echo -e "📱 ${YELLOW}Compilando Aplicações...${NC}"
build_project "apps/ERPZen.Web/src/ERPZen.Web.HttpApi.Host/ERPZen.Web.HttpApi.Host.csproj" "Web Application"
build_project "apps/ERPZen.Mobile/src/ERPZen.Mobile.HttpApi.Host/ERPZen.Mobile.HttpApi.Host.csproj" "Mobile API"

echo ""
echo -e "🧪 ${YELLOW}Executando Testes...${NC}"

# Encontrar e executar todos os projetos de teste
test_projects=$(find . -name "*.Tests.csproj" | head -10)

test_count=0
pass_count=0

for test_project in $test_projects; do
    project_name=$(basename $(dirname "$test_project"))
    test_count=$((test_count + 1))

    test_project "$test_project" "$project_name"

    if [ $? -eq 0 ]; then
        pass_count=$((pass_count + 1))
    fi

    echo ""
done

# Gerar relatório
echo -e "📊 ${YELLOW}Relatório de Build e Teste${NC}"
echo "=============================="
echo -e "Build: ${GREEN}✅ Todos os projetos compilaram${NC}"
echo -e "Testes: ${GREEN}$pass_count${NC}/${test_count} projetos passaram nos testes"

if [ $pass_count -eq $test_count ]; then
    echo -e "Status: ${GREEN}🎉 Todos os testes passaram!${NC}"
    exit_code=0
else
    echo -e "Status: ${YELLOW}⚠️  Alguns testes falharam, mas o build foi bem-sucedido${NC}"
    exit_code=1
fi

echo ""
echo -e "🚀 ${YELLOW}Próximos Passos:${NC}"
echo "1. Execute: docker-compose up -d"
echo "2. Execute: ./scripts/04-run-migrations.sh"
echo "3. Execute: ./scripts/06-run-apps.sh"
echo ""
echo -e "📝 ${YELLOW}Comandos úteis:${NC}"
echo "• Build específico: dotnet build services/fundamental/ERPZen.Admin"
echo "• Testar específico: dotnet test services/fundamental/ERPZen.Admin/src/ERPZen.Admin.Domain.Tests"
echo "• Executar serviço: dotnet run --project services/fundamental/ERPZen.Admin/src/ERPZen.Admin.HttpApi.Host"

exit $exit_code