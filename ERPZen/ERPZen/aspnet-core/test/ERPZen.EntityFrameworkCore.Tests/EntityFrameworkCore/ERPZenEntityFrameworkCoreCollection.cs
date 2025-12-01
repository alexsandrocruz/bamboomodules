using Xunit;

namespace ERPZen.EntityFrameworkCore;

[CollectionDefinition(ERPZenTestConsts.CollectionDefinitionName)]
public class ERPZenEntityFrameworkCoreCollection : ICollectionFixture<ERPZenEntityFrameworkCoreFixture>
{

}
