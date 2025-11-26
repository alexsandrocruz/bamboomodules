import React from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

// Create a client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      retry: 3,
      retryDelay: attemptIndex => Math.min(1000 * 2 ** attemptIndex, 30000),
      refetchOnWindowFocus: false,
      refetchOnReconnect: true,
    },
    mutations: {
      retry: 1,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <div className="min-h-screen bg-gray-50">
        <header className="bg-bamboo-primary text-white">
          <div className="container mx-auto px-4 py-4">
            <h1 className="text-2xl font-bold">Bamboo ERP</h1>
            <p className="text-bamboo-primary/100">React Frontend</p>
          </div>
        </header>

        <main className="container mx-auto px-4 py-8">
          <div className="space-y-6">
            {/* Welcome Section */}
            <div className="card">
              <div className="card-header">
                <h2 className="card-title">Welcome to Bamboo ERP</h2>
                <p className="card-description">
                  Modern React frontend built with Vite, TypeScript, and TailwindCSS
                </p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div className="p-4 bg-green-50 rounded-lg border border-green-200">
                  <h3 className="font-semibold text-green-800 mb-2">✅ Completed</h3>
                  <ul className="text-sm text-green-700 space-y-1">
                    <li>• Vite + React + TypeScript setup</li>
                    <li>• TailwindCSS configured</li>
                    <li>• ESLint + Prettier setup</li>
                    <li>• Core dependencies installed</li>
                  </ul>
                </div>

                <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
                  <h3 className="font-semibold text-blue-800 mb-2">🚧 In Progress</h3>
                  <ul className="text-sm text-blue-700 space-y-1">
                    <li>• ABP Framework integration</li>
                    <li>• Syncfusion components</li>
                    <li>• View Processor</li>
                  </ul>
                </div>

                <div className="p-4 bg-gray-50 rounded-lg border border-gray-200">
                  <h3 className="font-semibold text-gray-800 mb-2">📋 Next Steps</h3>
                  <ul className="text-sm text-gray-700 space-y-1">
                    <li>• Authentication system</li>
                    <li>• Dynamic views</li>
                    <li>• Dashboard</li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Technology Stack */}
            <div className="card">
              <div className="card-header">
                <h2 className="card-title">Technology Stack</h2>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="text-center p-4">
                  <div className="text-2xl mb-2">⚡</div>
                  <h4 className="font-semibold">Vite</h4>
                  <p className="text-sm text-gray-600">Build Tool</p>
                </div>

                <div className="text-center p-4">
                  <div className="text-2xl mb-2">⚛️</div>
                  <h4 className="font-semibold">React 18</h4>
                  <p className="text-sm text-gray-600">UI Framework</p>
                </div>

                <div className="text-center p-4">
                  <div className="text-2xl mb-2">📘</div>
                  <h4 className="font-semibold">TypeScript</h4>
                  <p className="text-sm text-gray-600">Type Safety</p>
                </div>

                <div className="text-center p-4">
                  <div className="text-2xl mb-2">🎨</div>
                  <h4 className="font-semibold">TailwindCSS</h4>
                  <p className="text-sm text-gray-600">Styling</p>
                </div>

                <div className="text-center p-4">
                  <div className="text-2xl mb-2">🔄</div>
                  <h4 className="font-semibold">React Query</h4>
                  <p className="text-sm text-gray-600">Data Fetching</p>
                </div>

                <div className="text-center p-4">
                  <div className="text-2xl mb-2">🗄️</div>
                  <h4 className="font-semibold">Zustand</h4>
                  <p className="text-sm text-gray-600">State Management</p>
                </div>

                <div className="text-center p-4">
                  <div className="text-2xl mb-2">🧩</div>
                  <h4 className="font-semibold">Syncfusion</h4>
                  <p className="text-sm text-gray-600">UI Components</p>
                </div>

                <div className="text-center p-4">
                  <div className="text-2xl mb-2">🏗️</div>
                  <h4 className="font-semibold">ABP Framework</h4>
                  <p className="text-sm text-gray-600">Backend</p>
                </div>
              </div>
            </div>

            {/* Component Demo */}
            <div className="card">
              <div className="card-header">
                <h2 className="card-title">UI Components Demo</h2>
                <p className="card-description">Testing TailwindCSS components</p>
              </div>

              <div className="space-y-4">
                <div className="flex flex-wrap gap-2">
                  <button className="btn btn-primary">Primary Button</button>
                  <button className="btn btn-secondary">Secondary Button</button>
                  <button className="btn btn-success">Success Button</button>
                  <button className="btn btn-warning">Warning Button</button>
                  <button className="btn btn-danger">Danger Button</button>
                  <button className="btn btn-outline">Outline Button</button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="form-group">
                    <label className="form-label">Email Address</label>
                    <input
                      type="email"
                      className="form-input"
                      placeholder="user@example.com"
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">Password</label>
                    <input
                      type="password"
                      className="form-input"
                      placeholder="Enter password"
                    />
                  </div>
                </div>

                <div className="flex flex-wrap gap-2">
                  <span className="status-badge status-success">Active</span>
                  <span className="status-badge status-warning">Pending</span>
                  <span className="status-badge status-error">Error</span>
                  <span className="status-badge status-info">Info</span>
                </div>

                <div className="flex items-center gap-2">
                  <div className="loading-spinner w-6 h-6"></div>
                  <span className="text-sm text-gray-600">Loading...</span>
                </div>
              </div>
            </div>
          </div>
        </main>

        <footer className="bg-gray-100 border-t border-gray-200 mt-auto">
          <div className="container mx-auto px-4 py-4 text-center text-sm text-gray-600">
            <p>Bamboo ERP © 2025 - Built with ❤️ using modern web technologies</p>
          </div>
        </footer>
      </div>

      {/* React Query Devtools - only in development */}
      {import.meta.env.DEV && <ReactQueryDevtools initialIsOpen={false} />}
    </QueryClientProvider>
  );
}

export default App;