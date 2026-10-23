# Bloque D. Cobros y comunicaciones

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