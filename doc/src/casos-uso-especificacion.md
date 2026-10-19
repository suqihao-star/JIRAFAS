# Especificación de casos de uso

Este documento sirve como plantilla para describir cada caso de uso representado en el diagrama. La estructura está pensada para cumplir con la pauta de la asignatura y facilitar que todas las especificaciones mantengan el mismo formato.

## Plantilla general

> Rellena una ficha por cada caso de uso del sistema.

### CU-XX - [Nombre del caso de uso]

| Campo | Contenido |
|---|---|
| Identificador | CU-XX |
| Nombre | [Nombre descriptivo del caso de uso] |
| Objetivo | [Qué persigue el caso de uso y qué necesidad cubre] |
| Actor principal | [Actor que inicia el caso de uso] |
| Actores secundarios | [Otros actores o sistemas que intervienen, si aplica] |

### Precondiciones

- [Condición previa 1]
- [Condición previa 2]

### Flujo principal

1. [El actor inicia la interacción con el sistema]
2. [El sistema solicita o muestra la información necesaria]
3. [El actor introduce o selecciona los datos requeridos]
4. [El sistema valida la información]
5. [El sistema ejecuta la acción principal]
6. [El sistema confirma el resultado]

### Flujos alternativos

#### A1. [Nombre del flujo alternativo]

1. [Paso en el que se desvía del flujo principal]
2. [Descripción de la alternativa]
3. [Resultado de la alternativa]

#### A2. [Nombre del flujo alternativo]

1. [Paso en el que se desvía del flujo principal]
2. [Descripción de la alternativa]
3. [Resultado de la alternativa]

### Flujos de excepción

#### E1. [Nombre de la excepción]

1. [Situación que provoca la excepción]
2. [Respuesta del sistema]
3. [Acción que puede realizar el actor, si aplica]

#### E2. [Nombre de la excepción]

1. [Situación que provoca la excepción]
2. [Respuesta del sistema]
3. [Acción que puede realizar el actor, si aplica]

### Postcondiciones

- [Estado del sistema al finalizar el caso de uso]
- [Datos creados, modificados o persistidos]
- [Efectos visibles para el actor o para otros sistemas]

## Recomendaciones de uso

- Usa un identificador único y estable para cada caso de uso, por ejemplo, CU-01, CU-02, etc.
- El nombre debe ser breve y orientado a la acción, por ejemplo: "Registrar factura" o "Consultar estado de factura".
- El objetivo debe expresar la finalidad del caso de uso, no su implementación.
- El flujo principal debe describir la secuencia normal, sin incluir errores ni variantes.
- Los flujos alternativos recogen caminos válidos que no rompen el objetivo principal.
- Los flujos de excepción recogen errores, validaciones fallidas o condiciones que impiden completar el caso de uso.
- Las postcondiciones deben indicar el estado final relevante del sistema.

## Ejemplo de estructura mínima

### CU-01 - [Nombre del caso de uso]

| Campo | Contenido |
|---|---|
| Identificador | CU-01 |
| Nombre | [Nombre del caso de uso] |
| Objetivo | [Objetivo del caso de uso] |
| Actor principal | [Actor principal] |
| Actores secundarios | [Actores secundarios, si existen] |

### Precondiciones

- [Precondición]

### Flujo principal

1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

### Flujos alternativos

- [Flujo alternativo, si aplica]

### Flujos de excepción

- [Excepción, si aplica]

### Postcondiciones

- [Postcondición]
