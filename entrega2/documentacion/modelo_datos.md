# Modelo físico de datos

## Alcance
Almacenar los datos del sistema de facturación de Turbine (Grupo Jirafas, Entrega 2): clientes y contactos, suscripciones, tarifas y descuentos, facturas, cobros y comunicaciones, seguimiento e informes, y administración del sistema, para dar soporte a los 36 casos de uso de la Entrega 1 (CU-01 y CU-03 a CU-37). El modelo parte del diagrama de clases acordado y puesto en común por el grupo y tiene 41 tablas.

El diagrama completo está en `modelo_datos.puml` y también lo hemos dividido en seis diagramas, uno por bloque (`modelo_datos_bloque_A.puml` hasta `modelo_datos_bloque_F.puml`), para que se lea mejor.

Para leer el diagrama: las columnas con un punto negro delante son obligatorias (NOT NULL). PK indica la clave primaria, FK una clave foránea y UK un valor que no se puede repetir. En las relaciones, `||` significa uno obligatorio, `|o` cero o uno, `o{` cero o muchos y `o|` cero o uno. El texto de cada línea es el nombre de la columna que hace de clave foranea.

En los diagramas por bloque, las tablas que están fuera del recuadro pertenecen a otros bloques y solo muestran su clave primaria. Cada relación aparece en el bloque de la tabla que tiene la clave foranea.

## Justificación del modelo
- `CLIENTE (1)` -- `SUSCRIPCION`, `FACTURA`, `TAREA`, `EXCEPCION_COMERCIAL`, `INCIDENCIA`, `REVISION_TARIFA_ANUAL`, `SOLICITUD_DESCUENTO (0..N)`: un cliente puede no tener ninguno; cada uno pertenece a un cliente concreto.
- `USUARIO (1)` -- `CLIENTE (0..N)` mediante `id_responsable`: cada cliente tiene un responsable interno.
- `CLIENTE (N)` -- `CONTACTO (N)` mediante `CLIENTE_CONTACTO` (con `tipo`): un contacto puede ser de varios clientes con un papel distinto en cada uno (FR-04).
- `USUARIO (N)` -- `CLIENTE (N)` mediante `FAVORITO`, y `COMENTARIO (N)` -- `USUARIO (N)` mediante `MENCION`
- `CLIENTE (N)` -- `ETIQUETA (N)` mediante `CLIENTE_ETIQUETA`: las etiquetas del cliente son una lista y no caben en una columna.
- `IMPORTACION_CSV (1)` -- `FILA_IMPORTACION (1..N)`; `IMPORTACION_CSV (0..1)` -- `CLIENTE (0..N)`: cliente creado o actualizado en una importación.
- `FACTURA (1)` -- `LINEA_FACTURA (0..N)`: un borrador puede no tener líneas todavía (CU-10); para emitir se exige al menos una (CU-12)
- `SERIE_FACTURACION (0..1)` -- `FACTURA (0..N)`: un borrador aún no tiene serie.
- `SUSCRIPCION (0..1)` -- `FACTURA (0..N)` y `EJECUCION_TAREA (0..1)` -- `FACTURA (0..N)`: solo las recurrentes tienen suscripcion y ejecución del planificador.
- `FACTURA (0..1)` -- `FACTURA (0..N)` mediante `id_factura_original`: rectificativas de una factura.
- `FACTURA (1)` -- `APROBACION_FACTURA (0..N)`: cada retención es una fila (CU-13 FA-1).
- `MOVIMIENTO_COBRO (N)` -- `FACTURA (N)` mediante `CONCILIACION`, con importe, regla y reversión: un cobro puede repartirse entre facturas y una factura cobrarse en varios pagos (FR-21).
- `FACTURA (0..1)` -- `COMUNICACION (0..N)`; `PLANTILLA_COMUNICACION (1)` -- `COMUNICACION (0..N)`; `CONTACTO (0..1)` -- `COMUNICACION (0..N)`.
- `INCIDENCIA (1)` -- `COMENTARIO (0..N)` y `ADJUNTO (0..N)`; `FACTURA (0..1)` -- `INCIDENCIA (0..N)`.
- `EXCEPCION_COMERCIAL (0..1)` -- `SOLICITUD_DESCUENTO (0..1)`: clave foránea única, relación 1:1 (CU-01 FA-4).
- `USUARIO (1)` -- `OBJETIVO_FACTURACION (0..N)`: lo gestiona un Administrador (CU-28)
- `CONFIGURACION_SISTEMA` no tiene claves foráneas: es una tabla de una sola fila y una clave hacia ella desde series, impuestos o rangos siempre valdria 1.
- Cada tabla tiene como clave primaria `id_tabla` (`id_cliente`, `id_factura`…); las tablas intermedias usan como clave las dos foráneas. Las columnas `id_cliente`, `id_factura`, `id_usuario`… actuan como claves foraneas donde corresponda

