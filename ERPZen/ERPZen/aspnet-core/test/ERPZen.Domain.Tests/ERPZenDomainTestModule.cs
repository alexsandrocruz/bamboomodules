using Volo.Abp.Modularity;

namespace ERPZen;

[DependsOn(
    typeof(ERPZenDomainModule),
    typeof(ERPZenTestBaseModule)
)]
public class ERPZenDomainTestModule : AbpModule
{

}
