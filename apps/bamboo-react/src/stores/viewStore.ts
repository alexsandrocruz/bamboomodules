import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

export interface ViewConfig {
  viewId: string;
  model: string;
  viewType: 'form' | 'tree' | 'kanban' | 'calendar' | 'search' | 'graph' | 'pivot';
  arch: string;
  fields: Record<string, any>;
  componentMap: Record<string, any>;
  context?: Record<string, any>;
}

export interface ViewRecord {
  id: string;
  data: Record<string, any>;
  isNew?: boolean;
  isModified?: boolean;
}

export interface ViewFilter {
  field: string;
  operator: string;
  value: any;
}

export interface ViewSort {
  field: string;
  direction: 'asc' | 'desc';
}

interface ViewState {
  // Current view state
  currentView: ViewConfig | null;
  records: ViewRecord[];
  selectedRecords: string[];
  filters: ViewFilter[];
  sorts: ViewSort[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
  };

  // UI state
  isLoading: boolean;
  isSaving: boolean;
  error: string | null;
  searchQuery: string;

  // Actions
  loadView: (viewId: string, context?: Record<string, any>) => Promise<void>;
  loadRecords: (viewId: string, page?: number, pageSize?: number, filters?: ViewFilter[], sorts?: ViewSort[]) => Promise<void>;
  createRecord: (data: Record<string, any>) => Promise<ViewRecord>;
  updateRecord: (recordId: string, data: Record<string, any>) => Promise<ViewRecord>;
  deleteRecord: (recordId: string) => Promise<void>;
  selectRecords: (recordIds: string[]) => void;
  clearSelection: () => void;
  setFilters: (filters: ViewFilter[]) => void;
  setSorts: (sorts: ViewSort[]) => void;
  setPage: (page: number, pageSize?: number) => void;
  setSearchQuery: (query: string) => void;
  setError: (error: string | null) => void;
  clearError: () => void;
  refreshRecords: () => Promise<void>;
}

