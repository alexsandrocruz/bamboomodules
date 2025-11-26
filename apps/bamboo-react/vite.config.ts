import react from '@vitejs/plugin-react';
import { defineConfig, loadEnv } from 'vite';

const normalizeUrl = (value?: string, fallback?: string) => {
  const url = (value ?? fallback ?? '').trim();
  if (!url) return '';
  return url.endsWith('/') ? url.slice(0, -1) : url;
};

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');

  const devPort = Number(env.VITE_DEV_SERVER_PORT) || 5173;
  const apiProxyTarget = normalizeUrl(env.VITE_API_PROXY_TARGET || env.VITE_API_BASE_URL, 'http://localhost:7105');
  const authProxyTarget = normalizeUrl(env.VITE_AUTH_PROXY_TARGET || env.VITE_AUTH_BASE_URL, 'http://localhost:7103');
  const usePolling = env.VITE_USE_POLLING === 'true';

  return {
    plugins: [react()],
    server: {
      host: true,
      port: devPort,
      strictPort: true,
      watch: usePolling ? { usePolling: true } : undefined,
      proxy: {
        '/api': {
          target: apiProxyTarget,
          changeOrigin: true,
          secure: false,
        },
        '/connect': {
          target: authProxyTarget,
          changeOrigin: true,
          secure: false,
        },
        '/Abp': {
          target: apiProxyTarget,
          changeOrigin: true,
          secure: false,
        },
      },
    },
    preview: {
      host: true,
      port: devPort,
    },
    test: {
      passWithNoTests: true,
      globals: true,
      environment: 'jsdom',
    },
  };
});
