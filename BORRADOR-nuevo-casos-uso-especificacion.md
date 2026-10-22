# Especificación de casos de uso

Este documento especifica los casos de uso del **Sistema de facturación de Turbine** (proyecto JIRAFAS). La numeración, los nombres, los actores y las relaciones `<<include>>` / `<<extend>>` siguen el diagrama de casos de uso de Pablo Fernández Carabantes (bloques A–F). Cada caso de uso sigue la plantilla de especificación textual exigida (identificación, precondiciones, flujo principal, flujos alternativos, flujos de excepción y postcondiciones). Las relaciones entre casos de uso y la trazabilidad con `requisitos.md` se recogen en los anexos A y B, y las decisiones de análisis en el anexo C.

## Actores

| Actor | Descripción |
|---|---|
| Usuario operativo | Trabaja sobre los clientes que tiene asignados: los da de alta y gestiona, prepara o emite facturas según su permiso, sigue cobros, registra incidencias y solicita descuentos. |
| Administrador | Gestiona clientes, facturas, cobros, asignaciones y aprobaciones, y consulta el dashboard financiero global. Hereda todo lo del Usuario operativo. |
| Superadministrador | Configura tarifas, series, plazos de recordatorio, umbrales de aprobación y plantillas; consulta la auditoría y aprueba descuentos sobre el umbral. Hereda todo lo del Administrador. |
| Planificador del sistema | Actor técnico que lanza los procesos automáticos (facturación recurrente, recordatorios, sincronización de pagos). |
| Sistema de pagos (Stripe/Revolut) | Sistema externo que informa de los cobros. |
| Proveedor de correo | Servicio externo de envío de comunicaciones (enviado, rebotado, fallido). |
| Sistema externo | Consumidor de la API documentada. |

> Convención del diagrama: cada caso se asocia solo al rol más bajo que puede ejecutarlo; los roles superiores lo heredan.

## Índice de casos de uso

| ID | Nombre | Actor principal |
|---|---|---|
| **A. Clientes y contactos** | | |
| CU-01 | Gestionar cliente y contactos | Usuario operativo |
| CU-02 | Detectar cliente duplicado | (incluido en CU-01 y CU-03) |
| CU-03 | Importar datos por CSV | Usuario operativo |
| CU-04 | Gestionar tareas del cliente | Usuario operativo |
| **B. Suscripciones, tarifas y descuentos** | | |
| CU-05 | Gestionar baja y pausa de suscripción | Usuario operativo / Planificador |
| CU-06 | Revisar y aprobar rango de tarifa anual | Administrador |
| CU-07 | Solicitar descuento | Usuario operativo |
| CU-08 | Aprobar descuento | Administrador |
| CU-09 | Escalar aprobación al Superadministrador | Superadministrador |
| **C. Facturación** | | |
| CU-10 | Gestionar borrador de factura | Usuario operativo |
| CU-11 | Generar facturas recurrentes | Planificador del sistema |
| CU-12 | Emitir factura | Usuario operativo |
| CU-13 | Aprobar factura retenida | Administrador |
| CU-14 | Rectificar, anular o declarar incobrable una factura | Administrador |
| CU-15 | Buscar y consultar facturas y clientes | Usuario operativo |
| **D. Cobros y comunicaciones** | | |
| CU-16 | Registrar movimiento de cobro | Sistema de pagos / Planificador |
| CU-17 | Conciliar pagos | Usuario operativo |
| CU-18 | Enviar comunicación al cliente | Proveedor de correo |
| CU-19 | Gestionar rebote de correo | Usuario operativo / Proveedor de correo |
| CU-20 | Ejecutar flujo de recordatorios e impago | Planificador del sistema |
| CU-21 | Suspender recordatorios de una factura | Usuario operativo |
| CU-22 | Gestionar plantillas de comunicación | Administrador |
| **E. Seguimiento, consulta e informes** | | |
| CU-23 | Gestionar notificaciones y canales | Usuario operativo / Planificador |
| CU-24 | Configurar alertas | Administrador |
| CU-25 | Gestionar incidencias y comentarios | Usuario operativo |
| CU-26 | Generar, exportar y conservar informes | Usuario operativo |
| CU-27 | Consultar dashboard financiero | Administrador |
| CU-28 | Gestionar objetivos y centros de coste | Administrador |
| CU-29 | Consultar pantalla de trabajo diario | Usuario operativo |
| **F. Administración, seguridad y sistema** | | |
| CU-30 | Iniciar sesión y recuperar contraseña | Usuario operativo |
| CU-31 | Gestionar usuarios, roles y asignación de clientes | Administrador |
| CU-32 | Ejecutar acción masiva | Administrador |
| CU-33 | Consultar monitorización y métricas | Administrador / Planificador |
| CU-34 | Consultar registro de auditoría | Superadministrador |
| CU-35 | Configurar facturación y tarifas | Superadministrador |
| CU-36 | Configurar recordatorios y funciones inteligentes | Superadministrador |
| CU-37 | Consultar datos y operar por API | Sistema externo |

---

<!-- Bloque A. Clientes y contactos -->

## CU-01 — Gestionar cliente y contactos

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-01 |
| **Nombre** | Gestionar cliente y contactos |
| **Objetivo** | Dar de alta y mantener la ficha comercial y fiscal de un cliente y sus contactos, para poder asociarle suscripciones y facturarle. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso sobre la gestión de clientes.
- PRE-2. Para editar un cliente existente, este debe estar asignado al usuario (o el usuario ser Administrador o superior).

---

### 3. Flujo principal

*Escenario descrito: alta de cliente.*

1. **Usuario operativo:** Selecciona «Añadir cliente» en el módulo de clientes.
2. **Sistema:** Muestra el formulario de alta, autocompletando los campos recurrentes (país, moneda, vencimiento, tarifa) cuando es posible.
3. **Usuario operativo:** Introduce los datos fiscales (nombre comercial, razón social, NIF o identificador fiscal, domicilio fiscal, país, moneda de trabajo) y la ficha comercial (fecha de inicio, plan o servicio, tarifa acordada, responsable interno, condiciones de pago y, si existe, documento firmado fuera de la plataforma).
4. **Usuario operativo:** Registra al menos un contacto (nombre, correo y tipo: contratación, recepción de facturas o impagos).
5. **Sistema:** Valida el formato de los datos, comprueba posibles duplicados (CU-02) y, si el alta es a mitad de mes, muestra el cálculo del prorrateo de la primera factura antes de confirmar.
6. **Sistema:** Guarda el cliente y sus contactos, y registra el alta en la línea temporal del cliente.
7. **Sistema:** Confirma la operación y muestra la ficha del cliente creado.

---

### 4. Flujos alternativos

#### FA-1 — Editar un cliente existente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario desea modificar un cliente ya existente.

1. **Usuario operativo:** Abre la ficha de un cliente asignado y selecciona «Editar».
2. **Sistema:** Muestra los datos actuales del cliente.
3. **Usuario operativo:** Modifica los datos.
4. **Sistema:** Valida y guarda los cambios, y los registra en la línea temporal.

**Continuación:** el caso de uso continúa en el paso 7 del flujo principal.

#### FA-2 — Gestionar contactos

**Se produce en:** después del paso 7 (desde la ficha del cliente ya creado).  
**Condición:** El usuario necesita añadir, modificar o inactivar un contacto del cliente.

1. **Usuario operativo:** Añade, modifica o marca como inactivo un contacto desde la ficha del cliente.
2. **Sistema:** Permite que un contacto pertenezca a varios clientes.
3. **Sistema:** Al marcar un contacto como inactivo, conserva su histórico y los destinatarios de las facturas ya enviadas.

**Continuación:** el caso de uso finaliza.

#### FA-3 — Etiquetar y marcar como favorito

**Se produce en:** después del paso 7 (desde la ficha del cliente ya creado).  
**Condición:** El usuario desea clasificar el cliente.

1. **Usuario operativo:** Asigna etiquetas al cliente (por ejemplo: estratégico, beta, partner, riesgo de cobro), además del sector y la ubicación, o lo marca como favorito.
2. **Sistema:** Guarda la clasificación. El acceso rápido por favoritos no sustituye la comprobación de permisos.

**Continuación:** el caso de uso finaliza.

#### FA-4 — Excepción comercial explícita

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario registra o solicita una excepción comercial: inicio futuro, primer mes gratuito o facturación sin prorrateo.

1. **Usuario operativo:** Registra o solicita una excepción comercial: inicio futuro, primer mes gratuito o facturación sin prorrateo.
2. **Sistema:** Guarda la excepción de forma explícita en la ficha del cliente. Si tiene efecto económico (primer mes gratuito o facturación sin prorrateo), queda pendiente de aprobación (CU-07 y CU-08) y no se aplica en la facturación hasta ser aprobada (A-10).
3. **Sistema:** Si se trata de un inicio futuro, deja al cliente en estado «pendiente de activación»: no genera facturas ni recordatorios hasta esa fecha.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

#### FA-5 — Datos fiscales aún no disponibles

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario no dispone todavía del identificador fiscal (p. ej. un identificador extranjero).

1. **Sistema:** Permite guardar el cliente, lo marca con «datos fiscales incompletos» e indica qué falta.
2. **Sistema:** No permitirá emitir facturas a ese cliente hasta completar los datos (CU-12, FE-1).

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Posible cliente duplicado

**Se produce en:** paso 5 del flujo principal.  
**Condición:** CU-02 detecta un cliente con el mismo identificador fiscal.

1. **Sistema:** Avisa al usuario y ofrece abrir la ficha existente, sin fusionar nada automáticamente.
2. **Usuario operativo:** Puede cancelar el alta, corregir el identificador o confirmar que se trata de un cliente distinto.

**Resultado:** El usuario cancela el alta, o corrige el identificador y el caso de uso regresa al paso 3 del flujo principal, o confirma que se trata de un cliente distinto y el caso de uso continúa en el paso 6.

#### FE-2 — Datos obligatorios o formato inválido

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Faltan datos obligatorios (salvo el identificador fiscal, ver FA-5) o su formato no es válido.

1. **Sistema:** No guarda y señala exactamente qué campos hay que corregir.
2. **Usuario operativo:** Corrige y reenvía el formulario.

**Resultado:** El usuario corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-3 — Cliente no asignado

**Se produce en:** FA-1 y FA-2 (acceso a un cliente ya existente).  
**Condición:** El usuario intenta acceder a un cliente que no tiene asignado.

1. **Usuario operativo:** Intenta acceder a un cliente que no tiene asignado.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor) e informa de que el cliente no está asignado al usuario.

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. El cliente y sus contactos quedan registrados con su responsable interno y su clasificación.
- POST-2. La línea temporal del cliente refleja el alta o la modificación.
- POST-3. El cliente queda «activo» (o «pendiente de activación» si tiene inicio futuro) y es elegible para suscripciones y facturación.
- POST-4. La acción queda registrada en el registro de auditoría.

---

## CU-02 — Detectar cliente duplicado

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-02 |
| **Nombre** | Detectar cliente duplicado |
| **Objetivo** | Avisar al usuario cuando un cliente que se va a crear o importar puede ya existir, evitando duplicidades sin fusionar registros automáticamente. |
| **Actores participantes** | Usuario operativo (principal; a través de CU-01 o CU-03) |

---

### 2. Precondiciones

- PRE-1. Se está creando o importando un cliente (CU-01 o CU-03).

---

### 3. Flujo principal

1. **Caso de uso invocador (CU-01 o CU-03):** Entrega al sistema el identificador fiscal del cliente.
2. **Sistema:** Normaliza el identificador (mayúsculas, sin espacios ni guiones) y lo compara con los clientes existentes.
3. **Sistema:** No encuentra coincidencias y devuelve «sin duplicados» al caso de uso que lo invocó, que continúa su flujo.

---

### 4. Flujos alternativos

#### FA-1 — Coincidencia encontrada

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El sistema encuentra uno o varios clientes con el mismo identificador fiscal.

1. **Sistema:** Encuentra uno o varios clientes con el mismo identificador fiscal.
2. **Sistema:** Avisa de la posible duplicidad y muestra enlace a la ficha de cada coincidencia.
3. **Usuario operativo:** Decide: cancelar, corregir el identificador o confirmar que es un cliente distinto. El sistema nunca fusiona automáticamente.

**Continuación:** el caso de uso devuelve la decisión del usuario al caso de uso que lo invocó (CU-01 o CU-03), que continúa su flujo.

#### FA-2 — Detección dentro de una importación CSV

**Se produce en:** paso 1 del flujo principal (invocación desde CU-03).  
**Condición:** CU-02 es invocado desde CU-03 durante una importación CSV.

1. **Sistema:** Marca cada fila con posible duplicado en la previsualización.
2. **Usuario operativo:** Decide fila a fila si la importa como cliente nuevo, actualiza de forma explícita el cliente existente, la omite o la corrige.
3. **Sistema:** No fusiona ni actualiza nunca por su cuenta.

**Continuación:** el caso de uso devuelve el resultado a CU-03, que continúa su flujo.

---

### 5. Flujos de excepción

#### FE-1 — Cliente sin identificador fiscal

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El cliente no tiene identificador fiscal (p. ej. un identificador extranjero aún no disponible).

1. **Sistema:** Indica que no puede comprobar duplicados por ese campo.
2. **Usuario operativo:** Puede continuar, asumiendo que la comprobación no se ha realizado.

**Resultado:** El caso de uso devuelve «comprobación no realizada» al caso de uso que lo invocó, que continúa su flujo.

