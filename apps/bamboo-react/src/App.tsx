function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-green-700 text-white">
        <div className="container mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold">Bamboo ERP</h1>
          <p className="text-green-100">React Frontend</p>
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
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;