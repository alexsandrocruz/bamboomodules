# Implementação do View-Processor para Bamboo ERP

## 📋 Resumo Executivo

Este documento detalha a implementação do **View-Processor** - o motor responsável por converter as views XML do Odoo (armazenadas no banco) em componentes React Syncfusion funcionais. Este é o **componente crítico** que está faltando para completar a UI do Bamboo ERP.

---

## 🏗️ Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                     Frontend (React/ABP)                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌──────────────────┐    ┌─────────────┐ │
│  │   XML Parser    │───▶│ ComponentMapper  │───▶│  Renderer   │ │
│  │   (TypeScript)  │    │   (Syncfusion)   │    │ (React)     │ │
│  └─────────────────┘    └──────────────────┘    └─────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼ HTTP API
┌─────────────────────────────────────────────────────────────────┐
│                    Backend (ABP/C#)                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌──────────────────┐    ┌─────────────┐ │
│  │ ir_ui_view      │    │ View Processor   │    │ Generic API │ │
│  │   (PostgreSQL)  │    │   (C# Service)   │    │  (ABP)      │ │
│  └─────────────────┘    └──────────────────┘    └─────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Backend Implementation (C#/.NET)

### 1. **View Processor Service**

```csharp
// services/core/src/Bamboo.Core.Application/Views/ViewProcessorAppService.cs
using System.Xml;
using System.Text.Json;
using Bamboo.Core.Models;

namespace Bamboo.Core.Application.Views
{
    public class ViewProcessorAppService : ApplicationService, IViewProcessorAppService
    {
        private readonly IRepository<IrUiView, Guid> _viewRepository;
        private readonly IRepository<IrModel, Guid> _modelRepository;
        private readonly IRepository<IrModelFields, Guid> _fieldsRepository;

        public ViewProcessorAppService(
            IRepository<IrUiView, Guid> viewRepository,
            IRepository<IrModel, Guid> modelRepository,
            IRepository<IrModelFields, Guid> fieldsRepository)
        {
            _viewRepository = viewRepository;
            _modelRepository = modelRepository;
            _fieldsRepository = fieldsRepository;
        }

        public async Task<ViewProcessorResultDto> ProcessViewAsync(ProcessViewInput input)
        {
            // 1. Buscar view no banco
            var view = await _viewRepository.GetAsync(input.ViewId);

            // 2. Obter XML combinado (com herança)
            var combinedXml = await GetCombinedViewXmlAsync(view);

            // 3. Parsear XML
            var parsedView = ParseViewXml(combinedXml);

            // 4. Obter fields do modelo
            var modelFields = await GetModelFieldsAsync(view.Model);

            // 5. Mapear para componentes
            var componentMap = MapToComponents(parsedView, modelFields);

            return new ViewProcessorResultDto
            {
                ViewId = view.Id,
                ViewType = view.Type,
                Model = view.Model,
                ComponentMap = componentMap,
                Fields = modelFields.Select(f => ObjectMapper.Map<IrModelFieldsDto>(f)).ToList()
            };
        }

        public async Task<string> GetCombinedViewXmlAsync(IrUiView view)
        {
            var xml = view.ArchDb?.GetRawText() ?? view.ArchFs;

            // Aplicar herança
            if (view.InheritId.HasValue)
            {
                var parentView = await _viewRepository.GetAsync(view.InheritId.Value);
                var parentXml = await GetCombinedViewXmlAsync(parentView);
                xml = ApplyInheritance(parentXml, xml);
            }

            return xml;
        }

        private ParsedViewDto ParseViewXml(string xml)
        {
            var doc = new XmlDocument();
            doc.LoadXml(xml);

            var root = doc.DocumentElement;

            return root.Name switch
            {
                "form" => ParseFormView(root),
                "tree" => ParseTreeView(root),
                "kanban" => ParseKanbanView(root),
                "calendar" => ParseCalendarView(root),
                "search" => ParseSearchView(root),
                "graph" => ParseGraphView(root),
                "pivot" => ParsePivotView(root),
                _ => throw new NotSupportedException($"View type {root.Name} not supported")
            };
        }

        private ParsedViewDto ParseFormView(XmlElement root)
        {
            var result = new FormViewDto();

            // Parse sheet
            var sheet = root.SelectSingleNode("sheet");
            if (sheet != null)
            {
                result.Sheet = ParseSheet(sheet);
            }

            // Parse notebook (tabs)
            var notebook = root.SelectSingleNode("notebook");
            if (notebook != null)
            {
                result.Notebook = ParseNotebook(notebook);
            }

            // Parse buttons
            var buttons = root.SelectNodes("header/button");
            if (buttons != null)
            {
                result.Buttons = ParseButtons(buttons);
            }

            return new ParsedViewDto { Type = "form", Data = result };
        }

        private FormSheetDto ParseSheet(XmlNode sheet)
        {
            var groups = new List<FormGroupDto>();

            foreach (XmlNode group in sheet.SelectNodes("group"))
            {
                var groupDto = new FormGroupDto
                {
                    Name = group.Attributes?["name"]?.Value,
                    String = group.Attributes?["string"]?.Value,
                    Fields = ParseFields(group)
                };

                groups.Add(groupDto);
            }

            return new FormSheetDto { Groups = groups };
        }

        private List<FieldDto> ParseFields(XmlNode container)
        {
            var fields = new List<FieldDto>();

            foreach (XmlNode field in container.SelectNodes("field"))
            {
                var fieldDto = new FieldDto
                {
                    Name = field.Attributes?["name"]?.Value,
                    String = field.Attributes?["string"]?.Value,
                    Required = field.Attributes?["required"]?.Value == "True",
                    Readonly = field.Attributes?["readonly"]?.Value == "True",
                    Invisible = field.Attributes?["invisible"]?.Value == "True",
                    Widget = field.Attributes?["widget"]?.Value,
                    Options = ParseFieldOptions(field),
                    Domain = field.Attributes?["domain"]?.Value
                };

                fields.Add(fieldDto);
            }

            return fields;
        }

        private ComponentMapDto MapToComponents(ParsedViewDto parsedView, List<IrModelFields> modelFields)
        {
            var componentMap = new ComponentMapDto
            {
                ViewType = parsedView.Type,
                MainComponent = GetMainComponent(parsedView.Type),
                Components = new List<ComponentDto>()
            };

            switch (parsedView.Type)
            {
                case "form":
                    componentMap = MapFormViewComponents(componentMap, (FormViewDto)parsedView.Data, modelFields);
                    break;
                case "tree":
                    componentMap = MapTreeViewComponents(componentMap, (TreeViewDto)parsedView.Data, modelFields);
                    break;
                case "kanban":
                    componentMap = MapKanbanViewComponents(componentMap, (KanbanViewDto)parsedView.Data, modelFields);
                    break;
            }

            return componentMap;
        }

        private ComponentMapDto MapFormViewComponents(ComponentMapDto componentMap, FormViewDto formView, List<IrModelFields> modelFields)
        {
            componentMap.MainComponent = "OdooForm";

            // Mapear fields da sheet
            if (formView.Sheet != null)
            {
                foreach (var group in formView.Sheet.Groups)
                {
                    foreach (var field in group.Fields)
                    {
                        var modelField = modelFields.FirstOrDefault(f => f.Name == field.Name);
                        if (modelField != null)
                        {
                            componentMap.Components.Add(new ComponentDto
                            {
                                Name = field.Name,
                                Type: MapFieldTypeToComponent(modelField.TType),
                                Props = MapFieldToProps(field, modelField),
                                Label = field.String ?? modelField.FieldDescription
                            });
                        }
                    }
                }
            }

            return componentMap;
        }

        private string MapFieldTypeToComponent(string odooType)
        {
            return odooType switch
            {
                "char" => "TextBoxComponent",
                "text" => "RichTextEditorComponent",
                "selection" => "DropDownListComponent",
                "many2one" => "DropDownListComponent",
                "one2many" => "GridComponent",
                "many2many" => "MultiSelectComponent",
                "boolean" => "CheckBoxComponent",
                "integer" => "NumericTextBoxComponent",
                "float" => "NumericTextBoxComponent",
                "monetary" => "NumericTextBoxComponent",
                "date" => "DatePickerComponent",
                "datetime" => "DateTimePickerComponent",
                "binary" => "FileUploadComponent",
                "html" => "RichTextEditorComponent",
                _ => "TextBoxComponent"
            };
        }

        private async Task<List<IrModelFields>> GetModelFieldsAsync(string modelName)
        {
            var model = await _modelRepository.FirstOrDefaultAsync(m => m.Model == modelName);
            if (model == null)
                return new List<IrModelFields>();

            return await _fieldsRepository.GetListAsync(f => f.ModelId == model.Id);
        }
    }

    // DTOs
    public class ProcessViewInput
    {
        public Guid ViewId { get; set; }
        public Dictionary<string, object> Context { get; set; } = new();
    }

    public class ViewProcessorResultDto
    {
        public Guid ViewId { get; set; }
        public string ViewType { get; set; }
        public string Model { get; set; }
        public ComponentMapDto ComponentMap { get; set; }
        public List<IrModelFieldsDto> Fields { get; set; }
    }

    public class ComponentMapDto
    {
        public string ViewType { get; set; }
        public string MainComponent { get; set; }
        public List<ComponentDto> Components { get; set; } = new();
    }

    public class ComponentDto
    {
        public string Name { get; set; }
        public string Type { get; set; }
        public object Props { get; set; }
        public string Label { get; set; }
        public Dictionary<string, object> Events { get; set; } = new();
    }

    public class ParsedViewDto
    {
        public string Type { get; set; }
        public object Data { get; set; }
    }

    public class FormViewDto
    {
        public FormSheetDto Sheet { get; set; }
        public NotebookDto Notebook { get; set; }
        public List<ButtonDto> Buttons { get; set; }
    }

    public class FormSheetDto
    {
        public List<FormGroupDto> Groups { get; set; }
    }

    public class FormGroupDto
    {
        public string Name { get; set; }
        public string String { get; set; }
        public List<FieldDto> Fields { get; set; }
    }

    public class FieldDto
    {
        public string Name { get; set; }
        public string String { get; set; }
        public bool Required { get; set; }
        public bool Readonly { get; set; }
        public bool Invisible { get; set; }
        public string Widget { get; set; }
        public object Options { get; set; }
        public string Domain { get; set; }
    }
}
```

### 2. **API Controller**

```csharp
// services/core/src/Bamboo.Core.HttpApi/Controllers/ViewProcessorController.cs
using Microsoft.AspNetCore.Mvc;
using Bamboo.Core.Application.Views;

namespace Bamboo.Core.HttpApi.Controllers
{
    [Route("api/services/core/view-processor")]
    public class ViewProcessorController : AbpControllerBase
    {
        private readonly IViewProcessorAppService _viewProcessorService;

        public ViewProcessorController(IViewProcessorAppService viewProcessorService)
        {
            _viewProcessorService = viewProcessorService;
        }

        [HttpPost("process")]
        public async Task<ViewProcessorResultDto> ProcessViewAsync([FromBody] ProcessViewInput input)
        {
            return await _viewProcessorService.ProcessViewAsync(input);
        }

        [HttpGet("render/{viewId}")]
        public async Task<ViewProcessorResultDto> RenderViewAsync(Guid viewId)
        {
            var input = new ProcessViewInput { ViewId = viewId };
            return await _viewProcessorService.ProcessViewAsync(input);
        }

        [HttpGet("model-fields/{modelName}")]
        public async Task<List<IrModelFieldsDto>> GetModelFieldsAsync(string modelName)
        {
            return await _viewProcessorService.GetModelFieldsAsync(modelName);
        }
    }
}
```

---

## 🎨 Frontend Implementation (React/TypeScript)

### 1. **View Processor Service**

```typescript
// shared/src/lib/view-processor.service.ts
import { HttpClient } from '@abp/ng.core';
import { Observable } from 'rxjs';

export interface ProcessViewInput {
  viewId: string;
  context?: Record<string, any>;
}

export interface ViewProcessorResult {
  viewId: string;
  viewType: string;
  model: string;
  componentMap: ComponentMap;
  fields: ModelField[];
}

export interface ComponentMap {
  viewType: string;
  mainComponent: string;
  components: Component[];
}

export interface Component {
  name: string;
  type: string;
  props: any;
  label: string;
  events?: Record<string, any>;
}

export interface ModelField {
  id: string;
  name: string;
  fieldDescription: string;
  tType: string;
  required: boolean;
  readonly: boolean;
  relation?: string;
  selection?: string[][];
}

export class ViewProcessorService {
  constructor(private http: HttpClient) {}

  processView(input: ProcessViewInput): Observable<ViewProcessorResult> {
    return this.http.post<ViewProcessorResult>('/api/services/core/view-processor/process', input);
  }

  renderView(viewId: string): Observable<ViewProcessorResult> {
    return this.http.get<ViewProcessorResult>(`/api/services/core/view-processor/render/${viewId}`);
  }

  getModelFields(modelName: string): Observable<ModelField[]> {
    return this.http.get<ModelField[]>(`/api/services/core/view-processor/model-fields/${modelName}`);
  }
}
```

### 2. **Dynamic Component Loader**

```typescript
// shared/src/components/dynamic-view-renderer.tsx
import React, { Suspense, lazy } from 'react';
import { ViewProcessorResult } from '../lib/view-processor.service';

// Lazy loading dos componentes
const OdooForm = lazy(() => import('./views/odoo-form'));
const OdooTree = lazy(() => import('./views/odoo-tree'));
const OdooKanban = lazy(() => import('./views/odoo-kanban'));
const OdooCalendar = lazy(() => import('./views/odoo-calendar'));
const OdooSearch = lazy(() => import('./views/odoo-search'));
const OdooGraph = lazy(() => import('./views/odoo-graph'));
const OdooPivot = lazy(() => import('./views/odoo-pivot'));

interface DynamicViewRendererProps {
  viewData: ViewProcessorResult;
  record?: any;
  records?: any[];
  onDataChange?: (data: any) => void;
}

const componentMap = {
  'form': OdooForm,
  'tree': OdooTree,
  'kanban': OdooKanban,
  'calendar': OdooCalendar,
  'search': OdooSearch,
  'graph': OdooGraph,
  'pivot': OdooPivot
};

export const DynamicViewRenderer: React.FC<DynamicViewRendererProps> = ({
  viewData,
  record,
  records,
  onDataChange
}) => {
  const Component = componentMap[viewData.viewType as keyof typeof componentMap];

  if (!Component) {
    return (
      <div className="alert alert-warning">
        View type '{viewData.viewType}' not supported
      </div>
    );
  }

  return (
    <Suspense fallback={<div className="loading-spinner">Loading view...</div>}>
      <Component
        viewData={viewData}
        record={record}
        records={records}
        onDataChange={onDataChange}
      />
    </Suspense>
  );
};
```

### 3. **Odoo Form Component**

```typescript
// shared/src/components/views/odoo-form.tsx
import React, { useState, useEffect } from 'react';
import {
  TextBoxComponent,
  DropDownListComponent,
  DatePickerComponent,
  CheckBoxComponent,
  RichTextEditorComponent,
  NumericTextBoxComponent,
  FileUploadComponent
} from '@syncfusion/ej2-react-inputs';
import {
  TabComponent,
  TabItemsDirective,
  TabItemDirective
} from '@syncfusion/ej2-react-navigations';
import { ButtonComponent } from '@syncfusion/ej2-react-buttons';
import { ViewProcessorResult, Component } from '../../lib/view-processor.service';

interface OdooFormProps {
  viewData: ViewProcessorResult;
  record?: any;
  onDataChange?: (data: any) => void;
}

export const OdooForm: React.FC<OdooFormProps> = ({
  viewData,
  record = {},
  onDataChange
}) => {
  const [formData, setFormData] = useState(record);
  const [loading, setLoading] = useState(false);

  const componentMap = {
    'TextBoxComponent': TextBoxComponent,
    'DropDownListComponent': DropDownListComponent,
    'DatePickerComponent': DatePickerComponent,
    'CheckBoxComponent': CheckBoxComponent,
    'RichTextEditorComponent': RichTextEditorComponent,
    'NumericTextBoxComponent': NumericTextBoxComponent,
    'FileUploadComponent': FileUploadComponent
  };

  const handleFieldChange = (fieldName: string, value: any) => {
    const newData = { ...formData, [fieldName]: value };
    setFormData(newData);
    onDataChange?.(newData);
  };

  const renderField = (component: Component) => {
    const FieldComponent = componentMap[component.type as keyof typeof componentMap];
    if (!FieldComponent) return null;

    const commonProps = {
      value: formData[component.name] || '',
      change: (e: any) => handleFieldChange(component.name, e.value),
      placeholder: component.label,
      enabled: !component.props?.readonly
    };

    switch (component.type) {
      case 'DropDownListComponent':
        if (component.props?.relation) {
          // Carregar dados relacionados
          return (
            <FieldComponent
              {...commonProps}
              dataSource={[]} // TODO: Carregar da API
              fields={{ text: 'name', value: 'id' }}
              allowFiltering={true}
            />
          );
        }
        if (component.props?.selection) {
          return (
            <FieldComponent
              {...commonProps}
              dataSource={component.props.selection}
              fields={{ text: 'label', value: 'value' }}
            />
          );
        }
        break;

      case 'NumericTextBoxComponent':
        return (
          <FieldComponent
            {...commonProps}
            format={component.props?.widget === 'monetary' ? 'C2' : 'N'}
            decimals={component.props?.widget === 'monetary' ? 2 : 0}
          />
        );

      case 'CheckBoxComponent':
        return (
          <FieldComponent
            {...commonProps}
            checked={formData[component.name] || false}
          />
        );

      case 'RichTextEditorComponent':
        return (
          <FieldComponent
            {...commonProps}
            value={formData[component.name] || ''}
          />
        );

      default:
        return <FieldComponent {...commonProps} />;
    }

    return <FieldComponent {...commonProps} />;
  };

  const renderFormGroups = () => {
    const groups = viewData.componentMap.components.reduce((acc, component) => {
      // Agrupar por algum critério (ex: group, sheet)
      const group = component.props?.group || 'default';
      if (!acc[group]) acc[group] = [];
      acc[group].push(component);
      return acc;
    }, {} as Record<string, Component[]>);

    return Object.entries(groups).map(([groupName, components]) => (
      <div key={groupName} className="form-group">
        <h4>{groupName}</h4>
        <div className="row">
          {components.map((component, index) => (
            <div key={component.name} className="col-md-6 mb-3">
              <label className="form-label">
                {component.label}
                {component.props?.required && <span className="text-danger">*</span>}
              </label>
              {renderField(component)}
            </div>
          ))}
        </div>
      </div>
    ));
  };

  return (
    <div className="odoo-form">
      {renderFormGroups()}

      <div className="form-actions mt-4">
        <ButtonComponent
          cssClass="e-primary"
          onClick={() => console.log('Save', formData)}
        >
          Save
        </ButtonComponent>
        <ButtonComponent
          cssClass="e-secondary"
          onClick={() => setFormData(record)}
        >
          Discard
        </ButtonComponent>
      </div>
    </div>
  );
};
```

### 4. **Odoo Tree Component**

```typescript
// shared/src/components/views/odoo-tree.tsx
import React, { useState, useEffect } from 'react';
import {
  GridComponent,
  ColumnsDirective,
  ColumnDirective,
  Page,
  Sort,
  Filter,
  Edit,
  Toolbar,
  ExcelExport,
  PdfExport
} from '@syncfusion/ej2-react-grids';
import { ViewProcessorResult } from '../../lib/view-processor.service';

interface OdooTreeProps {
  viewData: ViewProcessorResult;
  records?: any[];
  onRecordSelect?: (record: any) => void;
  onRecordEdit?: (record: any) => void;
}

export const OdooTree: React.FC<OdooTreeProps> = ({
  viewData,
  records = [],
  onRecordSelect,
  onRecordEdit
}) => {
  const [data, setData] = useState(records);

  const gridOptions = {
    allowPaging: true,
    allowSorting: true,
    allowFiltering: true,
    allowExcelExport: true,
    allowPdfExport: true,
    pageSettings: { pageSize: 20 },
    toolbar: ['Search', 'ExcelExport', 'PdfExport'],
    editSettings: {
      allowEditing: true,
      allowAdding: true,
      allowDeleting: true,
      mode: 'Dialog'
    }
  };

  const handleRecordClick = (args: any) => {
    if (onRecordSelect) {
      onRecordSelect(args.rowData);
    }
  };

  const handleEdit = (args: any) => {
    if (onRecordEdit) {
      onRecordEdit(args.rowData);
    }
  };

  return (
    <div className="odoo-tree">
      <GridComponent
        dataSource={data}
        {...gridOptions}
        recordClick={handleRecordClick}
        actionComplete={handleEdit}
      >
        <ColumnsDirective>
          {viewData.componentMap.components.map((component) => (
            <ColumnDirective
              key={component.name}
              field={component.name}
              headerText={component.label}
              type={getColumnType(component.type)}
              format={getColumnFormat(component.props?.widget)}
              template={getColumnTemplate(component)}
              editType={getEditType(component.type)}
              validationRules={getValidationRules(component.props)}
            />
          ))}
        </ColumnsDirective>
        <Page />
        <Sort />
        <Filter />
        <Edit />
        <Toolbar />
      </GridComponent>
    </div>
  );
};

const getColumnType = (componentType: string) => {
  const typeMap = {
    'NumericTextBoxComponent': 'number',
    'DatePickerComponent': 'date',
    'DateTimePickerComponent': 'datetime',
    'CheckBoxComponent': 'boolean',
    'DropDownListComponent': 'string'
  };
  return typeMap[componentType] || 'string';
};

const getColumnFormat = (widget?: string) => {
  const formatMap = {
    'monetary': 'C2',
    'percentage': 'P2',
    'date': 'dd/MM/yyyy',
    'datetime': 'dd/MM/yyyy HH:mm'
  };
  return formatMap[widget as keyof typeof formatMap];
};

const getColumnTemplate = (component: Component) => {
  if (component.props?.widget === 'statusbar') {
    return (props: any) => (
      <span className={`status-${props[component.name]}`}>
        {props[component.name]}
      </span>
    );
  }
  if (component.type === 'CheckBoxComponent') {
    return (props: any) => (
      <input
        type="checkbox"
        checked={props[component.name]}
        disabled
      />
    );
  }
  return null;
};

const getEditType = (componentType: string) => {
  const editTypeMap = {
    'TextBoxComponent': 'textedit',
    'NumericTextBoxComponent': 'numericedit',
    'DatePickerComponent': 'datepicker',
    'DropDownListComponent': 'dropdownedit',
    'CheckBoxComponent': 'booleanedit'
  };
  return editTypeMap[componentType] || 'textedit';
};

const getValidationRules = (props?: any) => {
  const rules: any = {};
  if (props?.required) {
    rules.required = true;
  }
  if (props?.min) {
    rules.min = props.min;
  }
  if (props?.max) {
    rules.max = props.max;
  }
  return Object.keys(rules).length > 0 ? rules : null;
};
```

### 5. **View Container Component**

```typescript
// shared/src/components/view-container.tsx
import React, { useState, useEffect } from 'react';
import { ViewProcessorService } from '../lib/view-processor.service';
import { DynamicViewRenderer } from './dynamic-view-renderer';
import { LoadingSpinner } from './loading-spinner';

interface ViewContainerProps {
  viewId?: string;
  model?: string;
  viewType?: string;
  recordId?: string;
}

export const ViewContainer: React.FC<ViewContainerProps> = ({
  viewId,
  model,
  viewType,
  recordId
}) => {
  const [viewData, setViewData] = useState(null);
  const [records, setRecords] = useState([]);
  const [record, setRecord] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const viewProcessorService = new ViewProcessorService(/* inject HttpClient */);

  useEffect(() => {
    loadViewData();
  }, [viewId]);

  const loadViewData = async () => {
    if (!viewId) return;

    try {
      setLoading(true);

      // Carregar configuração da view
      const viewResponse = await viewProcessorService.renderView(viewId);
      setViewData(viewResponse);

      // Carregar dados baseado no tipo
      if (viewResponse.viewType === 'tree') {
        // Carregar lista de registros
        const recordsResponse = await fetch(`/api/services/core/${viewResponse.model}/search_read`);
        const recordsData = await recordsResponse.json();
        setRecords(recordsData.result || []);
      } else if (viewResponse.viewType === 'form' && recordId) {
        // Carregar registro específico
        const recordResponse = await fetch(`/api/services/core/${viewResponse.model}/read/${recordId}`);
        const recordData = await recordResponse.json();
        setRecord(recordData.result || {});
      }

    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDataChange = async (newData: any) => {
    if (recordId) {
      // Atualizar registro existente
      try {
        await fetch(`/api/services/core/${viewData.model}/write/${recordId}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ data: newData })
        });
        setRecord(newData);
      } catch (err) {
        setError(err.message);
      }
    }
  };

  const handleRecordSelect = (selectedRecord: any) => {
    // Navegar para view de formulário
    window.location.href = `#/app/${viewData.model}/form/${selectedRecord.id}`;
  };

  if (loading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return (
      <div className="alert alert-danger">
        Error loading view: {error}
      </div>
    );
  }

  if (!viewData) {
    return (
      <div className="alert alert-warning">
        No view data available
      </div>
    );
  }

  return (
    <div className="view-container">
      <DynamicViewRenderer
        viewData={viewData}
        record={record}
        records={records}
        onDataChange={handleDataChange}
      />
    </div>
  );
};
```

---

## 🔌 Integração com ABP Framework

### 1. **Module Configuration**

```typescript
// shared/src/bamboo-view-processor.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ViewProcessorService } from './lib/view-processor.service';
import { DynamicViewRenderer } from './components/dynamic-view-renderer';
import { ViewContainer } from './components/view-container';

