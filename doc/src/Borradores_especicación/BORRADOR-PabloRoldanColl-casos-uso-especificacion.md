# Especificación de Casos de Uso

## Bloque A. Clientes y contactos

### CU-01 - Gestionar cliente y contactos

| Campo | Contenido |
|---|---|
| Identificador | CU-01 |
| Nombre | Gestionar cliente y contactos |
| Objetivo | Permitir la creación, edición y mantenimiento de la información de los clientes corporativos y sus personas de contacto. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- El actor debe estar autenticado en el sistema.

#### Flujo principal
1. El actor selecciona la opción de crear o editar un cliente.
2. El sistema muestra el formulario de datos del cliente y contactos.
3. El actor introduce la información requerida.
4. El sistema ejecuta el CU-02 Detectar cliente duplicado (`<<include>>`).
5. El sistema valida los datos y guarda el registro.
6. El sistema confirma la operación exitosa.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Cliente duplicado detectado**
1. El CU-02 devuelve que el cliente ya existe.
2. El sistema bloquea la creación y muestra un aviso al actor.
3. El actor decide si editar el existente o cancelar.

#### Postcondiciones
- El cliente y sus contactos quedan registrados o actualizados en la base de datos.

---

### CU-02 - Detectar cliente duplicado

| Campo | Contenido |
|---|---|
| Identificador | CU-02 |
| Nombre | Detectar cliente duplicado |
| Objetivo | Prevenir la redundancia de datos verificando si un cliente ya existe en el sistema basándose en identificadores únicos (NIF/CIF, correo). |
| Actor principal | Sistema (invocado internamente) |
| Actores secundarios | Ninguno |

#### Precondiciones
- Haber sido invocado mediante `<<include>>` por CU-01 o CU-03.

#### Flujo principal
1. El sistema recibe los datos del cliente a validar.
2. El sistema consulta la base de datos comparando NIF/CIF o dominios de correo.
3. El sistema determina que no hay coincidencias.
4. El sistema devuelve un estado de validación positiva.

#### Flujos alternativos
**A1. Coincidencia encontrada**
1. En el paso 3, el sistema encuentra una coincidencia exacta.
2. El sistema devuelve un estado de advertencia y el ID del cliente duplicado.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El sistema de origen (CU-01 o CU-03) recibe el resultado de la validación.

---

### CU-03 - Importar datos por CSV

| Campo | Contenido |
|---|---|
| Identificador | CU-03 |
| Nombre | Importar datos por CSV |
| Objetivo | Permitir la carga masiva de clientes y contactos desde un archivo externo. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- El actor dispone de un archivo CSV con el formato estandarizado.

#### Flujo principal
1. El actor sube el archivo CSV al sistema.
2. El sistema lee y mapea las columnas del archivo.
3. Por cada registro, el sistema invoca el CU-02 Detectar cliente duplicado (`<<include>>`).
4. El sistema procesa e inserta los registros válidos.
5. El sistema muestra un resumen de la importación.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Formato de archivo inválido**
1. En el paso 2, el sistema no reconoce las cabeceras.
2. El sistema aborta la operación y solicita corregir el archivo.

#### Postcondiciones
- Múltiples clientes son persistidos en el sistema simultáneamente.

---

### CU-04 - Gestionar tareas del cliente

| Campo | Contenido |
|---|---|
| Identificador | CU-04 |
| Nombre | Gestionar tareas del cliente |
| Objetivo | Administrar la lista de acciones pendientes (To-Do) asociadas al seguimiento de un cliente específico. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- El cliente debe existir previamente en el sistema.

#### Flujo principal
1. El actor accede a la ficha del cliente y abre la sección de tareas.
2. El sistema muestra las tareas pendientes.
3. El actor crea una nueva tarea o marca una existente como completada.
4. El sistema actualiza el estado de la tarea.
5. El sistema confirma visualmente el cambio.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El registro de tareas del cliente queda actualizado.

---

## Bloque B. Suscripciones, tarifas y descuentos

### CU-05 - Gestionar baja y pausa de suscripción

| Campo | Contenido |
|---|---|
| Identificador | CU-05 |
| Nombre | Gestionar baja y pausa de suscripción |
| Objetivo | Detener temporal o definitivamente la facturación recurrente de un cliente. |
| Actor principal | Usuario operativo |
| Actores secundarios | Planificador del sistema |

#### Precondiciones
- El cliente debe tener una suscripción activa.

