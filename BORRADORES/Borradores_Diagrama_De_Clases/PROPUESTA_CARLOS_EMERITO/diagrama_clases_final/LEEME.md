# Propuesta de diagrama de clases — Carlos Emérito

Propuesta individual para el sistema de facturación de **TurbineH (grupo JIRAFAS)**.
Sigue la división en bloques A–F de la especificación de casos de uso y la misma
organización de archivos que la propuesta final de Juan.

**62 clases y 35 enumeraciones**, con atributos, métodos, relaciones, notas y una
tabla de trazabilidad de los 50 requisitos funcionales.

## Archivos

| Archivo | Contenido |
|---|---|
| `plantuml/vista_general.puml` | Clases principales de cada bloque y sus relaciones, sin atributos |
| `plantuml/bloque_A.puml` … `bloque_F.puml` | Un diagrama por bloque, con atributos, métodos, enumeraciones, notas y clases de referencia |
| `plantuml/diagrama_clases_completo.puml` | Todas las clases con atributos y relaciones en un único diagrama |
| `svg/` | Imágenes generadas con PlantUML a partir de los `.puml` |

## Reparto por bloques

| Bloque | Casos de uso | Clases propias |
|---|---|---|
| **A — Clientes y contactos** | CU-01, CU-03, CU-04 | `Cliente`, `Contacto`, `ClienteContacto`, `Tarea`, `ExcepcionComercial`, `ImportacionCSV`, `FilaImportacion` |
| **B — Suscripciones, tarifas y descuentos** | CU-05 a CU-09 | `Suscripcion`, `Pausa`, `SolicitudAprobacion`, `SolicitudDescuento`, `RevisionTarifa`, `AprobacionExcepcion` |
| **C — Facturación** | CU-10 a CU-15 | `Factura`, `FacturaRectificativa`, `LineaFactura`, `ConceptoFacturable`, `DatosFiscalesFactura`, `AprobacionFactura`, `OperacionExcepcional`, `PeriodoFiscal`, `FiltroGuardado` |
| **D — Cobros y comunicaciones** | CU-16 a CU-22 | `SistemaPagos`, `ConectorStripe`, `ConectorRevolut`, `MovimientoCobro`, `Conciliacion`, `DiferenciaCobro`, `Comunicacion`, `IntentoEnvio`, `CanalEnvio`, `ProveedorCorreo`, `SimuladorWhatsApp`, `PlantillaComunicacion`, `VersionPlantilla`, `SuspensionRecordatorios` |
| **E — Seguimiento, consulta e informes** | CU-23 a CU-29 | `Notificacion`, `PreferenciaNotificacion`, `ReglaAlerta`, `Incidencia`, `Comentario`, `Adjunto`, `Informe`, `ObjetivoFacturacion`, `CambioObjetivo`, `CentroCoste`, `TipoCambio` |
| **F — Administración, seguridad y sistema** | CU-30 a CU-37 | `Usuario`, `Permiso`, `Sesion`, `EnlaceTemporal`, `EventoAuditoria`, `AccionMasiva`, `EjecucionTarea`, `ErrorTecnico`, `ConfiguracionSistema`, `FuncionInteligente`, `SerieFacturacion`, `Impuesto`, `RangoTarifa`, `ClienteAPI`, `SolicitudExterna` |

## Decisiones de diseño

### Identidad y accesos

- **El rol es una enumeración (`Rol`) y no una jerarquía de clases.** FR-07 permite
  cambiar el rol de un usuario y un objeto no puede cambiar de subclase. Los permisos
  configurables del Administrador se modelan aparte con `Permiso`.
- **`Sesion` y `EnlaceTemporal`** cubren la sesión segura, la invalidación al
  desactivar una cuenta y la recuperación de contraseña (FR-06, NFR-08, NFR-17).
- **No hay autorregistro**: el alta solo se produce por invitación.

### Clientes, suscripciones y facturación

- **`Cliente.estado` y `Suscripcion.estado` están separados.** La baja comercial
  detiene las mensualidades, pero no borra al cliente ni sus facturas (BR-14, BR-19).
- **La tarifa no se duplica en `Cliente` y `Suscripcion`.** Vive en `Suscripcion`,
  enlazada con `RangoTarifa`; la ficha comercial guarda lo pactado (FR-03).
