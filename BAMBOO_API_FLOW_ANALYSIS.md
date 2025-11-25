# Fluxo Completo da API Genérica - Bamboo ERP

## Visão Geral

Você fez uma excelente pergunta! Quando chamamos a API genérica (ex: criar um contato), existe um fluxo sofisticado que mapeia a requisição genérica para o service específico de negócio. Vou detalhar todo o processo:

## 🔍 Fluxo Completo: `POST /api/v1/generic/ResPartner/create`

### Passo 1: **Requisição HTTP**
```http
POST /api/v1/generic/ResPartner/create
Content-Type: application/json

{
  "entity": {
    "name": "João Silva",
    "email": "joao@exemplo.com",
    "phone": "+55 11 99999-9999"
  },
  "fields": ["name", "email", "phone"]
}
```

### Passo 2: **GenericModelController**
**Arquivo**: `/services/core/src/Bamboo.Core.HttpApi/GenericModelController.cs`

```csharp
[HttpPost("{modelName}/create")]
public async Task<JsonElement> CreateAsync(string modelName, [FromBody] CreateRequestDto request)
{
    // modelName = "ResPartner"
    var result = await _genericModelService.CreateAsync(modelName, request.Entity, request.Fields);
    return JsonSerializer.SerializeToElement(result, _jsonSerializerOptions);
}
```

**O que acontece:**
- ✅ **Roteamento**: `[Route("api/v1/generic")]` + `{modelName}/create`
- ✅ **Extração**: `modelName = "ResPartner"` da URL
- ✅ **Delegação**: Chama `_genericModelService.CreateAsync()`

### Passo 3: **GenericModelService**
**Arquivo**: `/services/core/src/Bamboo.Core.Application/Commons/GenericModelService.cs`

```csharp
public async Task<JsonElement> CreateAsync(string modelName, object entity, List<string> fields)
{
    // 🎯 **RESOLUÇÃO DO SERVICE ESPECÍFICO**
    var service = GetGenericService(modelName);

    // 🔄 **DESERIALIZAÇÃO TIPO SEGURA**
    var entityType = _modelTypeRegistry.GetType(modelName);  // ResPartner type
    var jsonElement = JsonSerializer.SerializeToElement(entity);
    var typedEntity = JsonSerializer.Deserialize(jsonElement, entityType);  // ResPartner object

    // 🚀 **CHAMADA AO SERVICE DE NEGÓCIO**
    var result = await CallServiceMethodAsync<object>(service, "CreateAsync", typedEntity, fields);
    return JsonSerializer.SerializeToElement(result, _jsonSerializerOptions);
}
```

### Passo 4: **GetGenericService() - O Mágico!** 🎩

```csharp
private object GetGenericService(string modelName)
{
    // 📋 **1. TIPO DA ENTIDADE**
    var entityType = _modelTypeRegistry.GetType(modelName);
    // Result: entityType = typeof(ResPartner)

    // 🔍 **2. INTERFACE DO SERVICE**
    var serviceType = _modelTypeRegistry.GetServiceInterfaceType(modelName);
    // Result: serviceType = typeof(IResPartnerAppService)

    // 🎯 **3. SE NÃO ENCONTRAR, USA GENÉRICO**
    if (serviceType == null) {
        serviceType = typeof(IGenericApplicationService<>).MakeGenericType(entityType);
        // Result: typeof(IGenericApplicationService<ResPartner>)
    }

    // 💉 **4. INJEÇÃO DE DEPENDÊNCIA**
    return _serviceProvider.GetService(serviceType)
        ?? throw new UserFriendlyException($"Service for {modelName} not found");
}
```

### Passo 5: **ModelTypeRegistry - O Mapa do Tesouro** 🗺️

**Arquivo**: `/services/core/src/Bamboo.Core.Application/Commons/ModelTypeRegistry.cs`

Este é o **coração do sistema de resolução**!

#### **Como Funciona o Registro:**

1. **No Startup** (`CoreApplicationModule.cs`):
```csharp
context.Services.AddSingleton<IModelTypeRegistry>(provider =>
{
    var registry = new ModelTypeRegistry();
    registry.RegisterTypes(typeof(CoreDomainSharedModule).Assembly);  // Entidades
    registry.RegisterServiceTypes([typeof(CoreApplicationModule).Assembly]);  // Services
    return registry;
});
```

