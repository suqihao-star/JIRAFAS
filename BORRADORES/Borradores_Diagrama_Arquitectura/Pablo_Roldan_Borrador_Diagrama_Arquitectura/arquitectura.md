# Arquitectura y componentes

## Vista representada

El diagrama representa una **arquitectura lógica de software y de componentes**, **no** una topología de despliegue físico ni de red. Muestra cómo se organiza el sistema de facturación de TurbineH en niveles de responsabilidad, cómo se descompone su núcleo de negocio en los seis módulos funcionales derivados del diagrama de clases (**Bloques A–F**), y cómo interactúan los servicios transversales, el planificador asíncrono, los adaptadores externos y los repositorios de datos.

## Responsabilidades

| Componente | Responsabilidad | Relaciones principales |
| --- | --- | --- |
| **Aplicación Web Responsive** | Interfaz de usuario multidispositivo (escritorio, tablet y móvil) para operar sobre clientes, facturas, cobros, pantalla de trabajo diario, buscador, dashboard financiero e informes (`NFR-04`). | Recibe interacción de `Usuario Operativo`, `Administrador` y `Superadministrador`; consume `API REST Documentada y Autenticada` vía HTTPS.

 |
| **API REST Documentada y Autenticada** | Punto único de entrada al servidor; expone operaciones para la aplicación web y para sistemas externos bajo las mismas reglas de negocio, garantizando inmutabilidad (`BR-09`), numeración única (`BR-10`) y bloqueo de escritura directa externa (`BR-21`). | Recibe peticiones de `Aplicación Web Responsive` y `Sistema Externo`; delega verificación en `Seguridad Transversal`; enruta hacia `Bloques A–F` y deriva peticiones externas a `Control Solicitudes API Externas`.

 |
| **Seguridad Transversal** | Gestión de sesiones seguras, doble factor opcional (`2FA`), validación de dominio corporativo autorizado y comprobación de control de acceso basado en roles y asignaciones (`RBAC`) en servidor (`NFR-07`, `NFR-08`). | Invocada por `API REST`; consulta usuarios, roles y clientes asignados en `Bloque F` (`UserAdmin`).

 |
| **Bloque A · Clientes y Contactos** | Gestión del catálogo comercial y fiscal (`Cliente`, `Contacto`, `ClienteContacto`), detección de duplicados por NIF, favoritos, línea temporal, tareas heredables (`Tarea`), excepciones comerciales (`ExcepcionComercial`) e importación masiva (`ImportacionCSV`, `FilaImportacion`). | Invocado por `API REST`; entrega clientes activos y excepciones a `Bloque B`; guarda contratos en `Almacén Seguro de Archivos`; persiste en `Base de Datos Relacional` y registra eventos en `Auditoría Inmutable`.

 |
| **Bloque B · Suscripciones, Tarifas y Descuentos** | Ciclo de vida de suscripciones (`Suscripcion`: altas, pausas, bajas y cálculo de prorrateo), revisión anual de rangos de tarifa (`RevisionTarifaAnual`) y flujo de aprobación escalonada de descuentos con segregación de funciones (`SolicitudDescuento`, `BR-12`). | Recibe contexto de `Bloque A` y parámetros de `Bloque F`; alimenta cuotas y descuentos a `Bloque C`; consulta sugerencias opcionales a `Adaptador IA Opcional`; persiste en `Base de Datos Relacional` y audita acciones.

 |
| **Bloque C · Facturación** | Gestión de borradores y emisión inmutable de facturas puntuales y recurrentes (`Factura`, `LineaFactura`, `FiltroGuardado`), asignación correlativa por serie, retenciones por cambios sensibles (`AprobacionFactura`), rectificativas y anulaciones (`FacturaRectificativa`, `OperacionExcepcional`) y generación de PDFs legales (`FR-12`). | Recibe cuotas de `Bloque B` y disparos programados de `Planificador del Sistema` (`J1`); envía facturas emitidas a `Bloque D` y métricas a `Bloque E`; almacena PDFs en `Almacén Seguro de Archivos`; persiste en `Base de Datos Relacional` y audita acciones.

 |
