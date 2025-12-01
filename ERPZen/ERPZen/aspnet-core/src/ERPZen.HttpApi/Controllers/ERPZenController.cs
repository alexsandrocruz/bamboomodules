using ERPZen.Localization;
using Volo.Abp.AspNetCore.Mvc;

namespace ERPZen.Controllers;

/* Inherit your controllers from this class.
 */
public abstract class ERPZenController : AbpControllerBase
{
    protected ERPZenController()
    {
        LocalizationResource = typeof(ERPZenResource);
    }
}
