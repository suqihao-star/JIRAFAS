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
