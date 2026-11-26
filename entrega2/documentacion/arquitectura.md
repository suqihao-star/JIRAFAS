# Arquitectura y componentes

## Vista representada

El sistema de facturación de TurbineH se representa como una **arquitectura lógica en capas y componentes**, no como una topología de despliegue. La vista principal (`diagramas/arquitectura.puml`) muestra la separación entre presentación, aplicación, procesamiento asíncrono, integración y persistencia. La vista de descomposición (`diagramas/arquitectura_dominio.puml`) detalla las dependencias entre los seis bloques del núcleo de dominio.

La solución es un **monolito modular**: una única aplicación desplegable, con un punto de entrada REST y seis módulos de negocio cohesivos (A–F). Alrededor del núcleo se sitúan los servicios transversales de seguridad, auditoría y monitorización, el planificador de tareas, los adaptadores externos y los almacenes de datos y documentos.

## Responsabilidades

| Componente | Responsabilidad | Relaciones principales |
|---|---|---|
| Aplicación web responsive | Interfaz multidispositivo para trabajo diario, dashboard, buscador e informes (`NFR-04`). | Recibe la interacción de los tres actores; consume la API por HTTPS. |
| API REST documentada y autenticada | Punto único de entrada al servidor; aplica las mismas reglas de negocio a la web y a los sistemas externos (`BR-07`, `BR-09`, `BR-10`, `BR-12`, `BR-21`). | Valida con seguridad; delega en los bloques A–F; atiende consultas y solicitudes externas de `CU-37`. |
| Seguridad transversal | Sesiones seguras, 2FA opcional y control de acceso basado en roles y asignaciones en servidor (`NFR-07`, `NFR-08`, `NFR-09`). | Es invocada por la API; consulta usuarios, roles y clientes asignados en el bloque F. |
| Bloque A · Clientes y contactos | Catálogo de clientes y contactos, tareas, excepciones comerciales e importación CSV. | Alimenta a B y C; registra auditoría y persiste en la base de datos. |
| Bloque B · Suscripciones, tarifas y descuentos | Ciclo de vida de suscripciones, prorrateo, revisión anual de tarifa y solicitudes de descuento con aprobación (`BR-12`). | Recibe datos de A y parámetros de F; genera cuotas para C. |
| Bloque C · Facturación | Borradores, emisión inmutable, numeración por serie, retenciones, rectificativas y anulaciones (`BR-09`, `BR-10`). | Consume datos de A y B; entrega facturas a D; genera el PDF mediante el motor documental; alimenta E. |
| Bloque D · Cobros y comunicaciones | Movimientos de cobro, conciliación, comunicaciones, plantillas, recordatorios e impagos. | Recibe facturas de C; usa los puertos `SistemaPagos` y `CanalEnvio`; notifica rebotes a E. |
| Bloque E · Seguimiento, consulta e informes | Notificaciones, alertas, incidencias, comentarios internos, dashboard, objetivos y centros de coste. | Consume datos de C y D; genera informes con apoyo de trabajadores en segundo plano. |
| Bloque F · Administración, seguridad y sistema | Usuarios y roles, acciones masivas, configuración de series, impuestos, tarifas y solicitudes externas pendientes de revisión. | Suministra parámetros a B, C y D; canaliza solicitudes externas hacia A. |
| Auditoría | Registro append-only de acciones relevantes mediante `EventoAuditoria`, consultable por el superadministrador (`NFR-09`). | Recibe eventos del dominio y escribe en la base de datos sin modificaciones ni borrados. |
| Monitorización y métricas | Estado de tareas programadas (`EjecucionTarea`), colas y errores técnicos con identificador (`CU-33`). | Recibe reportes del planificador; persiste estados en la base de datos. |
| Planificador del sistema | Ejecución desatendida de la facturación del día 1 (`J1`), recordatorios e impagos (`J2`), consulta de pagos (`J3`), resumen diario (`J4`) y copias de seguridad (`J5`). | Dispara procesos en el dominio y en las copias de seguridad; registra su estado en monitorización. |
| Workers en segundo plano | Informes pesados (`CU-26`) y reintentos de envío (`CU-18`) sin bloquear las peticiones interactivas (`NFR-12`). | Trabajan sobre el dominio y registran su estado. |
| Capa de integración y servicios documentales | Puertos `SistemaPagos` y `CanalEnvio`, adaptadores de Stripe/Revolut, correo, WhatsApp, IA opcional y motor documental. | Aísla el dominio de los proveedores (`BR-06`); el motor documental es un servicio interno, no un puerto externo. |
| Base de datos relacional | Almacenamiento transaccional de las entidades A–F, con decimal exacto (`NFR-06`), secuencias atómicas, los PDF de facturas (`FR-12`) y los adjuntos (`ADJUNTO.contenido` como `BLOB`). | Recibe operaciones del dominio, la auditoría, la monitorización y el motor documental; se respalda en copias de seguridad. |
| Almacén de documentos | Repositorio de informes exportados, con enlaces temporales de una hora (`NFR-17`, `A-03`). | Recibe informes del motor documental y se respalda en copias de seguridad. |
| Copias de seguridad | Respaldos automáticos de datos y documentos, con restauración validada (`NFR-14`). | Recibe copias de la base de datos y del almacén; permite restaurarlas. |
| Sistemas externos | Stripe/Revolut, proveedor de correo, WhatsApp, servicio IA (Brain) y CRM/ERP. | Se comunican con la API o con los adaptadores; nunca escriben directamente en el dominio (`BR-21`). |

