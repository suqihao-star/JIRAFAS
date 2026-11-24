# Modelo físico de datos

> Sistema de facturación de Turbine · Grupo JIRAFAS · Análisis y Diseño de Aplicaciones 2026-27 · Entrega 2
>
> Fuentes: [`../diagramas/modelo_datos.sql`](../diagramas/modelo_datos.sql) (script ejecutable) y [`../diagramas/modelo_datos.puml`](../diagramas/modelo_datos.puml) (diagrama).
> Se deriva del diagrama de clases (propuesta de Pablo Fernández Carabantes) y de la Entrega 1 (requisitos y casos de uso CU-01 a CU-37).

## Alcance

Este modelo define cómo se guardan los datos del sistema de facturación: clientes y contactos, suscripciones y tarifas, facturas, cobros y conciliación, comunicaciones, seguimiento e informes, y administración y auditoría. Da soporte a los 37 casos de uso de la Entrega 1 y a los requisitos funcionales (FR), no funcionales (NFR) y reglas de negocio (BR) que afectan a los datos.

Cifras del modelo:

| Elemento | Cantidad |
|---|---|
| Tablas | 41 (agrupadas en los bloques A–F de los casos de uso) |
| Columnas | 306 |
| Claves foráneas | 66 |
| Restricciones `CHECK` | 103 |
| Índices adicionales (búsqueda y unicidad parcial) | 26 |
| Disparadores | 13 (5 funciones) |

Está escrito para **PostgreSQL 15 o superior** (ver «Decisiones abiertas», punto 1). El script se ha ejecutado completo sobre PostgreSQL 16 sin errores, y las columnas y claves foráneas del diagrama coinciden con las creadas en la base de datos.

### Figuras

El diagrama completo es muy ancho, así que se entrega también dividido por bloques, como recomienda el README de la plantilla. En cada bloque, las tablas en gris son de otros bloques y solo muestran su clave primaria.

| Figura | Archivo |
|---|---|
| Vista general (41 tablas) | `modelo_datos.png` |
| Bloque A · Clientes y contactos | `modelo_datos_bloque_A.png` |
| Bloque B · Suscripciones, tarifas y descuentos | `modelo_datos_bloque_B.png` |
| Bloque C · Facturación | `modelo_datos_bloque_C.png` |
| Bloque D · Cobros y comunicaciones | `modelo_datos_bloque_D.png` |
| Bloque E · Seguimiento, consulta e informes | `modelo_datos_bloque_E.png` |
| Bloque F · Administración, seguridad y sistema | `modelo_datos_bloque_F.png` |

## Del diagrama de clases al modelo de tablas

No toda clase es una tabla ni toda tabla sale de una clase. El diagrama de clases tiene 40 clases y 2 interfaces; el modelo tiene 41 tablas. Los cambios son estos:

| En el diagrama de clases | En el modelo de datos | Motivo |
|---|---|---|
| `Usuario`, `UsuarioOperativo`, `Administrador`, `Superadministrador` | Una tabla `USUARIO` con la columna `rol` (`OPERATIVO`, `ADMINISTRADOR`, `SUPERADMINISTRADOR`) | Las subclases casi no añaden atributos y cambiar de rol es cambiar una columna (CU-31). |
| `Factura`, `FacturaRectificativa` | Una tabla `FACTURA` con `tipo = 'RECTIFICATIVA'` e `id_factura_original` | La rectificativa comparte numeración, PDF y cobros con el resto de facturas (BR-09, FR-45). |
| `SistemaPagos`, `CanalEnvio` | Sin tabla | Son comportamiento, no datos (BR-06). Sus huellas son `MOVIMIENTO_COBRO.fuente` y `COMUNICACION.canal`. |
| `ClienteContacto` (clase asociación) | `CLIENTE_CONTACTO` | Relación N:M con atributo propio (`tipo`). |
| `Conciliacion` | `CONCILIACION` entre `MOVIMIENTO_COBRO` y `FACTURA` | Relación N:M con importe, regla y reversión. |
| Asociación `favoritos` | `FAVORITO` | N:M sin atributos. |
| Asociación `menciona` | `MENCION` | N:M sin atributos. |
| `Cliente.etiquetas : List<String>` | `ETIQUETA` y `CLIENTE_ETIQUETA` | Un atributo multivaluado no cabe en una columna (primera forma normal). |
| `Incidencia.adjuntos : List<String>` | `ADJUNTO` | Mismo motivo. |
| `ConfiguracionSistema` «configura» series, impuestos y rangos | `CONFIGURACION_SISTEMA` con una única fila (`CHECK id_configuracion = 1`); `SERIE_FACTURACION`, `IMPUESTO` y `RANGO_TARIFA` sin clave foránea hacia ella | Con una única configuración, esa clave no aporta nada. |
| Atributo derivado `/saldoPendiente` | Columna `FACTURA.saldo_pendiente` | Se guarda para consultar rápido (NFR-12); la aplicación la recalcula con cada cobro. |
| Operaciones de las clases | Sin reflejo en tablas | Son comportamiento. Solo las reglas que protegen datos pasan a restricciones y disparadores. |
| Resto de clases | Una tabla cada una | Atributos → columnas; asociaciones → claves foráneas. |

