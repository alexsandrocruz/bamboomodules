using ERPZen.Samples;
using Xunit;

namespace ERPZen.EntityFrameworkCore.Applications;

[Collection(ERPZenTestConsts.CollectionDefinitionName)]
public class EfCoreSampleAppServiceTests : SampleAppServiceTests<ERPZenEntityFrameworkCoreTestModule>
{

}