@NgModule({
  declarations: [
    DynamicViewRenderer,
    ViewContainer
  ],
  imports: [
    CommonModule
  ],
  providers: [
    ViewProcessorService
  ],
  exports: [
    DynamicViewRenderer,
    ViewContainer
  ]
})
export class BambooViewProcessorModule {}
```

### 2. **ABP Service Registration**

```csharp
// services/core/src/Bamboo.Core.Application/BambooCoreApplicationModule.cs
using Bamboo.Core.Application.Views;

namespace Bamboo.Core.Application
{
    [DependsOn(
        typeof(BambooCoreDomainModule),
        typeof(AbpAutoMapperModule)
    )]
    public class BambooCoreApplicationModule : AbpModule
    {
        public override void ConfigureServices(ServiceConfigurationContext context)
        {
            // ... outros serviços

            // Registrar View Processor
            context.Services.AddTransient<IViewProcessorAppService, ViewProcessorAppService>();
        }
    }
}
```

### 3. **Routing Integration**

```typescript
// apps/bamboo-web/src/app/app-routing.module.ts
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { ViewContainer } from '@shared/view-processor/view-container';

const routes: Routes = [
  {
    path: '',
    children: [
      {
        path: 'app/:model',
        children: [
          {
            path: 'tree',
            component: ViewContainer,
            data: { viewType: 'tree' }
          },
          {
            path: 'form/:id',
            component: ViewContainer,
            data: { viewType: 'form' }
          },
          {
            path: 'kanban',
            component: ViewContainer,
            data: { viewType: 'kanban' }
          }
        ]
      }
    ]
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
```

---

## 📋 Estrutura de Arquivos

```
shared/
├── src/
│   ├── lib/
│   │   ├── view-processor.service.ts
│   │   ├── view-processor.types.ts
│   │   └── field-mappers.ts
│   ├── components/
│   │   ├── dynamic-view-renderer.tsx
│   │   ├── view-container.tsx
│   │   ├── loading-spinner.tsx
│   │   └── views/
│   │       ├── odoo-form.tsx
│   │       ├── odoo-tree.tsx
│   │       ├── odoo-kanban.tsx
│   │       ├── odoo-calendar.tsx
│   │       ├── odoo-search.tsx
│   │       ├── odoo-graph.tsx
│   │       └── odoo-pivot.tsx
│   └── bamboo-view-processor.module.ts

services/core/src/Bamboo.Core.Application/
├── Views/
│   ├── ViewProcessorAppService.cs
│   ├── IViewProcessorAppService.cs
│   ├── ViewProcessorController.cs
│   └── Dtos/
│       ├── ViewProcessorDto.cs
│       ├── ComponentMapDto.cs
│       └── ParsedViewDto.cs
```

---

## 🎯 Exemplo de Uso Completo

### **Menu Navigation → View Rendering:**

1. **Usuário clica no menu "Sales → Orders"**
2. **Router naviga para**: `/app/sale.order/tree`
3. **ViewContainer component**:
   - Busca view ID do menu via API
   - Carrega configuração da view com ViewProcessorService
   - Renderiza DynamicViewRenderer com OdooTree
   - Carrega registros via API genérica
4. **OdooTree component**:
   - Renderiza Syncfusion Grid com colunas mapeadas
   - Habilita sorting, filtering, paging
   - Permite double-click para editar
5. **Usuário double-click um registro**:
   - Router naviga para: `/app/sale.order/form/{id}`
   - ViewContainer renderiza OdooForm
   - Form renderizado com campos Syncfusion
   - Save action via API genérica

---

## 📈 Considerações de Performance

### **1. View Caching:**
```typescript
// Cache de configurações de views
const viewCache = new Map<string, ViewProcessorResult>();

export const getCachedView = async (viewId: string): Promise<ViewProcessorResult> => {
  if (viewCache.has(viewId)) {
    return viewCache.get(viewId)!;
  }

  const viewData = await viewProcessorService.renderView(viewId);
  viewCache.set(viewId, viewData);
  return viewData;
};
```

### **2. Lazy Loading:**
```typescript
// Carregar views sob demanda
const viewRoutes = {
  'sale.order': () => import('./views/sale-order'),
  'res.partner': () => import('./views/res-partner'),
  // ...
};
```

### **3. Virtual Scrolling:**
```tsx
// Para grandes datasets
<GridComponent
  enableVirtualization={true}
  height={400}
/>
```

---

## 🎨 Temas e Customização

### **Brand Integration:**
```scss
// Tema Bamboo para Syncfusion
.bamboo-theme {
  .e-grid .e-headercell {
    background-color: #2e7d32;
    color: white;
  }

  .e-form-container {
    .e-control {
      border-color: #2e7d32;
    }
  }
}
```

---

## 💡 Conclusão

O View-Processor é o **componente fundamental** que conecta a infraestrutura de backend do Bamboo ERP (com as views XML do Odoo) com uma interface moderna usando Syncfusion React components.

### **✅ Benefícios:**
- **Aproveita Investimento Existente**: Usa as 500+ entidades e views XML já implementadas
- **Rapidez de Desenvolvimento**: 2-3 meses vs 6-12 meses do zero
- **Qualidade Enterprise**: Components Syncfusion testados e performáticos
- **Flexibilidade**: Sistema de mapeamento extensível para novos components
- **Manutenibilidade**: Separação clara entre backend (C#) e frontend (React)

### **🚀 Próximos Passos:**
1. Implementar backend C# ViewProcessorAppService
2. Criar frontend TypeScript service
3. Desenvolver component mapper
4. Implementar views básicas (form, tree, kanban)
5. Extender para views avançadas (calendar, graphs, pivot)
6. Integrar com sistema de menus e navegação
7. Performance optimization e testing

Com esta implementação, o Bamboo ERP terá uma interface **completa, moderna e funcional** que rivaliza com o Odoo original, mantendo toda a robustez do backend ABP Framework já implementado.