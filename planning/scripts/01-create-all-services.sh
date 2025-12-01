#!/bin/bash

# ERPZen - Script de Criação de Todos os Microserviços
# Este script cria todos os 30+ serviços do ERPZen usando ABP CLI

echo "🚀 Iniciando criação do ERPZen - 30+ Microserviços"
echo "================================================="

# Verificar se ABP CLI está instalado
if ! command -v abp &> /dev/null; then
    echo "❌ ABP CLI não está instalada. Execute: dotnet tool install -g Volo.Abp.Cli"
    exit 1
fi

# Criar estrutura principal
echo "📁 Criando estrutura de diretórios..."
mkdir -p ERPZen/services
mkdir -p ERPZen/shared
mkdir -p ERPZen/apps
mkdir -p ERPZen/infrastructure
mkdir -p ERPZen/docs

cd ERPZen

echo "✅ Estrutura de diretórios criada"

# Serviços Fundamentais
echo "🏛️ Criando serviços fundamentais..."

echo "📋 Criando ERPZen.Admin (Auth & Identity)..."
abp new ERPZen.Admin -t app -m all --database-provider ef --separate-identity-server

echo "📋 Criando ERPZen.Core (Configurações Base)..."
abp new ERPZen.Core -t app -m all --database-provider ef --no-identity

echo "📋 Criando ERPZen.Contatos (Gestão de Contatos)..."
abp new ERPZen.Contatos -t app -m all --database-provider ef --no-identity

# Serviços de Negócio Essenciais
echo "💼 Criando serviços de negócio essenciais..."

services_essentials=(
    "Financeiro:Contabilidade e Finanças"
    "Estoque:Gestão de Estoque e Produtos"
    "Vendas:Pedidos de Venda"
    "Compras:Requisições e Compras"
    "CRM:Gestão de Relacionamento com Cliente"
    "Producao:Manufatura e MRP"
    "Projetos:Gestão de Projetos"
    "RH:Recursos Humanos"
    "Comunicacao:Email e Mensagens"
)

for service_info in "${services_essentials[@]}"; do
    IFS=':' read -r service_name description <<< "$service_info"
    echo "📋 Criando ERPZen.$service_name ($description)..."
    abp new ERPZen.$service_name -t app -m all --database-provider ef --no-identity
done

# Serviços de Comunicação e Colaboração
echo "📡 Criando serviços de comunicação e colaboração..."

services_communication=(
    "Website:CMS e Gestão de Conteúdo"
    "Marketing:Automação de Marketing"
    "Eventos:Gestão de Eventos"
    "Survey:Pesquisas e Formulários"
    "Helpdesk:Suporte ao Cliente"
    "Knowledge:Base de Conhecimento"
)

for service_info in "${services_communication[@]}"; do
    IFS=':' read -r service_name description <<< "$service_info"
    echo "📋 Criando ERPZen.$service_name ($description)..."
    abp new ERPZen.$service_name -t app -m all --database-provider ef --no-identity
done

# Serviços Operacionais e Qualidade
echo "⚙️ Criando serviços operacionais e qualidade..."

services_operations=(
    "Qualidade:Controle de Qualidade"
    "Manutencao:Manutenção de Equipamentos"
    "Campo:Shop Floor / Chão de Fábrica"
    "Documents:Gestão Documental"
    "Timesheet:Controle de Horas"
    "Expenses:Gestão de Despesas"
)

for service_info in "${services_operations[@]}"; do
    IFS=':' read -r service_name description <<< "$service_info"
    echo "📋 Criando ERPZen.$service_name ($description)..."
    abp new ERPZen.$service_name -t app -m all --database-provider ef --no-identity
done

# Serviços de RH Expandidos
echo "👥 Criando serviços de RH expandidos..."

services_hr_extended=(
    "Attendance:Controle de Ponto"
    "Leaves:Gestão de Férias e Ausências"
)

for service_info in "${services_hr_extended[@]}"; do
    IFS=':' read -r service_name description <<< "$service_info"
    echo "📋 Criando ERPZen.$service_name ($description)..."
    abp new ERPZen.$service_name -t app -m all --database-provider ef --no-identity
done

# Serviços Especializados
echo "🚗 Criando serviços especializados..."

services_specialized=(
    "Fleet:Gestão de Frota"
    "Rental:Gestão de Locação"
)

for service_info in "${services_specialized[@]}"; do
    IFS=':' read -r service_name description <<< "$service_info"
    echo "📋 Criando ERPZen.$service_name ($description)..."
    abp new ERPZen.$service_name -t app -m all --database-provider ef --no-identity
done

# Serviços de Infraestrutura
echo "🌐 Criando serviços de infraestrutura..."

services_infrastructure=(
    "Gateway:API Gateway"
    "Notifications:Central de Notificações"
)

for service_info in "${services_infrastructure[@]}"; do
    IFS=':' read -r service_name description <<< "$service_info"
    echo "📋 Criando ERPZen.$service_name ($description)..."
    abp new ERPZen.$service_name -t app -m all --database-provider ef --no-identity
done

# Criar aplicação Web
echo "🌐 Criando aplicação Web..."
abp new ERPZen.Web -t app -m all --database-provider ef --no-ui --no-identity

# Criar aplicação Mobile API
echo "📱 Criando API Mobile..."
abp new ERPZen.Mobile -t app -m all --database-provider ef --no-ui --no-identity

echo ""
echo "🎉 Todos os serviços do ERPZen foram criados com sucesso!"
echo ""
echo "📊 Resumo:"
echo "   • 30+ microserviços criados"
echo "   • 1 aplicação Web"
echo "   • 1 API Mobile"
echo "   • Estrutura completa de diretórios"
echo ""
echo "🔧 Próximos passos:"
echo "   1. Execute: chmod +x scripts/setup-structure.sh"
echo "   2. Execute: scripts/setup-structure.sh"
echo "   3. Configure docker-compose.yml"
echo "   4. Execute: docker-compose up -d"
echo ""
echo "📚 Consulte o arquivo ERPZen-Planning.md para mais detalhes"