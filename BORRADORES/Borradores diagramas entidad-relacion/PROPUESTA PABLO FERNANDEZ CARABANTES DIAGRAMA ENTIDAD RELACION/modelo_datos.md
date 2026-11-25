# Modelo físico de datos

## Alcance
Diagrama entidad-relación (modelo físico) del sistema de facturación de Turbine (Grupo Jirafas, Entrega 2), hecho en sql developer. Se hace teniendo en cuenta el diagrama de clases una vez acordado y puesto en comun, y la Entrega 1. Este recoge las entidades, atributos y relaciones necesarios para los 36 casos de uso.

| Bloque | Tablas |
|---|---|
| A · Clientes y contactos | CLIENTE, CONTACTO, CLIENTE_CONTACTO, ETIQUETA, CLIENTE_ETIQUETA, FAVORITO, TAREA, EXCEPCION_COMERCIAL, IMPORTACION_CSV, FILA_IMPORTACION |
| B · Suscripciones, tarifas y descuentos | SUSCRIPCION, REVISION_TARIFA_ANUAL, SOLICITUD_DESCUENTO |
| C · Facturación | FACTURA, APROBACION_FACTURA, LINEA_FACTURA, FILTRO_GUARDADO, OPERACION_EXCEPCIONAL |
| D · Cobros y comunicaciones | MOVIMIENTO_COBRO, CONCILIACION, PLANTILLA_COMUNICACION, COMUNICACION, SUSPENSION_RECORDATORIOS |
| E · Seguimiento, consulta e informes | CENTRO_COSTE, REGLA_ALERTA, INCIDENCIA, ADJUNTO, COMENTARIO, MENCION, NOTIFICACION, INFORME, OBJETIVO_FACTURACION |
| F · Administración, seguridad y sistema | USUARIO, EVENTO_AUDITORIA, ACCION_MASIVA, EJECUCION_TAREA, CONFIGURACION_SISTEMA, SERIE_FACTURACION, IMPUESTO, RANGO_TARIFA, SOLICITUD_EXTERNA |


## Justificación del modelo
Paso del diagrama de clases a tablas.
- Cada clase es una tabla y cada atributo una columna (SolicitudDescuento → SOLICITUD_DESCUENTO, fechaEmision → fecha_emision). Cada tabla tiene una clave primaria técnica id_<tabla> autonumérica; las tablas intermedias usan como clave las dos foráneas.
- Herencia de roles una tabla. Usuario <- UsuarioOperativo <- Administrador <- Superadministrador es USUARIO con la columna rol (OPERATIVO, ADMIN, SUPERADMIN): las subclases casi no añaden atributos y cambiar de rol (cambiarRol()) es cambiar una columna. Las relaciones con Administrador (aprobador, gestiona…) son claves foráneas a USUARIO.
- Factura y rectificativa → una tabla. FACTURA guarda las dos: una fila es rectificativa si tiene id_factura_original (relación rectificaA) y motivo_rectificacion. Comparten numeración, PDF y cobros.
- Listas. Cliente.etiquetas → ETIQUETA + CLIENTE_ETIQUETA; Incidencia.adjuntos → ADJUNTO. Una lista no cabe en una columna.
- No son tablas. Las interfaces SistemaPagos y CanalEnvio (no guardan datos; el resultado queda en MOVIMIENTO_COBRO.fuente y COMUNICACION.canal) y las operaciones de las clases.

