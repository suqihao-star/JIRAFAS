# Bloque A. Clientes y contactos

## CU-01 - Gestionar cliente y contactos

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-01 |
| Nombre | Gestionar cliente y contactos |
| Objetivo | Dar de alta y mantener la ficha comercial y fiscal de un cliente y sus contactos, para poder asociarle suscripciones y facturarle. |
| Actores participantes | Usuario operativo |

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso sobre la gestión de clientes.
- PRE-2. Para editar un cliente existente, este debe estar asignado al usuario (o el usuario ser Administrador o superior).

### 3. Flujo principal

1. Actor: El Usuario operativo selecciona "Añadir cliente" en el módulo de clientes.
2. Sistema: El sistema muestra el formulario de alta, autocompletando los campos recurrentes (país, moneda, vencimiento, tarifa) cuando es posible.
3. Actor: El Usuario operativo introduce los datos fiscales (nombre comercial, razón social, NIF o identificador fiscal, domicilio fiscal, país, moneda de trabajo) y la ficha comercial (fecha de inicio, plan o servicio, tarifa acordada, responsable interno, condiciones de pago y, si existe, documento firmado fuera de la plataforma).
4. Sistema: El sistema valida el formato de los datos, comprueba posibles duplicados y, si el alta es a mitad de mes, muestra el cálculo del prorrateo de la primera factura antes de confirmar. En caso de no haber error, se guarda el cliente y sus contactos, se registra el alta y se confirma la operación. El sistema muestra el cliente creado.

### 4. Flujos alternativos

#### FA-1. Editar un cliente existente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona editar cliente.

1. En el paso 1, el Usuario operativo abre la ficha de un cliente asignado y selecciona "Editar".
2. El sistema muestra los datos actuales modificables.
3. El usuario los modifica y confirma los cambios.
4. El sistema valida y guarda los cambios, y los registra en la línea temporal.

**Resultado:** Cliente existente editado.

#### FA-2. Gestionar contactos

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona gestionar contactos.

1. Desde la ficha, el usuario añade, modifica o marca como inactivo un contacto.
2. El sistema permite que un contacto pertenezca a varios clientes.
3. Al marcar un contacto como inactivo, el sistema conserva su histórico y los destinatarios de las facturas ya enviadas.

**Resultado:** Contactos modificados de los clientes.

#### FA-3. Etiquetar y marcar como favorito

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona "añadir etiqueta" o marcar como favorito.

1. El usuario asigna etiquetas al cliente (por ejemplo: estratégico, beta, partner, riesgo de cobro), además del sector y la ubicación, o lo marca como favorito.
2. El sistema guarda la clasificación. El acceso rápido por favoritos no sustituye la comprobación de permisos.

**Resultado:** Clientes etiquetados y marcados en el sistema.

#### FA-4. Excepción comercial explícita

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario selecciona una excepción comercial.

1. El usuario registra una excepción comercial: primer mes gratuito, inicio futuro u otra excepción.
2. El sistema guarda la excepción de forma explícita en la ficha del cliente. Si tiene efecto económico (primer mes gratuito o facturación sin prorrateo), queda pendiente de aprobación (CU-07 y CU-08) y no se aplica en la facturación hasta ser aprobada.
3. Si es un inicio futuro, el sistema deja al cliente en estado "pendiente de activación": no genera facturas ni recordatorios hasta esa fecha.

**Resultado:** Clientes registrados con excepciones comerciales.

#### FA-5. Datos fiscales aún no disponibles

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario no dispone todavía del identificador fiscal.

1. El sistema permite guardar el cliente, lo marca con "datos fiscales incompletos" e indica qué falta.

**Resultado:** El sistema no podrá emitir facturas hasta que se completen los datos fiscales faltantes.

### 5. Flujos de excepción

#### FE-1. Posible cliente duplicado

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El sistema detecta datos duplicados en la introducción de datos.

1. El sistema avisa al usuario y ofrece abrir la ficha existente, sin fusionar nada, además de modificar la ficha actual para corregir un posible error.

**Resultado:** El usuario decide entre modificar la actual o la existente.

#### FE-2. Datos obligatorios o formato inválido

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El sistema detecta datos malformateados en la introducción de datos.

1. El sistema detecta datos malformateados y señala los campos a corregir.

**Resultado:** El usuario puede corregir los datos antes de completar la ficha.

#### FE-3. Cliente no asignado

**Se produce en:** FA-1 o FA-2.  
**Condición:** El usuario intenta acceder a un cliente que no tiene asignado.

1. En FA-1 o FA-2, el usuario intenta acceder a un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor) e informa de que el cliente no está asignado al usuario.

**Resultado:** Acceso denegado.

### Postcondiciones

- POST-1. El cliente y sus contactos quedan registrados con su responsable interno y su clasificación.
- POST-2. La línea temporal del cliente refleja el alta o la modificación.
- POST-3. El cliente queda "activo" (o "pendiente de activación" si tiene inicio futuro) y es elegible para suscripciones y facturación.
- POST-4. La acción queda registrada en el registro de auditoría.

---

## CU-03 - Importar datos por CSV

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-02 |
| Nombre | Importar datos por CSV |
| Objetivo | Cargar de forma masiva clientes (y opcionalmente facturas históricas) desde un archivo CSV, controlando errores antes de confirmar. |
| Actores participantes | Usuario operativo |

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso de importación.
- PRE-2. El usuario dispone de un archivo CSV con el formato esperado.

### 3. Flujo principal

1. Actor: El Usuario operativo selecciona "Importar CSV" y sube el archivo.
2. Sistema: El sistema valida la estructura (columnas y codificación) y analiza cada fila.
3. Sistema: El sistema comprueba posibles duplicados por identificador fiscal y marca las coincidencias para revisión del usuario.
4. Sistema: El sistema muestra una previsualización con filas válidas, filas con error (y su motivo) y posibles duplicados.
5. Actor: El Usuario operativo corrige los errores o excluye las filas problemáticas.
6. Sistema: El sistema indica el número exacto de registros que se van a crear o actualizar y solicita confirmación.
7. Actor: El Usuario operativo confirma la operación.
8. Sistema: El sistema crea los clientes nuevos y actualiza únicamente aquellos que el usuario marcó explícitamente como actualización de un cliente existente.
9. Sistema: El sistema muestra un resumen con registros creados, actualizados y rechazados, con sus motivos, y registra la operación.

### 4. Flujos alternativos

#### FA-1. Importar facturas históricas

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario indica que el archivo CSV incluye facturas históricas.

1. En el paso 1, el usuario indica que el archivo incluye facturas históricas.
2. El sistema las importa marcadas como "migradas", con su número y documento original, y sin enviar ninguna notificación al cliente.

**Resultado:** Facturas históricas importadas y marcadas como migradas.

#### FA-2. Cancelar antes de confirmar

**Se produce en:** cualquier momento anterior al paso 7 del flujo principal.  
**Condición:** El usuario decide cancelar el proceso de importación.

1. En cualquier momento anterior al paso 7, el usuario cancela.
2. El sistema descarta la carga sin modificar datos.

**Resultado:** Importación cancelada sin alterar los datos existentes.

#### FA-3. Filas sin identificador fiscal

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Una o varias filas no incluyen identificador fiscal.

1. En el paso 3, una fila no incluye identificador fiscal.
2. El sistema no puede comprobar duplicados en esa fila y la marca como "datos fiscales incompletos" en la previsualización, permitiendo importarla.
3. Esa fila no podrá facturarse hasta completar los datos.

**Resultado:** Fila importada y marcada con datos fiscales incompletos.

### 5. Flujos de excepción

#### FE-1. Archivo inválido

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El archivo no es un CSV válido o faltan columnas obligatorias.

1. En el paso 2, el archivo no es un CSV válido o faltan columnas obligatorias.
2. El sistema rechaza la carga e indica qué falta.
3. El usuario corrige el archivo y vuelve a subirlo.

**Resultado:** Carga rechazada hasta que se corrija la estructura del archivo.

#### FE-2. Todas las filas rechazadas

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Ninguna fila del archivo resulta válida tras la comprobación.

1. En el paso 4, ninguna fila es válida.
2. El sistema no permite confirmar y muestra los motivos de rechazo.

**Resultado:** Proceso de importación bloqueado hasta corregir los datos.

#### FE-3. Fallo durante la importación

**Se produce en:** paso 8 del flujo principal.  
**Condición:** Se produce un error técnico durante la persistencia de datos.

1. En el paso 8 se produce un error técnico.
2. El sistema revierte la operación completa para no dejar registros a medias, registra el error con identificador y lo muestra al usuario.
3. El usuario puede corregir la causa y volver a lanzar la importación.

**Resultado:** Transacción revertida completamente sin cambios en la base de datos.

### Postcondiciones

- POST-1. Los clientes válidos quedan creados, y los marcados explícitamente como actualización quedan actualizados.
- POST-2. La operación queda registrada en el registro de auditoría con su resumen y el usuario que la realizó.
- POST-3. Las facturas históricas importadas quedan marcadas como migradas y no generan notificaciones.

---

## CU-04 - Gestionar tareas del cliente

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-03 |
| Nombre | Gestionar tareas del cliente |
| Objetivo | Registrar y seguir tareas pendientes asociadas a un cliente, de modo que no se pierdan cuando cambie su responsable. |
| Actores participantes | Usuario operativo |

### 2. Precondiciones

- PRE-1. El usuario está autenticado.
- PRE-2. El cliente está asignado al usuario (o el usuario es Administrador o superior).

### 3. Flujo principal

1. Actor: El Usuario operativo abre la ficha de un cliente asignado y accede a la sección de tareas.
2. Sistema: El sistema muestra las tareas pendientes y completadas del cliente.
3. Actor: El Usuario operativo selecciona "Añadir tarea".
4. Actor: El Usuario operativo introduce la descripción de la tarea y, opcionalmente, una fecha prevista.
5. Sistema: El sistema valida los datos.
6. Sistema: El sistema guarda la tarea asociada al cliente (no al usuario) y la registra en la línea temporal del cliente.
7. Sistema: El sistema muestra la tarea en la ficha y en la pantalla de trabajo diario del responsable interno del cliente.

### 4. Flujos alternativos

#### FA-1. Editar una tarea

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario selecciona una tarea pendiente y elige editarla.

1. En el paso 2, el usuario selecciona una tarea pendiente y la edita.
2. El sistema valida y guarda los cambios, y los registra en la línea temporal.

**Resultado:** Tarea del cliente modificada y cambios registrados.

#### FA-2. Completar una tarea

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario marca una tarea como completada.

1. En el paso 2, el usuario marca una tarea como completada.
2. El sistema la conserva como completada, registrando quién y cuándo, y la retira de la pantalla de trabajo diario.

**Resultado:** Tarea guardada como completada y retirada de la pantalla de trabajo diario.

#### FA-3. Cambio de responsable del cliente

**Se produce en:** cualquier momento de la gestión del cliente.  
**Condición:** Un Administrador reasigna el cliente a un nuevo responsable interno.

1. Un Administrador cambia el responsable interno del cliente.
2. Las tareas pendientes, al estar asociadas al cliente, pasan automáticamente a su nuevo responsable sin intervención del usuario.

**Resultado:** Tareas pendientes reasignadas automáticamente al nuevo responsable.

### 5. Flujos de excepción

#### FE-1. Datos inválidos

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La descripción está vacía o la fecha prevista no es válida.

1. En el paso 5, la descripción está vacía o la fecha prevista no es válida.
2. El sistema no guarda e indica qué campo hay que corregir.
3. El usuario corrige y reenvía.

**Resultado:** El usuario corrige los datos antes de completar la tarea.

#### FE-2. Cliente no asignado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta acceder a las tareas de un cliente que no tiene asignado.

1. El usuario intenta acceder a las tareas de un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor) e informa de la restricción.

**Resultado:** Acceso denegado a las tareas del cliente.

#### FE-3. Tarea modificada por otro usuario

**Se produce en:** FA-1 o FA-2.  
**Condición:** Otro usuario ha modificado o completado la misma tarea de forma concurrente.

1. En FA-1 o FA-2, otro usuario ha modificado o completado la misma tarea mientras tanto.
2. El sistema avisa del conflicto, muestra el estado actual y no sobrescribe el cambio ajeno.