### Tipos de datos

| Tipo en el diagrama de clases | Tipo SQL | Nota |
|---|---|---|
| `Decimal` (importes) | `NUMERIC(14,2)` | Nunca `FLOAT` (NFR-06). Cantidades `NUMERIC(12,3)`; porcentajes `NUMERIC(5,2)`. |
| `Fecha` / `FechaHora` | `DATE` / `TIMESTAMPTZ` | |
| `Archivo` | `BYTEA` | El PDF se guarda en la base de datos (FR-12). |
| `String` de estado o tipo | `VARCHAR` + `CHECK ... IN (...)` | Los valores son los de la tabla «Valores permitidos» del documento de clases. |
| `String` de longitud libre | `TEXT` | Motivos, descripciones, contenido de plantillas. |
| `String` con estructura (criterios, datos fiscales, datos externos) | `JSONB` | `criterios` de filtros e informes, `datos_fiscales_emision`, `solicitud_externa.datos`, valores de auditoría. |
| Clave primaria | `BIGINT GENERATED ALWAYS AS IDENTITY` | Hay hasta cientos de miles de facturas (NFR-13) y la auditoría crece sin parar. |
| Moneda | `CHAR(3)` con `CHECK` de tres letras mayúsculas | Código ISO 4217 (FR-03: varias monedas). |

## Justificación del modelo

Las cardinalidades se leen «padre (mín..máx) — hijo (mín..máx)». Una clave foránea `NOT NULL` da `1` en el lado del padre; si admite `NULL`, da `0..1`. Que algo sea `1..*` (por ejemplo, «todo cliente tiene al menos un contacto») **no lo puede expresar una clave foránea**: lo valida la aplicación y se indica con un comentario en el SQL.

### Bloque A · Clientes y contactos

- `CLIENTE (0..N)` — `USUARIO (1)`: todo cliente tiene un responsable interno (`id_responsable`); un usuario puede no tener ninguno.
- `CLIENTE (1..N)` — `CONTACTO (0..N)` mediante `CLIENTE_CONTACTO`: un contacto puede ser de varios clientes; el `tipo` (contratación, facturación o impagos) pertenece a la pareja (FR-04).
- `CLIENTE (1)` — `TAREA (0..N)`, `SUSCRIPCION (0..N)` y `EXCEPCION_COMERCIAL (0..N)`: son partes del cliente (composición UML), por eso borran en cascada.
- `IMPORTACION_CSV (1)` — `FILA_IMPORTACION (1..N)`: la clave de la fila es `(id_importacion, numero_fila)`.
- `IMPORTACION_CSV (0..1)` — `CLIENTE (0..N)`: marca qué importación creó o actualizó al cliente.
- `CLIENTE` — `ETIQUETA` mediante `CLIENTE_ETIQUETA`, y `USUARIO` — `CLIENTE` mediante `FAVORITO`: N:M sin atributos.

### Bloque B · Suscripciones, tarifas y descuentos

- `CLIENTE (1)` — `REVISION_TARIFA_ANUAL (0..N)`; la revisión apunta, de forma opcional, al `RANGO_TARIFA` propuesto y al administrador que la decide.
- `CLIENTE (1)` — `SOLICITUD_DESCUENTO (0..N)`; la solicitud puede referirse a una `SUSCRIPCION (0..1)`, tiene un solicitante (`1`) y un aprobador (`0..1`).
- `EXCEPCION_COMERCIAL (0..1)` — `SOLICITUD_DESCUENTO (0..1)`: relación 1:1 opcional, con `UNIQUE` en `excepcion_comercial.id_solicitud`.

