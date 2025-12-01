using Volo.Abp.Settings;

namespace ERPZen.Settings;

public class ERPZenSettingDefinitionProvider : SettingDefinitionProvider
{
    public override void Define(ISettingDefinitionContext context)
    {
        //Define your own settings here. Example:
        //context.Add(new SettingDefinition(ERPZenSettings.MySetting1));
    }
}
