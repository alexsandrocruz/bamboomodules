using Volo.Abp.Modularity;

namespace ERPZen;

public abstract class ERPZenApplicationTestBase<TStartupModule> : ERPZenTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
