# ERPZen - Planning Document

## Visão Geral

ERPZen é uma implementação completa de ERP em microserviços baseada no conhecimento das entidades Odoo 18, desenvolvida com ABP Framework e .NET 8.0.

## Arquitetura de Microserviços

### Estrutura Principal
```
ERPZen/
├── services/                    # 30+ microserviços
├── shared/                      # Componentes compartilhados
├── apps/                        # Aplicações cliente
├── infrastructure/              # Docker, CI/CD, Monitoramento
├── docs/                        # Documentação
└── scripts/                     # Scripts de automação
```

## Lista Completa de Microserviços (30+)

### 🏛️ Serviços Fundamentais
1. **ERPZen.Admin** - Autenticação e Administração
2. **ERPZen.Core** - Configurações e Entidades Base
3. **ERPZen.Contatos** - Gestão de Contatos e Parceiros

### 💼 Serviços de Negócio Essenciais
4. **ERPZen.Financeiro** - Contabilidade e Finanças
5. **ERPZen.Estoque** - Gestão de Estoque
6. **ERPZen.Vendas** - Pedidos de Venda
7. **ERPZen.Compras** - Pedidos de Compra
8. **ERPZen.CRM** - Gestão de Relacionamento
9. **ERPZen.Producao** - Manufatura (MRP)
10. **ERPZen.Projetos** - Gestão de Projetos
11. **ERPZen.RH** - Recursos Humanos

### 📡 Comunicação e Colaboração
12. **ERPZen.Comunicacao** - Email e Mensagens
13. **ERPZen.Website** - CMS e Gestão de Conteúdo
14. **ERPZen.Marketing** - Automação de Marketing
15. **ERPZen.Eventos** - Gestão de Eventos
16. **ERPZen.Survey** - Pesquisas e Formulários
17. **ERPZen.Helpdesk** - Suporte ao Cliente
18. **ERPZen.Knowledge** - Base de Conhecimento

### ⚙️ Operações e Qualidade
19. **ERPZen.Qualidade** - Controle de Qualidade
20. **ERPZen.Manutencao** - Manutenção de Equipamentos
21. **ERPZen.Campo** - Shop Floor / Chão de Fábrica
22. **ERPZen.Documents** - Gestão Documental
23. **ERPZen.Timesheet** - Controle de Horas
24. **ERPZen.Expenses** - Gestão de Despesas

### 🏢 Serviços de RH Expandidos
25. **ERPZen.Attendance** - Controle de Ponto
26. **ERPZen.Leaves** - Gestão de Férias e Ausências

### 🚗 Serviços Especializados
27. **ERPZen.Fleet** - Gestão de Frota
28. **ERPZen.Rental** - Gestão de Locação

### 🌐 Infraestrutura
29. **ERPZen.Gateway** - API Gateway
30. **ERPZen.Notifications** - Central de Notificações

## Mapeamento de Entidades por Serviço

### Serviços Fundamentais

#### ERPZen.Admin
- OpenIddict (OAuth2/OIDC)
- Identity Management
- Multi-tenancy
- Permissions & Roles

#### ERPZen.Core
- ResCompany (Empresas)
- ResCountry/ResState (Localização)
- ResCurrency (Moedas)
- ResUsers (Configurações básicas)
- ResConfigSettings (Configurações)

#### ERPZen.Contatos
- ResPartner (Clientes, Fornecedores, Contatos)
- ResPartnerBank (Dados Bancários)
- ResPartnerTitle (Títulos)
- ResPartnerCategory (Categorias)
- ResPartnerIndustry (Setores)

### Serviços de Negócio Essenciais

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
- ProductTemplate (Templates)

#### ERPZen.Vendas (Sales)
- SaleOrder (Pedidos)
- SaleOrderLine (Itens)
- SaleConfiguration (Configurações)
- SaleOrderTemplate (Templates)
- SaleReport (Relatórios)

#### ERPZen.Compras (Purchase)
- PurchaseOrder (Pedidos)
- PurchaseOrderLine (Itens)
- PurchaseRequisition (Requisições)
- PurchaseConfiguration (Configurações)

#### ERPZen.CRM
- CrmLead (Leads)
- CrmOpportunity (Oportunidades)
- CrmTeam (Equipes)
- CrmStage (Estágios Pipeline)
- CrmActivity (Atividades)
- CrmLostReason (Motivos Perda)

#### ERPZen.Producao (Manufacturing)
- MrpProduction (Ordens Produção)
- MrpBom (Lista Materiais)
- MrpWorkcenter (Centros Trabalho)
- MrpRouting (Roteiros)
- MrpWorkorder (Ordens Trabalho)

