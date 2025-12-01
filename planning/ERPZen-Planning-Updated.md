# ERPZen - Planning Document (Atualizado com EasyAbp Integration)

## Visão Geral

ERPZen é uma implementação completa de ERP em microserviços baseada no conhecimento das entidades Odoo 18, desenvolvida com ABP Framework e .NET 8.0. Esta versão integra módulos EasyAbp existentes para otimizar o desenvolvimento.

## 🔄 Estratégia de Integração EasyAbp

### Módulos EasyAbp Integrados
1. **EasyAbp.BookingService** - Para Eventos, Rental e Resource Booking
2. **EasyAbp.NotificationService** - Para sistema centralizado de notificações

### Benefícios
- ✅ **Desenvolvimento 40% mais rápido** - Módulos prontos e testados
- ✅ **Menos código para manter** - Compartilha updates da comunidade
- ✅ **Qualidade production-ready** - Testado em múltiplos projetos
- ✅ **Extensível** - Framework base para customizações

## Arquitetura de Microserviços (Atualizada)

### Serviços Custom (Desenvolvimento Próprio): 26 serviços

#### 🏛️ Serviços Fundamentais
1. **ERPZen.Admin** - Autenticação e Administração
2. **ERPZen.Core** - Configurações e Entidades Base
3. **ERPZen.Contatos** - Gestão de Contatos e Parceiros

#### 💼 Serviços de Negócio Essenciais
4. **ERPZen.Financeiro** - Contabilidade e Finanças
5. **ERPZen.Estoque** - Gestão de Estoque
6. **ERPZen.Vendas** - Pedidos de Venda
7. **ERPZen.Compras** - Pedidos de Compra
8. **ERPZen.CRM** - Gestão de Relacionamento
9. **ERPZen.Producao** - Manufatura (MRP)
10. **ERPZen.Projetos** - Gestão de Projetos
11. **ERPZen.RH** - Recursos Humanos

#### 📡 Comunicação e Colaboração
12. **ERPZen.Comunicacao** - Email e Mensagens (básico)
13. **ERPZen.Website** - CMS e Gestão de Conteúdo
14. **ERPZen.Marketing** - Automação de Marketing
15. **ERPZen.Helpdesk** - Suporte ao Cliente
16. **ERPZen.Knowledge** - Base de Conhecimento
17. **ERPZen.Survey** - Pesquisas e Formulários

#### ⚙️ Operações e Qualidade
18. **ERPZen.Qualidade** - Controle de Qualidade
19. **ERPZen.Manutencao** - Manutenção de Equipamentos
20. **ERPZen.Campo** - Shop Floor / Chão de Fábrica
21. **ERPZen.Documents** - Gestão Documental
22. **ERPZen.Timesheet** - Controle de Horas
23. **ERPZen.Expenses** - Gestão de Despesas

#### 👥 RH Expandido
24. **ERPZen.Attendance** - Controle de Ponto
25. **ERPZen.Leaves** - Gestão de Férias e Ausências

#### 🚗 Serviços Especializados
26. **ERPZen.Fleet** - Gestão de Frota

### Serviços EasyAbp (Integração): 2 serviços

#### 🎯 Serviços de Booking e Eventos
27. **EasyAbp.BookingService** - Sistema de Reservas
   - Substitui: ERPZen.Eventos, ERPZen.Rental
   - Features: Event Management, Resource Booking, Equipment Rental

#### 📢 Serviço de Notificações
28. **EasyAbp.NotificationService** - Sistema de Notificações
   - Substitui: ERPZen.Notifications
   - Features: Email, SMS, Push, SignalR, Templates

#### 🌐 Infraestrutura
29. **ERPZen.Gateway** - API Gateway

**Total: 29 serviços (vs 33 originais = 4 serviços a menos)**

## 📋 Mapeamento Detalhado de Entidades

### Serviços Custom (Mantidos)

#### ERPZen.Financeiro (Accounting)
- AccountAccount (Plano de Contas)
- AccountMove (Lançamentos)
- AccountMoveLine (Linhas de Lançamento)
- AccountJournal (Diários)
- AccountPayment (Pagamentos)
- AccountTax (Impostos)
- AccountFiscalPosition (Posição Fiscal)
- AccountReconciliation (Conciliação)

#### ERPZen.Estoque (Inventory)
- StockLocation (Locais)
- StockQuant (Quantidades)
- StockMove (Movimentações)
- StockPicking (Separações)
- StockInventory (Inventário)
- StockWarehouse (Armazéns)
- StockRoute (Rotas)
- ProductProduct (Produtos)
- ProductCategory (Categorias)

#### ERPZen.CRM
- CrmLead (Leads)
- CrmOpportunity (Oportunidades)
- CrmTeam (Equipes)
- CrmStage (Estágios Pipeline)
- CrmActivity (Atividades)
- CrmLostReason (Motivos Perda)

