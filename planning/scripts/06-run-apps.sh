#!/bin/bash

# ERPZen - Script de Execução das Aplicações
# Inicia todos os serviços e aplicações

echo "🚀 Iniciando aplicações do ERPZen..."
echo "=================================="

# Verificar se a infraestrutura está rodando
echo "🔍 Verificando infraestrutura..."
if ! docker ps | grep -q "erpzen-postgres"; then
    echo "❌ PostgreSQL não está rodando. Execute: docker-compose -f infrastructure/docker/docker-compose.yml up -d"
    exit 1
fi

if ! docker ps | grep -q "erpzen-redis"; then
    echo "❌ Redis não está rodando. Execute: docker-compose -f infrastructure/docker/docker-compose.yml up -d"
    exit 1
fi

if ! docker ps | grep -q "erpzen-rabbitmq"; then
    echo "❌ RabbitMQ não está rodando. Execute: docker-compose -f infrastructure/docker/docker-compose.yml up -d"
    exit 1
fi

echo "✅ Infraestrutura está rodando"

# Função para iniciar serviço em background
start_service() {
    local service_name=$1
    local service_path=$2
    local port=$3

    echo "🔧 Iniciando $service_name na porta $port..."

    # Criar diretório de logs se não existir
    mkdir -p logs

    # Iniciar serviço em background
    nohup dotnet run --project "$service_path" \
        --urls "http://localhost:$port" \
        > "logs/${service_name,,}.log" 2>&1 &

    # Guardar PID
    echo $! > "logs/${service_name,,}.pid"

    echo "✅ $service_name iniciado (PID: $!)"
}

# Aguardar um momento para os serviços iniciarem
echo "⏱️  Aguardando infraestrutura estabilizar..."
sleep 10

# Iniciar serviços na ordem correta de dependência
echo "🏛️ Iniciando serviços fundamentais..."

start_service "Admin-Service" \
    "services/fundamental/ERPZen.Admin/src/ERPZen.Admin.HttpApi.Host/ERPZen.Admin.HttpApi.Host.csproj" \
    7001

# Aguardar serviço de admin
sleep 5

start_service "Core-Service" \
    "services/fundamental/ERPZen.Core/src/ERPZen.Core.HttpApi.Host/ERPZen.Core.HttpApi.Host.csproj" \
    7002

sleep 3

start_service "Contatos-Service" \
    "services/fundamental/ERPZen.Contatos/src/ERPZen.Contatos.HttpApi.Host/ERPZen.Contatos.HttpApi.Host.csproj" \
    7003

echo "💼 Iniciando serviços de negócio..."

start_service "Financeiro-Service" \
    "services/business/ERPZen.Financeiro/src/ERPZen.Financeiro.HttpApi.Host/ERPZen.Financeiro.HttpApi.Host.csproj" \
    7004

start_service "Estoque-Service" \
    "services/business/ERPZen.Estoque/src/ERPZen.Estoque.HttpApi.Host/ERPZen.Estoque.HttpApi.Host.csproj" \
    7005

start_service "Vendas-Service" \
    "services/business/ERPZen.Vendas/src/ERPZen.Vendas.HttpApi.Host/ERPZen.Vendas.HttpApi.Host.csproj" \
    7006

start_service "Compras-Service" \
    "services/business/ERPZen.Compras/src/ERPZen.Compras.HttpApi.Host/ERPZen.Compras.HttpApi.Host.csproj" \
    7007

start_service "CRM-Service" \
    "services/business/ERPZen.CRM/src/ERPZen.CRM.HttpApi.Host/ERPZen.CRM.HttpApi.Host.csproj" \
    7008

start_service "Producao-Service" \
    "services/business/ERPZen.Producao/src/ERPZen.Producao.HttpApi.Host/ERPZen.Producao.HttpApi.Host.csproj" \
    7009

start_service "Projetos-Service" \
    "services/business/ERPZen.Projetos/src/ERPZen.Projetos.HttpApi.Host/ERPZen.Projetos.HttpApi.Host.csproj" \
    7010

start_service "RH-Service" \
    "services/business/ERPZen.RH/src/ERPZen.RH.HttpApi.Host/ERPZen.RH.HttpApi.Host.csproj" \
    7011

start_service "Comunicacao-Service" \
    "services/business/ERPZen.Comunicacao/src/ERPZen.Comunicacao.HttpApi.Host/ERPZen.Comunicacao.HttpApi.Host.csproj" \
    7012

echo "📡 Iniciando serviços de comunicação..."

start_service "Website-Service" \
    "services/communication/ERPZen.Website/src/ERPZen.Website.HttpApi.Host/ERPZen.Website.HttpApi.Host.csproj" \
    7013

