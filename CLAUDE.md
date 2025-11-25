# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bamboo ERP is a C# port of Odoo ERP built on the ABP Framework v8.3.4 with microservices architecture. It converts 500+ Odoo entities from integer IDs to UUID (PostgreSQL uuid type) and implements a generic API system compatible with Odoo-style calls.

## Architecture

### Microservices Structure
- **Admin Service** (`/services/admin/`): Authentication, authorization, and administrative functions using OpenIddict OAuth2/OIDC
- **Core Service** (`/services/core/`): Business logic and domain operations with 500+ converted Odoo entities
- **Shared Components** (`/shared/`): Common libraries, utilities, and cross-service communication
- **Applications** (`/apps/`): Web UI implementations (MVC, Blazor)

### Key Technologies
- **.NET 8.0** with ABP Framework v8.3.4
- **PostgreSQL 16+** with TimescaleDB (custom uuidv7() function)
- **Redis** for caching
- **MinIO** for object storage
- **Docker Compose** for orchestration
- **Entity Framework Core** with custom UUID migrations

## Development Commands

### Building the Solution
```bash
# Build all services for production deployment
./scripts/build.sh

# Manual build commands
dotnet publish --sc --os linux -f net8.0 -o bin/Bamboo.Admin services/admin/Bamboo.Admin/Bamboo.Admin.sln
dotnet publish --sc --os linux -f net8.0 -o bin/Bamboo.Core services/core/Bamboo.Core.sln
```

### Database Operations
```bash
# Create databases with uuidv7() function
./scripts/db-create-admin-db.sh
./scripts/db-create-core-db.sh

# Run migrations
./scripts/db-migrate-admin.sh
./scripts/db-migrate-core.sh

# Initialize databases (run after Docker containers start)
docker exec -it bamboo-admin dotnet /app/Bamboo.Admin.DbMigrator.dll
docker exec -it bamboo-core dotnet /app/Bamboo.Core.DbMigrator.dll

# Migrate data from Odoo 18
./scripts/pgloader/run-data-odoo18.sh
```

### Entity Framework Migrations
```bash
# Admin service migrations
cd services/admin && abp create-migration-and-run-migrator Bamboo.Admin.EntityFrameworkCore

# Core service migrations (from project root)
dotnet ef migrations add Initial --startup-project services/core/host/Bamboo.Core.HttpApi.Host/Bamboo.Core.HttpApi.Host.csproj --project services/core/src/Bamboo.Core.EntityFrameworkCore/Bamboo.Core.EntityFrameworkCore.csproj --context CoreDbContext
dotnet ef database update --startup-project services/core/host/Bamboo.Core.HttpApi.Host/Bamboo.Core.HttpApi.Host.csproj --project services/core/src/Bamboo.Core.EntityFrameworkCore/Bamboo.Core.EntityFrameworkCore.csproj --context CoreDbContext
```

### Running Services
```bash
# Docker Compose (recommended)
docker compose up -d

# Visual Studio Development
1. Open services/admin/Bamboo.Admin.sln - run Bamboo.Admin.HttpApi.Host
2. Open services/core/Bamboo.Core.sln - run Bamboo.Core.HttpApi.Host
3. Open apps/Bamboo.Web.MVC.sln - run web UI

# Individual services
dotnet run --project services/admin/host/Bamboo.Admin.HttpApi.Host/Bamboo.Admin.HttpApi.Host.csproj
dotnet run --project services/core/host/Bamboo.Core.HttpApi.Host/Bamboo.Core.HttpApi.Host.csproj
```

### Testing
```bash
# Admin service tests
dotnet test services/admin/src/Bamboo.Admin.Application.Tests/
dotnet test services/admin/src/Bamboo.Admin.Domain.Tests/
dotnet test services/admin/src/Bamboo.Admin.EntityFrameworkCore.Tests/

# Core service tests
dotnet test services/core/src/Bamboo.Core.Application.Tests/
dotnet test services/core/src/Bamboo.Core.Domain.Tests/
dotnet test services/core/src/Bamboo.Core.EntityFrameworkCore.Tests/
```

## Key Implementation Details

### Entity Model System
- **Location**: `/shared/core/Bamboo.Core.Domain.Shared/Models/`
- **Pattern**: Uses same models for entities and DTOs
- **Inheritance**: All entities inherit from `FullAuditedEntity<Guid>` and implement `IMultiTenant`
- **Field Mappings**:
  - `company_id` → `TenantId`
  - `create_uid` → `CreatorId`
  - `write_uid` → `LastModifierId`
  - `create_date` → `CreationTime`
  - `write_date` → `LastModificationTime`

### Generic API System
- **Purpose**: Odoo-style JSON-RPC and REST API compatibility
- **Implementation**: Generic controllers that handle CRUD operations for all entities
- **Features**: Search, read, create, write, unlink operations matching Odoo API patterns

### UUID Migration System
- **Function**: Custom PostgreSQL `uuidv7()` function for sequential UUIDs
- **Migration**: Automated scripts to convert Odoo int IDs to UUIDs
- **Foreign Keys**: All foreign keys automatically converted to maintain relationships

### Multi-tenancy
- **Implementation**: Built on ABP Framework multi-tenancy
- **Mapping**: Odoo's `company_id` maps to ABP's `TenantId`
- **Isolation**: Complete data isolation per tenant

## Configuration

### Environment Variables (Docker)
- `POSTGRES_HOST`: PostgreSQL server hostname
- `POSTGRES_APP_USER`: Database username (default: bamboo)
- `POSTGRES_APP_PASSWORD`: Database password
- `POSTGRES_ADMIN_DB`: Admin database name (default: bamboo_admin)
- `POSTGRES_CORE_DB`: Core database name (default: bamboo_core)
- `AUTHORITY_SERVER_URL`: Auth server URL for cross-service authentication

### Configuration Files
- `/conf/appsettings.json`: Base application configuration
- `/conf/appsettings.admin.secrets.json`: Admin service secrets
- `/conf/appsettings.core.secrets.json`: Core service secrets
- `/conf/nginx.bamboo.conf`: Nginx reverse proxy configuration

### Docker Ports
- **7109**: Nginx reverse proxy (main entry point)
- **7103**: Auth server
- **7104**: Admin API service
- **7105**: Core API service
- **5433**: PostgreSQL
- **7179**: Redis
- **7101/7102**: MinIO API/Console

## Development Workflow

### Adding New Entities
1. Define entity in `/shared/core/Bamboo.Core.Domain.Shared/Models/`
2. Inherit from `FullAuditedEntity<Guid>` and implement `IMultiTenant`
3. Add required ABP attributes (`[Module]`, `[Model]`, `[RelationField]`)
4. Generate and run EF Core migration
5. Generic API automatically handles CRUD operations

### Modifying Existing Entities
- Never remove columns that exist in Odoo (breaks data migration)
- Add new columns with nullable properties for backwards compatibility
- Update migrations carefully to avoid breaking existing data

### Data Migration from Odoo
- Use pgloader with custom configuration in `/scripts/pgloader/`
- Follow migration guide in `/docs/migrate-odoo-uuid.md`
- Ensure source Odoo database is multi-company and has NULL values cleaned

### Testing Strategy
- Unit tests for domain logic in each service's `.Tests` projects
- Integration tests for Entity Framework operations
- API client tests for service communication
- Use `Bamboo.*.TestBase` projects for common test setup