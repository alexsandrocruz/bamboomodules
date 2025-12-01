using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using ERPZen.Data;
using Volo.Abp.DependencyInjection;

namespace ERPZen.EntityFrameworkCore;

public class EntityFrameworkCoreERPZenDbSchemaMigrator
    : IERPZenDbSchemaMigrator, ITransientDependency
{
    private readonly IServiceProvider _serviceProvider;

    public EntityFrameworkCoreERPZenDbSchemaMigrator(
        IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public async Task MigrateAsync()
    {
        /* We intentionally resolve the ERPZenDbContext
         * from IServiceProvider (instead of directly injecting it)
         * to properly get the connection string of the current tenant in the
         * current scope.
         */

        await _serviceProvider
            .GetRequiredService<ERPZenDbContext>()
            .Database
            .MigrateAsync();
    }
}