## Reglas y restricciones
- Tipos: importes `NUMBER(15,2)`, nunca `FLOAT` (NFR-06). booleanos `NUMBER(1)` con valor `0` o `1`.
- Estados y tipos: cada columna solo admite los valores de su enumeración del diagrama de clases. Un ejemplo de esto es: `FACTURA.tipo IN ('PUNTUAL', 'RECURRENTE')`.
- Valores unicos: `USUARIO.correo_corporativo`, `SERIE_FACTURACION.codigo`, `IMPUESTO.nombre`, `ETIQUETA.nombre`, `CENTRO_COSTE.nombre`, `OBJETIVO_FACTURACION.periodo`, `(PLANTILLA_COMUNICACION.tipo, idioma, version)`, `(FILTRO_GUARDADO.id_usuario, nombre)`, `(FILA_IMPORTACION.id_importacion, numero_fila)`, `EXCEPCION_COMERCIAL.id_solicitud_descuento`.
- `FACTURA`: `(id_serie, numero)` único (BR-10); `(id_suscripcion, periodo_facturado)` unico sin contar rectificativas (NFR-15, CU-11); si `estado` no es `BORRADOR` ni `APROBADA`, `numero`, `id_serie` y `fecha_emision` no son nulos. Si hay `numero`, hay `id_serie`; `tipo = 'RECURRENTE'` exige `id_suscripcion` y `periodo_facturado`, y `tipo = 'PUNTUAL'` no tiene `periodo_facturado`; `id_factura_original` y `motivo_rectificacion` van juntos (FR-45); `base_imponible >= 0` y `total >= 0` salvo en rectificativas; `fecha_vencimiento >= fecha_emision`; una emitida no migrada tiene `datos_fiscales_emision` (BR-09).
- `LINEA_FACTURA`: `cantidad > 0`; `descuento` entre 0 y 100. `IMPUESTO.porcentaje` entre 0 y 100
- `RANGO_TARIFA`: `facturacion_maxima >= facturacion_minima` o nula (sin tope). `SERIE_FACTURACION.ultimo_numero >= 0`. `CONFIGURACION_SISTEMA.id_configuracion = 1` (una sola fila).
- Separación de funciones (BR-12): `id_aprobador <> id_solicitante` en `SOLICITUD_DESCUENTO`, `APROBACION_FACTURA` y `OPERACION_EXCEPCIONAL`; `id_aprobador <> id_ejecutor` en `ACCION_MASIVA`.
- `ACCION_MASIVA`: con `alto_impacto = 1` y `estado = 'EJECUTADA'`, `id_aprobador` no es nulo (CU-32 FA-2). Es decir ninguna accion masiva de alto impacto se puede ejecutar sin que alguien la haya aprobado.
- `SOLICITUD_DESCUENTO`: `valor > 0` y, si `tipo = 'PORCENTAJE'`, `valor <= 100`; resuelta (ni `PENDIENTE` ni `ESCALADA`) tiene `id_aprobador` y `fecha_decision`; `RECHAZADA` o `APROBADA_CONDICIONADA` exige `motivo_decision` (CU-08 FA-1, FA-2).
- `APROBACION_FACTURA`: como mucho una con `estado IN ('PENDIENTE', 'PENDIENTE_INFORMACION')` por factura (CU-13 FE-2); decidida tiene `id_aprobador` y `fecha_decision`; `RECHAZADA` o `PENDIENTE_INFORMACION` exige `motivo_decision`; `fecha_decision >= fecha_solicitud`. Es decir, una factura no puede estar esperando a dos revisiones a la vez.
- `REVISION_TARIFA_ANUAL`: si no está `PENDIENTE`, tiene `id_aprobador` y `fecha_decision`.
- `OPERACION_EXCEPCIONAL`: `APROBADA` o `EJECUTADA` tiene `id_aprobador` (BR-13)
- `MOVIMIENTO_COBRO`: `importe > 0`; `(fuente, id_externo)` único, un evento de cobro no se registra dos veces (CU-16 FE-1).
- `CONCILIACION`: `importe_asignado > 0`; `MANUAL` implica que tenga un `id_realizada_por` y `AUTOMATICA` tiene una `regla` (FR-22); `revertida = 1` exige `id_revertida_por`, `fecha_reversion` y `motivo_reversion`; la tupla `(id_movimiento, id_factura)` es única mientras no sea revertida
- `SUSCRIPCION`: `EN_PAUSA` exige `motivo_pausa` y `fecha_inicio_pausa` (FR-16); `CANCELADA` exige `fecha_baja` y `motivo_baja` (CU-05 FA-2); `fecha_baja >= fecha_inicio`.
- `USUARIO`: si no es un `INVITADO`, `hash_contrasena` no es nulo (CU-31); `puede_gestionar_usuarios = 1` solo si el `rol = 'ADMIN'` (FR-07).
- `TAREA`: `COMPLETADA` tiene `id_completada_por` y `fecha_completada`; `PENDIENTE` no tiene `fecha_completada`.
- `EXCEPCION_COMERCIAL`: `tipo = 'INICIO_FUTURO'` exige `fecha_inicio_futura`. `EJECUCION_TAREA`: `fin >= inicio`. `NOTIFICACION`: `resuelta = 1` solo si `requiere_accion = 1`. `COMUNICACION`: `numero_intento >= 1`
- Ninguna clave foránea borra en cascada, debido a que una factura emitida, un cobro o un contacto no desaparecen con su padre (BR-09, BR-19).
- No se pueden expresar como restricción y las controla la aplicación: una factura emitida no se modifica (BR-09, FR-14), quién puede aprobar según su rol (CU-09), el registro de auditoría no se edita ni se borra (NFR-09), un usuario operativo solo trabaja con sus clientes asignados (NFR-07), el correo de un usuario pertenece al dominio corporativo (FR-06),`saldo_pendiente` se recalcula con cada conciliación o reversión (FR-21), y las cardinalidades mínimas 1..* (un contacto pertenece al menos a un cliente, una importación tiene al menos una fila).