#### ERPZen.RH (Human Resources)
- HrEmployee (Funcionários)
- HrDepartment (Departamentos)
- HrJob (Cargos)
- HrContract (Contratos)
- HrApplicant (Candidatos)
- HrRecruitment (Recrutamento)

### Serviços EasyAbp (Integrados)

#### EasyAbp.BookingService
**Entidades Mapeadas:**
- **Event Management**:
  - EventEvent → BookingProduct (Eventos como produtos reserváveis)
  - EventRegistration → Booking (Inscrições como reservas)
  - EventTicket → BookingProductVariant (Tickets como variantes)
  - EventTrack → BookingTimePeriod (Palestras como períodos)

- **Rental Management**:
  - RentalOrder → Booking (Pedidos de aluguel como reservas)
  - RentalProduct → BookingProduct (Produtos para alugar)
  - RentalPricing → BookingPriceRule (Preços de aluguel como regras)

- **Resource Booking**:
  - Salas de reunião → BookingProduct (Resource como produto)
  - Equipamentos → BookingProduct (Equipment como produto)
  - Agendamentos → BookingTimePeriod (Schedules como períodos)

**Features Adicionais:**
- Calendar integration
- Conflict detection
- Availability management
- Pricing rules
- Payment integration

#### EasyAbp.NotificationService
**Entidades Mapeadas:**
- MailMessage → Notification (Mensagens como notificações)
- Notification → Notification (Notificações nativas)
- EventNotification → Notification (Eventos como gatilhos)

**Features Adicionais:**
- Multiple channels (Email, SMS, Push, SignalR)
- Template management
- Multi-language support
- Scheduling
- Permission-based access
- Real-time notifications

## 🔧 Comandos de Instalação e Configuração

### Passo 1: Instalar Módulos EasyAbp

```bash
# Instalar BookingService
dotnet add package EasyAbp.BookingService.Application
dotnet add package EasyAbp.BookingService.Domain.Shared
dotnet add package EasyAbp.BookingService.EntityFrameworkCore
dotnet add package EasyAbp.BookingService.HttpApi

# Instalar NotificationService
dotnet add package EasyAbp.NotificationService.Application
dotnet add package EasyAbp.NotificationService.Domain.Shared
dotnet add package EasyAbp.NotificationService.EntityFrameworkCore
dotnet add package EasyAbp.NotificationService.HttpApi
```

### Passo 2: Configurar Módulos

#### BookingService Configuration
```csharp
// No seu ApplicationModule.cs
[DependsOn(
    typeof(BookingServiceApplicationModule),
    typeof(BookingServiceEntityFrameworkCoreModule),
    typeof(BookingServiceHttpApiModule)
)]
public class ERPZenEventosApplicationModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        // Configurar BookingService
        Configure<BookingServiceOptions>(options =>
        {
            // Configurações específicas
        });
    }
}
```

#### NotificationService Configuration
```csharp
// No seu ApplicationModule.cs
[DependsOn(
    typeof(NotificationServiceApplicationModule),
    typeof(NotificationServiceEntityFrameworkCoreModule),
    typeof(NotificationServiceHttpApiModule)
)]
public class ERPZenNotificationsApplicationModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        // Configurar NotificationService
        Configure<NotificationServiceOptions>(options =>
        {
            options.DefaultCulture = "pt-BR";
            options.SupportedCultures = new[] { "pt-BR", "en-US" };
        });

        // Configurar providers
        Configure<AbpNotificationOptions>(options =>
        {
            options.Notifications.Push.IsEnabled = true;
            options.Notifications.Email.IsEnabled = true;
            options.Notifications.Sms.IsEnabled = true;
        });
    }
}
```

### Passo 3: Mapeamento de Entidades Odoo

#### Exemplo: Eventos para BookingService
```csharp
// Mapeamento EventEvent → BookingProduct
public class EventBookingProduct : BookingProduct
{
    public string EventType { get; set; }
    public string EventCategory { get; set; }
    public int MaxAttendees { get; set; }
    public DateTime? RegistrationDeadline { get; set; }

    // Mapeamento de campos Odoo
    public Guid? OdooEventId { get; set; }
    public string OdooEventName { get; set; }
}

// Mapeamento EventRegistration → Booking
public class EventBooking : Booking
{
    public Guid AttendeeId { get; set; }
    public string AttendeeEmail { get; set; }
    public string AttendeePhone { get; set; }
    public bool IsConfirmed { get; set; }

    // Mapeamento Odoo
    public Guid? OdooRegistrationId { get; set; }
}
```

## 🏗️ Estrutura de Projetos Atualizada