| **Bloque D · Cobros y Comunicaciones** | Registro idempotente de movimientos de cobro (`MovimientoCobro`), conciliación automática/manual y reversiones trazables (`Conciliacion`), envío multicanal con plantillas versionadas (`Comunicacion`, `PlantillaComunicacion`) y gestión de recordatorios e impagos (`SuspensionRecordatorios`). | Recibe facturas de `Bloque C` y disparos de `Planificador` (`J2`, `J3`); opera mediante `<<interface>> SistemaPagos` y `<<interface>> CanalEnvio`; notifica rebotes e impagos a `Bloque E`; persiste en `Base de Datos Relacional`.

 |
| **Bloque E · Seguimiento, Consulta e Informes** | Pantalla de trabajo diario, bandeja de notificaciones y alertas parametrizables (`Notificacion`, `ReglaAlerta`), gestión de incidencias y comentarios internos (`Incidencia`, `Comentario`, `BR-20`), dashboard financiero, objetivos y centros de coste (`Informe`, `ObjetivoFacturacion`, `CentroCoste`). | Recibe eventos de `Bloque C`, `Bloque D` y `Planificador` (`J4`); guarda adjuntos e informes CSV/PDF en `Almacén Seguro de Archivos`; consulta apoyo opcional en `Adaptador IA Opcional`; persiste en `Base de Datos Relacional`.

 |
| **Bloque F · Administración y Sistema** | Administración de usuarios, roles y acciones masivas (`Usuario`, `Administrador`, `Superadministrador`, `AccionMasiva`), configuración global de series, impuestos, tarifas y plazos (`ConfiguracionSistema`, `SerieFacturacion`, `Impuesto`, `RangoTarifa`) y registro de solicitudes externas pendientes (`SolicitudExterna`). | Invocado por `API REST`; suministra reglas y parámetros a `Bloques B, C y D`; canaliza solicitudes externas revisables hacia `Bloque A`; persiste en `Base de Datos Relacional`.

 |
| **Auditoría Inmutable** | Registro de solo lectura (*append-only*) de quién hizo qué, cuándo y con qué valores anteriores y nuevos (`EventoAuditoria`), además de errores técnicos con identificador (`NFR-09`). | Recibe trazas de todos los módulos (`Bloques A–F`) y escribe en `Base de Datos Relacional` sin permitir modificación ni borrado.

 |
| **Monitorización y Métricas** | Seguimiento operativo del estado de las tareas programadas (`EjecucionTarea`), cola de correos pendientes, errores de integración con ID y métricas agregadas sin vigilancia individual (`CU-33`, `BR-08`). | Recibe reportes de `Planificador del Sistema` (`J1`–`J5`) y persiste estados en `Base de Datos Relacional`.

 |
| **Planificador del Sistema** | Ejecución desatendida y tolerante a fallos de tareas periódicas: facturación recurrente el día 1 (`J1`), flujo diario de recordatorios e impagos (`J2`), consulta periódica de pagos (`J3`), resumen diario de notificaciones (`J4`) y copias de seguridad automáticas (`J5`). | Dispara procesos en `Bloque C`, `Bloque D`, `Bloque E` y `Copias de Seguridad`; reporta su ejecución en `Monitorización y Métricas`.

 |
| **Capa de Integración (Puertos y Adaptadores)** | Desacopla el núcleo de negocio frente a servicios externos mediante interfaces (`SistemaPagos`, `CanalEnvio`) y adaptadores concretos para pasarelas (`Stripe`/`Revolut`), correo electrónico, `WhatsApp` simulado y el servicio opcional de IA (`Brain`). | Implementa puertos consumidos por `Bloque D`, `Bloque B` y `Bloque E`; se comunica con `Pasarelas de Pago`, `Proveedor de Correo` y `Servicio IA`.

 |
