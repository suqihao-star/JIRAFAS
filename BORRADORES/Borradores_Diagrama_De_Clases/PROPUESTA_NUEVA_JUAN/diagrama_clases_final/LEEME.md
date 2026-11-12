# Diagrama de clases final (Juan + Pablo)

Versión combinada de `diagramas_clases_juan` y `PROPUESTA_NUEVA_PABLO_FERNÁNDEZ_CARABANTES`.
61 clases y 35 enumeraciones, repartidas en los bloques A–F de la especificación de casos de uso.

## Archivos

| Archivo | Contenido |
|---|---|
| `vista_general` | Clases principales de cada bloque y sus relaciones, sin atributos |
| `bloque_A` … `bloque_F` | Un diagrama por bloque, con atributos, métodos, enumeraciones y notas |
| `diagrama_clases_completo` | Todas las clases con atributos en un solo diagrama |

Cada uno está en `plantuml/*.puml` (código) y `svg/*.svg` (imagen generada con PlantUML).

## Qué se ha tomado de cada propuesta

**De Pablo (estructura base)**
- Reparto por bloques fiel a la especificación: `Incidencia` en E, `SuspensionRecordatorios` en D, `FiltroGuardado` en C.
- Paquetes grises para las clases de otros bloques y títulos con los CU de cada bloque.
- `ConfiguracionSistema` única, con valores por defecto de los recordatorios (3, 5 y 2 días).
- `FacturaRectificativa` como subclase de `Factura`.
- `OperacionExcepcional` para rectificar, anular, declarar incobrable o cancelar.
- `EventoAuditoria` como fuente de la línea temporal del cliente.
- Menciones como asociación `Comentario` → `Usuario`, y etiquetas como lista en `Cliente`.

**De Juan (lo que exigen los requisitos y faltaba)**
- Jerarquía `SolicitudAprobacion` con separación de funciones (BR-12) y motivo de espera (FR-18).
- `IntentoEnvio`: canal, intento, resultado, fecha y destinatario de cada envío (FR-46).
- `VersionPlantilla`: qué texto se usó en cada envío (FR-26, BR-11).
- `DiferenciaCobro` (FR-21) y `reglaAplicada` en `Conciliacion` (FR-22).
- `DatosFiscalesFactura`: copia de los datos al emitir (BR-11).
- `Pausa` con historial (FR-16), `CambioObjetivo` (FR-41) y `PreferenciaNotificacion` (FR-24).
- `Sesion`, `EnlaceTemporal` y `Permiso` (FR-06, FR-07, NFR-08).
- Interfaces `SistemaPagos` y `CanalEnvio` con sus implementaciones (BR-06).
- `ErrorTecnico` (NFR-09), `ClienteAPI` (FR-49) y `TipoCambio` (RB-02).
- Enumeraciones para todos los estados y tipos, en lugar de `String` con notas.

**Nuevo (no estaba en ninguna)**
- `PeriodoFiscal`: cierre trimestral y reapertura por el Superadministrador (FR-14).
- `Comentario` también sobre facturas y clientes, no solo incidencias (FR-35).
- Estados `INCOBRABLE` y `CANCELADA` en `EstadoFactura` (CU-14, CU-20).
- `FilaImportacion` enlazada con la factura migrada (FR-08).
- Atributos que faltaban: `prioridad` en `Incidencia` (FR-34), `resuelta` en `Notificacion` (FR-24), descuento e impuesto por línea (FR-02), `concepto` en `MovimientoCobro` (FR-15).

**Corregido**
- Referencias erróneas: ficha comercial es FR-03 (no FR-24), monitorización es CU-33 (no CU-34), gestión de usuarios es CU-31 (no CU-32).
- La tarifa ya no está duplicada en `Cliente` y `Suscripcion`: vive en `Suscripcion`, enlazada con `RangoTarifa`.
- `ExcepcionComercial` se aprueba con `AprobacionExcepcion`, no con una solicitud de descuento.