start_service "Marketing-Service" \
    "services/communication/ERPZen.Marketing/src/ERPZen.Marketing.HttpApi.Host/ERPZen.Marketing.HttpApi.Host.csproj" \
    7014

start_service "Eventos-Service" \
    "services/communication/ERPZen.Eventos/src/ERPZen.Eventos.HttpApi.Host/ERPZen.Eventos.HttpApi.Host.csproj" \
    7015

start_service "Survey-Service" \
    "services/communication/ERPZen.Survey/src/ERPZen.Survey.HttpApi.Host/ERPZen.Survey.HttpApi.Host.csproj" \
    7016

start_service "Helpdesk-Service" \
    "services/communication/ERPZen.Helpdesk/src/ERPZen.Helpdesk.HttpApi.Host/ERPZen.Helpdesk.HttpApi.Host.csproj" \
    7017

start_service "Knowledge-Service" \
    "services/communication/ERPZen.Knowledge/src/ERPZen.Knowledge.HttpApi.Host/ERPZen.Knowledge.HttpApi.Host.csproj" \
    7018

echo "⚙️ Iniciando serviços operacionais..."

start_service "Qualidade-Service" \
    "services/operations/ERPZen.Qualidade/src/ERPZen.Qualidade.HttpApi.Host/ERPZen.Qualidade.HttpApi.Host.csproj" \
    7019

start_service "Manutencao-Service" \
    "services/operations/ERPZen.Manutencao/src/ERPZen.Manutencao.HttpApi.Host/ERPZen.Manutencao.HttpApi.Host.csproj" \
    7020

start_service "Campo-Service" \
    "services/operations/ERPZen.Campo/src/ERPZen.Campo.HttpApi.Host/ERPZen.Campo.HttpApi.Host.csproj" \
    7021

start_service "Documents-Service" \
    "services/operations/ERPZen.Documents/src/ERPZen.Documents.HttpApi.Host/ERPZen.Documents.HttpApi.Host.csproj" \
    7022

start_service "Timesheet-Service" \
    "services/operations/ERPZen.Timesheet/src/ERPZen.Timesheet.HttpApi.Host/ERPZen.Timesheet.HttpApi.Host.csproj" \
    7023

start_service "Expenses-Service" \
    "services/operations/ERPZen.Expenses/src/ERPZen.Expenses.HttpApi.Host/ERPZen.Expenses.HttpApi.Host.csproj" \
    7024

echo "👥 Iniciando serviços de RH..."

start_service "Attendance-Service" \
    "services/hr/ERPZen.Attendance/src/ERPZen.Attendance.HttpApi.Host/ERPZen.Attendance.HttpApi.Host.csproj" \
    7025

start_service "Leaves-Service" \
    "services/hr/ERPZen.Leaves/src/ERPZen.Leaves.HttpApi.Host/ERPZen.Leaves.HttpApi.Host.csproj" \
    7026

echo "🚗 Iniciando serviços especializados..."

start_service "Fleet-Service" \
    "services/specialized/ERPZen.Fleet/src/ERPZen.Fleet.HttpApi.Host/ERPZen.Fleet.HttpApi.Host.csproj" \
    7027

start_service "Rental-Service" \
    "services/specialized/ERPZen.Rental/src/ERPZen.Rental.HttpApi.Host/ERPZen.Rental.HttpApi.Host.csproj" \
    7028

echo "🌐 Iniciando serviços de infraestrutura..."

start_service "Survey-Service-Alternative" \
    "services/communication/ERPZen.Survey/src/ERPZen.Survey.HttpApi.Host/ERPZen.Survey.HttpApi.Host.csproj" \
    7029

start_service "Gateway-Service" \
    "services/infrastructure/ERPZen.Gateway/src/ERPZen.Gateway.HttpApi.Host/ERPZen.Gateway.HttpApi.Host.csproj" \
    7000

start_service "Notifications-Service" \
    "services/infrastructure/ERPZen.Notifications/src/ERPZen.Notifications.HttpApi.Host/ERPZen.Notifications.HttpApi.Host.csproj" \
    7030

echo "📱 Iniciando aplicações cliente..."

start_service "Web-Application" \
    "apps/ERPZen.Web/src/ERPZen.Web.HttpApi.Host/ERPZen.Web.HttpApi.Host.csproj" \
    7031

start_service "Mobile-API" \
    "apps/ERPZen.Mobile/src/ERPZen.Mobile.HttpApi.Host/ERPZen.Mobile.HttpApi.Host.csproj" \
    7032

# Aguardar serviços iniciarem
echo "⏱️  Aguardando serviços iniciarem..."
sleep 15

