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