### Descomposición interna de los bloques

| Bloque | Subcomponentes | Clases principales |
|---|---|---|
| A · Clientes y contactos | `ClientMgmt`, `TasksExc`, `CSVImport` | `Cliente`, `Contacto`, `ClienteContacto`, `Tarea`, `ExcepcionComercial`, `ImportacionCSV`, `FilaImportacion`. |
| B · Suscripciones, tarifas y descuentos | `SubMgmt`, `PricingDisc` | `Suscripcion`, `RevisionTarifaAnual`, `SolicitudDescuento`. |
| C · Facturación | `BillingEngine`, `ApprovalsRect`, motor documental | `Factura`, `FacturaRectificativa`, `LineaFactura`, `AprobacionFactura`, `OperacionExcepcional`, `FiltroGuardado`. |
| D · Cobros y comunicaciones | `Reconcil`, `CommsMgr` | `MovimientoCobro`, `Conciliacion`, `Comunicacion`, `PlantillaComunicacion`, `SuspensionRecordatorios`. |
| E · Seguimiento, consulta e informes | `DailyWork`, `IssuesMgr`, `ReportsDash` | `Notificacion`, `ReglaAlerta`, `Incidencia`, `Comentario`, `Informe`, `ObjetivoFacturacion`, `CentroCoste`. |
| F · Administración, seguridad y sistema | `UserAdmin`, `SysConfig`, `ExtControl` | `Usuario`, `UsuarioOperativo`, `Administrador`, `Superadministrador`, `AccionMasiva`, `ConfiguracionSistema`, `SerieFacturacion`, `Impuesto`, `RangoTarifa`, `SolicitudExterna`. |

`EventoAuditoria` y `EjecucionTarea` pertenecen al bloque F en el diagrama de clases, pero la arquitectura los representa como servicios transversales (`AUD` y `MON`) para no duplicar su responsabilidad. `UsuarioOperativo` se incluye en F para mantener la jerarquía de roles completa.

## Relaciones entre módulos

La vista `arquitectura_dominio.puml` resume las dependencias entre bloques. Las cardinalidades se apoyan en el diagrama de clases y son orientativas a nivel de componente; la fuente detallada es `diagramas/diagrama_clases.puml`.

| Relación | Cardinalidad | Motivo |
|---|---|---|
| A -> B | Cliente 1 - 0..* Suscripción | Un cliente puede no tener suscripciones o tener varias. |
| B -> C | Suscripción 0..1 - 0..* Factura | Una suscripción genera facturas, pero una factura puntual no necesita suscripción. |
| A -> C | Cliente 1 - 0..* Factura | El cliente es el titular de sus facturas. |
| C -> D | Factura 1 - 0..* Conciliación | Una factura puede tener varios movimientos de conciliación, o ninguno. |
| C -> D | Factura 0..1 - 0..* Comunicación | Una comunicación puede no estar asociada a una factura. |
| D -> E | Rebote crea incidencia / notificación | Los eventos de cobro y envío alimentan el seguimiento. |
| C -> E | Centro de coste e informes | Los datos de facturación alimentan el dashboard y los informes. |
| F -> B, C y D | Parámetros de configuración | Series, impuestos, tarifas, umbrales y cadencia de recordatorios. |
| F -> A | Solicitud externa pendiente | Las peticiones externas se revisan antes de modificar clientes o recurrencias. |