# Verificar saúde dos serviços
echo "🏥 Verificando saúde dos serviços..."

services=(
    "Admin-Service:7001"
    "Core-Service:7002"
    "Contatos-Service:7003"
    "Financeiro-Service:7004"
    "Estoque-Service:7005"
    "Vendas-Service:7006"
    "Compras-Service:7007"
    "CRM-Service:7008"
    "Producao-Service:7009"
    "Projetos-Service:7010"
    "RH-Service:7011"
    "Comunicacao-Service:7012"
    "Website-Service:7013"
    "Marketing-Service:7014"
    "Eventos-Service:7015"
    "Survey-Service:7016"
    "Helpdesk-Service:7017"
    "Knowledge-Service:7018"
    "Qualidade-Service:7019"
    "Manutencao-Service:7020"
    "Campo-Service:7021"
    "Documents-Service:7022"
    "Timesheet-Service:7023"
    "Expenses-Service:7024"
    "Attendance-Service:7025"
    "Leaves-Service:7026"
    "Fleet-Service:7027"
    "Rental-Service:7028"
    "Notifications-Service:7030"
    "Gateway-Service:7000"
    "Web-Application:7031"
    "Mobile-API:7032"
)

healthy_count=0
total_count=${#services[@]}

for service_info in "${services[@]}"; do
    IFS=':' read -r service_name port <<< "$service_info"

    echo -n "🔍 $service_name ($port): "

    # Tentar fazer requisição de saúde
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port/health" | grep -q "200\|404"; then
        echo -e "✅ ${GREEN}Healthy${NC}"
        healthy_count=$((healthy_count + 1))
    else
        echo -e "⚠️  ${YELLOW}Starting...${NC}"
    fi
done

# Criar script para parar serviços
cat > scripts/stop-apps.sh << 'EOF'
#!/bin/bash

echo "🛑 Parando aplicações do ERPZen..."

# Ler todos os arquivos PID e matar os processos
for pid_file in logs/*.pid; do
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        echo "🔄 Parando processo $pid ($(basename "$pid_file" .pid))..."
        kill $pid 2>/dev/null
        rm "$pid_file"
    fi
done

# Forçar parada de processos restantes
pkill -f "dotnet.*ERPZen"

echo "✅ Todos os serviços parados"
EOF

chmod +x scripts/stop-apps.sh

# Criar script para ver logs
cat > scripts/view-logs.sh << 'EOF'
#!/bin/bash

service_name=$1

if [ -z "$service_name" ]; then
    echo "📋 Logs disponíveis:"
    ls -1 logs/*.log 2>/dev/null | sed 's/logs\///g' | sed 's/\.log//g'
    echo ""
    echo "🔍 Uso: ./scripts/view-logs.sh <nome-do-serviço>"
    echo "Exemplo: ./scripts/view-logs.sh Admin-Service"
    exit 1
fi

log_file="logs/${service_name}.log"

if [ -f "$log_file" ]; then
    echo "📝 Mostrando logs do $service_name (Ctrl+C para sair):"
    tail -f "$log_file"
else
    echo "❌ Arquivo de log não encontrado: $log_file"
    exit 1
fi
EOF

chmod +x scripts/view-logs.sh

echo ""
echo -e "🎉 ${GREEN}ERPZen iniciado com sucesso!${NC}"
echo ""
echo -e "📊 ${YELLOW}Status:${NC} $healthy_count/$total_count serviços saudáveis"
echo ""
echo -e "🌐 ${YELLOW}URLs Importantes:${NC}"
echo "   • API Gateway: http://localhost:7000"
echo "   • Admin Service: http://localhost:7001"
echo "   • Core Service: http://localhost:7002"
echo "   • Web Application: http://localhost:7031"
echo "   • Mobile API: http://localhost:7032"
echo ""
echo -e "🔧 ${YELLOW}Swagger UI:${NC}"
echo "   • Admin: http://localhost:7001/swagger"
echo "   • Core: http://localhost:7002/swagger"
echo "   • Contatos: http://localhost:7003/swagger"
echo ""
echo -e "📝 ${YELLOW}Comandos Úteis:${NC}"
echo "   • Parar serviços: ./scripts/stop-apps.sh"
echo "   • Ver logs: ./scripts/view-logs.sh <serviço>"
echo "   • Ver status: curl http://localhost:7000/health"
echo ""
echo -e "🐳 ${YELLOW}Infraestrutura:${NC}"
echo "   • PostgreSQL: localhost:5432"
echo "   • Redis: localhost:6379"
echo "   • RabbitMQ Management: http://localhost:15672 (erpzen/erpzen123)"