## Trazabilidad
| Requisitos/casos | Tablas/columnas | Observación |
|---|---|---|
| FR-03, FR-04, FR-33, CU-01 | CLIENTE, CONTACTO, CLIENTE_CONTACTO.tipo, ETIQUETA, CLIENTE_ETIQUETA, EXCEPCION_COMERCIAL | Ficha del cliente, contactos compartidos, etiquetas y excepciones comerciales. |
| FR-08, CU-03 | IMPORTACION_CSV, FILA_IMPORTACION, CLIENTE.id_importacion, FACTURA.migrada | Resumen de cada importación y resultado de cada fila. |
| FR-32, CU-04 | TAREA | Tareas del cliente con quién y cuándo se completaron. |
| FR-09, FR-16, CU-05 | SUSCRIPCION (estado, pausa y baja) | Pausa y baja con motivo y fechas |
| FR-10, FR-17, CU-06 | REVISION_TARIFA_ANUAL, RANGO_TARIFA | Revision anual con rango propuesto y decision |
| FR-18, CU-07–CU-09 | SOLICITUD_DESCUENTO | Solicitud, aprobación y escalado del descuento. |
| FR-02, FR-13, CU-10 | FACTURA (estado BORRADOR), LINEA_FACTURA, IMPUESTO | Borrador editable con varias líneas. |
| FR-11, NFR-15, CU-11 | FACTURA.periodo_facturado, FACTURA.id_ejecucion, EJECUCION_TAREA | Mensualidades sin duplicar y registro de cada ejecución. |
| FR-01, FR-12, BR-09, BR-10, CU-12 | FACTURA (numero, id_serie, documento_pdf, datos_fiscales_emision), SERIE_FACTURACION | Numero único por serie, PDF conservado y datos fiscales del momento de emitir. |
| FR-13, FR-18, BR-12, CU-13 | APROBACION_FACTURA, FACTURA.retenida | Historial de retenciones con solicitante y aprobador distintos |
| FR-19, FR-45, CU-14 | OPERACION_EXCEPCIONAL, FACTURA.id_factura_original, motivo_rectificacion | Rectificar, anular, incobrable o cancelar con motivo y aprobacion. |
| FR-28, CU-15 | FILTRO_GUARDADO, FAVORITO | Filtros guardados y clientes favoritos. |
| FR-15, FR-21, FR-22, CU-16, CU-17 | MOVIMIENTO_COBRO, CONCILIACION, FACTURA.saldo_pendiente | Cobros sin duplicar, conciliación parcial y reversión trazada. |
| FR-23, FR-26, FR-46, CU-18, CU-19, CU-22 | COMUNICACION, PLANTILLA_COMUNICACION | Cada intento con canal, resultado y versión de plantilla. |
| FR-05, CU-20, CU-21 | CONFIGURACION_SISTEMA (días de recordatorio), CLIENTE.vencimiento_pactado_dias, SUSPENSION_RECORDATORIOS | Calendario de recordatorios y suspensión por factura. |
| FR-24, FR-42, CU-23, CU-24 | NOTIFICACION, REGLA_ALERTA, USUARIO.preferencias_notificacion | Avisos leídos y resueltos por separado; reglas de alerta. |
| FR-34, FR-36, BR-20, CU-25 | INCIDENCIA, COMENTARIO, MENCION, ADJUNTO | Comentarios internos: no tienen relación con COMUNICACION. |
| FR-25, FR-37, CU-26 | INFORME | Informes con filtros, formato y caducidad. |
| FR-29, FR-40, FR-41, CU-27, CU-28 | OBJETIVO_FACTURACION, CENTRO_COSTE, CLIENTE.id_centro_coste, FACTURA.id_centro_coste | El dashboard se calcula con consultas; objetivos y centros de coste se guardan. |
| FR-06, FR-07, NFR-08, CU-30, CU-31 | USUARIO (correo_corporativo, rol, estado, intentos_fallidos, bloqueado_hasta) | Acceso con correo corporativo, roles y bloqueo. |
| FR-31, CU-32 | ACCION_MASIVA | Alcance y aprobación de acciones de alto impacto. |
| FR-38, FR-48 · CU-33 | EJECUCION_TAREA, COMUNICACION.estado | Monitorizacion de tareas y cola de correos |
| NFR-09, CU-34 | EVENTO_AUDITORIA | Valores anteriores y nuevos, autor y errores tecnicos |
| FR-01, FR-17, FR-39, CU-35, CU-36 | CONFIGURACION_SISTEMA, SERIE_FACTURACION, IMPUESTO, RANGO_TARIFA | Parametros del superadministrador |
| FR-49, BR-21, CU-37 | SOLICITUD_EXTERNA | Lo que llega por la API queda pendiente de revision |

