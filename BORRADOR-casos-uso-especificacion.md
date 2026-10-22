# Especificación de casos de uso

Este documento especifica los casos de uso del **Sistema de facturación de Turbine** (proyecto JIRAFAS). La numeración, los nombres, los actores y las relaciones `<<include>>` / `<<extend>>` siguen el diagrama de casos de uso de Pablo Fernández Carabantes (bloques A–F). Cada ficha indica los requisitos de `requisitos.md` que cubre. Incluye las 37 fichas del índice, agrupadas por bloques, y al final los supuestos de análisis introducidos.

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

## Bloque A. Clientes y contactos

### CU-01 - Gestionar cliente y contactos

| Campo | Contenido |
|---|---|
| Identificador | CU-01 |
| Nombre | Gestionar cliente y contactos |
| Objetivo | Dar de alta y mantener la ficha comercial y fiscal de un cliente y sus contactos, para poder asociarle suscripciones y facturarle. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | `<<include>>` CU-02 Detectar cliente duplicado |
| Requisitos relacionados | FR-03, FR-04, FR-11, FR-27, FR-30, FR-33, FR-43, FR-44, FR-47, UR-12, BR-17, BR-18, BR-19, NFR-07, NFR-09 |

### Precondiciones

- El usuario está autenticado y tiene permiso sobre la gestión de clientes.
- Para editar un cliente existente, este debe estar asignado al usuario (o el usuario ser Administrador o superior).

### Flujo principal (alta de cliente)

1. El Usuario operativo selecciona "Añadir cliente" en el módulo de clientes.
2. El sistema muestra el formulario de alta, autocompletando los campos recurrentes (país, moneda, vencimiento, tarifa) cuando es posible.
3. El Usuario operativo introduce los datos fiscales (nombre comercial, razón social, NIF o identificador fiscal, domicilio fiscal, país, moneda de trabajo) y la ficha comercial (fecha de inicio, plan o servicio, tarifa acordada, responsable interno, condiciones de pago y, si existe, documento firmado fuera de la plataforma).
4. El Usuario operativo registra al menos un contacto (nombre, correo y tipo: contratación, recepción de facturas o impagos).
5. El sistema valida el formato de los datos, comprueba posibles duplicados (CU-02) y, si el alta es a mitad de mes, muestra el cálculo del prorrateo de la primera factura antes de confirmar.
6. El sistema guarda el cliente y sus contactos, y registra el alta en la línea temporal del cliente.
7. El sistema confirma la operación y muestra la ficha del cliente creado.

### Flujos alternativos

#### A1. Editar un cliente existente

1. En el paso 1, el Usuario operativo abre la ficha de un cliente asignado y selecciona "Editar".
2. El sistema muestra los datos actuales y el usuario los modifica.
3. El sistema valida y guarda los cambios, y los registra en la línea temporal. Continúa en el paso 7.

#### A2. Gestionar contactos

1. Desde la ficha, el usuario añade, modifica o marca como inactivo un contacto.
2. El sistema permite que un contacto pertenezca a varios clientes.
3. Al marcar un contacto como inactivo, el sistema conserva su histórico y los destinatarios de las facturas ya enviadas.

#### A3. Etiquetar y marcar como favorito

1. El usuario asigna etiquetas al cliente (por ejemplo: estratégico, beta, partner, riesgo de cobro), además del sector y la ubicación, o lo marca como favorito.
2. El sistema guarda la clasificación. El acceso rápido por favoritos no sustituye la comprobación de permisos.

#### A4. Excepción comercial explícita

1. En el paso 3, el usuario registra o solicita una excepción comercial: inicio futuro, primer mes gratuito o facturación sin prorrateo.
2. El sistema guarda la excepción de forma explícita en la ficha del cliente. Si tiene efecto económico (primer mes gratuito o facturación sin prorrateo), queda pendiente de aprobación (CU-07 y CU-08) y no se aplica en la facturación hasta ser aprobada (A-10).
3. Si es un inicio futuro, el sistema deja al cliente en estado "pendiente de activación": no genera facturas ni recordatorios hasta esa fecha.

#### A5. Datos fiscales aún no disponibles

1. En el paso 3, el usuario no dispone todavía del identificador fiscal (p. ej. un identificador extranjero).
2. El sistema permite guardar el cliente, lo marca con "datos fiscales incompletos" e indica qué falta.
3. No se podrán emitir facturas a ese cliente hasta completar los datos (CU-12, E1).

### Flujos de excepción

#### E1. Posible cliente duplicado

1. En el paso 5, CU-02 detecta un cliente con el mismo identificador fiscal.
2. El sistema avisa al usuario y ofrece abrir la ficha existente, sin fusionar nada automáticamente.
3. El usuario puede cancelar el alta, corregir el identificador o confirmar que se trata de un cliente distinto.

#### E2. Datos obligatorios o formato inválido

1. En el paso 5, faltan datos obligatorios (salvo el identificador fiscal, ver A5) o su formato no es válido.
2. El sistema no guarda y señala exactamente qué campos hay que corregir.
3. El usuario corrige y reenvía el formulario.

#### E3. Cliente no asignado

1. En A1 o A2, el usuario intenta acceder a un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor) e informa de que el cliente no está asignado al usuario.

### Postcondiciones

- El cliente y sus contactos quedan registrados con su responsable interno y su clasificación.
- La línea temporal del cliente refleja el alta o la modificación.
- El cliente queda "activo" (o "pendiente de activación" si tiene inicio futuro) y es elegible para suscripciones y facturación.
- La acción queda registrada en el registro de auditoría.

---

### CU-02 - Detectar cliente duplicado

| Campo | Contenido |
|---|---|
| Identificador | CU-02 |
| Nombre | Detectar cliente duplicado |
| Objetivo | Avisar al usuario cuando un cliente que se va a crear o importar puede ya existir, evitando duplicidades sin fusionar registros automáticamente. |
| Actor principal | Usuario operativo (a través de CU-01 o CU-03) |
| Actores secundarios | Ninguno |
| Relaciones | Incluido por CU-01 y CU-03 |
| Requisitos relacionados | FR-27, UR-12, BR-01 |

### Precondiciones

- Se está creando o importando un cliente (CU-01 o CU-03).

### Flujo principal

1. CU-01 o CU-03 entrega al sistema el identificador fiscal del cliente.
2. El sistema normaliza el identificador (mayúsculas, sin espacios ni guiones) y lo compara con los clientes existentes.
3. El sistema no encuentra coincidencias y devuelve "sin duplicados" al caso de uso que lo invocó, que continúa su flujo.

### Flujos alternativos

#### A1. Coincidencia encontrada

1. En el paso 3, el sistema encuentra uno o varios clientes con el mismo identificador fiscal.
2. El sistema avisa de la posible duplicidad y muestra enlace a la ficha de cada coincidencia.
3. El usuario decide: cancelar, corregir el identificador o confirmar que es un cliente distinto. El sistema nunca fusiona automáticamente.

#### A2. Detección dentro de una importación CSV

1. Cuando lo invoca CU-03, el sistema marca cada fila con posible duplicado en la previsualización.
2. El usuario decide fila a fila si la importa como cliente nuevo, actualiza de forma explícita el cliente existente, la omite o la corrige. El sistema nunca fusiona ni actualiza por su cuenta.

### Flujos de excepción

#### E1. Cliente sin identificador fiscal

1. El cliente no tiene identificador fiscal (p. ej. un identificador extranjero aún no disponible).
2. El sistema no puede comprobar duplicados por ese campo y lo indica al usuario.
3. El usuario puede continuar, asumiendo que la comprobación no se ha realizado.

### Postcondiciones

- El usuario conoce las posibles duplicidades antes de guardar.
- No se ha fusionado ni modificado ningún cliente existente.

---

### CU-03 - Importar datos por CSV

| Campo | Contenido |
|---|---|
| Identificador | CU-03 |
| Nombre | Importar datos por CSV |
| Objetivo | Cargar de forma masiva clientes (y opcionalmente facturas históricas) desde un archivo CSV, controlando errores antes de confirmar. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | `<<include>>` CU-02 Detectar cliente duplicado |
| Requisitos relacionados | FR-08, FR-27, FR-31, UR-12, BR-01, BR-06, NFR-09 |

### Precondiciones

- El usuario está autenticado y tiene permiso de importación.
- Dispone de un archivo CSV con el formato esperado.

### Flujo principal

1. El Usuario operativo selecciona "Importar CSV" y sube el archivo.
2. El sistema valida la estructura (columnas y codificación) y analiza cada fila.
3. El sistema comprueba posibles duplicados por identificador fiscal (CU-02).
4. El sistema muestra una previsualización con filas válidas, filas con error (y su motivo) y posibles duplicados.
5. El usuario corrige los errores o excluye las filas problemáticas.
6. El sistema indica el número exacto de registros que se van a crear o actualizar y solicita confirmación.
7. El usuario confirma.
8. El sistema crea los clientes nuevos y actualiza únicamente aquellos que el usuario marcó explícitamente como actualización de un cliente existente (CU-02, A2).
9. El sistema muestra un resumen con registros creados, actualizados y rechazados, con sus motivos, y registra la operación.

### Flujos alternativos

#### A1. Importar facturas históricas

1. En el paso 1, el usuario indica que el archivo incluye facturas históricas.
2. El sistema las importa marcadas como "migradas", con su número y documento original, y sin enviar ninguna notificación al cliente.

#### A2. Cancelar antes de confirmar

1. En cualquier momento anterior al paso 7, el usuario cancela.
2. El sistema descarta la carga sin modificar datos.

#### A3. Filas sin identificador fiscal

1. En el paso 3, una fila no incluye identificador fiscal.
2. El sistema no puede comprobar duplicados en esa fila (CU-02, E1), la marca como "datos fiscales incompletos" en la previsualización (A-05) y permite importarla.
3. Esa fila no podrá facturarse hasta completar los datos (CU-12, E1).

### Flujos de excepción

#### E1. Archivo inválido

1. En el paso 2, el archivo no es un CSV válido o faltan columnas obligatorias.
2. El sistema rechaza la carga e indica qué falta.
3. El usuario corrige el archivo y vuelve a subirlo.

#### E2. Todas las filas rechazadas

1. En el paso 4, ninguna fila es válida.
2. El sistema no permite confirmar y muestra los motivos de rechazo.

#### E3. Fallo durante la importación

1. En el paso 8 se produce un error técnico.
2. El sistema revierte la operación completa para no dejar registros a medias, registra el error con identificador y lo muestra al usuario.
3. El usuario puede corregir la causa y volver a lanzar la importación.

### Postcondiciones

- Los clientes válidos quedan creados, y los marcados explícitamente como actualización quedan actualizados.
- La operación queda registrada con su resumen y el usuario que la realizó.
- Las facturas históricas importadas quedan marcadas como migradas y no generan notificaciones.

---

### CU-04 - Gestionar tareas del cliente

| Campo | Contenido |
|---|---|
| Identificador | CU-04 |
| Nombre | Gestionar tareas del cliente |
| Objetivo | Registrar y seguir tareas pendientes asociadas a un cliente, de modo que no se pierdan cuando cambie su responsable. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | Ninguna |
| Requisitos relacionados | FR-32, FR-43, FR-50, UR-12, NFR-07 |

### Precondiciones

- El usuario está autenticado.
- El cliente está asignado al usuario (o el usuario es Administrador o superior).

### Flujo principal (crear una tarea)

1. El Usuario operativo abre la ficha de un cliente asignado y accede a la sección de tareas.
2. El sistema muestra las tareas pendientes y completadas del cliente.
3. El usuario selecciona "Añadir tarea".
4. El usuario introduce la descripción de la tarea y, opcionalmente, una fecha prevista.
5. El sistema valida los datos.
6. El sistema guarda la tarea asociada al cliente (no al usuario) y la registra en la línea temporal del cliente.
7. El sistema muestra la tarea en la ficha y en la pantalla de trabajo diario del responsable interno del cliente (CU-29).

### Flujos alternativos

#### A1. Editar una tarea

1. En el paso 2, el usuario selecciona una tarea pendiente y la edita.
2. El sistema valida y guarda los cambios, y los registra en la línea temporal.

#### A2. Completar una tarea

