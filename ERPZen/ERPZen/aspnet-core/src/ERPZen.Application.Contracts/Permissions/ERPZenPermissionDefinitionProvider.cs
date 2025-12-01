using ERPZen.Localization;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;

namespace ERPZen.Permissions;

public class ERPZenPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var myGroup = context.AddGroup(ERPZenPermissions.GroupName);
        //Define your own permissions here. Example:
        //myGroup.AddPermission(ERPZenPermissions.MyPermission1, L("Permission:MyPermission1"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<ERPZenResource>(name);
    }
}
