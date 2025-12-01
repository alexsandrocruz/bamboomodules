using Microsoft.Extensions.Localization;
using ERPZen.Localization;
using Volo.Abp.Ui.Branding;
using Volo.Abp.DependencyInjection;

namespace ERPZen;

[Dependency(ReplaceServices = true)]
public class ERPZenBrandingProvider : DefaultBrandingProvider
{
    private IStringLocalizer<ERPZenResource> _localizer;

    public ERPZenBrandingProvider(IStringLocalizer<ERPZenResource> localizer)
    {
        _localizer = localizer;
    }

    public override string AppName => _localizer["AppName"];
}