1. En el paso 2, el usuario marca una tarea como completada.
2. El sistema la conserva como completada, registrando quién y cuándo, y la retira de la pantalla de trabajo diario.

#### A3. Cambio de responsable del cliente

1. Un Administrador cambia el responsable interno del cliente (CU-31).
2. Las tareas pendientes, al estar asociadas al cliente, pasan automáticamente a su nuevo responsable sin intervención del usuario.

### Flujos de excepción

#### E1. Datos inválidos

1. En el paso 5, la descripción está vacía o la fecha prevista no es válida.
2. El sistema no guarda e indica qué campo hay que corregir.
3. El usuario corrige y reenvía.

#### E2. Cliente no asignado

1. El usuario intenta acceder a las tareas de un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor).

#### E3. Tarea modificada por otro usuario

1. En A1 o A2, otro usuario ha modificado o completado la misma tarea mientras tanto.
2. El sistema avisa del conflicto, muestra el estado actual y no sobrescribe el cambio ajeno.

### Postcondiciones

- La tarea queda asociada al cliente con su estado (pendiente o completada).
- La línea temporal del cliente refleja la creación, edición o cierre.
- Las tareas pendientes son visibles para el responsable interno actual del cliente.

---

## Bloque B. Suscripciones, tarifas y descuentos

### CU-05 - Gestionar baja y pausa de suscripción

| Campo | Contenido |
|---|---|
| Identificador | CU-05 |
| Nombre | Gestionar baja y pausa de suscripción |
| Objetivo | Registrar la baja comercial de un cliente o la pausa de su suscripción, deteniendo la generación de nuevas mensualidades sin perder el seguimiento de las facturas pendientes. |
| Actor principal | Usuario operativo / Planificador del sistema |
| Actores secundarios | Ninguno |
| Relaciones | Ninguna |
| Requisitos relacionados | FR-09, FR-16, FR-43, FR-24, UR-12, BR-14, BR-15, BR-19, NFR-09 |

### Precondiciones

- El usuario está autenticado y el cliente está asignado al usuario (o el usuario es Administrador o superior).
- El cliente tiene una suscripción activa.

### Flujo principal (registrar la baja)

1. El Usuario operativo abre la ficha del cliente y selecciona "Registrar baja".
2. El sistema solicita la fecha de baja y el motivo, y muestra las facturas pendientes de cobro del cliente, si las hay.
3. El usuario introduce la fecha de baja y el motivo.
4. El sistema valida los datos y solicita confirmación, avisando de que dejarán de generarse mensualidades desde esa fecha.
5. El usuario confirma.
6. El sistema registra la baja, deja de generar mensualidades a partir de la fecha indicada y mantiene activo el flujo de recobro de las facturas pendientes (CU-20).
7. El sistema registra el evento en la línea temporal y confirma la operación.

### Flujos alternativos

#### A1. Pausar la suscripción

1. En el paso 1, el usuario selecciona "Pausar suscripción".
2. El usuario indica el motivo, la fecha de inicio y, si se conoce, la fecha prevista de reactivación.
3. El sistema registra la pausa: el cliente sigue activo, conserva sus facturas pendientes y no se generan mensualidades durante la pausa.

#### A2. Aviso de fecha prevista de reactivación

1. Llega la fecha prevista de reactivación de una pausa.
2. El Planificador del sistema lo detecta y el sistema avisa al responsable del cliente.
3. El responsable reactiva la suscripción o prorroga la pausa, y el sistema lo registra.

#### A3. Baja de un cliente con deuda pendiente

1. En el paso 2, el cliente tiene facturas pendientes de cobro.
2. La deuda no bloquea la baja comercial: el sistema permite continuar y las facturas pendientes siguen su flujo de recobro.

### Flujos de excepción

#### E1. Datos obligatorios o fecha no válida

1. En el paso 4, falta el motivo o la fecha no es válida.
2. El sistema no registra la operación e indica qué corregir.

#### E2. Suscripción no activa

1. El cliente ya está dado de baja, o la suscripción ya está pausada.
2. El sistema impide repetir la operación e informa del estado actual.

#### E3. Cliente no asignado

1. El usuario intenta operar sobre un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor).

### Postcondiciones

- La suscripción queda de baja o pausada, y no se generan nuevas mensualidades durante ese periodo.
- Las facturas pendientes se conservan y el recobro continúa en la baja; en la pausa el cliente sigue activo.
- Los datos del cliente y de las facturas emitidas se conservan.
- El evento queda en la línea temporal y en el registro de auditoría.

---

### CU-06 - Revisar y aprobar rango de tarifa anual

| Campo | Contenido |
|---|---|
| Identificador | CU-06 |
| Nombre | Revisar y aprobar rango de tarifa anual |
| Objetivo | Actualizar anualmente el plan de precios de un cliente en función de su facturación, con aprobación humana y trazabilidad del cambio. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | Usa la tabla de tarifas configurada en CU-35 |
| Requisitos relacionados | FR-10, FR-17, UR-13, BR-11, BR-12, NFR-09 |

### Precondiciones

- El usuario está autenticado con rol Administrador o superior.
- Existe una tabla de tarifas vigente (CU-35).

### Flujo principal

1. El Administrador abre la ficha del cliente y selecciona "Revisión anual de tarifa".
2. El sistema solicita la facturación anual verificada del cliente.
3. El Administrador introduce el importe.
4. El sistema propone el rango de tarifa que corresponde según la tabla vigente y muestra la tarifa actual junto a la propuesta.
5. El Administrador revisa la propuesta y la aprueba.
6. El sistema registra quién aprobó el cambio, cuándo, el precio anterior y el nuevo.
7. El sistema aplica la nueva tarifa solo a las facturas futuras y confirma la operación.

### Flujos alternativos

#### A1. Rechazar o mantener la tarifa actual

1. En el paso 5, el Administrador decide no aplicar el cambio propuesto e indica el motivo.
2. El sistema conserva la tarifa actual y registra la decisión.

#### A2. Mismo rango

1. En el paso 4, el rango propuesto coincide con el actual.
2. El sistema lo indica y no genera ningún cambio de precio.

### Flujos de excepción

#### E1. Facturación anual inválida

1. En el paso 3, el importe falta o no es válido.
2. El sistema no calcula la propuesta e indica qué corregir.

#### E2. El aprobador es quien solicitó el cambio

1. En el paso 5, el importe es sensible y el aprobador es la misma persona que preparó o solicitó el cambio.
2. El sistema impide la aprobación e indica que debe aprobarla otra persona.

#### E3. Sin rango aplicable

1. En el paso 4, la tabla de tarifas no tiene un rango para ese importe.
2. El sistema no propone cambio y avisa de que debe revisarse la tabla (CU-35).

### Postcondiciones

- La tarifa del cliente queda actualizada o sin cambios, con registro de quién la aprobó, cuándo, el precio anterior y el nuevo.
- Las facturas históricas ya emitidas no se modifican.

---

### CU-07 - Solicitar descuento

| Campo | Contenido |
|---|---|
| Identificador | CU-07 |
| Nombre | Solicitar descuento |
| Objetivo | Permitir que quien gestiona al cliente solicite un descuento o una excepción económica, que quedará pendiente de aprobación. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | La solicitud se resuelve en CU-08; puede escalarse mediante CU-09 |
| Requisitos relacionados | FR-13, FR-18, UR-12, BR-12, NFR-09 |

### Precondiciones

- El usuario está autenticado y el cliente está asignado al usuario (o el usuario es Administrador o superior).

### Flujo principal

1. El Usuario operativo abre la ficha del cliente y selecciona "Solicitar descuento".
2. El sistema muestra el formulario de solicitud.
3. El usuario indica el importe o porcentaje, el periodo de aplicación y el motivo.
4. El sistema valida los datos y comprueba si el descuento supera el umbral configurable.
5. El sistema crea la solicitud en estado "pendiente de aprobación", explicando el motivo por el que queda pendiente, y no la aplica.
6. El sistema notifica a los Administradores y confirma la solicitud al usuario.

### Flujos alternativos

#### A1. El descuento supera el umbral

1. En el paso 4, el descuento supera el umbral configurable.
2. El sistema indica que requerirá la aprobación del Superadministrador (CU-09).

#### A2. Solicitar una excepción comercial con efecto económico

1. Desde CU-01 (A4), el usuario solicita un primer mes gratuito o la facturación sin prorrateo.
2. La solicitud sigue este mismo flujo y la excepción no se aplica hasta su aprobación (A-10).

#### A3. Cancelar la solicitud

1. Mientras la solicitud está pendiente, el usuario la cancela.
2. El sistema la marca como cancelada y lo registra.

### Flujos de excepción

#### E1. Datos inválidos

1. En el paso 4, el importe o porcentaje no es válido o falta el motivo.
2. El sistema no crea la solicitud e indica qué corregir.

#### E2. Cliente no asignado

1. El usuario intenta solicitar un descuento para un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor).

### Postcondiciones

- La solicitud queda registrada como pendiente, con su solicitante, motivo e importe.
- El descuento no afecta a ninguna factura hasta ser aprobado.

---

### CU-08 - Aprobar descuento

| Campo | Contenido |
|---|---|
| Identificador | CU-08 |
| Nombre | Aprobar descuento |
| Objetivo | Revisar y resolver las solicitudes de descuento, con trazabilidad y separación entre quien solicita y quien aprueba. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | Extendido por CU-09 Escalar aprobación al Superadministrador (cuando el descuento supera el umbral configurable) |
| Requisitos relacionados | FR-18, FR-24, UR-13, BR-12, NFR-09 |

### Precondiciones

- Existe una solicitud de descuento pendiente (CU-07).
- El usuario está autenticado con rol Administrador o superior.

### Flujo principal

1. El Administrador accede a las aprobaciones pendientes desde su bandeja o su pantalla de trabajo diario.
2. El sistema las lista con cliente, importe, solicitante y motivo por el que están pendientes.
3. El Administrador abre una solicitud y revisa los datos.
4. El Administrador aprueba el descuento.
5. El sistema registra quién lo aprobó, cuándo y los valores aprobados, y deja el descuento disponible para la facturación futura.
6. El sistema notifica al solicitante y confirma la operación.

### Flujos alternativos

#### A1. Rechazar la solicitud

1. En el paso 4, el Administrador rechaza la solicitud e indica el motivo.
2. El sistema la marca como rechazada, lo registra y notifica al solicitante.

#### A2. El descuento supera el umbral

1. En el paso 3, el descuento supera el umbral configurable.
2. El sistema impide que el Administrador la resuelva y la deriva al Superadministrador (CU-09).

### Flujos de excepción

#### E1. El aprobador es el solicitante

1. En el paso 4, el aprobador es quien solicitó el descuento.
2. El sistema impide la aprobación e indica que debe resolverla otra persona.

#### E2. Solicitud ya resuelta

1. Otro aprobador ha resuelto la solicitud mientras tanto.
2. El sistema informa del resultado y no permite resolverla de nuevo.

### Postcondiciones

- La solicitud queda aprobada o rechazada, con registro de quién, cuándo y por qué.
- Un descuento aprobado puede aplicarse en la facturación futura; no altera facturas ya emitidas.

---

### CU-09 - Escalar aprobación al Superadministrador

| Campo | Contenido |
|---|---|
| Identificador | CU-09 |
| Nombre | Escalar aprobación al Superadministrador |
| Objetivo | Resolver las solicitudes de descuento que superan el umbral configurable, que solo puede aprobar el Superadministrador. |
| Actor principal | Superadministrador |
| Actores secundarios | Ninguno |
| Relaciones | `<<extend>>` CU-08 Aprobar descuento (el descuento supera el umbral configurable) |
| Requisitos relacionados | FR-18, FR-24, UR-13, BR-12, NFR-09 |

### Precondiciones

- Existe una solicitud de descuento pendiente que supera el umbral configurable.
- El usuario está autenticado como Superadministrador.

### Flujo principal

1. El sistema deriva la solicitud al Superadministrador y le notifica que tiene una aprobación pendiente.
2. El Superadministrador abre la solicitud.
3. El sistema muestra el cliente, el importe, el solicitante y el motivo por el que requiere su aprobación.
4. El Superadministrador aprueba el descuento.
5. El sistema registra quién lo aprobó, cuándo y los valores aprobados.
6. El sistema notifica al solicitante y al Administrador, y confirma la operación.