2. **Registro de Services**:
```csharp
public void RegisterServiceTypes(IEnumerable<Assembly> assemblies)
{
    // 🔍 **BUSCA POR INTERFACES DE SERVICE**
    var appServiceInterfaceTypes = assemblies
        .SelectMany(a => a.GetTypes())
        .Where(type => type.IsInterface &&
                      typeof(IApplicationService).IsAssignableFrom(type) &&
                      type.Name.EndsWith("AppService"));

    foreach (var interfaceType in appServiceInterfaceTypes)
    {
        // 🏗️ **BUSCA IMPLEMENTAÇÃO CONCRETA**
        var implementationType = assemblies
            .SelectMany(a => a.GetTypes())
            .FirstOrDefault(t => t.IsClass && !t.IsAbstract &&
                                interfaceType.IsAssignableFrom(t));

        if (implementationType != null)
        {
            // 🏷️ **PEGA O MODEL ATTRIBUTE**
            var modelAttr = implementationType.GetCustomAttribute<ModelAttribute>();
            if (modelAttr == null) continue;

            // 🎯 **EXTRAI TEntity DA HERANÇA**
            Type entityType = FindEntityTypeFromGenericBase(implementationType);

            if (entityType != null)
            {
                // 📝 **REGISTRA MAPEAMENTO**
                _serviceInterface[modelAttr.Name] = interfaceType;  // "res.partner" → IResPartnerAppService
                _serviceInterface[entityType.Name] = interfaceType; // "ResPartner" → IResPartnerAppService
            }
        }
    }
}
```

3. **Busca do Tipo da Entidade**:
```csharp
public Type GetType(string modelName)
{
    // Tenta registrar o nome do modelo Odoo primeiro
    if (_entityType.TryGetValue(modelName, out var entity))
        return entity;

    // Tenta o nome da classe C#
    return _entityType.FirstOrDefault(x => x.Key.Equals(modelName, StringComparison.OrdinalIgnoreCase)).Value;
}
```

### Passo 6: **ResPartnerAppService - Regras de Negócio!** 🎯

**Arquivo**: `/services/core/src/Bamboo.Core.Application/Services/Resources/ResPartnerAppService.cs`

```csharp
[Model("res.partner")]  // ← **MAPEAMENTO ODOO**
public class ResPartnerAppService : GenericApplicationService<ResPartner>, IResPartnerAppService
{
    public ResPartnerAppService(
        IRepository<ResPartner, Guid> repository,
        // ... outras dependências
    ) : base(repository, /* ... */) { }

    // 🔥 **AQUI ESTÃO AS REGRAS DE NEGÓCIO!**

    // Sobrescreve se precisar de lógica customizada
    public override async Task<ResPartner> CreateAsync(ResPartner entity, List<string> fields)
    {
        // 🏢 **VALIDAÇÕES DE NEGÓCIO**
        if (string.IsNullOrEmpty(entity.Name))
            throw new UserFriendlyException("Nome do contato é obrigatório");

        // 📧 **VALIDAÇÃO DE EMAIL ÚNICO**
        if (!string.IsNullOrEmpty(entity.Email) && await EmailJaExiste(entity.Email))
            throw new UserFriendlyException("Email já cadastrado");

        // 🏭 **LÓGICA ESPECÍFICA**
        if (entity.IsCompany)
            entity.CompanyType = "company";
        else
            entity.CompanyType = "person";

        // 💾 **CHAMA BASE (CRUD GENÉRICO)**
        return await base.CreateAsync(entity, fields);
    }

    // 🎭 **ACTIONS CUSTOMIZADAS**
    public async Task ButtonSincronizarCrmAsync(Guid id)
    {
        var partner = await Repository.GetAsync(id);
        // Lógica de sincronização com CRM...
    }
}
```

### Passo 7: **GenericApplicationService - Base CRUD**

**Arquivo**: `/services/core/src/Bamboo.Core.Application/Commons/GenericApplicationService.cs`

```csharp
public class GenericApplicationService<TEntity> : ApplicationService, IGenericApplicationService<TEntity>
    where TEntity : class, IEntity<Guid>
{
    public virtual async Task<TEntity> CreateAsync(TEntity entity, List<string> fields)
    {
        // 🔐 **AUTORIZAÇÃO**
        await _authorizationService.CheckCreatePermissionAsync();

        // 📋 **PERMISSÕES DE CAMPO**
        var allowedFields = await _authorizationService.GetAllowedFieldsAsync("create");
        if (!allowedFields.Contains("*"))
        {
            // Remove campos não permitidos
            entity = FilterFields(entity, allowedFields);
        }

        // 💾 **PERSISTÊNCIA**
        return await Repository.InsertAsync(entity, autoSave: true);
    }

    // 📖 **READ COM PERMISSÕES**
    public virtual async Task<List<object>> ReadAsync(List<Guid> ids, List<string> fields)
    {
        await _authorizationService.CheckReadPermissionAsync();

        var query = await Repository.GetQueryableAsync();
        var entities = await AsyncExecuter.ToListAsync(query.Where(e => ids.Contains(e.Id)));

        // 🔍 **FILTRA CAMPOS PERMITIDOS**
        var allowedFields = await _authorizationService.GetAllowedFieldsAsync("read");
        return entities.Select(e => FilterFields(e, allowedFields, fields)).ToList();
    }
}
```

---

