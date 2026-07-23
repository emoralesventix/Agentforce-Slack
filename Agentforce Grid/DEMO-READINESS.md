# Agentforce Grid - Demo Readiness

## Org validada

- Alias: `Agentforce Org`
- Usuario: `emorales@agentforce.com`
- Edicion: Developer Edition
- API: 67.0
- Permission set: `Agentforce_Grid_Demo_Manager`
- Permiso efectivo `Manage Agentforce Grids`: habilitado y verificado
- Dataset: 15 Accounts sinteticas con prefijo `AF Grid Demo`
- Los registros se crean sin `Description` ni `Rating` para que el efecto de la demo sea visible.

## Correcciones necesarias al material original

1. Usar **Create Grid**, no **New Workbook**, de acuerdo con la UI documentada actualmente.
2. `Account.Description` es Long Text Area y no es filtrable. El SOQL `WHERE Description = null` falla.
3. `Account.Rating` solo admite `Hot`, `Warm` y `Cold`. No intentar guardar `HIGH`, `MEDIUM` o `LOW` directamente.
4. Grid permite exportar la worksheet desde el menu de opciones; la respuesta de FAQ que dice que no se puede exportar esta desactualizada.

## Query valida para la demo

```sql
SELECT Id, Name, Industry, AnnualRevenue,
       NumberOfEmployees, Website, BillingCity, Description, Rating
FROM Account
WHERE Name LIKE 'AF Grid Demo %'
ORDER BY Name
LIMIT 15
```

El prefijo aísla exactamente los registros sinteticos de la demo y permite limpiarlos despues.

## Columna AI: Summary

```text
Genera un resumen ejecutivo de 2 o 3 oraciones para esta cuenta de Salesforce.

Nombre: {{ ref('Demo Accounts', 'Name') }}
Industria: {{ ref('Demo Accounts', 'Industry') }}
Revenue anual: {{ ref('Demo Accounts', 'AnnualRevenue') }}
Empleados: {{ ref('Demo Accounts', 'NumberOfEmployees') }}
Ciudad: {{ ref('Demo Accounts', 'BillingCity') }}

El resumen debe ser profesional, mencionar los datos relevantes sin inventar
informacion y destacar el potencial comercial.
```

Formato de respuesta: texto.

## Columna AI: Classification

```text
Clasifica el potencial comercial de la cuenta usando estas reglas:

- HIGH: AnnualRevenue mayor a 5000000
- MEDIUM: AnnualRevenue entre 1000000 y 5000000, ambos inclusive
- LOW: AnnualRevenue menor a 1000000

AnnualRevenue: {{ ref('Demo Accounts', 'AnnualRevenue') }}
Resumen: {{ ref('AI - Account Summary', '') }}

Responde solamente con HIGH, MEDIUM o LOW.
```

Para referenciar directamente un campo de una columna Object usar
`{{ ref('Demo Accounts', 'AnnualRevenue') }}`. Para referenciar el resultado
completo de otra columna usar `{{ ref('AI - Account Summary', '') }}`. No hacen
falta columnas Reference auxiliares.

## Columna Action: Update Record

- Tipo de columna: `Action`
- Nombre interno v67: `RecordUpdateAction`
- Columna fuente: `Demo Accounts`
- Objeto: `Account`
- Actualizar: `Description = {{ ref('AI - Account Summary', '') }}`
- No actualizar `Rating` con `{{ ref('AI - Classification', '') }}`.

Opcionalmente se puede agregar una columna intermedia que convierta `HIGH/MEDIUM/LOW` en `Hot/Warm/Cold`, y recien entonces escribir `Rating`.

## Columna AI: Outreach Email

La comparación textual directa contra el SINGLE_SELECT no fue confiable por API en esta org. Para una ejecución demostrablemente acotada, guardar primero la columna sin reprocesar y ejecutar sólo las celdas HIGH con:

```json
{
  "trigger": "RUN_SELECTION",
  "seedCellIds": ["cell-id-high-1", "cell-id-high-2"]
}
```

Endpoint: `POST /worksheets/{worksheetId}/trigger-row-execution`. Usar los IDs de celda de `AI - Outreach Email`, no los row IDs. En la demo validada quedaron 5 celdas `Complete` y 10 `Stale`, sin ejecutar estas últimas.

Prompt:

```text
Redacta un email corto de prospeccion para {{ ref('Demo Accounts', 'Name') }}
basandote en este contexto:
{{ ref('AI - Account Summary', '') }}

Debe ser profesional pero directo, tener un maximo de 4 oraciones y terminar
con un call to action claro. No inventes nombres de personas ni datos de contacto.
```

## Smoke test antes de presentar

1. Abrir Agentforce Grid desde App Launcher.
2. Crear el Grid `Account Enrichment Demo`.
3. Cargar la query valida y comprobar que devuelve 15 filas.
4. Ejecutar `Summary` sobre una sola fila y revisar el detalle de la celda.
5. Ejecutar `Classification` sobre esa misma fila.
6. Ejecutar `Update Record` sobre esa fila y verificar `Description` en Account.
7. Ejecutar `Outreach Email` sobre una fila HIGH y otra LOW para probar la condicion.
8. Revisar el estimado de consumo antes de seleccionar todas las filas.

## Estado validado de la demo

- Grid: `TEST EM`
- Worksheet: `Demo - Account Enrichment`
- 15 resúmenes completos.
- Clasificación corregida y consistente: 5 HIGH, 5 MEDIUM y 5 LOW.
- 15 `Account.Description` actualizadas por `Update Record`.
- `Account.Rating` no fue modificado.
- 5 emails de outreach generados mediante `RUN_SELECTION`; las otras 10 celdas permanecen `Stale`.

## Verificacion por CLI

```powershell
sf data query --target-org "Agentforce Org" --query "SELECT Id, Name, Industry, AnnualRevenue, NumberOfEmployees, BillingCity, Description, Rating FROM Account WHERE Name LIKE 'AF Grid Demo %' ORDER BY Name" --json
```

## Limpieza despues de la demo

Primero previsualizar siempre el alcance:

```powershell
sf data query --target-org "Agentforce Org" --query "SELECT Id, Name FROM Account WHERE Name LIKE 'AF Grid Demo %' ORDER BY Name" --json
```

Luego borrar unicamente los IDs creados, que quedaron guardados en
`agentforce-grid-demo-created-ids.csv`:

```powershell
sf data delete bulk --target-org "Agentforce Org" --sobject Account --file "Agentforce Grid/agentforce-grid-demo-created-ids.csv" --wait 10 --json
```

No ejecutar una eliminacion por patron sin revisar primero el resultado. Para
volver a sembrar los datos despues de limpiarlos:

```powershell
sf data import tree --target-org "Agentforce Org" --files "Agentforce Grid/agentforce-grid-demo-accounts.json" --json
```

Si se vuelven a crear, reemplazar el CSV de limpieza con los nuevos IDs que
devuelva la importacion.

## Documentacion oficial consultada

- Create a Grid Worksheet: https://help.salesforce.com/s/articleView?id=ai.agentforce_grid_create_worksheet.htm&language=en_US&type=5
- Trailhead - Agentforce Grid: https://trailhead.salesforce.com/content/learn/modules/agentforce-grid