### Bloque C · Facturación

- `CLIENTE (1)` — `FACTURA (0..N)`. `SUSCRIPCION (0..1)` — `FACTURA (0..N)` («genera»), `SERIE_FACTURACION (0..1)` — `FACTURA (0..N)` («numera»; una factura en borrador aún no tiene serie).
- `FACTURA (1)` — `LINEA_FACTURA (0..N)` y `FACTURA (1)` — `APROBACION_FACTURA (0..N)`: composiciones, con borrado en cascada. Solo se puede borrar una factura que nunca se emitió (BR-09).
- `FACTURA (0..1)` — `FACTURA (0..N)` (`id_factura_original`): una rectificativa corrige a una factura; una factura puede tener varias rectificativas.
- `LINEA_FACTURA (0..N)` — `IMPUESTO (1)`. La línea copia el porcentaje al emitir (`porcentaje_impuesto`), así que cambiar un impuesto no reescribe facturas históricas (BR-11).
- `FACTURA (1)` — `OPERACION_EXCEPCIONAL (0..N)`.
- `USUARIO (1)` — `FILTRO_GUARDADO (0..N)`, único por `(id_usuario, nombre)`.

### Bloque D · Cobros y comunicaciones

- `MOVIMIENTO_COBRO (1)` — `CONCILIACION (0..N)` — `FACTURA (1)`: un cobro se reparte entre varias facturas y una factura admite varios cobros (FR-21). Se asegura que no se asigna dos veces el mismo cobro a la misma factura mientras esté vigente.
- `FACTURA (0..1)` — `COMUNICACION (0..N)`: cada intento, reenvío o canal es una fila, y su historial es el de la factura (FR-46, CU-18).
- `COMUNICACION (0..N)` — `PLANTILLA_COMUNICACION (1)` y `CONTACTO (0..1)`. Las plantillas son filas versionadas (`tipo`, `idioma`, `version`), de modo que una comunicación conserva la versión con la que se envió (BR-11, CU-22).
- `FACTURA (1)` — `SUSPENSION_RECORDATORIOS (0..N)`, con una sola activa por factura.

### Bloque E · Seguimiento, consulta e informes

- `CLIENTE (1)` — `INCIDENCIA (0..N)`; la incidencia puede llevar una `FACTURA (0..1)` y tiene un responsable (`1`).
- `INCIDENCIA (1)` — `COMENTARIO (0..N)` y `ADJUNTO (0..N)`.
- `COMENTARIO (1)` — `MENCION (0..N)` — `USUARIO (1)`, y `COMENTARIO (0..1)` — `NOTIFICACION (0..N)`.
- `REGLA_ALERTA (0..1)` — `NOTIFICACION (0..N)`; `USUARIO (1)` — `NOTIFICACION (0..N)`, `INFORME (0..N)`.
- `CENTRO_COSTE (0..1)` — `CLIENTE (0..N)` y `FACTURA (0..N)`.

### Bloque F · Administración, seguridad y sistema

- `USUARIO (0..1)` — `EVENTO_AUDITORIA (0..N)`: el autor es opcional porque algunos eventos los genera el Planificador.
- `USUARIO (1)` — `ACCION_MASIVA (0..N)` como ejecutor; el aprobador es `0..1`.
- `EJECUCION_TAREA (0..1)` — `FACTURA (0..N)`: qué ejecución del Planificador generó cada factura recurrente (CU-11, NFR-15).
- `CLIENTE (1)` — `SOLICITUD_EXTERNA (0..N)`.

## Reglas y restricciones

**La notación gráfica no valida automáticamente las restricciones**, así que se describen aquí. Todas están implementadas en `modelo_datos.sql` y se han probado.

### Restricciones declarativas (`CHECK`, `UNIQUE`, índices parciales)