#### ERPZen.Projetos (Project)
- ProjectProject (Projetos)
- ProjectTask (Tarefas)
- ProjectStage (Estágios)
- ProjectCollaborator (Colaboradores)
- ProjectIssue (Issues)
- ProjectTag (Tags)

#### ERPZen.RH (Human Resources)
- HrEmployee (Funcionários)
- HrDepartment (Departamentos)
- HrJob (Cargos)
- HrContract (Contratos)
- HrApplicant (Candidatos)
- HrRecruitment (Recrutamento)

### Serviços de Comunicação

#### ERPZen.Comunicacao (Mail & Discuss)
- MailMessage (Mensagens)
- MailFollowers (Seguidores)
- MailActivity (Atividades)
- MailChannel (Canais)
- MailThread (Threads)
- Notification (Notificações)

#### ERPZen.Website (CMS)
- Website (Configurações)
- WebsitePage (Páginas)
- WebsiteMenu (Menus)
- WebsiteRedirect (Redirecionamentos)
- WebsiteSeoMetadata (SEO)

#### ERPZen.Marketing
- MarketingCampaign (Campanhas)
- MarketingCampaignLine (Itens)
- UtmCampaign (UTM Tracking)
- MarketingAutomation (Automação)
- LeadCapture (Captura Leads)

#### ERPZen.Eventos
- EventEvent (Eventos)
- EventRegistration (Inscrições)
- EventTrack (Palestras)
- EventSponsor (Patrocinadores)
- EventTicket (Tickets)

#### ERPZen.Survey
- SurveySurvey (Pesquisas)
- SurveyQuestion (Perguntas)
- SurveyUserInput (Respostas)
- SurveyQuestionAnswer (Opções)

#### ERPZen.Helpdesk
- HelpdeskTicket (Tickets)
- HelpdeskTeam (Equipes)
- HelpdeskStage (Estágios)
- HelpdeskCategory (Categorias)
- HelpdeskSla (SLAs)

#### ERPZen.Knowledge
- KnowledgeArticle (Artigos)
- KnowledgeCategory (Categorias)
- KnowledgeChapter (Capítulos)
- KnowledgeSection (Seções)

### Serviços Operacionais

#### ERPZen.Qualidade
- QualityCheck (Inspeções)
- QualityAlert (Alertas)
- QualityControlPoint (Pontos Controle)
- QualityCategory (Categorias)
- QualityTeam (Equipes)

#### ERPZen.Manutencao
- MaintenanceEquipment (Equipamentos)
- MaintenanceRequest (Solicitações)
- MaintenanceOrder (Ordens)
- MaintenanceCategory (Categorias)
- MaintenanceStage (Estágios)

#### ERPZen.Campo (Shop Floor)
- MrpWorkorder (Ordens Trabalho)
- MrpWorkcenterProductivity (Produtividade)
- BarcodeScanning (Códigos Barras)
- ManufacturingOrder (Ordens Manufatura)

#### ERPZen.Documents
- DocumentsDocument (Documentos)
- DocumentsFolder (Pastas)
- DocumentsWorkflow (Workflows)
- DocumentsAccess (Acesso)
- DocumentsVersion (Versionamento)

#### ERPZen.Timesheet
- AccountAnalyticLine (Linhas Analíticas)
- HrTimesheetSheet (Folhas Ponto)
- ProjectTask (Tarefas)

#### ERPZen.Expenses
- HrExpense (Despesas)
- HrExpenseSheet (Relatórios)
- HrExpenseProduct (Produtos)

### Serviços RH Expandidos

#### ERPZen.Attendance
- HrAttendance (Registros Ponto)
- HrAttendanceReason (Motivos)
- HrAttendanceOvertime (Horas Extras)

#### ERPZen.Leaves
- HrLeave (Licenças)
- HrLeaveType (Tipos Licença)
- HrLeaveAllocation (Alocações)
- HrLeaveAllocationRequest (Solicitações)

### Serviços Especializados

#### ERPZen.Fleet
- FleetVehicle (Veículos)
- FleetVehicleModel (Modelos)
- FleetService (Serviços)
- FleetVehicleLogServices (Logs)
- FleetVehicleCost (Custos)

#### ERPZen.Rental
- RentalOrder (Ordens Aluguel)
- RentalPricing (Preços)
- RentalProduct (Produtos Alugar)

### Infraestrutura