- **`Pausa` conserva el historial.** Una suscripción puede pausarse y reactivarse
  varias veces sin perder los periodos anteriores (FR-16, BR-15).
- **`ConceptoFacturable` es el catálogo de conceptos.** `LineaFactura` copia concepto,
  precio, descuento e impuesto en el momento de emitir, de modo que cambiar el catálogo
  no reescribe facturas históricas (BR-09, BR-11).
- **`DatosFiscalesFactura` es una copia tomada al emitir.** Los cambios posteriores
  del cliente, del emisor o de las tarifas no alteran la factura (BR-11).
- **`PeriodoFiscal`** modela el cierre trimestral: bloquea la edición ordinaria de las
  facturas del periodo y solo el Superadministrador puede reabrirlo con un motivo (FR-14).
- **Una factura retenida no es un estado.** FR-19 no lo incluye: la factura sigue en
  `BORRADOR` con una `AprobacionFactura` pendiente que guarda la causa (FR-13).

### Aprobaciones

- **`SolicitudAprobacion` es una jerarquía única.** Descuentos, revisiones de tarifa,
  excepciones comerciales, retenciones de factura y operaciones excepcionales comparten
  estado, motivo, nivel requerido, solicitante y aprobador.
- **`puedeResolver` comprueba la separación de funciones**: en importes sensibles el
  aprobador no puede ser el solicitante (BR-12).
- **`motivoPendiente` explica siempre por qué una solicitud espera** (FR-18).

### Cobros y comunicaciones

- **`SistemaPagos` y `CanalEnvio` son interfaces** con implementaciones concretas.
  Incorporar otro proveedor de pagos o de mensajería no cambia el modelo (BR-06).
- **`MovimientoCobro.idEventoExterno` es único**: un evento repetido no se contabiliza
  dos veces (FR-15).
- **`Conciliacion.revertir` no borra el evento**: queda constancia de quién o qué regla
  concilió, quién revirtió, cuándo y por qué (FR-22).
- **`DiferenciaCobro`** detecta pagos insuficientes o en exceso sin marcar la factura
  como pagada (FR-21).
- **`IntentoEnvio` y `VersionPlantilla`** permiten saber qué se envió, por qué canal,
  a quién, con qué resultado y con qué texto exacto (FR-26, FR-46, BR-11).

### Seguimiento e informes

- **`EventoAuditoria` es la única fuente de la línea temporal del cliente.** Evita
  duplicar una clase `EventoLineaTemporal` y alimenta la auditoría y la trazabilidad
  (FR-43, NFR-09).
- **`PreferenciaNotificacion`** permite elegir por categoría si la notificación se ve
  en la aplicación, se envía por email o entra en el resumen diario (FR-24, FR-42).
- **`Informe` puede reutilizar un `FiltroGuardado`** (FR-25, FR-28).
- **`CambioObjetivo`** registra autor, fecha y valores anterior y nuevo de cada
  modificación de objetivos (FR-41).
- **El dashboard y la pantalla de trabajo diario no tienen clase propia**: son vistas
  calculadas sobre `Factura`, `MovimientoCobro`, `Notificacion`, `Tarea` y
  `SolicitudAprobacion` (FR-29, FR-50).

### Reglas transversales

- **Importes en `Decimal`** para evitar pérdidas de céntimos (NFR-06).
- **`version` en las entidades que se editan a la vez** para el control de edición
  concurrente (NFR-13).
- **Estados y tipos como enumeraciones**, no como `String` con notas, para que el
  diagrama sea verificable.
- **Referencias corregidas**: la ficha comercial es FR-03 (no FR-24), la monitorización
  es CU-33 (no CU-34) y la gestión de usuarios es CU-31 (no CU-32).

## Qué aporta esta propuesta

Tomando como base la estructura combinada de Juan y Pablo, esta versión añade o
refuerza:

- **`ConceptoFacturable`** como catálogo explícito, con copia de valores en la línea.
- **`PeriodoFiscal`** con cierre y reapertura motivada.
- **`Informe` → `FiltroGuardado`**, para reutilizar los filtros guardados del buscador.
- **`Cliente.estado` independiente de `Suscripcion.estado`**, para no mezclar la baja
  comercial con el ciclo de vida del cliente.