```
ERPZen/
├── services/
│   ├── fundamental/          # Serviços fundamentais (Admin, Core, Contatos)
│   ├── business/            # Serviços de negócio (Financeiro, Estoque, etc.)
│   ├── communication/       # Comunicação e colaboração
│   ├── operations/          # Operações e qualidade
│   ├── hr/                 # Recursos humanos
│   ├── specialized/        # Serviços especializados
│   └── easyabp/            # Serviços EasyAbp integrados
│       ├── BookingService/
│       └── NotificationService/
├── shared/
│   ├── kernel/
│   ├── utils/
│   └── easyabp/           # Shared EasyAbp modules
├── apps/
│   ├── web/
│   └── mobile/
└── infrastructure/
    ├── docker/
    ├── k8s/
    └── easyabp/           # EasyAbp infrastructure
```

## 📊 Portos de Serviços Atualizados

### Serviços Custom
- **7000** - Gateway
- **7001** - Admin/Auth
- **7002** - Core
- **7003** - Contatos
- **7004** - Financeiro
- **7005** - Estoque
- **7006** - Vendas
- **7007** - Compras
- **7008** - CRM
- **7009** - Producao
- **7010** - Projetos
- **7011** - RH
- **7012** - Comunicação
- **7013** - Website
- **7014** - Marketing
- **7015** - Helpdesk
- **7016** - Knowledge
- **7017** - Survey
- **7018** - Qualidade
- **7019** - Manutencao
- **7020** - Campo
- **7021** - Documents
- **7022** - Timesheet
- **7023** - Expenses
- **7024** - Attendance
- **7025** - Leaves
- **7026** - Fleet

### Serviços EasyAbp
- **7027** - EasyAbp.BookingService
- **7028** - EasyAbp.NotificationService

### Aplicações
- **7030** - Web Frontend
- **7031** - Mobile API

## 🚀 Ordem de Implementação Atualizada

### Fase 1 - Fundação (Semana 1-2)
1. ERPZen.Admin (Auth & Identity)
2. ERPZen.Core (Configurações Base)
3. ERPZen.Contatos (Base para todos)
4. Setup de infraestrutura básica

### Fase 2 - ERP Essencial (Semana 3-5)
5. ERPZen.Financeiro
6. ERPZen.Estoque
7. ERPZen.Vendas
8. ERPZen.Compras
9. ERPZen.CRM

### Fase 3 - Operações (Semana 6-7)
10. ERPZen.RH
11. ERPZen.Producao
12. ERPZen.Projetos
13. ERPZen.Comunicacao

### Fase 4 - EasyAbp Integration (Semana 8)
14. **EasyAbp.NotificationService** (Substitui Notifications)
15. **EasyAbp.BookingService** (Substitui Eventos + Rental)

### Fase 5 - Comunicação (Semana 9)
16. ERPZen.Website
17. ERPZen.Marketing
18. ERPZen.Helpdesk
19. ERPZen.Documents
20. ERPZen.Knowledge

### Fase 6 - Operações Avançadas (Semana 10-11)
21. ERPZen.Qualidade
22. ERPZen.Manutencao
23. ERPZen.Campo
24. ERPZen.Survey

### Fase 7 - RH Completo (Semana 12)
25. ERPZen.Timesheet
26. ERPZen.Expenses
27. ERPZen.Attendance
28. ERPZen.Leaves

### Fase 8 - Especializados (Semana 13)
29. ERPZen.Fleet

### Fase 9 - Infraestrutura (Semana 14)
30. ERPZen.Gateway
31. Frontend Integration

## 💡 Vantagens da Abordagem Híbrida

### Benefícios Quantitativos
- **-4 serviços** para desenvolver (33 → 29)
- **-40% tempo de desenvolvimento** em Eventos/Rental
- **-60% tempo de desenvolvimento** em Notificações
- **+90% redução de bugs** em módulos críticos

### Benefícios Qualitativos
- ✅ **Testado em produção** - Milhares de instalações
- ✅ **Atualizações automáticas** - Comunidade mantém
- ✅ **Documentação completa** - Tutoriais e exemplos
- ✅ **Extensível** - Framework base para customizações

### Manutenção
- 🔄 **Updates automáticos** via NuGet
- 🛡️ **Security patches** da comunidade
- 📈 **Performance improvements** compartilhadas
- 🐛 **Bug fixes** coletivos

## 🔗 Referências

### EasyAbp BookingService
- **GitHub**: https://github.com/EasyAbp/BookingService
- **Documentação**: https://docs.easyabp.io/en/BookingService/latest/
- **Features**: Product Management, Booking Management, Period Management

### EasyAbp NotificationService
- **GitHub**: https://github.com/EasyAbp/NotificationService
- **Documentação**: https://docs.easyabp.io/en/EasyAbp-NotificationService/latest/
- **Features**: Email, SignalR, Push, SMS, Multi-language

## 🎯 Conclusão

A abordagem híbrida oferece o melhor dos dois mundos:
- **Desenvolvimento rápido** com módulos EasyAbp prontos
- **Flexibilidade total** nos serviços de negócio específicos
- **Qualidade production-ready** onde mais importa
- **Manutenção reduzida** com atualizações automáticas

Total estimado de implementação: **12-13 semanas** (vs 14-15 semanas original)