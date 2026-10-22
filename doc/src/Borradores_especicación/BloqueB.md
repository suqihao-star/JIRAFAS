# Bloque B. Suscripciones, tarifas y descuentos

## CU-01 - Gestionar baja y pausa de suscripción

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-01 |
| Nombre | Gestionar baja y pausa de suscripción |
| Objetivo | Permitir al usuario operativo gestionar la baja o pausa de una suscripción del cliente para dejarla en el estado correcto y evitar cobros o servicios inconsistentes. |
| Actores participantes | Usuario operativo, Planificador del sistema |

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso para gestionar suscripciones.
- PRE-2. Existe una suscripción activa o en pausa asociada a un cliente.

### 3. Flujo principal

1. Actor: El Usuario operativo accede a la suscripción del cliente y selecciona "Gestionar baja o pausa".
2. Sistema: El sistema muestra el estado actual de la suscripción, las condiciones vigentes y las opciones disponibles.
3. Actor: El Usuario operativo indica si la suscripción se pausa o se da de baja, con la fecha de efecto y, si procede, la causa.
4. Sistema: El sistema valida la operación, comprueba que no exista una inconsistencia con la facturación y guarda el cambio.
5. Sistema: El sistema actualiza el estado de la suscripción, registra la operación en la línea temporal y notifica al responsable interno del cliente cuando corresponda.

### 4. Flujos alternativos

#### FA-1. Pausar suscripción

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario selecciona pausar la suscripción en lugar de darla de baja.

1. El usuario indica una pausa temporal con fecha de reactivación.
2. El sistema guarda el estado "en pausa" y conserva la configuración de la suscripción.
3. El sistema evita facturar mientras esté en pausa, salvo acuerdo explícito.

**Resultado:** Suscripción pausada y mantenida para reactivación posterior.

#### FA-2. Dar de baja una suscripción

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario confirma la baja definitiva.

1. El usuario indica la fecha de baja efectiva y la causa del cierre.
2. El sistema marca la suscripción como cancelada y calcula el cierre de servicios y facturación pendiente.
3. El sistema registra el cierre y elimina cualquier tarea pendiente asociada que ya no proceda.

**Resultado:** Suscripción dada de baja y cerrada correctamente.

### 5. Flujos de excepción

#### FE-1. Fecha de baja o pausa inválida

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La fecha indicada no es válida o cae en un periodo no permitido.

1. El sistema detecta la fecha no válida.
2. El sistema informa al usuario del error y bloquea la confirmación hasta corregirla.

**Resultado:** El usuario corrige la fecha antes de guardar la operación.

#### FE-2. Suscripción no asignada

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta gestionar una suscripción que no tiene asignada.

1. El sistema verifica el permiso sobre la suscripción.
2. El sistema rechaza la operación y informa de que no está autorizada.

**Resultado:** Acceso denegado a la gestión de la suscripción.

### Postcondiciones

- POST-1. La suscripción queda en el estado correcto (activa, en pausa o cancelada).
- POST-2. La línea temporal del cliente refleja la operación realizada.
- POST-3. El sistema ajusta la facturación y los servicios asociados al nuevo estado.
- POST-4. La acción queda registrada en el registro de auditoría.

---

## CU-02 - Revisar y aprobar rango de tarifa anual

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-02 |
| Nombre | Revisar y aprobar rango de tarifa anual |
| Objetivo | Permitir al Administrador revisar y aprobar el rango de tarifa anual asociado a un cliente o servicio, evitando cambios no controlados en la facturación. |
| Actores participantes | Administrador |

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol de Administrador.
- PRE-2. Existe un rango de tarifa anual pendiente de revisión.

### 3. Flujo principal

1. Actor: El Administrador accede a la revisión de tarifas anuales pendientes.
2. Sistema: El sistema muestra el rango propuesto, su historial y el contexto del cliente o servicio.
3. Actor: El Administrador revisa la información y decide aprobarla.
4. Sistema: El sistema valida la decisión, guarda la aprobación y registra la operación.
5. Sistema: El sistema aplica el rango aprobado a la facturación y deja constancia del cambio en la ficha del cliente.

### 4. Flujos alternativos

#### FA-1. Rechazar rango de tarifa anual

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador decide rechazar el rango propuesto.

1. El Administrador marca el rango como rechazado y añade, si procede, el motivo.
2. El sistema guarda el rechazo y conserva la versión anterior vigente.
3. El sistema notifica al responsable que debe corregir o volver a proponer el rango.

**Resultado:** Rango no aprobado y no aplicado a la facturación vigente.