| Regla | Mecanismo | Dónde |
|---|---|---|
| BR-10: número único dentro de su serie | `UNIQUE (id_serie, numero)` (varios `NULL` permitidos: los borradores no tienen número) | `FACTURA` |
| Número y fecha de emisión van juntos; en `BORRADOR` están vacíos | `CHECK` | `FACTURA` |
| BR-17, NFR-15: una sola mensualidad vigente por suscripción y periodo, también tras un reintento | Índice único parcial `(id_suscripcion, periodo_facturado) WHERE tipo = 'RECURRENTE'` excluyendo anuladas y canceladas | `FACTURA` |
| FR-45: una rectificativa siempre apunta a su original y lleva motivo | `CHECK ((tipo = 'RECTIFICATIVA') = (id_factura_original IS NOT NULL))` | `FACTURA` |
| Una factura emitida tiene fecha de emisión y datos fiscales congelados | `CHECK` por estado | `FACTURA` |
| BR-12: el aprobador no es quien solicitó | `CHECK (id_aprobador <> id_solicitante)` | `SOLICITUD_DESCUENTO`, `APROBACION_FACTURA`, `OPERACION_EXCEPCIONAL`, `ACCION_MASIVA` |
| Una decisión (aprobar o rechazar) deja aprobador y fecha; un rechazo lleva motivo | `CHECK` por estado | `SOLICITUD_DESCUENTO`, `REVISION_TARIFA_ANUAL`, `APROBACION_FACTURA` |
| CU-13: una sola retención abierta por factura | Índice único parcial `WHERE estado IN ('PENDIENTE', 'PENDIENTE_INFORMACION')` | `APROBACION_FACTURA` |
| BR-13: una operación aprobada o ejecutada tiene aprobador | `CHECK` | `OPERACION_EXCEPCIONAL` |
| FR-15: un evento de cobro duplicado no se contabiliza dos veces | `UNIQUE (fuente, id_externo)` | `MOVIMIENTO_COBRO` |
| CU-17: una reversión deja fecha y motivo; la conciliación manual deja quién la hizo | `CHECK` | `CONCILIACION` |
| BR-14, BR-15: la pausa y la baja son estados distintos y exigen sus fechas y motivos | `CHECK` por estado | `SUSCRIPCION` |
| CU-21: una suspensión de recordatorios activa por factura | Índice único parcial `WHERE activa` | `SUSPENSION_RECORDATORIOS` |
| CU-01: el aviso de duplicado no impide el alta | `identificador_fiscal` **no es único** (solo tiene índice) | `CLIENTE` |
| FR-47: un cliente con datos fiscales incompletos puede existir; si se marca completo, deben estar todos | `CHECK (datos_fiscales_incompletos OR (razon_social IS NOT NULL AND ...))` | `CLIENTE` |
| BR-20: un comentario nunca se envía al cliente | No existe ninguna clave foránea de `COMENTARIO` hacia `COMUNICACION` | `COMENTARIO` |
| BR-19: desactivar un contacto no borra el histórico | `CONTACTO.activo`; `COMUNICACION` guarda copia del correo usado y la clave hacia el contacto no es de borrado en cascada | `CONTACTO`, `COMUNICACION` |
| NFR-06: importes sin pérdida de céntimos | `NUMERIC`, nunca `FLOAT` | Todas |
| NFR-17: contraseñas no en claro | Solo existe `hash_contrasena` | `USUARIO` |
| FR-06: acceso con correo corporativo (único sin distinguir mayúsculas) | Índice único sobre `lower(correo_corporativo)` | `USUARIO` |

### Disparadores (reglas entre tablas)

| Regla | Disparador | Efecto |
|---|---|---|
| BR-09: factura emitida inmutable | `trg_factura_inmutable` | Una vez emitida (con `fecha_emision`), no se puede borrar ni cambiar importes, número, fechas, cliente, serie ni datos fiscales; no puede volver a `BORRADOR`. Siguen cambiando `estado`, `saldo_pendiente`, `retenida` y `centro_coste`, y el PDF puede añadirse una vez. |
| BR-09: líneas de factura emitida inmutables | `trg_linea_factura_bloqueada` | No se insertan, modifican ni borran líneas de una factura emitida. |
| BR-13: «pagada» solo con un cobro | `trg_factura_pagada` | No se pasa a `PAGADA` ni `PARCIALMENTE_CONCILIADA` si no existe una conciliación vigente (salvo facturas históricas `migrada`, CU-03). |
| BR-12: quién puede aprobar | `fn_exigir_rol_admin` (8 disparadores) | Aprobadores, solicitantes de operaciones excepcionales, ejecutores de acciones masivas y gestores de objetivos deben ser Administrador o Superadministrador. |
| NFR-09: auditoría no editable | `trg_auditoria_fila`, `trg_auditoria_truncate` | `EVENTO_AUDITORIA` es de solo inserción: no admite `UPDATE`, `DELETE` ni `TRUNCATE`. |

