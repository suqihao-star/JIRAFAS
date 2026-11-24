# Diagramas UML de secuencia
Sistema de facturación de Turbine · Grupo JIRAFAS · Entrega 2

## Selección de escenarios
Se seleccionan los **siete casos de uso más importantes** del sistema. Juntos recorren el ciclo completo del negocio:

**alta del cliente → aprobación de condiciones económicas → facturación (puntual y recurrente) → cobro → conciliación → reclamación de la deuda.**

Concentran las reglas de negocio críticas: aprobaciones con umbral y separación de funciones, numeración única, inmutabilidad de la factura emitida, idempotencia de emisiones y cobros, y auditoría. También incluyen a los actores automáticos y externos de los escenarios seleccionados: Planificador, sistema de pagos y proveedor de correo (este último a través de CU-18).

Base: especificación de la Entrega 1 y diagrama de clases simplificado (propuesta nueva de Pablo Fernández Carabantes). No se pretende representar todos los casos de uso. Los relacionados con los elegidos aparecen como fragmentos `ref`: CU-07, CU-09, CU-12, CU-13, CU-18 y CU-19.

Se entregan **siete diagramas principales**, uno por caso de uso. Deshacer una conciliación (CU-17 FA-3) es una interacción independiente, que vale tanto para conciliaciones manuales como para las automáticas de CU-16. Se incluye como **anexo complementario** (`anexo/SEC_06b`), fuera de la selección principal.

| Diagrama | Caso de uso | Justificación |
|---|---|---|
| [SEC_01_CU-01_alta_cliente.puml](SEC_01_CU-01_alta_cliente.puml) | CU-01 — Alta de cliente y contactos | Punto de partida: sin cliente no hay suscripción ni factura. Duplicados, datos fiscales incompletos, prorrateo y excepciones comerciales. El escenario es el **alta**: la edición, la gestión de contactos, las etiquetas y los favoritos (FA-1/2/3, FE-3) quedan fuera. |
| [SEC_02_CU-08_aprobar_descuento.puml](SEC_02_CU-08_aprobar_descuento.puml) | CU-08 — Aprobar descuento | Circuito de aprobación económica: umbral configurable, separación de funciones (BR-12), aprobación condicionada, rechazo y escalado a CU-09. |
| [SEC_03_CU-11_generar_facturas_recurrentes.puml](SEC_03_CU-11_generar_facturas_recurrentes.puml) | CU-11 — Generar facturas recurrentes | Proceso automático mensual: elegibilidad, excepciones, prorrateo, recuperación sin duplicados y emisión mediante CU-12. |
| [SEC_04_CU-12_emitir_factura.puml](SEC_04_CU-12_emitir_factura.puml) | CU-12 — Emitir factura | Núcleo del sistema: validación fiscal, vista previa, retención (CU-13), numeración única, PDF, inmutabilidad y envío (CU-18). |
| [SEC_05_CU-16_registrar_cobro.puml](SEC_05_CU-16_registrar_cobro.puml) | CU-16 — Registrar movimiento de cobro | Integración con Stripe/Revolut, por notificación o por consulta periódica: duplicados, conciliación automática y cobros sin referencia. |
| [SEC_06_CU-17_conciliar_pagos.puml](SEC_06_CU-17_conciliar_pagos.puml) | CU-17 — Conciliar pagos (manual) | Reparto entre facturas, exceso de importe, concurrencia y actualización de saldos. |
| *Anexo:* [SEC_06b_CU-17_deshacer_conciliacion.puml](anexo/SEC_06b_CU-17_deshacer_conciliacion.puml) | CU-17 FA-3 — Deshacer una conciliación | Reversión auditada, sin borrar el histórico, de conciliaciones manuales o automáticas (FR-22). |
| [SEC_07_CU-20_recordatorios_e_impago.puml](SEC_07_CU-20_recordatorios_e_impago.puml) | CU-20 — Ejecutar flujo de recordatorios e impago | Reclamación automática de la deuda: cadencia, vencimiento pactado, deuda parcial, suspensión y avisos periódicos sin duplicar. |

## Descripción de los escenarios

