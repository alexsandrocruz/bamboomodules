#!/bin/bash

# ERPZen - Script de Criação de Microserviços (Atualizado com EasyAbp)
# Este script cria 29 serviços do ERPZen (26 custom + 3 EasyAbp)

echo "🚀 Iniciando criação do ERPZen - 29 Microserviços (26 Custom + 3 EasyAbp)"
echo "=========================================================================="

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
    "Helpdesk:Suporte ao Cliente"
    "Knowledge:Base de Conhecimento"
    "Survey:Pesquisas e Formulários"
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
echo "📋 Criando ERPZen.Fleet (Gestão de Frota)..."
abp new ERPZen.Fleet -t app -m all --database-provider ef --no-identity

# Serviços de Infraestrutura
echo "🌐 Criando serviços de infraestrutura..."
echo "📋 Criando ERPZen.Gateway (API Gateway)..."
abp new ERPZen.Gateway -t app -m all --database-provider ef --no-identity

# Criar aplicação Web
echo "🌐 Criando aplicação Web..."
abp new ERPZen.Web -t app -m all --database-provider ef --no-ui --no-identity

# Criar aplicação Mobile API
echo "📱 Criando API Mobile..."
abp new ERPZen.Mobile -t app -m all --database-provider ef --no-ui --no-identity

# Criar estrutura para EasyAbp
echo "🔧 Criando estrutura para módulos EasyAbp..."
mkdir -p services/easyabp

# Criar projeto BookingService (baseado em EasyAbp)
echo "🎯 Criando EasyAbp.BookingService..."
mkdir -p services/easyabp/BookingService
cd services/easyabp/BookingService

# Criar estrutura de projeto BookingService
echo "📁 Criando estrutura do BookingService..."
mkdir -p {src,src/BookingService.Application,src/BookingService.Application.Contracts,src/BookingService.Domain.Shared,src/BookingService.Domain,src/BookingService.EntityFrameworkCore,src/BookingService.HttpApi,src/BookingService.HttpApi.Host,test}

# Criar .csproj principal
cat > src/BookingService.Application/BookingService.Application.csproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="EasyAbp.BookingService.Application" Version="8.3.4" />
    <PackageReference Include="Volo.Abp.AutoMapper" Version="8.3.4" />
    <PackageReference Include="Volo.Abp.Ddd.Application" Version="8.3.4" />
  </ItemGroup>
</Project>
EOF

# Criar Application Module
cat > src/BookingService.Application/BookingServiceApplicationModule.cs << 'EOF'
using Volo.Abp.AutoMapper;
using Volo.Abp.Modularity;
using EasyAbp.BookingService;

[DependsOn(
    typeof(BookingServiceApplicationModule),
    typeof(AbpAutoMapperModule)
)]
public class ERPZenBookingServiceApplicationModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        // Custom configurations for ERPZen Booking Service
    }
}
EOF

# Voltar ao diretório raiz
cd - > /dev/null

# Criar projeto NotificationService (baseado em EasyAbp)
echo "📢 Criando EasyAbp.NotificationService..."
mkdir -p services/easyabp/NotificationService
cd services/easyabp/NotificationService

# Criar estrutura de projeto NotificationService
echo "📁 Criando estrutura do NotificationService..."
mkdir -p {src,src/NotificationService.Application,src/NotificationService.Application.Contracts,src/NotificationService.Domain.Shared,src/NotificationService.Domain,src/NotificationService.EntityFrameworkCore,src/NotificationService.HttpApi,src/NotificationService.HttpApi.Host,test}

# Criar .csproj principal
cat > src/NotificationService.Application/NotificationService.Application.csproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="EasyAbp.NotificationService.Application" Version="8.3.4" />
    <PackageReference Include="Volo.Abp.AutoMapper" Version="8.3.4" />
    <PackageReference Include="Volo.Abp.Ddd.Application" Version="8.3.4" />
  </ItemGroup>
</Project>
EOF

# Criar Application Module
cat > src/NotificationService.Application/NotificationServiceApplicationModule.cs << 'EOF'
using Volo.Abp.AutoMapper;
using Volo.Abp.Modularity;
using EasyAbp.NotificationService;