- **Jerarquía de aprobaciones cerrada y común**, en lugar de aprobaciones sueltas.
- **Enumeraciones completas** para todos los estados, canales, tipos y resultados.

## Cobertura de requisitos funcionales

| FR | Dónde se modela |
|---|---|
| FR-01 | `Factura`, `SerieFacturacion`, `Impuesto` |
| FR-02 | `Factura.tipo`, `LineaFactura`, `ConceptoFacturable` |
| FR-03 | `Cliente`, `Cliente.fechaInicio`, `Suscripcion` |
| FR-04 | `Contacto`, `ClienteContacto`, `IntentoEnvio.destinatario` |
| FR-05 | `ConfiguracionSistema`, `Cliente.vencimientoPactadoDias`, `SuspensionRecordatorios` |
| FR-06 | `Usuario`, `Sesion`, `EnlaceTemporal`, `ConfiguracionSistema.dominiosAutorizados` |
| FR-07 | `Usuario.rol`, `Permiso`, asignación de clientes |
| FR-08 | `ImportacionCSV`, `FilaImportacion` |
| FR-09 | `Suscripcion.darDeBaja`, `Cliente.fechaBaja`, `EstadoCliente.BAJA` |
| FR-10 | `RevisionTarifa` |
| FR-11 | `Suscripcion.calcularProrrateo`, `EjecucionTarea` |
| FR-12 | `Factura.rutaPDF`, `Factura.hashPDF` |
| FR-13 | `AprobacionFactura`, `CausaRetencion` |
| FR-14 | `PeriodoFiscal`, `Factura.estaBloqueada` |
| FR-15 | `SistemaPagos`, `MovimientoCobro` |
| FR-16 | `Pausa` |
| FR-17 | `RangoTarifa.fechaEfecto` |
| FR-18 | `SolicitudDescuento`, `SolicitudAprobacion.motivoPendiente` |
| FR-19 | `EstadoFactura` |
| FR-20 | `Factura.validarDatosFiscales` |
| FR-21 | `DiferenciaCobro` |
| FR-22 | `Conciliacion.revertir` |
| FR-23 | `IntentoEnvio.resultado`, `Incidencia.reboteDe` |
| FR-24 | `Notificacion`, `PreferenciaNotificacion` |
| FR-25 | `Informe` |
| FR-26 | `PlantillaComunicacion`, `VersionPlantilla` |
| FR-27 | `Cliente.buscarDuplicados` |
| FR-28 | `FiltroGuardado` |
| FR-29 | Vista calculada (nota del bloque E) |
| FR-30 | Comportamiento de interfaz |
| FR-31 | `AccionMasiva` |
| FR-32 | `Tarea` |
| FR-33 | `Cliente.etiquetas`, `Cliente.sector`, `Cliente.ubicacion` |
| FR-34 | `Incidencia`, `Adjunto` |
| FR-35 | `Comentario` |
| FR-36 | `Comentario` menciona a `Usuario` |
| FR-37 | `Informe.fechaCaducidad`, `ConfiguracionSistema.diasConservacionInformes` |
| FR-38 | `EjecucionTarea` |
| FR-39 | `FuncionInteligente` |
| FR-40 | `CentroCoste` |
| FR-41 | `ObjetivoFacturacion`, `CambioObjetivo` |
| FR-42 | `ReglaAlerta`, `PreferenciaNotificacion` |
| FR-43 | `EventoAuditoria.clienteAfectado` |
| FR-44 | Asociación `Usuario`–`Cliente` de favoritos |
| FR-45 | `FacturaRectificativa`, `OperacionExcepcional` |
| FR-46 | `Comunicacion`, `IntentoEnvio`, `CanalEnvio` |
| FR-47 | `ExcepcionComercial`, `AprobacionExcepcion` |
| FR-48 | `EjecucionTarea`, `ErrorTecnico` |
| FR-49 | `ClienteAPI`, `SolicitudExterna` |
| FR-50 | Vista calculada (nota del bloque E) |

## Cómo regenerar las imágenes

Desde `PROPUESTA_CARLOS_EMERITO/diagrama_clases_final`:

```bash
java -jar plantuml.jar -charset UTF-8 -tsvg -o svg plantuml/*.puml
```

Los `.puml` son la fuente de verdad; los `.svg` se pueden regenerar en cualquier
momento con una versión reciente de PlantUML.