| **Base de Datos Relacional** | Almacenamiento transaccional ACID de todas las entidades de los bloques A–F, con aritmética decimal exacta sin coma flotante (`NFR-06`), secuencias atómicas de numeración y tabla de auditoría protegida. | Recibe operaciones CRUD de `Bloques A–F`, inserciones de `Auditoría Inmutable` y `Monitorización`; es respaldada por `Copias de Seguridad`.

 |
| **Almacén Seguro de Archivos** | Repositorio privado de documentos binarios (PDFs legales de facturas emitidas, contratos firmados, adjuntos de incidencias e informes exportados) accesibles únicamente mediante enlaces temporales firmados con caducidad de 1 hora (`NFR-17`, `A-03`). | Recibe ficheros desde `Bloque A`, `Bloque C` (`PDFGen`) y `Bloque E`; es respaldado por `Copias de Seguridad`.

 |
| **Copias de Seguridad** | Ejecución programada de respaldos cifrados de datos y documentos con validación periódica de restauración (`NFR-14`). | Ejecutado por `Planificador del Sistema` (`J5`); respalda `Base de Datos Relacional` y `Almacén Seguro de Archivos`.

 |

## Justificación y alternativas

* **Decisiones arquitectónicas principales:**
* **Arquitectura en capas con punto de entrada único (`API REST`):** Separar la `Aplicación Web Responsive` (`NFR-04`) de la capa de servidor mediante una `API REST` autenticada permite que la interfaz web y los sistemas externos compartan exactamente las mismas reglas de negocio y controles de autorización en servidor (`BR-07`, `NFR-07`), impidiendo que un cliente manipule rutas, salte aprobaciones o altere facturas emitidas (`BR-09`).


* **Monolito modular estructurado por dominio (`Bloques A–F`):** Organizar el backend en seis módulos cohesivos sobre una única base de datos relacional ACID responde a la escala esperada del sistema (miles de clientes y cientos de miles de facturas, `NFR-13`). Garantiza cálculos monetarios exactos en formato `DECIMAL` (`NFR-06`) y asignación atómica e idempotente de números correlativos por serie (`BR-10`) sin la complejidad de transacciones distribuidas.


* **Puertos y Adaptadores (Arquitectura Hexagonal) en integraciones:** Definir las interfaces `SistemaPagos` y `CanalEnvio` aísla el dominio de cambios de proveedor en pasarelas de cobro o mensajería (`BR-06`). Asimismo, encapsular el servicio de IA (`Brain`) tras `AIConnector` asegura que el sistema opere con normalidad sin dependencia crítica de la IA (`RB-03`) y exige confirmación humana para cualquier sugerencia económica (`BR-22`).


* **Procesamiento asíncrono y persistencia híbrida:** Delegar los lotes periódicos (emisión mensual del día 1, recordatorios, polling de cobros, resúmenes y backups) al `Planificador del Sistema` mantiene tiempos de respuesta inmediatos en las consultas interactivas (`NFR-12`) y facilita reanudar ejecuciones interrumpidas sin duplicar facturas (`NFR-15`). Separar `Base de Datos Relacional` de `Almacén Seguro de Archivos` evita sobrecargar la base transaccional con binarios y permite proteger PDFs e informes tras URLs temporales de 1 hora (`NFR-17`, `A-03`).




* **Restricciones y dependencias externas:**
* *Restricciones del dominio:* Prohibición de autorregistro y exigencia de dominio corporativo (`FR-06`, `A-01`); inmutabilidad de facturas emitidas (`BR-09`); separación estricta entre solicitante y aprobador en importes sensibles (`BR-12`); prohibición de escritura directa por API externa (`BR-21`); y conservación diferenciada entre documentos fiscales legales e informes temporales (`FR-37`, `BR-19`).


