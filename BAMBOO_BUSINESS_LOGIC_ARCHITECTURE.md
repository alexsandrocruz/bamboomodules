# Arquitetura de Regras de Negócio - Bamboo ERP

## Visão Geral

Você está correto! O Bamboo ERP possui uma **API Genérica de CRUD** para operações básicas, mas as **regras de negócio complexas** estão implementadas em uma arquitetura bem estruturada separadamente. Esta é uma prática excelente de arquitetura de software.

## 🏗️ Arquitetura de Regras de Negócio

### Padrão Arquitetural

O projeto segue uma **arquitetura em camadas limpamente separada**:

```
┌─────────────────────────────────────┐
│           API Genérica CRUD         │ ← Operações básicas (create, read, update, delete)
├─────────────────────────────────────┤
│       Application Services          │ ← **LÓGICA DE NEGÓCIO AQUI** 🎯
├─────────────────────────────────────┤
│           Domain Layer              │ ← Entidades e regras de domínio
├─────────────────────────────────────┤
│      Infrastructure Layer           │ ← Repositórios e dados
└─────────────────────────────────────┘
```

---

## 📍 Onde Ficam as Regras de Negócio

### 1. **Application Services** (Principal Localização)

**Caminho**: `/services/core/src/Bamboo.Core.Application/Services/`

Esta é **onde estão 90% das regras de negócio**! Cada módulo tem seu serviço específico:

#### 📋 Estrutura dos Services:
```
Services/
├── Accounting/
│   ├── AccountMoveAppService.cs      ← Regras de faturamento
│   ├── AccountPaymentAppService.cs   ← Regras de pagamento
│   └── AccountTaxAppService.cs       ← Regras de impostos
├── Inventory/
│   ├── StockPickingAppService.cs     ← Regras de separação de estoque
│   └── StockMoveAppService.cs        ← Regras de movimentação
├── Manufacturing/
│   ├── MrpProductionAppService.cs    ← Regras de produção
│   └── MrpBomAppService.cs           ← Regras de BOM
├── HumanResources/
│   ├── HrEmployeeAppService.cs       ← Regras de funcionários
│   └── HrContractAppService.cs       ← Regras de contratos
└── Mixins/                           ← Lógica compartilhada
    ├── ProductCatalogMixinAppService.cs
    └── MailActivityMixinAppService.cs
```

### 2. **Generic CRUD Foundation** (Base)

**Arquivo**: `/services/core/src/Bamboo.Core.Application/Commons/GenericApplicationService.cs`

```csharp
public class GenericApplicationService<TEntity> : ApplicationService
{
    // Fornece CRUD básico para TODAS as entidades
    // CREATE, READ, UPDATE, DELETE genéricos
}
```

### 3. **Business Logic Extension Pattern**

Cada serviço específico **herda** do serviço genérico e **adiciona** regras de negócio:

```csharp
[Module("Account")]
public class AccountMoveAppService : GenericApplicationService<AccountMove>
{
    // === REGRAS DE NEGÓCIO ESPECÍFICAS ===

    // Fluxo de faturamento
    protected async Task<AccountMove> ActionInvoiceReadyToBeSentInternalAsync()
    {
        // Lógica complexa de quando uma fatura está pronta para envio
    }

    // Integração com ordens de compra
    protected async Task AddPurchaseOrderLinesAsync()
    {
        // Lógica de integração entre módulos
    }
}
```

---

## 💡 Exemplos de Regras de Negócio Implementadas

### 🏦 **Contabilidade (AccountMoveAppService)**

```csharp
// Regra: Fatura pronta para envio
ActionInvoiceReadyToBeSentInternalAsync()

// Regra: Adicionar linhas de ordem de compra
AddPurchaseOrderLinesAsync()

// Regra: Validação de fatura
ButtonValidateAsync()
```

### 📦 **Estoque (StockPickingAppService)**

```csharp
// Regra: Finalizar separação de estoque
ActionDoneInternalAsync()

// Regra: Processar sucata/quebra
ButtonScrapAsync()

// Regra: Validar separação
ButtonValidateAsync()
```

### 🏭 **Manufatura (MrpProductionAppService)**

```csharp
// Regra: Cancelar ordem de produção
ActionCancelInternalAsync()

// Regra: Gerar backorder
ActionGenerateBackorderWizardInternalAsync()

// Regra: Alocar recursos
AssignAsync()
```

---

## 🔧 Padrões de Implementação de Regras

### 1. **Action/Handler Pattern**

```csharp
// Actions visíveis para o usuário (botões na UI)
public async Task ButtonOpenBillsAsync()
{
    // Chama a lógica interna
    return await ActionOpenBillsInternalAsync();
}

// Lógica interna de negócio
protected async Task ActionOpenBillsInternalAsync()
{
    // === REGRAS DE NEGÓCIO COMPLEXAS ===
    // Validações, cálculos, integrações
}
```

### 2. **Mixin Services** (Lógica Compartilhada)

Para lógica que é usada por múltiplos módulos:

```csharp
// Compartilhado entre vários serviços
public class ProductCatalogMixinAppService
{
    // Lógica de catálogo de produtos usada em vendas, compras, etc.
}
```

### 3. **Authorization & Domain Rules**