### CU-01 — Alta de cliente y contactos
1. Se comprueba el permiso del usuario. `:Sistema` autocompleta los valores habituales a partir de `ConfiguracionSistema`.
2. Al guardar, se vuelve a comprobar el permiso y se valida el formato y el responsable interno (FE-2). Se crea el `Cliente` como candidato y se comprueban duplicados con `comprobarDuplicado()`. Si hay un posible duplicado, se avisa sin fusionar nada y el candidato se descarta (FE-1).
3. Si falta el identificador fiscal, se marca `datosFiscalesIncompletos` (FA-5). Si el alta es a mitad de mes, se muestra el prorrateo antes de confirmar.
4. Se asigna el responsable interno y `darDeAlta()` deja el cliente ACTIVO o, si la fecha de inicio es futura, PENDIENTE_ACTIVACION. Cada contacto se reutiliza si ya existe (un contacto puede pertenecer a varios clientes, FR-04) o se crea, y se vincula con su `ClienteContacto` (tipo). Una `ExcepcionComercial` con efecto económico remite a CU-07 (FA-4).
5. Se registra el `EventoAuditoria` y se muestra la ficha.

### CU-08 — Aprobar descuento
1. El Administrador abre la solicitud. Se comprueba su permiso de aprobación y, si la solicitud ya está resuelta, se bloquea (FE-1).
2. `superaUmbral()` determina si la decisión le corresponde. Si supera el umbral, dentro de una sección crítica se revalidan el permiso, el estado y el umbral. Si siguen vigentes, se escala con `escalar()`, se avisa al Superadministrador y continúa CU-09 (FA-3/FE-2).
3. Si no, decide. Al confirmar, dentro de una sección crítica, se revalidan la autorización, el estado, el umbral y la separación de funciones (BR-12). Una decisión no válida, o que ahora supera el umbral, se bloquea sin efectos ni notificación.
4. Rechazo: `rechazar(motivo)` (FA-1). Aprobación: `Administrador.aprobarDescuento(s)` → `aprobar()`. Si es condicionada (FA-2), la condición se guarda en `motivoDecision`. El descuento aprobado no modifica la tarifa del cliente: se aplica a las facturas de los periodos incluidos en su `fechaVigencia` mediante la asociación `Factura.descuentoAplicado` (CU-11). Las facturas emitidas no cambian.
5. Las decisiones con efecto se notifican al solicitante y se auditan.

### CU-11 — Generar facturas recurrentes
1. El Planificador inicia la ejecución del periodo y se crea una `EjecucionTarea`.
2. Por cada `Suscripcion` se llama a `esFacturable(periodo)`. Las pausadas, canceladas o pendientes de activación se omiten (FA-1).
3. Se consultan las excepciones (FA-4). Los periodos exentos se omiten y las excepciones pendientes no se aplican (se avisa al responsable). Se calcula el prorrateo si procede (FA-2).
4. En una sección crítica (una obligación por suscripción y periodo) se busca la factura del periodo. Si ya tiene emisión definitiva (EMITIDA, ENVIADA, VENCIDA, PAGADA…), se omite (FA-3). Si quedó pendiente de una ejecución interrumpida, se reutiliza. Si no existe, se crea.
5. Si la mensualidad no tiene emisión definitiva, se fijan su `fechaVencimiento` (pactado o, si no hay, general) y, si existe un descuento aprobado y vigente, `descuentoAplicado`. Después se crea la `LineaFactura` con la tarifa vigente o prorrateada (FA-2) y su `Impuesto`, se calculan los totales y se emite mediante CU-12. Si faltan datos o aprobaciones, se crea una `Incidencia` y el lote continúa (FE-1).
6. Se registran emitidas, retenidas, pendientes y errores (FE-2), y se continúa con el lote.