export const useViewStore = create<ViewState>()(
  devtools(
    (set, get) => ({
      // Initial state
      currentView: null,
      records: [],
      selectedRecords: [],
      filters: [],
      sorts: [],
      pagination: {
        page: 1,
        pageSize: 20,
        total: 0,
        totalPages: 0,
      },
      isLoading: false,
      isSaving: false,
      error: null,
      searchQuery: '',

      // Actions
      loadView: async (viewId: string, context?: Record<string, any>) => {
        set({ isLoading: true, error: null });

        try {
          // TODO: Implement actual API call to View Processor
          // const viewConfig = await viewProcessorService.getView(viewId, context);

          // Mock implementation for now
          await new Promise(resolve => setTimeout(resolve, 500));

          const mockViewConfig: ViewConfig = {
            viewId,
            model: 'res.partner',
            viewType: 'tree',
            arch: '<tree><field name="name"/><field name="email"/></tree>',
            fields: {
              name: { type: 'char', string: 'Name' },
              email: { type: 'char', string: 'Email' },
            },
            componentMap: {
              name: { type: 'TextBoxComponent' },
              email: { type: 'TextBoxComponent' },
            },
            context,
          };

          set({
            currentView: mockViewConfig,
            isLoading: false,
          });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Failed to load view',
            isLoading: false,
          });
        }
      },

      loadRecords: async (_viewId: string, page = 1, pageSize = 20, filters = [], sorts = []) => {
        set({ isLoading: true, error: null });
        void _viewId;

        try {
          // TODO: Implement actual API call
          // const response = await viewProcessorService.getRecords(viewId, { page, pageSize, filters, sorts });

          // Mock implementation for now
          await new Promise(resolve => setTimeout(resolve, 800));

          const mockRecords: ViewRecord[] = Array.from({ length: pageSize }, (_, index) => ({
            id: `record-${(page - 1) * pageSize + index + 1}`,
            data: {
              name: `Partner ${(page - 1) * pageSize + index + 1}`,
              email: `partner${(page - 1) * pageSize + index + 1}@example.com`,
              phone: `+55 11 1234-${String(index).padStart(4, '0')}`,
            },
          }));

          set({
            records: mockRecords,
            pagination: {
              page,
              pageSize,
              total: 1000, // Mock total
              totalPages: Math.ceil(1000 / pageSize),
            },
            filters,
            sorts,
            isLoading: false,
          });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Failed to load records',
            isLoading: false,
          });
        }
      },

      createRecord: async (data: Record<string, any>) => {
        set({ isSaving: true, error: null });

        try {
          // TODO: Implement actual API call
          // const newRecord = await viewProcessorService.createRecord(currentView.model, data);

          // Mock implementation for now
          await new Promise(resolve => setTimeout(resolve, 500));

          const newRecord: ViewRecord = {
            id: `record-new-${Date.now()}`,
            data,
            isNew: true,
          };

          set(state => ({
            records: [newRecord, ...state.records],
            pagination: {
              ...state.pagination,
              total: state.pagination.total + 1,
            },
            isSaving: false,
          }));

          return newRecord;
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Failed to create record',
            isSaving: false,
          });
          throw error;
        }
      },

      updateRecord: async (recordId: string, data: Record<string, any>) => {
        set({ isSaving: true, error: null });

        try {
          // TODO: Implement actual API call
          // const updatedRecord = await viewProcessorService.updateRecord(recordId, data);

          // Mock implementation for now
          await new Promise(resolve => setTimeout(resolve, 500));

          set(state => ({
            records: state.records.map(record =>
              record.id === recordId
                ? { ...record, data: { ...record.data, ...data }, isModified: true }
                : record
            ),
            isSaving: false,
          }));

          const updatedRecord = get().records.find(r => r.id === recordId);
          if (!updatedRecord) throw new Error('Record not found');
          return updatedRecord;
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Failed to update record',
            isSaving: false,
          });
          throw error;
        }
      },

      deleteRecord: async (recordId: string) => {
        set({ isSaving: true, error: null });

        try {
          // TODO: Implement actual API call
          // await viewProcessorService.deleteRecord(recordId);

          // Mock implementation for now
          await new Promise(resolve => setTimeout(resolve, 300));

          set(state => ({
            records: state.records.filter(record => record.id !== recordId),
            selectedRecords: state.selectedRecords.filter(id => id !== recordId),
            pagination: {
              ...state.pagination,
              total: state.pagination.total - 1,
            },
            isSaving: false,
          }));
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Failed to delete record',
            isSaving: false,
          });
        }
      },

      selectRecords: (recordIds: string[]) => {
        set({ selectedRecords: recordIds });
      },

      clearSelection: () => {
        set({ selectedRecords: [] });
      },

      setFilters: (filters: ViewFilter[]) => {
        set({ filters });
        // Auto-refresh records when filters change
        get().refreshRecords();
      },

      setSorts: (sorts: ViewSort[]) => {
        set({ sorts });
        // Auto-refresh records when sorts change
        get().refreshRecords();
      },

      setPage: (page: number, pageSize?: number) => {
        const currentState = get();
        set({
          pagination: {
            ...currentState.pagination,
            page,
            ...(pageSize && { pageSize }),
          },
        });
        // Auto-refresh records when page changes
        get().refreshRecords();
      },

      setSearchQuery: (query: string) => {
        set({ searchQuery: query });
        // Auto-refresh records when search query changes
        get().refreshRecords();
      },

      setError: (error: string | null) => {
        set({ error });
      },

      clearError: () => {
        set({ error: null });
      },

      refreshRecords: async () => {
        const { currentView, pagination, filters, sorts, searchQuery } = get();
        if (!currentView) return;

        const searchFilters = searchQuery
          ? [{ field: 'search', operator: 'ilike', value: `%${searchQuery}%` }]
          : [];

        await get().loadRecords(
          currentView.viewId,
          pagination.page,
          pagination.pageSize,
          [...filters, ...searchFilters],
          sorts
        );
      },
    }),
    {
      name: 'bamboo-view-store',
    }
  )
);
