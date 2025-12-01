using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.AuditLogging.EntityFrameworkCore;
using Volo.Abp.BackgroundJobs.EntityFrameworkCore;
using Volo.Abp.FeatureManagement.EntityFrameworkCore;
using Volo.Abp.PermissionManagement.EntityFrameworkCore;
using Volo.Abp.SettingManagement.EntityFrameworkCore;
using Volo.Abp.TenantManagement.EntityFrameworkCore;
using Volo.Abp.AuditLogging;
using Volo.Abp.BackgroundJobs;
using Volo.Abp.FeatureManagement;
using Volo.Abp.PermissionManagement;
using Volo.Abp.SettingManagement;
using Volo.Abp.TenantManagement;

namespace Bamboo.Core.EntityFrameworkCore;

[ConnectionStringName(CoreDbProperties.ConnectionStringName)]
public partial class CoreDbContext :
    AbpDbContext<CoreDbContext>,
    ICoreDbContext,
    IPermissionManagementDbContext,
    ISettingManagementDbContext,
    ITenantManagementDbContext
{
    /* Add DbSet for each Aggregate Root here. Example:
     * public DbSet<Question> Questions { get; set; }
     */

    #region Entities from the modules

    // Background Jobs
    public DbSet<BackgroundJobRecord> BackgroundJobs { get; set; }

    // Feature Management
    public DbSet<FeatureValue> FeatureValues { get; set; }

    // Permission Management
    public DbSet<PermissionGroupDefinitionRecord> PermissionGroups { get; set; }
    public DbSet<PermissionDefinitionRecord> Permissions { get; set; }
    public DbSet<PermissionGrant> PermissionGrants { get; set; }

    // Setting Management
    public DbSet<Setting> Settings { get; set; }
    public DbSet<SettingDefinitionRecord> SettingDefinitionRecords { get; set; }

    // Tenant Management
    public DbSet<Tenant> Tenants { get; set; }
    public DbSet<TenantConnectionString> TenantConnectionStrings { get; set; }

    #endregion

    public CoreDbContext(DbContextOptions<CoreDbContext> options)
        : base(options)
    {
        ChangeTracker.LazyLoadingEnabled = false;
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        //optionsBuilder.LogTo(Console.WriteLine, LogLevel.Debug);
        //optionsBuilder.EnableSensitiveDataLogging().EnableDetailedErrors();
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        builder.UseIdentityColumns();
        base.OnModelCreating(builder);

        builder.ConfigureCore();
        //builder.ConfigureCoreFluentExt();
        builder.ApplyAllConfigurations();
        builder.SnakeCase();

        /* Configure ABP Framework Modules */

        builder.ConfigurePermissionManagement();
        builder.ConfigureSettingManagement();
        builder.ConfigureBackgroundJobs();
        builder.ConfigureFeatureManagement();
        builder.ConfigureTenantManagement();
    }
}