### CU-12 — Emitir factura
1. El usuario solicita emitir un borrador, o CU-11 solicita la emisión de una mensualidad (FA-2). En este segundo caso, la llamada entra desde CU-11, no directamente desde el Planificador.
2. Se comprueban la autorización, el estado (FE-2) y los datos fiscales (FE-1). Cada comprobación tiene su propio `break` y responde al origen correspondiente, sin numerar.
3. Se calculan los totales. En la emisión manual se muestra la vista previa.
4. Si hay un cambio sensible o un importe alto sin aprobar, la factura queda retenida y se notifica (FA-1 → CU-13). Si CU-13 la aprueba, la emisión se retoma en la numeración. Si la rechaza, vuelve a BORRADOR.
5. En una sección crítica se revalidan la autorización, el estado, los datos fiscales y las condiciones económicas aprobadas, y se genera el PDF. Con `getNumero()` se comprueba si la factura ya tiene número. En el primer intento se asigna el correlativo (`asignarSiguienteNumero()` → `setNumero()`); en un reintento tras un fallo del PDF se reutiliza el ya reservado, sin consumir otro (FE-3).
6. Tras una emisión válida se audita y se envía mediante CU-18. El paso a ENVIADA se hace en una sección crítica y solo si la factura sigue EMITIDA, para no pisar un estado de cobro si el pago llegó a la vez. Un fallo de envío conserva el número y el PDF (FA-3).

### CU-16 — Registrar movimiento de cobro
1. El sistema de pagos notifica un cobro, o el Planificador consulta los nuevos con `consultarPagos()` dentro de una `EjecucionTarea` (FA-1). Si la integración falla, el error queda en la ejecución, visible en la monitorización, y se reintenta (FE-2).
2. Por cada movimiento se crea el `MovimientoCobro`. En una sección crítica se descarta si `esDuplicado()` (FE-1) y se registra y concilia. Esa sección crítica también da acceso exclusivo al saldo de la factura candidata, que se vuelve a leer antes de conciliar, igual que en la conciliación manual y la reversión.
3. Si la referencia coincide claramente con una factura cobrable, en la misma moneda y con importe positivo no superior al saldo, se crea una `Conciliacion` AUTOMATICA y la factura pasa a PAGADA o PARCIALMENTE_CONCILIADA (CU-17 FA-1).
4. Si no, el movimiento queda PENDIENTE, asignado al responsable del cliente o, si no se identifica el cliente, a una persona designada, y aparece en su pantalla de trabajo diario. Si el importe supera el saldo, se señala la diferencia (FA-2, FR-21).

### CU-17 — Conciliar pagos (manual) · SEC_06
1. Los movimientos y las facturas que se muestran se filtran según el ámbito autorizado del usuario. El usuario selecciona un movimiento pendiente. Si ya está conciliado, se impide asociarlo de nuevo (FE-2).
2. Se comprueban, por este orden: la asignación del cliente, que ningún importe supere el saldo pendiente (FE-1; el usuario corrige la asociación o deja la diferencia para revisión), que el reparto coincida con el importe disponible del movimiento (FA-2), y la moneda y el estado cobrable de cada factura.
3. En una sección crítica se revalidan los saldos, se crea cada `Conciliacion` con `conciliarPago(m, f)` y se le fija el importe validado (la operación del modelo no lo recibe). Después se actualizan los saldos y estados. El movimiento queda CONCILIADO solo si todo su importe está asignado.

### Anexo — CU-17 FA-3 Deshacer una conciliación · anexo/SEC_06b
1. El usuario indica la conciliación (manual o automática) y el motivo. Se comprueba su permiso sobre el cliente.
2. En una sección crítica se revalida que siga vigente, se llama a `revertir(motivo)` sin borrar nada y se recalcula el saldo de la factura.
3. El estado del `MovimientoCobro` se recalcula según las conciliaciones que le queden vigentes: no pasa entero a PENDIENTE si conserva otras asociaciones válidas.

### CU-20 — Ejecutar flujo de recordatorios e impago
1. El Planificador inicia la ejecución diaria. Si la anterior quedó interrumpida, se registra (FE-2) y se revisa cada reserva que quedó abierta, comprobando con su clave si el aviso llegó a enviarse. Si se envió, se marca como enviado. Si no, se libera la reserva. Si el resultado es incierto, queda pendiente de revisión y no se reenvía a ciegas.
2. Se lee la cadencia de `ConfiguracionSistema` y se seleccionan las facturas con deuda, también las parcialmente conciliadas y las de clientes dados de baja (FA-1).
3. Para cada factura se calcula el aviso pendiente a partir de su `fechaVencimiento`, que se fijó al emitirla con el vencimiento pactado o, si no hay, el general. Cada aviso se identifica por **factura, fase y fecha programada**, y está pendiente si su fecha ya llegó y no se ha enviado. Así los avisos de impago se repiten cada `frecuenciaAvisoImpagoDias` (FR-05). Si se acumulan varios atrasados, solo se envía el más reciente, para no mandar varios avisos de golpe.
4. Se omiten las suspendidas (FA-3) y las pagadas (FA-2). Si falta un contacto activo de tipo IMPAGOS, se crean una `Incidencia` y una `Notificacion` (FE-3).
5. El aviso se reserva en una sección crítica con su clave (factura, fase, fecha programada). El envío se hace mediante CU-18 fuera de la sección crítica. Si se completa, el aviso se marca como enviado. Un fallo técnico deja el intento recuperable; un rebote continúa en CU-19 (FE-1). El resumen queda en `EjecucionTarea`.