---

### 6. Postcondiciones

- POST-1. El usuario conoce las posibles duplicidades antes de guardar.
- POST-2. No se ha fusionado ni modificado ningún cliente existente.

---

## CU-03 — Importar datos por CSV

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-03 |
| **Nombre** | Importar datos por CSV |
| **Objetivo** | Cargar de forma masiva clientes (y opcionalmente facturas históricas) desde un archivo CSV, controlando errores antes de confirmar. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso de importación.
- PRE-2. Dispone de un archivo CSV con el formato esperado.

---

### 3. Flujo principal

1. **Usuario operativo:** Selecciona «Importar CSV» y sube el archivo.
2. **Sistema:** Valida la estructura (columnas y codificación) y analiza cada fila.
3. **Sistema:** Comprueba posibles duplicados por identificador fiscal (CU-02).
4. **Sistema:** Muestra una previsualización con filas válidas, filas con error (y su motivo) y posibles duplicados.
5. **Usuario operativo:** Corrige los errores o excluye las filas problemáticas.
6. **Sistema:** Indica el número exacto de registros que se van a crear o actualizar y solicita confirmación.
7. **Usuario operativo:** Confirma.
8. **Sistema:** Crea los clientes nuevos y actualiza únicamente aquellos que el usuario marcó explícitamente como actualización de un cliente existente (CU-02, FA-2).
9. **Sistema:** Muestra un resumen con registros creados, actualizados y rechazados, con sus motivos, y registra la operación.

---

### 4. Flujos alternativos

#### FA-1 — Importar facturas históricas

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario indica que el archivo incluye facturas históricas.

1. **Usuario operativo:** Indica que el archivo incluye facturas históricas.
2. **Sistema:** Las importa marcadas como «migradas», con su número y documento original, y sin enviar ninguna notificación al cliente.

**Continuación:** el caso de uso continúa en el paso 2 del flujo principal.

#### FA-2 — Cancelar antes de confirmar

**Se produce en:** cualquier paso anterior al paso 7 del flujo principal.  
**Condición:** El usuario decide cancelar la importación antes de confirmarla.

1. **Usuario operativo:** Cancela la importación.
2. **Sistema:** Descarta la carga sin modificar datos.

**Continuación:** el caso de uso finaliza.

#### FA-3 — Filas sin identificador fiscal

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Una fila no incluye identificador fiscal.

1. **Sistema:** No puede comprobar duplicados en esa fila (CU-02, FE-1), la marca como «datos fiscales incompletos» en la previsualización (A-05) y permite importarla.
2. **Sistema:** Esa fila no podrá facturarse hasta completar los datos (CU-12, FE-1).

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Archivo inválido

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El archivo no es un CSV válido o faltan columnas obligatorias.

1. **Sistema:** Rechaza la carga e indica qué falta.
2. **Usuario operativo:** Corrige el archivo y vuelve a subirlo.

**Resultado:** El usuario corrige el archivo y el caso de uso regresa al paso 1 del flujo principal.

#### FE-2 — Todas las filas rechazadas

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Ninguna fila es válida.

1. **Sistema:** No permite confirmar y muestra los motivos de rechazo.

**Resultado:** El caso de uso no puede continuar; el usuario puede cancelar o corregir el archivo y repetir desde el paso 1 del flujo principal.

#### FE-3 — Fallo durante la importación

**Se produce en:** paso 8 del flujo principal.  
**Condición:** Se produce un error técnico durante la importación.

1. **Sistema:** Revierte la operación completa para no dejar registros a medias, registra el error con identificador y lo muestra al usuario.
2. **Usuario operativo:** Puede corregir la causa y volver a lanzar la importación.

**Resultado:** No se ha modificado ningún dato; si el usuario repite la importación, el caso de uso regresa al paso 1 del flujo principal.

---

### 6. Postcondiciones

- POST-1. Los clientes válidos quedan creados, y los marcados explícitamente como actualización quedan actualizados.
- POST-2. La operación queda registrada con su resumen y el usuario que la realizó.
- POST-3. Las facturas históricas importadas quedan marcadas como migradas y no generan notificaciones.

---

## CU-04 — Gestionar tareas del cliente

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-04 |
| **Nombre** | Gestionar tareas del cliente |
| **Objetivo** | Registrar y seguir tareas pendientes asociadas a un cliente, de modo que no se pierdan cuando cambie su responsable. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado.
- PRE-2. El cliente está asignado al usuario (o el usuario es Administrador o superior).

---

### 3. Flujo principal

*Escenario descrito: crear una tarea.*

1. **Usuario operativo:** Abre la ficha de un cliente asignado y accede a la sección de tareas.
2. **Sistema:** Muestra las tareas pendientes y completadas del cliente.
3. **Usuario operativo:** Selecciona «Añadir tarea».
4. **Usuario operativo:** Introduce la descripción de la tarea y, opcionalmente, una fecha prevista.
5. **Sistema:** Valida los datos.
6. **Sistema:** Guarda la tarea asociada al cliente (no al usuario) y la registra en la línea temporal del cliente.
7. **Sistema:** Muestra la tarea en la ficha y en la pantalla de trabajo diario del responsable interno del cliente (CU-29).

---

### 4. Flujos alternativos

#### FA-1 — Editar una tarea

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario selecciona una tarea pendiente y la edita.

1. **Usuario operativo:** Selecciona una tarea pendiente y la edita.
2. **Sistema:** Valida y guarda los cambios, y los registra en la línea temporal.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Completar una tarea

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario marca una tarea como completada.

1. **Usuario operativo:** Marca una tarea como completada.
2. **Sistema:** La conserva como completada, registrando quién y cuándo, y la retira de la pantalla de trabajo diario.

**Continuación:** el caso de uso finaliza.

#### FA-3 — Cambio de responsable del cliente

**Se produce en:** cualquier momento posterior al paso 6 del flujo principal (cambio de responsable en CU-31).  
**Condición:** Un Administrador cambia el responsable interno del cliente (CU-31).

1. **Administrador:** Cambia el responsable interno del cliente (CU-31).
2. **Sistema:** Las tareas pendientes, al estar asociadas al cliente, pasan automáticamente a su nuevo responsable sin intervención del usuario.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Datos inválidos

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La descripción está vacía o la fecha prevista no es válida.

1. **Sistema:** No guarda e indica qué campo hay que corregir.
2. **Usuario operativo:** Corrige y reenvía.

**Resultado:** El usuario corrige la causa y el caso de uso regresa al paso 4 del flujo principal.

#### FE-2 — Cliente no asignado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta acceder a las tareas de un cliente que no tiene asignado.

1. **Usuario operativo:** Intenta acceder a las tareas de un cliente que no tiene asignado.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

#### FE-3 — Tarea modificada por otro usuario

**Se produce en:** FA-1 y FA-2 (edición o cierre de una tarea).  
**Condición:** Otro usuario ha modificado o completado la misma tarea mientras tanto.

1. **Sistema:** Avisa del conflicto, muestra el estado actual de la tarea y no sobrescribe el cambio ajeno.

**Resultado:** El usuario puede revisar el estado actual y repetir su cambio.

---

### 6. Postcondiciones

- POST-1. La tarea queda asociada al cliente con su estado (pendiente o completada).
- POST-2. La línea temporal del cliente refleja la creación, edición o cierre.
- POST-3. Las tareas pendientes son visibles para el responsable interno actual del cliente.

---

<!-- Bloque B. Suscripciones, tarifas y descuentos -->

## CU-05 — Gestionar baja y pausa de suscripción

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-05 |
| **Nombre** | Gestionar baja y pausa de suscripción |
| **Objetivo** | Registrar la baja comercial de un cliente o la pausa de su suscripción, deteniendo la generación de nuevas mensualidades sin perder el seguimiento de las facturas pendientes. |
| **Actores participantes** | Usuario operativo y Planificador del sistema (principales) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado y el cliente está asignado al usuario (o el usuario es Administrador o superior).
- PRE-2. El cliente tiene una suscripción activa.

---

### 3. Flujo principal

*Escenario descrito: registrar la baja.*

1. **Usuario operativo:** Abre la ficha del cliente y selecciona «Registrar baja».
2. **Sistema:** Solicita la fecha de baja y el motivo, y muestra las facturas pendientes de cobro del cliente, si las hay.
3. **Usuario operativo:** Introduce la fecha de baja y el motivo.
4. **Sistema:** Valida los datos y solicita confirmación, avisando de que dejarán de generarse mensualidades desde esa fecha.
5. **Usuario operativo:** Confirma.
6. **Sistema:** Registra la baja, deja de generar mensualidades a partir de la fecha indicada y mantiene activo el flujo de recobro de las facturas pendientes (CU-20).
7. **Sistema:** Registra el evento en la línea temporal y confirma la operación.

---

### 4. Flujos alternativos

#### FA-1 — Pausar la suscripción

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona «Pausar suscripción».

1. **Usuario operativo:** Selecciona «Pausar suscripción».
2. **Usuario operativo:** Indica el motivo, la fecha de inicio y, si se conoce, la fecha prevista de reactivación.
3. **Sistema:** Registra la pausa: el cliente sigue activo, conserva sus facturas pendientes y no se generan mensualidades durante la pausa.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Aviso de fecha prevista de reactivación

**Se produce en:** cualquier momento posterior al paso 6 del flujo principal (llegada de la fecha prevista de reactivación).  
**Condición:** Llega la fecha prevista de reactivación de una pausa.

1. **Planificador del sistema:** Detecta que ha llegado la fecha prevista de reactivación.
2. **Sistema:** Avisa al responsable del cliente.
3. **Usuario operativo:** Reactiva la suscripción o prorroga la pausa.
4. **Sistema:** Registra la decisión.

**Continuación:** el caso de uso finaliza.

#### FA-3 — Baja de un cliente con deuda pendiente

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El cliente tiene facturas pendientes de cobro.

1. **Sistema:** La deuda no bloquea la baja comercial: el sistema permite continuar y las facturas pendientes siguen su flujo de recobro.

**Continuación:** el caso de uso continúa en el paso 3 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Datos obligatorios o fecha no válida

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Falta el motivo o la fecha no es válida.

1. **Sistema:** No registra la operación e indica qué corregir.

**Resultado:** El usuario corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Suscripción no activa

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El cliente ya está dado de baja, o la suscripción ya está pausada.

1. **Sistema:** Impide repetir la operación e informa del estado actual.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

#### FE-3 — Cliente no asignado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta operar sobre la suscripción de un cliente que no tiene asignado.

1. **Usuario operativo:** Intenta operar sobre la suscripción de un cliente que no tiene asignado.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. La suscripción queda de baja o pausada, y no se generan nuevas mensualidades durante ese periodo.
- POST-2. Las facturas pendientes se conservan y el recobro continúa en la baja; en la pausa el cliente sigue activo.
- POST-3. Los datos del cliente y de las facturas emitidas se conservan.
- POST-4. El evento queda en la línea temporal y en el registro de auditoría.

---

## CU-06 — Revisar y aprobar rango de tarifa anual

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-06 |
| **Nombre** | Revisar y aprobar rango de tarifa anual |
| **Objetivo** | Actualizar anualmente el plan de precios de un cliente en función de su facturación, con aprobación humana y trazabilidad del cambio. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior.
- PRE-2. Existe una tabla de tarifas vigente (CU-35).

---

### 3. Flujo principal

1. **Administrador:** Abre la ficha del cliente y selecciona «Revisión anual de tarifa».
2. **Sistema:** Solicita la facturación anual verificada del cliente.
3. **Administrador:** Introduce el importe.
4. **Sistema:** Propone el rango de tarifa que corresponde según la tabla vigente y muestra la tarifa actual junto a la propuesta.
5. **Administrador:** Revisa la propuesta y la aprueba.
6. **Sistema:** Registra quién aprobó el cambio, cuándo, el precio anterior y el nuevo.
7. **Sistema:** Aplica la nueva tarifa solo a las facturas futuras y confirma la operación.

---

### 4. Flujos alternativos

#### FA-1 — Rechazar o mantener la tarifa actual

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Administrador decide no aplicar el cambio propuesto e indica el motivo.

1. **Administrador:** Decide no aplicar el cambio propuesto e indica el motivo.
2. **Sistema:** Conserva la tarifa actual y registra la decisión.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Mismo rango

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El rango propuesto coincide con el actual.

1. **Sistema:** Lo indica y no genera ningún cambio de precio.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Facturación anual inválida

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El importe falta o no es válido.

1. **Sistema:** No calcula la propuesta e indica qué corregir.

**Resultado:** El Administrador corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — El aprobador es quien solicitó el cambio

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El importe es sensible y el aprobador es la misma persona que preparó o solicitó el cambio.

1. **Sistema:** Impide la aprobación e indica que debe aprobarla otra persona.

**Resultado:** La tarifa no cambia hasta que otra persona apruebe el cambio.

#### FE-3 — Sin rango aplicable

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La tabla de tarifas no tiene un rango para ese importe.

1. **Sistema:** No propone cambio y avisa de que debe revisarse la tabla (CU-35).

**Resultado:** El caso de uso termina sin proponer ningún cambio de tarifa.

---

### 6. Postcondiciones

- POST-1. La tarifa del cliente queda actualizada o sin cambios, con registro de quién la aprobó, cuándo, el precio anterior y el nuevo.
- POST-2. Las facturas históricas ya emitidas no se modifican.

---