Relaciones principales (cardinalidad padre — hija):
- `CLIENTE (1)` — `SUSCRIPCION`, `FACTURA`, `TAREA`, `EXCEPCION_COMERCIAL`, `INCIDENCIA`, `REVISION_TARIFA_ANUAL`, `SOLICITUD_DESCUENTO (0..N)`: todo lo del cliente pertenece a un cliente concreto.
- `USUARIO (1)` — `CLIENTE (0..N)` mediante `id_responsable`: cada cliente tiene un responsable interno.
- `CLIENTE (N)` — `CONTACTO (N)` mediante `CLIENTE_CONTACTO` (con `tipo`): un contacto puede ser de varios clientes con un papel distinto en cada uno (FR-04).
- `USUARIO (N)` — `CLIENTE (N)` mediante `FAVORITO`, y `COMENTARIO (N)` — `USUARIO (N)` mediante `MENCION`.
- `IMPORTACION_CSV (1)` — `FILA_IMPORTACION (1..N)`; `IMPORTACION_CSV (0..1)` — `CLIENTE (0..N)`: cliente creado o actualizado en una importación.
- `FACTURA (1)` — `LINEA_FACTURA (0..N)`: un borrador puede no tener líneas todavía (CU-10); para emitir se exige al menos una (CU-12).
- `SERIE_FACTURACION (0..1)` — `FACTURA (0..N)`: un borrador aún no tiene serie.
- `SUSCRIPCION (0..1)` — `FACTURA (0..N)` y `EJECUCION_TAREA (0..1)` — `FACTURA (0..N)`: solo las recurrentes tienen suscripción y ejecución del Planificador.
- `FACTURA (0..1)` — `FACTURA (0..N)` mediante `id_factura_original`: rectificativas de una factura.
- `FACTURA (1)` — `APROBACION_FACTURA (0..N)`: cada retención es una fila (CU-13 FA-1).
- `MOVIMIENTO_COBRO (N)` — `FACTURA (N)` mediante `CONCILIACION`, con importe, regla y reversión: un cobro puede repartirse entre facturas y una factura cobrarse en varios pagos (FR-21).
- `FACTURA (0..1)` — `COMUNICACION (0..N)`; `PLANTILLA_COMUNICACION (1)` — `COMUNICACION (0..N)`; `CONTACTO (0..1)` — `COMUNICACION (0..N)`.
- `INCIDENCIA (1)` — `COMENTARIO (0..N)` y `ADJUNTO (0..N)`; `FACTURA (0..1)` — `INCIDENCIA (0..N)`.
- `EXCEPCION_COMERCIAL (0..1)` — `SOLICITUD_DESCUENTO (0..1)`: clave foránea única, relación 1:1 (CU-01 FA-4).
- `USUARIO (1)` — `OBJETIVO_FACTURACION (0..N)`: lo gestiona un Administrador (CU-28).
- `CONFIGURACION_SISTEMA` no tiene claves foráneas: es una tabla de una sola fila y una clave hacia ella desde series, impuestos o rangos siempre valdría 1.

## Reglas y restricciones
Comprobadas por la base de datos:
- Tipos: importes NUMBER(15,2), nunca FLOAT (NFR-06); porcentajes NUMBER(5,2); fechas DATE y TIMESTAMP; booleanos NUMBER(1) con CHECK IN (0, 1); PDF y adjuntos BLOB.
- Estados y tipos: CHECK (… IN (…)) con los valores de las enumeraciones del diagrama de clases.
- Únicos: correo corporativo del usuario, código de serie, nombre de impuesto, etiqueta y centro de coste, periodo de un objetivo, plantilla por tipo + idioma + versión.
- uq_factura_serie_numero: número de factura único dentro de su serie (BR-10).
- uq_factura_periodo: una sola mensualidad por suscripción y periodo, sin contar rectificativas (NFR-15, CU-11).
- ck_factura_numero: una factura emitida tiene número, serie y fecha de emisión; un borrador puede no tenerlos.
- ck_factura_recurrente y ck_factura_rectificativa: una recurrente tiene suscripción y periodo; una rectificativa tiene factura original y motivo.
- uq_aprob_fact_abierta: como mucho una retención abierta por factura (CU-13 FE-2); ck_aprob_fact_motivo: rechazar o pedir información exige motivo.
- Separación de funciones (BR-12): ck_desc_separacion, ck_aprob_fact_separacion, ck_operacion_separacion, ck_accion_aprobador (aprobador ≠ solicitante).
- uq_mov_evento: un evento de cobro (fuente + id externo) no se registra dos veces (CU-16 FE-1).
- ck_conc_reversion y uq_conc_activa: una conciliación revertida guarda quién, cuándo y por qué; la misma pareja cobro–factura no está conciliada dos veces a la vez.
- Coherencia de fechas e importes: vencimiento ≥ emisión, cantidad > 0, descuento entre 0 y 100, rango de tarifa mínimo ≤ máximo, etc.
- Ninguna clave foránea borra en cascada: una factura emitida, un cobro o un contacto no desaparecen con su padre (BR-09, BR-19).
- ck_usuario_activacion: un usuario invitado puede no tener contraseña todavía; al activarse debe tenerla (CU-31). ck_usuario_permiso_rol: solo un ADMIN tiene el permiso de gestionar usuarios (FR-07).
- ck_susc_pausa y ck_susc_baja: una suscripción en pausa guarda motivo y fecha de inicio (FR-16); una cancelada, fecha y motivo de baja (CU-05 FA-2).
- ck_desc_decision y ck_desc_motivo: un descuento resuelto tiene aprobador y fecha; rechazarlo o aprobarlo con condiciones exige motivo (CU-08 FA-1, FA-2).
- ck_factura_emitida_datos: una factura emitida conserva los datos fiscales del momento de emitir, salvo las migradas (CU-12, BR-09).
- ck_factura_importes: los importes no son negativos, salvo en una rectificativa (FR-45).
- ck_operacion_aprobada: una operación excepcional aprobada o ejecutada tiene aprobador (BR-13).
- ck_conc_origen: una conciliación manual guarda quién la hizo; una automática, la regla aplicada (FR-22).