#### FA-2. Revisión con valor límite

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El rango propuesto está próximo a un límite configurable.

1. El sistema marca la revisión como de atención especial.
2. El Administrador puede aprobarlo, rechazarlo o exigir una revisión adicional.

**Resultado:** El rango queda con un nivel de validación acorde al riesgo o impacto asociado.

### 5. Flujos de excepción

#### FE-1. Rango sin información suficiente

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La propuesta de tarifa anual no incluye datos necesarios para su aprobación.

1. El sistema detecta la falta de información requerida.
2. El sistema bloquea la aprobación y señala qué falta completar.

**Resultado:** El Administrador no puede aprobar un rango incompleto.

#### FE-2. Cambio concurrente

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Otro usuario ha actualizado el rango mientras se estaba revisando.

1. El sistema detecta el conflicto de concurrencia.
2. El sistema muestra la versión actual y evita sobrescribir cambios ajenos.

**Resultado:** Se conserva la integridad de la información y se informa del conflicto.

### Postcondiciones

- POST-1. El rango de tarifa anual queda aprobado o rechazado.
- POST-2. La facturación utiliza el rango vigente correspondiente.
- POST-3. La decisión queda registrada en la auditoría y la línea temporal del cliente.

---

## CU-03 - Solicitar descuento

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-03 |
| Nombre | Solicitar descuento |
| Objetivo | Permitir al usuario operativo solicitar un descuento para un cliente o suscripción, dejando la petición registrada para revisión y aprobación. |
| Actores participantes | Usuario operativo |

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso para gestionar descuentos.
- PRE-2. Existe un cliente o una suscripción asociada al que se le quiere aplicar un descuento.

### 3. Flujo principal

1. Actor: El Usuario operativo accede al cliente o la suscripción y selecciona "Solicitar descuento".
2. Sistema: El sistema muestra el formulario de solicitud con los datos relevantes del cliente, el importe y la justificación.
3. Actor: El Usuario operativo introduce el tipo de descuento, el porcentaje o importe, el motivo y la fecha de vigencia.
4. Sistema: El sistema valida la información y registra la solicitud en estado "pendiente de aprobación".
5. Sistema: El sistema muestra la solicitud en la lista de pendientes y la asocia al responsable de aprobación.

### 4. Flujos alternativos

#### FA-1. Descuento con revisión especial

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La solicitud supera el umbral configurable o requiere validación adicional.

1. El usuario completa la solicitud con el descuento relevante.
2. El sistema marca la solicitud como "requiere revisión especial".
3. La solicitud se reenvía al responsable con nivel de aprobación superior.

**Resultado:** La petición queda en cola de revisión reforzada.

#### FA-2. Solicitud anulada antes de confirmar

**Se produce en:** cualquier momento antes del paso 4 del flujo principal.  
**Condición:** El usuario decide cancelar la solicitud.

1. El usuario cancela la operación desde el formulario.
2. El sistema descarta la solicitud sin guardar cambios.

**Resultado:** Solicitud no registrada.

### 5. Flujos de excepción

#### FE-1. Datos incompletos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La solicitud carece de información obligatoria o contiene un valor no válido.

1. El sistema detecta los campos vacíos o incorrectos.
2. El sistema informa al usuario y bloquea el envío hasta corregirlos.

**Resultado:** La solicitud no se registra hasta completar la información.

#### FE-2. Cliente no asignado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta solicitar un descuento para un cliente sin permisos sobre él.

1. El sistema comprueba la asignación del cliente.
2. El sistema rechaza la solicitud y muestra un aviso de acceso restringido.

**Resultado:** Solicitud no autorizada.

### Postcondiciones

- POST-1. La solicitud queda registrada con su estado inicial pendiente de aprobación.
- POST-2. La línea temporal del cliente refleja la petición de descuento.
- POST-3. El responsable autorizado puede revisar y decidir sobre la solicitud.

---

## CU-04 - Aprobar descuento

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-04 |
| Nombre | Aprobar descuento |
| Objetivo | Permitir al Administrador aprobar o rechazar una solicitud de descuento para que el beneficio se aplique o no en la facturación del cliente. |
| Actores participantes | Administrador |

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol de Administrador.
- PRE-2. Existe una solicitud de descuento pendiente de aprobación.

### 3. Flujo principal