**Resultado:** Se informa del conflicto y se previene la sobrescritura no deseada.

### Postcondiciones

- POST-1. La tarea queda asociada al cliente con su estado (pendiente o completada).
- POST-2. La línea temporal del cliente refleja la creación, edición o cierre de la tarea.
- POST-3. Las tareas pendientes son visibles para el responsable interno actual del cliente.

# Bloque B. Suscripciones, tarifas y descuentos

## CU-05 - Gestionar baja y pausa de suscripción

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

## CU-06 - Revisar y aprobar rango de tarifa anual

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

## CU-07 - Solicitar descuento

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

## CU-08 - Aprobar descuento

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

## CU-09 - Escalar aprobación al Superadministrador

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

# Bloque C. Facturación

---

## CU-10 — Gestionar borrador de factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-10 |
| **Nombre** | Gestionar borrador de factura |
| **Objetivo** | Preparar, consultar y modificar una factura no emitida, con sus líneas e importes, antes de someterla a la emisión definitiva. |
| **Actores participantes** | Principal: Usuario operativo. Otros participantes: Administrador cuando se cambian cuantías reservadas a ese rol. |

---

### 2. Precondiciones

- PRE-1. El Usuario operativo ha iniciado sesión y dispone de acceso al cliente al que corresponderá la factura.
- PRE-2. Existen los datos comerciales o fiscales del cliente necesarios para preparar un borrador.

---

### 3. Flujo principal

1. **Usuario operativo:** Entra en facturación y selecciona crear un borrador.
2. **Sistema:** Solicita seleccionar el cliente de la factura puntual; las mensualidades recurrentes no pasan por borrador manual porque las genera CU-11.
3. **Usuario operativo:** Introduce las líneas: concepto, cantidad, precio unitario, descuento, si existe, e impuesto; también la descripción y las fechas necesarias.
4. **Sistema:** Completa los valores habituales disponibles, como moneda, condiciones de vencimiento y tarifa, y calcula los importes con precisión decimal.
5. **Sistema:** Muestra el borrador para revisión sin asignar todavía una numeración definitiva de factura emitida.
6. **Usuario operativo:** Confirma que desea guardar el borrador.
7. **Sistema:** Registra el borrador con estado «borrador» y permite continuar su edición mientras no se haya emitido.
8. **Sistema:** Muestra el resumen guardado; el borrador queda disponible como precondición de la emisión manual (CU-12), sin relación «include» ni «extend» entre ambos casos.

---

### 4. Flujos alternativos

#### FA-1 — Editar un borrador existente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona un borrador previamente creado.

1. El Usuario operativo abre un borrador de un cliente autorizado y selecciona editar.
2. El sistema presenta los datos actuales y permite modificar los campos para los que el actor tenga permiso.
3. Tras la validación, guarda los cambios y mantiene el documento en estado de borrador.

**Continuación:** Finaliza con la nueva versión del borrador guardada; aún no se emite.

#### FA-2 — Modificar manualmente una cuantía

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Un Administrador autorizado decide modificar manualmente una cuantía.

1. Un Administrador con permiso modifica el precio, importe o descuento permitido antes de emitir.
2. El sistema recalcula las líneas y el total e identifica las modificaciones que puedan requerir aprobación posterior según FR-13.
3. La cuantía queda guardada en el borrador, pero todavía no se considera una factura emitida.

**Continuación:** El caso de uso continúa en el paso 4 del flujo principal para recalcular el borrador y sigue con su confirmación.

#### FA-3 — Eliminar borrador nunca emitido

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita eliminar un borrador que nunca llegó a emitirse.

1. El usuario autorizado selecciona eliminar un borrador que no tiene emisión definitiva.
2. El sistema advierte sobre la eliminación y solicita confirmación cuando corresponda.
3. Se elimina el borrador conforme a las restricciones aplicables, conservando la trazabilidad que proceda; no se borra ninguna factura emitida.

**Continuación:** Finaliza con el borrador eliminado conforme a las restricciones; no afecta a facturas emitidas.

#### FA-4 — Borrador con cambio sensible

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El borrador incluye un importe modificado manualmente, un descuento extraordinario, un vencimiento fuera de lo habitual o es una factura puntual de importe alto.

1. El sistema marca el borrador e informa de que quedará retenido para aprobación al emitirlo.
2. No impide guardar el borrador.
3. La retención efectiva se decide en la emisión (CU-12).

**Continuación:** El caso de uso continúa en el paso 5 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Datos o líneas incorrectos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Una línea o dato de factura es inválido o incompleto.

1. El sistema localiza una línea con valores no válidos o datos insuficientes.
2. Señala los campos problemáticos y no guarda el cambio solicitado.
3. El Usuario operativo corrige los valores y vuelve a confirmar.

**Resultado:** El cambio del borrador no se guarda hasta corregir los campos y revalidar.

#### FE-2 — Intento de modificar una factura emitida

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se intenta editar o borrar una factura que ya está emitida.

1. El registro seleccionado ya ha pasado a estado de factura emitida o está bloqueado por las reglas aplicables.
2. El sistema rechaza la edición o eliminación ordinaria.
3. Informa de que las correcciones posteriores deben seguir CU-14 si corresponden.

**Resultado:** Se bloquea la modificación ordinaria y se remite al procedimiento de CU-14.

#### FE-3 — Modificación simultánea incompatible

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El borrador ha sido modificado simultáneamente desde otra sesión.

1. Dos usuarios intentan conservar versiones diferentes del mismo borrador.
2. El sistema evita sobrescribir silenciosamente los cambios de otro usuario.
3. Muestra el conflicto para que se revise antes de guardar.

**Resultado:** Se impide sobrescribir cambios ajenos sin revisión; la edición queda pendiente.

---

### 6. Postcondiciones

- POST-1. El borrador queda creado, actualizado o eliminado según la acción autorizada.
- POST-2. No se modifica una factura ya emitida ni se consume una nueva numeración definitiva por guardar el borrador.
- POST-3. La emisión posterior queda fuera de este caso de uso y se realiza en CU-12.

---

## CU-11 — Generar facturas recurrentes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-11 |
| **Nombre** | Generar facturas recurrentes |
| **Objetivo** | Ejecutar la facturación mensual de las suscripciones que corresponden al periodo, asegurando que cada factura se emita una sola vez. |
| **Actores participantes** | Principal: Planificador del sistema. Otros participantes: CU-12 interviene mediante «include» y, por su intermediación, CU-18 para el envío. |

---

### 2. Precondiciones

- PRE-1. Ha llegado la fecha programada de facturación mensual o procede recuperar una ejecución interrumpida.
- PRE-2. Existen suscripciones registradas con condiciones comerciales y tarifas verificables.

---

### 3. Flujo principal

1. **Planificador del sistema:** Inicia la generación recurrente correspondiente al periodo, normalmente el día 1.
2. **Sistema:** Consulta las suscripciones y determina cuáles están activas y deben facturarse en ese periodo.
3. **Sistema:** Para cada suscripción elegible, verifica las condiciones vigentes: tarifa aprobada, descuentos aplicables, fechas y vencimiento pactado cuando exista.
4. **Sistema:** Calcula las líneas y el importe correspondiente con los impuestos configurados, sin cambiar documentos históricos.
5. **Sistema:** Verifica que esa mensualidad no se haya emitido ya para la misma suscripción y periodo.
6. **Sistema:** Invoca CU-12 «Emitir factura» para cada mensualidad válida, aplicando la emisión sin aprobación adicional cuando coincide con una suscripción aprobada.
7. **Sistema:** Registra cuáles se emitieron, cuáles quedaron pendientes y los errores individuales sin detener innecesariamente la totalidad del proceso.
8. **Sistema:** Cierra o actualiza el estado de la ejecución y deja disponible el resumen para monitorización.

---

### 4. Flujos alternativos

#### FA-1 — Suscripción pausada, de baja o pendiente de activación

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Una suscripción no debe facturarse por estar pausada, de baja o pendiente de activación.

1. Al comprobar la elegibilidad, una suscripción está pausada, tiene baja efectiva o aún no ha llegado su fecha futura de inicio.
2. El sistema no genera una mensualidad durante el periodo en el que no corresponde facturar.
3. Deja constancia del motivo y continúa con las demás suscripciones.

**Continuación:** Omite dicha suscripción y continúa en el paso 2 con las demás; luego cierra la ejecución.

#### FA-2 — Primera mensualidad o prorrateo

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La primera mensualidad necesita prorrateo o tiene una excepción de inicio acordada.

1. Una suscripción comienza en mitad del mes y sus condiciones requieren facturar la parte proporcional.
2. El sistema utiliza la regla de prorrateo documentada y las excepciones comerciales registradas previamente en la ficha.
3. Emite únicamente lo que corresponda al periodo, sin inventar una mensualidad completa adicional.

**Continuación:** El caso de uso continúa en el paso 4 del flujo principal y calcula exclusivamente el importe correspondiente al periodo.

#### FA-3 — Recuperación tras una interrupción

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se reejecuta una generación mensual tras una interrupción o fallo.

1. La tarea se vuelve a ejecutar porque una ejecución previa quedó incompleta.
2. El sistema comprueba qué mensualidades ya tienen factura emitida.
3. Procesa exclusivamente las pendientes; no duplica numeración ni crea dos facturas para la misma obligación.

**Continuación:** El caso de uso continúa en el paso 2 del flujo principal tras identificar el periodo, respetando las facturas ya emitidas.

#### FA-4 — Suscripción con excepción comercial

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La suscripción tiene una excepción comercial registrada en la ficha del cliente.

1. El sistema comprueba si la excepción con efecto económico está aprobada.
2. Si está aprobada, la aplica: con «primer mes gratuito» no cobra la primera mensualidad y con «sin prorrateo» empieza a facturar la mensualidad completa desde el mes siguiente.
3. Si sigue pendiente de aprobación, no la aplica y la señala al responsable del cliente.

**Continuación:** El caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Datos imprescindibles o aprobación pendiente

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Faltan datos fiscales imprescindibles o una condición económica aprobada.

1. Una suscripción carece de información fiscal necesaria o tiene una condición económica que no está aprobada.
2. El sistema deja esa factura sin emitir o retenida según la causa e identifica al cliente afectado.
3. Registra la incidencia para que una persona autorizada la resuelva y continúa con las demás suscripciones.

**Resultado:** La mensualidad afectada no se emite; queda identificada para resolver, sin detener todo el lote.

#### FE-2 — Fallo durante una emisión

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Falla la emisión individual ejecutada mediante CU-12.

1. CU-12 devuelve un error de emisión para un cliente determinado.
2. El sistema registra el error con identificador y estado de la operación, evitando generar un duplicado al reintentar.
3. La ejecución puede continuar con el resto de clientes y recuperar después la emisión pendiente.

**Resultado:** Se registra el fallo, se conservan los éxitos anteriores y el reintento no crea duplicados.

---

### 6. Postcondiciones

- POST-1. Las mensualidades elegibles quedan emitidas exactamente una vez o registradas como pendientes o fallidas.
- POST-2. Queda un resumen de ejecución que permite identificar éxitos y excepciones.
- POST-3. Las suscripciones suspendidas o dadas de baja no generan nuevas mensualidades durante el periodo afectado.

---

## CU-12 — Emitir factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-12 |
| **Nombre** | Emitir factura |
| **Objetivo** | Validar, numerar, generar y conservar una factura definitiva y activar su envío al cliente, garantizando la inmutabilidad e idempotencia de la emisión. |
| **Actores participantes** | Principal: Usuario operativo. Otros participantes: Planificador del sistema si CU-11 invoca este caso; Proveedor de correo a través de CU-18; Administrador en la extensión CU-13. |

---

### 2. Precondiciones

- PRE-1. El actor autorizado dispone de un borrador no emitido o de los datos de una mensualidad preparados por CU-11.
- PRE-2. Se ha seleccionado el cliente y están disponibles las reglas de impuestos y series aplicables.

---

### 3. Flujo principal