* *Dependencias externas:* Pasarelas de pago (`Stripe` / `Revolut`) para consulta y recepción de movimientos de cobro; `Proveedor de Correo` (`SMTP` / API) para entrega y detección de rebotes; canal simulado de `WhatsApp` (condicionado a consentimiento explícito del contacto); `Servicio IA (Brain)` opcional; y `Sistemas Externos` (`CRM` / `ERP`) que consumen la API documentada.




* **Alternativas consideradas y descartadas:**
* *Arquitectura de microservicios:* Descartada por sobreingeniería para el volumen de datos y equipo de TurbineH; fragmentar clientes, suscripciones, facturación y cobros en servicios independientes complicaría la consistencia transaccional de la numeración correlativa (`BR-10`), la conciliación y el despliegue reproducible (`NFR-11`).


* *Mutación directa desde sistemas externos vía API:* Descartada porque vulneraría `BR-21` y `BR-12`; toda operación de modificación enviada por un sistema externo se materializa como `SolicitudExterna` pendiente de revisión humana.


* *Ejecución síncrona de facturación masiva e informes:* Descartada porque bloquearía las peticiones web del usuario (`NFR-12`) y dificultaría la recuperación idempotente ante caídas (`NFR-15`).


* *Almacenamiento de PDFs en carpetas públicas o como BLOBs masivos en BD:* Descartado para impedir accesos por URLs adivinables (`NFR-17`) y evitar degradar las copias de seguridad y consultas transaccionales de `MainDB`.





## Trazabilidad

* **Bloque A · Clientes y contactos (`CU-01` a `CU-04`):**
* `CU-01` *(Gestionar cliente y contactos, incluyendo detección de duplicados `CU-02` absorbida como flujo de excepción)* se realiza mediante la cooperación de `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque A (ClientMgmt, TasksExc)`, `Almacén Seguro de Archivos` (para contratos firmados), `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-03` *(Importar datos por CSV)* se realiza mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque A (CSVImport)`, `Bloque C` (si incluye facturas históricas migradas), `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-04` *(Gestionar tareas del cliente)* se realiza mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque A (TasksExc)`, `Bloque E (DailyWork)`, `Auditoría Inmutable` y `Base de Datos Relacional`.




* **Bloque B · Suscripciones, tarifas y descuentos (`CU-05` a `CU-09`):**
* `CU-05` *(Gestionar baja y pausa de suscripción)* se realiza mediante `Aplicación Web Responsive` (y `Planificador del Sistema` en reactivaciones programadas), `API REST`, `Seguridad Transversal`, `Bloque B (SubMgmt)`, `Bloque E (DailyWork)`, `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-06` *(Revisar y aprobar rango de tarifa anual)* se realiza mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque B (SubMgmt)`, `Bloque F (SysConfig)`, `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-07`, `CU-08` y `CU-09` *(Solicitar descuento, Aprobar descuento y Escalar aprobación al Superadministrador)* se realizan mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal` (validación de rol y separación de funciones), `Bloque B (PricingDisc)`, `Bloque F (SysConfig)`, `Adaptador IA Opcional` (sugerencias opcionales), `Auditoría Inmutable` y `Base de Datos Relacional`.