1. Actor: El Administrador accede a la bandeja de solicitudes de descuento pendientes.
2. Sistema: El sistema muestra el detalle de la solicitud, el cliente, el importe y la justificación.
3. Actor: El Administrador revisa la solicitud y decide aprobarla.
4. Sistema: El sistema valida la decisión, aplica el descuento aprobado y registra la operación.
5. Sistema: El sistema notifica al usuario operativo y actualiza la factura o la configuración de precios asociada.

### 4. Flujos alternativos

#### FA-1. Rechazar descuento

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador decide rechazar la solicitud.

1. El Administrador indica el motivo del rechazo.
2. El sistema guarda la decisión y la solicitud queda rechazada.
3. El sistema notifica al usuario operativo para que corrija o reenvíe la petición.

**Resultado:** Descuento no concedido y solicitud rechazada.

#### FA-2. Aplicación condicionada

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La aprobación requiere que se cumpla una condición adicional de negocio.

1. El sistema marca la aprobación como condicionada.
2. El descuento solo se aplica cuando se cumpla dicha condición.
3. La aprobación queda visible en la línea temporal con la condición asociada.

**Resultado:** Descuento aprobado con condiciones de aplicación.

### 5. Flujos de excepción

#### FE-1. Solicitud ya resuelta

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La solicitud de descuento fue modificada o resuelta por otra persona antes de la revisión.

1. El sistema comprueba el estado actual de la solicitud.
2. El sistema informa del cambio previo y bloquea la aprobación duplicada.

**Resultado:** Se evita la doble resolución de la misma solicitud.

#### FE-2. Descuento fuera de rango

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El descuento solicitado supera el rango permitido por la política de la empresa.

1. El sistema valida el importe o porcentaje solicitado.
2. El sistema rechaza la aprobación y propone su escalado o revisión por un nivel superior.

**Resultado:** Descuento no aprobado por limitación de política.

### Postcondiciones

- POST-1. La solicitud queda aprobada o rechazada con su justificación.
- POST-2. La facturación o la tarifa aplicable se actualiza según el resultado.
- POST-3. La operación queda registrada en auditoría y en la línea temporal del cliente.

---

## CU-05 - Escalar aprobación al Superadministrador

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-05 |
| Nombre | Escalar aprobación al Superadministrador |
| Objetivo | Permitir que una solicitud de descuento que excede el umbral configurado pase a revisión del Superadministrador para su aprobación final. |
| Actores participantes | Superadministrador |

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol de Superadministrador.
- PRE-2. Existe una solicitud de descuento que supera el umbral configurado.

### 3. Flujo principal

1. Actor: El Superadministrador accede a la solicitud escalada.
2. Sistema: El sistema muestra la información completa de la solicitud, el importe solicitado y el motivo del escalado.
3. Actor: El Superadministrador revisa la solicitud y decide aprobarla o rechazarla.
4. Sistema: El sistema registra la decisión final y la aplica a la facturación o la deja sin efecto.
5. Sistema: El sistema notifica a la persona que originó la solicitud y deja constancia del resultado en la auditoría.

### 4. Flujos alternativos

#### FA-1. Descuento escalado para revisión final

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La solicitud requiere revisión final por elevación de nivel.

1. El sistema marca la solicitud como escalada y la muestra junto con el historial de decisiones previas.
2. El Superadministrador toma la decisión final con la misma información y contexto.

**Resultado:** La solicitud queda resuelta con la autoridad máxima del proceso.

#### FA-2. Escalado rechazado

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador decide no aprobar el descuento.

1. El sistema guarda la decisión y la justificación.
2. La solicitud queda cerrada con rechazo final y se notifica al usuario operativo.

**Resultado:** El descuento no se aplica por decisión final del nivel superior.

### 5. Flujos de excepción

#### FE-1. Solicitud ya resuelta

**Se produce en:** paso 1 del flujo principal.  
**Condición:** La solicitud escalada ya ha sido resuelta por otra persona.

1. El sistema detecta el cambio de estado.
2. El sistema informa del conflicto y bloquea la resolución duplicada.

**Resultado:** Se evita la doble aprobación o rechazo del mismo descuento.

#### FE-2. Escalado sin autorización

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un usuario sin permisos de Superadministrador intenta acceder a la solicitud escalada.

1. El sistema comprueba el rol del usuario.
2. El sistema rechaza el acceso y muestra la restricción de autorización.

**Resultado:** El caso de uso queda restringido al nivel de aprobación requerido.

### Postcondiciones

- POST-1. La solicitud queda resuelta por el nivel de aprobación superior.
- POST-2. El descuento queda aplicado o rechazado según la decisión final.
- POST-3. La resolución queda registrada en auditoría con el responsable y la fecha.