1. **Usuario operativo:** Solicita emitir un borrador o CU-11 invoca la emisión automática de una mensualidad.
2. **Sistema:** Valida los datos fiscales, las líneas y los impuestos y comprueba si la operación ya fue emitida anteriormente.
3. **Sistema:** En la emisión manual, el sistema presenta una vista previa con importes, datos fiscales y condiciones de pago.
4. **Usuario operativo:** Confirma la emisión manual; para una mensualidad aprobada, el proceso automático utiliza la autorización de la suscripción.
5. **Sistema:** Comprueba si existe alguna condición económica que requiera retener la factura para revisión antes del envío.
6. **Sistema:** Asigna de forma segura el número correlativo único dentro de la serie cuando la factura esté autorizada para su emisión.
7. **Sistema:** Genera el PDF, conserva los datos emitidos y el documento y bloquea su modificación ordinaria.
8. **Sistema:** Invoca CU-18 «Enviar comunicación al cliente» para efectuar el envío automático por el canal que corresponda.
9. **Sistema:** Registra el estado de emisión y el resultado del intento de envío y presenta o devuelve la confirmación de la operación.

---

### 4. Flujos alternativos

#### FA-1 — Factura con cambio sensible: extensión CU-13

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La factura contiene una modificación económica o condición sensible que exige revisión.

1. En la comprobación previa se detecta importe modificado, descuento extraordinario, vencimiento atípico o factura puntual de importe elevado.
2. El sistema registra la causa de la retención y activa CU-13 «Aprobar factura retenida» antes de permitir su envío.
3. Tras la aprobación, continúa la emisión y el envío si aún están pendientes; si se rechaza, mantiene la factura sin enviar para su corrección autorizada.

**Continuación:** Activa CU-13 y solo retoma el paso 6 cuando la operación puede emitirse; si es rechazada, no se completa la emisión.

#### FA-2 — Emisión recurrente desde CU-11

**Se produce en:** paso 1 del flujo principal.  
**Condición:** CU-11 invoca la emisión de una mensualidad exactamente ajustada a condiciones aprobadas.

1. La emisión se ejecuta desde una suscripción cuyas condiciones ya han sido aprobadas y no presentan cambios sensibles.
2. El sistema valida automáticamente los datos, asigna numeración y conserva el PDF sin exigir una aprobación humana por cada mensualidad.
3. El resultado se devuelve a CU-11 y el envío se intenta mediante CU-18.

**Continuación:** Omite la confirmación manual del paso 4 y continúa con la validación y emisión automática.

#### FA-3 — Fallo de envío posterior a la emisión

**Se produce en:** paso 8 del flujo principal.  
**Condición:** CU-18 informa de un fallo de envío posterior a la emisión.

1. CU-18 devuelve un error una vez que la factura ya se ha emitido.
2. El sistema conserva la factura, su número y su PDF, y registra que el envío está pendiente o ha fallado; la factura permanece «emitida» y no pasa a «enviada» hasta que el envío se complete.
3. Un reintento utiliza la misma factura y el mismo número, sin volver a emitirla.

**Continuación:** El caso de uso continúa en el paso 9 del flujo principal registrando el error de entrega, sin modificar la factura ya emitida.

---

### 5. Flujos de excepción

#### FE-1 — Falta un dato fiscal imprescindible

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Falta información fiscal necesaria o existe un dato inválido.

1. La validación detecta un campo fiscal obligatorio ausente o incorrecto.
2. El sistema bloquea la emisión antes de asignar número y especifica qué falta.
3. El actor corrige los datos por la vía autorizada y repite la validación.

**Resultado:** Se bloquea la emisión antes de asignar número y se indican los datos a corregir.

#### FE-2 — Duplicidad o concurrencia durante la emisión

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Dos intentos pretenden emitir la misma obligación o emplear el mismo número.

1. Dos solicitudes intentan emitir la misma obligación o generar numeración simultáneamente.
2. El sistema verifica la operación y la serie y evita duplicar facturas o números.
3. Devuelve la factura ya emitida, o mantiene la operación pendiente de completar, según corresponda.

**Resultado:** Se evita la duplicación y se recupera el resultado válido de la operación ya registrada.

#### FE-3 — No se puede generar o conservar el PDF

**Se produce en:** paso 7 del flujo principal.  
**Condición:** No puede producirse o conservarse el PDF legal de la factura.

1. Se produce un fallo antes de completar la emisión y la conservación del documento.
2. El sistema registra la incidencia e impide confirmar una factura como emitida sin documento válido.
3. Permite recuperar el intento sin crear una segunda factura ni consumir indebidamente numeración.

**Resultado:** No se confirma una nueva emisión incompleta y queda disponible un reintento seguro.

---

### 6. Postcondiciones

- POST-1. Si finaliza correctamente, la factura posee serie y número únicos, importes calculados y PDF conservado.
- POST-2. La factura emitida queda protegida contra cambios ordinarios y su envío se ha intentado mediante CU-18.
- POST-3. Los fallos de envío o validación quedan diferenciados de una emisión correcta y no producen duplicados.
- POST-4. El saldo pendiente del cliente incluye la nueva factura emitida.

---

## CU-13 — Aprobar factura retenida

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-13 |
| **Nombre** | Aprobar factura retenida |
| **Objetivo** | Resolver la revisión humana de una factura que contiene una modificación o excepción económica sensible antes de permitir su envío. |
| **Actores participantes** | Principal: Administrador. Otros participantes: Usuario operativo que solicitó la factura; CU-12 es el caso de uso extendido. |

---

### 2. Precondiciones

- PRE-1. CU-12 ha identificado una causa de retención y la factura está pendiente de aprobación.
- PRE-2. El Administrador ha iniciado sesión; sus permisos de aprobación se comprueban al resolver la solicitud.

---

### 3. Flujo principal

1. **Administrador:** Accede a la bandeja de facturas pendientes de aprobación.
2. **Sistema:** Muestra la factura, su cliente, los importes, la condición excepcional detectada y el motivo de la retención.
3. **Administrador:** Consulta el detalle y verifica las condiciones fiscales y económicas propuestas.
4. **Sistema:** Comprueba que la solicitud sigue pendiente y que la persona tiene permiso para decidir.
5. **Administrador:** Selecciona aprobar y confirma su decisión.
6. **Sistema:** Registra quién aprobó y cuándo y deja la factura lista para completar el procedimiento de emisión y envío de CU-12.
7. **Sistema:** Actualiza el estado y comunica al solicitante el resultado de la revisión.

---

### 4. Flujos alternativos

#### FA-1 — Rechazar la factura

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Administrador concluye que la factura retenida no debe aprobarse.

1. El Administrador selecciona rechazar e indica el motivo.
2. El sistema registra el rechazo y mantiene bloqueado el envío de la factura retenida.
3. La factura vuelve a estado «borrador» y el solicitante recibe el resultado para corregirla antes de volver a emitirla.

**Continuación:** Finaliza con la decisión de rechazo y la factura sin enviarse.

#### FA-2 — Aprobación pendiente por falta de información

**Se produce en:** paso 3 del flujo principal.  
**Condición:** No hay información suficiente para decidir todavía.

1. El Administrador necesita aclarar un importe, descuento o vencimiento antes de decidir.
2. El sistema mantiene la retención y registra el motivo por el que no se ha aprobado.
3. Cuando se complete la información, el expediente volverá a estar disponible para su revisión.

**Continuación:** Finaliza con la solicitud pendiente y los datos requeridos identificados.

---

### 5. Flujos de excepción

#### FE-1 — Aprobación incompatible con los permisos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador no tiene permiso o incumple la separación de funciones requerida.

1. El Administrador no tiene la autorización requerida o es el solicitante cuando la separación de funciones lo prohíbe.
2. El sistema bloquea la decisión y muestra el motivo.
3. La factura permanece retenida hasta que intervenga una persona habilitada.

**Resultado:** La factura continúa retenida a la espera de otro aprobador.

#### FE-2 — Factura resuelta por otro usuario

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La factura retenida fue resuelta por otra persona antes de confirmar.

1. La factura ya se aprobó, rechazó o cambió de estado antes de registrar la decisión.
2. El sistema evita registrar otra aprobación contradictoria.
3. Muestra el estado actual y no provoca un envío duplicado.

**Resultado:** No se duplica la decisión y se muestra su estado actualizado.

#### FE-3 — Faltan datos fiscales al retomar la emisión

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Tras la aprobación, la emisión detecta que falta un dato fiscal imprescindible.

1. CU-12 bloquea la emisión antes de asignar número e indica qué falta.
2. La aprobación queda registrada y no es necesario repetirla.
3. Se completan los datos y se reintenta la emisión.

**Resultado:** La factura queda aprobada pero sin emitir hasta completar los datos.

---

### 6. Postcondiciones

- POST-1. La factura queda aprobada, rechazada o todavía retenida según la decisión.
- POST-2. La decisión y su autor se registran de forma trazable.
- POST-3. Únicamente una aprobación válida permite continuar el envío correspondiente desde CU-12.

---

## CU-14 — Rectificar, anular o declarar incobrable una factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-14 |
| **Nombre** | Rectificar, anular o declarar incobrable una factura |
| **Objetivo** | Gestionar las correcciones y decisiones excepcionales sobre una factura emitida sin borrar su histórico ni equiparar anulaciones o deudas incobrables a cobros. |
| **Actores participantes** | Principal: Administrador. Otros participantes: ninguno en el diagrama. La aprobación adicional que exige la regla económica es un flujo interno (FA-3), no un actor ni un caso de uso aparte; quién aprueba queda pendiente (Q-12). |

---

### 2. Precondiciones

- PRE-1. El Administrador está autenticado y tiene permiso administrativo sobre la factura.
- PRE-2. La factura de origen existe y está emitida; se conoce su situación actual.

---

### 3. Flujo principal

1. **Administrador:** Localiza una factura emitida y selecciona la operación excepcional que necesita realizar.
2. **Sistema:** Presenta el documento original, sus importes y estado, y comprueba si la acción es admisible.
3. **Sistema:** Para una rectificación, el sistema propone los datos que se rectificarán y solicita el motivo.
4. **Administrador:** Revisa los cambios y los importes resultantes.
5. **Sistema:** Comprueba los permisos y determina si el importe o la naturaleza de la operación exigen aprobación adicional.
6. **Administrador:** Confirma la rectificación y obtiene, si procede, la aprobación requerida.
7. **Sistema:** Emite o registra la rectificativa conforme al procedimiento aplicable, vinculándola a la factura original sin reescribir su documento.
8. **Sistema:** Actualiza el estado y el saldo correspondiente teniendo en cuenta el documento corrector, y registra la acción realizada.

---

### 4. Flujos alternativos

#### FA-1 — Anular una factura cuando legalmente proceda

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita anular una factura en un supuesto legalmente permitido.

1. El Administrador solicita anular la factura en lugar de rectificarla.
2. El sistema comprueba las condiciones legales y los permisos y requiere motivo y aprobación cuando corresponda.
3. Registra la anulación o el documento que la formalice, mantiene el histórico y no convierte la factura en pagada.

**Continuación:** Finaliza con la anulación registrada y trazable, sin reescribir el documento emitido.

#### FA-2 — Declarar una deuda incobrable o cancelarla administrativamente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita cancelar o declarar incobrable una obligación pendiente.

1. El Administrador selecciona una deuda pendiente y solicita declararla incobrable o cancelarla.
2. El sistema solicita el motivo y somete la decisión a la aprobación administrativa necesaria.
3. Tras su validación, registra la situación especial de la deuda, detiene los recordatorios de impago de esa factura y nunca cambia su estado a «pagada» por ese motivo.

**Continuación:** Finaliza con la deuda en su estado administrativo correcto, nunca como pagada por este motivo.

#### FA-3 — Operación pendiente de aprobación

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La operación supera las reglas económicas que exigen otra aprobación.

1. El importe o la regla sensible exigen que otra persona revise la solicitud.
2. El sistema mantiene la operación sin efecto definitivo e informa del motivo de la espera.
3. La persona autorizada aprueba o rechaza antes de registrar el cambio excepcional.

**Continuación:** Se reanuda en el paso 6 cuando se obtiene la autorización; sin ella la operación continúa pendiente.

---

### 5. Flujos de excepción

#### FE-1 — Operación no permitida para la factura

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El estado de la factura o las reglas aplicables impiden la operación.

1. La factura, su estado o las restricciones legales no permiten la anulación o rectificación propuesta.
2. El sistema bloquea la acción, conserva el original e informa de la causa.
3. Si la factura no llegó a emitirse, el sistema indica que el borrador puede editarse o eliminarse; si lo que no procede es la anulación, ofrece generar una rectificativa.