### Flujos alternativos

#### A1. Rechazar la solicitud

1. En el paso 4, el Superadministrador rechaza la solicitud e indica el motivo.
2. El sistema la marca como rechazada, lo registra y notifica.

### Flujos de excepción

#### E1. El Superadministrador es el solicitante

1. En el paso 4, el Superadministrador es quien solicitó el descuento.
2. El sistema impide la aprobación e indica que debe resolverla otra persona.

#### E2. Solicitud ya resuelta

1. La solicitud ya fue resuelta mientras tanto.
2. El sistema informa del resultado y no permite resolverla de nuevo.

### Postcondiciones

- La solicitud queda aprobada o rechazada por el Superadministrador, con registro de quién, cuándo y por qué.
- El descuento aprobado puede aplicarse en la facturación futura.

---

## Bloque C. Facturación

### CU-10 - Gestionar borrador de factura

| Campo | Contenido |
|---|---|
| Identificador | CU-10 |
| Nombre | Gestionar borrador de factura |
| Objetivo | Preparar, modificar o eliminar una factura antes de emitirla, con sus líneas, impuestos y totales correctos. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | El borrador se emite en CU-12 |
| Requisitos relacionados | FR-01, FR-02, FR-13, FR-14, FR-19, FR-30, UR-05, BR-09, BR-24, NFR-06, NFR-13 |

### Precondiciones

- El usuario está autenticado y tiene permiso para preparar facturas.
- El cliente está asignado al usuario (o el usuario es Administrador o superior).

### Flujo principal (crear un borrador de factura puntual)

1. El Usuario operativo selecciona "Nueva factura" para un cliente.
2. El sistema muestra el formulario autocompletando los campos recurrentes (moneda, vencimiento, impuestos).
3. El usuario añade una o varias líneas con concepto, cantidad, precio unitario, descuento (si aplica) e impuesto.
4. El sistema calcula los importes y el IVA con precisión decimal y muestra los totales en la moneda del cliente.
5. El usuario guarda el borrador.
6. El sistema guarda la factura en estado "borrador", sin número, y confirma la operación.

### Flujos alternativos

#### A1. Editar un borrador existente

1. El usuario abre un borrador y modifica sus líneas o datos.
2. El sistema recalcula los totales y guarda los cambios.

#### A2. Eliminar un borrador

1. El usuario elimina un borrador que nunca ha sido emitido.
2. El sistema lo elimina, ya que los borradores nunca emitidos pueden eliminarse, y lo registra.

#### A3. Cambio sensible en el borrador

1. En los pasos 3 o 5, la factura incluye un importe modificado manualmente, un descuento extraordinario, un vencimiento fuera de lo habitual o es una factura puntual de importe muy alto.
2. El sistema marca el borrador con cambio sensible e informa de que quedará retenida al emitirse (CU-12, A1).

#### A4. Borrador de factura recurrente

1. En el paso 1, el usuario indica que la factura es recurrente.
2. El sistema la prepara con las líneas de la suscripción del cliente y continúa en el paso 4.

### Flujos de excepción

#### E1. Datos inválidos

1. En el paso 5, hay líneas sin concepto, cantidades o precios no válidos o falta un dato obligatorio.
2. El sistema no guarda e indica qué campos corregir.

#### E2. Factura ya emitida

1. El usuario intenta modificar o eliminar una factura que ya fue emitida.
2. El sistema bloquea la edición ordinaria e indica que cualquier corrección requiere una factura rectificativa (CU-14).

#### E3. Edición simultánea

1. Otro usuario modifica el mismo borrador al mismo tiempo.
2. El sistema avisa del conflicto y no sobrescribe el cambio ajeno.

### Postcondiciones

- El borrador queda guardado con sus líneas, impuestos y totales, sin número de factura.
- Un borrador con cambio sensible queda marcado para retención al emitirse.
- Un borrador eliminado deja de existir; las facturas emitidas no se alteran.

---

### CU-11 - Generar facturas recurrentes

| Campo | Contenido |
|---|---|
| Identificador | CU-11 |
| Nombre | Generar facturas recurrentes |
| Objetivo | Generar y emitir automáticamente cada mes la factura de las suscripciones activas de cada cliente, con las tarifas, el prorrateo y los descuentos aprobados aplicables. |
| Actor principal | Planificador del sistema |
| Actores secundarios | Proveedor de correo (a través de CU-12 → CU-18) |
| Relaciones | `<<include>>` CU-12 Emitir factura (extendido por CU-13 Aprobar factura retenida cuando hay cambios sensibles) |
| Requisitos relacionados | FR-01, FR-02, FR-09, FR-11, FR-13, FR-16, FR-18, FR-20, FR-24, FR-47, FR-48, BR-02, BR-10, BR-12, BR-14, BR-15, BR-16, BR-17, BR-18, BR-24, NFR-06, NFR-15 |

### Precondiciones

- Es el día 1 del mes (o se relanza una ejecución interrumpida, ver E2).
- Existen clientes con suscripciones activas.

### Flujo principal

1. El Planificador del sistema inicia la ejecución de facturación recurrente.
2. El sistema selecciona los clientes con suscripciones activas, excluyendo las suscripciones pausadas, los clientes dados de baja y los clientes pendientes de activación.
3. Para cada cliente, el sistema calcula las líneas de factura con la tarifa acordada, aplicando el prorrateo si el alta fue a mitad de mes y los descuentos aprobados vigentes.
4. El sistema crea la factura (borrador) en la moneda del cliente, con el vencimiento pactado si existe (prevalece sobre el general).
5. Como la factura procede exactamente de una suscripción aprobada, se emite sin aprobación adicional (CU-12).
6. El sistema registra el resultado de la ejecución para el panel de monitorización.

### Flujos alternativos

#### A1. Alta a mitad de mes

1. En el paso 3, el sistema aplica la regla de prorrateo única y documentada, también en casos límite (alta el último día del mes).

#### A2. Factura con cambio sensible

1. En el paso 5, la factura no procede exactamente de una suscripción aprobada: lleva un importe modificado manualmente, un descuento extraordinario o un vencimiento fuera de lo habitual.
2. El sistema la deja retenida y explica el motivo (CU-13 extiende CU-12). Se emitirá tras la aprobación de un Administrador.
3. El proceso continúa con el resto de clientes.

#### A3. Cliente con excepción comercial

1. En el paso 3, el cliente tiene una excepción comercial registrada explícitamente en su ficha (CU-01, A4).
2. El sistema la aplica solo si está aprobada (A-10): con "primer mes gratuito" la primera mensualidad no se cobra; con "sin prorrateo" se factura la mensualidad completa.

### Flujos de excepción

#### E1. Faltan datos fiscales de un cliente

1. En el paso 4, a un cliente le falta un dato fiscal imprescindible.
2. El sistema omite la factura de ese cliente, registra la incidencia e indica qué falta, y notifica al responsable del cliente.
3. El proceso continúa con el resto de clientes.

#### E2. Interrupción o reejecución

1. La ejecución se interrumpe o se lanza de nuevo.
2. El sistema recupera el proceso sin duplicar facturas ni consumir numeración: no genera una segunda factura para el mismo cliente y periodo.

### Postcondiciones

- Cada cliente facturable tiene una única factura del periodo: emitida y con número correlativo dentro de su serie, o retenida pendiente de aprobación (la numeración se asigna al emitirla, CU-12).
- Los clientes con errores quedan señalados para su revisión.
- La ejecución queda registrada para monitorización.

---

### CU-12 - Emitir factura

| Campo | Contenido |
|---|---|
| Identificador | CU-12 |
| Nombre | Emitir factura |
| Objetivo | Convertir un borrador de factura en una factura emitida, con numeración y PDF, y enviarla al cliente. |
| Actor principal | Usuario operativo (según su permiso) |
| Actores secundarios | Proveedor de correo |
| Relaciones | Incluido por CU-11; `<<include>>` CU-18 Enviar comunicación al cliente; extendido por CU-13 Aprobar factura retenida |
| Requisitos relacionados | FR-01, FR-12, FR-13, FR-14, FR-18, FR-19, FR-20, FR-23, FR-24, FR-46, BR-09, BR-10, BR-12, UR-10, NFR-13 |

### Precondiciones

- Existe una factura en estado "borrador" o "aprobada".
- El usuario tiene permiso para emitir facturas.

### Flujo principal

1. El Usuario operativo selecciona la factura y elige "Emitir".
2. El sistema muestra la vista previa de la factura.
3. El sistema verifica que no faltan datos fiscales imprescindibles.
4. El Usuario operativo confirma la emisión.
5. El sistema asigna el siguiente número correlativo de la serie y genera el PDF, que guarda en la base de datos.
6. El sistema cambia el estado a "emitida" y bloquea su edición ordinaria.
7. El sistema envía la factura por correo al contacto de facturación (CU-18) y registra canal, intento, resultado, fecha y destinatario.
8. El sistema cambia el estado a "enviada" y confirma al usuario.

### Flujos alternativos

#### A1. Factura retenida para revisión

1. Al confirmar en el paso 4, la factura tiene un cambio sensible (importe manual, descuento extraordinario, vencimiento atípico o factura puntual de importe muy alto).
2. El sistema la retiene, explica el motivo y avisa a los Administradores (CU-13).
3. Tras la aprobación, la factura pasa a "aprobada" y el flujo continúa en el paso 5. En importes sensibles, el aprobador no puede ser quien preparó o solicitó el cambio.

#### A2. Emisión automática desde la facturación recurrente

1. CU-11 invoca la emisión de una factura generada exactamente desde una suscripción aprobada.
2. El flujo se ejecuta sin intervención del usuario: omite la vista previa y la confirmación (pasos 2 y 4), mantiene la comprobación de datos fiscales del paso 3 (su fallo se trata como en CU-11, E1) y continúa en el paso 5.

#### A3. Envío adicional por WhatsApp

1. En el paso 7, el contacto de facturación ha dado su consentimiento para WhatsApp.
2. El sistema envía además la factura por WhatsApp (de forma simulada) y registra canal, intento, resultado, fecha y destinatario.
3. Un fallo en este canal no afecta al envío por correo ni deshace la emisión.

### Flujos de excepción

#### E1. Faltan datos fiscales

1. En el paso 3, falta un dato fiscal imprescindible.
2. El sistema bloquea la emisión e indica qué falta.
3. El usuario completa los datos y reintenta.

#### E2. Fallo en el envío

1. En el paso 7, el envío falla.
2. La emisión no se deshace: la factura sigue emitida con su número.
3. El sistema registra el fallo y la factura permanece "emitida" (no "enviada") hasta que el envío se complete.
4. El reintento de envío, manual o automático, no crea otra factura ni otro número.

#### E3. Correo rebotado

1. En el paso 7, el proveedor de correo informa de un rebote.
2. El sistema registra el resultado "rebotado" en el envío, no marca la factura como notificada y se gestiona mediante CU-19 (que extiende CU-18).

#### E4. Emisión concurrente

1. Entre los pasos 4 y 5, otro usuario emite la misma factura al mismo tiempo.
2. El sistema impide la duplicación y la numeración doble, e informa de que ya fue emitida.

### Postcondiciones

- La factura queda emitida, numerada, con PDF y sin posibilidad de edición ordinaria (cualquier corrección exige rectificativa).
- El envío queda registrado con su resultado.
- El saldo pendiente del cliente refleja la nueva factura.

---

### CU-13 - Aprobar factura retenida

| Campo | Contenido |
|---|---|
| Identificador | CU-13 |
| Nombre | Aprobar factura retenida |
| Objetivo | Revisar las facturas retenidas por un cambio sensible y decidir si pueden emitirse. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | `<<extend>>` CU-12 Emitir factura (la factura tiene un cambio sensible: importe manual, descuento extraordinario, vencimiento atípico o puntual de importe alto) |
| Requisitos relacionados | FR-13, FR-18, FR-19, FR-24, UR-13, BR-12, NFR-09 |

### Precondiciones

- Existe una factura retenida (CU-12, A1 o CU-11, A2) con el motivo de la retención.
- El usuario está autenticado con rol Administrador o superior.

### Flujo principal