## Justificación y alternativas

- **Capas con entrada única por API.** La web y los sistemas externos comparten la misma API y las mismas reglas, de modo que ningún cliente puede saltarse permisos, aprobaciones o la inmutabilidad de una factura emitida (`BR-07`, `BR-09`, `BR-21`, `NFR-07`). El despliegue reproducible y la separación de secretos quedan cubiertos por `NFR-11`.
- **Monolito modular A–F.** Para el volumen previsto (miles de clientes y cientos de miles de facturas) es preferible una única base de datos transaccional ACID, con numeración atómica por serie y recuperación idempotente (`NFR-06`, `NFR-13`, `NFR-15`), frente a transacciones distribuidas entre microservicios.
- **Puertos y adaptadores.** `SistemaPagos` y `CanalEnvio` aíslan el dominio de Stripe, Revolut, el correo y WhatsApp (`BR-06`). El adaptador de correo recibe y normaliza los avisos de entrega o rebote; el proveedor externo no escribe directamente en el dominio. El adaptador de IA es opcional y toda sugerencia económica exige confirmación humana (`RB-03`, `BR-22`).
- **Procesamiento asíncrono.** La facturación recurrente, los recordatorios, la consulta de pagos, los resúmenes, los informes pesados y los reintentos se ejecutan fuera de la petición web (`NFR-12`). `J1` es idempotente para no duplicar facturas tras una interrupción (`NFR-15`).
- **PDF y adjuntos en la base de datos; informes aparte.** El PDF legal de cada factura y los adjuntos (`ADJUNTO.contenido`) se guardan en la base de datos relacional, conforme a `FR-12` y al modelo entidad-relación; el almacén de documentos se reserva para informes exportados, servidos mediante enlaces temporales de una hora (`NFR-17`, `A-03`). Así se conserva la factura junto a su registro transaccional y se evita mezclar informes con la tabla de facturación.
- **Copias de seguridad.** `J5` programa los respaldos; la base de datos y el almacén de documentos originan las copias, y la restauración se valida (`NFR-14`). La copia no se modela como una dependencia de la que dependa la base de datos en producción.

Alternativas descartadas:

- **Microservicios por bloque:** añaden complejidad de transacciones distribuidas y de numeración correlativa sin una necesidad de escala que lo justifique.
- **Escritura directa de sistemas externos:** vulneraría `BR-21` y `BR-12`; toda modificación externa se convierte en una `SolicitudExterna` pendiente de revisión.
- **Generación síncrona de facturación masiva e informes:** bloquearía la interfaz y dificultaría la recuperación idempotente.
- **PDF en carpetas públicas o fuera de la base de datos:** contradice `FR-12` y expone documentos a URL adivinables; el acceso debe ser autenticado y temporal.

## Trazabilidad

| Ámbito | Casos de uso | Componentes que cooperan |
|---|---|---|
| Clientes y contactos | `CU-01`, `CU-02` (absorbido en `CU-01`), `CU-03`, `CU-04` | Web, API, seguridad, bloque A (`ClientMgmt`, `TasksExc`, `CSVImport`), auditoría y base de datos. |
| Suscripciones, tarifas y descuentos | `CU-05` a `CU-09` | Web, API, seguridad, bloques B (`SubMgmt`, `PricingDisc`) y F (`SysConfig`), adaptador IA opcional, auditoría y base de datos. |
| Facturación | `CU-10` a `CU-15` | Web, API, seguridad, bloques A, B y C (`BillingEngine`, `ApprovalsRect`), motor documental, base de datos (incluido el PDF), auditoría y monitorización. |
| Cobros y comunicaciones | `CU-16` a `CU-22` | Web, API, seguridad, bloques C, D (`Reconcil`, `CommsMgr`) y E, `SistemaPagos`, `CanalEnvio`, adaptadores, auditoría y base de datos. |
| Seguimiento, consulta e informes | `CU-23` a `CU-29` | Web, API, seguridad, bloques C, D y E (`DailyWork`, `IssuesMgr`, `ReportsDash`), workers, motor documental, almacén de documentos para informes exportados, auditoría y base de datos. |
| Administración y API externa | `CU-30` a `CU-37` | Web, API, seguridad, bloque F (`UserAdmin`, `SysConfig`, `ExtControl`), monitorización, auditoría, base de datos y sistemas externos para `CU-37`. |

### Detalle por caso de uso