**Resultado:** La factura original y sus saldos permanecen sin cambios.

#### FE-2 — Falta motivo o aprobación

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Falta el motivo o una aprobación necesaria.

1. Se intenta completar una rectificación o cancelación sin el motivo o la autorización exigidos.
2. El sistema no registra la decisión como definitiva.
3. El Administrador completa la justificación o solicita la aprobación faltante.

**Resultado:** La operación excepcional no se completa y permanece pendiente hasta ser autorizada.

#### FE-3 — Factura ya rectificada o anulada

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La factura ya está en estado «rectificada» o «anulada».

1. El sistema detecta el estado de la factura.
2. Impide repetir la operación e informa del estado y del documento vinculado.
3. El Administrador consulta el documento existente si necesita revisarlo.

**Resultado:** No se genera ningún documento nuevo y la factura conserva su estado.

---

### 6. Postcondiciones

- POST-1. La factura original y su PDF permanecen conservados y vinculados a cualquier rectificativa correspondiente.
- POST-2. Los estados y saldos reflejan la operación excepcional autorizada.
- POST-3. La acción y su motivación quedan auditadas; «incobrable», «anulada» y «rectificada» no equivalen a «pagada».

---

## CU-15 — Buscar y consultar facturas y clientes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-15 |
| **Nombre** | Buscar y consultar facturas y clientes |
| **Objetivo** | Localizar rápidamente las fichas y facturas a las que puede acceder el usuario, consultar sus estados y descargar los documentos correspondientes. |
| **Actores participantes** | Principal: Usuario operativo. |

---

### 2. Precondiciones

- PRE-1. El Usuario operativo está autenticado y tiene permisos de lectura sobre al menos parte de la información del sistema.
- PRE-2. Existen datos de clientes o facturas que pueden consultarse.

---

### 3. Flujo principal

1. **Usuario operativo:** Abre la búsqueda global o el listado autorizado.
2. **Sistema:** Ofrece criterios de consulta, como nombre comercial, razón social, NIF, contacto, correo o número de factura.
3. **Usuario operativo:** Escribe un término y aplica filtros disponibles, como empresa, fechas, sector o estado de factura.
4. **Sistema:** Ejecuta la búsqueda respetando las asignaciones y permisos del actor.
5. **Sistema:** Muestra los resultados autorizados y su información básica relevante.
6. **Usuario operativo:** Selecciona un cliente o factura para examinar sus datos y estado.
7. **Sistema:** Muestra el detalle permitido y, para las facturas, la opción de descargar el PDF conservado.
8. **Usuario operativo:** Consulta el detalle o descarga el documento cuando lo necesita.

---

### 4. Flujos alternativos

#### FA-1 — Guardar y reutilizar filtros

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Usuario operativo decide guardar los filtros para consultas posteriores.

1. El Usuario operativo configura una combinación de filtros habitual.
2. Selecciona guardar la vista o el filtro para futuras consultas.
3. El sistema conserva esa preferencia y la aplica respetando los permisos vigentes al volver a usarla.

**Continuación:** El caso de uso continúa en el paso 4 del flujo principal o finaliza dejando guardada la vista sin modificar datos de negocio.

#### FA-2 — Descargar el PDF de una factura

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El Usuario operativo solicita descargar el documento PDF de una factura autorizada.

1. El Usuario operativo abre una factura autorizada y solicita su PDF.
2. El sistema vuelve a comprobar que dispone de permiso para el documento.
3. Facilita la descarga de la versión emitida sin modificar el documento histórico.

**Continuación:** Finaliza con el documento entregado por un acceso autorizado.

#### FA-3 — Resultados sin coincidencias

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No se encuentran registros correspondientes a la consulta.

1. No existe ningún registro accesible que cumpla los términos y filtros introducidos.
2. El sistema informa de que no hay resultados y conserva los criterios introducidos.
3. El Usuario operativo ajusta la búsqueda si desea ampliarla.

**Continuación:** Finaliza mostrando un resultado vacío y permitiendo reformular la búsqueda.

#### FA-4 — Acceso desde favoritos o recientes

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Usuario operativo abre un cliente o factura desde sus favoritos o elementos recientes.

1. El Usuario operativo selecciona el elemento en su lista de favoritos o recientes.
2. El sistema comprueba los permisos igualmente, porque estas listas no son un mecanismo de autorización.
3. Si el acceso está permitido, muestra el detalle.

**Continuación:** El caso de uso continúa en el paso 7 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Acceso denegado a un registro o documento

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Se intenta abrir o descargar un elemento al que no se tiene derecho.

1. El actor intenta abrir mediante enlace una ficha o factura que no está dentro de su ámbito de autorización.
2. El servidor impide la lectura o descarga aunque el actor conozca el identificador.
3. Se informa de que la operación no está permitida.

**Resultado:** Se deniega el acceso y no se entrega información no autorizada.

#### FE-2 — Criterios o documento no disponibles

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Los criterios no son válidos o el documento solicitado no está disponible.

1. La consulta no puede ejecutarse o el archivo PDF solicitado no está accesible por un fallo.
2. El sistema informa del problema sin exponer datos de otras empresas.
3. El usuario puede reintentar la consulta o comunicar la incidencia.

**Resultado:** Se informa del problema; puede corregirse la búsqueda o revisar la disponibilidad.

---

### 6. Postcondiciones

- POST-1. Se obtiene la información y, en su caso, el PDF autorizado sin modificar los datos de negocio.
- POST-2. Los filtros guardados permanecen disponibles para el usuario.
- POST-3. No se revela información de clientes o facturas fuera de los permisos del actor.

# Bloque D. Cobros y comunicaciones

### CU-16 - Registrar movimiento de cobro

| Campo | Contenido |
|---|---|
| Identificador | CU-16 |
| Nombre | Registrar movimiento de cobro |
| Objetivo | Incorporar ingresos económicos al sistema para su posterior asignación a deudas pendientes. |
| Actor principal | Sistema de pagos (o Planificador del sistema) |
| Actores secundarios | Ninguno |

#### Precondiciones
- Debe existir constancia de un ingreso de fondos por parte de un cliente.

#### Flujo principal
1. El actor informa al sistema sobre un nuevo ingreso de fondos.
2. El sistema registra los datos financieros del ingreso (importe, fecha y referencia).
3. El sistema invoca el CU-17 Conciliar pagos (`<<include>>`).
4. El sistema confirma que el cobro ha quedado registrado.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El ingreso económico queda consolidado en los registros financieros del sistema.

---

### CU-17 - Conciliar pagos

| Campo | Contenido |
|---|---|
| Identificador | CU-17 |
| Nombre | Conciliar pagos |
| Objetivo | Cruzar un ingreso económico registrado con las deudas vigentes para amortizar facturas pendientes. |
| Actor principal | Usuario operativo (o Sistema automáticamente) |
| Actores secundarios | Ninguno |

#### Precondiciones
- Existen ingresos no asignados y facturas pendientes de cobro.

#### Flujo principal
1. El actor selecciona un ingreso no asignado.
2. El sistema identifica y muestra las deudas pendientes compatibles con dicho ingreso.
3. El actor asocia el ingreso a la factura correspondiente.
4. El sistema actualiza el estado de cobro de la factura.
5. El sistema actualiza el saldo global del cliente.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Exceso de pago**
1. El sistema detecta que el importe del ingreso es superior al total de la factura.
2. El sistema salda la factura y registra la diferencia como saldo a favor en la cuenta del cliente.

#### Postcondiciones
- La deuda del cliente queda total o parcialmente amortizada.

---

### CU-18 - Enviar comunicación al cliente

| Campo | Contenido |
|---|---|
| Identificador | CU-18 |
| Nombre | Enviar comunicación al cliente |
| Objetivo | Garantizar la entrega de notificaciones institucionales y operativas a los clientes. |
| Actor principal | Proveedor de correo |
| Actores secundarios | Sistema de origen (CU-12, CU-20, CU-19) |

#### Precondiciones
- Ser invocado por otro caso de uso (`<<include>>` o `<<extend>>`) que requiera notificar al cliente.

#### Flujo principal
1. El sistema de origen solicita la emisión de una comunicación, aportando los datos necesarios.
2. El sistema genera el mensaje combinando la información con la plantilla correspondiente (CU-22).
3. El sistema transfiere el mensaje al Proveedor de correo.
4. El Proveedor de correo distribuye el mensaje al destinatario.
5. El sistema registra la comunicación en el historial del cliente.

#### Flujos alternativos
**A1. Extensión por rebote (`<<extend>>`)**
1. En el paso 4, el Proveedor de correo detecta que el mensaje no puede ser entregado.
2. El proceso se extiende al CU-19 Gestionar rebote de correo.

#### Flujos de excepción
**E1. Indisponibilidad del proveedor**
1. En el paso 3, el Proveedor de correo no admite la transferencia del mensaje.
2. El sistema retiene la comunicación para reintentar el envío posteriormente.

#### Postcondiciones
- La comunicación es despachada hacia el cliente y queda constancia de ello.

---

### CU-19 - Gestionar rebote de correo

| Campo | Contenido |
|---|---|
| Identificador | CU-19 |
| Nombre | Gestionar rebote de correo |
| Objetivo | Administrar los fallos definitivos de entrega de mensajes para mantener la fiabilidad de los canales de contacto. |
| Actor principal | Usuario operativo (o Proveedor de correo) |
| Actores secundarios | Ninguno |

#### Precondiciones
- Un envío previo (CU-18) ha devuelto un error permanente de entrega.

#### Flujo principal
1. El Proveedor de correo notifica al sistema el fallo de entrega (extendiendo CU-18).
2. El sistema clasifica el punto de contacto del cliente como inválido.
3. El sistema invoca el CU-25 Gestionar incidencias y comentarios (`<<include>>`) para generar una tarea de revisión.
4. El actor proporciona un punto de contacto válido para el cliente.
5. El sistema restablece el estado del contacto a operativo.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El dato de contacto erróneo queda invalidado y se inicia una acción de subsanación.

---

### CU-20 - Ejecutar flujo de recordatorios e impago

| Campo | Contenido |
|---|---|
| Identificador | CU-20 |
| Nombre | Ejecutar flujo de recordatorios e impago |
| Objetivo | Sistematizar la reclamación de deudas identificando facturas vencidas y emitiendo los avisos correspondientes. |
| Actor principal | Planificador del sistema |
| Actores secundarios | Ninguno |

#### Precondiciones
- Existen facturas emitidas cuyo plazo de pago ha expirado.

#### Flujo principal
1. El actor identifica las facturas vencidas que no han sido cobradas.
2. El sistema evalúa las políticas de reclamación (CU-36) para determinar si procede emitir un aviso en el momento actual.
3. El sistema invoca el CU-18 Enviar comunicación al cliente (`<<include>>`) con el nivel de advertencia adecuado.
4. El sistema actualiza el estado de seguimiento de la factura.

#### Flujos alternativos
**A1. Factura pausada o en disputa (`<<extend>>`)**
1. En el paso 2, el sistema detecta que la factura cuenta con una exención de reclamación.
2. El proceso se desvía al CU-21 Suspender recordatorios de una factura (`<<extend>>`).
3. El sistema omite la emisión del recordatorio para esa factura concreta.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- Las acciones de reclamación pertinentes son generadas y registradas para los deudores.

---

### CU-21 - Suspender recordatorios de una factura

| Campo | Contenido |
|---|---|
| Identificador | CU-21 |
| Nombre | Suspender recordatorios de una factura |
| Objetivo | Detener temporalmente las acciones de reclamación sobre una deuda específica por encontrarse en negociación o revisión. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- La factura se encuentra pendiente de cobro e incluida en el flujo de reclamaciones.

#### Flujo principal
1. El actor selecciona una factura con deuda pendiente.
2. El actor indica la orden de pausar las reclamaciones y adjunta una justificación administrativa.
3. El sistema clasifica la factura como excluida del flujo de reclamaciones automáticas.
4. El sistema omite dicha factura en futuras ejecuciones del CU-20 (`<<extend>>`).

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- La factura queda exenta del motor de reclamación de impagos de forma temporal.

---

### CU-22 - Gestionar plantillas de comunicación