## CU-07 — Solicitar descuento

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-07 |
| **Nombre** | Solicitar descuento |
| **Objetivo** | Permitir que quien gestiona al cliente solicite un descuento o una excepción económica, que quedará pendiente de aprobación. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado y el cliente está asignado al usuario (o el usuario es Administrador o superior).

---

### 3. Flujo principal

1. **Usuario operativo:** Abre la ficha del cliente y selecciona «Solicitar descuento».
2. **Sistema:** Muestra el formulario de solicitud.
3. **Usuario operativo:** Indica el importe o porcentaje, el periodo de aplicación y el motivo.
4. **Sistema:** Valida los datos y comprueba si el descuento supera el umbral configurable.
5. **Sistema:** Crea la solicitud en estado «pendiente de aprobación», explicando el motivo por el que queda pendiente, y no la aplica.
6. **Sistema:** Notifica a los Administradores y confirma la solicitud al usuario.

---

### 4. Flujos alternativos

#### FA-1 — El descuento supera el umbral

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El descuento supera el umbral configurable.

1. **Sistema:** Indica que requerirá la aprobación del Superadministrador (CU-09).

**Continuación:** el caso de uso continúa en el paso 5 del flujo principal.

#### FA-2 — Solicitar una excepción comercial con efecto económico

**Se produce en:** paso 1 del flujo principal (solicitud originada en CU-01, FA-4).  
**Condición:** El usuario solicita, desde CU-01, un primer mes gratuito o la facturación sin prorrateo.

1. **Usuario operativo:** Solicita desde CU-01 (FA-4) un primer mes gratuito o la facturación sin prorrateo.
2. **Sistema:** Tramita la solicitud con este mismo flujo y no aplica la excepción hasta su aprobación (A-10).

**Continuación:** el caso de uso continúa en el paso 3 del flujo principal.

#### FA-3 — Cancelar la solicitud

**Se produce en:** cualquier momento posterior al paso 6 del flujo principal (solicitud pendiente).  
**Condición:** El usuario decide cancelar una solicitud que sigue pendiente.

1. **Usuario operativo:** Cancela la solicitud mientras está pendiente.
2. **Sistema:** La marca como cancelada y lo registra.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Datos inválidos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El importe o porcentaje no es válido o falta el motivo.

1. **Sistema:** No crea la solicitud e indica qué corregir.

**Resultado:** El usuario corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Cliente no asignado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta solicitar un descuento de un cliente que no tiene asignado.

1. **Usuario operativo:** Intenta solicitar un descuento de un cliente que no tiene asignado.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. La solicitud queda registrada como pendiente, con su solicitante, motivo e importe.
- POST-2. El descuento no afecta a ninguna factura hasta ser aprobado.

---

## CU-08 — Aprobar descuento

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-08 |
| **Nombre** | Aprobar descuento |
| **Objetivo** | Revisar y resolver las solicitudes de descuento, con trazabilidad y separación entre quien solicita y quien aprueba. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. Existe una solicitud de descuento pendiente (CU-07).
- PRE-2. El usuario está autenticado con rol Administrador o superior.

---

### 3. Flujo principal

1. **Administrador:** Accede a las aprobaciones pendientes desde su bandeja o su pantalla de trabajo diario.
2. **Sistema:** Las lista con cliente, importe, solicitante y motivo por el que están pendientes.
3. **Administrador:** Abre una solicitud y revisa los datos.
4. **Administrador:** Aprueba el descuento.
5. **Sistema:** Registra quién lo aprobó, cuándo y los valores aprobados, y deja el descuento disponible para la facturación futura.
6. **Sistema:** Notifica al solicitante y confirma la operación.

---

### 4. Flujos alternativos

#### FA-1 — Rechazar la solicitud

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador rechaza la solicitud e indica el motivo.

1. **Administrador:** Rechaza la solicitud e indica el motivo.
2. **Sistema:** La marca como rechazada, lo registra y notifica al solicitante.

**Continuación:** el caso de uso finaliza.

#### FA-2 — El descuento supera el umbral

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El descuento supera el umbral configurable.

1. **Sistema:** Impide que el Administrador la resuelva y la deriva al Superadministrador (CU-09).

**Continuación:** el caso de uso continúa en CU-09 y finaliza aquí.

---

### 5. Flujos de excepción

#### FE-1 — El aprobador es el solicitante

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El aprobador es quien solicitó el descuento.

1. **Sistema:** Impide la aprobación e indica que debe resolverla otra persona.

**Resultado:** La solicitud permanece pendiente hasta que la resuelva otra persona.

#### FE-2 — Solicitud ya resuelta

**Se produce en:** paso 3 o paso 4 del flujo principal.  
**Condición:** Otro aprobador ha resuelto la solicitud mientras tanto.

1. **Sistema:** Informa del resultado y no permite resolverla de nuevo.

**Resultado:** El caso de uso termina sin volver a resolver la solicitud.

---

### 6. Postcondiciones

- POST-1. La solicitud queda aprobada o rechazada, con registro de quién, cuándo y por qué.
- POST-2. Un descuento aprobado puede aplicarse en la facturación futura; no altera facturas ya emitidas.

---

## CU-09 — Escalar aprobación al Superadministrador

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-09 |
| **Nombre** | Escalar aprobación al Superadministrador |
| **Objetivo** | Resolver las solicitudes de descuento que superan el umbral configurable, que solo puede aprobar el Superadministrador. |
| **Actores participantes** | Superadministrador (principal) |

---

### 2. Precondiciones

- PRE-1. Existe una solicitud de descuento pendiente que supera el umbral configurable.
- PRE-2. El usuario está autenticado como Superadministrador.

---

### 3. Flujo principal

1. **Sistema:** Deriva la solicitud al Superadministrador y le notifica que tiene una aprobación pendiente.
2. **Superadministrador:** Abre la solicitud.
3. **Sistema:** Muestra el cliente, el importe, el solicitante y el motivo por el que requiere su aprobación.
4. **Superadministrador:** Aprueba el descuento.
5. **Sistema:** Registra quién lo aprobó, cuándo y los valores aprobados.
6. **Sistema:** Notifica al solicitante y al Administrador, y confirma la operación.

---

### 4. Flujos alternativos

#### FA-1 — Rechazar la solicitud

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Superadministrador rechaza la solicitud e indica el motivo.

1. **Superadministrador:** Rechaza la solicitud e indica el motivo.
2. **Sistema:** La marca como rechazada, lo registra y notifica.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — El Superadministrador es el solicitante

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Superadministrador es quien solicitó el descuento.

1. **Superadministrador:** Es quien solicitó el descuento.
2. **Sistema:** Impide la aprobación e indica que debe resolverla otra persona.

**Resultado:** La solicitud permanece pendiente hasta que la resuelva otra persona.

#### FE-2 — Solicitud ya resuelta

**Se produce en:** paso 2 o paso 4 del flujo principal.  
**Condición:** La solicitud ya fue resuelta mientras tanto.

1. **Sistema:** Informa del resultado y no permite resolverla de nuevo.

**Resultado:** El caso de uso termina sin volver a resolver la solicitud.

---

### 6. Postcondiciones

- POST-1. La solicitud queda aprobada o rechazada por el Superadministrador, con registro de quién, cuándo y por qué.
- POST-2. El descuento aprobado puede aplicarse en la facturación futura.

---

<!-- Bloque C. Facturación -->

## CU-10 — Gestionar borrador de factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-10 |
| **Nombre** | Gestionar borrador de factura |
| **Objetivo** | Preparar, modificar o eliminar una factura antes de emitirla, con sus líneas, impuestos y totales correctos. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso para preparar facturas.
- PRE-2. El cliente está asignado al usuario (o el usuario es Administrador o superior).

---

### 3. Flujo principal

*Escenario descrito: crear un borrador de factura puntual.*

1. **Usuario operativo:** Selecciona «Nueva factura» para un cliente.
2. **Sistema:** Muestra el formulario autocompletando los campos recurrentes (moneda, vencimiento, impuestos).
3. **Usuario operativo:** Añade una o varias líneas con concepto, cantidad, precio unitario, descuento (si aplica) e impuesto.
4. **Sistema:** Calcula los importes y el IVA con precisión decimal y muestra los totales en la moneda del cliente.
5. **Usuario operativo:** Guarda el borrador.
6. **Sistema:** Guarda la factura en estado «borrador», sin número, y confirma la operación.

---

### 4. Flujos alternativos

#### FA-1 — Editar un borrador existente

**Se produce en:** después del paso 6 del flujo principal (borrador ya guardado).  
**Condición:** El usuario abre un borrador y modifica sus líneas o datos.

1. **Usuario operativo:** Abre un borrador y modifica sus líneas o datos.
2. **Sistema:** Recalcula los totales y guarda los cambios.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Eliminar un borrador

**Se produce en:** después del paso 6 del flujo principal (borrador ya guardado).  
**Condición:** El usuario elimina un borrador que nunca ha sido emitido.

1. **Usuario operativo:** Elimina un borrador que nunca ha sido emitido.
2. **Sistema:** Lo elimina, ya que los borradores nunca emitidos pueden eliminarse, y lo registra.

**Continuación:** el caso de uso finaliza.

#### FA-3 — Cambio sensible en el borrador

**Se produce en:** pasos 3 o 5 del flujo principal.  
**Condición:** La factura incluye un importe modificado manualmente, un descuento extraordinario, un vencimiento fuera de lo habitual o es una factura puntual de importe muy alto.

1. **Sistema:** Marca el borrador con cambio sensible e informa de que quedará retenida al emitirse (CU-12, FA-1).

**Continuación:** el caso de uso continúa en el paso 5 del flujo principal.

#### FA-4 — Borrador de factura recurrente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario indica que la factura es recurrente.

1. **Usuario operativo:** Indica que la factura es recurrente.
2. **Sistema:** La prepara con las líneas de la suscripción del cliente y continúa en el paso 4.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Datos inválidos

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Hay líneas sin concepto, cantidades o precios no válidos o falta un dato obligatorio.

1. **Sistema:** No guarda e indica qué campos corregir.

**Resultado:** El usuario corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Factura ya emitida

**Se produce en:** FA-1 y FA-2 (modificación o eliminación de una factura ya emitida).  
**Condición:** El usuario intenta modificar o eliminar una factura que ya fue emitida.

1. **Usuario operativo:** Intenta modificar o eliminar una factura que ya fue emitida.
2. **Sistema:** Bloquea la edición ordinaria e indica que cualquier corrección requiere una factura rectificativa (CU-14).

**Resultado:** El caso de uso termina sin modificar la factura emitida; la corrección debe tramitarse en CU-14.

#### FE-3 — Edición simultánea

**Se produce en:** pasos 3 a 5 del flujo principal y FA-1.  
**Condición:** Otro usuario modifica el mismo borrador al mismo tiempo.

1. **Sistema:** Avisa del conflicto y no sobrescribe el cambio ajeno.

**Resultado:** El usuario puede revisar el estado actual del borrador y repetir su cambio.

---

### 6. Postcondiciones

- POST-1. El borrador queda guardado con sus líneas, impuestos y totales, sin número de factura.
- POST-2. Un borrador con cambio sensible queda marcado para retención al emitirse.
- POST-3. Un borrador eliminado deja de existir; las facturas emitidas no se alteran.

---

## CU-11 — Generar facturas recurrentes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-11 |
| **Nombre** | Generar facturas recurrentes |
| **Objetivo** | Generar y emitir automáticamente cada mes la factura de las suscripciones activas de cada cliente, con las tarifas, el prorrateo y los descuentos aprobados aplicables. |
| **Actores participantes** | Planificador del sistema (principal), Proveedor de correo (secundario; a través de CU-12 → CU-18) |

---

### 2. Precondiciones

- PRE-1. Es el día 1 del mes (o se relanza una ejecución interrumpida, ver FE-2).
- PRE-2. Existen clientes con suscripciones activas.

---

### 3. Flujo principal

1. **Planificador del sistema:** Inicia la ejecución de facturación recurrente.
2. **Sistema:** Selecciona los clientes con suscripciones activas, excluyendo las suscripciones pausadas, los clientes dados de baja y los clientes pendientes de activación.
3. **Sistema:** Para cada cliente, el sistema calcula las líneas de factura con la tarifa acordada, aplicando el prorrateo si el alta fue a mitad de mes y los descuentos aprobados vigentes.
4. **Sistema:** Crea la factura (borrador) en la moneda del cliente, con el vencimiento pactado si existe (prevalece sobre el general).
5. **Sistema:** Como la factura procede exactamente de una suscripción aprobada, la emite sin aprobación adicional (CU-12).
6. **Sistema:** Registra el resultado de la ejecución para el panel de monitorización.

---

### 4. Flujos alternativos

#### FA-1 — Alta a mitad de mes

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El alta del cliente se produjo a mitad de mes.

1. **Sistema:** Aplica la regla de prorrateo única y documentada, también en casos límite (alta el último día del mes).

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

#### FA-2 — Factura con cambio sensible

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La factura no procede exactamente de una suscripción aprobada: lleva un importe modificado manualmente, un descuento extraordinario o un vencimiento fuera de lo habitual.

1. **Sistema:** La deja retenida y explica el motivo (CU-13 extiende CU-12). Se emitirá tras la aprobación de un Administrador.
2. **Sistema:** El proceso continúa con el resto de clientes.

**Continuación:** el caso de uso continúa con el siguiente cliente (paso 3 del flujo principal); la factura queda retenida hasta su aprobación (CU-13).

#### FA-3 — Cliente con excepción comercial

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El cliente tiene una excepción comercial registrada explícitamente en su ficha (CU-01, FA-4).