## Decisiones que conviene saber defender

- **Rol como enumeración y no como herencia.** FR-07 permite cambiar el rol de un usuario y un objeto no puede cambiar de subclase. Los permisos configurables del Administrador van en `Permiso`.
- **Factura retenida no es un estado.** FR-19 no la incluye: la factura sigue en `BORRADOR` con una `AprobacionFactura` pendiente que guarda la causa.
- **Dashboard y pantalla de trabajo diario sin clase propia.** Son vistas calculadas sobre clases existentes (nota en el bloque E).
- **`version` en las entidades que se editan a la vez**, para el control de edición concurrente (NFR-13). Importes en `Decimal` (NFR-06).

## Cobertura de requisitos funcionales

| FR | Dónde se modela |
|---|---|
| FR-01 | Factura, SerieFacturacion, Impuesto |
| FR-02 | Factura.tipo, LineaFactura |
| FR-03 | Cliente, Suscripcion |
| FR-04 | Contacto, ClienteContacto, IntentoEnvio.destinatario |
| FR-05 | ConfiguracionSistema, Cliente.vencimientoPactadoDias, SuspensionRecordatorios |
| FR-06 | Usuario, Sesion, EnlaceTemporal, ConfiguracionSistema.dominiosAutorizados |
| FR-07 | Usuario.rol, Permiso, asignadoA |
| FR-08 | ImportacionCSV, FilaImportacion |
| FR-09 | Suscripcion.darDeBaja, EstadoCliente.BAJA |
| FR-10 | RevisionTarifa |
| FR-11 | Suscripcion.calcularProrrateo, EjecucionTarea |
| FR-12 | Factura.rutaPDF/hashPDF |
| FR-13 | AprobacionFactura, CausaRetencion |
| FR-14 | PeriodoFiscal, Factura.estaBloqueada |
| FR-15 | SistemaPagos, MovimientoCobro |
| FR-16 | Pausa |
| FR-17 | RangoTarifa.fechaEfecto |
| FR-18 | SolicitudDescuento, SolicitudAprobacion.motivoPendiente |
| FR-19 | EstadoFactura |
| FR-20 | Factura.validarDatosFiscales |
| FR-21 | DiferenciaCobro |
| FR-22 | Conciliacion.revertir |
| FR-23 | IntentoEnvio.resultado, Incidencia reboteDe |
| FR-24 | Notificacion, PreferenciaNotificacion, responsableInterno |
| FR-25 | Informe |
| FR-26 | PlantillaComunicacion, VersionPlantilla |
| FR-27 | Cliente.buscarDuplicados |
| FR-28 | FiltroGuardado |
| FR-29 | vista calculada (nota bloque E) |
| FR-30 | comportamiento de interfaz |
| FR-31 | AccionMasiva |
| FR-32 | Tarea |
| FR-33 | Cliente.etiquetas/sector/ubicacion |
| FR-34 | Incidencia, Adjunto |
| FR-35 | Comentario |
| FR-36 | Comentario menciona Usuario |
| FR-37 | Informe.fechaCaducidad, ConfiguracionSistema.diasConservacionInformes |
| FR-38 | EjecucionTarea |
| FR-39 | FuncionInteligente |
| FR-40 | CentroCoste |
| FR-41 | ObjetivoFacturacion, CambioObjetivo |
| FR-42 | ReglaAlerta, PreferenciaNotificacion |
| FR-43 | EventoAuditoria clienteAfectado |
| FR-44 | favoritos |
| FR-45 | FacturaRectificativa, OperacionExcepcional |
| FR-46 | Comunicacion, IntentoEnvio, CanalEnvio |
| FR-47 | ExcepcionComercial, AprobacionExcepcion |
| FR-48 | EjecucionTarea, ErrorTecnico |
| FR-49 | ClienteAPI, SolicitudExterna |
| FR-50 | vista calculada (nota bloque E) |