| Campo | Contenido |
|---|---|
| Identificador | CU-22 |
| Nombre | Gestionar plantillas de comunicación |
| Objetivo | Definir y mantener los formatos y contenidos estructurados que se usarán en las notificaciones del sistema. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- El actor debe contar con los privilegios administrativos necesarios.

#### Flujo principal
1. El actor solicita gestionar los formatos de comunicación.
2. El sistema expone los formatos y campos de información disponibles.
3. El actor define el contenido estático y los parámetros dinámicos del mensaje.
4. El sistema valida la integridad de la estructura de la plantilla.
5. El sistema almacena el formato validado para su uso en futuras comunicaciones.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El formato de comunicación queda actualizado y disponible para su uso por parte del sistema.

# Bloque E. Seguimiento, consulta e informes

---

## CU-23 — Gestionar notificaciones y canales

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-23 |
| **Nombre** | Gestionar notificaciones y canales |
| **Objetivo** | Consultar y atender notificaciones internas y configurar cómo recibe cada usuario los avisos, diferenciando el estado leído del resuelto. |
| **Actores participantes** | Principal: Usuario operativo. Otros participantes: Planificador del sistema para notificaciones y resúmenes automáticos. |

---

### 2. Precondiciones

- PRE-1. El usuario tiene una sesión válida y un perfil de notificaciones disponible.
- PRE-2. Existen eventos de negocio que pueden generar avisos al responsable del cliente.

---

### 3. Flujo principal

1. **Usuario operativo:** Abre su bandeja de notificaciones.
2. **Sistema:** Muestra los avisos permitidos, relacionados con pagos, vencimientos, incidencias, aprobaciones o tareas, con su estado correspondiente.
3. **Usuario operativo:** Selecciona una notificación y consulta su contenido y la referencia al elemento relacionado.
4. **Sistema:** Presenta el detalle autorizado y permite marcar el aviso como leído.
5. **Usuario operativo:** Cuando la notificación requiere una actuación, accede al elemento que debe resolver.
6. **Usuario operativo:** Una vez atendido el asunto, marca el aviso como resuelto si el tipo de notificación lo permite.
7. **Sistema:** Actualiza el estado, manteniendo la diferencia entre leído y resuelto.
8. **Sistema:** Conserva las preferencias de recepción aplicables al usuario.

---

### 4. Flujos alternativos

#### FA-1 — Configurar canales de recepción

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario decide cambiar su modo de recepción de notificaciones.

1. El Usuario operativo entra en sus preferencias de notificación.
2. Selecciona qué categorías desea recibir dentro de la aplicación, por correo o en un resumen diario, dentro de lo permitido.
3. El sistema guarda las preferencias, que usarán los siguientes avisos y resúmenes programados.

**Continuación:** Finaliza con las preferencias válidas guardadas.

#### FA-2 — Consultar la bandeja global como Administrador

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un Administrador autorizado solicita consultar la bandeja global.

1. Un Administrador autorizado entra en la bandeja global de avisos.
2. El sistema muestra las notificaciones generales que puede supervisar además de las propias.
3. El Administrador consulta o gestiona las permitidas sin alterar las asignaciones de los usuarios.

**Continuación:** Finaliza con la consulta global autorizada; no cambia estados por el mero acceso.

#### FA-3 — Notificación por mención o alerta programada

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Se recibe una notificación generada por mención o por alerta programada.

1. Un comentario menciona al usuario, o el Planificador detecta una condición de alerta configurada.
2. El sistema genera la notificación para su destinatario y aplica sus preferencias de canal.
3. La notificación queda disponible y se gestiona con las mismas reglas de lectura y resolución.

**Continuación:** El caso de uso continúa en el paso 2 del flujo principal y muestra el aviso en la bandeja del destinatario correspondiente.

#### FA-4 — Resumen diario

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Llega la hora del resumen diario y el usuario lo tiene activado.

1. El Planificador del sistema inicia la generación del resumen.
2. El sistema reúne las notificaciones pendientes de las categorías elegidas por cada usuario.
3. Las envía por correo y registra el envío.

**Continuación:** Finaliza; las notificaciones incluidas conservan su estado en la bandeja.

---

### 5. Flujos de excepción

#### FE-1 — Notificación sin acceso al contenido

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La notificación apunta a un recurso cuyo acceso no corresponde al usuario.

1. El usuario sigue teniendo una notificación pero perdió permiso sobre el cliente o documento relacionado.
2. El sistema permite ver únicamente lo que corresponda y bloquea el acceso al elemento restringido.
3. No expone información fuera del alcance del actor.

**Resultado:** No se expone el contenido del recurso; la notificación puede conservar su estado.

#### FE-2 — Error al cambiar el estado o preferencias

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Falla la actualización del estado o de las preferencias de recepción.

1. No puede guardarse una marca de leído, resolución o preferencia de canal.
2. El sistema informa del fallo y conserva el último estado confirmado.
3. El Usuario operativo puede reintentar la actualización.

**Resultado:** El sistema mantiene el último estado confirmado y ofrece reintentar.

#### FE-3 — Notificación ya resuelta por otro usuario

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Otro usuario ha resuelto el asunto de la notificación mientras tanto.

1. El sistema detecta que la notificación ya está resuelta.
2. Informa del estado actual y no duplica la acción.

**Resultado:** La notificación conserva el estado registrado.

---

### 6. Postcondiciones

- POST-1. Las notificaciones consultadas mantienen un estado coherente de lectura y resolución.
- POST-2. Las preferencias de canal quedan guardadas para posteriores comunicaciones internas.
- POST-3. Los avisos no sustituyen la gestión efectiva de deudas o incidencias asociadas.

---

## CU-24 — Configurar alertas

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-24 |
| **Nombre** | Configurar alertas |
| **Objetivo** | Definir reglas parametrizables para advertir sobre situaciones relevantes de cobro o seguimiento, sin implantar un motor general de procesos. |
| **Actores participantes** | Principal: Administrador. Otros participantes: ninguno en el diagrama; la evaluación de las reglas y la entrega de alertas pertenecen a CU-23, donde participa el Planificador. |

---

### 2. Precondiciones

- PRE-1. El Administrador ha iniciado sesión y solicita configurar reglas; sus permisos efectivos se verifican antes de guardar.
- PRE-2. Existe el conjunto de tipos de regla y parámetros admitidos por el sistema.

---

### 3. Flujo principal

1. **Administrador:** Abre la configuración de alertas.
2. **Sistema:** Presenta las reglas disponibles, por ejemplo antigüedad del vencimiento o importe pendiente acumulado.
3. **Administrador:** Elige un tipo de regla y establece los valores de sus parámetros.
4. **Sistema:** Valida que los valores y la condición pertenecen al conjunto de reglas admitido.
5. **Sistema:** Muestra cómo quedará definida la alerta y solicita confirmación.
6. **Administrador:** Confirma la configuración.
7. **Sistema:** Guarda la regla para que se evalúe cuando corresponda.
8. **Sistema:** Muestra la alerta configurada y la deja disponible para su administración futura.

---

### 4. Flujos alternativos

#### FA-1 — Modificar o desactivar una regla existente

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador elige editar o desactivar una regla ya registrada.

1. El Administrador selecciona una alerta previamente configurada.
2. Cambia un umbral permitido o desactiva la regla, según sus permisos.
3. El sistema valida y registra el nuevo estado sin convertirlo en un proceso BPMN abierto.

**Continuación:** El caso de uso continúa en el paso 4 del flujo principal para validar y después guardar el cambio.

---

### 5. Flujos de excepción

#### FE-1 — Parámetro inválido o regla no admitida

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Los parámetros no son válidos o se solicita un tipo de regla no admitido.

1. El Administrador introduce un umbral que no es válido o intenta definir un tipo de condición no contemplado.
2. El sistema rechaza la configuración y explica la restricción.
3. El Administrador corrige los parámetros o selecciona otra regla disponible.

**Resultado:** No se registra la configuración inválida.

#### FE-2 — Falta permiso para cambiar la alerta

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El usuario carece de permisos para modificar las reglas corporativas.

1. El usuario intenta alterar una regla corporativa sin tener autorización.
2. El sistema bloquea el cambio.
3. La configuración vigente no se modifica.

**Resultado:** La configuración existente se conserva sin cambios.

---

### 6. Postcondiciones

- POST-1. La regla de alerta queda creada, modificada o desactivada según la decisión válida.
- POST-2. Las evaluaciones posteriores utilizarán los parámetros vigentes.
- POST-3. La evaluación de las reglas por el Planificador, la entrega de alertas y los canales personales se gestionan en CU-23.

---

## CU-25 — Gestionar incidencias y comentarios

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-25 |
| **Nombre** | Gestionar incidencias y comentarios |
| **Objetivo** | Registrar y resolver incidencias administrativas asociadas a clientes o facturas, con responsables, prioridad, comentarios internos y adjuntos. |
| **Actores participantes** | Principal: Usuario operativo. Otros participantes: CU-19 invoca este caso mediante «include» cuando un correo rebota. |

---

### 2. Precondiciones

- PRE-1. El Usuario operativo está autenticado y puede acceder al cliente o factura de la incidencia.
- PRE-2. Existe una ficha de cliente y, si corresponde, una factura con la que relacionar la incidencia.

---

### 3. Flujo principal

1. **Usuario operativo:** Entra en la ficha o factura y selecciona crear incidencia.
2. **Sistema:** Solicita descripción, responsable, estado, prioridad y datos de seguimiento de la incidencia.
3. **Usuario operativo:** Introduce los datos y asocia la incidencia con el elemento correspondiente.
4. **Sistema:** Valida la información y el ámbito de permisos.
5. **Usuario operativo:** Confirma el registro.
6. **Sistema:** Crea la incidencia, la vincula con el cliente y, cuando proceda, con la factura, y la muestra entre los asuntos pendientes.
7. **Usuario operativo:** Puede incorporar comentarios internos y adjuntos permitidos; las menciones a usuarios generan sus notificaciones.
8. **Sistema:** Guarda las actuaciones y muestra el estado actualizado de la incidencia.

---

### 4. Flujos alternativos

#### FA-1 — Incidencia de entrega incluida desde CU-19

**Se produce en:** paso 1 del flujo principal.  
**Condición:** CU-19 requiere crear una incidencia de entrega a partir de un rebote de correo.

1. CU-19 detecta un rebote y solicita registrar una incidencia de entrega.
2. El sistema crea la incidencia con la factura, el destinatario y la información del fallo que conoce.
3. La incidencia queda disponible para que el responsable la consulte y la resuelva desde este caso de uso.

**Continuación:** El caso de uso continúa en el paso 4 del flujo principal con los datos del fallo ya disponibles y registra la incidencia.

#### FA-2 — Añadir comentario con mención

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El Usuario operativo menciona a un usuario en un comentario interno.

1. El Usuario operativo abre una incidencia o elemento autorizado y escribe un comentario interno.
2. Incluye una mención a otro usuario cuando corresponda.
3. El sistema conserva el comentario sin enviarlo al cliente y genera la notificación interna prevista por FR-36.

**Continuación:** El caso de uso continúa en el paso 8 del flujo principal tras guardar el comentario y generar la notificación de la mención.

#### FA-3 — Actualizar o cerrar una incidencia

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se selecciona una incidencia existente para modificarla o cerrarla.

1. El Usuario operativo selecciona una incidencia existente y modifica su estado, prioridad, responsable o información de seguimiento.
2. Cuando procede, registra que la incidencia ha quedado resuelta.
3. El sistema guarda la actualización y mantiene el historial relevante del asunto.

**Continuación:** Finaliza con su estado y resolución registrados, cuando proceda.

---

### 5. Flujos de excepción

#### FE-1 — Adjunto no permitido o no accesible

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Un adjunto supera las restricciones de tipo, tamaño o autorización.

1. El actor intenta subir un adjunto incompatible con las restricciones aplicables o acceder a uno que no puede consultar.
2. El sistema rechaza la operación e informa de la causa sin divulgar documentos ajenos.
3. La incidencia permanece sin cambios en ese adjunto.

**Resultado:** Se rechaza el archivo; la incidencia puede mantenerse sin él.

#### FE-2 — Datos imprescindibles insuficientes

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No se identifican cliente, asunto o datos esenciales de la incidencia.