#### Flujo principal
1. El actor selecciona la suscripción de un cliente.
2. El actor elige la acción "Pausar" o "Dar de baja" e introduce una fecha de efectividad.
3. El sistema valida la solicitud.
4. El Planificador del sistema programa la detención de la facturación para la fecha indicada.
5. El sistema confirma el cambio de estado.

#### Flujos alternativos
**A1. Ejecución automática por el Planificador**
1. El Planificador del sistema detecta impago prolongado.
2. El Planificador ejecuta la pausa automáticamente.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- La suscripción cambia a estado pausado o cancelado y se detiene la emisión de facturas futuras (CU-11).

---

### CU-06 - Revisar y aprobar rango de tarifa anual

| Campo | Contenido |
|---|---|
| Identificador | CU-06 |
| Nombre | Revisar y aprobar rango de tarifa anual |
| Objetivo | Validar y dar visto bueno a los cambios en los rangos de precios de las suscripciones. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- Debe existir una propuesta de nueva tarifa pendiente de revisión.

#### Flujo principal
1. El actor accede a la bandeja de tarifas pendientes.
2. El sistema muestra los detalles de la propuesta de tarifa.
3. El actor revisa y pulsa "Aprobar".
4. El sistema actualiza el estado de la tarifa a "Vigente".
5. El sistema notifica la disponibilidad de la nueva tarifa.

#### Flujos alternativos
**A1. Rechazar tarifa**
1. En el paso 3, el actor pulsa "Rechazar" y añade un motivo.
2. El sistema marca la propuesta como rechazada.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- La nueva tarifa queda disponible para ser asignada a clientes.

---

### CU-07 - Solicitar descuento

| Campo | Contenido |
|---|---|
| Identificador | CU-07 |
| Nombre | Solicitar descuento |
| Objetivo | Proponer una reducción de tarifa para un cliente, sujeta a aprobación superior. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- El cliente debe estar en proceso de renovación o alta.

#### Flujo principal
1. El actor configura una cotización para un cliente.
2. El actor aplica un porcentaje de descuento e introduce una justificación.
3. El sistema registra la solicitud en estado "Pendiente de aprobación".
4. El sistema alerta al Administrador (CU-08).

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Descuento fuera de límites base**
1. El actor intenta aplicar un descuento del 100% que el sistema no admite algorítmicamente.
2. El sistema rechaza el intento y pide ajustar el valor.

#### Postcondiciones
- Se crea una solicitud de descuento pendiente de validación.

---

### CU-08 - Aprobar descuento

| Campo | Contenido |
|---|---|
| Identificador | CU-08 |
| Nombre | Aprobar descuento |
| Objetivo | Evaluar y conceder descuentos comerciales propuestos por los usuarios operativos. |
| Actor principal | Administrador |
| Actores secundarios | Superadministrador (mediante extensión) |

#### Precondiciones
- Existe una solicitud de descuento pendiente (generada en CU-07).

#### Flujo principal
1. El actor revisa la solicitud de descuento.
2. El sistema verifica si el descuento supera el umbral configurable. (En el flujo principal, no lo supera).
3. El actor aprueba el descuento.
4. El sistema aplica el descuento a la tarifa del cliente.
5. El sistema notifica al Usuario operativo.

#### Flujos alternativos
**A1. Descuento supera umbral (`<<extend>>`)**
1. En el paso 2, el sistema detecta que el descuento es excepcionalmente alto.
2. Se ejecuta el CU-09 Escalar aprobación al Superadministrador (`<<extend>>`).
3. El proceso de aprobación queda bloqueado hasta que el Superadministrador resuelva.

#### Flujos de excepción
**E1. Denegación de descuento**
1. En el paso 3, el actor rechaza la solicitud.
2. El sistema cancela el descuento y notifica al solicitante.

#### Postcondiciones
- El descuento queda aplicado o rechazado definitivamente.

---

### CU-09 - Escalar aprobación al Superadministrador

| Campo | Contenido |
|---|---|
| Identificador | CU-09 |
| Nombre | Escalar aprobación al Superadministrador |
| Objetivo | Gestionar la aprobación de descuentos que exceden el límite de autoridad del Administrador. |
| Actor principal | Superadministrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- Invocado por extensión (`<<extend>>`) desde el CU-08 al superarse el umbral de descuento.

#### Flujo principal
1. El actor recibe la solicitud escalada de alto descuento.
2. El sistema muestra el histórico del cliente y la justificación.
3. El actor autoriza la operación especial.
4. El sistema marca el descuento como aprobado.
5. El sistema devuelve el control y notifica a los roles inferiores.

#### Flujos alternativos
**A1. Rechazo de la escala**
1. El actor deniega la autorización.
2. El sistema cancela el trámite.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- Un descuento de alto riesgo queda auditado y aprobado o denegado por el máximo nivel.