### Reglas que quedan en la aplicación

La base de datos no puede o no debe garantizarlas; deben validarse en el servidor (NFR-07):

- Las cardinalidades `1..*` (cliente con al menos un contacto, configuración con al menos una serie, etc.).
- Que la suma de las conciliaciones de un cobro no supere su importe, y el cálculo de totales, prorrateo y `saldo_pendiente` (`calcularTotales`, `calcularProrrateo`, `registrarCobro`).
- Que `SolicitudDescuento` por encima del umbral la decida el Superadministrador (FR-18): el estado `ESCALADA` se pierde al resolverse, y su historial queda en `EVENTO_AUDITORIA`.
- La asignación de numeración: debe hacerse dentro de una transacción con `UPDATE serie_facturacion SET ultimo_numero = ultimo_numero + 1 WHERE id_serie = ? RETURNING ultimo_numero`. El bloqueo de fila evita duplicados con usuarios simultáneos (BR-10, NFR-13).
- Que un cambio de rol, la baja o las configuraciones queden registrados en `EVENTO_AUDITORIA`.

### Pruebas realizadas

Se ejecutó el script completo en PostgreSQL 16 y se lanzaron 18 casos de prueba sobre datos de ejemplo. Se aceptan: crear un borrador, emitirlo, cambiar su estado y saldo, conciliarlo y pagarlo, y aprobar un descuento con un administrador distinto del solicitante. Se rechazan: modificar el total o borrar una factura emitida, modificar sus líneas, pasar a `PAGADA` sin cobro, repetir un número, aprobar uno mismo o con un operativo, duplicar la mensualidad de un periodo, repetir un evento de pago, editar o vaciar la auditoría, crear una rectificativa sin original y marcar completos los datos fiscales de un cliente sin ellos.

## Trazabilidad