1. La incidencia no tiene información mínima para identificar el asunto, responsable o estado que exige el formulario.
2. El sistema señala los campos pendientes y no confirma el alta.
3. El Usuario operativo corrige la información y vuelve a guardarla.

**Resultado:** No se registra una incidencia incompleta; se solicita corrección.

---

### 6. Postcondiciones

- POST-1. La incidencia queda creada, actualizada o resuelta, vinculada a su cliente y factura cuando corresponda.
- POST-2. Los comentarios permanecen internos y las menciones generan avisos a los usuarios autorizados.
- POST-3. Los adjuntos e incidencias conservan sus restricciones de acceso.

---

## CU-26 — Generar, exportar y conservar informes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-26 |
| **Nombre** | Generar, exportar y conservar informes |
| **Objetivo** | Obtener informes de facturación y cobros filtrados, exportarlos y consultarlos durante el periodo de conservación permitido, siempre según los permisos del usuario. |
| **Actores participantes** | Principal: Usuario operativo. |

---

### 2. Precondiciones

- PRE-1. El Usuario operativo está autenticado; los datos solicitados y la exportación quedan sujetos a comprobación de permisos.
- PRE-2. Existen datos de facturación para el periodo solicitado.

---

### 3. Flujo principal

1. **Usuario operativo:** Entra en el apartado de informes.
2. **Sistema:** Presenta filtros por periodo, cliente, responsable, país, sector, estado de factura, tipo y moneda.
3. **Usuario operativo:** Selecciona los filtros y solicita generar el informe.
4. **Sistema:** Valida los criterios y delimita los datos al ámbito autorizado del usuario.
5. **Sistema:** Calcula los resultados y genera una presentación consultable del informe.
6. **Sistema:** Muestra las cifras y el detalle permitido, junto con las opciones de exportación.
7. **Usuario operativo:** Selecciona CSV o PDF legible y confirma la exportación.
8. **Sistema:** Crea el archivo autorizado, lo pone a disposición mediante acceso autenticado y registra el informe con su periodo de conservación.

---

### 4. Flujos alternativos

#### FA-1 — Consultar un informe previamente generado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Usuario operativo abre un informe conservado, en lugar de crear uno nuevo.

1. El Usuario operativo accede a la relación de informes que puede consultar.
2. Selecciona un informe existente dentro de su plazo de conservación.
3. El sistema comprueba de nuevo sus permisos y ofrece el archivo o un enlace autenticado válido.

**Continuación:** Finaliza con el informe accesible según sus permisos actuales.

#### FA-2 — Regenerar un informe expirado o no conservado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita regenerar un informe cuyo archivo temporal ya no se conserva.

1. El informe generado ya no está almacenado por haberse cumplido el plazo configurable.
2. El sistema comprueba si conserva los datos necesarios y si el Usuario operativo mantiene los permisos.
3. Cuando ambas condiciones se cumplen, regenera el informe a partir de los criterios pertinentes.

**Continuación:** El caso de uso continúa en el paso 3 del flujo principal con los filtros autorizados guardados y genera una versión nueva cuando procede.

#### FA-3 — Informe de alcance global para administradores

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un Administrador autorizado requiere datos de facturación global.

1. Un Administrador o Superadministrador autorizado aplica filtros al conjunto global de facturación.
2. El sistema permite los resultados completos propios de sus permisos.
3. La exportación incluye únicamente los datos que puede consultar ese rol.

**Continuación:** El caso de uso continúa en el paso 5 del flujo principal con el ámbito global habilitado para ese usuario.

#### FA-4 — Informe pesado en segundo plano

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El informe requiere un procesamiento largo.

1. El sistema lo genera en segundo plano y el Usuario operativo puede seguir trabajando.
2. Muestra su estado: pendiente, procesando o completado con errores.
3. Notifica al Usuario operativo cuando está listo; la tarea no depende de que la pestaña siga abierta.

**Continuación:** El caso de uso continúa en el paso 6 del flujo principal cuando el informe está disponible.

---

### 5. Flujos de excepción

#### FE-1 — Intento de exportar información no autorizada

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La exportación incluye datos ajenos a los permisos del solicitante.

1. El usuario solicita clientes o datos que exceden su ámbito de acceso.
2. El sistema restringe o rechaza la consulta y la exportación en el servidor.
3. No entrega información ajena aunque se alteren manualmente los parámetros del filtro o el enlace.

**Resultado:** Se restringe o deniega la información no autorizada y no se genera una filtración.

#### FE-2 — No puede regenerarse el informe

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Los datos o permisos actuales impiden regenerar un informe antiguo.

1. El informe ha caducado y ya no existen los datos necesarios, o el actor ha perdido permisos.
2. El sistema informa de que no es posible regenerarlo en esas condiciones.
3. No muestra un archivo histórico al que el actor ya no está autorizado a acceder.

**Resultado:** No se genera un informe sin soporte válido y se explica el motivo.

#### FE-3 — Sin datos para los filtros

**Se produce en:** paso 5 del flujo principal.  
**Condición:** No existen datos que cumplan los filtros elegidos.

1. El sistema lo indica y sugiere ampliar los filtros.
2. No genera ningún archivo.

**Resultado:** No se crea el informe; pueden ajustarse los filtros.

---

### 6. Postcondiciones

- POST-1. El informe queda generado o consultado conforme a los filtros y al ámbito autorizado.
- POST-2. Las exportaciones admitidas se ofrecen como CSV o PDF con acceso autenticado.
- POST-3. Los archivos de informe siguen una conservación configurable distinta de la de las facturas emitidas.

---

## CU-27 — Consultar dashboard financiero

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-27 |
| **Nombre** | Consultar dashboard financiero |
| **Objetivo** | Permitir al Administrador comprobar indicadores de facturación y cobro y acceder al detalle que justifica cada cifra. |
| **Actores participantes** | Principal: Administrador. |

---

### 2. Precondiciones

- PRE-1. El Administrador ha iniciado sesión; el acceso a indicadores financieros globales se verifica al abrir el panel.
- PRE-2. Existen datos de facturas y cobros que permitan calcular los indicadores.

---

### 3. Flujo principal

1. **Administrador:** Abre el dashboard financiero.
2. **Sistema:** Obtiene los importes y estados de facturación y cobro que corresponde mostrar.
3. **Sistema:** Presenta las cifras actuales, entre ellas importes facturados, cobrados, pendientes o vencidos, según los indicadores disponibles.
4. **Administrador:** Selecciona un periodo o filtro de empresa cuando lo necesita.
5. **Sistema:** Recalcula las cifras a partir de los datos incluidos en el filtro, respetando moneda y reglas de suma aplicables.
6. **Administrador:** Selecciona una cifra para consultar qué registros contribuyen a ella.
7. **Sistema:** Muestra el desglose de facturas o cobros que componen el indicador.
8. **Administrador:** Examina los registros y vuelve al resumen cuando termina.

---

### 4. Flujos alternativos

#### FA-1 — Consultar otra métrica o desglosarla

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El Administrador selecciona otra cifra o un desglose distinto del dashboard.

1. El Administrador selecciona un indicador diferente o modifica los filtros.
2. El sistema actualiza tanto el importe agregado como los detalles subyacentes.
3. Las cifras continúan derivándose de los mismos datos que componen el desglose mostrado.

**Continuación:** El caso de uso continúa en el paso 7 del flujo principal para presentar el detalle seleccionado.

#### FA-2 — Presentar cifras de distintas monedas

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La información a representar incluye importes emitidos en distintas monedas.

1. Los registros consultados contienen facturas emitidas en monedas diferentes.
2. El sistema conserva los importes legales en su moneda original y, si aplica conversiones para el informe, utiliza las referencias registradas para reporting.
3. La presentación no modifica ni reescribe los importes originales de ninguna factura.

**Continuación:** El caso de uso continúa en el paso 6 del flujo principal después de aplicar las reglas de reporting y conservar las monedas originales.

#### FA-3 — Comparar con objetivos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador activa la comparación con los objetivos de facturación o cobro.

1. El sistema muestra las cifras reales junto al objetivo vigente para el periodo.
2. La comparación es informativa y no altera ningún dato.

**Continuación:** El caso de uso continúa en el paso 5 del flujo principal.

#### FA-4 — Agrupar por centro de coste

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador quiere ver las cifras por centro de coste o proyecto.

1. El sistema agrupa las cifras por categoría.
2. Cada grupo mantiene el desglose hasta las facturas que lo componen.

**Continuación:** El caso de uso continúa en el paso 6 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Información insuficiente para una cifra

**Se produce en:** paso 5 del flujo principal.  
**Condición:** No pueden reconciliarse los datos que componen un indicador.

1. El sistema carece de los datos necesarios para calcular un indicador de forma fiable.
2. Muestra la limitación en lugar de presentar una cifra inventada.
3. El Administrador puede consultar los registros o comunicar la incidencia.

**Resultado:** Se advierte que el valor no está disponible o requiere revisión y no se presenta como exacto.

#### FE-2 — Acceso no autorizado al dashboard global

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario no tiene acceso al dashboard financiero global.

1. Un usuario sin permisos globales intenta abrir el panel o su detalle por enlace directo.
2. El sistema deniega el acceso.
3. No revela información financiera del conjunto de clientes.

**Resultado:** No se revela información financiera global.

#### FE-3 — Filtro inválido

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador introduce un rango de fechas u otro criterio no válido.

1. El sistema detecta que el filtro no es válido.
2. No aplica el filtro e indica qué debe corregirse.
3. Mantiene las cifras que se estaban mostrando.

**Resultado:** El caso de uso regresa al paso 4 del flujo principal sin alterar la vista anterior.

---

### 6. Postcondiciones

- POST-1. El Administrador consulta indicadores financieros y sus desgloses correspondientes.
- POST-2. No se modifica ningún importe ni factura mediante esta consulta.
- POST-3. Cada cifra presentada se corresponde con un conjunto identificable de registros de origen.

---

## CU-28 — Gestionar objetivos y centros de coste

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-28 |
| **Nombre** | Gestionar objetivos y centros de coste |
| **Objetivo** | Definir objetivos informativos de facturación y clasificaciones de clientes o facturas por centros de coste o proyectos para su uso posterior en informes. |
| **Actores participantes** | Principal: Administrador. |

---

### 2. Precondiciones

- PRE-1. El Administrador ha iniciado sesión; el permiso para cambiar objetivos o categorías se verifica al guardar.
- PRE-2. El sistema dispone del área de configuración de informes y categorías.

---

### 3. Flujo principal

1. **Administrador:** Abre la gestión de objetivos y centros de coste.
2. **Sistema:** Muestra los objetivos de facturación vigentes y las categorías o proyectos existentes.
3. **Administrador:** Selecciona establecer o modificar un objetivo de facturación.
4. **Administrador:** Introduce el valor y el periodo aplicable y revisa su finalidad exclusivamente informativa.
5. **Sistema:** Valida el dato y presenta la comparación con el objetivo anterior cuando existe.
6. **Administrador:** Confirma la operación.
7. **Sistema:** Conserva quién realizó el cambio, la fecha y los valores anterior y nuevo.
8. **Sistema:** Muestra el objetivo actualizado, que podrá visualizarse en el dashboard sin alterar las facturas.

---

### 4. Flujos alternativos

#### FA-1 — Crear o modificar un centro de coste o proyecto

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador quiere mantener centros de coste o proyectos, en vez de objetivos.

1. El Administrador selecciona la gestión de categorías y crea o edita el nombre de una categoría.
2. El sistema valida y guarda la modificación.
3. Las facturas y clientes previamente clasificados mantienen su asociación histórica aunque cambie el nombre visible.

**Continuación:** Finaliza con la categoría creada o modificada conservando su histórico.

#### FA-2 — Clasificar un cliente o factura

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se solicita asignar un centro de coste o proyecto a una ficha o factura.

1. El Administrador autorizado selecciona un cliente o factura y una categoría de centro de coste o proyecto.
2. El sistema registra la clasificación para su posterior filtrado en informes.
3. No cambia importes, impuestos ni el documento original por el hecho de clasificarlo.

**Continuación:** Finaliza con la clasificación registrada sin alterar el total legal de la factura.

---

### 5. Flujos de excepción

#### FE-1 — Objetivo o categoría inválidos

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El objetivo o categoría contiene valores inválidos.

