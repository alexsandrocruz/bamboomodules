# Como Funcionam as Regras de Negócio no Bamboo ERP

## 🎯 **Fluxo Mágico da API Genérica**

Quando você chama `POST /api/v1/generic/ResPartner/create` para incluir um contato, acontece este processo incrível:

### **1. Roteamento Genérico**
```
HTTP Request → GenericModelController → GenericModelService
```

O sistema recebe a requisição HTTP genérica e começa o processo de resolução.

### **2. Resolução Dinâmica (O Segredo!)**
```csharp
var service = GetGenericService("ResPartner");
// 🎩 MÁGICA ACONTECE AQUI!
```

O sistema precisa descobrir qual service específico deve ser chamado para aquela entidade.

### **3. ModelTypeRegistry - O Mapa do Tesouro**
Este é o **componente principal** que mapeia nomes de entidades para services específicos:

- `"ResPartner"` → `IResPartnerAppService`
- `"AccountMove"` → `IAccountMoveAppService`
- `"StockPicking"` → `IStockPickingAppService`

**Como funciona o registro automático:**
1. **No startup**: Scanneia todos os assemblies do projeto
2. **Auto-descoberta**: Encontra services com atributo `[Model("nome_odoo")]`
3. **Registro**: Cria um mapa mental de `nome → service`
4. **Cache**: Mantém o mapa em memória para performance

### **4. Service Resolution via Dependency Injection**
```csharp
// Se existe service específico:
var service = ServiceProvider.GetService<IResPartnerAppService>();

// Se não existe, usa service genérico:
var service = ServiceProvider.GetService<IGenericApplicationService<ResPartner>>();
```

O sistema tenta injetar o service específico. Se não encontrar, ele usa o service genérico como fallback.

### **5. Chamada Dinâmica via Reflection**
```csharp
// Chama método dinamicamente com os parâmetros corretos
CallServiceMethodAsync<ResPartner>(service, "CreateAsync", entity, fields);
```

Usa reflection para invocar o método específico no service encontrado.

### **6. Business Logic! 🏢**
Aqui é onde as regras de negócio realmente vivem:

```csharp
[Model("res.partner")]
public class ResPartnerAppService : GenericApplicationService<ResPartner>
{
    // 🏢 **AQUI FICAM AS REGRAS DE NEGÓCIO!**
    public override async Task<ResPartner> CreateAsync(ResPartner entity, List<string> fields)
    {
        // ✅ Validações de negócio
        if (string.IsNullOrEmpty(entity.Name))
            throw new UserFriendlyException("Nome do contato é obrigatório");

        // ✅ Validação de email único
        if (!string.IsNullOrEmpty(entity.Email) && await EmailJaExiste(entity.Email))
            throw new UserFriendlyException("Email já cadastrado");

        // ✅ Lógica específica do domínio
        if (entity.IsCompany)
            entity.CompanyType = "company";
        else
            entity.CompanyType = "person";

        // ✅ Integrações com outros sistemas
        if (entity.NeedsCrmSync)
            await SyncWithCrm(entity);

        // 📦 Chama o CRUD genérico para persistência
        return await base.CreateAsync(entity, fields);
    }
}
```

### **7. Generic Base - CRUD Padrão**
```csharp
public class GenericApplicationService<TEntity> : ApplicationService
{
    public virtual async Task<TEntity> CreateAsync(TEntity entity, List<string> fields)
    {
        // 🔐 Autorização e segurança
        await _authorizationService.CheckCreatePermissionAsync();

        // 📋 Permissões de campo
        var allowedFields = await _authorizationService.GetAllowedFieldsAsync("create");

        // 💾 Persistência no banco
        return await Repository.InsertAsync(entity, autoSave: true);
    }
}
```

---

## 🔧 **Arquitetura Brilhante**

### **Vantagens Principais:**

#### 1. **Zero Configuration** 🚀
- Funciona imediatamente para qualquer entidade
- Não precisa criar endpoints manualmente
- Auto-descoberta de services

#### 2. **Extensível** 🛠️
- Adicione regras específicas quando necessário
- Herde do service genérico e sobrescreva métodos
- Mantenha funcionalidade padrão intacta

#### 3. **Odoo Compatible** 🔄
- Mesma estrutura de URLs do Odoo
- Suporte a JSON-RPC
- Compatibilidade com domínio filters

#### 4. **Enterprise Ready** 🏢
- Autorização integrada
- Auditoria automática
- Multi-tenancy
- Field-level permissions

---

## 🏗️ **O Segredo da Implementação**