---

## Bloque C. Facturación

### CU-10 - Gestionar borrador de factura

| Campo | Contenido |
|---|---|
| Identificador | CU-10 |
| Nombre | Gestionar borrador de factura |
| Objetivo | Permitir la preparación manual de una factura antes de su emisión formal. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- El cliente debe tener datos de facturación válidos.

#### Flujo principal
1. El actor crea o edita un borrador de factura.
2. El sistema solicita líneas de concepto, importes e impuestos.
3. El actor añade los datos comerciales.
4. El sistema calcula los totales en tiempo real.
5. El sistema guarda el documento en estado "Borrador".

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- Existe una factura editable en el sistema sin numeración fiscal asignada.

---

### CU-11 - Generar facturas recurrentes

| Campo | Contenido |
|---|---|
| Identificador | CU-11 |
| Nombre | Generar facturas recurrentes |
| Objetivo | Automatizar la creación y emisión periódica de facturas basadas en suscripciones activas. |
| Actor principal | Planificador del sistema |
| Actores secundarios | Ninguno |

#### Precondiciones
- Existen suscripciones activas que alcanzan su ciclo de renovación.

#### Flujo principal
1. El actor (cron) despierta según la programación diaria.
2. El sistema busca suscripciones renovables en la fecha actual.
3. Por cada suscripción, el sistema consolida los datos y genera el documento fiscal.
4. El sistema invoca el CU-12 Emitir factura (`<<include>>`) para formalizarlas.
5. El sistema actualiza la fecha de próximo cobro de la suscripción.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Cliente con datos fiscales incompletos**
1. En el paso 3, el sistema detecta que falta el NIF o dirección.
2. El sistema retiene la generación y crea una incidencia (CU-25).

#### Postcondiciones
- Las facturas del ciclo quedan emitidas y listas para cobro.

---

### CU-12 - Emitir factura

| Campo | Contenido |
|---|---|
| Identificador | CU-12 |
| Nombre | Emitir factura |
| Objetivo | Formalizar una factura, asignándole numeración fiscal inmutable y notificando al cliente. |
| Actor principal | Usuario operativo (o Planificador del sistema) |
| Actores secundarios | Ninguno |

#### Precondiciones
- La factura debe estar en estado borrador o generada por el CU-11.

#### Flujo principal
1. El actor solicita emitir la factura.
2. El sistema valida la integridad financiera del documento.
3. El sistema bloquea el documento, le asigna número de serie y fecha de emisión.
4. El sistema invoca el CU-18 Enviar comunicación al cliente (`<<include>>`).
5. El sistema cambia el estado a "Emitida / Pendiente de cobro".

#### Flujos alternativos
**A1. Factura retenida por cambios sensibles (`<<extend>>`)**
1. En el paso 2, el sistema detecta importe manual alto o vencimiento atípico.
2. Se invoca la extensión hacia el CU-13 Aprobar factura retenida (`<<extend>>`).
3. La emisión se pausa hasta que el Administrador apruebe.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- La factura es legalmente vinculante, inmutable y el cliente ha sido notificado.

---

### CU-13 - Aprobar factura retenida

| Campo | Contenido |
|---|---|
| Identificador | CU-13 |
| Nombre | Aprobar factura retenida |
| Objetivo | Revisar facturas bloqueadas por el sistema debido a anomalías (importes altos, descuentos raros) antes de su emisión. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- Invocado por extensión (`<<extend>>`) desde el CU-12 al detectar anomalías.

#### Flujo principal
1. El actor accede al panel de facturas en cuarentena.
2. El sistema resalta el cambio sensible (ej. vencimiento atípico).
3. El actor revisa y aprueba el documento.
4. El sistema devuelve el control al CU-12 para completar la emisión.

#### Flujos alternativos
**A1. Devolver a borrador**
1. El actor detecta un error real y rechaza la emisión.
2. El sistema devuelve la factura al estado "Borrador" y alerta al creador.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- La factura retenida se libera para su emisión o se descarta.

---

### CU-14 - Rectificar, anular o declarar incobrable una factura

| Campo | Contenido |
|---|---|
| Identificador | CU-14 |
| Nombre | Rectificar, anular o declarar incobrable |
| Objetivo | Gestionar el ciclo de vida excepcional de una factura emitida para mantener la contabilidad saneada. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- La factura objetivo debe estar previamente emitida (CU-12).