* **Bloque C · Facturación (`CU-10` a `CU-15`):**
* `CU-10` *(Gestionar borrador de factura)* se realiza mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque C (BillingEngine)`, `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-11` y `CU-12` *(Generar facturas recurrentes y Emitir factura)* se realizan mediante `Planificador del Sistema (J1)` o `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque B (SubMgmt)`, `Bloque C (BillingEngine, ApprovalsRect, PDFGen)`, `Bloque D (CommsMgr)`, `Almacén Seguro de Archivos`, `Monitorización y Métricas`, `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-13` y `CU-14` *(Aprobar factura retenida y Rectificar, anular o declarar incobrable una factura)* se realizan mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque C (ApprovalsRect, BillingEngine, PDFGen)`, `Almacén Seguro de Archivos`, `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-15` *(Buscar y consultar facturas y clientes)* se realiza mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque C (BillingEngine)`, `Bloque A (ClientMgmt)`, `Base de Datos Relacional` y `Almacén Seguro de Archivos` (descarga autenticada de PDF).




* **Bloque D · Cobros y comunicaciones (`CU-16` a `CU-22`):**
* `CU-16` y `CU-17` *(Registrar movimiento de cobro y Conciliar pagos)* se realizan mediante `Planificador del Sistema (J3)` o `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque D (Reconcil)`, `<<interface>> SistemaPagos`, `Adaptador Pasarelas Pago`, `Pasarelas de Pago (Stripe/Revolut)`, `Bloque C (BillingEngine)`, `Monitorización y Métricas`, `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-18` y `CU-19` *(Enviar comunicación al cliente y Gestionar rebote de correo)* se realizan mediante `Bloque D (CommsMgr)`, `<<interface>> CanalEnvio`, `Adaptador Correo Electrónico`, `Adaptador WhatsApp`, `Proveedor de Correo`, `Bloque A (ClientMgmt)`, `Bloque E (IssuesMgr)`, `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-20`, `CU-21` y `CU-22` *(Ejecutar flujo de recordatorios e impago, Suspender recordatorios y Gestionar plantillas de comunicación)* se realizan mediante `Planificador del Sistema (J2)` o `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque D (CommsMgr)`, `Bloque F (SysConfig)`, `Monitorización y Métricas`, `Auditoría Inmutable` y `Base de Datos Relacional`.




* **Bloque E · Seguimiento, consulta e informes (`CU-23` a `CU-29`):**
* `CU-23` y `CU-24` *(Gestionar notificaciones y canales y Configurar alertas)* se realizan mediante `Aplicación Web Responsive`, `Planificador del Sistema (J4)`, `API REST`, `Seguridad Transversal`, `Bloque E (DailyWork)`, `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-25` *(Gestionar incidencias y comentarios)* se realiza mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque E (IssuesMgr, DailyWork)`, `Almacén Seguro de Archivos` (adjuntos), `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-26`, `CU-27` y `CU-28` *(Generar, exportar y conservar informes, Consultar dashboard financiero y Gestionar objetivos y centros de coste)* se realizan mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque E (ReportsDash)`, `Bloque C (BillingEngine)`, `Bloque D (Reconcil)`, `Adaptador IA Opcional`, `Almacén Seguro de Archivos` (exportaciones CSV/PDF), `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-29` *(Consultar pantalla de trabajo diario)* se realiza mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque E (DailyWork, IssuesMgr)`, `Bloque A (TasksExc)`, `Bloque C (ApprovalsRect)`, `Bloque D (Reconcil)` y `Base de Datos Relacional`.




* **Bloque F · Administración, seguridad y sistema (`CU-30` a `CU-37`):**
* `CU-30` y `CU-31` *(Iniciar sesión y recuperar contraseña y Gestionar usuarios, roles y asignación de clientes)* se realizan mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque F (UserAdmin)`, `Adaptador Correo Electrónico` (invitaciones y enlaces temporales), `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-32`, `CU-35` y `CU-36` *(Ejecutar acción masiva, Configurar facturación y tarifas y Configurar recordatorios y funciones inteligentes)* se realizan mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Bloque F (UserAdmin, SysConfig)`, `Adaptador IA Opcional`, `Auditoría Inmutable` y `Base de Datos Relacional`.


* `CU-33` y `CU-34` *(Consultar monitorización y métricas y Consultar registro de auditoría)* se realizan mediante `Aplicación Web Responsive`, `API REST`, `Seguridad Transversal`, `Monitorización y Métricas`, `Auditoría Inmutable`, `Planificador del Sistema (J5)` y `Base de Datos Relacional`.


* `CU-37` *(Consultar datos y operar por API)* se realiza mediante `Sistema Externo`, `API REST Documentada y Autenticada`, `Seguridad Transversal`, `Bloque F (ExtControl)`, `Bloque A` (revisión humana de solicitudes), `Auditoría Inmutable` y `Base de Datos Relacional`.