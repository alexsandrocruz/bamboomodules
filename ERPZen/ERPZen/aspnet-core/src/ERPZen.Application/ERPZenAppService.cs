using System;
using System.Collections.Generic;
using System.Text;
using ERPZen.Localization;
using Volo.Abp.Application.Services;

namespace ERPZen;

/* Inherit your application services from this class.
 */
public abstract class ERPZenAppService : ApplicationService
{
    protected ERPZenAppService()
    {
        LocalizationResource = typeof(ERPZenResource);
    }
}