#### Flujo principal
1. El actor selecciona una factura emitida y elige la opción contable (ej. Rectificar).
2. El sistema solicita motivo y confirmación.
3. El actor confirma la acción.
4. El sistema genera una factura rectificativa (abono) correlativa.
5. El sistema ajusta el estado contable de ambas facturas.

#### Flujos alternativos
**A1. Declarar incobrable**
1. En el paso 1, el actor selecciona "Declarar incobrable".
2. El sistema cierra la factura a nivel de cobros y la envía a la cuenta de pérdidas.

#### Flujos de excepción
**E1. Factura ya cobrada**
1. El sistema detecta que la factura ya tiene cobros conciliados.
2. El sistema impide la anulación directa y sugiere emitir abono parcial.

#### Postcondiciones
- El estado fiscal del documento queda corregido mediante trazabilidad legal.

---

### CU-15 - Buscar y consultar facturas y clientes

| Campo | Contenido |
|---|---|
| Identificador | CU-15 |
| Nombre | Buscar y consultar facturas y clientes |
| Objetivo | Proporcionar un motor de búsqueda y filtros para localizar entidades comerciales rápidamente. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- El actor debe tener sesión activa.

#### Flujo principal
1. El actor introduce un término de búsqueda (nombre, NIF, número de factura) en el buscador global.
2. El sistema consulta los índices de base de datos.
3. El sistema muestra una lista de resultados agrupados por tipo (Clientes, Facturas).
4. El actor hace clic en un resultado.
5. El sistema despliega la ficha detallada.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El actor visualiza la información deseada.

---

## Bloque D. Cobros y comunicaciones

### CU-16 - Registrar movimiento de cobro

| Campo | Contenido |
|---|---|
| Identificador | CU-16 |
| Nombre | Registrar movimiento de cobro |
| Objetivo | Incorporar ingresos económicos al sistema, ya sea de forma automática vía pasarela o por conciliación bancaria manual. |
| Actor principal | Sistema de pagos (Stripe/Revolut) (o Planificador) |
| Actores secundarios | Ninguno |

#### Precondiciones
- El cliente debe haber realizado un pago.

#### Flujo principal
1. El actor notifica al sistema el ingreso de fondos (vía Webhook o importación bancaria).
2. El sistema registra el importe, fecha y referencia de pago.
3. El sistema invoca el CU-17 Conciliar pagos (`<<include>>`) para asociar el dinero a una deuda.
4. El sistema confirma el registro del cobro.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El dinero ingresado queda registrado en la base de datos financiera.

---

### CU-17 - Conciliar pagos

| Campo | Contenido |
|---|---|
| Identificador | CU-17 |
| Nombre | Conciliar pagos |
| Objetivo | Cruzar un ingreso económico registrado (CU-16) con una o varias facturas pendientes de cobro para saldar la deuda. |
| Actor principal | Usuario operativo (o Sistema automáticamente) |
| Actores secundarios | Ninguno |

#### Precondiciones
- Existen cobros sin asignar y facturas pendientes.

#### Flujo principal
1. El actor (o el sistema automáticamente) selecciona un cobro huérfano.
2. El sistema sugiere facturas pendientes coincidentes en importe o cliente.
3. El actor asocia el cobro a la factura correspondiente.
4. El sistema marca la factura como "Cobrada" o "Cobrada parcialmente".
5. El sistema actualiza el saldo del cliente.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Exceso de pago**
1. El importe del cobro es superior a la factura.
2. El sistema cancela la factura y deja el sobrante como "Saldo a favor" en la ficha del cliente.

#### Postcondiciones
- La deuda del cliente queda amortizada.

---

### CU-18 - Enviar comunicación al cliente

| Campo | Contenido |
|---|---|
| Identificador | CU-18 |
| Nombre | Enviar comunicación al cliente |
| Objetivo | Encapsular el envío de correos electrónicos transaccionales (facturas, recordatorios). |
| Actor principal | Proveedor de correo |
| Actores secundarios | Sistema de origen (CU-12, CU-20, CU-19) |

#### Precondiciones
- Ser invocado por otro caso de uso (`<<include>>` o `<<extend>>`).

#### Flujo principal
1. El sistema de origen solicita el envío adjuntando destinatario, asunto y cuerpo.
2. El sistema compila la plantilla (CU-22).
3. El sistema entrega el paquete al Proveedor de correo.
4. El Proveedor de correo transmite el email al servidor del cliente.
5. El sistema registra la salida del email en el historial del cliente.

#### Flujos alternativos
**A1. Extensión por rebote (`<<extend>>`)**
1. Si el correo no puede ser entregado, el Proveedor notifica al sistema.
2. El proceso se extiende al CU-19 Gestionar rebote de correo.

