using ERPZen.Samples;
using Xunit;

namespace ERPZen.EntityFrameworkCore.Domains;

[Collection(ERPZenTestConsts.CollectionDefinitionName)]
public class EfCoreSampleDomainTests : SampleDomainTests<ERPZenEntityFrameworkCoreTestModule>
{

}