## Trazabilidad
| Diagrama | Caso de uso | Participantes / responsabilidades | Requisitos funcionales relacionados |
|---|---|---|---|
| SEC-01 | CU-01 (alta) | Usuario operativo; `Cliente` (`darDeAlta`, `comprobarDuplicado`), `Contacto`, `ClienteContacto`, `ExcepcionComercial`, `ConfiguracionSistema`, `EventoAuditoria` | FR-03, 04, 11, 27, 30, 43, 47 |
| SEC-02 | CU-08 | Administrador; `Administrador.aprobarDescuento`, `SolicitudDescuento` (`superaUmbral`, `aprobar`, `rechazar`, `escalar`, `fechaVigencia`), `Notificacion`, `EventoAuditoria` | FR-18, 24 |
| SEC-03 | CU-11 | Planificador; `Suscripcion` (`esFacturable`, `precioVigente`), `Cliente`, `ExcepcionComercial`, `ConfiguracionSistema`, `Factura` (`calcularTotales`, `descuentoAplicado`), `LineaFactura`, `Notificacion`, `Incidencia`, `EjecucionTarea` | FR-01, 09, 11, 13, 16, 47, 48 |
| SEC-04 | CU-12 | Usuario operativo, CU-11; `Factura` (`validarDatosFiscales`, `calcularTotales`, `emitir`, `generarPDF`), `LineaFactura.calcularImporte`, `Cliente`, `ConfiguracionSistema`, `SerieFacturacion.asignarSiguienteNumero`, `Notificacion`, `EventoAuditoria` | FR-01, 12, 13, 14, 18, 19, 20, 46 |
| SEC-05 | CU-16 | Sistema de pagos, Planificador; `SistemaPagos.consultarPagos`, `MovimientoCobro.esDuplicado`, `Conciliacion`, `Factura`, `Cliente`, `EjecucionTarea`, `EventoAuditoria` | FR-15, 19, 21, 48, 50 |
| SEC-06 | CU-17 | Usuario operativo; `UsuarioOperativo.conciliarPago`, `MovimientoCobro`, `Factura`, `Conciliacion`, `EventoAuditoria` | FR-15, 19, 21 |
| SEC-06b (anexo) | CU-17 FA-3 | Usuario operativo; `Conciliacion.revertir`, `Factura`, `MovimientoCobro`, `EventoAuditoria` | FR-19, 22 |
| SEC-07 | CU-20 | Planificador; `ConfiguracionSistema`, `Factura`, `Cliente`, `Incidencia`, `Notificacion`, `EjecucionTarea` | FR-05, 09, 23, 48 |