1. **Sistema:** La aplica solo si está aprobada (A-10): con «primer mes gratuito» la primera mensualidad no se cobra; con «sin prorrateo» se factura la mensualidad completa.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Faltan datos fiscales de un cliente

**Se produce en:** paso 4 del flujo principal.  
**Condición:** A un cliente le falta un dato fiscal imprescindible.

1. **Sistema:** Omite la factura de ese cliente, registra la incidencia e indica qué falta, y notifica al responsable del cliente.
2. **Sistema:** El proceso continúa con el resto de clientes.

**Resultado:** El caso de uso continúa con el siguiente cliente (paso 3 del flujo principal).

#### FE-2 — Interrupción o reejecución

**Se produce en:** cualquier paso del flujo principal.  
**Condición:** La ejecución se interrumpe o se lanza de nuevo.

1. **Sistema:** Recupera el proceso sin duplicar facturas ni consumir numeración: no genera una segunda factura para el mismo cliente y periodo.

**Resultado:** El caso de uso continúa en el paso 6 del flujo principal.

---

### 6. Postcondiciones

- POST-1. Cada cliente facturable tiene una única factura del periodo: emitida y con número correlativo dentro de su serie, o retenida pendiente de aprobación (la numeración se asigna al emitirla, CU-12).
- POST-2. Los clientes con errores quedan señalados para su revisión.
- POST-3. La ejecución queda registrada para monitorización.

---

## CU-12 — Emitir factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-12 |
| **Nombre** | Emitir factura |
| **Objetivo** | Convertir un borrador de factura en una factura emitida, con numeración y PDF, y enviarla al cliente. |
| **Actores participantes** | Usuario operativo (principal; según su permiso), Proveedor de correo (secundario) |

---

### 2. Precondiciones

- PRE-1. Existe una factura en estado «borrador» o «aprobada».
- PRE-2. El usuario tiene permiso para emitir facturas.

---

### 3. Flujo principal

1. **Usuario operativo:** Selecciona la factura y elige «Emitir».
2. **Sistema:** Muestra la vista previa de la factura.
3. **Sistema:** Verifica que no faltan datos fiscales imprescindibles.
4. **Usuario operativo:** Confirma la emisión.
5. **Sistema:** Asigna el siguiente número correlativo de la serie y genera el PDF, que guarda en la base de datos.
6. **Sistema:** Cambia el estado a «emitida» y bloquea su edición ordinaria.
7. **Sistema:** Envía la factura por correo al contacto de facturación (CU-18) y registra canal, intento, resultado, fecha y destinatario.
8. **Sistema:** Cambia el estado a «enviada» y confirma al usuario.

---

### 4. Flujos alternativos

#### FA-1 — Factura retenida para revisión

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Al confirmar, la factura tiene un cambio sensible (importe manual, descuento extraordinario, vencimiento atípico o factura puntual de importe muy alto).

1. **Sistema:** Retiene la factura, explica el motivo y avisa a los Administradores (CU-13).
2. **Administrador:** Aprueba la factura (CU-13). En importes sensibles, el aprobador no puede ser quien preparó o solicitó el cambio.
3. **Sistema:** Cambia el estado de la factura a «aprobada».

**Continuación:** el caso de uso continúa en el paso 5 del flujo principal.

#### FA-2 — Emisión automática desde la facturación recurrente

**Se produce en:** paso 1 del flujo principal (invocación desde CU-11).  
**Condición:** CU-11 invoca la emisión de una factura generada exactamente desde una suscripción aprobada.

1. **Planificador del sistema:** Invoca, desde CU-11, la emisión de la factura.
2. **Sistema:** Omite la vista previa y la confirmación (pasos 2 y 4), mantiene la comprobación de datos fiscales del paso 3 (su fallo se trata como en CU-11, FE-1) y emite la factura sin intervención del usuario.

**Continuación:** el caso de uso continúa en el paso 5 del flujo principal.

#### FA-3 — Envío adicional por WhatsApp

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El contacto de facturación ha dado su consentimiento para WhatsApp.

1. **Sistema:** Envía además la factura por WhatsApp (de forma simulada) y registra canal, intento, resultado, fecha y destinatario.
2. **Sistema:** Si este canal falla, no afecta al envío por correo ni deshace la emisión.

**Continuación:** el caso de uso continúa en el paso 8 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Faltan datos fiscales

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Falta un dato fiscal imprescindible.

1. **Sistema:** Bloquea la emisión e indica qué falta.
2. **Usuario operativo:** Completa los datos y reintenta.

**Resultado:** El usuario completa los datos y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Fallo en el envío

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El envío falla.

1. **Sistema:** Registra el fallo de envío; la emisión no se deshace y la factura sigue emitida con su número.
2. **Sistema:** Mantiene la factura en estado «emitida» (no «enviada») hasta que el envío se complete.
3. **Sistema:** Permite reintentar el envío, de forma manual o automática, sin crear otra factura ni otro número.

**Resultado:** La factura permanece «emitida»; el caso de uso continúa en el paso 8 del flujo principal cuando el envío se complete.

#### FE-3 — Correo rebotado

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El proveedor de correo informa de un rebote.

1. **Proveedor de correo:** Informa de un rebote.
2. **Sistema:** Registra el resultado «rebotado» en el envío, no marca la factura como notificada y deriva la gestión a CU-19 (que extiende CU-18).

**Resultado:** El caso de uso termina; el rebote se gestiona mediante CU-19.

#### FE-4 — Emisión concurrente

**Se produce en:** pasos 4 y 5 del flujo principal.  
**Condición:** Otro usuario emite la misma factura al mismo tiempo.

1. **Sistema:** Impide la duplicación y la numeración doble, e informa de que ya fue emitida.

**Resultado:** El caso de uso termina sin emitir de nuevo la factura.

---

### 6. Postcondiciones

- POST-1. La factura queda emitida, numerada, con PDF y sin posibilidad de edición ordinaria (cualquier corrección exige rectificativa).
- POST-2. El envío queda registrado con su resultado.
- POST-3. El saldo pendiente del cliente refleja la nueva factura.

---

## CU-13 — Aprobar factura retenida

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-13 |
| **Nombre** | Aprobar factura retenida |
| **Objetivo** | Revisar las facturas retenidas por un cambio sensible y decidir si pueden emitirse. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. Existe una factura retenida (CU-12, FA-1 o CU-11, FA-2) con el motivo de la retención.
- PRE-2. El usuario está autenticado con rol Administrador o superior.

---

### 3. Flujo principal

1. **Administrador:** Accede a las aprobaciones pendientes desde su bandeja o su pantalla de trabajo diario.
2. **Sistema:** Lista las facturas retenidas con cliente, importe, preparador y motivo de la retención.
3. **Administrador:** Abre una factura y revisa el cambio sensible y la vista previa.
4. **Administrador:** Aprueba la factura.
5. **Sistema:** Registra quién la aprobó y cuándo, y cambia su estado a «aprobada».
6. **Sistema:** Retoma la emisión (CU-12, desde el paso 5) y notifica al preparador.

---

### 4. Flujos alternativos

#### FA-1 — Rechazar la factura

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador rechaza la factura e indica el motivo.

1. **Administrador:** Rechaza la factura e indica el motivo.
2. **Sistema:** Devuelve la factura a «borrador», registra la decisión y notifica al preparador, que puede corregirla (CU-10).

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — El aprobador es quien preparó el cambio

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El importe es sensible y el aprobador es quien preparó o solicitó el cambio.

1. **Sistema:** Impide la aprobación e indica que debe aprobarla otra persona.

**Resultado:** La factura permanece retenida hasta que la apruebe otra persona.

#### FE-2 — Factura ya resuelta

**Se produce en:** paso 3 o paso 4 del flujo principal.  
**Condición:** Otro Administrador ha resuelto la factura mientras tanto.

1. **Administrador:** Ha resuelto la factura mientras tanto.
2. **Sistema:** Informa del resultado y no permite resolverla de nuevo.

**Resultado:** El caso de uso termina sin volver a resolver la factura.

#### FE-3 — Faltan datos fiscales

**Se produce en:** paso 6 del flujo principal (retoma de la emisión).  
**Condición:** Tras la aprobación, falta un dato fiscal imprescindible.

1. **Sistema:** Bloquea la emisión según CU-12 (FE-1) hasta completar los datos.

**Resultado:** La factura permanece «aprobada» y sin emitir hasta que se completen los datos.

---

### 6. Postcondiciones

- POST-1. La factura queda «aprobada» y se emite, o vuelve a «borrador» si se rechaza.
- POST-2. Queda registrado quién decidió, cuándo y por qué.

---

## CU-14 — Rectificar, anular o declarar incobrable una factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-14 |
| **Nombre** | Rectificar, anular o declarar incobrable una factura |
| **Objetivo** | Corregir o cancelar una factura ya emitida sin modificarla, mediante rectificativa vinculada, anulación o declaración de incobrable, con aprobación y motivo. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. Existe una factura emitida.
- PRE-2. El usuario está autenticado con rol Administrador o superior.

---

### 3. Flujo principal

*Escenario descrito: factura rectificativa.*

1. **Administrador:** Abre una factura emitida y selecciona «Rectificar».
2. **Sistema:** Propone los datos que se rectifican y mantiene el vínculo con la factura original.
3. **Administrador:** Ajusta los datos e indica el motivo.
4. **Sistema:** Comprueba si, según el importe, requiere aprobación; en este caso no la requiere.
5. **Sistema:** Asigna el siguiente número correlativo, genera el PDF de la rectificativa y la guarda.
6. **Sistema:** Cambia el estado de la factura original a «rectificada» y la envía al contacto de facturación igual que en la emisión ordinaria (CU-12).
7. **Sistema:** Registra la operación y confirma al Administrador.

---

### 4. Flujos alternativos

#### FA-1 — La rectificativa requiere aprobación

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El importe exige aprobación.

1. **Sistema:** Deja la rectificativa pendiente, explica el motivo y avisa al aprobador. La aprobación la resuelve otra persona distinta de quien la solicitó (BR-12) y la emisión continúa en el paso 5.

**Continuación:** el caso de uso continúa en el paso 5 del flujo principal.

#### FA-2 — Anular la factura

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Administrador selecciona «Anular» e indica el motivo.

1. **Administrador:** Selecciona «Anular» e indica el motivo.
2. **Sistema:** Si legalmente procede, el sistema pide la aprobación que corresponda y cambia el estado a «anulada», conservando la factura y su número.

**Continuación:** el caso de uso finaliza.

#### FA-3 — Declarar la deuda incobrable

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Administrador selecciona «Declarar incobrable» e indica el motivo.

1. **Administrador:** Selecciona «Declarar incobrable» e indica el motivo.
2. **Sistema:** Tras la aprobación correspondiente, el sistema marca la deuda como incobrable sin considerarla pagada y detiene los recordatorios de esa factura (A-12).

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Factura no emitida

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta rectificar o anular una factura en estado «borrador».

1. **Administrador:** Intenta rectificar o anular una factura en estado «borrador».
2. **Sistema:** Informa de que no procede y de que el borrador puede editarse o eliminarse (CU-10).

**Resultado:** El caso de uso termina sin realizar la operación; el borrador puede gestionarse en CU-10.

#### FE-2 — Anulación no procedente

**Se produce en:** FA-2 (anulación).  
**Condición:** La anulación no procede legalmente.

1. **Sistema:** Impide la anulación y ofrece generar una rectificativa.

**Resultado:** El caso de uso termina sin anular; el Administrador puede iniciar una rectificativa desde el paso 1 del flujo principal.

#### FE-3 — Falta el motivo o la aprobación

**Se produce en:** cualquier paso en que se ejecute la operación (flujo principal, FA-2 o FA-3).  
**Condición:** Falta el motivo o la aprobación requerida, o el aprobador es quien lo solicitó.

1. **Sistema:** No ejecuta la operación e indica qué falta.

**Resultado:** La operación queda sin ejecutar hasta que se aporte lo que falta.

#### FE-4 — Factura ya rectificada o anulada

**Se produce en:** paso 1 del flujo principal.  
**Condición:** La factura ya está en estado «rectificada» o «anulada».

1. **Sistema:** Impide repetir la operación e informa del estado.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

---

### 6. Postcondiciones

- POST-1. La factura original no se modifica ni se borra; queda «rectificada», «anulada» o marcada como incobrable, con su motivo y aprobación.
- POST-2. Una rectificativa queda emitida, numerada y vinculada a la original.
- POST-3. Una deuda declarada incobrable, anulada o rectificada nunca pasa a «pagada».
- POST-4. La operación queda registrada en el registro de auditoría.

---

## CU-15 — Buscar y consultar facturas y clientes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-15 |
| **Nombre** | Buscar y consultar facturas y clientes |
| **Objetivo** | Localizar rápidamente clientes y facturas y consultar su información, incluida la descarga del PDF. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado.

---

### 3. Flujo principal

1. **Usuario operativo:** Introduce un término en el buscador.
2. **Sistema:** Busca por nombre comercial, razón social, NIF, persona de contacto, número de factura y correo, limitándose a lo que el usuario tiene permiso para ver.
3. **Sistema:** Muestra los resultados agrupados por clientes y facturas.
4. **Usuario operativo:** Aplica filtros (estado de la factura, empresa, fecha, sector).
5. **Sistema:** Actualiza los resultados.
6. **Usuario operativo:** Abre una factura o la ficha de un cliente, y el sistema muestra su información básica.

