# Bamboo ERP - React Frontend

## 📋 Overview

Frontend React + TypeScript para o Bamboo ERP, construído com Vite, Syncfusion Components e integração com ABP Framework.

## 🏗️ Stack Tecnológico

- **Build Tool**: Vite 5.x
- **Framework**: React 18.x com TypeScript
- **UI Components**: Syncfusion Essential UI Kit
- **Styling**: TailwindCSS (planejado)
- **State Management**: Zustand (planejado)
- **HTTP Client**: Axios + TanStack Query (planejado)
- **Authentication**: ABP Framework Integration (planejado)
- **Code Quality**: ESLint + Prettier

## 🚀 Getting Started

### Prerequisites

- Node.js >= 18.x
- npm >= 9.x

### Installation & Environment

1. Copie `.env.example` para `.env.local` (ou use o `.env.development` já preenchido) e ajuste as URLs do backend conforme seu ambiente.
2. Instale as dependências e rode o dev server com hot reload + proxy para o backend ABP.

```bash
npm install
npm run dev       # hot reload + proxy /api e /connect
npm run build
npm run preview
npm run test
```

### Development URLs

- **Development**: http://localhost:5173
- **Core API**: http://localhost:7105
- **Admin API**: http://localhost:7104 (quando necessário)
- **Authentication**: http://localhost:7103 (Auth Server)

## 📁 Estrutura do Projeto

```
src/
├── components/           # React Components
│   ├── common/          # Generic reusable components
│   ├── syncfusion/      # Syncfusion component wrappers
│   ├── abp/            # ABP integration components
│   └── view-processor/ # Dynamic view rendering components
├── hooks/              # Custom React hooks
├── services/           # API and business logic services
│   ├── abp/           # ABP framework services
│   ├── auth/          # Authentication services
│   ├── view/          # View processor services
│   └── api/           # Generic API services
├── stores/             # State management (Zustand)
├── types/              # TypeScript type definitions
└── utils/              # Utility functions
```

## 🎯 Features

### **Phase 1: Foundation**
- [x] Project setup with Vite + React + TypeScript
- [x] ESLint + Prettier configuration
- [x] VSCode workspace setup
- [ ] ABP Framework integration
- [ ] Syncfusion components setup

### **Phase 2: Authentication**
- [ ] ABP OAuth2 integration
- [ ] Login/logout functionality
- [ ] User session management
- [ ] Permission system

### **Phase 3: View Processor**
- [ ] XML parser for Odoo views
- [ ] Component mapping engine
- [ ] Dynamic view renderer
- [ ] Tree/List views
- [ ] Form views

### **Phase 4: Advanced Features**
- [ ] Kanban boards
- [ ] Calendar views
- [ ] Charts and analytics
- [ ] Dashboard system

## 🔧 Configuration

### Environment Variables

Use `.env.example` como base. Há presets prontos em `.env.development` (localhost) e `.env.docker` (docker compose).

```env
# Backend (deixe vazio para usar o host atual + proxy)
VITE_API_BASE_URL=
VITE_AUTH_BASE_URL=

# Dev server
VITE_DEV_SERVER_PORT=5173
VITE_USE_POLLING=false

# Proxy targets (dev)
VITE_API_PROXY_TARGET=http://localhost:7105
VITE_AUTH_PROXY_TARGET=http://localhost:7103
```

- Para rodar dentro do Docker compose, carregue `.env.docker` ou defina `VITE_API_PROXY_TARGET=http://app-core:8080` e `VITE_AUTH_PROXY_TARGET=http://auth-server:8080`.
- Em produção, defina `VITE_API_BASE_URL`/`VITE_AUTH_BASE_URL` se o frontend estiver em domínio separado; caso contrário mantenha vazio e use o proxy/reverse-proxy padrão.

### Syncfusion Configuration

```typescript
// src/config/syncfusion.ts
import { registerLicense } from '@syncfusion/ej2-base';

// Register Syncfusion license (if applicable)
registerLicense('YOUR_LICENSE_KEY');

// Global configuration
export const syncfusionConfig = {
  theme: 'material',
  locale: 'pt-BR',
  culture: 'pt-BR'
};
```

## 📝 Development Guidelines

### Code Style

O projeto usa ESLint + Prettier com configurações automáticas:

```bash
# Check linting
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format
```

### Component Structure

```typescript
// Component template
import React from 'react';

interface ComponentProps {
  // Props interface
}

export const Component: React.FC<ComponentProps> = ({ ...props }) => {
  // Component logic

  return (
    <div>
      {/* JSX */}
    </div>
  );
};

export default Component;
```

### API Services

```typescript
// Service template
import { axiosInstance } from '../utils/http';

export class ExampleService {
  async getData() {
    const response = await axiosInstance.get('/api/endpoint');
    return response.data;
  }
}
```

## 🧪 Testing

```bash
# Run tests
npm run test

# Run tests in watch mode
npm run test:watch
```

## 📦 Build & Deployment

### Build e preview locais
```bash
npm run build
npm run preview
```

### Docker (dev + hot reload)
```bash
# sobe frontend + serviços ABP necessários
docker compose up app-core auth-server app-frontend
# acessa http://localhost:5173 (proxy já configurado para /api e /connect)
```

### Docker (imagem de produção)
```bash
docker build -f apps/bamboo-react/Dockerfile -t bamboo-frontend:latest --target production apps/bamboo-react
docker run -p 8080:80 bamboo-frontend:latest
```

## 🔗 Integration

### Backend Integration

O frontend se integra com:

- **Bamboo Core API**: `/api/services/core/*`
- **Bamboo Admin API**: `/api/services/admin/*`
- **ABP Authentication**: `/connect/*`

### View Processor

As views XML do Odoo são processadas através do `ViewProcessorService`:

```typescript
// Example usage
const viewData = await viewProcessorService.processView({
  viewId: 'uuid-do-view',
  context: { active_ids: [...] }
});
```

## 📊 Performance

### Metas

- **Lighthouse Score**: >90
- **First Contentful Paint**: <1.5s
- **Time to Interactive**: <3s
- **Bundle Size**: <2MB (gzipped)

### Otimizações

- Code splitting por routes
- Lazy loading de componentes
- Virtual scrolling para grandes datasets
- Service Worker para caching
- Bundle analysis com `npm run analyze`

## 🐛 Troubleshooting

### Common Issues

**Syncfusion License Error**
```bash
# Register license in src/config/syncfusion.ts
registerLicense('YOUR_LICENSE_KEY');
```

**API Connection Issues**
```bash
# Check backend URLs in .env.local
VITE_API_BASE_URL=http://localhost:7105
```

**TypeScript Errors**
```bash
# Clear TypeScript cache
npm run build -- --reset-cache
```

## 📚 Documentation

- [Syncfusion React Documentation](https://ej2.syncfusion.com/react/documentation/)
- [ABP Framework Documentation](https://docs.abp.io/)
- [Vite Documentation](https://vitejs.dev/)
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)

## 🤝 Contributing

1. Fork o projeto
2. Crie feature branch (`git checkout -b feature/amazing-feature`)
3. Commit suas mudanças (`git commit -m 'Add amazing feature'`)
4. Push para branch (`git push origin feature/amazing-feature`)
5. Abra Pull Request

## 📄 License

Este projeto está sob licença da Bamboo ERP. Ver arquivo LICENSE para detalhes.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/bamboo-frontend/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/bamboo-frontend/discussions)
- **Documentation**: [Project Wiki](https://github.com/your-org/bamboo-frontend/wiki)

---

**Status**: 🚧 Em desenvolvimento
**Version**: 1.0.0
**Last Updated**: 2025-01-25