## Decisiones abiertas
- Herencia en una sola tabla. Usuario, UsuarioOperativo, Administrador y Superadministrador son la tabla USUARIO con la columna rol (OPERATIVO, ADMIN, SUPERADMIN). Se descartó una tabla por subclase porque casi no tienen atributos propios y cambiar de rol sería mover filas entre tablas.
- Factura y rectificativa en una sola tabla. Una fila de FACTURA es rectificativa si tiene id_factura_original y motivo_rectificacion. Hemos descartado una tabla aparte porque comparten varias cosas entre ellas numeración, PDF y cobros.
- saldo_pendiente guardado. Es un atributo derivado, se guarda para consultar rapido el dashboard y la pantalla diaria (NFR-12). La alternativa es calcularlo siempre con una consulta sobre CONCILIACION
- Parametros sin valor en la Entrega 1. El umbral de descuento, el umbral de importe alto, las series y los impuestos son configurables (CU-35), pero no tenemos sus valores ya que el cliente no los especificó. Seria una pregunta interesante al cliente
- Datos fiscales de la emisión se guardan como texto. Si el cliente necesitara consultarlos por campos, se separarían en columnas
- Rectificativas con importe negativo. Hemos considerado que se permite el importe negativo porque una rectificativa sirve para corregir una factura ya emitida y muchas veces la correccion es restar una cantidad de dinero.
