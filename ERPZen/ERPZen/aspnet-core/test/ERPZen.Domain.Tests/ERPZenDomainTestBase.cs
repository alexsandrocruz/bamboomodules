using Volo.Abp.Modularity;

namespace ERPZen;

/* Inherit from this class for your domain layer tests. */
public abstract class ERPZenDomainTestBase<TStartupModule> : ERPZenTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