#### Flujos de excepción
**E1. Fallo de conexión con SMTP**
1. En el paso 3, el Proveedor de correo no responde.
2. El sistema encola el correo para un reintento automático posterior.

#### Postcondiciones
- El correo electrónico es despachado hacia el cliente.

---

### CU-19 - Gestionar rebote de correo

| Campo | Contenido |
|---|---|
| Identificador | CU-19 |
| Nombre | Gestionar rebote de correo |
| Objetivo | Manejar los correos no entregados (hard bounce) para evitar problemas de comunicación y mantener limpia la base de datos. |
| Actor principal | Usuario operativo (o Proveedor de correo detectando fallo) |
| Actores secundarios | Ninguno |

#### Precondiciones
- Un envío previo (CU-18) ha devuelto un error permanente de entrega.

#### Flujo principal
1. El Proveedor de correo alerta del rebote al sistema (extendiendo CU-18).
2. El sistema marca la dirección de correo del cliente como "Inválida".
3. El sistema invoca el CU-25 Gestionar incidencias y comentarios (`<<include>>`) para crear un ticket de revisión.
4. El actor recibe la incidencia, contacta al cliente por otra vía y actualiza el email.
5. El sistema limpia la alerta de rebote.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El contacto queda invalidado hasta su corrección y se genera una incidencia operativa.

---

### CU-20 - Ejecutar flujo de recordatorios e impago

| Campo | Contenido |
|---|---|
| Identificador | CU-20 |
| Nombre | Ejecutar flujo de recordatorios e impago |
| Objetivo | Automatizar la persecución de la deuda enviando correos escalonados a los clientes morosos. |
| Actor principal | Planificador del sistema |
| Actores secundarios | Ninguno |

#### Precondiciones
- Existen facturas cuyo vencimiento ha expirado.

#### Flujo principal
1. El actor (cron) despierta y consulta facturas vencidas no cobradas.
2. El sistema evalúa las reglas de impago (CU-36) para ver si toca enviar aviso.
3. El sistema invoca el CU-18 Enviar comunicación al cliente (`<<include>>`) usando la plantilla correspondiente a la gravedad.
4. El sistema actualiza la fase de impago en la factura.

#### Flujos alternativos
**A1. Factura pausada o en disputa (`<<extend>>`)**
1. En el paso 2, el sistema detecta que la factura tiene activa una suspensión.
2. El proceso se desvía al CU-21 Suspender recordatorios de una factura (`<<extend>>`).
3. El sistema omite el envío del recordatorio para esta factura concreta.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El cliente moroso recibe una notificación de deuda.

---

### CU-21 - Suspender recordatorios de una factura

| Campo | Contenido |
|---|---|
| Identificador | CU-21 |
| Nombre | Suspender recordatorios de una factura |
| Objetivo | Detener temporalmente las automatizaciones de cobro sobre una factura específica porque está en disputa, negociación o revisión. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- La factura debe estar pendiente de cobro y tener recordatorios programados.

#### Flujo principal
1. El actor accede a la factura vencida.
2. El actor activa la opción "Pausar recordatorios" y añade un motivo.
3. El sistema marca la factura con el flag "Recordatorios suspendidos".
4. El sistema intercepta las futuras ejecuciones del CU-20 para esta factura (`<<extend>>`).

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- La factura queda aislada del motor de reclamación automática temporalmente.

---

### CU-22 - Gestionar plantillas de comunicación

| Campo | Contenido |
|---|---|
| Identificador | CU-22 |
| Nombre | Gestionar plantillas de comunicación |
| Objetivo | Diseñar los textos, asuntos y variables (ej. {NombreCliente}) de los correos automáticos. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- Permisos administrativos.

#### Flujo principal
1. El actor abre el editor de plantillas.
2. El sistema carga los layouts disponibles (Nueva Factura, Recordatorio 1, etc.).
3. El actor modifica el texto y añade variables dinámicas.
4. El sistema valida la sintaxis de las variables.
5. El sistema guarda la plantilla y la pone en producción para futuros envíos (CU-18).

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El contenido de las notificaciones automáticas queda actualizado.

---

## Bloque E. Seguimiento, consulta e informes

### CU-23 - Gestionar notificaciones y canales

| Campo | Contenido |
|---|---|
| Identificador | CU-23 |
| Nombre | Gestionar notificaciones y canales |
| Objetivo | Configurar cómo y por dónde (Email, In-App, Slack) reciben alertas los usuarios internos. |
| Actor principal | Usuario operativo (o Planificador para generarlas) |
| Actores secundarios | Ninguno |