No las valida el modelo (las controla la aplicación):
- Una factura emitida no se modifica (BR-09, FR-14); se corrige con una rectificativa.
- Quién puede decidir según su rol: aprobar descuentos y facturas retenidas solo Administrador; un descuento ESCALADA solo el Superadministrador (CU-09).
- El registro de auditoría no se edita ni se borra (NFR-09).
- Un usuario operativo solo trabaja con sus clientes asignados (NFR-07).
- El correo de un usuario pertenece al dominio corporativo configurado (FR-06).
- saldo_pendiente se recalcula con cada conciliación o reversión (FR-21).

## Trazabilidad
| Requisitos/casos | Tablas/columnas | Observación |
|---|---|---|
| FR-03, FR-04, FR-33 · CU-01 | CLIENTE, CONTACTO, CLIENTE_CONTACTO.tipo, ETIQUETA, CLIENTE_ETIQUETA, EXCEPCION_COMERCIAL | Ficha del cliente, contactos compartidos, etiquetas y excepciones comerciales. |
| FR-08 · CU-03 | IMPORTACION_CSV, FILA_IMPORTACION, CLIENTE.id_importacion, FACTURA.migrada | Resumen de cada importación y resultado de cada fila. |
| FR-32 · CU-04 | TAREA | Tareas del cliente con quién y cuándo se completaron. |
| FR-09, FR-16 · CU-05 | SUSCRIPCION (estado, pausa y baja) | Pausa y baja con motivo y fechas. |
| FR-10, FR-17 · CU-06 | REVISION_TARIFA_ANUAL, RANGO_TARIFA | Revisión anual con rango propuesto y decisión. |
| FR-18 · CU-07–CU-09 | SOLICITUD_DESCUENTO | Solicitud, aprobación y escalado del descuento. |
| FR-02, FR-13 · CU-10 | FACTURA (estado BORRADOR), LINEA_FACTURA, IMPUESTO | Borrador editable con varias líneas. |
| FR-11, NFR-15 · CU-11 | FACTURA.periodo_facturado, FACTURA.id_ejecucion, EJECUCION_TAREA | Mensualidades sin duplicar y registro de cada ejecución. |
| FR-01, FR-12, BR-09, BR-10 · CU-12 | FACTURA (numero, id_serie, documento_pdf, datos_fiscales_emision), SERIE_FACTURACION | Número único por serie, PDF conservado y datos fiscales del momento de emitir. |
| FR-13, FR-18, BR-12 · CU-13 | APROBACION_FACTURA, FACTURA.retenida | Historial de retenciones con solicitante y aprobador distintos. |
| FR-19, FR-45 · CU-14 | OPERACION_EXCEPCIONAL, FACTURA.id_factura_original, motivo_rectificacion | Rectificar, anular, incobrable o cancelar con motivo y aprobación. |
| FR-28 · CU-15 | FILTRO_GUARDADO, FAVORITO | Filtros guardados y clientes favoritos. |
| FR-15, FR-21, FR-22 · CU-16, CU-17 | MOVIMIENTO_COBRO, CONCILIACION, FACTURA.saldo_pendiente | Cobros sin duplicar, conciliación parcial y reversión trazada. |
| FR-23, FR-26, FR-46 · CU-18, CU-19, CU-22 | COMUNICACION, PLANTILLA_COMUNICACION | Cada intento con canal, resultado y versión de plantilla. |
| FR-05 · CU-20, CU-21 | CONFIGURACION_SISTEMA (días de recordatorio), CLIENTE.vencimiento_pactado_dias, SUSPENSION_RECORDATORIOS | Calendario de recordatorios y suspensión por factura. |
| FR-24, FR-42 · CU-23, CU-24 | NOTIFICACION, REGLA_ALERTA, USUARIO.preferencias_notificacion | Avisos leídos y resueltos por separado; reglas de alerta. |
| FR-34, FR-36, BR-20 · CU-25 | INCIDENCIA, COMENTARIO, MENCION, ADJUNTO | Comentarios internos: no tienen relación con COMUNICACION. |
| FR-25, FR-37 · CU-26 | INFORME | Informes con filtros, formato y caducidad. |
| FR-29, FR-40, FR-41 · CU-27, CU-28 | OBJETIVO_FACTURACION, CENTRO_COSTE, CLIENTE.id_centro_coste, FACTURA.id_centro_coste | El dashboard se calcula con consultas; objetivos y centros de coste se guardan. |
| FR-06, FR-07, NFR-08 · CU-30, CU-31 | USUARIO (correo_corporativo, rol, estado, intentos_fallidos, bloqueado_hasta) | Acceso con correo corporativo, roles y bloqueo. |
| FR-31 · CU-32 | ACCION_MASIVA | Alcance y aprobación de acciones de alto impacto. |
| FR-38, FR-48 · CU-33 | EJECUCION_TAREA, COMUNICACION.estado | Monitorización de tareas y cola de correos. |
| NFR-09 · CU-34 | EVENTO_AUDITORIA | Valores anteriores y nuevos, autor y errores técnicos. |
| FR-01, FR-17, FR-39 · CU-35, CU-36 | CONFIGURACION_SISTEMA, SERIE_FACTURACION, IMPUESTO, RANGO_TARIFA | Parámetros del Superadministrador. |
| FR-49, BR-21 · CU-37 | SOLICITUD_EXTERNA | Lo que llega por la API queda pendiente de revisión. |

## Decisiones abiertas
- Herencia en una sola tabla. Se descartó una tabla por subclase (ADMINISTRADOR, SUPERADMINISTRADOR…) porque casi no tienen atributos propios y complicaría cambiar de rol.
- saldo_pendiente guardado. Es un atributo derivado; se guarda para consultar rápido el dashboard y la pantalla diaria (NFR-12). La alternativa es calcularlo siempre con una consulta sobre CONCILIACION.
- Parámetros sin valor en la Entrega 1. El umbral de descuento, el umbral de importe alto, el dominio corporativo, las series y los impuestos son configurables (CU-35), pero la Entrega 1 no da sus valores. Pregunta al cliente: ¿qué valores iniciales usar?
- Reglas en la aplicación. Las reglas de la lista «No las valida el modelo» podrían reforzarse en la base de datos con disparadores; se dejan en la aplicación para mantener el modelo sencillo.
- Datos fiscales de la emisión se guardan como texto; si el cliente necesitara consultarlos por campos, se separarían en columnas.
- Rectificativas con importe negativo. La Entrega 1 habla de notas de crédito o rectificativas (FR-45), pero no dice si su importe es negativo o si se registra en positivo como abono. Se permite el negativo solo en rectificativas.