---

### 4. Flujos alternativos

#### FA-1 — Guardar un filtro

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El usuario guarda la combinación de filtros.

1. **Usuario operativo:** Guarda la combinación de filtros.
2. **Sistema:** La conserva para usarla de nuevo.

**Continuación:** el caso de uso continúa en el paso 5 del flujo principal.

#### FA-2 — Acceder por favoritos

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario accede a la ficha de un cliente desde sus favoritos.

1. **Usuario operativo:** Accede a la ficha de un cliente desde sus favoritos.
2. **Sistema:** Comprueba igualmente los permisos antes de mostrarla.

**Continuación:** el caso de uso continúa en el paso 6 del flujo principal.

#### FA-3 — Descargar el PDF de una factura

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El usuario selecciona «Descargar PDF» en una factura emitida.

1. **Usuario operativo:** Selecciona «Descargar PDF» en una factura emitida.
2. **Sistema:** Entrega el PDF guardado, sin regenerarlo.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Sin resultados

**Se produce en:** paso 3 del flujo principal.  
**Condición:** No hay coincidencias.

1. **Sistema:** Lo indica y sugiere revisar el término o los filtros.

**Resultado:** El usuario puede modificar el término o los filtros y el caso de uso regresa al paso 1 del flujo principal.

#### FE-2 — Recurso no permitido

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El usuario intenta abrir un cliente o factura que no tiene permiso para ver.

1. **Usuario operativo:** Intenta abrir un cliente o factura que no tiene permiso para ver.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

---

### 6. Postcondiciones

- POST-1. El usuario ha localizado y consultado la información que necesitaba, dentro de sus permisos.
- POST-2. La consulta no modifica ningún dato.

---

<!-- Bloque D. Cobros y comunicaciones -->

## CU-16 — Registrar movimiento de cobro

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-16 |
| **Nombre** | Registrar movimiento de cobro |
| **Objetivo** | Incorporar al sistema los cobros recibidos a través del sistema de pagos para poder determinar si una factura ha sido pagada. |
| **Actores participantes** | Sistema de pagos (principal; Stripe/Revolut), Planificador del sistema (secundario; consulta periódica) |

---

### 2. Precondiciones

- PRE-1. La integración con el sistema de pagos está configurada.

---

### 3. Flujo principal

1. **Sistema de pagos:** Notifica un cobro (o el Planificador del sistema lo obtiene en la consulta periódica).
2. **Sistema:** Comprueba que el evento no está duplicado.
3. **Sistema:** Registra el movimiento con importe, fecha, moneda, concepto y referencia.
4. **Sistema:** Busca la factura a partir de la referencia del pago.
5. **Sistema:** Si la coincidencia es clara, concilia el pago con la factura mediante conciliación automática (CU-17, FA-1).
6. **Sistema:** Registra el resultado de la operación.

---

### 4. Flujos alternativos

#### FA-1 — Consulta periódica de pagos

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El cobro no llega por notificación, sino mediante la consulta periódica del Planificador.

1. **Planificador del sistema:** Consulta al sistema de pagos los movimientos nuevos.

**Continuación:** el caso de uso continúa en el paso 2 del flujo principal.

#### FA-2 — Cobro sin referencia clara

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No hay coincidencia clara o hay varias posibles.

1. **Sistema:** Deja el movimiento pendiente de conciliación manual, lo asigna al responsable del cliente (o a una persona designada) y lo muestra en su pantalla de trabajo diario. La conciliación se completará después, de forma manual, en CU-17.

**Continuación:** el caso de uso continúa en el paso 6 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Evento duplicado

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El sistema detecta que el evento ya fue registrado.

1. **Sistema:** Detecta que el evento ya fue registrado.
2. **Sistema:** Lo descarta sin contabilizarlo dos veces.

**Resultado:** El evento duplicado no se contabiliza y el caso de uso termina.

#### FE-2 — Fallo de la integración

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El sistema de pagos no responde o devuelve un error.

1. **Sistema de pagos:** No responde o devuelve un error.
2. **Sistema:** Registra el error de integración, que se muestra en el panel de monitorización, y reintenta en la siguiente ejecución.

**Resultado:** El caso de uso termina y se reintentará en la siguiente ejecución.

---

### 6. Postcondiciones

- POST-1. El movimiento queda registrado de forma inmutable.
- POST-2. El movimiento está conciliado con una factura o pendiente de conciliación manual.

---

## CU-17 — Conciliar pagos

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-17 |
| **Nombre** | Conciliar pagos |
| **Objetivo** | Asociar los movimientos de cobro con las facturas pendientes y actualizar su estado de pago. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. Existe un movimiento de cobro registrado sin conciliar, o una conciliación automática que debe revisarse.
- PRE-2. Existe al menos una factura emitida pendiente de cobro del cliente.
- PRE-3. El cliente está asignado al usuario (o el usuario es Administrador o superior).

---

### 3. Flujo principal

1. **Usuario operativo:** Accede a los movimientos pendientes de conciliación (por ejemplo, desde su pantalla de trabajo diario).
2. **Sistema:** Los muestra con su importe, fecha, concepto y referencia.
3. **Usuario operativo:** Selecciona un movimiento y busca al cliente o la factura.
4. **Usuario operativo:** Asocia el movimiento a la factura (o a varias).
5. **Sistema:** Valida los importes.
6. **Sistema:** Actualiza el estado de cada factura: «pagada» si queda saldada, «parcialmente conciliada» si el importe es menor.
7. **Sistema:** Registra quién realizó la conciliación y confirma la operación.

---

### 4. Flujos alternativos

#### FA-1 — Conciliación automática

**Se produce en:** paso 1 del flujo principal (invocado desde CU-16).  
**Condición:** CU-16 encuentra una coincidencia clara entre el pago y una factura.

1. **Sistema:** Concilia el pago con la factura sin intervención del usuario, registra la regla aplicada y actualiza el estado de la factura como en el paso 6.

**Continuación:** el caso de uso finaliza sin intervención del usuario.

#### FA-2 — Un cobro para varias facturas

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El usuario reparte el importe entre varias facturas del cliente.

1. **Usuario operativo:** Reparte el importe entre varias facturas del cliente.
2. **Sistema:** Valida que la suma coincide con el movimiento y continúa en el paso 6.

**Continuación:** el caso de uso continúa en el paso 6 del flujo principal.

#### FA-3 — Deshacer una conciliación

**Se produce en:** después del paso 7 del flujo principal.  
**Condición:** El usuario detecta una conciliación errónea.

1. **Usuario operativo:** Revierte una conciliación errónea (manual o automática), indicando el motivo.
2. **Sistema:** No borra el evento: registra quién o qué regla la hizo, quién la revirtió, cuándo y por qué, y restaura el estado de la factura.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Importe superior al adeudado

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El importe supera el total pendiente.

1. **Sistema:** No marca la factura como pagada, señala la diferencia y avisa para su revisión.
2. **Usuario operativo:** Corrige la asociación o deja la diferencia pendiente de revisión.

**Resultado:** El usuario corrige la asociación y el caso de uso regresa al paso 4 del flujo principal, o deja la diferencia pendiente de revisión y el caso de uso termina.

#### FE-2 — Movimiento ya conciliado

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El movimiento seleccionado ya está asociado a una factura.

1. **Sistema:** Impide asociarlo de nuevo.

**Resultado:** El usuario puede elegir otro movimiento y el caso de uso regresa al paso 3 del flujo principal.

---

### 6. Postcondiciones

- POST-1. La factura queda «pagada» o «parcialmente conciliada» con el rastro de quién y cuándo lo hizo.
- POST-2. Las diferencias de importe quedan señaladas para su revisión.
- POST-3. Los movimientos y las reversiones quedan registrados de forma inmutable.

---

## CU-18 — Enviar comunicación al cliente

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-18 |
| **Nombre** | Enviar comunicación al cliente |
| **Objetivo** | Entregar al cliente, por correo, facturas y recordatorios mediante plantillas, registrando cada intento y su resultado. |
| **Actores participantes** | Proveedor de correo (principal) |

---

### 2. Precondiciones

- PRE-1. Un caso de uso (CU-12 o CU-20) solicita la comunicación indicando cliente, tipo de comunicación y, si procede, la factura.
- PRE-2. El cliente tiene un contacto del tipo adecuado (facturación o impagos) con correo válido.

---

### 3. Flujo principal

1. **Sistema:** Recibe la solicitud de comunicación (factura, recordatorio previo, recordatorio de vencimiento, aviso de impago o disputa resuelta).
2. **Sistema:** Selecciona la plantilla del tipo de comunicación en el idioma correspondiente.
3. **Sistema:** Completa las variables dinámicas (nombre de la empresa, número de factura, importe, responsable) y adjunta el PDF cuando se trata de una factura.
4. **Sistema:** Entrega el mensaje al Proveedor de correo.
5. **Proveedor de correo:** Confirma la entrega.
6. **Sistema:** Registra canal, intento, resultado, fecha, destinatario y plantilla utilizada.
7. **Sistema:** Devuelve el resultado al caso de uso que lo solicitó.

---

### 4. Flujos alternativos

#### FA-1 — Reenvío de una comunicación

**Se produce en:** paso 1 del flujo principal (nueva solicitud sobre una comunicación ya enviada).  
**Condición:** Un usuario solicita reenviar una comunicación ya enviada (por ejemplo, tras corregir un contacto en CU-19).

1. **Usuario operativo:** Solicita reenviar una comunicación ya enviada (por ejemplo, tras corregir un contacto en CU-19).
2. **Sistema:** Repite los pasos 2 a 6 sin generar un nuevo documento ni una nueva numeración, y registra el nuevo intento.

**Continuación:** el caso de uso continúa en el paso 7 del flujo principal.

#### FA-2 — Canal adicional simulado

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El contacto ha dado su consentimiento para WhatsApp.

1. **Sistema:** Envía además la comunicación por WhatsApp de forma simulada y registra el intento, sin que un fallo en ese canal afecte al correo.

**Continuación:** el caso de uso continúa en el paso 6 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Correo rebotado

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Proveedor de correo informa de un rebote.

1. **Proveedor de correo:** Informa de un rebote.
2. **Sistema:** Registra el resultado como «rebotado» y continúa con CU-19.

**Resultado:** El caso de uso continúa con CU-19 (Gestionar rebote de correo).

#### FE-2 — Proveedor no disponible

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Proveedor de correo no responde o devuelve un error.

1. **Proveedor de correo:** No responde o devuelve un error.
2. **Sistema:** Mantiene el mensaje en la cola de correos pendientes, registra el error de integración visible en monitorización (CU-33) y reintenta el envío.

**Resultado:** El mensaje queda en cola y el caso de uso regresa al paso 4 del flujo principal cuando se reintenta el envío.

#### FE-3 — Falta destinatario o dato de la plantilla

**Se produce en:** pasos 2 o 3 del flujo principal.  
**Condición:** El contacto no tiene correo o falta un dato de una variable obligatoria.

1. **Sistema:** No envía la comunicación, registra el fallo y avisa al responsable del cliente.

**Resultado:** El caso de uso termina sin enviar la comunicación.

---

### 6. Postcondiciones

- POST-1. La comunicación queda enviada, en cola o fallida, con su registro de canal, intento, resultado, fecha, destinatario y plantilla.
- POST-2. Los comentarios internos nunca se incluyen en comunicaciones al cliente.
- POST-3. No se envían comunicaciones comerciales fuera de las facturas y los recordatorios.

---

## CU-19 — Gestionar rebote de correo

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-19 |
| **Nombre** | Gestionar rebote de correo |
| **Objetivo** | Resolver un envío rebotado corrigiendo el contacto y reenviando la comunicación hasta que se entregue. |
| **Actores participantes** | Usuario operativo y Proveedor de correo (principales) |

---

### 2. Precondiciones

- PRE-1. Una comunicación enviada por CU-18 ha rebotado.

---

### 3. Flujo principal

1. **Proveedor de correo:** Informa del rebote de una comunicación.
2. **Sistema:** Registra el resultado «rebotado» y mantiene la comunicación como no entregada.
3. **Sistema:** Crea una incidencia de entrega (CU-25) y avisa al responsable del cliente.
4. **Usuario operativo:** Abre la incidencia y consulta el destinatario y el motivo del rebote.
5. **Usuario operativo:** Corrige el contacto o selecciona otro contacto del cliente (CU-01, FA-2).
6. **Usuario operativo:** Solicita reenviar la comunicación.
7. **Sistema:** Reenvía la comunicación (CU-18, FA-1) con el mismo documento y registra el nuevo intento.
8. **Proveedor de correo:** Confirma la entrega y el sistema marca la comunicación como entregada y la incidencia como resuelta.

---

### 4. Flujos alternativos

#### FA-1 — El reenvío vuelve a rebotar

**Se produce en:** paso 8 del flujo principal.  
**Condición:** El Proveedor de correo informa de un nuevo rebote.

1. **Proveedor de correo:** Informa de un nuevo rebote.
2. **Sistema:** Registra el intento, mantiene abierta la incidencia y avisa de nuevo al responsable.

**Continuación:** el caso de uso regresa al paso 4 del flujo principal con la incidencia abierta.

#### FA-2 — Cerrar la incidencia sin reenviar

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El usuario gestiona el contacto por otra vía.

1. **Usuario operativo:** Gestiona el contacto por otra vía.
2. **Usuario operativo:** Cierra la incidencia con un comentario y el sistema lo registra.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Sin contacto alternativo válido

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El cliente no tiene ningún contacto con correo válido.