1. El valor del objetivo o los datos de la categoría no son admisibles.
2. El sistema informa de la validación fallida y no guarda el dato incorrecto.
3. El Administrador revisa y corrige la propuesta.

**Resultado:** No se guarda el cambio y se solicita corregir los parámetros.

#### FE-2 — Modificación sin autorización

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El actor carece de permiso para modificar el objetivo o categoría.

1. El actor intenta cambiar objetivos o categorías sin permiso.
2. El sistema rechaza la operación.
3. Se conservan los valores vigentes y las asociaciones existentes.

**Resultado:** Se mantiene la configuración previa sin afectar facturas.

#### FE-3 — Eliminar una categoría con información asociada

**Se produce en:** paso 1 de FA-1.  
**Condición:** Se intenta eliminar un centro de coste o proyecto que tiene clientes o facturas asociados.

1. El sistema impide la eliminación.
2. Ofrece desactivar la categoría en su lugar.
3. Las asociaciones históricas se conservan.

**Resultado:** La categoría no se elimina y el histórico permanece intacto.

---

### 6. Postcondiciones

- POST-1. Los objetivos y categorías quedan actualizados conforme a la autorización.
- POST-2. Los cambios de objetivos tienen registro de autor, fecha y valores anterior y nuevo.
- POST-3. La clasificación se refleja en informes sin reconstruir ni alterar facturas históricas.

---

## CU-29 — Consultar pantalla de trabajo diario

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-29 |
| **Nombre** | Consultar pantalla de trabajo diario |
| **Objetivo** | Ofrecer a cada usuario un resumen de los asuntos de facturación y seguimiento que requieren su atención, con acceso al registro correspondiente. |
| **Actores participantes** | Principal: Usuario operativo. |

---

### 2. Precondiciones

- PRE-1. El Usuario operativo ha iniciado sesión y tiene asignaciones y permisos que determinan su ámbito de trabajo.
- PRE-2. El sistema dispone de los estados actuales de facturas, cobros, entregas, aprobaciones y tareas.

---

### 3. Flujo principal

1. **Usuario operativo:** Inicia sesión y accede a su pantalla de trabajo diario.
2. **Sistema:** Consulta las facturas próximas a vencer o vencidas que el usuario puede atender.
3. **Sistema:** Reúne pagos pendientes de conciliación, problemas de entrega, solicitudes de aprobación y tareas según sus permisos.
4. **Sistema:** Muestra los asuntos con información suficiente para reconocer su tipo y situación.
5. **Usuario operativo:** Identifica una tarea o incidencia que necesita revisar.
6. **Usuario operativo:** Selecciona el acceso directo al cliente, factura, pago o asunto correspondiente.
7. **Sistema:** Comprueba la autorización actual y abre el elemento en la función que lo gestiona.
8. **Usuario operativo:** Continúa su actuación en el caso de uso correspondiente, sin que la navegación cambie automáticamente el estado del asunto.

---

### 4. Flujos alternativos

#### FA-1 — Vista de un Administrador

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario que consulta la pantalla tiene rol de Administrador y permiso global.

1. Un Administrador abre su pantalla de trabajo diario.
2. El sistema puede incluir asuntos de su ámbito, como aprobaciones pendientes, además de los elementos operativos permitidos.
3. Los accesos directos llevan a la función correspondiente con comprobación de permisos.

**Continuación:** El caso de uso continúa en el paso 2 del flujo principal con la información adicional de su bandeja global.

#### FA-2 — No existen asuntos pendientes

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No existen asuntos que el usuario deba atender.

1. No se encuentra ninguna factura, pago, tarea o incidencia que requiera atención del usuario.
2. El sistema muestra la pantalla sin elementos pendientes y lo indica claramente.
3. El Usuario operativo puede continuar consultando otras funciones autorizadas.

**Continuación:** Finaliza mostrando la bandeja vacía sin generar tareas nuevas.

---

### 5. Flujos de excepción

#### FE-1 — Elemento reasignado o sin acceso

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El usuario ya no dispone de acceso por una reasignación o cambio de permisos.

1. El usuario pulsa un acceso directo a un asunto cuya asignación o autorización ha cambiado.
2. El sistema vuelve a comprobar permisos antes de mostrarlo.
3. Si ya no tiene acceso, rechaza la apertura sin divulgar su contenido.

**Resultado:** Se deniega la apertura y se actualiza la vista permitida.

#### FE-2 — Error al actualizar la pantalla

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La información de la bandeja no puede actualizarse.

1. No pueden obtenerse temporalmente los estados de una o varias fuentes.
2. El sistema muestra el resto de secciones e indica cuál no ha podido cargarse.
3. El usuario puede reintentar la consulta sin modificar el estado de los asuntos.

**Resultado:** Se muestra el error sin dar por resueltos asuntos que siguen pendientes.

#### FE-3 — Elemento ya resuelto

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Otro usuario ha resuelto el asunto mientras tanto.

1. El sistema informa del estado actual del elemento.
2. Lo retira de la lista de pendientes.

**Resultado:** La pantalla se actualiza sin abrir un asunto ya cerrado.

---

### 6. Postcondiciones

- POST-1. El usuario obtiene una vista de los asuntos que puede atender con accesos directos autorizados.
- POST-2. Consultar o navegar no implica resolver automáticamente una tarea ni una incidencia.
- POST-3. El alcance de los datos está limitado por el rol y las asignaciones vigentes.

# Bloque F. Administración, seguridad y sistema

## CU-30 — Iniciar sesión y recuperar contraseña

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-30 |
| **Nombre** | Iniciar sesión y recuperar contraseña |
| **Objetivo** | Permitir el acceso seguro a la plataforma con cuenta corporativa y recuperar la contraseña de forma segura. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario tiene una cuenta activa creada por invitación (CU-31).

---

### 3. Flujo principal

*Escenario descrito: iniciar sesión.*

1. **Usuario operativo:** Accede a la plataforma e introduce su correo corporativo y su contraseña.
2. **Sistema:** Valida el dominio autorizado, las credenciales y que la cuenta está activa.
3. **Sistema:** Crea una sesión segura.
4. **Sistema:** Muestra la pantalla de trabajo diario (CU-29).

---

### 4. Flujos alternativos

#### FA-1 — Recuperar la contraseña

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona «He olvidado mi contraseña» e introduce su correo.

1. **Usuario operativo:** Selecciona «He olvidado mi contraseña» e introduce su correo.
2. **Sistema:** Envía un enlace temporal de recuperación, que caduca a la hora de enviarse (A-04), y responde de la misma forma exista o no la cuenta.
3. **Usuario operativo:** Abre el enlace e introduce una nueva contraseña.
4. **Sistema:** Guarda la contraseña, invalida el enlace y las sesiones anteriores, y registra el cambio.

**Continuación:** el caso de uso finaliza y el usuario puede iniciar sesión desde el paso 1 del flujo principal.

#### FA-2 — Doble factor opcional

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario tiene activado el doble factor.

1. **Usuario operativo:** Tiene activado el doble factor.
2. **Sistema:** Solicita el segundo factor antes de crear la sesión.

**Continuación:** el caso de uso continúa en el paso 3 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Credenciales incorrectas

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El correo o la contraseña no son correctos.

1. **Sistema:** Rechaza el acceso con un mensaje genérico que no revela qué dato falló.

**Resultado:** El usuario puede volver a intentarlo desde el paso 1 del flujo principal.

#### FE-2 — Cuenta no autorizada o desactivada

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El dominio no está autorizado o la cuenta está desactivada.

1. **Sistema:** Rechaza el acceso. No existe el autorregistro.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

#### FE-3 — Demasiados intentos fallidos

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario supera el número de intentos fallidos permitido.

1. **Usuario operativo:** Supera el número de intentos fallidos permitido.
2. **Sistema:** Bloquea temporalmente el acceso y lo registra.

**Resultado:** El acceso queda bloqueado temporalmente.

#### FE-4 — Enlace caducado

**Se produce en:** FA-1 (recuperación de contraseña).  
**Condición:** El enlace de recuperación ha caducado o ya se usó.

1. **Sistema:** Lo indica y permite solicitar un nuevo enlace.

**Resultado:** El usuario puede solicitar un nuevo enlace desde el paso 1 de FA-1.

---

### 6. Postcondiciones

- POST-1. El usuario tiene una sesión activa o ha cambiado su contraseña de forma segura.
- POST-2. Los accesos fallidos y los cambios de contraseña quedan registrados.

---

## CU-31 — Gestionar usuarios, roles y asignación de clientes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-31 |
| **Nombre** | Gestionar usuarios, roles y asignación de clientes |
| **Objetivo** | Dar de alta usuarios por invitación, asignarles rol y clientes, y desactivarlos cuando proceda. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior y tiene permiso para gestionar usuarios.

---

### 3. Flujo principal

*Escenario descrito: invitar a un usuario.*

1. **Administrador:** Selecciona «Invitar usuario».
2. **Sistema:** Solicita el correo corporativo y el rol.
3. **Administrador:** Los introduce.
4. **Sistema:** Valida que el dominio está autorizado, que el usuario no existe y que el rol puede concederse.
5. **Sistema:** Envía la invitación por correo.
6. **Usuario invitado:** Activa su cuenta y define su contraseña.
7. **Administrador:** Asigna clientes al usuario.
8. **Sistema:** Guarda la asignación y la registra.

---

### 4. Flujos alternativos

#### FA-1 — Cambiar el rol

**Se produce en:** después del paso 8 del flujo principal (usuario ya creado).  
**Condición:** El Administrador cambia el rol de un usuario.

1. **Administrador:** Cambia el rol de un usuario.
2. **Sistema:** Aplica los nuevos permisos, comprobados en servidor, y lo registra.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Desactivar una cuenta

**Se produce en:** después del paso 8 del flujo principal (usuario ya creado).  
**Condición:** El Administrador desactiva una cuenta.

1. **Administrador:** Desactiva una cuenta.
2. **Sistema:** Impide nuevos accesos, invalida las sesiones activas y conserva la cuenta y su rastro histórico.

**Continuación:** el caso de uso finaliza.

#### FA-3 — Reasignar clientes

**Se produce en:** después del paso 8 del flujo principal (usuario ya creado).  
**Condición:** El Administrador reasigna clientes de un usuario a otro.

1. **Administrador:** Reasigna clientes de un usuario a otro.
2. **Sistema:** Las tareas pendientes de esos clientes pasan al nuevo responsable (CU-04, FA-3).

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Correo no corporativo

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El dominio no está autorizado.

1. **Sistema:** No envía la invitación e indica el motivo.

**Resultado:** El Administrador puede corregir el correo y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Usuario ya existente

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Ya existe una cuenta con ese correo.

1. **Sistema:** No crea un duplicado e indica el estado de la cuenta existente.

**Resultado:** El caso de uso termina sin crear un duplicado.

#### FE-3 — Rol no permitido

**Se produce en:** paso 4 del flujo principal y FA-1.  
**Condición:** El Administrador intenta conceder o modificar el rol Superadministrador.

1. **Administrador:** Intenta conceder o modificar el rol Superadministrador.
2. **Sistema:** Lo impide (A-14).

**Resultado:** El caso de uso termina sin realizar la operación.

#### FE-4 — Sin permiso para gestionar usuarios

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un Administrador sin permiso de gestión de usuarios intenta realizar la operación.