#### Precondiciones
- El actor tiene sesión iniciada.

#### Flujo principal
1. El actor accede a preferencias de usuario.
2. El sistema lista los eventos suscribibles (Ej. Pago recibido, Rebote de correo).
3. El actor selecciona los canales deseados para cada evento.
4. El sistema guarda las preferencias.
5. El sistema enrutará las futuras notificaciones según esta configuración.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- Las preferencias de alerta del usuario quedan guardadas.

---

### CU-24 - Configurar alertas

| Campo | Contenido |
|---|---|
| Identificador | CU-24 |
| Nombre | Configurar alertas |
| Objetivo | Definir umbrales de negocio (ej. cobros caen un 20%) que dispararán notificaciones proactivas a los administradores. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- Permisos de Administrador.

#### Flujo principal
1. El actor entra al panel de alertas de negocio.
2. El actor crea una regla (ej. "Avisar si MRR baja de X").
3. El sistema valida y persiste la métrica a observar.
4. El sistema confirma la activación del monitor.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El sistema queda vigilando la métrica indicada.

---

### CU-25 - Gestionar incidencias y comentarios

| Campo | Contenido |
|---|---|
| Identificador | CU-25 |
| Nombre | Gestionar incidencias y comentarios |
| Objetivo | Documentar problemas, llamadas y notas internas asociadas a un cliente o factura. |
| Actor principal | Usuario operativo (o incluido automáticamente por CU-19) |
| Actores secundarios | Ninguno |

#### Precondiciones
- Existencia de la entidad (cliente o factura) a la que asociar la nota.

#### Flujo principal
1. El actor (o el sistema vía include) abre el hilo de incidencias de un cliente.
2. El actor redacta un comentario o describe un problema.
3. El sistema adjunta la marca de tiempo y el autor.
4. El sistema guarda y muestra el comentario en el muro del cliente.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- Se añade un registro cualitativo al histórico del cliente.

---

### CU-26 - Generar, exportar y conservar informes

| Campo | Contenido |
|---|---|
| Identificador | CU-26 |
| Nombre | Generar, exportar y conservar informes |
| Objetivo | Extraer datos financieros y operativos en formatos portables (PDF, Excel) para contabilidad externa o archivo. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- Haber generado actividad en el sistema.

#### Flujo principal
1. El actor navega al módulo de reportes.
2. El actor selecciona el tipo de informe (ej. Libro de IVA) y un rango de fechas.
3. El sistema procesa los datos y compila el documento.
4. El sistema permite la descarga del archivo.
5. El sistema guarda una copia estática del informe en el repositorio documental.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Consulta sin datos**
1. En el paso 3, no hay operaciones en el rango de fechas.
2. El sistema muestra un aviso de "Documento vacío" y cancela la generación.

#### Postcondiciones
- El actor obtiene un documento consolidado de la actividad.

---

### CU-27 - Consultar dashboard financiero

| Campo | Contenido |
|---|---|
| Identificador | CU-27 |
| Nombre | Consultar dashboard financiero |
| Objetivo | Visualizar las métricas clave de negocio (MRR, Churn, Deuda viva) en tiempo real para toma de decisiones. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- Permisos de Administrador.

#### Flujo principal
1. El actor accede a la pantalla principal financiera.
2. El sistema calcula en tiempo real los KPIs leyendo facturas, cobros y suscripciones.
3. El sistema renderiza las gráficas y resúmenes.
4. El actor interactúa con las gráficas para ver detalles de un mes concreto.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El administrador dispone de una fotografía financiera actualizada.

---

### CU-28 - Gestionar objetivos y centros de coste

| Campo | Contenido |
|---|---|
| Identificador | CU-28 |
| Nombre | Gestionar objetivos y centros de coste |
| Objetivo | Categorizar los ingresos para el análisis financiero avanzado y fijar metas de facturación. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- Permisos de Administrador.

#### Flujo principal
1. El actor entra a la configuración analítica.
2. El actor crea un nuevo centro de coste (ej. "Proyecto Alpha") o fija una meta de MRR.
3. El sistema guarda la configuración.
4. El sistema permite desde ese momento etiquetar facturas bajo ese centro de coste.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- La estructura analítica de la empresa se actualiza.

---

### CU-29 - Consultar pantalla de trabajo diario

| Campo | Contenido |
|---|---|
| Identificador | CU-29 |
| Nombre | Consultar pantalla de trabajo diario |
| Objetivo | Proveer a los operativos de un resumen de sus tareas urgentes, cobros pendientes y recordatorios del día. |
| Actor principal | Usuario operativo |
| Actores secundarios | Ninguno |