**Arquivo**: `/services/core/src/Bamboo.Core.Application/Commons/`

```csharp
public class AuthorizationService
{
    // Regras de acesso baseadas em negócio
    // "Usuários do grupo 'Contador' podem editar faturas"
    // "Somente gerentes podem aprovar ordens > R$10.000"
}

public class DomainParser
{
    // Converte regras de domínio Odoo para queries SQL
    // " [('state', '=', 'draft')] " → WHERE state = 'draft'
}
```

---

## 🎯 Tipos de Regras de Negócio Encontradas

### 1. **Workflow Management**
- **Estados e Transições**: Draft → Confirmed → Done → Cancelled
- **Validações de Estado**: "Fatura cancelada não pode ser editada"
- **Autorizações**: "Aprovação necessária para valores > R$5.000"

### 2. **Cálculos de Negócio**
- **Cálculos de Impostos**: Automatically calculate based on product tax rules
- **Preços e Descontos**: Business rules for pricing based on customer, quantity, promotions
- **Custos de Produção**: Material costs, labor costs, overhead allocation

### 3. **Integrações entre Módulos**
- **Vendas → Estoque**: Automatic stock reservation when confirming sales order
- **Compras → Contabilidade**: Invoice generation from purchase orders
- **Produção → Estoque**: Raw material consumption, finished goods receipt

### 4. **Validações de Negócio**
- **Validações de Campos**: "Data de vencimento deve ser futura"
- **Regras de Negócio**: "Cliente com contas atrasadas não pode fazer novas compras"
- **Validações Cruzadas**: "Quantidade não pode exceder estoque disponível"

### 5. **Automações**
- **Envio Automático**: Send invoice email when status becomes 'ready_to_send'
- **Atualizações em Lote**: Update product costs from purchase orders
- **Notificações**: Alert managers when inventory below minimum

---

## 🏛️ Vantagens Desta Arquitetura

### ✅ **Separação Clara**
- **CRUD Genérico**: Fácil para operações básicas
- **Business Logic**: Concentrada e organizada
- **Extensibilidade**: Fácil adicionar novas regras

### ✅ **Consistência**
- **Padrões Repetíveis**: Mesmos patterns para todos os módulos
- **Herança**: Reutilização de lógica comum
- **Interface Consistente**: Mesmos tipos de operações

### ✅ **Odoo Compatibility**
- **Mapeamento Direto**: Lógica mantida compatível com Odoo
- **Comentários Fonte**: Referências ao código Python original
- **Comportamento Idêntico**: Mesmas regras do sistema original

### ✅ **Performance**
- **Cached Authorization**: Regras de acesso em cache
- **Optimized Queries**: Domain parsing otimizado
- **Async Operations**: Todas operações são assíncronas

---

## 🔍 Como Adicionar Novas Regras de Negócio

### Passo 1: Identificar o Service

```csharp
// Se for regra de faturamento:
/services/core/src/Bamboo.Core.Application/Services/Accounting/AccountMoveAppService.cs

// Se for regra de estoque:
/services/core/src/Bamboo.Core.Application/Services/Inventory/StockPickingAppService.cs
```

### Passo 2: Implementar o Método

```csharp
public class AccountMoveAppService : GenericApplicationService<AccountMove>
{
    // Nova regra de negócio
    protected async Task<AccountMove> MyNewBusinessRuleAsync()
    {
        // 1. Validações de negócio
        // 2. Cálculos necessários
        // 3. Integrações com outros módulos
        // 4. Atualizações de estado
        // 5. Notificações
        // 6. Retorno do resultado

        return entity;
    }

    // Se for action visível para usuário:
    public async Task<MyResultDto> ButtonMyNewActionAsync()
    {
        var entity = await MyNewBusinessRuleAsync();
        return ObjectMapper.Map<AccountMove, MyResultDto>(entity);
    }
}
```

### Passo 3: Se for Lógica Compartilhada

```csharp
// Criar novo Mixin se a lógica for usada por múltiplos serviços
public class MySharedLogicMixinAppService
{
    // Lógica compartilhada aqui
}
```

---

## 📊 Resumo da Arquitetura

| Componente | Propósito | Exemplo |
|------------|-----------|---------|
| **Generic CRUD** | Operações básicas de banco | `Create`, `Read`, `Update`, `Delete` |
| **App Services** | **Regras de negócio específicas** | `ActionInvoiceReadyToBeSentAsync` |
| **Mixins** | Lógica compartilhada entre módulos | `ProductCatalogMixin` |
| **Authorization** | Regras de acesso baseadas em negócio | "Apenas contadores podem editar faturas" |
| **Domain Parser** | Conversão de regras de domínio Odoo | `[('state', '=', 'draft')]` → SQL |

## 🎯 Conclusão

A arquitetura do Bamboo ERP é **excelente** para separação de responsabilidades:

1. **API Genérica** para CRUD fácil e rápido
2. **Business Rules** em Application Services bem organizados
3. **Shared Logic** através de Mixins
4. **Security & Authorization** integrados nas regras de negócio

Esta abordagem permite que o sistema cresça de forma organizada, com regras de negócio claras, separadas da infraestrutura básica, mantendo compatibilidade com o Odoo original.