1. **Administrador:** Intenta gestionar usuarios sin tener ese permiso.
2. **Sistema:** Rechaza la operación (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. El usuario queda invitado, con rol y clientes asignados, o desactivado, según el flujo.
- POST-2. Los cambios quedan en el registro de auditoría.

---

## CU-32 — Ejecutar acción masiva

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-32 |
| **Nombre** | Ejecutar acción masiva |
| **Objetivo** | Aplicar una misma operación a varios elementos a la vez, con confirmación explícita del alcance y controles adicionales. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior y tiene permiso sobre los elementos afectados.

---

### 3. Flujo principal

1. **Administrador:** Selecciona los elementos mediante filtro o selección manual.
2. **Administrador:** Elige la acción masiva (por ejemplo, reasignar clientes o etiquetarlos).
3. **Sistema:** Muestra el número exacto de elementos afectados y un resumen de la acción.
4. **Administrador:** Confirma de forma explícita.
5. **Sistema:** Ejecuta la acción sobre todos los elementos.
6. **Sistema:** Muestra el resumen del resultado.
7. **Sistema:** Registra la operación en el registro de auditoría.

---

### 4. Flujos alternativos

#### FA-1 — Cancelar

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador cancela.

1. **Administrador:** Cancela.
2. **Sistema:** No modifica ningún dato.

**Continuación:** el caso de uso finaliza sin modificar ningún dato.

#### FA-2 — Acción de alto impacto económico

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La acción tiene alto impacto económico.

1. **Sistema:** Exige controles adicionales: una confirmación reforzada y la aprobación de otra persona distinta de quien la solicita (A-17).

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Selección vacía

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La selección no contiene elementos.

1. **Sistema:** No permite continuar.

**Resultado:** El Administrador debe seleccionar al menos un elemento y el caso de uso regresa al paso 1 del flujo principal.

#### FE-2 — Elementos no permitidos

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La selección incluye elementos sobre los que el usuario no tiene permiso.

1. **Sistema:** Los excluye o impide la acción e indica el motivo.

**Resultado:** El caso de uso continúa en el paso 4 del flujo principal solo con los elementos permitidos, o termina si no queda ninguno.

#### FE-3 — Fallo durante la ejecución

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La ejecución falla.

1. **Sistema:** Revierte la acción completa, no deja datos a medias y muestra el error (A-18).

**Resultado:** Ningún elemento queda modificado; el Administrador puede reintentar desde el paso 1 del flujo principal.

---

### 6. Postcondiciones

- POST-1. La acción se ha aplicado a todos los elementos confirmados, o a ninguno.
- POST-2. La operación queda registrada, con su alcance exacto y su responsable.

---

## CU-33 — Consultar monitorización y métricas

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-33 |
| **Nombre** | Consultar monitorización y métricas |
| **Objetivo** | Conocer el estado de las tareas automatizadas, las integraciones y las copias de seguridad, y consultar métricas agregadas del sistema. |
| **Actores participantes** | Administrador y Planificador del sistema (principales) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior.

---

### 3. Flujo principal

1. **Administrador:** Accede al panel de monitorización.
2. **Sistema:** Muestra la última ejecución de la generación recurrente, la cola de correos pendientes, los errores de integración recientes y la última copia de seguridad correcta.
3. **Administrador:** Selecciona un elemento con incidencia.
4. **Sistema:** Muestra su detalle con un identificador de error.
5. **Administrador:** Consulta las métricas agregadas del sistema.

---

### 4. Flujos alternativos

#### FA-1 — El Planificador registra resultados

**Se produce en:** cualquier momento (los resultados se registran al finalizar cada tarea automatizada).  
**Condición:** El Planificador del sistema finaliza una tarea automatizada.

1. **Planificador del sistema:** Finaliza una tarea automatizada.
2. **Sistema:** Registra su resultado, que queda disponible en el panel.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Métricas de uso

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Administrador consulta las métricas de uso.

1. **Administrador:** Consulta las métricas de uso.
2. **Sistema:** Las muestra de forma agregada, sin vigilancia individual de empleados.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Sin datos

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Todavía no existe ninguna ejecución registrada.

1. **Sistema:** Lo indica sin mostrar estados engañosos.

**Resultado:** El caso de uso finaliza sin datos que mostrar.

#### FE-2 — Fuente de datos no disponible

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Una fuente no responde.

1. **Sistema:** Muestra el resto del panel e indica qué fuente falla.

**Resultado:** El caso de uso continúa en el paso 3 del flujo principal con las fuentes disponibles.

---

### 6. Postcondiciones

- POST-1. El Administrador conoce el estado operativo del sistema.
- POST-2. La consulta no modifica ningún dato.

---

## CU-34 — Consultar registro de auditoría

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-34 |
| **Nombre** | Consultar registro de auditoría |
| **Objetivo** | Revisar quién hizo qué y cuándo en la plataforma. |
| **Actores participantes** | Superadministrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado como Superadministrador.

---

### 3. Flujo principal

1. **Superadministrador:** Accede al registro de auditoría.
2. **Sistema:** Muestra los eventos más recientes.
3. **Superadministrador:** Filtra por usuario, acción, fecha o entidad (cliente, factura u otra).
4. **Sistema:** Muestra los eventos que cumplen los filtros.
5. **Superadministrador:** Abre un evento.
6. **Sistema:** Muestra quién lo realizó, qué se hizo, cuándo y, si procede, los valores anteriores y nuevos.

---

### 4. Flujos alternativos

#### FA-1 — Consultar el historial de una entidad

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador accede al registro desde una factura o cliente.

1. **Superadministrador:** Accede al registro desde una factura o cliente.
2. **Sistema:** Muestra los eventos de esa entidad.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

#### FA-2 — Consultar un error técnico

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador busca por un identificador de error.

1. **Superadministrador:** Busca por un identificador de error.
2. **Sistema:** Muestra los eventos relacionados.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Sin resultados

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Ningún evento cumple los filtros.

1. **Sistema:** Lo indica.

**Resultado:** El usuario puede ajustar los filtros y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Acceso no autorizado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un usuario con otro rol intenta acceder.

1. **Usuario sin permiso:** Intenta acceder al registro de auditoría.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. El Superadministrador ha consultado los eventos.
- POST-2. El registro es de solo lectura: ningún evento puede modificarse ni borrarse.

---

## CU-35 — Configurar facturación y tarifas

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-35 |
| **Nombre** | Configurar facturación y tarifas |
| **Objetivo** | Mantener los parámetros que rigen la facturación: series, impuestos, tabla de tarifas, umbrales de aprobación y datos del emisor. |
| **Actores participantes** | Superadministrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado como Superadministrador.

---

### 3. Flujo principal

1. **Superadministrador:** Accede a la configuración de facturación.
2. **Sistema:** Muestra los parámetros vigentes (series, impuestos, tabla de tarifas, umbrales de aprobación y datos del emisor).
3. **Superadministrador:** Modifica uno o varios parámetros.
4. **Sistema:** Valida los cambios.
5. **Sistema:** Informa de que se aplicarán solo a las facturas y revisiones futuras.
6. **Superadministrador:** Confirma.
7. **Sistema:** Guarda los cambios con su fecha de efecto y registra el valor anterior y el nuevo.

---

### 4. Flujos alternativos

#### FA-1 — Modificar la tabla de tarifas

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador modifica los rangos y precios.

1. **Superadministrador:** Modifica los rangos y precios.
2. **Sistema:** Valida que los rangos son coherentes y los guarda.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

#### FA-2 — Crear una serie de facturación

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador crea una serie nueva con su numeración inicial.

1. **Superadministrador:** Crea una serie nueva con su numeración inicial.
2. **Sistema:** La guarda y la deja disponible.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Valores inválidos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un valor no es válido (por ejemplo, rangos de tarifa solapados o con huecos).

1. **Sistema:** No guarda e indica qué corregir.

**Resultado:** El Superadministrador corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Serie en uso

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador intenta eliminar una serie con facturas emitidas.

1. **Superadministrador:** Intenta eliminar una serie con facturas emitidas.
2. **Sistema:** Lo impide para preservar la numeración correlativa.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

---

### 6. Postcondiciones

- POST-1. La configuración queda actualizada para las facturas y revisiones futuras.
- POST-2. Las facturas históricas no se alteran.
- POST-3. El cambio queda en el registro de auditoría.

---

## CU-36 — Configurar recordatorios y funciones inteligentes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-36 |
| **Nombre** | Configurar recordatorios y funciones inteligentes |
| **Objetivo** | Definir la cadencia de los recordatorios de pago y activar o desactivar las funciones opcionales de IA. |
| **Actores participantes** | Superadministrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado como Superadministrador.

---

### 3. Flujo principal

1. **Superadministrador:** Accede a la configuración de recordatorios.
2. **Sistema:** Muestra la cadencia vigente: recordatorio previo, recordatorio de vencimiento y frecuencia de los avisos de impago.
3. **Superadministrador:** Modifica los plazos.
4. **Sistema:** Valida que son coherentes entre sí.
5. **Sistema:** Guarda los cambios, que se aplicarán en las siguientes ejecuciones (CU-20), y registra el valor anterior y el nuevo.

---

### 4. Flujos alternativos

#### FA-1 — Activar o desactivar funciones inteligentes

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El Superadministrador activa o desactiva una función inteligente.

1. **Superadministrador:** Activa o desactiva una función inteligente.
2. **Sistema:** Lo guarda y mantiene el funcionamiento normal sin ella (BR-23). Las sugerencias con efecto económico siempre requieren confirmación humana (FR-39).

**Continuación:** el caso de uso finaliza.

#### FA-2 — Vencimiento pactado

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Existen clientes con un vencimiento pactado distinto del general.

1. **Sistema:** Recuerda que el vencimiento pactado con un cliente prevalece sobre el general.
2. **Sistema:** Los clientes con vencimiento pactado no se ven afectados por el cambio del general.

**Continuación:** el caso de uso continúa en el paso 5 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Valores incoherentes

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un plazo es negativo o el recordatorio previo queda posterior al vencimiento.

1. **Sistema:** No guarda e indica qué corregir.

**Resultado:** El Superadministrador corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Servicio de IA no disponible

**Se produce en:** FA-1 (funciones inteligentes).  
**Condición:** El servicio de IA no responde.

1. **Sistema:** Desactiva la función de forma controlada, sigue funcionando sin ella y lo registra en la monitorización.

**Resultado:** El caso de uso continúa sin la función inteligente; el resto del sistema sigue funcionando.

---

### 6. Postcondiciones

- POST-1. La cadencia y las funciones quedan configuradas para las ejecuciones siguientes.
- POST-2. Los avisos ya enviados no se modifican.
- POST-3. El cambio queda en el registro de auditoría.

---

## CU-37 — Consultar datos y operar por API

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-37 |
| **Nombre** | Consultar datos y operar por API |
| **Objetivo** | Permitir que un sistema externo autorizado consulte datos y registre solicitudes controladas sin saltarse las reglas de negocio. |
| **Actores participantes** | Sistema externo (principal) |

---

### 2. Precondiciones

- PRE-1. El sistema externo dispone de credenciales válidas y permisos concedidos.

---

### 3. Flujo principal

*Escenario descrito: consulta.*

1. **Sistema externo:** Se autentica ante la API.
2. **Sistema externo:** Solicita una consulta (por ejemplo, datos de un cliente, sus facturas o su deuda pendiente).
3. **Sistema:** Valida las credenciales y comprueba los permisos en servidor.
4. **Sistema:** Aplica las mismas reglas de negocio que en la aplicación.
5. **Sistema:** Devuelve los datos permitidos.
6. **Sistema:** Registra la petición.

---

### 4. Flujos alternativos

#### FA-1 — Registrar una solicitud controlada

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El Sistema externo envía una solicitud (por ejemplo, de baja de un cliente).

1. **Sistema externo:** Envía una solicitud (por ejemplo, de baja de un cliente).
2. **Sistema:** La registra como pendiente de revisión humana y no modifica directamente los datos ni las recurrencias (BR-22).

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Autenticación inválida

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Las credenciales no son válidas o han caducado.

1. **Sistema:** Rechaza la petición.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

#### FE-2 — Sin permiso

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El sistema externo no tiene permiso sobre ese dato.

1. **Sistema externo:** No tiene permiso sobre ese dato.
2. **Sistema:** Rechaza la petición.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

#### FE-3 — Operación prohibida

**Se produce en:** paso 2 del flujo principal y FA-1.  
**Condición:** El Sistema externo intenta modificar o eliminar directamente una recurrencia o saltarse una aprobación.

1. **Sistema externo:** Intenta modificar o eliminar directamente una recurrencia o saltarse una aprobación.
2. **Sistema:** Rechaza la operación y la registra.

**Resultado:** El sistema externo no obtiene datos ni efectos y el caso de uso termina.

#### FE-4 — Solicitud inválida

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La solicitud está mal formada.

1. **Sistema:** La rechaza e indica el error.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

---

### 6. Postcondiciones

- POST-1. El sistema externo recibe solo los datos permitidos, o su solicitud queda pendiente de revisión humana.
- POST-2. Toda petición queda registrada.

---