1. **Sistema:** La incidencia permanece abierta y el sistema muestra el cliente como «contacto pendiente de corregir».

**Resultado:** La incidencia permanece abierta y el caso de uso termina hasta que se disponga de un contacto válido.

#### FE-2 — Cliente no asignado

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El usuario intenta gestionar la incidencia de un cliente que no tiene asignado.

1. **Usuario operativo:** Intenta gestionar la incidencia de un cliente que no tiene asignado.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. La comunicación queda entregada o la incidencia continúa abierta con su historial de intentos.
- POST-2. Los contactos corregidos quedan registrados en la línea temporal del cliente.

---

## CU-20 — Ejecutar flujo de recordatorios e impago

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-20 |
| **Nombre** | Ejecutar flujo de recordatorios e impago |
| **Objetivo** | Avisar automáticamente al cliente antes y después del vencimiento de una factura hasta que se detecte el pago o intervenga una persona. |
| **Actores participantes** | Planificador del sistema (principal), Proveedor de correo (secundario; a través de CU-18) |

---

### 2. Precondiciones

- PRE-1. Existen facturas emitidas pendientes de cobro.
- PRE-2. Los plazos y la cadencia de recordatorios están configurados (CU-36).

---

### 3. Flujo principal

1. **Planificador del sistema:** Inicia la ejecución diaria.
2. **Sistema:** Selecciona las facturas emitidas pendientes de cobro, excluyendo las pagadas, anuladas o con recordatorios suspendidos.
3. **Sistema:** Determina, para cada factura, el recordatorio que corresponde según su vencimiento, dando prioridad al vencimiento pactado sobre el general.
4. **Sistema:** Comprueba que no se ha detectado un pago desde la última ejecución.
5. **Sistema:** Solicita el envío de la comunicación correspondiente (recordatorio previo, de vencimiento o aviso de impago) mediante CU-18.
6. **Sistema:** Registra cada aviso en la factura y en la línea temporal del cliente.
7. **Sistema:** Registra el resultado de la ejecución en la monitorización (CU-33).

---

### 4. Flujos alternativos

#### FA-1 — Factura de un cliente dado de baja

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La factura pertenece a un cliente dado de baja.

1. **Sistema:** La incluye igualmente: el recobro de la deuda continúa tras la baja.

**Continuación:** el caso de uso continúa en el paso 3 del flujo principal.

#### FA-2 — Pago detectado

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Se ha detectado el pago de la factura (CU-16).

1. **Sistema:** No envía el aviso y detiene el flujo de esa factura.

**Continuación:** el caso de uso continúa con la siguiente factura (paso 3 del flujo principal).

#### FA-3 — Recordatorios suspendidos

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La factura tiene los recordatorios suspendidos (CU-21).

1. **Sistema:** La omite hasta que se reanuden.

**Continuación:** el caso de uso continúa con la siguiente factura (paso 3 del flujo principal).

---

### 5. Flujos de excepción

#### FE-1 — Fallo o rebote del envío

**Se produce en:** paso 5 del flujo principal.  
**Condición:** CU-18 informa de un fallo o de un rebote.

1. **Sistema:** Registra el resultado, gestiona la incidencia (CU-19) y continúa con las demás facturas.

**Resultado:** El caso de uso continúa con la siguiente factura (paso 3 del flujo principal).

#### FE-2 — Ejecución interrumpida

**Se produce en:** cualquier paso del flujo principal.  
**Condición:** La ejecución se interrumpe antes de terminar.

1. **Sistema:** Al reanudarse, completa los avisos pendientes sin enviar dos veces el mismo aviso y registra el error en monitorización.

**Resultado:** El caso de uso continúa en el paso 5 del flujo principal con las facturas pendientes.

#### FE-3 — Falta contacto de impagos

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El cliente no tiene contacto del tipo adecuado.

1. **Sistema:** No envía el aviso, crea una incidencia y avisa al responsable del cliente.

**Resultado:** El caso de uso continúa con la siguiente factura (paso 3 del flujo principal).

---

### 6. Postcondiciones

- POST-1. Cada factura pendiente ha recibido a lo sumo un aviso por fase, registrado con su resultado.
- POST-2. El flujo de una factura se detiene al detectarse el pago, al suspenderse o al intervenir una persona.
- POST-3. El resultado de la ejecución queda disponible en la monitorización.

---

## CU-21 — Suspender recordatorios de una factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-21 |
| **Nombre** | Suspender recordatorios de una factura |
| **Objetivo** | Pausar los recordatorios automáticos de una factura concreta mientras existe una disputa o un seguimiento humano. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. La factura está emitida y pendiente de cobro.
- PRE-2. El cliente está asignado al usuario (o el usuario es Administrador o superior).

---

### 3. Flujo principal

1. **Usuario operativo:** Abre la factura y selecciona «Suspender recordatorios».
2. **Sistema:** Solicita el motivo y una fecha de revisión.
3. **Usuario operativo:** Los introduce.
4. **Sistema:** Valida los datos y guarda la suspensión.
5. **Sistema:** Registra la acción en la línea temporal y confirma la operación.

---

### 4. Flujos alternativos

#### FA-1 — Reanudar los recordatorios

**Se produce en:** después del paso 5 del flujo principal (suspensión vigente).  
**Condición:** El usuario selecciona «Reanudar recordatorios» antes de la fecha de revisión.

1. **Usuario operativo:** Selecciona «Reanudar recordatorios» antes de la fecha de revisión.
2. **Sistema:** Levanta la suspensión y CU-20 vuelve a incluir la factura.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Llega la fecha de revisión

**Se produce en:** después del paso 5 del flujo principal (llegada de la fecha de revisión).  
**Condición:** Llega la fecha de revisión de la suspensión.

1. **Sistema:** Avisa al responsable del cliente; la suspensión se mantiene hasta que se reanude o se prorrogue (A-13).

**Continuación:** el caso de uso finaliza.

#### FA-3 — Disputa resuelta

**Se produce en:** FA-1 (reanudación de los recordatorios).  
**Condición:** El motivo de la suspensión era una disputa que se ha resuelto.

1. **Sistema:** Ofrece enviar al cliente la comunicación de «disputa resuelta» (CU-18).
2. **Usuario operativo:** Acepta el envío.
3. **Sistema:** Envía la comunicación (CU-18).

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Datos inválidos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Falta el motivo o la fecha de revisión no es futura.

1. **Sistema:** No guarda e indica qué corregir.

**Resultado:** El usuario corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Factura no pendiente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** La factura ya está pagada, anulada o no ha sido emitida.

1. **Sistema:** Impide la suspensión e informa del estado actual.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

#### FE-3 — Cliente no asignado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta suspender recordatorios de un cliente que no tiene asignado.

1. **Usuario operativo:** Intenta suspender recordatorios de un cliente que no tiene asignado.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. La factura queda con los recordatorios suspendidos, con su motivo y fecha de revisión, o reanudados.
- POST-2. La acción queda en la línea temporal y en el registro de auditoría.

---

## CU-22 — Gestionar plantillas de comunicación

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-22 |
| **Nombre** | Gestionar plantillas de comunicación |
| **Objetivo** | Mantener las plantillas de los correos de factura y recordatorios, con variables, idiomas e historial de uso. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior y tiene permiso para editar plantillas.

---

### 3. Flujo principal

1. **Administrador:** Accede a las plantillas y selecciona el tipo (factura, recordatorio previo, vencimiento, impago o disputa resuelta) y el idioma.
2. **Sistema:** Muestra el contenido y las variables dinámicas disponibles.
3. **Administrador:** Edita el contenido.
4. **Administrador:** Solicita la previsualización.
5. **Sistema:** Muestra la previsualización con datos de ejemplo y avisa mediante una alerta si falta alguna variable.
6. **Administrador:** Guarda la plantilla.
7. **Sistema:** Guarda una nueva versión, que se usará en los envíos posteriores, y registra quién la modificó y cuándo.

---

### 4. Flujos alternativos

#### FA-1 — Crear una plantilla en otro idioma

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Administrador crea la plantilla de un tipo existente en otro idioma.

1. **Administrador:** Crea la plantilla de un tipo existente en otro idioma.
2. **Sistema:** La guarda como una nueva plantilla disponible para ese idioma.

**Continuación:** el caso de uso continúa en el paso 2 del flujo principal.

#### FA-2 — Consultar el historial de uso

**Se produce en:** paso 1 del flujo principal (consulta de un envío concreto).  
**Condición:** El Administrador consulta qué plantilla se usó en un envío.

1. **Administrador:** Consulta qué plantilla se usó en un envío.
2. **Sistema:** Muestra la versión utilizada en ese envío.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Contenido o variable no válidos

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El contenido está vacío o usa una variable inexistente.

1. **Sistema:** No guarda e indica qué corregir.

**Resultado:** El usuario corrige el contenido y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Sin permiso

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un usuario sin permiso intenta editar una plantilla.

