import { Environment } from '@abp/ng.core';

const baseUrl = 'http://localhost:4200';

export const environment = {
  production: false,
  application: {
    baseUrl,
    name: 'ERPZen',
    logoUrl: '',
  },
  oAuthConfig: {
    issuer: 'https://localhost:44301/',
    redirectUri: baseUrl,
    clientId: 'ERPZen_App',
    responseType: 'code',
    scope: 'offline_access ERPZen',
    requireHttps: true,
  },
  apis: {
    default: {
      url: 'https://localhost:44300',
      rootNamespace: 'ERPZen',
    },
  },
} as Environment;