1. El Administrador accede a las aprobaciones pendientes desde su bandeja o su pantalla de trabajo diario.
2. El sistema lista las facturas retenidas con cliente, importe, preparador y motivo de la retención.
3. El Administrador abre una factura y revisa el cambio sensible y la vista previa.
4. El Administrador aprueba la factura.
5. El sistema registra quién la aprobó y cuándo, y cambia su estado a "aprobada".
6. El sistema retoma la emisión (CU-12, desde el paso 5) y notifica al preparador.

### Flujos alternativos

#### A1. Rechazar la factura

1. En el paso 4, el Administrador rechaza la factura e indica el motivo.
2. El sistema devuelve la factura a "borrador", registra la decisión y notifica al preparador, que puede corregirla (CU-10).

### Flujos de excepción

#### E1. El aprobador es quien preparó el cambio

1. En el paso 4, el importe es sensible y el aprobador es quien preparó o solicitó el cambio.
2. El sistema impide la aprobación e indica que debe aprobarla otra persona.

#### E2. Factura ya resuelta

1. Otro Administrador ha resuelto la factura mientras tanto.
2. El sistema informa del resultado y no permite resolverla de nuevo.

#### E3. Faltan datos fiscales

1. Tras la aprobación, falta un dato fiscal imprescindible.
2. La emisión queda bloqueada según CU-12 (E1) hasta completar los datos.

### Postcondiciones

- La factura queda "aprobada" y se emite, o vuelve a "borrador" si se rechaza.
- Queda registrado quién decidió, cuándo y por qué.

---

### CU-14 - Rectificar, anular o declarar incobrable una factura

| Campo | Contenido |
|---|---|
| Identificador | CU-14 |
| Nombre | Rectificar, anular o declarar incobrable una factura |
| Objetivo | Corregir o cancelar una factura ya emitida sin modificarla, mediante rectificativa vinculada, anulación o declaración de incobrable, con aprobación y motivo. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | Ninguna |
| Requisitos relacionados | FR-14, FR-19, FR-45, FR-46, UR-13, BR-09, BR-12, BR-13, NFR-09 |

### Precondiciones

- Existe una factura emitida.
- El usuario está autenticado con rol Administrador o superior.

### Flujo principal (factura rectificativa)

1. El Administrador abre una factura emitida y selecciona "Rectificar".
2. El sistema propone los datos que se rectifican y mantiene el vínculo con la factura original.
3. El Administrador ajusta los datos e indica el motivo.
4. El sistema comprueba si, según el importe, requiere aprobación; en este caso no la requiere.
5. El sistema asigna el siguiente número correlativo, genera el PDF de la rectificativa y la guarda.
6. El sistema cambia el estado de la factura original a "rectificada" y la envía al contacto de facturación igual que en la emisión ordinaria (CU-12).
7. El sistema registra la operación y confirma al Administrador.

### Flujos alternativos

#### A1. La rectificativa requiere aprobación

1. En el paso 4, el importe exige aprobación.
2. El sistema deja la rectificativa pendiente, explica el motivo y avisa al aprobador. La aprobación la resuelve otra persona distinta de quien la solicitó (BR-12) y la emisión continúa en el paso 5.

#### A2. Anular la factura

1. En el paso 1, el Administrador selecciona "Anular" e indica el motivo.
2. Si legalmente procede, el sistema pide la aprobación que corresponda y cambia el estado a "anulada", conservando la factura y su número.

#### A3. Declarar la deuda incobrable

1. En el paso 1, el Administrador selecciona "Declarar incobrable" e indica el motivo.
2. Tras la aprobación correspondiente, el sistema marca la deuda como incobrable sin considerarla pagada y detiene los recordatorios de esa factura (A-12).

### Flujos de excepción

#### E1. Factura no emitida

1. El usuario intenta rectificar o anular una factura en estado "borrador".
2. El sistema informa de que no procede y de que el borrador puede editarse o eliminarse (CU-10).

#### E2. Anulación no procedente

1. En A2, la anulación no procede legalmente.
2. El sistema la impide y ofrece generar una rectificativa.

#### E3. Falta el motivo o la aprobación

1. En cualquier flujo, falta el motivo o la aprobación requerida, o el aprobador es quien lo solicitó.
2. El sistema no ejecuta la operación e indica qué falta.

#### E4. Factura ya rectificada o anulada

1. La factura ya está en estado "rectificada" o "anulada".
2. El sistema impide repetir la operación e informa del estado.

### Postcondiciones

- La factura original no se modifica ni se borra; queda "rectificada", "anulada" o marcada como incobrable, con su motivo y aprobación.
- Una rectificativa queda emitida, numerada y vinculada a la original.
- Una deuda declarada incobrable, anulada o rectificada nunca pasa a "pagada".
- La operación queda registrada en el registro de auditoría.

---

### CU-15 - Buscar y consultar facturas y clientes

| Campo | Contenido |
|---|---|
| Identificador | CU-15 |
| Nombre | Buscar y consultar facturas y clientes |
| Objetivo | Localizar rápidamente clientes y facturas y consultar su información, incluida la descarga del PDF. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | Ninguna |
| Requisitos relacionados | FR-12, FR-19, FR-28, FR-44, UR-02, UR-03, UR-07, NFR-07, NFR-12 |

### Precondiciones

- El usuario está autenticado.

### Flujo principal

1. El Usuario operativo introduce un término en el buscador.
2. El sistema busca por nombre comercial, razón social, NIF, persona de contacto, número de factura y correo, limitándose a lo que el usuario tiene permiso para ver.
3. El sistema muestra los resultados agrupados por clientes y facturas.
4. El usuario aplica filtros (estado de la factura, empresa, fecha, sector).
5. El sistema actualiza los resultados.
6. El usuario abre una factura o la ficha de un cliente y el sistema muestra su información básica.

### Flujos alternativos

#### A1. Guardar un filtro

1. En el paso 4, el usuario guarda la combinación de filtros.
2. El sistema la conserva para usarla de nuevo.

#### A2. Acceder por favoritos

1. En el paso 1, el usuario accede a la ficha de un cliente desde sus favoritos.
2. El sistema comprueba igualmente los permisos antes de mostrarla.

#### A3. Descargar el PDF de una factura

1. En el paso 6, el usuario selecciona "Descargar PDF" en una factura emitida.
2. El sistema entrega el PDF guardado, sin regenerarlo.

### Flujos de excepción

#### E1. Sin resultados

1. En el paso 3, no hay coincidencias.
2. El sistema lo indica y sugiere revisar el término o los filtros.

#### E2. Recurso no permitido

1. En el paso 6, el usuario intenta abrir un cliente o factura que no tiene permiso para ver.
2. El sistema rechaza el acceso (el control se realiza en servidor).

### Postcondiciones

- El usuario ha localizado y consultado la información que necesitaba, dentro de sus permisos.
- La consulta no modifica ningún dato.

---

## Bloque D. Cobros y comunicaciones

### CU-16 - Registrar movimiento de cobro

| Campo | Contenido |
|---|---|
| Identificador | CU-16 |
| Nombre | Registrar movimiento de cobro |
| Objetivo | Incorporar al sistema los cobros recibidos a través del sistema de pagos para poder determinar si una factura ha sido pagada. |
| Actor principal | Sistema de pagos (Stripe/Revolut) |
| Actores secundarios | Planificador del sistema (consulta periódica) |
| Relaciones | `<<include>>` CU-17 Conciliar pagos |
| Requisitos relacionados | FR-15, FR-21, FR-24, FR-48, FR-50, BR-06, BR-13, UR-14, NFR-09 |

> Alcance: el sistema no gestiona los pagos en sí, solo registra y concilia los movimientos que se reflejan en el sistema de pagos. Las notificaciones de pago pueden ser simuladas (FR-15).

### Precondiciones

- La integración con el sistema de pagos está configurada.

### Flujo principal

1. El Sistema de pagos notifica un cobro (o el Planificador lo obtiene en la consulta periódica).
2. El sistema comprueba que el evento no está duplicado.
3. El sistema registra el movimiento con importe, fecha, moneda, concepto y referencia.
4. El sistema busca la factura a partir de la referencia del pago.
5. Si la coincidencia es clara, el sistema concilia el pago con la factura mediante conciliación automática (CU-17, A1).
6. El sistema registra el resultado de la operación.

### Flujos alternativos

#### A1. Consulta periódica de pagos

1. En el paso 1, el Planificador consulta al sistema de pagos los movimientos nuevos y se continúa en el paso 2.

#### A2. Cobro sin referencia clara

1. En el paso 4, no hay coincidencia clara o hay varias posibles.
2. El sistema deja el movimiento pendiente de conciliación manual, lo asigna al responsable del cliente (o a una persona designada) y lo muestra en su pantalla de trabajo diario. La conciliación se completará después, de forma manual, en CU-17.

### Flujos de excepción

#### E1. Evento duplicado

1. En el paso 2, el sistema detecta que el evento ya fue registrado.
2. Lo descarta sin contabilizarlo dos veces.

#### E2. Fallo de la integración

1. El sistema de pagos no responde o devuelve un error.
2. El sistema registra el error de integración, que se muestra en el panel de monitorización, y reintenta en la siguiente ejecución.

### Postcondiciones

- El movimiento queda registrado de forma inmutable.
- El movimiento está conciliado con una factura o pendiente de conciliación manual.

---

### CU-17 - Conciliar pagos

| Campo | Contenido |
|---|---|
| Identificador | CU-17 |
| Nombre | Conciliar pagos |
| Objetivo | Asociar los movimientos de cobro con las facturas pendientes y actualizar su estado de pago. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | Incluido por CU-16 |
| Requisitos relacionados | FR-15, FR-19, FR-21, FR-22, FR-24, FR-50, BR-13, UR-14, NFR-09 |

### Precondiciones

- Existe un movimiento de cobro registrado sin conciliar, o una conciliación automática que debe revisarse.
- Existe al menos una factura emitida pendiente de cobro del cliente.
- El cliente está asignado al usuario (o el usuario es Administrador o superior).

### Flujo principal

1. El Usuario operativo accede a los movimientos pendientes de conciliación (por ejemplo, desde su pantalla de trabajo diario).
2. El sistema los muestra con su importe, fecha, concepto y referencia.
3. El usuario selecciona un movimiento y busca al cliente o la factura.
4. El usuario asocia el movimiento a la factura (o a varias).
5. El sistema valida los importes.
6. El sistema actualiza el estado de cada factura: "pagada" si queda saldada, "parcialmente conciliada" si el importe es menor.
7. El sistema registra quién realizó la conciliación y confirma la operación.

### Flujos alternativos

#### A1. Conciliación automática

1. Cuando CU-16 encuentra una coincidencia clara, el sistema concilia sin intervención, registra la regla aplicada y actualiza el estado de la factura como en el paso 6.

#### A2. Un cobro para varias facturas

1. En el paso 4, el usuario reparte el importe entre varias facturas del cliente.
2. El sistema valida que la suma coincide con el movimiento y continúa en el paso 6.

#### A3. Deshacer una conciliación

1. Tras el paso 7, el usuario revierte una conciliación errónea (manual o automática), indicando el motivo.
2. El sistema no borra el evento: registra quién o qué regla la hizo, quién la revirtió, cuándo y por qué, y restaura el estado de la factura.

### Flujos de excepción

#### E1. Importe superior al adeudado

1. En el paso 5, el importe supera el total pendiente.
2. El sistema no marca la factura como pagada, señala la diferencia y avisa para su revisión.
3. El usuario corrige la asociación o deja la diferencia pendiente de revisión.

#### E2. Movimiento ya conciliado

1. En el paso 3, el movimiento seleccionado ya está asociado a una factura.
2. El sistema impide asociarlo de nuevo.

### Postcondiciones

- La factura queda "pagada" o "parcialmente conciliada" con el rastro de quién y cuándo lo hizo.
- Las diferencias de importe quedan señaladas para su revisión.
- Los movimientos y las reversiones quedan registrados de forma inmutable.

---

### CU-18 - Enviar comunicación al cliente