#### Precondiciones
- Usuario autenticado con trabajo pendiente o clientes asignados.

#### Flujo principal
1. El actor inicia sesión (redirección post CU-30) o hace clic en "Inicio".
2. El sistema recopila las tareas vencidas, incidencias abiertas y facturas conflictivas asignadas a ese usuario.
3. El sistema muestra la lista de prioridades de la jornada.
4. El actor navega desde esa pantalla a las gestiones específicas.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El usuario es dirigido operativamente hacia lo más urgente.

---

## Bloque F. Administración, seguridad y sistema

### CU-30 - Iniciar sesión y recuperar contraseña

| Campo | Contenido |
|---|---|
| Identificador | CU-30 |
| Nombre | Iniciar sesión y recuperar contraseña |
| Objetivo | Autenticar al usuario de forma segura para acceder al sistema y proporcionar un mecanismo para restaurar el acceso si se olvida la contraseña. |
| Actor principal | Usuario operativo |
| Actores secundarios | Proveedor de correo |

#### Precondiciones
- El usuario debe tener una cuenta registrada y activa en el sistema.

#### Flujo principal
1. El actor accede a la pantalla de inicio de sesión del sistema.
2. El sistema solicita las credenciales de acceso.
3. El actor introduce sus credenciales y pulsa entrar.
4. El sistema valida la información.
5. El sistema genera un token de sesión e inicia la sesión del usuario.
6. El sistema redirige al actor al dashboard.

#### Flujos alternativos
**A1. Recuperar contraseña**
1. En el paso 2, el actor selecciona "He olvidado mi contraseña".
2. El sistema envía un enlace de recuperación al correo electrónico.
3. El actor accede al enlace y establece una nueva contraseña.

#### Flujos de excepción
**E1. Credenciales inválidas**
1. El sistema detecta que el correo o la contraseña no coinciden y deniega el acceso.

#### Postcondiciones
- El actor queda autenticado y con acceso a las funciones correspondientes a su rol.

---

### CU-31 - Gestionar usuarios, roles y asignación de clientes

| Campo | Contenido |
|---|---|
| Identificador | CU-31 |
| Nombre | Gestionar usuarios, roles y asignación de clientes |
| Objetivo | Administrar las cuentas de los empleados del sistema, definiendo su nivel de acceso (rol) y qué cartera de clientes tienen asignada. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- El actor debe estar autenticado con rol de Administrador o superior.

#### Flujo principal
1. El actor accede a la sección de gestión de usuarios.
2. El actor selecciona crear o editar un usuario.
3. El sistema despliega el formulario de datos, rol y asignación de clientes.
4. El actor completa los datos.
5. El sistema valida y guarda la configuración.

#### Flujos alternativos
**A1. Suspender usuario**
1. El actor cambia el estado del usuario a inactivo y reasigna su cartera de clientes.

#### Flujos de excepción
**E1. Duplicidad de correo electrónico**
1. El sistema detecta que el correo ingresado ya pertenece a otro usuario y bloquea la creación.

#### Postcondiciones
- El sistema cuenta con un usuario actualizado con nuevos permisos o clientes.

---

### CU-32 - Ejecutar acción masiva

| Campo | Contenido |
|---|---|
| Identificador | CU-32 |
| Nombre | Ejecutar acción masiva |
| Objetivo | Permitir la aplicación de cambios o procesos sobre un volumen alto de registros simultáneamente para ahorrar tiempo. |
| Actor principal | Administrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- Debe existir un conjunto de datos filtrado o seleccionado.

#### Flujo principal
1. El actor selecciona un conjunto de registros (ej. facturas).
2. El sistema habilita el menú de "Acciones masivas".
3. El actor selecciona la acción deseada (ej. cambiar estado).
4. El sistema pide confirmación.
5. El sistema procesa la acción sobre todos los registros en segundo plano.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Fallo parcial en la ejecución**
1. El sistema encuentra errores en algunos registros, aplica la acción solo a los válidos y muestra un reporte de fallos.

#### Postcondiciones
- Múltiples registros del sistema han sido modificados simultáneamente.

---

### CU-33 - Consultar monitorización y métricas

| Campo | Contenido |
|---|---|
| Identificador | CU-33 |
| Nombre | Consultar monitorización y métricas |
| Objetivo | Proporcionar una visión técnica y de rendimiento sobre la salud del sistema y uso de recursos. |
| Actor principal | Administrador |
| Actores secundarios | Planificador del sistema |

#### Precondiciones
- El Planificador del sistema debe estar recolectando datos.

