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

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Development URLs

- **Development**: http://localhost:5173
- **Backend API**: http://localhost:7104 (Core API)
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

Create `.env.local` file:

```env
# Backend Configuration
VITE_API_BASE_URL=http://localhost:7104
VITE_AUTH_BASE_URL=http://localhost:7103

# Application
VITE_APP_NAME=Bamboo ERP
VITE_APP_VERSION=1.0.0

# Features (toggle during development)
VITE_ENABLE_SYNCFUSION=true
VITE_ENABLE_ANALYTICS=false
```

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

# Generate coverage report
npm run test:coverage
```

## 📦 Build & Deployment

### Development Build
```bash
npm run build:dev
```

### Production Build
```bash
npm run build:prod
```

### Docker Build
```bash
# Build Docker image
docker build -t bamboo-frontend .

# Run container
docker run -p 5173:5173 bamboo-frontend
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
VITE_API_BASE_URL=http://localhost:7104
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