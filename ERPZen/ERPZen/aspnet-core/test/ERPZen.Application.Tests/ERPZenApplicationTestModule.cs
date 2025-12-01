using Volo.Abp.Modularity;

namespace ERPZen;

[DependsOn(
    typeof(ERPZenApplicationModule),
    typeof(ERPZenDomainTestModule)
)]
public class ERPZenApplicationTestModule : AbpModule
{

}