- **Bloque A · Clientes y contactos.** `CU-01` (incluye `CU-02` como flujo de excepción): web, API, seguridad, bloque A (`ClientMgmt`, `TasksExc`), auditoría y base de datos. `CU-03`: bloque A (`CSVImport`) y bloque C si importa facturas históricas. `CU-04`: bloque A (`TasksExc`), bloque E (`DailyWork`), auditoría y base de datos.
- **Bloque B · Suscripciones, tarifas y descuentos.** `CU-05`: web o planificador, bloque B (`SubMgmt`), bloque E (`DailyWork`), auditoría y base de datos. `CU-06`: bloque B (`SubMgmt`) y bloque F (`SysConfig`). `CU-07`, `CU-08` y `CU-09`: bloque B (`PricingDisc`), bloque F (`SysConfig`) y adaptador IA opcional.
- **Bloque C · Facturación.** `CU-10`: bloque C (`BillingEngine`), auditoría y base de datos. `CU-11` y `CU-12`: planificador `J1` o web, bloques B (`SubMgmt`) y C (`BillingEngine`, `ApprovalsRect`), bloque D (`CommsMgr`), motor documental, base de datos (PDF), monitorización y auditoría. `CU-13` y `CU-14`: bloque C (`ApprovalsRect`, `BillingEngine`), motor documental, base de datos (PDF) y auditoría. `CU-15`: bloques A (`ClientMgmt`) y C (`BillingEngine`), base de datos con el PDF.
- **Bloque D · Cobros y comunicaciones.** `CU-16` y `CU-17`: planificador `J3` o web, bloque D (`Reconcil`), `SistemaPagos`, adaptador de pasarelas, bloque C, monitorización, auditoría y base de datos. `CU-18` y `CU-19`: bloque D (`CommsMgr`), `CanalEnvio`, adaptadores de correo y WhatsApp, bloque A, bloque E, auditoría y base de datos; el proveedor de correo notifica al adaptador, nunca al dominio. `CU-20`, `CU-21` y `CU-22`: planificador `J2` o web, bloque D (`CommsMgr`), bloque F (`SysConfig`), monitorización, auditoría y base de datos.
- **Bloque E · Seguimiento, consulta e informes.** `CU-23` y `CU-24`: web o planificador `J4`, bloque E (`DailyWork`), auditoría y base de datos. `CU-25`: bloque E (`IssuesMgr`, `DailyWork`), base de datos (adjuntos) y auditoría. `CU-26`, `CU-27` y `CU-28`: bloque E (`ReportsDash`), bloques C y D, adaptador IA opcional, motor documental, almacén de documentos para informes exportados, auditoría y base de datos. `CU-29`: bloque E (`DailyWork`, `IssuesMgr`), bloques A, C y D, y base de datos.
- **Bloque F · Administración, seguridad y sistema.** `CU-30` y `CU-31`: bloque F (`UserAdmin`), adaptador de correo para invitaciones y enlaces, auditoría y base de datos. `CU-32`, `CU-35` y `CU-36`: bloque F (`UserAdmin`, `SysConfig`), adaptador IA opcional, auditoría y base de datos. `CU-33` y `CU-34`: monitorización, auditoría, planificador `J5` y base de datos. `CU-37`: sistema externo, API, seguridad, bloque F (`ExtControl`), bloque A para revisión humana, auditoría y base de datos.

| Requisito | Componente que lo materializa |
|---|---|
| `NFR-04` | Aplicación web responsive. |
| `NFR-06` | Base de datos relacional con decimal exacto. |
| `NFR-07`, `NFR-08` | Seguridad transversal y API. |
| `NFR-09` | Auditoría y monitorización. |
| `NFR-11` | Despliegue reproducible y secretos separados del código. |
| `NFR-12` | Workers y procesamiento asíncrono. |
| `NFR-13` | Monolito modular y base de datos transaccional. |
| `NFR-14` | Copias de seguridad y `J5`. |
| `NFR-15` | `J1` idempotente y recuperación de facturación. |
| `NFR-17` | Acceso autenticado a PDF y enlaces temporales del almacén. |
| `BR-06` | Puertos y adaptadores de integración. |
| `BR-07` | API REST documentada y autenticada. |
| `BR-09`, `BR-10`, `BR-12` | Bloques C y F, API y base de datos. |
| `BR-21` | API, `SolicitudExterna` y ausencia de escritura directa externa. |
| `BR-22`, `RB-03` | Adaptador IA opcional. |