#### ERPZen.Gateway
- API Gateway (Ocelot/YARP)
- Rate Limiting
- Load Balancing
- Health Checks

#### ERPZen.Notifications
- Central de Notificações
- Push Notifications
- Email Templates
- SMS Integration

## Tecnologias

### Backend
- **.NET 8.0** com ABP Framework
- **Entity Framework Core** com PostgreSQL
- **Redis** para Cache Distribuído
- **RabbitMQ** para Eventos
- **Docker** para Containerização

### Frontend
- **React 19.2** com TypeScript
- **Vite** para Build
- **TailwindCSS** para Estilos
- **Zustand** para Estado

### Infraestrutura
- **Docker Compose** para Desenvolvimento
- **Kubernetes** para Produção
- **GitHub Actions** para CI/CD
- **Prometheus/Grafana** para Monitoramento

## Ordem de Implementação Sugerida

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

### Fase 4 - Colaboração (Semana 8-9)
14. ERPZen.Website
15. ERPZen.Marketing
16. ERPZen.Helpdesk
17. ERPZen.Documents
18. ERPZen.Knowledge

### Fase 5 - Avançado (Semana 10-11)
19. ERPZen.Qualidade
20. ERPZen.Manutencao
21. ERPZen.Campo
22. ERPZen.Eventos

### Fase 6 - RH Completo (Semana 12)
23. ERPZen.Timesheet
24. ERPZen.Expenses
25. ERPZen.Attendance
26. ERPZen.Leaves

### Fase 7 - Especializados (Semana 13)
27. ERPZen.Fleet
28. ERPZen.Rental
29. ERPZen.Survey

### Fase 8 - Infraestrutura (Semana 14)
30. ERPZen.Gateway
31. ERPZen.Notifications

## Banco de Dados por Serviço

Cada microserviço terá seu próprio banco de dados PostgreSQL:

- `erpzen_admin` - Autenticação e perfis
- `erpzen_core` - Configurações e entidades base
- `erpzen_contatos` - Gestão de contatos e parceiros
- `erpzen_financeiro` - Contabilidade e finanças
- `erpzen_estoque` - Gestão de estoque e produtos
- `erpzen_vendas` - Pedidos e vendas
- `erpzen_compras` - Requisições e compras
- `erpzen_crm` - Leads e oportunidades
- `erpzen_producao` - Manufatura e MRP
- `erpzen_projetos` - Gestão de projetos
- `erpzen_rh` - Recursos humanos
- `erpzen_comunicacao` - Email e mensagens
- `erpzen_website` - CMS e conteúdo
- `erpzen_marketing` - Campanhas e automação
- `erpzen_eventos` - Gestão de eventos
- `erpzen_qualidade` - Controle de qualidade
- `erpzen_manutencao` - Manutenção de equipamentos
- `erpzen_campo` - Shop floor e produção
- `erpzen_documents` - Gestão documental
- `erpzen_helpdesk` - Suporte técnico
- `erpzen_knowledge` - Base de conhecimento
- `erpzen_timesheet` - Controle de horas
- `erpzen_expenses` - Despesas corporativas
- `erpzen_attendance` - Controle de ponto
- `erpzen_leaves` - Férias e ausências
- `erpzen_fleet` - Gestão de frota
- `erpzen_rental` - Locação de bens
- `erpzen_survey` - Pesquisas e formulários

## Portos de Serviço

Cada serviço rodará em sua própria porta:

- **7000** - Gateway
- **7001** - Admin/Auth
- **7002** - Core
- **7003** - Contatos
- **7004** - Financeiro
- **7005** - Estoque
- **7006** - Vendas
- **7007** - Compras
- **7008** - CRM
- **7009** - Produção
- **7010** - Projetos
- **7011** - RH
- **7012** - Comunicação
- **7013** - Website
- **7014** - Marketing
- **7015** - Eventos
- **7016** - Qualidade
- **7017** - Manutenção
- **7018** - Campo
- **7019** - Documents
- **7020** - Helpdesk
- **7021** - Knowledge
- **7022** - Timesheet
- **7023** - Expenses
- **7024** - Attendance
- **7025** - Leaves
- **7026** - Fleet
- **7027** - Rental
- **7028** - Survey
- **7029** - Notifications
- **7030** - Web Frontend
- **7031** - Mobile API

## Próximos Passos

1. Executar scripts de criação dos projetos
2. Configurar desenvolvimento local
3. Implementar entidades base do Odoo
4. Configurar comunicação entre serviços
5. Implementar frontend unificado
6. Configurar deploy em produção