### **ModelTypeRegistry - Coração do Sistema**
```csharp
public class ModelTypeRegistry
{
    private readonly Dictionary<string, Type> _entityType = new();
    private readonly Dictionary<string, Type> _serviceInterface = new();

    public void RegisterServiceTypes(IEnumerable<Assembly> assemblies)
    {
        // 🔍 Busca por interfaces de service
        var appServiceInterfaceTypes = assemblies
            .SelectMany(a => a.GetTypes())
            .Where(type => type.IsInterface &&
                          typeof(IApplicationService).IsAssignableFrom(type) &&
                          type.Name.EndsWith("AppService"));

        foreach (var interfaceType in appServiceInterfaceTypes)
        {
            // 🏗️ Busca implementação concreta
            var implementationType = assemblies
                .SelectMany(a => a.GetTypes())
                .FirstOrDefault(t => t.IsClass && !t.IsAbstract &&
                                    interfaceType.IsAssignableFrom(t));

            if (implementationType != null)
            {
                // 🏷️ Pega o Model Attribute
                var modelAttr = implementationType.GetCustomAttribute<ModelAttribute>();
                if (modelAttr == null) continue;

                // 🎯 Extrai TEntity da herança
                Type entityType = FindEntityTypeFromGenericBase(implementationType);

                if (entityType != null)
                {
                    // 📝 Registra mapeamento
                    _serviceInterface[modelAttr.Name] = interfaceType;
                    _serviceInterface[entityType.Name] = interfaceType;
                }
            }
        }
    }
}
```

### **Fluxo de Resolução**
```csharp
private object GetGenericService(string modelName)
{
    // 📋 1. Tipo da entidade
    var entityType = _modelTypeRegistry.GetType(modelName);

    // 🔍 2. Interface do service
    var serviceType = _modelTypeRegistry.GetServiceInterfaceType(modelName);

    // 🎯 3. Fallback para genérico
    if (serviceType == null) {
        serviceType = typeof(IGenericApplicationService<>).MakeGenericType(entityType);
    }

    // 💉 4. Injeção de dependência
    return _serviceProvider.GetService(serviceType);
}
```

---

## 🚀 **Exemplos Práticos**

### **Exemplo 1: Contato Simples**
```http
POST /api/v1/generic/ResPartner/create
{
  "entity": {
    "name": "João Silva",
    "email": "joao@exemplo.com"
  },
  "fields": ["name", "email"]
}
```

**Fluxo:**
1. `GenericModelController.CreateAsync("ResPartner", ...)`
2. `GenericModelService.GetGenericService("ResPartner")` → `ResPartnerAppService`
3. `ResPartnerAppService.CreateAsync()` → Validações → `base.CreateAsync()`
4. `GenericApplicationService<ResPartner>.CreateAsync()` → Database

### **Exemplo 2: Fatura com Lógica Complexa**
```http
POST /api/v1/generic/AccountMove/create
{
  "entity": {
    "partner_id": "uuid-do-cliente",
    "invoice_date": "2024-01-15",
    "invoice_line_ids": [...]
  }
}
```

**Fluxo:**
1. `GenericModelController.CreateAsync("AccountMove", ...)`
2. `GenericModelService.GetGenericService("AccountMove")` → `AccountMoveAppService`
3. `AccountMoveAppService.CreateAsync()` → **Lógica complexa de contabilidade**
   - Calcula impostos
   - Valida dados fiscais
   - Gera sequência numérica
   - Verifica permissões de contabilidade
4. `base.CreateAsync()` → Database

---

## 🎯 **Como Adicionar Novas Regras de Negócio**

### **Passo 1: Criar Service Específico**
```csharp
[Model("meu.modelo")]
public class MeuModeloAppService : GenericApplicationService<MeuModelo>
{
    public override async Task<MeuModelo> CreateAsync(MeuModelo entity, List<string> fields)
    {
        // 🏢 SUAS REGRAS DE NEGÓCIO AQUI
        await ValidarRegrasEspecificas(entity);
        await IntegrarComOutrosSistemas(entity);

        return await base.CreateAsync(entity, fields);
    }
}
```

### **Passo 2: Registrar (Automaticamente)**
O sistema vai descobrir automaticamente seu service através do `[Model("meu.modelo")]` attribute!

### **Passo 3: Usar API**
```http
POST /api/v1/generic/meu.modelo/create
{
  "entity": { /* seus dados */ }
}
```

---

## 📊 **Resumo da Arquitetura**

```
🌐 API Genérica (HTTP)
    ↓
🎛️ GenericModelController (Roteamento)
    ↓
🔍 GenericModelService (Resolução)
    ↓
🗺️ ModelTypeRegistry (Mapeamento)
    ↓
💉 ServiceProvider (DI)
    ↓
🎯 Service Específico (Business Logic) ← **AQUI ESTÃO AS REGRAS!**
    ↓
🔧 Generic Base (CRUD Padrão)
    ↓
💾 Repository (Database)
    ↓
📤 JSON Response
```

## 🏆 **Conclusão**

O Bamboo ERP implementa uma das arquiteturas mais elegantes de **generic API + specific business logic** que existem:

- **Funciona imediatamente** para 1000+ entidades sem configuração
- **Permite customização** profunda quando necessário
- **Mantém compatibilidade** total com Odoo
- **É enterprise-ready** com todas as features corporativas

O sistema permite que desenvolvedores foquem **apenas nas regras de negócio**, enquanto a infraestrutura de API, roteamento, autorização e persistência funciona automaticamente!

O arquivo `GoogleCalendarSyncAppService.cs` que você abriu é um exemplo perfeito - ele herda do genérico e adiciona **lógica específica de sincronização com Google Calendar** 🗓️, mostrando como o sistema suporta tanto casos simples quanto complexos.