| Campo | Contenido |
|---|---|
| Identificador | CU-18 |
| Nombre | Enviar comunicación al cliente |
| Objetivo | Entregar al cliente, por correo, facturas y recordatorios mediante plantillas, registrando cada intento y su resultado. |
| Actor principal | Proveedor de correo |
| Actores secundarios | Ninguno |
| Relaciones | Incluido por CU-12 y CU-20; extendido por CU-19 Gestionar rebote de correo |
| Requisitos relacionados | FR-23, FR-26, FR-46, FR-48, BR-06, BR-20, BR-21, NFR-17 |

### Precondiciones

- Un caso de uso (CU-12 o CU-20) solicita la comunicación indicando cliente, tipo de comunicación y, si procede, la factura.
- El cliente tiene un contacto del tipo adecuado (facturación o impagos) con correo válido.

### Flujo principal

1. El sistema recibe la solicitud de comunicación (factura, recordatorio previo, recordatorio de vencimiento, aviso de impago o disputa resuelta).
2. El sistema selecciona la plantilla del tipo de comunicación en el idioma correspondiente.
3. El sistema completa las variables dinámicas (nombre de la empresa, número de factura, importe, responsable) y adjunta el PDF cuando se trata de una factura.
4. El sistema entrega el mensaje al Proveedor de correo.
5. El Proveedor de correo confirma la entrega.
6. El sistema registra canal, intento, resultado, fecha, destinatario y plantilla utilizada.
7. El sistema devuelve el resultado al caso de uso que lo solicitó.

### Flujos alternativos

#### A1. Reenvío de una comunicación

1. Un usuario solicita reenviar una comunicación ya enviada (por ejemplo, tras corregir un contacto en CU-19).
2. El sistema repite los pasos 2 a 6 sin generar un nuevo documento ni una nueva numeración, y registra el nuevo intento.

#### A2. Canal adicional simulado

1. El contacto ha dado su consentimiento para WhatsApp.
2. El sistema envía además la comunicación por WhatsApp de forma simulada y registra el intento, sin que un fallo en ese canal afecte al correo.

### Flujos de excepción

#### E1. Correo rebotado

1. En el paso 5, el Proveedor de correo informa de un rebote.
2. El sistema registra el resultado como "rebotado" y continúa con CU-19.

#### E2. Proveedor no disponible

1. En el paso 4, el Proveedor de correo no responde o devuelve un error.
2. El sistema mantiene el mensaje en la cola de correos pendientes, registra el error de integración visible en monitorización (CU-33) y reintenta el envío.

#### E3. Falta destinatario o dato de la plantilla

1. En los pasos 2 o 3, el contacto no tiene correo o falta un dato de una variable obligatoria.
2. El sistema no envía la comunicación, registra el fallo y avisa al responsable del cliente.

### Postcondiciones

- La comunicación queda enviada, en cola o fallida, con su registro de canal, intento, resultado, fecha, destinatario y plantilla.
- Los comentarios internos nunca se incluyen en comunicaciones al cliente.
- No se envían comunicaciones comerciales fuera de las facturas y los recordatorios.

---

### CU-19 - Gestionar rebote de correo

| Campo | Contenido |
|---|---|
| Identificador | CU-19 |
| Nombre | Gestionar rebote de correo |
| Objetivo | Resolver un envío rebotado corrigiendo el contacto y reenviando la comunicación hasta que se entregue. |
| Actor principal | Usuario operativo / Proveedor de correo |
| Actores secundarios | Ninguno |
| Relaciones | `<<extend>>` CU-18 (el correo rebota); `<<include>>` CU-25 Gestionar incidencias y comentarios |
| Requisitos relacionados | FR-04, FR-23, FR-24, FR-34, UR-14, BR-03 |

### Precondiciones

- Una comunicación enviada por CU-18 ha rebotado.

### Flujo principal

1. El Proveedor de correo informa del rebote de una comunicación.
2. El sistema registra el resultado "rebotado" y mantiene la comunicación como no entregada.
3. El sistema crea una incidencia de entrega (CU-25) y avisa al responsable del cliente.
4. El Usuario operativo abre la incidencia y consulta el destinatario y el motivo del rebote.
5. El usuario corrige el contacto o selecciona otro contacto del cliente (CU-01, A2).
6. El usuario solicita reenviar la comunicación.
7. El sistema reenvía la comunicación (CU-18, A1) con el mismo documento y registra el nuevo intento.
8. El Proveedor de correo confirma la entrega y el sistema marca la comunicación como entregada y la incidencia como resuelta.

### Flujos alternativos

#### A1. El reenvío vuelve a rebotar

1. En el paso 8, el Proveedor de correo informa de un nuevo rebote.
2. El sistema registra el intento, mantiene abierta la incidencia y avisa de nuevo al responsable.

#### A2. Cerrar la incidencia sin reenviar

1. En el paso 4, el usuario gestiona el contacto por otra vía.
2. El usuario cierra la incidencia con un comentario y el sistema lo registra.

### Flujos de excepción

#### E1. Sin contacto alternativo válido

1. En el paso 5, el cliente no tiene ningún contacto con correo válido.
2. La incidencia permanece abierta y el sistema muestra el cliente como "contacto pendiente de corregir".

#### E2. Cliente no asignado

1. El usuario intenta gestionar la incidencia de un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor).

### Postcondiciones

- La comunicación queda entregada o la incidencia continúa abierta con su historial de intentos.
- Los contactos corregidos quedan registrados en la línea temporal del cliente.

---

### CU-20 - Ejecutar flujo de recordatorios e impago

| Campo | Contenido |
|---|---|
| Identificador | CU-20 |
| Nombre | Ejecutar flujo de recordatorios e impago |
| Objetivo | Avisar automáticamente al cliente antes y después del vencimiento de una factura hasta que se detecte el pago o intervenga una persona. |
| Actor principal | Planificador del sistema |
| Actores secundarios | Proveedor de correo (a través de CU-18) |
| Relaciones | `<<include>>` CU-18 Enviar comunicación al cliente; extendido por CU-21 Suspender recordatorios de una factura |
| Requisitos relacionados | FR-05, FR-26, FR-48, BR-03, BR-14, BR-15, BR-16, NFR-15 |

### Precondiciones

- Existen facturas emitidas pendientes de cobro.
- Los plazos y la cadencia de recordatorios están configurados (CU-36).

### Flujo principal

1. El Planificador del sistema inicia la ejecución diaria.
2. El sistema selecciona las facturas emitidas pendientes de cobro, excluyendo las pagadas, anuladas o con recordatorios suspendidos.
3. El sistema determina, para cada factura, el recordatorio que corresponde según su vencimiento, dando prioridad al vencimiento pactado sobre el general.
4. El sistema comprueba que no se ha detectado un pago desde la última ejecución.
5. El sistema solicita el envío de la comunicación correspondiente (recordatorio previo, de vencimiento o aviso de impago) mediante CU-18.
6. El sistema registra cada aviso en la factura y en la línea temporal del cliente.
7. El sistema registra el resultado de la ejecución en la monitorización (CU-33).

### Flujos alternativos

#### A1. Factura de un cliente dado de baja

1. En el paso 2, la factura pertenece a un cliente dado de baja.
2. El sistema la incluye igualmente: el recobro de la deuda continúa tras la baja.

#### A2. Pago detectado

1. En el paso 4, se ha detectado el pago de la factura (CU-16).
2. El sistema no envía el aviso y detiene el flujo de esa factura.

#### A3. Recordatorios suspendidos

1. En el paso 2, la factura tiene los recordatorios suspendidos (CU-21).
2. El sistema la omite hasta que se reanuden.

### Flujos de excepción

#### E1. Fallo o rebote del envío

1. En el paso 5, CU-18 informa de un fallo o de un rebote.
2. El sistema registra el resultado, gestiona la incidencia (CU-19) y continúa con las demás facturas.

#### E2. Ejecución interrumpida

1. La ejecución se interrumpe antes de terminar.
2. Al reanudarse, el sistema completa los avisos pendientes sin enviar dos veces el mismo aviso y registra el error en monitorización.

#### E3. Falta contacto de impagos

1. En el paso 5, el cliente no tiene contacto del tipo adecuado.
2. El sistema no envía el aviso, crea una incidencia y avisa al responsable del cliente.

### Postcondiciones

- Cada factura pendiente ha recibido a lo sumo un aviso por fase, registrado con su resultado.
- El flujo de una factura se detiene al detectarse el pago, al suspenderse o al intervenir una persona.
- El resultado de la ejecución queda disponible en la monitorización.

---

### CU-21 - Suspender recordatorios de una factura

| Campo | Contenido |
|---|---|
| Identificador | CU-21 |
| Nombre | Suspender recordatorios de una factura |
| Objetivo | Pausar los recordatorios automáticos de una factura concreta mientras existe una disputa o un seguimiento humano. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | `<<extend>>` CU-20 (una factura concreta tiene los recordatorios suspendidos) |
| Requisitos relacionados | FR-05, FR-24, FR-26, UR-14, BR-03, NFR-09 |

### Precondiciones

- La factura está emitida y pendiente de cobro.
- El cliente está asignado al usuario (o el usuario es Administrador o superior).

### Flujo principal

1. El Usuario operativo abre la factura y selecciona "Suspender recordatorios".
2. El sistema solicita el motivo y una fecha de revisión.
3. El usuario los introduce.
4. El sistema valida los datos y guarda la suspensión.
5. El sistema registra la acción en la línea temporal y confirma la operación.

### Flujos alternativos

#### A1. Reanudar los recordatorios

1. El usuario selecciona "Reanudar recordatorios" antes de la fecha de revisión.
2. El sistema levanta la suspensión y CU-20 vuelve a incluir la factura.

#### A2. Llega la fecha de revisión

1. Llega la fecha de revisión de la suspensión.
2. El sistema avisa al responsable del cliente; la suspensión se mantiene hasta que se reanude o se prorrogue (A-13).

#### A3. Disputa resuelta

1. En A1, el motivo de la suspensión era una disputa.
2. El sistema ofrece enviar al cliente la comunicación de "disputa resuelta" (CU-18) y, si el usuario la acepta, la envía.

### Flujos de excepción

#### E1. Datos inválidos

1. En el paso 4, falta el motivo o la fecha de revisión no es futura.
2. El sistema no guarda e indica qué corregir.

#### E2. Factura no pendiente

1. La factura ya está pagada, anulada o no ha sido emitida.
2. El sistema impide la suspensión e informa del estado actual.

#### E3. Cliente no asignado

1. El usuario intenta suspender recordatorios de un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor).

### Postcondiciones

- La factura queda con los recordatorios suspendidos, con su motivo y fecha de revisión, o reanudados.
- La acción queda en la línea temporal y en el registro de auditoría.

---

### CU-22 - Gestionar plantillas de comunicación

| Campo | Contenido |
|---|---|
| Identificador | CU-22 |
| Nombre | Gestionar plantillas de comunicación |
| Objetivo | Mantener las plantillas de los correos de factura y recordatorios, con variables, idiomas e historial de uso. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | Las plantillas se usan en CU-18 |
| Requisitos relacionados | FR-26, UR-15, BR-11, BR-20, NFR-09 |

### Precondiciones

- El usuario está autenticado con rol Administrador o superior y tiene permiso para editar plantillas.

### Flujo principal

1. El Administrador accede a las plantillas y selecciona el tipo (factura, recordatorio previo, vencimiento, impago o disputa resuelta) y el idioma.
2. El sistema muestra el contenido y las variables dinámicas disponibles.
3. El Administrador edita el contenido.
4. El Administrador solicita la previsualización.
5. El sistema muestra la previsualización con datos de ejemplo y avisa mediante una alerta si falta alguna variable.
6. El Administrador guarda la plantilla.
7. El sistema guarda una nueva versión, que se usará en los envíos posteriores, y registra quién la modificó y cuándo.

### Flujos alternativos

#### A1. Crear una plantilla en otro idioma

1. En el paso 1, el Administrador crea la plantilla de un tipo existente en otro idioma.
2. El sistema la guarda como una nueva plantilla disponible para ese idioma.

#### A2. Consultar el historial de uso

1. El Administrador consulta qué plantilla se usó en un envío.
2. El sistema muestra la versión utilizada en ese envío.

### Flujos de excepción

#### E1. Contenido o variable no válidos

1. En el paso 6, el contenido está vacío o usa una variable inexistente.
2. El sistema no guarda e indica qué corregir.