#### Flujo principal
1. El actor navega a la sección de monitorización.
2. El sistema solicita al Planificador del sistema las métricas actualizadas (CPU, memoria, errores).
3. El sistema renderiza las gráficas técnicas.
4. El actor analiza la información.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Pérdida de conexión con el Planificador**
1. El sistema no puede recuperar los datos y muestra una advertencia de indisponibilidad.

#### Postcondiciones
- El actor obtiene un diagnóstico visual del estado de salud del servidor.

---

### CU-34 - Consultar registro de auditoría

| Campo | Contenido |
|---|---|
| Identificador | CU-34 |
| Nombre | Consultar registro de auditoría |
| Objetivo | Garantizar la trazabilidad revisando el historial inmutable de acciones críticas de los usuarios. |
| Actor principal | Superadministrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- El sistema de auditoría debe estar activo registrando eventos.

#### Flujo principal
1. El actor accede al módulo de registro de auditoría.
2. El actor introduce parámetros de búsqueda (ej. ID de usuario o fecha).
3. El sistema filtra los registros según los criterios.
4. El actor visualiza el detalle técnico del cambio (estado anterior vs. nuevo).

#### Flujos alternativos
**A1. Exportación del registro**
1. El actor exporta los registros a un archivo CSV/PDF para revisión externa.

#### Flujos de excepción
- No aplica.

#### Postcondiciones
- El actor obtiene trazabilidad exacta de las manipulaciones en el sistema.

---

### CU-35 - Configurar facturación y tarifas

| Campo | Contenido |
|---|---|
| Identificador | CU-35 |
| Nombre | Configurar facturación y tarifas |
| Objetivo | Parametrizar las reglas de negocio base: series de facturación, impuestos y el catálogo de tarifas disponibles. |
| Actor principal | Superadministrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- El actor tiene permisos de Superadministrador.

#### Flujo principal
1. El actor entra al menú de "Configuración del negocio".
2. El actor selecciona la sección de Catálogo de Tarifas y añade o edita una tarifa base.
3. El sistema valida que los importes sean correctos.
4. El sistema guarda la nueva configuración y actualiza el listado maestro.

#### Flujos alternativos
**A1. Cambio de serie de facturación**
1. El actor cambia el prefijo numérico de las facturas para el nuevo año fiscal.

#### Flujos de excepción
**E1. Modificación de tarifa en uso**
1. El sistema bloquea el borrado de una tarifa si ya está asignada a clientes activos.

#### Postcondiciones
- Las reglas financieras base del sistema quedan establecidas para las futuras emisiones.

---

### CU-36 - Configurar recordatorios y funciones inteligentes

| Campo | Contenido |
|---|---|
| Identificador | CU-36 |
| Nombre | Configurar recordatorios y funciones inteligentes |
| Objetivo | Establecer el comportamiento del motor automático de notificaciones (frecuencias de recordatorios de impago). |
| Actor principal | Superadministrador |
| Actores secundarios | Ninguno |

#### Precondiciones
- Acceso con credenciales de Superadministrador.

#### Flujo principal
1. El actor accede al panel de automatizaciones.
2. El actor modifica el cronograma de recordatorios (ej. "Avisar a los 3 días").
3. El sistema valida las reglas lógicas (evitando solapamientos).
4. El sistema persiste la nueva configuración en el motor de automatización.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Conflicto temporal**
1. El sistema detecta una configuración incongruente (ej. aviso 2 programado antes que el aviso 1) e impide guardar.

#### Postcondiciones
- El Planificador altera su comportamiento futuro de acuerdo a las nuevas reglas.

---

### CU-37 - Consultar datos y operar por API

| Campo | Contenido |
|---|---|
| Identificador | CU-37 |
| Nombre | Consultar datos y operar por API |
| Objetivo | Proveer una interfaz programática (API) para que otros sistemas empresariales puedan sincronizar datos con Turbine. |
| Actor principal | Sistema externo |
| Actores secundarios | Ninguno |

#### Precondiciones
- El Sistema externo dispone de un token de API válido.

#### Flujo principal
1. El Sistema externo realiza una petición HTTP a la API de Turbine.
2. El sistema verifica la validez del token y los permisos.
3. El sistema procesa la solicitud (lectura o escritura).
4. El sistema devuelve un código HTTP 200 (OK) junto con los datos en formato JSON.

#### Flujos alternativos
- No aplica.

#### Flujos de excepción
**E1. Token inválido**
1. El sistema rechaza la petición con HTTP 401 (Unauthorized).

#### Postcondiciones
- El Sistema externo ha interactuado con éxito con la base de datos de Turbine.
