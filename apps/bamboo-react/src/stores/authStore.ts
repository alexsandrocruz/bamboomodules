import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  roles: string[];
  permissions: string[];
}

export interface Tenant {
  id: string;
  name: string;
  isActive: boolean;
}

interface AuthState {
  // State
  user: User | null;
  tenant: Tenant | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;

  // Actions
  login: (email: string, password: string, tenantId?: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<void>;
  updateProfile: (profile: Partial<User>) => Promise<void>;
  switchTenant: (tenantId: string) => Promise<void>;
  checkAuth: () => Promise<void>;
  setError: (error: string | null) => void;
  clearError: () => void;
}

export const useAuthStore = create<AuthState>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial state
        user: null,
        tenant: null,
        accessToken: null,
        refreshToken: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,

        // Actions
        login: async (email: string, password: string, tenantId?: string) => {
          set({ isLoading: true, error: null });

          try {
            // TODO: Implement actual API call to ABP authentication
            // const response = await authService.login(email, password, tenantId);

            // Mock implementation for now
            await new Promise(resolve => setTimeout(resolve, 1000));

            const mockUser: User = {
              id: '1',
              name: 'Demo User',
              email,
              roles: ['admin'],
              permissions: ['*', 'admin.*'],
            };

            const mockTenant: Tenant = {
              id: tenantId || 'default',
              name: 'Default Tenant',
              isActive: true,
            };

            const mockTokens = {
              accessToken: 'mock-access-token',
              refreshToken: 'mock-refresh-token',
            };

            set({
              user: mockUser,
              tenant: mockTenant,
              accessToken: mockTokens.accessToken,
              refreshToken: mockTokens.refreshToken,
              isAuthenticated: true,
              isLoading: false,
            });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Login failed',
              isLoading: false,
            });
          }
        },

        logout: async () => {
          set({ isLoading: true });

          try {
            // TODO: Implement actual API call
            // await authService.logout();

            await new Promise(resolve => setTimeout(resolve, 500));

            set({
              user: null,
              tenant: null,
              accessToken: null,
              refreshToken: null,
              isAuthenticated: false,
              isLoading: false,
              error: null,
            });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Logout failed',
              isLoading: false,
            });
          }
        },

        refreshToken: async () => {
          const { refreshToken: currentRefreshToken } = get();
          if (!currentRefreshToken) {
            return;
          }

          try {
            // TODO: Implement actual API call
            // const tokens = await authService.refreshToken(currentRefreshToken);

            set({
              accessToken: 'new-mock-access-token',
              refreshToken: 'new-mock-refresh-token',
            });
          } catch (error) {
            // If refresh fails, logout user
            get().logout();
          }
        },

        updateProfile: async (profile: Partial<User>) => {
          const { user } = get();
          if (!user) return;

          set({ isLoading: true });

          try {
            // TODO: Implement actual API call
            // await authService.updateProfile(profile);

            await new Promise(resolve => setTimeout(resolve, 500));

            set({
              user: { ...user, ...profile },
              isLoading: false,
            });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Profile update failed',
              isLoading: false,
            });
          }
        },

        switchTenant: async (tenantId: string) => {
          set({ isLoading: true });

          try {
            // TODO: Implement actual API call
            // const tenant = await authService.switchTenant(tenantId);

            await new Promise(resolve => setTimeout(resolve, 500));

            const mockTenant: Tenant = {
              id: tenantId,
              name: `Tenant ${tenantId}`,
              isActive: true,
            };

            set({
              tenant: mockTenant,
              isLoading: false,
            });
          } catch (error) {
            set({
              error: error instanceof Error ? error.message : 'Tenant switch failed',
              isLoading: false,
            });
          }
        },

        checkAuth: async () => {
          const { accessToken } = get();
          if (!accessToken) {
            return;
          }

          set({ isLoading: true });

          try {
            // TODO: Implement actual API call
            // const user = await authService.getCurrentUser();

            await new Promise(resolve => setTimeout(resolve, 500));

            // If token is valid, keep current state
            set({ isLoading: false });
          } catch (error) {
            // If token is invalid, clear auth state
            set({
              user: null,
              tenant: null,
              accessToken: null,
              refreshToken: null,
              isAuthenticated: false,
              isLoading: false,
            });
          }
        },

        setError: (error: string | null) => {
          set({ error });
        },

        clearError: () => {
          set({ error: null });
        },
      }),
      {
        name: 'bamboo-auth-store',
        partialize: (state) => ({
          user: state.user,
          tenant: state.tenant,
          accessToken: state.accessToken,
          refreshToken: state.refreshToken,
          isAuthenticated: state.isAuthenticated,
        }),
      }
    ),
    {
      name: 'bamboo-auth-store',
    }
  )
);