## Consistencia
- **Modelo de referencia:** `diagrama_clases_simplificado.puml`. Todas las líneas de vida, salvo los actores y `:Sistema`, tienen como tipo una clase o interfaz de ese modelo (`SistemaPagos` es una interfaz). Las **operaciones de negocio** invocadas (`darDeAlta`, `comprobarDuplicado`, `superaUmbral`, `aprobar`, `rechazar`, `escalar`, `esFacturable`, `calcularTotales`, `validarDatosFiscales`, `emitir`, `generarPDF`, `asignarSiguienteNumero`, `consultarPagos`, `esDuplicado`, `conciliarPago`, `revertir`…) están declaradas con ese nombre en la clase receptora. Lo comprueba un validador estático.
- **`:Sistema`:** es el estereotipo «control» y hace de controlador de la capa de aplicación (interfaz y servicios), no de clase nueva del dominio. Autoriza, coordina y delimita transacciones. Además aplica algunas reglas de cálculo (prorrateo, cadencia de avisos, actualización de saldos) porque el modelo de clases, que es fijo, no ofrece una operación de dominio para ellas. Ver «Diferencias». Sus automensajes (`comprobarAutorizacion`, `validarFormato`, `buscarFacturaPorReferencia`, `calcularAvisoDebido`…) son responsabilidades de esa capa.
- **Accesos a atributos y asociaciones:** los `get…()`/`set…()` y los constructores `<<create>>` no se dibujan en el diagrama de clases. Se consideran **implícitos**: son accesos conceptuales a atributos privados y a extremos de asociación, no operaciones declaradas. Hay tres matices:
  - `getExcepciones()`, `getSuspensiones()` y `getConciliaciones()` recorren asociaciones (composición o asociación sin flecha) cuya navegabilidad el modelo no fija. Se asume navegable desde `Cliente`, `Factura` y `MovimientoCobro`.
  - `getContactos()` devuelve los contactos con el tipo guardado en la clase asociación `ClienteContacto`. El filtrado por tipo IMPAGOS se hace sobre ese atributo.
  - Los identificadores usados en los mensajes (`c.id`, `s.id`, `f.id`, `m.id`…) representan la identidad del objeto, no un atributo del modelo. En el modelo solo `Cliente` y `Usuario` declaran `id`.
- **`emitir()`:** en el modelo devuelve `void`. Las respuestas «factura emitida» y «emisión no confirmada» representan su terminación normal o con fallo (FE-3), no un valor de retorno.
- **Creación:** los objetos nuevos se crean con `create` en el punto exacto de su creación, y el mensaje `<<create>>` usa la flecha discontinua de punta abierta (UML 2.5).
- **Respuestas:** las respuestas van siempre a quien inició la interacción. CU-12 y CU-16 tienen dos orígenes posibles y lo distinguen con `alt`. En CU-12, la emisión recurrente entra como mensaje desde CU-11.
- **Fragmentos:** las guardas se escriben entre corchetes. `ref` remite a otra interacción (caso de uso incluido o extendido). `critical` marca una región atómica que no puede intercalarse con otras ejecuciones, sin fijar una tecnología de persistencia. En CU-12, FE-1 y FE-2 se comprueban antes de la vista previa y se **revalidan** dentro de la sección crítica, porque otro intento concurrente puede haber cambiado la factura.
- **`EventoAuditoria`:** cada acción con efecto crea uno. Cubre la auditoría y la línea temporal del cliente (FR-43): el evento guarda la entidad y su identificador, y se vincula al cliente a través de ella.
- **Diferencias con el diagrama de clases** (propuestas para la puesta en común; no se modifica el diagrama de clases):
  1. **Cobro en `Factura`:** el cobro y su reversión se aplican desde `:Sistema` con `setSaldoPendiente()` + `setEstado()`. Por el principio de experto en información, debería hacerlo la propia `Factura` con `registrarCobro(importe)` y `revertirCobro(importe)`. Además, `UsuarioOperativo.conciliarPago(m, f)` no recibe el importe asignado: se propone `conciliarPago(m, f, importe)`.
  2. **Navegabilidad:** conviene fijarla en `Cliente → ExcepcionComercial`, `Factura → SuspensionRecordatorios` y `MovimientoCobro → Conciliacion`.
  3. **Estados sin documentar:** faltan en las notas los de `MovimientoCobro` (REGISTRADO, PENDIENTE, CONCILIADO) y los de `SolicitudDescuento` (PENDIENTE_APROBACION, ESCALADA, APROBADA, RECHAZADA).
  4. **Condición de aprobación:** `SolicitudDescuento` no tiene un atributo para la condición de una aprobación condicionada (CU-08 FA-2). Hoy se guarda en `motivoDecision`.
  5. **Avisos de recordatorio:** para garantizar un único envío por aviso, el modelo debería guardar qué aviso (fase y fecha programada) se envió de cada factura. Hoy solo se deduce de las `Comunicacion` enlazadas a la factura.
- **Limitaciones:** se han comprobado estáticamente los fragmentos, las activaciones y las clases y operaciones. No se ha ejecutado el renderizador PlantUML ni se dispone del diagrama de arquitectura definitivo (`arquitectura.md` sigue siendo la plantilla) para contrastarlo.