#### E2. Sin permiso

1. Un usuario sin permiso intenta editar una plantilla.
2. El sistema rechaza la operación (el control se realiza en servidor).

### Postcondiciones

- La nueva versión de la plantilla se aplica a los envíos posteriores.
- Los envíos y las facturas ya emitidos conservan la versión utilizada y no se alteran.
- El cambio queda en el registro de auditoría.

---

## Bloque E. Seguimiento, consulta e informes

### CU-23 - Gestionar notificaciones y canales

| Campo | Contenido |
|---|---|
| Identificador | CU-23 |
| Nombre | Gestionar notificaciones y canales |
| Objetivo | Consultar y resolver las notificaciones internas, configurar su canal y comunicarse en los canales internos de cliente o factura. |
| Actor principal | Usuario operativo / Planificador del sistema (resumen diario) |
| Actores secundarios | Ninguno |
| Relaciones | Recibe las alertas definidas en CU-24 y los avisos generados por otros casos de uso |
| Requisitos relacionados | FR-24, FR-35, FR-36, FR-42, UR-14, BR-03, BR-21 |

### Precondiciones

- El usuario está autenticado.

### Flujo principal

1. El Usuario operativo abre su bandeja de notificaciones.
2. El sistema muestra las notificaciones dirigidas al usuario, ordenadas por fecha y diferenciando las que requieren acción.
3. El usuario abre una notificación y accede al elemento relacionado.
4. El usuario realiza la acción necesaria o la marca como leída o resuelta.
5. El sistema actualiza el estado de la notificación.
6. El usuario configura, para cada tipo de notificación, el canal (en la aplicación, por correo o en el resumen diario).
7. El sistema guarda las preferencias.

### Flujos alternativos

#### A1. Resumen diario

1. El Planificador del sistema llega a la hora del resumen diario.
2. El sistema reúne las notificaciones pendientes de los usuarios que lo han activado y se las envía por correo.

#### A2. Bandeja global del Administrador

1. En el paso 1, el usuario es Administrador o superior.
2. El sistema muestra además las notificaciones globales de los clientes que gestiona.

#### A3. Canal interno de cliente o factura

1. En el paso 3, el usuario escribe un mensaje en el canal interno de un cliente o factura, con adjuntos si procede.
2. El sistema lo guarda y notifica a los usuarios mencionados (CU-25). Nunca se envía al cliente (A-15).

### Flujos de excepción

#### E1. Notificación ya resuelta

1. En el paso 4, otro usuario ha resuelto la notificación.
2. El sistema informa del estado actual y no duplica la acción.

#### E2. Fallo en el envío del resumen

1. En A1, falla el envío del correo.
2. El sistema reintenta y registra el error en la monitorización (CU-33).

### Postcondiciones

- Las notificaciones quedan con su estado actualizado y las preferencias de canal guardadas.
- Los mensajes internos permanecen dentro de la plataforma.

---

### CU-24 - Configurar alertas

| Campo | Contenido |
|---|---|
| Identificador | CU-24 |
| Nombre | Configurar alertas |
| Objetivo | Definir, dentro de un conjunto cerrado de reglas, las alertas que generan notificaciones sobre facturas y clientes. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | Las alertas generan notificaciones gestionadas en CU-23 |
| Requisitos relacionados | FR-42, UR-14, BR-03, NFR-09 |

### Precondiciones

- El usuario está autenticado con rol Administrador o superior.

### Flujo principal

1. El Administrador accede a la configuración de alertas.
2. El sistema muestra las reglas disponibles (por ejemplo, factura vencida durante más de N días o cliente con deuda superior a un importe) y las alertas activas.
3. El Administrador selecciona una regla y define sus parámetros.
4. El sistema valida los parámetros y activa la alerta.
5. El sistema confirma la operación y registra el cambio.

### Flujos alternativos

#### A1. Modificar una alerta

1. En el paso 2, el Administrador modifica los parámetros de una alerta activa.
2. El sistema valida, guarda y registra los valores anteriores y nuevos.

#### A2. Desactivar una alerta

1. El Administrador desactiva una alerta.
2. El sistema deja de generar notificaciones de esa alerta, sin borrar las ya emitidas.

### Flujos de excepción

#### E1. Parámetros inválidos

1. En el paso 4, un parámetro no es válido.
2. El sistema no guarda e indica qué corregir.

#### E2. Regla no disponible

1. El usuario intenta definir una regla que no pertenece al conjunto disponible.
2. El sistema no lo permite: las alertas solo se crean a partir de las reglas existentes.

### Postcondiciones

- La alerta queda activa, modificada o desactivada.
- El cambio queda en el registro de auditoría.

---

### CU-25 - Gestionar incidencias y comentarios

| Campo | Contenido |
|---|---|
| Identificador | CU-25 |
| Nombre | Gestionar incidencias y comentarios |
| Objetivo | Registrar y seguir las incidencias de un cliente o factura, con comentarios internos, menciones y adjuntos. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | Incluido por CU-19 Gestionar rebote de correo |
| Requisitos relacionados | FR-24, FR-34, FR-35, FR-36, UR-14, BR-21, NFR-07 |

### Precondiciones

- El usuario está autenticado y el cliente está asignado al usuario (o el usuario es Administrador o superior).

### Flujo principal

1. El Usuario operativo abre la ficha del cliente o la factura y selecciona "Nueva incidencia".
2. El sistema muestra el formulario.
3. El usuario indica el título, la descripción, el responsable y la prioridad, y adjunta archivos si procede.
4. El sistema valida los datos y guarda la incidencia con estado "abierta".
5. El sistema notifica al responsable y la registra en la línea temporal.
6. El usuario o el responsable añaden comentarios internos a la incidencia.

### Flujos alternativos

#### A1. Actualizar la incidencia

1. El usuario cambia el estado, la prioridad o el responsable.
2. El sistema guarda el cambio, lo registra y notifica al nuevo responsable.

#### A2. Mencionar a un usuario

1. En el paso 6, el usuario menciona a otro usuario en un comentario.
2. El sistema le envía una notificación.

#### A3. Incidencia automática

1. Otro caso de uso (CU-19) crea una incidencia al detectar un problema.
2. El sistema la guarda como incidencia automática y continúa en el paso 5.

### Flujos de excepción

#### E1. Datos o adjunto inválidos

1. En el paso 4, falta el título o el adjunto no cumple los límites permitidos.
2. El sistema no guarda e indica qué corregir.

#### E2. Cliente no asignado

1. El usuario intenta abrir una incidencia de un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor).

### Postcondiciones

- La incidencia queda registrada con su estado, prioridad, responsable, comentarios y adjuntos.
- Los comentarios internos nunca se envían al cliente.

---

### CU-26 - Generar, exportar y conservar informes

| Campo | Contenido |
|---|---|
| Identificador | CU-26 |
| Nombre | Generar, exportar y conservar informes |
| Objetivo | Obtener informes filtrados, exportarlos y conservarlos durante un periodo para su posterior descarga. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | Ninguna |
| Requisitos relacionados | FR-25, FR-37, UR-09, UR-15, BR-04, BR-24, NFR-07, NFR-12, NFR-17 |

### Precondiciones

- El usuario está autenticado y tiene permiso para consultar informes.

### Flujo principal

1. El Usuario operativo accede a los informes y selecciona el tipo de informe.
2. El usuario define los filtros (periodo, cliente, responsable, país, sector, estado, tipo y moneda).
3. El sistema genera el informe limitándose a los datos que el usuario tiene permiso para ver y lo muestra.
4. El usuario selecciona "Exportar" y elige el formato (CSV o PDF).
5. El sistema genera el archivo, lo conserva durante el periodo configurado y entrega un enlace de descarga temporal (A-04).
6. El usuario descarga el archivo.

### Flujos alternativos

#### A1. Informe pesado

1. En el paso 3, el informe requiere un procesamiento largo.
2. El sistema lo genera en segundo plano, notifica al usuario cuando está listo y no bloquea la aplicación.

#### A2. Descargar un informe conservado

1. El usuario accede a un informe exportado anteriormente.
2. El sistema comprueba los permisos y la vigencia del archivo y lo entrega.

### Flujos de excepción

#### E1. Sin datos

1. En el paso 3, no hay datos para los filtros elegidos.
2. El sistema lo indica y sugiere ampliar los filtros.

#### E2. Archivo expirado o enlace no autorizado

1. En A2, el archivo ha superado el periodo de conservación o el usuario ya no tiene permiso.
2. El sistema no lo entrega y ofrece generarlo de nuevo si los permisos lo permiten.

#### E3. Fallo en la generación

1. En los pasos 3 o 5, la generación falla.
2. El sistema muestra un error con un identificador y lo registra en la monitorización (CU-33).

### Postcondiciones

- El informe se ha generado con los filtros indicados y solo con datos permitidos.
- El archivo exportado se conserva durante el periodo configurado y solo es accesible con autenticación.

---

### CU-27 - Consultar dashboard financiero

| Campo | Contenido |
|---|---|
| Identificador | CU-27 |
| Nombre | Consultar dashboard financiero |
| Objetivo | Ver el estado financiero global (facturación, cobros y deuda) y desglosar cada cifra hasta los datos que la componen. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | Muestra los objetivos y centros de coste de CU-28 |
| Requisitos relacionados | FR-29, FR-40, FR-41, UR-04, UR-09, BR-04, BR-24 |

### Precondiciones

- El usuario está autenticado con rol Administrador o superior.

### Flujo principal

1. El Administrador accede al dashboard financiero.
2. El sistema muestra las cifras principales actualizadas (por ejemplo, importes pendientes de cobro, facturación y deuda vencida).
3. El Administrador filtra por empresa, fecha u otros criterios disponibles.
4. El sistema actualiza las cifras.
5. El Administrador selecciona una cifra.
6. El sistema muestra el detalle (clientes y facturas) que la componen.

### Flujos alternativos

#### A1. Comparar con objetivos

1. En el paso 3, el Administrador activa la comparación con los objetivos de facturación (CU-28).
2. El sistema muestra las cifras reales junto al objetivo.

#### A2. Ver por centro de coste

1. El Administrador agrupa las cifras por centro de coste.
2. El sistema muestra el desglose por categoría.

#### A3. Abrir una factura desde el detalle

1. En el paso 6, el Administrador selecciona una factura.
2. El sistema abre su ficha (CU-15).

### Flujos de excepción

#### E1. Sin datos

1. En el paso 4, no hay datos para el periodo o filtros elegidos.
2. El sistema lo indica sin mostrar cifras a cero engañosas.

#### E2. Filtro inválido

1. El Administrador introduce un rango de fechas no válido.
2. El sistema no aplica el filtro e indica qué corregir.

### Postcondiciones

- El Administrador ha consultado las cifras con los filtros elegidos.
- La consulta no modifica ningún dato.
- Las cantidades en distintas monedas se muestran convertidas a la moneda base solo a efectos de informe.

---

### CU-28 - Gestionar objetivos y centros de coste

| Campo | Contenido |
|---|---|
| Identificador | CU-28 |
| Nombre | Gestionar objetivos y centros de coste |
| Objetivo | Definir los objetivos de facturación y las categorías de coste que alimentan el dashboard y los informes. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | Alimenta CU-27 y CU-26 |
| Requisitos relacionados | FR-40, FR-41, UR-15, BR-04, NFR-09 |

### Precondiciones

- El usuario está autenticado con rol Administrador o superior.

### Flujo principal (definir un objetivo)

1. El Administrador accede a la gestión de objetivos.
2. El sistema muestra los objetivos vigentes.
3. El Administrador define un objetivo de facturación indicando el periodo y el importe.
4. El sistema valida los datos y guarda el objetivo, registrando quién y cuándo.
5. El sistema lo hace visible en el dashboard (CU-27).

### Flujos alternativos

#### A1. Modificar un objetivo

1. En el paso 2, el Administrador modifica un objetivo existente.
2. El sistema guarda el cambio registrando los valores anteriores y nuevos.

#### A2. Gestionar centros de coste

1. El Administrador crea, renombra o desactiva una categoría de coste y la asigna a clientes o facturas.
2. El sistema guarda el cambio. Renombrar una categoría no altera ni elimina la información histórica asociada.