1. **Administrador:** Sin permiso intenta editar una plantilla.
2. **Sistema:** Rechaza la operación (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

---

### 6. Postcondiciones

- POST-1. La nueva versión de la plantilla se aplica a los envíos posteriores.
- POST-2. Los envíos y las facturas ya emitidos conservan la versión utilizada y no se alteran.
- POST-3. El cambio queda en el registro de auditoría.

---

<!-- Bloque E. Seguimiento, consulta e informes -->

## CU-23 — Gestionar notificaciones y canales

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-23 |
| **Nombre** | Gestionar notificaciones y canales |
| **Objetivo** | Consultar y resolver las notificaciones internas, configurar su canal y comunicarse en los canales internos de cliente o factura. |
| **Actores participantes** | Usuario operativo y Planificador del sistema (principales; resumen diario) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado.

---

### 3. Flujo principal

1. **Usuario operativo:** Abre su bandeja de notificaciones.
2. **Sistema:** Muestra las notificaciones dirigidas al usuario, ordenadas por fecha y diferenciando las que requieren acción.
3. **Usuario operativo:** Abre una notificación y accede al elemento relacionado.
4. **Usuario operativo:** Realiza la acción necesaria o la marca como leída o resuelta.
5. **Sistema:** Actualiza el estado de la notificación.
6. **Usuario operativo:** Configura, para cada tipo de notificación, el canal (en la aplicación, por correo o en el resumen diario).
7. **Sistema:** Guarda las preferencias.

---

### 4. Flujos alternativos

#### FA-1 — Resumen diario

**Se produce en:** después del paso 7 del flujo principal (hora del resumen diario).  
**Condición:** El Planificador del sistema llega a la hora del resumen diario.

1. **Planificador del sistema:** Llega a la hora del resumen diario.
2. **Sistema:** Reúne las notificaciones pendientes de los usuarios que lo han activado y se las envía por correo.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Bandeja global del Administrador

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario es Administrador o superior.

1. **Usuario operativo:** Es Administrador o superior.
2. **Sistema:** Muestra además las notificaciones globales de los clientes que gestiona.

**Continuación:** el caso de uso continúa en el paso 2 del flujo principal.

#### FA-3 — Canal interno de cliente o factura

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario escribe un mensaje en el canal interno de un cliente o factura, con adjuntos si procede.

1. **Usuario operativo:** Escribe un mensaje en el canal interno de un cliente o factura, con adjuntos si procede.
2. **Sistema:** Lo guarda y notifica a los usuarios mencionados (CU-25). Nunca se envía al cliente (A-15).

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Notificación ya resuelta

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Otro usuario ha resuelto la notificación.

1. **Sistema:** Informa del estado actual y no duplica la acción.

**Resultado:** El caso de uso termina sin duplicar la acción.

#### FE-2 — Fallo en el envío del resumen

**Se produce en:** FA-1 (resumen diario).  
**Condición:** Falla el envío del correo del resumen.

1. **Sistema:** Reintenta el envío y registra el error en la monitorización (CU-33).

**Resultado:** El resumen se enviará en el reintento y el caso de uso termina.

---

### 6. Postcondiciones

- POST-1. Las notificaciones quedan con su estado actualizado y las preferencias de canal guardadas.
- POST-2. Los mensajes internos permanecen dentro de la plataforma.

---

## CU-24 — Configurar alertas

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-24 |
| **Nombre** | Configurar alertas |
| **Objetivo** | Definir, dentro de un conjunto cerrado de reglas, las alertas que generan notificaciones sobre facturas y clientes. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior.

---

### 3. Flujo principal

1. **Administrador:** Accede a la configuración de alertas.
2. **Sistema:** Muestra las reglas disponibles (por ejemplo, factura vencida durante más de N días o cliente con deuda superior a un importe) y las alertas activas.
3. **Administrador:** Selecciona una regla y define sus parámetros.
4. **Sistema:** Valida los parámetros y activa la alerta.
5. **Sistema:** Confirma la operación y registra el cambio.

---

### 4. Flujos alternativos

#### FA-1 — Modificar una alerta

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El Administrador modifica los parámetros de una alerta activa.

1. **Administrador:** Modifica los parámetros de una alerta activa.
2. **Sistema:** Valida, guarda y registra los valores anteriores y nuevos.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Desactivar una alerta

**Se produce en:** paso 2 del flujo principal (alerta activa).  
**Condición:** El Administrador desactiva una alerta.

1. **Administrador:** Desactiva una alerta.
2. **Sistema:** Deja de generar notificaciones de esa alerta, sin borrar las ya emitidas.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Parámetros inválidos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un parámetro no es válido.

1. **Sistema:** No guarda e indica qué corregir.

**Resultado:** El Administrador corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Regla no disponible

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario intenta definir una regla que no pertenece al conjunto disponible.

1. **Administrador:** Intenta definir una regla que no pertenece al conjunto disponible.
2. **Sistema:** No lo permite: las alertas solo se crean a partir de las reglas existentes.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

---

### 6. Postcondiciones

- POST-1. La alerta queda activa, modificada o desactivada.
- POST-2. El cambio queda en el registro de auditoría.

---

## CU-25 — Gestionar incidencias y comentarios

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-25 |
| **Nombre** | Gestionar incidencias y comentarios |
| **Objetivo** | Registrar y seguir las incidencias de un cliente o factura, con comentarios internos, menciones y adjuntos. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado y el cliente está asignado al usuario (o el usuario es Administrador o superior).

---

### 3. Flujo principal

1. **Usuario operativo:** Abre la ficha del cliente o la factura y selecciona «Nueva incidencia».
2. **Sistema:** Muestra el formulario.
3. **Usuario operativo:** Indica el título, la descripción, el responsable y la prioridad, y adjunta archivos si procede.
4. **Sistema:** Valida los datos y guarda la incidencia con estado «abierta».
5. **Sistema:** Notifica al responsable y la registra en la línea temporal.
6. **Usuario operativo:** Añade comentarios internos a la incidencia (también puede hacerlo el responsable asignado).

---

### 4. Flujos alternativos

#### FA-1 — Actualizar la incidencia

**Se produce en:** después del paso 5 del flujo principal (incidencia ya registrada).  
**Condición:** El usuario cambia el estado, la prioridad o el responsable.

1. **Usuario operativo:** Cambia el estado, la prioridad o el responsable.
2. **Sistema:** Guarda el cambio, lo registra y notifica al nuevo responsable.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Mencionar a un usuario

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El usuario menciona a otro usuario en un comentario.

1. **Usuario operativo:** Menciona a otro usuario en un comentario.
2. **Sistema:** Le envía una notificación.

**Continuación:** el caso de uso continúa en el paso 6 del flujo principal.

#### FA-3 — Incidencia automática

**Se produce en:** paso 1 del flujo principal (invocación desde CU-19).  
**Condición:** CU-19 crea una incidencia al detectar un problema.

1. **Sistema:** Guarda la incidencia como incidencia automática.

**Continuación:** el caso de uso continúa en el paso 5 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Datos o adjunto inválidos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Falta el título o el adjunto no cumple los límites permitidos.

1. **Sistema:** No guarda e indica qué corregir.

**Resultado:** El usuario corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Cliente no asignado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta abrir una incidencia de un cliente que no tiene asignado.

1. **Usuario operativo:** Intenta abrir una incidencia de un cliente que no tiene asignado.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. La incidencia queda registrada con su estado, prioridad, responsable, comentarios y adjuntos.
- POST-2. Los comentarios internos nunca se envían al cliente.

---

## CU-26 — Generar, exportar y conservar informes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-26 |
| **Nombre** | Generar, exportar y conservar informes |
| **Objetivo** | Obtener informes filtrados, exportarlos y conservarlos durante un periodo para su posterior descarga. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso para consultar informes.

---

### 3. Flujo principal

1. **Usuario operativo:** Accede a los informes y selecciona el tipo de informe.
2. **Usuario operativo:** Define los filtros (periodo, cliente, responsable, país, sector, estado, tipo y moneda).
3. **Sistema:** Genera el informe limitándose a los datos que el usuario tiene permiso para ver y lo muestra.
4. **Usuario operativo:** Selecciona «Exportar» y elige el formato (CSV o PDF).
5. **Sistema:** Genera el archivo, lo conserva durante el periodo configurado y entrega un enlace de descarga temporal (A-04).
6. **Usuario operativo:** Descarga el archivo.

---

### 4. Flujos alternativos

#### FA-1 — Informe pesado

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El informe requiere un procesamiento largo.

1. **Sistema:** Lo genera en segundo plano, notifica al usuario cuando está listo y no bloquea la aplicación.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal cuando el informe está listo.

#### FA-2 — Descargar un informe conservado

**Se produce en:** paso 1 del flujo principal (informe ya exportado).  
**Condición:** El usuario accede a un informe exportado anteriormente.

1. **Usuario operativo:** Accede a un informe exportado anteriormente.
2. **Sistema:** Comprueba los permisos y la vigencia del archivo y lo entrega.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Sin datos

**Se produce en:** paso 3 del flujo principal.  
**Condición:** No hay datos para los filtros elegidos.

1. **Sistema:** Lo indica y sugiere ampliar los filtros.

**Resultado:** El usuario puede ampliar los filtros y el caso de uso regresa al paso 2 del flujo principal.

#### FE-2 — Archivo expirado o enlace no autorizado

**Se produce en:** FA-2 (descarga de un informe conservado).  
**Condición:** El archivo ha superado el periodo de conservación o el usuario ya no tiene permiso.

1. **Sistema:** No entrega el archivo y ofrece generarlo de nuevo si los permisos lo permiten.

**Resultado:** El caso de uso termina sin entregar el archivo.

#### FE-3 — Fallo en la generación

**Se produce en:** pasos 3 o 5 del flujo principal.  
**Condición:** La generación falla.

1. **Sistema:** Muestra un error con un identificador y lo registra en la monitorización (CU-33).

**Resultado:** El caso de uso termina sin generar el informe; el usuario puede repetirlo desde el paso 1 del flujo principal.

---

### 6. Postcondiciones

- POST-1. El informe se ha generado con los filtros indicados y solo con datos permitidos.
- POST-2. El archivo exportado se conserva durante el periodo configurado y solo es accesible con autenticación.

---

## CU-27 — Consultar dashboard financiero

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-27 |
| **Nombre** | Consultar dashboard financiero |
| **Objetivo** | Ver el estado financiero global (facturación, cobros y deuda) y desglosar cada cifra hasta los datos que la componen. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior.

---

### 3. Flujo principal

1. **Administrador:** Accede al dashboard financiero.
2. **Sistema:** Muestra las cifras principales actualizadas (por ejemplo, importes pendientes de cobro, facturación y deuda vencida).
3. **Administrador:** Filtra por empresa, fecha u otros criterios disponibles.
4. **Sistema:** Actualiza las cifras.
5. **Administrador:** Selecciona una cifra.
6. **Sistema:** Muestra el detalle (clientes y facturas) que la componen.

---

### 4. Flujos alternativos

#### FA-1 — Comparar con objetivos

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador activa la comparación con los objetivos de facturación (CU-28).

1. **Administrador:** Activa la comparación con los objetivos de facturación (CU-28).
2. **Sistema:** Muestra las cifras reales junto al objetivo.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

#### FA-2 — Ver por centro de coste

**Se produce en:** paso 4 del flujo principal (tras mostrar las cifras).  
**Condición:** El Administrador agrupa las cifras por centro de coste.

1. **Administrador:** Agrupa las cifras por centro de coste.
2. **Sistema:** Muestra el desglose por categoría.

**Continuación:** el caso de uso finaliza.

#### FA-3 — Abrir una factura desde el detalle

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El Administrador selecciona una factura.

1. **Administrador:** Selecciona una factura.
2. **Sistema:** Abre su ficha (CU-15).

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Sin datos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No hay datos para el periodo o filtros elegidos.

1. **Sistema:** Lo indica sin mostrar cifras a cero engañosas.

**Resultado:** El caso de uso termina mostrando la ausencia de datos; el usuario puede cambiar los filtros desde el paso 3 del flujo principal.

#### FE-2 — Filtro inválido

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador introduce un rango de fechas no válido.

1. **Administrador:** Introduce un rango de fechas no válido.
2. **Sistema:** No aplica el filtro e indica qué corregir.

**Resultado:** El Administrador corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

---

### 6. Postcondiciones

- POST-1. El Administrador ha consultado las cifras con los filtros elegidos.
- POST-2. La consulta no modifica ningún dato.
- POST-3. Las cantidades en distintas monedas se muestran convertidas a la moneda base solo a efectos de informe.

---

## CU-28 — Gestionar objetivos y centros de coste

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-28 |
| **Nombre** | Gestionar objetivos y centros de coste |
| **Objetivo** | Definir los objetivos de facturación y las categorías de coste que alimentan el dashboard y los informes. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior.

---

### 3. Flujo principal

*Escenario descrito: definir un objetivo.*

1. **Administrador:** Accede a la gestión de objetivos.
2. **Sistema:** Muestra los objetivos vigentes.
3. **Administrador:** Define un objetivo de facturación indicando el periodo y el importe.
4. **Sistema:** Valida los datos y guarda el objetivo, registrando quién y cuándo.
5. **Sistema:** Lo hace visible en el dashboard (CU-27).

---

### 4. Flujos alternativos

#### FA-1 — Modificar un objetivo

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El Administrador modifica un objetivo existente.

1. **Administrador:** Modifica un objetivo existente.
2. **Sistema:** Guarda el cambio registrando los valores anteriores y nuevos.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Gestionar centros de coste

**Se produce en:** paso 1 del flujo principal (gestión de categorías de coste).  
**Condición:** El Administrador crea, renombra o desactiva una categoría de coste y la asigna a clientes o facturas.

1. **Administrador:** Crea, renombra o desactiva una categoría de coste y la asigna a clientes o facturas.
2. **Sistema:** Guarda el cambio. Renombrar una categoría no altera ni elimina la información histórica asociada.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Datos inválidos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El periodo o el importe no son válidos, o solapan con otro objetivo.

1. **Sistema:** No guarda e indica qué corregir.

**Resultado:** El Administrador corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Categoría con información asociada

**Se produce en:** FA-2 (gestión de categorías de coste).  
**Condición:** El Administrador intenta eliminar una categoría que tiene información asociada.

1. **Administrador:** Intenta eliminar una categoría que tiene información asociada.
2. **Sistema:** No la elimina y ofrece desactivarla (A-16).

**Resultado:** El caso de uso termina sin eliminar la categoría.

---

### 6. Postcondiciones

- POST-1. Los objetivos y las categorías quedan guardados y visibles para el dashboard y los informes.
- POST-2. La información histórica no se altera.
- POST-3. Los cambios quedan en el registro de auditoría.

---

## CU-29 — Consultar pantalla de trabajo diario

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-29 |
| **Nombre** | Consultar pantalla de trabajo diario |
| **Objetivo** | Mostrar a cada usuario, en una única pantalla, lo que debe atender hoy. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado.

---

### 3. Flujo principal

1. **Usuario operativo:** Accede a su pantalla de trabajo diario (por defecto, tras iniciar sesión).
2. **Sistema:** Muestra, limitado a los clientes del usuario, las facturas que vencen pronto o están vencidas, los pagos pendientes de conciliar, los problemas de entrega, las aprobaciones pendientes y las tareas asignadas.
3. **Usuario operativo:** Selecciona un elemento.
4. **Sistema:** Abre la pantalla correspondiente para resolverlo.

---

### 4. Flujos alternativos

#### FA-1 — Aprobaciones del Administrador

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario es Administrador o superior.

1. **Usuario operativo:** Es Administrador o superior.
2. **Sistema:** Incluye además las aprobaciones que le corresponde resolver (CU-08, CU-09 y CU-13).

**Continuación:** el caso de uso continúa en el paso 3 del flujo principal.

#### FA-2 — Nada pendiente

**Se produce en:** paso 2 del flujo principal.  
**Condición:** No hay elementos pendientes.

1. **Sistema:** Lo indica con un mensaje claro.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Elemento ya resuelto

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Otro usuario ha resuelto el elemento mientras tanto.

1. **Sistema:** Informa de su estado actual y lo retira de la lista.

**Resultado:** El caso de uso continúa en el paso 2 del flujo principal con la lista actualizada.

#### FE-2 — Fallo parcial al cargar

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Una de las secciones no puede cargarse.

1. **Sistema:** Muestra el resto de secciones, indica cuál ha fallado y permite reintentar.

**Resultado:** El caso de uso continúa en el paso 3 del flujo principal con las secciones disponibles.

---

### 6. Postcondiciones

- POST-1. El usuario conoce sus pendientes y puede acceder a ellos directamente.
- POST-2. La consulta no modifica ningún dato.

---

<!-- Bloque F. Administración, seguridad y sistema -->

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

## Anexo A. Relaciones entre casos de uso

Relaciones `<<include>>` / `<<extend>>` del diagrama de casos de uso.

| Caso de uso | Relaciones |
|---|---|
| CU-01 — Gestionar cliente y contactos | `<<include>>` CU-02 Detectar cliente duplicado |
| CU-02 — Detectar cliente duplicado | Incluido por CU-01 y CU-03 |
| CU-03 — Importar datos por CSV | `<<include>>` CU-02 Detectar cliente duplicado |
| CU-06 — Revisar y aprobar rango de tarifa anual | Usa la tabla de tarifas configurada en CU-35 |
| CU-07 — Solicitar descuento | La solicitud se resuelve en CU-08; puede escalarse mediante CU-09 |
| CU-08 — Aprobar descuento | Extendido por CU-09 Escalar aprobación al Superadministrador (cuando el descuento supera el umbral configurable) |
| CU-09 — Escalar aprobación al Superadministrador | `<<extend>>` CU-08 Aprobar descuento (el descuento supera el umbral configurable) |
| CU-10 — Gestionar borrador de factura | El borrador se emite en CU-12 |
| CU-11 — Generar facturas recurrentes | `<<include>>` CU-12 Emitir factura (extendido por CU-13 Aprobar factura retenida cuando hay cambios sensibles) |
| CU-12 — Emitir factura | Incluido por CU-11; `<<include>>` CU-18 Enviar comunicación al cliente; extendido por CU-13 Aprobar factura retenida |
| CU-13 — Aprobar factura retenida | `<<extend>>` CU-12 Emitir factura (la factura tiene un cambio sensible: importe manual, descuento extraordinario, vencimiento atípico o puntual de importe alto) |
| CU-16 — Registrar movimiento de cobro | `<<include>>` CU-17 Conciliar pagos |
| CU-17 — Conciliar pagos | Incluido por CU-16 |
| CU-18 — Enviar comunicación al cliente | Incluido por CU-12 y CU-20; extendido por CU-19 Gestionar rebote de correo |
| CU-19 — Gestionar rebote de correo | `<<extend>>` CU-18 (el correo rebota); `<<include>>` CU-25 Gestionar incidencias y comentarios |
| CU-20 — Ejecutar flujo de recordatorios e impago | `<<include>>` CU-18 Enviar comunicación al cliente; extendido por CU-21 Suspender recordatorios de una factura |
| CU-21 — Suspender recordatorios de una factura | `<<extend>>` CU-20 (una factura concreta tiene los recordatorios suspendidos) |
| CU-22 — Gestionar plantillas de comunicación | Las plantillas se usan en CU-18 |
| CU-23 — Gestionar notificaciones y canales | Recibe las alertas definidas en CU-24 y los avisos generados por otros casos de uso |
| CU-24 — Configurar alertas | Las alertas generan notificaciones gestionadas en CU-23 |
| CU-25 — Gestionar incidencias y comentarios | Incluido por CU-19 Gestionar rebote de correo |
| CU-27 — Consultar dashboard financiero | Muestra los objetivos y centros de coste de CU-28 |
| CU-28 — Gestionar objetivos y centros de coste | Alimenta CU-27 y CU-26 |
| CU-29 — Consultar pantalla de trabajo diario | Punto de acceso a CU-04, CU-08, CU-13, CU-17, CU-19 y CU-21 |
| CU-30 — Iniciar sesión y recuperar contraseña | Da acceso a CU-29 |
| CU-33 — Consultar monitorización y métricas | Recibe los resultados de CU-11, CU-16, CU-18 y CU-20 |
| CU-34 — Consultar registro de auditoría | Recoge los eventos generados por el resto de casos de uso |
| CU-35 — Configurar facturación y tarifas | Sus parámetros se usan en CU-06, CU-07, CU-09, CU-11 y CU-12 |
| CU-36 — Configurar recordatorios y funciones inteligentes | Sus parámetros se usan en CU-20 |
| CU-37 — Consultar datos y operar por API | Las solicitudes registradas se resuelven en los casos de uso humanos (por ejemplo, CU-05) |

---

## Anexo B. Trazabilidad con los requisitos

| Caso de uso | Requisitos relacionados |
|---|---|
| CU-01 — Gestionar cliente y contactos | FR-03, FR-04, FR-11, FR-27, FR-30, FR-33, FR-43, FR-44, FR-47, UR-12, BR-17, BR-18, BR-19, NFR-07, NFR-09 |
| CU-02 — Detectar cliente duplicado | FR-27, UR-12, BR-01 |
| CU-03 — Importar datos por CSV | FR-08, FR-27, FR-31, UR-12, BR-01, BR-06, NFR-09 |
| CU-04 — Gestionar tareas del cliente | FR-32, FR-43, FR-50, UR-12, NFR-07 |
| CU-05 — Gestionar baja y pausa de suscripción | FR-09, FR-16, FR-43, FR-24, UR-12, BR-14, BR-15, BR-19, NFR-09 |
| CU-06 — Revisar y aprobar rango de tarifa anual | FR-10, FR-17, UR-13, BR-11, BR-12, NFR-09 |
| CU-07 — Solicitar descuento | FR-13, FR-18, UR-12, BR-12, NFR-09 |
| CU-08 — Aprobar descuento | FR-18, FR-24, UR-13, BR-12, NFR-09 |
| CU-09 — Escalar aprobación al Superadministrador | FR-18, FR-24, UR-13, BR-12, NFR-09 |
| CU-10 — Gestionar borrador de factura | FR-01, FR-02, FR-13, FR-14, FR-19, FR-30, UR-05, BR-09, BR-24, NFR-06, NFR-13 |
| CU-11 — Generar facturas recurrentes | FR-01, FR-02, FR-09, FR-11, FR-13, FR-16, FR-18, FR-20, FR-24, FR-47, FR-48, BR-02, BR-10, BR-12, BR-14, BR-15, BR-16, BR-17, BR-18, BR-24, NFR-06, NFR-15 |
| CU-12 — Emitir factura | FR-01, FR-12, FR-13, FR-14, FR-18, FR-19, FR-20, FR-23, FR-24, FR-46, BR-09, BR-10, BR-12, UR-10, NFR-13 |
| CU-13 — Aprobar factura retenida | FR-13, FR-18, FR-19, FR-24, UR-13, BR-12, NFR-09 |
| CU-14 — Rectificar, anular o declarar incobrable una factura | FR-14, FR-19, FR-45, FR-46, UR-13, BR-09, BR-12, BR-13, NFR-09 |
| CU-15 — Buscar y consultar facturas y clientes | FR-12, FR-19, FR-28, FR-44, UR-02, UR-03, UR-07, NFR-07, NFR-12 |
| CU-16 — Registrar movimiento de cobro | FR-15, FR-21, FR-24, FR-48, FR-50, BR-06, BR-13, UR-14, NFR-09 |
| CU-17 — Conciliar pagos | FR-15, FR-19, FR-21, FR-22, FR-24, FR-50, BR-13, UR-14, NFR-09 |
| CU-18 — Enviar comunicación al cliente | FR-23, FR-26, FR-46, FR-48, BR-06, BR-20, BR-21, NFR-17 |
| CU-19 — Gestionar rebote de correo | FR-04, FR-23, FR-24, FR-34, UR-14, BR-03 |
| CU-20 — Ejecutar flujo de recordatorios e impago | FR-05, FR-26, FR-48, BR-03, BR-14, BR-15, BR-16, NFR-15 |
| CU-21 — Suspender recordatorios de una factura | FR-05, FR-24, FR-26, UR-14, BR-03, NFR-09 |
| CU-22 — Gestionar plantillas de comunicación | FR-26, UR-15, BR-11, BR-20, NFR-09 |
| CU-23 — Gestionar notificaciones y canales | FR-24, FR-35, FR-36, FR-42, UR-14, BR-03, BR-21 |
| CU-24 — Configurar alertas | FR-42, UR-14, BR-03, NFR-09 |
| CU-25 — Gestionar incidencias y comentarios | FR-24, FR-34, FR-35, FR-36, UR-14, BR-21, NFR-07 |
| CU-26 — Generar, exportar y conservar informes | FR-25, FR-37, UR-09, UR-15, BR-04, BR-24, NFR-07, NFR-12, NFR-17 |
| CU-27 — Consultar dashboard financiero | FR-29, FR-40, FR-41, UR-04, UR-09, BR-04, BR-24 |
| CU-28 — Gestionar objetivos y centros de coste | FR-40, FR-41, UR-15, BR-04, NFR-09 |
| CU-29 — Consultar pantalla de trabajo diario | FR-24, FR-32, FR-50, UR-14, BR-03, NFR-07 |
| CU-30 — Iniciar sesión y recuperar contraseña | FR-06, UR-01, UR-11, BR-05, NFR-08, NFR-09 |
| CU-31 — Gestionar usuarios, roles y asignación de clientes | FR-06, FR-07, FR-32, UR-01, UR-06, NFR-07, NFR-08, NFR-09 |
| CU-32 — Ejecutar acción masiva | FR-31, UR-12, BR-12, NFR-07, NFR-09 |
| CU-33 — Consultar monitorización y métricas | FR-38, FR-48, UR-08, BR-03, BR-08, NFR-14 |
| CU-34 — Consultar registro de auditoría | FR-10, FR-22, UR-10, NFR-09 |
| CU-35 — Configurar facturación y tarifas | FR-01, FR-10, FR-17, FR-18, UR-13, BR-11, BR-12, NFR-09 |
| CU-36 — Configurar recordatorios y funciones inteligentes | FR-05, FR-39, UR-13, BR-16, BR-23, BR-25, NFR-09 |
| CU-37 — Consultar datos y operar por API | FR-49, BR-07, BR-22, NFR-07, NFR-09, NFR-17 |

---

## Anexo C. Supuestos de análisis introducidos

Decisiones tomadas al especificar que `requisitos.md` no resuelve de forma explícita. Siguen la numeración de la sección 6 de `requisitos.md` (A-02 a A-04 ya existen; A-01 es una fila vacía) y conviene trasladarlas allí o validarlas con el equipo.

| ID | Suposición | Justificación | Requisitos / casos afectados |
|---|---|---|---|
| A-05 | Un cliente puede guardarse sin identificador fiscal, quedando marcado con «datos fiscales incompletos» y sin poder facturarse hasta completarlos. | FR-20 bloquea la emisión por falta de datos fiscales, lo que implica que el cliente puede existir sin ellos; además un identificador extranjero puede no estar disponible al alta. | FR-03, FR-20 · CU-01 (FA-5), CU-02 (FE-1), CU-03 (FA-3), CU-11 (FE-1), CU-12 (FE-1) |
| A-06 | El alta de un cliente exige al menos un contacto. | FR-46 envía la factura al contacto de facturación; sin contacto no habría destinatario. | FR-04, FR-46 · CU-01 |
| A-07 | La importación CSV es atómica: ante un fallo técnico se revierte la operación completa. | Evitar registros a medias y duplicados al reintentar (afín a NFR-15). | FR-08, NFR-15 · CU-03 (FE-3) |
| A-08 | En una importación, una fila que coincide con un cliente existente solo lo actualiza si el usuario lo decide de forma explícita. | Conciliar FR-08 (registros «actualizados») con FR-27 (nunca fusionar automáticamente). | FR-08, FR-27 · CU-02 (FA-2), CU-03 |
| A-09 | Si el envío de una factura emitida falla, esta permanece en estado «emitida» hasta que el envío se complete, momento en que pasa a «enviada». | FR-19 define ambos estados y FR-46 indica que un fallo de envío no deshace la emisión. | FR-19, FR-46 · CU-12 (FE-2) |
| A-10 | Las excepciones comerciales con efecto económico (primer mes gratuito, facturación sin prorrateo) quedan pendientes de aprobación (CU-07 y CU-08) y no se aplican en la facturación hasta ser aprobadas. El inicio futuro no requiere aprobación. | BR-12 exige aprobación humana para excepciones económicas sensibles y UR-12 habla de «solicitar» excepciones; FR-47 no menciona aprobación. Sin esta decisión, CU-11 aplicaría un descuento no aprobado y lo emitiría sin revisión. | FR-47, FR-18, BR-12, UR-12 · CU-01 (FA-4), CU-11 (FA-3) |
| A-11 | Los umbrales de aprobación, las series, los impuestos, la tabla de tarifas y los datos del emisor se configuran en CU-35; la cadencia de recordatorios y las funciones inteligentes, en CU-36. | `requisitos.md` (sección 1.3) atribuye al Superadministrador la configuración de ambos grupos sin repartirlos; el diagrama los separa en CU-35 y CU-36. | FR-01, FR-05, FR-17, FR-18 · CU-35, CU-36 |
| A-12 | Una factura declarada incobrable deja de recibir recordatorios de impago, sin pasar nunca a «pagada». | FR-19 impide que una deuda incobrable figure como pagada, pero no dice si el recobro automático continúa. | FR-05, FR-19, FR-45 · CU-14 (FA-3), CU-20 |
| A-13 | Al llegar la fecha de revisión de una suspensión de recordatorios, el sistema avisa al responsable y la suspensión se mantiene hasta que se reanude o se prorrogue. | FR-05 exige una fecha de revisión pero no indica si la suspensión termina sola. | FR-05, FR-24 · CU-21 (FA-2) |
| A-14 | Un Administrador no puede conceder ni modificar el rol Superadministrador. | UR-06 permite gestionar roles sin fijar límites; se evita la escalada de privilegios. | FR-07, UR-06, NFR-08 · CU-31 (FE-3) |
| A-15 | Los «canales de comunicación internos» de FR-35 se interpretan como conversaciones internas, con adjuntos, asociadas a un cliente o factura, que nunca se envían al cliente. | La redacción de FR-35 es ambigua; BR-21 impide que los comentarios internos salgan al cliente. | FR-35, BR-21 · CU-23 (FA-3), CU-25 |
| A-16 | Una categoría de centro de coste con información asociada no se elimina, solo se desactiva. | FR-40 exige que la información histórica no se altere ni se elimine al modificar categorías. | FR-40 · CU-28 (FE-2) |
| A-17 | Las acciones masivas de alto impacto económico exigen confirmación reforzada y la aprobación de una persona distinta de quien las solicita. | FR-31 prohíbe estas acciones «sin controles» sin definirlos; se reutiliza el criterio de BR-12. | FR-31, BR-12 · CU-32 (FA-2) |
| A-18 | Las acciones masivas son atómicas: si fallan, se revierte la operación completa. | Mismo criterio que A-07; evita datos a medias en una operación de gran alcance. | FR-31, NFR-15 · CU-32 (FE-3) |
