import axios from 'axios';
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';

export interface ApiResponse<T = any> {
  result: T;
  error?: {
    code: string;
    message: string;
    details?: any;
  };
  success: boolean;
}

export interface PaginatedResponse<T> {
  items: T[];
  totalCount: number;
  pageSize: number;
  currentPage: number;
  totalPages: number;
}

// HTTP Client configuration
const httpConfig: AxiosRequestConfig = {
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:7104',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
};

// Create axios instance
export const axiosInstance: AxiosInstance = axios.create(httpConfig);

// Request interceptor
axiosInstance.interceptors.request.use(
  (config) => {
    // Add request timestamp for debugging
    (config as any).metadata = { startTime: new Date() };
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor
axiosInstance.interceptors.response.use(
  (response: AxiosResponse) => {
    // Calculate request duration for monitoring
    const endTime = new Date();
    const startTime = (response.config as any).metadata?.startTime;
    const duration = startTime ? endTime.getTime() - startTime.getTime() : 0;

    // Log slow requests in development
    if (import.meta.env.DEV && duration > 1000) {
      console.warn(`Slow API request: ${response.config.url} took ${duration}ms`);
    }

    return response;
  },
  async (error) => {
    // Handle network errors
    if (!error.response) {
      console.error('Network error:', error.message);
      return Promise.reject(new Error('Network connection failed. Please check your internet connection.'));
    }

    // Handle API error responses
    const apiError = error.response.data;
    if (apiError && typeof apiError === 'object' && 'error' in apiError) {
      const errorMessage = apiError.error?.message || apiError.message || 'An unexpected error occurred';
      return Promise.reject(new Error(errorMessage));
    }

    // Default error handling
    const errorMessage = error.response.data?.message || error.message || 'Request failed';
    return Promise.reject(new Error(errorMessage));
  }
);

// HTTP utility functions
export const http = {
  // GET request
  get: async <T = any>(url: string, config?: AxiosRequestConfig): Promise<ApiResponse<T>> => {
    const response = await axiosInstance.get<ApiResponse<T>>(url, config);
    return response.data;
  },

  // POST request
  post: async <T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<ApiResponse<T>> => {
    const response = await axiosInstance.post<ApiResponse<T>>(url, data, config);
    return response.data;
  },

  // PUT request
  put: async <T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<ApiResponse<T>> => {
    const response = await axiosInstance.put<ApiResponse<T>>(url, data, config);
    return response.data;
  },

  // PATCH request
  patch: async <T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<ApiResponse<T>> => {
    const response = await axiosInstance.patch<ApiResponse<T>>(url, data, config);
    return response.data;
  },

  // DELETE request
  delete: async <T = any>(url: string, config?: AxiosRequestConfig): Promise<ApiResponse<T>> => {
    const response = await axiosInstance.delete<ApiResponse<T>>(url, config);
    return response.data;
  },

  // File upload
  upload: async <T = any>(url: string, file: File, config?: AxiosRequestConfig): Promise<ApiResponse<T>> => {
    const formData = new FormData();
    formData.append('file', file);

    const uploadConfig: AxiosRequestConfig = {
      ...config,
      headers: {
        'Content-Type': 'multipart/form-data',
        ...config?.headers,
      },
    };

    const response = await axiosInstance.post<ApiResponse<T>>(url, formData, uploadConfig);
    return response.data;
  },

  // Download file
  download: async (url: string, filename?: string, config?: AxiosRequestConfig): Promise<void> => {
    const response = await axiosInstance.get(url, {
      ...config,
      responseType: 'blob',
    });

    // Create download link
    const blob = new Blob([response.data]);
    const downloadUrl = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = downloadUrl;
    link.download = filename || 'download';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(downloadUrl);
  },
};

// ABP-specific HTTP utilities
export const abpHttp = {
  // ABP application services
  callAppService: async <T = any>(
    serviceName: string,
    methodName: string,
    data?: any,
    config?: AxiosRequestConfig
  ): Promise<ApiResponse<T>> => {
    const url = `/api/services/${serviceName}/${methodName}`;
    return data ? http.post(url, data, config) : http.get(url, config);
  },

  // ABP authentication endpoints
  login: async (username: string, password: string, tenantId?: string): Promise<ApiResponse> => {
    const response = await fetch('/connect/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'password',
        username,
        password,
        client_id: 'Bamboo_Web',
        client_secret: '1q2w3e*',
        scope: 'Bamboo offline_access',
        ...(tenantId && { tenant_id: tenantId }),
      }),
    });

    if (!response.ok) {
      throw new Error('Login failed');
    }

    return response.json();
  },

  logout: async (): Promise<ApiResponse> => {
    const response = await fetch('/connect/revocation', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        client_id: 'Bamboo_Web',
        client_secret: '1q2w3e*',
      }),
    });

    return response.json();
  },

  getCurrentUser: async (): Promise<ApiResponse> => {
    return http.get('/api/abp/application-configuration');
  },

  refreshToken: async (refreshToken: string): Promise<ApiResponse> => {
    const response = await fetch('/connect/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        client_id: 'Bamboo_Web',
        client_secret: '1q2w3e*',
        refresh_token: refreshToken,
      }),
    });

    if (!response.ok) {
      throw new Error('Token refresh failed');
    }

    return response.json();
  },
};

export default http;