### Flujos de excepción

#### E1. Datos inválidos

1. En el paso 4, el periodo o el importe no son válidos, o solapan con otro objetivo.
2. El sistema no guarda e indica qué corregir.

#### E2. Categoría con información asociada

1. En A2, el Administrador intenta eliminar una categoría que tiene información asociada.
2. El sistema no la elimina y ofrece desactivarla (A-16).

### Postcondiciones

- Los objetivos y las categorías quedan guardados y visibles para el dashboard y los informes.
- La información histórica no se altera.
- Los cambios quedan en el registro de auditoría.

---

### CU-29 - Consultar pantalla de trabajo diario

| Campo | Contenido |
|---|---|
| Identificador | CU-29 |
| Nombre | Consultar pantalla de trabajo diario |
| Objetivo | Mostrar a cada usuario, en una única pantalla, lo que debe atender hoy. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | Punto de acceso a CU-04, CU-08, CU-13, CU-17, CU-19 y CU-21 |
| Requisitos relacionados | FR-24, FR-32, FR-50, UR-14, BR-03, NFR-07 |

### Precondiciones

- El usuario está autenticado.

### Flujo principal

1. El Usuario operativo accede a su pantalla de trabajo diario (por defecto, tras iniciar sesión).
2. El sistema muestra, limitado a los clientes del usuario, las facturas que vencen pronto o están vencidas, los pagos pendientes de conciliar, los problemas de entrega, las aprobaciones pendientes y las tareas asignadas.
3. El usuario selecciona un elemento.
4. El sistema abre la pantalla correspondiente para resolverlo.

### Flujos alternativos

#### A1. Aprobaciones del Administrador

1. En el paso 2, el usuario es Administrador o superior.
2. El sistema incluye además las aprobaciones que le corresponde resolver (CU-08, CU-09 y CU-13).

#### A2. Nada pendiente

1. En el paso 2, no hay elementos pendientes.
2. El sistema lo indica con un mensaje claro.

### Flujos de excepción

#### E1. Elemento ya resuelto

1. En el paso 4, otro usuario ha resuelto el elemento mientras tanto.
2. El sistema informa de su estado actual y lo retira de la lista.

#### E2. Fallo parcial al cargar

1. En el paso 2, una de las secciones no puede cargarse.
2. El sistema muestra el resto de secciones, indica cuál ha fallado y permite reintentar.

### Postcondiciones

- El usuario conoce sus pendientes y puede acceder a ellos directamente.
- La consulta no modifica ningún dato.

---

## Bloque F. Administración, seguridad y sistema

### CU-30 - Iniciar sesión y recuperar contraseña

| Campo | Contenido |
|---|---|
| Identificador | CU-30 |
| Nombre | Iniciar sesión y recuperar contraseña |
| Objetivo | Permitir el acceso seguro a la plataforma con cuenta corporativa y recuperar la contraseña de forma segura. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |
| Relaciones | Da acceso a CU-29 |
| Requisitos relacionados | FR-06, UR-01, UR-11, BR-05, NFR-08, NFR-09 |

### Precondiciones

- El usuario tiene una cuenta activa creada por invitación (CU-31).

### Flujo principal (iniciar sesión)

1. El usuario accede a la plataforma e introduce su correo corporativo y su contraseña.
2. El sistema valida el dominio autorizado, las credenciales y que la cuenta está activa.
3. El sistema crea una sesión segura.
4. El sistema muestra la pantalla de trabajo diario (CU-29).

### Flujos alternativos

#### A1. Recuperar la contraseña

1. En el paso 1, el usuario selecciona "He olvidado mi contraseña" e introduce su correo.
2. El sistema envía un enlace temporal de recuperación, que caduca a la hora de enviarse (A-04), y responde de la misma forma exista o no la cuenta.
3. El usuario abre el enlace e introduce una nueva contraseña.
4. El sistema guarda la contraseña, invalida el enlace y las sesiones anteriores, y registra el cambio.

#### A2. Doble factor opcional

1. En el paso 2, el usuario tiene activado el doble factor.
2. El sistema solicita el segundo factor antes de crear la sesión.

### Flujos de excepción

#### E1. Credenciales incorrectas

1. En el paso 2, el correo o la contraseña no son correctos.
2. El sistema rechaza el acceso con un mensaje genérico que no revela qué dato falló.

#### E2. Cuenta no autorizada o desactivada

1. El dominio no está autorizado o la cuenta está desactivada.
2. El sistema rechaza el acceso. No existe el autorregistro.

#### E3. Demasiados intentos fallidos

1. El usuario supera el número de intentos fallidos permitido.
2. El sistema bloquea temporalmente el acceso y lo registra.

#### E4. Enlace caducado

1. En A1, el enlace ha caducado o ya se usó.
2. El sistema lo indica y permite solicitar uno nuevo.

### Postcondiciones

- El usuario tiene una sesión activa o ha cambiado su contraseña de forma segura.
- Los accesos fallidos y los cambios de contraseña quedan registrados.

---

### CU-31 - Gestionar usuarios, roles y asignación de clientes

| Campo | Contenido |
|---|---|
| Identificador | CU-31 |
| Nombre | Gestionar usuarios, roles y asignación de clientes |
| Objetivo | Dar de alta usuarios por invitación, asignarles rol y clientes, y desactivarlos cuando proceda. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | Ninguna |
| Requisitos relacionados | FR-06, FR-07, FR-32, UR-01, UR-06, NFR-07, NFR-08, NFR-09 |

### Precondiciones

- El usuario está autenticado con rol Administrador o superior y tiene permiso para gestionar usuarios.

### Flujo principal (invitar a un usuario)

1. El Administrador selecciona "Invitar usuario".
2. El sistema solicita el correo corporativo y el rol.
3. El Administrador los introduce.
4. El sistema valida que el dominio está autorizado, que el usuario no existe y que el rol puede concederse.
5. El sistema envía la invitación por correo.
6. El usuario activa su cuenta y define su contraseña.
7. El Administrador asigna clientes al usuario.
8. El sistema guarda la asignación y la registra.

### Flujos alternativos

#### A1. Cambiar el rol

1. El Administrador cambia el rol de un usuario.
2. El sistema aplica los nuevos permisos, comprobados en servidor, y lo registra.

#### A2. Desactivar una cuenta

1. El Administrador desactiva una cuenta.
2. El sistema impide nuevos accesos, invalida las sesiones activas y conserva la cuenta y su rastro histórico.

#### A3. Reasignar clientes

1. El Administrador reasigna clientes de un usuario a otro.
2. Las tareas pendientes de esos clientes pasan al nuevo responsable (CU-04, A3).

### Flujos de excepción

#### E1. Correo no corporativo

1. En el paso 4, el dominio no está autorizado.
2. El sistema no envía la invitación e indica el motivo.

#### E2. Usuario ya existente

1. En el paso 4, ya existe una cuenta con ese correo.
2. El sistema no crea un duplicado e indica el estado de la cuenta existente.

#### E3. Rol no permitido

1. En el paso 4 o en A1, el Administrador intenta conceder o modificar el rol Superadministrador.
2. El sistema lo impide (A-14).

#### E4. Sin permiso para gestionar usuarios

1. Un Administrador sin permiso de gestión de usuarios intenta realizar la operación.
2. El sistema la rechaza (el control se realiza en servidor).

### Postcondiciones

- El usuario queda invitado, con rol y clientes asignados, o desactivado, según el flujo.
- Los cambios quedan en el registro de auditoría.

---

### CU-32 - Ejecutar acción masiva

| Campo | Contenido |
|---|---|
| Identificador | CU-32 |
| Nombre | Ejecutar acción masiva |
| Objetivo | Aplicar una misma operación a varios elementos a la vez, con confirmación explícita del alcance y controles adicionales. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |
| Relaciones | Ninguna |
| Requisitos relacionados | FR-31, UR-12, BR-12, NFR-07, NFR-09 |

### Precondiciones

- El usuario está autenticado con rol Administrador o superior y tiene permiso sobre los elementos afectados.

### Flujo principal

1. El Administrador selecciona los elementos mediante filtro o selección manual.
2. El Administrador elige la acción masiva (por ejemplo, reasignar clientes o etiquetarlos).
3. El sistema muestra el número exacto de elementos afectados y un resumen de la acción.
4. El Administrador confirma de forma explícita.
5. El sistema ejecuta la acción sobre todos los elementos.
6. El sistema muestra el resumen del resultado.
7. El sistema registra la operación en el registro de auditoría.

### Flujos alternativos

#### A1. Cancelar

1. En el paso 4, el Administrador cancela.
2. El sistema no modifica ningún dato.

#### A2. Acción de alto impacto económico

1. En el paso 3, la acción tiene alto impacto económico.
2. El sistema exige controles adicionales: una confirmación reforzada y la aprobación de otra persona distinta de quien la solicita (A-17).

### Flujos de excepción

#### E1. Selección vacía

1. En el paso 3, la selección no contiene elementos.
2. El sistema no permite continuar.

#### E2. Elementos no permitidos

1. En el paso 3, la selección incluye elementos sobre los que el usuario no tiene permiso.
2. El sistema los excluye o impide la acción e indica el motivo.

#### E3. Fallo durante la ejecución

1. En el paso 5, la ejecución falla.
2. El sistema revierte la acción completa, no deja datos a medias y muestra el error (A-18).

### Postcondiciones

- La acción se ha aplicado a todos los elementos confirmados, o a ninguno.
- La operación queda registrada, con su alcance exacto y su responsable.

---

### CU-33 - Consultar monitorización y métricas

| Campo | Contenido |
|---|---|
| Identificador | CU-33 |
| Nombre | Consultar monitorización y métricas |
| Objetivo | Conocer el estado de las tareas automatizadas, las integraciones y las copias de seguridad, y consultar métricas agregadas del sistema. |
| Actor principal | Administrador / Planificador del sistema |
| Actores secundarios | Ninguno |
| Relaciones | Recibe los resultados de CU-11, CU-16, CU-18 y CU-20 |
| Requisitos relacionados | FR-38, FR-48, UR-08, BR-03, BR-08, NFR-14 |

### Precondiciones

- El usuario está autenticado con rol Administrador o superior.

### Flujo principal

1. El Administrador accede al panel de monitorización.
2. El sistema muestra la última ejecución de la generación recurrente, la cola de correos pendientes, los errores de integración recientes y la última copia de seguridad correcta.
3. El Administrador selecciona un elemento con incidencia.
4. El sistema muestra su detalle con un identificador de error.
5. El Administrador consulta las métricas agregadas del sistema.

### Flujos alternativos

#### A1. El Planificador registra resultados

1. El Planificador del sistema finaliza una tarea automatizada.
2. El sistema registra su resultado, que queda disponible en el panel.

#### A2. Métricas de uso

1. En el paso 5, el Administrador consulta las métricas de uso.
2. El sistema las muestra de forma agregada, sin vigilancia individual de empleados.

### Flujos de excepción

#### E1. Sin datos

1. Todavía no existe ninguna ejecución registrada.
2. El sistema lo indica sin mostrar estados engañosos.

#### E2. Fuente de datos no disponible

1. En el paso 2, una fuente no responde.
2. El sistema muestra el resto del panel e indica qué fuente falla.

### Postcondiciones

- El Administrador conoce el estado operativo del sistema.
- La consulta no modifica ningún dato.

---

### CU-34 - Consultar registro de auditoría

| Campo | Contenido |
|---|---|
| Identificador | CU-34 |
| Nombre | Consultar registro de auditoría |
| Objetivo | Revisar quién hizo qué y cuándo en la plataforma. |
| Actor principal | Superadministrador |
| Actores secundarios | Ninguno |
| Relaciones | Recoge los eventos generados por el resto de casos de uso |
| Requisitos relacionados | FR-10, FR-22, UR-10, NFR-09 |

### Precondiciones

- El usuario está autenticado como Superadministrador.

### Flujo principal

1. El Superadministrador accede al registro de auditoría.
2. El sistema muestra los eventos más recientes.
3. El Superadministrador filtra por usuario, acción, fecha o entidad (cliente, factura u otra).
4. El sistema muestra los eventos que cumplen los filtros.
5. El Superadministrador abre un evento.
6. El sistema muestra quién lo realizó, qué se hizo, cuándo y, si procede, los valores anteriores y nuevos.