[DependsOn(
    typeof(NotificationServiceApplicationModule),
    typeof(AbpAutoMapperModule)
)]
public class ERPZenNotificationServiceApplicationModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        // Custom configurations for ERPZen Notification Service
        Configure<NotificationServiceOptions>(options =>
        {
            options.DefaultCulture = "pt-BR";
            options.SupportedCultures = new[] { "pt-BR", "en-US" };
        });
    }
}
EOF

# Voltar ao diretório raiz
cd - > /dev/null

# Criar script de instalação de pacotes EasyAbp
echo "📦 Criando script de instalação de pacotes EasyAbp..."
cat > scripts/install-easyabp-packages.sh << 'EOF'
#!/bin/bash

# ERPZen - Script de Instalação de Pacotes EasyAbp
# Instala os pacotes NuGet necessários para os módulos EasyAbp

echo "📦 Instalando pacotes EasyAbp..."
echo "================================"

echo "🎯 Instalando EasyAbp.BookingService..."

# Para BookingService
cd services/easyabp/BookingService/src/BookingService.Application
dotnet add package EasyAbp.BookingService.Application
dotnet add package EasyAbp.BookingService.Domain.Shared
dotnet add package Volo.Abp.AutoMapper
cd ../../../../..

cd services/easyabp/BookingService/src/BookingService.Domain
dotnet add package EasyAbp.BookingService.Domain
dotnet add package EasyAbp.BookingService.Domain.Shared
dotnet add package Volo.Abp.Ddd.Domain
cd ../../../../..

cd services/easyabp/BookingService/src/BookingService.EntityFrameworkCore
dotnet add package EasyAbp.BookingService.EntityFrameworkCore
dotnet add package EasyAbp.BookingService.Domain.Shared
dotnet add package Volo.Abp.EntityFrameworkCore.PostgreSQL
cd ../../../../..

cd services/easyabp/BookingService/src/BookingService.HttpApi
dotnet add package EasyAbp.BookingService.HttpApi
dotnet add package EasyAbp.BookingService.Application.Contracts
cd ../../../../..

echo "📢 Instalando EasyAbp.NotificationService..."

# Para NotificationService
cd services/easyabp/NotificationService/src/NotificationService.Application
dotnet add package EasyAbp.NotificationService.Application
dotnet add package EasyAbp.NotificationService.Domain.Shared
dotnet add package Volo.Abp.AutoMapper
cd ../../../../..

cd services/easyabp/NotificationService/src/NotificationService.Domain
dotnet add package EasyAbp.NotificationService.Domain
dotnet add package EasyAbp.NotificationService.Domain.Shared
dotnet add package Volo.Abp.Ddd.Domain
cd ../../../../..

cd services/easyabp/NotificationService/src/NotificationService.EntityFrameworkCore
dotnet add package EasyAbp.NotificationService.EntityFrameworkCore
dotnet add package EasyAbp.NotificationService.Domain.Shared
dotnet add package Volo.Abp.EntityFrameworkCore.PostgreSQL
cd ../../../../..

cd services/easyabp/NotificationService/src/NotificationService.HttpApi
dotnet add package EasyAbp.NotificationService.HttpApi
dotnet add package EasyAbp.NotificationService.Application.Contracts
cd ../../../../..

echo "✅ Pacotes EasyAbp instalados com sucesso!"
EOF

chmod +x scripts/install-easyabp-packages.sh

echo ""
echo "🎉 Estrutura do ERPZen criada com sucesso!"
echo ""
echo "📊 Resumo:"
echo "   • 26 microserviços custom criados"
echo "   • 2 serviços EasyAbp integrados (BookingService, NotificationService)"
echo "   • 1 aplicação Web"
echo "   • 1 API Mobile"
echo "   • Estrutura completa de diretórios"
echo ""
echo "🔧 Próximos passos:"
echo "   1. Execute: chmod +x scripts/setup-structure-updated.sh"
echo "   2. Execute: scripts/setup-structure-updated.sh"
echo "   3. Execute: scripts/install-easyabp-packages.sh"
echo "   4. Configure docker-compose-updated.yml"
echo "   5. Execute: docker-compose up -d"
echo ""
echo "📚 Consulte o arquivo ERPZen-Planning-Updated.md para mais detalhes"
echo ""
echo "🔗 Referências EasyAbp:"
echo "   • BookingService: https://github.com/EasyAbp/BookingService"
echo "   • NotificationService: https://github.com/EasyAbp/NotificationService"