## 🎯 **Exemplo Completo - Criando um Contato**

### **Request:**
```http
POST /api/v1/generic/ResPartner/create
{
  "entity": {
    "name": "Maria Santos",
    "email": "maria@empresa.com",
    "is_company": false
  },
  "fields": ["name", "email", "is_company", "company_type"]
}
```

### **Fluxo Executado:**

1. **GenericModelController.CreateAsync("ResPartner", entity, fields)**
   - ✅ Recebe requisição HTTP

2. **GenericModelService.CreateAsync("ResPartner", entity, fields)**
   - ✅ `GetGenericService("ResPartner")` → `ResPartnerAppService`

3. **ModelTypeRegistry.GetServiceInterfaceType("ResPartner")**
   - ✅ Retorna `typeof(IResPartnerAppService)`

4. **ServiceProvider.GetService<IResPartnerAppService>()**
   - ✅ Retorna instância de `ResPartnerAppService`

5. **CallServiceMethodAsync<ResPartner>(service, "CreateAsync", resPartner, fields)**
   - ✅ Usa reflection para chamar `ResPartnerAppService.CreateAsync(resPartner, fields)`

6. **ResPartnerAppService.CreateAsync(resPartner, fields)**
   - ✅ **Validação de negócio**: Nome obrigatório
   - ✅ **Validação**: Email único
   - ✅ **Lógica**: Define `company_type = "person"`
   - ✅ Chama `base.CreateAsync()`

7. **GenericApplicationService<ResPartner>.CreateAsync(resPartner, fields)**
   - ✅ **Autorização**: Verifica permissão de create
   - ✅ **Filtro de campos**: Aplica regras de acesso
   - ✅ **Persistência**: `Repository.InsertAsync(resPartner)`

8. **Retorno:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Maria Santos",
  "email": "maria@empresa.com",
  "is_company": false,
  "company_type": "person"
}
```

---

## 🔧 **Pontos Chave da Arquitetura**

### **1. Descoberta Automática**
- **Reflection** para encontrar services que herdam de `GenericApplicationService<T>`
- **ModelAttribute** para mapear nomes Odoo → C#
- **Registro automático** no startup

### **2. Herança vs Composição**
```csharp
// Service específico herda do genérico
ResPartnerAppService : GenericApplicationService<ResPartner>

// Pode sobrescrever métodos para lógica customizada
public override async Task<ResPartner> CreateAsync(...)
{
    // Lógica específica
    return await base.CreateAsync(...);  // CRUD genérico
}
```

### **3. Flexibilidade**
- **Se não existe service específico** → usa `GenericApplicationService<T>` puro
- **Se existe service específico** → usa lógica customizada
- **Fallback automático** mantém sistema funcionando

### **4. Performance**
- **Service resolution** via cache no `ModelTypeRegistry`
- **Dependency Injection** para gerenciar instâncias
- **Async operations** para performance

---

## 🚀 **Vantagens Desta Abordagem**

### **✅ Simplicidade para Desenvolvedores**
```http
// Qualquer entidade funciona sem código novo!
POST /api/v1/generic/{qualquer_entidade}/create
POST /api/v1/generic/{qualquer_entidade}/update
GET  /api/v1/generic/{qualquer_entidade}/search
```

### **✅ Extensibilidade**
```csharp
// Adicionar regras específicas é fácil
public class MinhaEntidadeAppService : GenericApplicationService<MinhaEntidade>
{
    public override async Task<MinhaEntidade> CreateAsync(...)
    {
        // Minha lógica de negócio aqui
        return await base.CreateAsync(...);
    }
}
```

### **✅ Odoo Compatibility**
- **Mesma estrutura de URLs** que Odoo
- **JSON-RPC support** também implementado
- **Domain filters** compatíveis

### **✅ Enterprise Features**
- **Authorization integrada**
- **Field-level permissions**
- **Auditing automático**
- **Multi-tenancy**

---

## 📊 **Resumo do Fluxo**

```
🌐 HTTP Request
    ↓
🎛️ GenericModelController (Routing)
    ↓
🔍 GenericModelService (Resolution)
    ↓
🗺️ ModelTypeRegistry (Mapping)
    ↓
💉 ServiceProvider (DI)
    ↓
🎯 ResPartnerAppService (Business Logic)
    ↓
🔧 GenericApplicationService (CRUD)
    ↓
💾 Repository (Database)
    ↓
📤 JSON Response
```

Esta arquitetura é **brilhante** porque:
1. **Funciona imediatamente** para qualquer entidade ( CRUD genérico )
2. **Permite customização** quando necessário (regras de negócio)
3. **Mantém compatibilidade** com Odoo
4. **É enterprise-ready** (segurança, auditoria, multi-tenancy)

O sistema inteiro é **auto-descobrível** e **extensível** - uma verdadeira obra de engenharia de software! 🏗️