### Flujos alternativos

#### A1. Consultar el historial de una entidad

1. En el paso 3, el Superadministrador accede al registro desde una factura o cliente.
2. El sistema muestra los eventos de esa entidad.

#### A2. Consultar un error técnico

1. En el paso 3, el Superadministrador busca por un identificador de error.
2. El sistema muestra los eventos relacionados.

### Flujos de excepción

#### E1. Sin resultados

1. En el paso 4, ningún evento cumple los filtros.
2. El sistema lo indica.

#### E2. Acceso no autorizado

1. Un usuario con otro rol intenta acceder.
2. El sistema rechaza el acceso (el control se realiza en servidor).

### Postcondiciones

- El Superadministrador ha consultado los eventos.
- El registro es de solo lectura: ningún evento puede modificarse ni borrarse.

---

### CU-35 - Configurar facturación y tarifas

| Campo | Contenido |
|---|---|
| Identificador | CU-35 |
| Nombre | Configurar facturación y tarifas |
| Objetivo | Mantener los parámetros que rigen la facturación: series, impuestos, tabla de tarifas, umbrales de aprobación y datos del emisor. |
| Actor principal | Superadministrador |
| Actores secundarios | Ninguno |
| Relaciones | Sus parámetros se usan en CU-06, CU-07, CU-09, CU-11 y CU-12 |
| Requisitos relacionados | FR-01, FR-10, FR-17, FR-18, UR-13, BR-11, BR-12, NFR-09 |

### Precondiciones

- El usuario está autenticado como Superadministrador.

### Flujo principal

1. El Superadministrador accede a la configuración de facturación.
2. El sistema muestra los parámetros vigentes (series, impuestos, tabla de tarifas, umbrales de aprobación y datos del emisor).
3. El Superadministrador modifica uno o varios parámetros.
4. El sistema valida los cambios.
5. El sistema informa de que se aplicarán solo a las facturas y revisiones futuras.
6. El Superadministrador confirma.
7. El sistema guarda los cambios con su fecha de efecto y registra el valor anterior y el nuevo.

### Flujos alternativos

#### A1. Modificar la tabla de tarifas

1. En el paso 3, el Superadministrador modifica los rangos y precios.
2. El sistema valida que los rangos son coherentes y los guarda.

#### A2. Crear una serie de facturación

1. En el paso 3, el Superadministrador crea una serie nueva con su numeración inicial.
2. El sistema la guarda y la deja disponible.

### Flujos de excepción

#### E1. Valores inválidos

1. En el paso 4, un valor no es válido (por ejemplo, rangos de tarifa solapados o con huecos).
2. El sistema no guarda e indica qué corregir.

#### E2. Serie en uso

1. El Superadministrador intenta eliminar una serie con facturas emitidas.
2. El sistema lo impide para preservar la numeración correlativa.

### Postcondiciones

- La configuración queda actualizada para las facturas y revisiones futuras.
- Las facturas históricas no se alteran.
- El cambio queda en el registro de auditoría.

---

### CU-36 - Configurar recordatorios y funciones inteligentes

| Campo | Contenido |
|---|---|
| Identificador | CU-36 |
| Nombre | Configurar recordatorios y funciones inteligentes |
| Objetivo | Definir la cadencia de los recordatorios de pago y activar o desactivar las funciones opcionales de IA. |
| Actor principal | Superadministrador |
| Actores secundarios | Ninguno |
| Relaciones | Sus parámetros se usan en CU-20 |
| Requisitos relacionados | FR-05, FR-39, UR-13, BR-16, BR-23, BR-25, NFR-09 |

### Precondiciones

- El usuario está autenticado como Superadministrador.

### Flujo principal

1. El Superadministrador accede a la configuración de recordatorios.
2. El sistema muestra la cadencia vigente: recordatorio previo, recordatorio de vencimiento y frecuencia de los avisos de impago.
3. El Superadministrador modifica los plazos.
4. El sistema valida que son coherentes entre sí.
5. El sistema guarda los cambios, que se aplicarán en las siguientes ejecuciones (CU-20), y registra el valor anterior y el nuevo.

### Flujos alternativos

#### A1. Activar o desactivar funciones inteligentes

1. En el paso 2, el Superadministrador activa o desactiva una función inteligente.
2. El sistema lo guarda y mantiene el funcionamiento normal sin ella (BR-23). Las sugerencias con efecto económico siempre requieren confirmación humana (FR-39).

#### A2. Vencimiento pactado

1. En el paso 4, el sistema recuerda que el vencimiento pactado con un cliente prevalece sobre el general.
2. Los clientes con vencimiento pactado no se ven afectados por el cambio del general.

### Flujos de excepción

#### E1. Valores incoherentes

1. En el paso 4, un plazo es negativo o el recordatorio previo queda posterior al vencimiento.
2. El sistema no guarda e indica qué corregir.

#### E2. Servicio de IA no disponible

1. En A1, el servicio de IA no responde.
2. El sistema desactiva la función de forma controlada, sigue funcionando sin ella y lo registra en la monitorización.

### Postcondiciones

- La cadencia y las funciones quedan configuradas para las ejecuciones siguientes.
- Los avisos ya enviados no se modifican.
- El cambio queda en el registro de auditoría.

---

### CU-37 - Consultar datos y operar por API

| Campo | Contenido |
|---|---|
| Identificador | CU-37 |
| Nombre | Consultar datos y operar por API |
| Objetivo | Permitir que un sistema externo autorizado consulte datos y registre solicitudes controladas sin saltarse las reglas de negocio. |
| Actor principal | Sistema externo |
| Actores secundarios | Ninguno |
| Relaciones | Las solicitudes registradas se resuelven en los casos de uso humanos (por ejemplo, CU-05) |
| Requisitos relacionados | FR-49, BR-07, BR-22, NFR-07, NFR-09, NFR-17 |

### Precondiciones

- El sistema externo dispone de credenciales válidas y permisos concedidos.

### Flujo principal (consulta)

1. El Sistema externo se autentica ante la API.
2. El Sistema externo solicita una consulta (por ejemplo, datos de un cliente, sus facturas o su deuda pendiente).
3. El sistema valida las credenciales y comprueba los permisos en servidor.
4. El sistema aplica las mismas reglas de negocio que en la aplicación.
5. El sistema devuelve los datos permitidos.
6. El sistema registra la petición.

### Flujos alternativos

#### A1. Registrar una solicitud controlada

1. En el paso 2, el Sistema externo envía una solicitud (por ejemplo, de baja de un cliente).
2. El sistema la registra como pendiente de revisión humana y no modifica directamente los datos ni las recurrencias (BR-22).

### Flujos de excepción

#### E1. Autenticación inválida

1. En el paso 1, las credenciales no son válidas o han caducado.
2. El sistema rechaza la petición.

#### E2. Sin permiso

1. En el paso 3, el sistema externo no tiene permiso sobre ese dato.
2. El sistema rechaza la petición.

#### E3. Operación prohibida

1. El Sistema externo intenta modificar o eliminar directamente una recurrencia o saltarse una aprobación.
2. El sistema rechaza la operación y la registra.

#### E4. Solicitud inválida

1. En el paso 2, la solicitud está mal formada.
2. El sistema la rechaza e indica el error.

### Postcondiciones

- El sistema externo recibe solo los datos permitidos, o su solicitud queda pendiente de revisión humana.
- Toda petición queda registrada.

---

## Supuestos de análisis introducidos

Decisiones tomadas al especificar que `requisitos.md` no resuelve de forma explícita. Siguen la numeración de la sección 6 de `requisitos.md` (A-02 a A-04 ya existen; A-01 es una fila vacía) y conviene trasladarlas allí o validarlas con el equipo.

| ID | Suposición | Justificación | Requisitos / casos afectados |
|---|---|---|---|
| A-05 | Un cliente puede guardarse sin identificador fiscal, quedando marcado con "datos fiscales incompletos" y sin poder facturarse hasta completarlos. | FR-20 bloquea la emisión por falta de datos fiscales, lo que implica que el cliente puede existir sin ellos; además un identificador extranjero puede no estar disponible al alta. | FR-03, FR-20 · CU-01 (A5), CU-02 (E1), CU-03 (A3), CU-11 (E1), CU-12 (E1) |
| A-06 | El alta de un cliente exige al menos un contacto. | FR-46 envía la factura al contacto de facturación; sin contacto no habría destinatario. | FR-04, FR-46 · CU-01 |
| A-07 | La importación CSV es atómica: ante un fallo técnico se revierte la operación completa. | Evitar registros a medias y duplicados al reintentar (afín a NFR-15). | FR-08, NFR-15 · CU-03 (E3) |
| A-08 | En una importación, una fila que coincide con un cliente existente solo lo actualiza si el usuario lo decide de forma explícita. | Conciliar FR-08 (registros "actualizados") con FR-27 (nunca fusionar automáticamente). | FR-08, FR-27 · CU-02 (A2), CU-03 |
| A-09 | Si el envío de una factura emitida falla, esta permanece en estado "emitida" hasta que el envío se complete, momento en que pasa a "enviada". | FR-19 define ambos estados y FR-46 indica que un fallo de envío no deshace la emisión. | FR-19, FR-46 · CU-12 (E2) |
| A-10 | Las excepciones comerciales con efecto económico (primer mes gratuito, facturación sin prorrateo) quedan pendientes de aprobación (CU-07 y CU-08) y no se aplican en la facturación hasta ser aprobadas. El inicio futuro no requiere aprobación. | BR-12 exige aprobación humana para excepciones económicas sensibles y UR-12 habla de "solicitar" excepciones; FR-47 no menciona aprobación. Sin esta decisión, CU-11 aplicaría un descuento no aprobado y lo emitiría sin revisión. | FR-47, FR-18, BR-12, UR-12 · CU-01 (A4), CU-11 (A3) |
| A-11 | Los umbrales de aprobación, las series, los impuestos, la tabla de tarifas y los datos del emisor se configuran en CU-35; la cadencia de recordatorios y las funciones inteligentes, en CU-36. | `requisitos.md` (sección 1.3) atribuye al Superadministrador la configuración de ambos grupos sin repartirlos; el diagrama los separa en CU-35 y CU-36. | FR-01, FR-05, FR-17, FR-18 · CU-35, CU-36 |
| A-12 | Una factura declarada incobrable deja de recibir recordatorios de impago, sin pasar nunca a "pagada". | FR-19 impide que una deuda incobrable figure como pagada, pero no dice si el recobro automático continúa. | FR-05, FR-19, FR-45 · CU-14 (A3), CU-20 |
| A-13 | Al llegar la fecha de revisión de una suspensión de recordatorios, el sistema avisa al responsable y la suspensión se mantiene hasta que se reanude o se prorrogue. | FR-05 exige una fecha de revisión pero no indica si la suspensión termina sola. | FR-05, FR-24 · CU-21 (A2) |
| A-14 | Un Administrador no puede conceder ni modificar el rol Superadministrador. | UR-06 permite gestionar roles sin fijar límites; se evita la escalada de privilegios. | FR-07, UR-06, NFR-08 · CU-31 (E3) |
| A-15 | Los "canales de comunicación internos" de FR-35 se interpretan como conversaciones internas, con adjuntos, asociadas a un cliente o factura, que nunca se envían al cliente. | La redacción de FR-35 es ambigua; BR-21 impide que los comentarios internos salgan al cliente. | FR-35, BR-21 · CU-23 (A3), CU-25 |
| A-16 | Una categoría de centro de coste con información asociada no se elimina, solo se desactiva. | FR-40 exige que la información histórica no se altere ni se elimine al modificar categorías. | FR-40 · CU-28 (E2) |
| A-17 | Las acciones masivas de alto impacto económico exigen confirmación reforzada y la aprobación de una persona distinta de quien las solicita. | FR-31 prohíbe estas acciones "sin controles" sin definirlos; se reutiliza el criterio de BR-12. | FR-31, BR-12 · CU-32 (A2) |
| A-18 | Las acciones masivas son atómicas: si fallan, se revierte la operación completa. | Mismo criterio que A-07; evita datos a medias en una operación de gran alcance. | FR-31, NFR-15 · CU-32 (E3) |