| Requisitos / casos de uso | Tablas y columnas | Observación |
|---|---|---|
| FR-03, FR-04, FR-27, FR-30, FR-33, FR-44, FR-47 · CU-01 | `CLIENTE`, `CONTACTO`, `CLIENTE_CONTACTO`, `ETIQUETA`, `CLIENTE_ETIQUETA`, `EXCEPCION_COMERCIAL`, `FAVORITO` | Ficha fiscal y comercial, contactos N:M con tipo, duplicados avisados sin fusionar (NFR-18, BR-18). |
| FR-08 · CU-03 | `IMPORTACION_CSV`, `FILA_IMPORTACION`, `CLIENTE.id_importacion`, `FACTURA.migrada` | Importación con previsualización, motivos de rechazo y facturas históricas. |
| FR-32 · CU-04 | `TAREA` | Las tareas pertenecen al cliente. |
| FR-09, FR-16, BR-14, BR-15 · CU-05 | `SUSCRIPCION`, `CLIENTE.estado`, `CLIENTE.fecha_baja` | La baja detiene mensualidades pero no el recobro. |
| FR-10, FR-17 · CU-06 | `REVISION_TARIFA_ANUAL`, `RANGO_TARIFA` | Rango propuesto, precios anterior y nuevo, aprobador y fecha. |
| FR-18, BR-12 · CU-07, CU-08, CU-09 | `SOLICITUD_DESCUENTO`, `CONFIGURACION_SISTEMA.umbral_descuento` | Solicitud, aprobación y escalado; aprobador distinto del solicitante. |
| FR-02, FR-13 · CU-10 | `FACTURA` (estado `BORRADOR`), `LINEA_FACTURA`, `IMPUESTO` | Borrador sin número hasta emitir. |
| FR-11, BR-17, NFR-15 · CU-11 | `EJECUCION_TAREA`, `FACTURA` (`RECURRENTE`, `id_ejecucion`), `SUSCRIPCION`, `EXCEPCION_COMERCIAL` | Generación mensual sin duplicar periodo. |
| FR-01, FR-12, FR-14, FR-19, FR-20, BR-09, BR-10 · CU-12 | `FACTURA`, `SERIE_FACTURACION`, `FACTURA.datos_fiscales_emision`, `FACTURA.documento_pdf` | Número único, PDF guardado y bloqueo tras emitir. |
| FR-13, FR-18, BR-12 · CU-13 | `APROBACION_FACTURA`, `FACTURA.retenida` | Una fila por retención, con historial. |
| FR-19, FR-45, BR-13 · CU-14 | `OPERACION_EXCEPCIONAL`, `FACTURA` (`RECTIFICATIVA`, `id_factura_original`) | Rectificar, anular, incobrable o cancelar con aprobación. |
| FR-28 · CU-15 | `FILTRO_GUARDADO`, `FAVORITO`, índices de búsqueda de `CLIENTE`, `CONTACTO` y `FACTURA` | Búsqueda por nombre, razón social, NIF, contacto, número y correo. |
| FR-15, BR-13 · CU-16 | `MOVIMIENTO_COBRO` (`UNIQUE fuente, id_externo`), `CONCILIACION` (`AUTOMATICA`) | Un evento duplicado no se contabiliza dos veces. |
| FR-15, FR-21, FR-22 · CU-17 | `CONCILIACION`, `FACTURA.saldo_pendiente`, `MOVIMIENTO_COBRO.id_asignado_a` | Conciliación manual, reparto y reversión trazada. |
| FR-26, FR-46 · CU-18 | `COMUNICACION`, `PLANTILLA_COMUNICACION` | Intento, canal, resultado, fecha y destinatario. |
| FR-23 · CU-19 | `COMUNICACION` (estado `REBOTADA`), `INCIDENCIA` | Un rebote no marca la factura como notificada y abre una incidencia. |
| FR-05, BR-14, BR-16 · CU-20, CU-21 | `CONFIGURACION_SISTEMA`, `CLIENTE.vencimiento_pactado_dias`, `FACTURA.fecha_vencimiento`, `SUSPENSION_RECORDATORIOS` | El vencimiento pactado prevalece sobre el general. |
| FR-26, BR-11 · CU-22 | `PLANTILLA_COMUNICACION.version` | Plantillas versionadas. |
| FR-24, FR-36, FR-42 · CU-23, CU-24 | `NOTIFICACION`, `REGLA_ALERTA`, `USUARIO.preferencias_notificacion` | Leída y resuelta por separado. |
| FR-34, FR-35, BR-20 · CU-25 | `INCIDENCIA`, `ADJUNTO`, `COMENTARIO`, `MENCION` | Comentarios siempre internos. |
| FR-25, FR-37 · CU-26 | `INFORME` | Formato, caducidad y estado de generación. |
| FR-29, FR-50 · CU-27, CU-29 | Consultas sobre `FACTURA`, `CONCILIACION`, `OBJETIVO_FACTURACION`, `MOVIMIENTO_COBRO`, `COMUNICACION`, `SOLICITUD_DESCUENTO` y `TAREA` | Sin tabla propia: se derivan de datos ya registrados. |
| FR-40, FR-41 · CU-28 | `OBJETIVO_FACTURACION`, `CENTRO_COSTE` | Objetivos informativos y categorías. |
| FR-06, FR-07, NFR-08 · CU-30, CU-31 | `USUARIO`, `CONFIGURACION_SISTEMA.dominio_corporativo`, `CLIENTE.id_responsable` | Acceso con correo corporativo, bloqueo por intentos, alta por invitación. |
| FR-31 · CU-32 | `ACCION_MASIVA` | Las de alto impacto exigen aprobador distinto. |
| FR-38, FR-48 · CU-33 | `EJECUCION_TAREA`, `COMUNICACION` (estado `EN_COLA`), `EVENTO_AUDITORIA.id_error` | Monitorización de tareas, cola de correos y errores. |
| NFR-09 · CU-34 | `EVENTO_AUDITORIA` | Solo inserción, con valores anteriores y nuevos. |
| FR-01, FR-17, FR-39 · CU-35, CU-36 | `CONFIGURACION_SISTEMA`, `SERIE_FACTURACION`, `IMPUESTO`, `RANGO_TARIFA` | Los cambios solo afectan al futuro (BR-11). |
| FR-49, BR-21 · CU-37 | `SOLICITUD_EXTERNA` | Lo que llega por la API queda para revisión. |
| NFR-12, NFR-13 | Índices `ix_*`; claves `BIGINT` | Búsquedas inmediatas y escala a cientos de miles de facturas. |

## Cambios respecto al diagrama de clases

Al bajar al nivel físico hubo que concretar algunos datos que el diagrama de clases deja implícitos. Conviene reflejarlos en el diagrama de clases para que ambos modelos sigan coherentes:

1. `Cliente.fecha_baja` (nuevo): la operación `darDeBaja(fecha)` necesita guardar la fecha.
2. `Cliente`: los datos fiscales (`razonSocial`, `identificadorFiscal`, `domicilioFiscal`, `pais`, `moneda`) son opcionales mientras `datosFiscalesIncompletos` sea verdadero (CU-01, FR-47).
3. `Usuario.hashContrasena` es opcional mientras el usuario está en estado `INVITADO` (CU-31).
4. `Factura`: `periodoFacturado` y `datosFiscalesEmision` son opcionales hasta emitir; `creadaPor` es `NULL` si la generó el Planificador (`Factura 0..N → 0..1 Usuario` ya lo recoge).
5. `Comunicacion.correoDestinatario` es obligatorio solo para el canal `EMAIL`; `WHATSAPP_SIMULADO` no tiene correo.
6. `ConfiguracionSistema` es una tabla de una sola fila.
7. `Factura.id_ejecucion` materializa la asociación `EjecucionTarea «genera» Factura`.

## Decisiones abiertas

1. **SGBD.** La Entrega 1 no fija el SGBD. Se asume PostgreSQL por ser software libre (NFR-11) y por ofrecer `NUMERIC` exacto (NFR-06), índices únicos parciales, `JSONB` y disparadores. Cambiar de SGBD obligaría a rehacer los índices parciales y los disparadores.
2. **Duplicado de cliente.** `identificador_fiscal` no es único porque CU-01 solo avisa de duplicados. Si el cliente decidiera prohibirlos, bastaría un índice único.
3. **Un tipo por pareja cliente–contacto.** La clave de `CLIENTE_CONTACTO` es `(id_cliente, id_contacto)`: un contacto tiene un solo tipo por cliente. Si un mismo contacto debe ser a la vez de facturación y de impagos, habría que incluir `tipo` en la clave.
4. **Importación y cliente.** Se sigue el diagrama de clases (`CLIENTE.id_importacion`). Un cliente tocado por varias importaciones solo recuerda la última. La alternativa, más precisa, es guardar el `id_cliente` en cada `FILA_IMPORTACION`.
5. **Descuento en línea de factura.** Se ha supuesto que `LINEA_FACTURA.descuento` es un importe, no un porcentaje, porque el diagrama no lo precisa. `importe` lo calcula la aplicación (`calcularImporte`) y la base de datos no lo recalcula.
6. **Sobrepago.** `saldo_pendiente` no tiene `CHECK >= 0`: FR-22 exige señalar el sobrepago y no se ha decidido cómo se representa.
7. **Rango de tarifa.** `facturacion_maxima` es obligatoria, así que no existe un último tramo «sin límite». Habría que preguntarlo al cliente.
8. **Formato del número de factura.** `numero` es `VARCHAR(40)`; el formato exacto (prefijo, relleno de ceros, año) lo marca la gestoría (BR-05) y no está en el modelo.
9. **Anonimización de contactos (NFR-18).** `COMUNICACION.correo_destinatario` guarda una copia del correo. Al anonimizar un contacto también habría que anonimizar esas copias, salvo que la conservación legal de las facturas lo impida. Pendiente de decidir.
10. **Objetivos de facturación.** No hay unicidad por `periodo`: no está claro si es un objetivo global o puede haber varios (por ejemplo, por centro de coste).
11. **País.** `pais` es texto libre; la moneda sí es código ISO 4217. Si se quisiera normalizar el país, bastaría un código ISO 3166.
12. **PDF en la base de datos.** FR-12 pide guardar el PDF en la base de datos (`BYTEA`). Con cientos de miles de facturas conviene vigilar el tamaño y las copias de seguridad (NFR-14); la alternativa sería guardar solo una referencia a un almacén de archivos.
13. **Datos de la API externa.** `solicitud_externa.datos` es `JSONB` porque el contenido de la API (CU-37) no está definido en la Entrega 1.

## Cómo reproducirlo

```bash
createdb jirafas
psql -d jirafas -v ON_ERROR_STOP=1 -f entrega2/diagramas/modelo_datos.sql
# Diagramas: abrir los .puml con PlantUML y exportar a SVG o PNG
java -jar plantuml.jar entrega2/diagramas/modelo_datos*.puml
```

Los `.puml` están generados a partir del propio `.sql` con `entrega2/diagramas/generar_puml.py` (`python3 generar_puml.py`). Si se cambia una tabla, hay que volver a ejecutarlo para que no se desincronicen.
