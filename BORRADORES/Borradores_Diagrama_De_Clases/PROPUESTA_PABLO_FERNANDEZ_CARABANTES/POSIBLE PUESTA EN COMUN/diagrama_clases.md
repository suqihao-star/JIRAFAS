# Diagrama UML de clases

## Alcance
Diagrama de clases grupo Jirafas. El diagrama tiene 40 clases, con una clase abstracta, Usuario, enumeraciones para definir los tipos de un atributo e interfaces. Ademas cuenta con numerosos atributos y operaciones divididos en 6 bloques como pasaba en el diagrama de casos de uso UML de la primera entrega. La tabla recoge las clases; cada enumeración está dentro del paquete de la clase que la usa:
| Paquete | Clases |
|---|---|
| A · Clientes y contactos | `Cliente`, `Contacto`, `ClienteContacto`, `Tarea`, `ExcepcionComercial`, `ImportacionCSV`, `FilaImportacion` |
| B · Suscripciones, tarifas y descuentos | `Suscripcion`, `RevisionTarifaAnual`, `SolicitudDescuento` |
| C · Facturación | `Factura`, `FacturaRectificativa`, `LineaFactura`, `AprobacionFactura`, `OperacionExcepcional`, `FiltroGuardado` |
| D · Cobros y comunicaciones | `MovimientoCobro`, `Conciliacion`, `Comunicacion`, `PlantillaComunicacion`, `SuspensionRecordatorios`, interfaces `SistemaPagos` y `CanalEnvio` |
| E · Seguimiento, consulta e informes | `Notificacion`, `ReglaAlerta`, `Incidencia`, `Comentario`, `Informe`, `ObjetivoFacturacion`, `CentroCoste` |
| F · Administración, seguridad y sistema | `Usuario`, `UsuarioOperativo`, `Administrador`, `Superadministrador`, `EventoAuditoria`, `AccionMasiva`, `EjecucionTarea`, `ConfiguracionSistema`, `SerieFacturacion`, `Impuesto`, `RangoTarifa`, `SolicitudExterna` |

Cubre los 36 casos de uso que se definieron en la entrega 1.

En el apartado de diagramas del repositorio se encuentran los codigos .puml de cada diagrama. Incluye el diagrama completo y los diagramas por bloques para que se entiendan de una forma correcta.

## Decisiones de diseño
- **Herencia de roles.** `Usuario` <- `UsuarioOperativo` <- `Administrador` <- `Superadministrador` repite la herencia de actores del UML de casos de uso: cada rol puede hacer todo lo del anterior. Por eso el Superadministrador no repite `aprobarDescuento()`: la hereda de `Administrador`.
- **Descuentos por encima del umbral.** `SolicitudDescuento` tiene `superaUmbral()` y `escalar()`, y `Superadministrador` tiene `resolverEscalado()`. La regla de que la solicitud escalada la resuelve el Superadministrador (FR-18, CU-08 FA-3, CU-09) va en una nota, porque una asociación no puede expresar una condición.
- **Composicion**. Son composiciones `Factura` con `LineaFactura`, `ImportacionCSV` con `FilaImportacion`, `Cliente` con `Tarea`, `Suscripcion` y `ExcepcionComercial`, `Incidencia` con `Comentario` y `Usuario` con `FiltroGuardado`. En todos los casos la parte no tiene sentido sin el todo. En cambio `ConfiguracionSistema` se relaciona con series, impuestos y rangos mediante una asociación «configura»: esos catálogos tienen vida propia.
- **Clase asociación.** `ClienteContacto` guarda el tipo de contacto que es contratación, facturación o impagos, de cada pareja cliente–contacto, que es una relación de muchos a muchos como se ve reflejado en FR-04.
- **Factura rectificativa como subclase.** `FacturaRectificativa` hereda de `Factura` y se vincula a la original con `rectificaA` se ve en FR-45. Es una factura mas: tiene numero, serie y PDF
- **Integraciones encapsuladas.** Stripe, Revolut y el proveedor de correo no son clases: se accede a ellos con las interfaces `SistemaPagos` y `CanalEnvio` (BR-06). La procedencia del cobro se guarda en `MovimientoCobro.fuente`, y así se pueden añadir otras fuentes de pago como se indicó en FR-15.
- **Estados y tipos como enumeraciones.** Cada estado o tipo con valores cerrados es una enumeración dentro del paquete de su clase, y el atributo usa ese tipo en lugar de `String`. Cada clase tiene una dependencia hacia las enumeraciones que usan sus atributos. Los atributos cuyos valores no son cerrados como `Notificacion.categoria`, `AccionMasiva.tipo`, `SolicitudExterna.tipo` e idiomas son del tipo `String`.
- **Tipos de datos.** `Decimal` para importes, nunca `Float`, para no perder céntimos (NFR-06); `Fecha` (dia), `FechaHora` (dia y hora) y `Archivo` (documento binario, como el PDF de la factura, FR-12). `[0..1]` marca un atributo opcional y `/` un atributo derivado.
- **Aprobación de facturas retenidas como clase.** Cada retención es un objeto `AprobacionFactura`, composición con `Factura`, con su motivo (FR-18), estado, fechas, motivo de la decisión, solicitante y aprobador. Así se recogemos todos los casos de CU-13 y los flujos: una nueva retención tras un rechazo (FA-1), la aprobación pendiente por falta de información con su motivo (FA-2, `solicitarInformacion()`), evitar decisiones contradictorias comprobando el estado (FE-2) y conservar la aprobación si la emisión falla (FE-3). `Factura` solo guarda `retenida` para saber si ahora mismo está retenida; el resto no se duplica. Sigue el mismo patrón que `SolicitudDescuento`, `RevisionTarifaAnual` y `OperacionExcepcional`.
- **Creador de la factura.** `creadaPor` es `0..1` porque las facturas recurrentes las genera el Planificador, no una persona (CU-11).
- **Atributo derivado.** `/saldoPendiente` se calcula a partir del total y de las conciliaciones (FR-21); la barra es la notación UML de atributo derivado.
- **Borrador incompleto.** Un borrador puede no tener aun lineas, serie, número ni fecha de emisión (CU-10): por eso `Factura *-- 0..* LineaFactura`, `SerieFacturacion 0..1 -- Factura` y `numero`, `fechaEmision` son `[0..1]`. Para emitir se exige al menos una línea y una serie (CU-12)
- **Datos fiscales de la emisión.** `Factura.datosFiscalesEmision` conserva los datos fiscales del cliente tal como estaban al emitir, para que un cambio posterior en la ficha no reescriba la factura (BR-09).
- **Origen de las facturas recurrentes.** `EjecucionTarea -- genera -- Factura` indica que ejecución del Planificador generó cada mensualidad. Al reanudar una ejecución interrumpida se sabe qué facturas existen ya y no se duplican (CU-11 FA-3, NFR-15).
- **Objetivos de facturación.** Los gestiona el Administrador (`Administrador - gestiona - ObjetivoFacturacion`; FR-41, actor de CU-28). Un objetivo solo tiene valor y periodo (CU-28 paso 4); los centros de coste clasifican clientes y facturas (CU-28 FA-2), no objetivos.
- **Factura emitida inmutable (BR-09).** Se indica en la nota de `Factura`. `LineaFactura.porcentajeImpuesto` copia el porcentaje al emitir para que un cambio en `Impuesto` no altere facturas históricas como se ve en BR-11.
- **Separación de funciones (BR-12).** Las clases que se aprueban tienen dos asociaciones distintas con usuarios: `AprobacionFactura`, `SolicitudDescuento`, `OperacionExcepcional` y `AccionMasiva` (`solicitante` / `aprobador`).
- **Un objeto `Comunicacion` por intento.** Cada intento, reenvío o canal es una `Comunicacion` con su `numeroIntento` y una copia del correo usado (`correoDestinatario`), de modo que el historial de envíos de una factura queda completo aunque el contacto se desactive o se anonimice (FR-04, FR-46, CU-18, CU-19)
- **Excepción comercial con efecto economico.** Se aprueba mediante `SolicitudDescuento`, como se especifica en CU-01 FA-4.
- **Línea temporal del cliente.** No tiene clase propia: la alimenta `EventoAuditoria` (FR-43), el cual es inmutable y guarda errores tecnicos con `idError` (NFR-09).
- **Configuración única.** `ConfiguracionSistema` agrupa los parámetros del Superadministrador: umbrales, plazos de recordatorio, dominio corporativo FR-06, comprobado con `admiteCorreo()`, conservacion de informes (FR-37) y datos del emisor.
- **Operaciones.** Ilustran responsabilidades. No son firmas finales de implementación. Las consultas comoo busqueda, dashboard o pantalla de trabajo diario no tienen clase propia, porque trabajan sobre los datos de las clases existentes.

## Trazabilidad
| Requisito / CU | Clases y operaciones | Motivo |
|---|---|---|
| FR-03, FR-04, FR-27, FR-30, FR-33, FR-44, FR-47 · CU-01 | `Cliente.darDeAlta`, `Cliente.editar`, `Cliente.comprobarDuplicado`, `Cliente.ubicacion`, `Cliente.documentoFirmado`, `Contacto.desactivar`, `ClienteContacto`, `ExcepcionComercial`, `Suscripcion.calcularProrrateo`, asociación `favoritos` | Alta y mantenimiento de la ficha fiscal y comercial, contactos N:M, aviso de duplicados sin fusionar, prorrateo previo y excepciones comerciales. |
| FR-08 · CU-03 | `ImportacionCSV.incluyeFacturasHistoricas`, `ImportacionCSV.validar`, `.previsualizar`, `.confirmar`, `.cancelar`, `FilaImportacion` (estados VALIDA, ERROR, DUPLICADO, DATOS_INCOMPLETOS, EXCLUIDA y `marcadaComoActualizacion`), `Factura.migrada` | Importación masiva con previsualización, motivos de rechazo y facturas históricas marcadas como migradas. |
| FR-32 · CU-04 | `Tarea.completar`, composición de `Cliente` con `Tarea` | Las tareas pertenecen al cliente y pasan al nuevo responsable si este cambia. |
| FR-09, FR-16, BR-14, BR-15 · CU-05 | `Suscripcion.pausar`, `.reactivar`, `.darDeBaja`, `Cliente.darDeBaja` | La pausa y la baja son estados distintos; la baja detiene mensualidades pero no el recobro. |
| FR-10, FR-17 · CU-06 | `RevisionTarifaAnual.fechaRevision`, `.aprobar`, `.rechazar`, `RangoTarifa` | Rango propuesto, precio anterior y nuevo, y quién aprobó y cuándo. |
| FR-18 · CU-07 | `UsuarioOperativo.solicitarDescuento`, `SolicitudDescuento` | La solicitud queda pendiente de aprobación con tipo, valor, motivo y vigencia. |
| FR-18, BR-12 · CU-08 | `Administrador.aprobarDescuento`, `SolicitudDescuento.aprobar`, `.rechazar`, `.superaUmbral`, `.escalar` | Aprobación del Administrador; por encima del umbral, escalado. |
| FR-18 · CU-09 | `Superadministrador.resolverEscalado` | Decisión final del superadministrador sobre la solicitud escalada. |
| FR-02, FR-13 · CU-10 | `Factura` en estado BORRADOR (sin líneas, serie ni numero al principio), `LineaFactura.calcularImporte`, `Factura.calcularTotales`, `Impuesto` | Borrador con varias líneas (concepto, cantidad, precio, descuento e impuesto), editable hasta emitir. |
| FR-11, BR-17, NFR-15 · CU-11 | `EjecucionTarea.reanudar`, asociación `EjecucionTarea` genera `Factura`, `Suscripcion.esFacturable`, `Suscripcion.calcularProrrateo`, `ExcepcionComercial`, `Factura.periodoFacturado` | Generación mensual por el Planificador, con prorrateo y sin duplicar la mensualidad de un periodo. |
| FR-01, FR-12, FR-14, FR-19, FR-20, BR-09, BR-10 · CU-12 | `UsuarioOperativo.emitirFactura`, `Factura.validarDatosFiscales` (devuelve lo que falta), `.detectarCausaRetencion`, `.emitir`, `.generarPDF`, `Factura.datosFiscalesEmision`, `SerieFacturacion.asignarSiguienteNumero` | Validación previa que indica qué falta, retención si hay un cambio sensible, número único en la serie, PDF guardado y bloqueo tras la emisión. |
| FR-13, FR-18, BR-12 · CU-13 | `Administrador.aprobarFacturaRetenida`, `AprobacionFactura.aprobar`, `.rechazar`, `.solicitarInformacion`, `.motivoRetencion`, `.estado`, asociaciones `solicitante` / `aprobador`, `Factura.retenida` | Revisión humana de cambios sensibles con historial de cada retención; quien aprueba no es quien la solicitó. |
| FR-19, FR-45, BR-13 · CU-14 | `OperacionExcepcional.aprobar`, `.ejecutar`, `FacturaRectificativa`, `Factura.anular` | Rectificar, anular, declarar incobrable o cancelar con motivo y aprobación, sin que nada pase a «pagada». |
| FR-28 · CU-15 | `FiltroGuardado.aplicar`, `Factura.documentoPDF`, asociación `favoritos` | Busqueda con filtros guardados y descarga del PDF conservado. |
| FR-15, BR-13 · CU-16 | `SistemaPagos.consultarPagos`, `MovimientoCobro.esDuplicado`, `Conciliacion` (tipo AUTOMATICA) | Un evento de cobro duplicado no se contabiliza dos veces; conciliacion automatica si la referencia es clara. |
| FR-15, FR-21, FR-22 · CU-17 | `UsuarioOperativo.conciliarPago`, `Factura.registrarCobro`, `Conciliacion.revertir`, `Factura./saldoPendiente`, asociaciones `realizadaPor` / `revertidaPor` | Conciliación manual, un cobro repartido entre varias facturas, sobrepago señalado y reversión trazada. |
| FR-26, FR-46 · CU-18 | `Comunicacion.enviar`, `.registrarResultado`, `.correoDestinatario`, `CanalEnvio.enviar`, `PlantillaComunicacion`, asociación `destinatario` | Envío con plantilla e idioma; se registran intento, canal, resultado, fecha y destinatario |
| FR-23 · CU-19 | `Comunicacion` (estado REBOTADA), `Comunicacion.reenviar(c : Contacto)`, `Incidencia.resolver(comentario)` | Un rebote no marca la factura como notificada, abre una incidencia y permite reenviar. |
| FR-05, BR-14, BR-16 · CU-20 | `EjecucionTarea` (RECORDATORIOS), `ConfiguracionSistema`, `Cliente.vencimientoPactadoDias`, `Factura.fechaVencimiento`, `Comunicacion` | Recordatorio previo, de vencimiento y de impago; el vencimiento pactado prevalece. |
| FR-05 · CU-21 | `SuspensionRecordatorios.reanudar` | Suspensión de los avisos de una factura con motivo y fecha de revisión. |
| FR-26, BR-11 · CU-22 | `PlantillaComunicacion.previsualizar`, `.version` | Plantillas editables y versionadas; los envíos anteriores conservan su versión. |
| FR-24, FR-36 · CU-23 | `Notificacion.marcarLeida`, `.marcarResuelta`, `.requiereAccion`, `Usuario.preferenciasNotificacion` | Bandeja con leída y resuelta por separado, y canales por usuario. |
| FR-42 · CU-24 | `ReglaAlerta.evaluar` | Conjunto cerrado de reglas parametrizables, sin motor de procesos |
| FR-34, FR-35, FR-36, BR-20 · CU-25 | `Incidencia.resolver`, `Comentario`, asociación `menciona`, `Notificacion` | Incidencias con responsable, prioridad y adjuntos; comentarios siempre internos; las menciones avisan. |
| FR-25, FR-37 · CU-26 | `Informe.generar`, `.exportar`, `.regenerar`, `.fechaCaducidad` | Informes filtrados, exportables a CSV o PDF, con caducidad y regenerables. |
| FR-29 · CU-27 | Consulta sobre `Factura`, `Conciliacion`, `ObjetivoFacturacion`, `CentroCoste` | El dashboard no tiene clase propia: sus cifras se derivan de datos ya registrados. |
| FR-40, FR-41 · CU-28 | `ObjetivoFacturacion.modificar`, asociación `Administrador` gestiona `ObjetivoFacturacion`, `CentroCoste.activo` | Objetivos informativos y categorías; los cambios quedan en `EventoAuditoria`. |
| FR-50 · CU-29 | Consulta sobre `Factura`, `MovimientoCobro` (`asignadoA`), `Comunicacion`, `SolicitudDescuento`, `Tarea` | La pantalla de trabajo diario reúne los asuntos pendientes sin clase propia. |
| FR-06, NFR-08 · CU-30 | `Usuario.iniciarSesion`, `.recuperarContrasena`, `.cerrarSesion`, `.bloqueadoHasta`, `ConfiguracionSistema.admiteCorreo` | Acceso solo con correo del dominio corporativo; bloqueo por intentos fallidos |
| FR-07 · CU-31 | `Administrador.invitarUsuario`, `.cambiarRol`, `Usuario.desactivar`, `Cliente.cambiarResponsable`, asociación `responsableInterno` | Alta por invitación, cambio de rol y asignación de clientes al responsable |
| FR-31 · CU-32 | `AccionMasiva.mostrarAlcance`, `.confirmar`, `.revertir`, asociación `aprobador` | Alcance exacto antes de ejecutar; las de alto impacto las aprueba otra persona. |
| FR-38, FR-48 · CU-33 | `EjecucionTarea`, `EjecucionTarea.reanudar`, `Comunicacion` (estado EN_COLA), `EventoAuditoria.idError` | Monitorización de tareas, cola de correos, errores y copias de seguridad, con metricas agregadas. |
| NFR-09 · CU-34 | `Superadministrador.consultarAuditoria`, `EventoAuditoria` | Registro de solo lectura con valores anteriores y nuevos |
| FR-01, FR-17 · CU-35 | `Superadministrador.modificarConfiguracion`, `ConfiguracionSistema.validar`, `SerieFacturacion`, `Impuesto`, `RangoTarifa` | Los cambios se aplican solo a facturas y revisiones futuras |
| FR-05, FR-39 · CU-36 | `ConfiguracionSistema` (días de recordatorio, `funcionesInteligentesActivas`, `diasConservacionInformes`) | Cadencia de recordatorios configurable. Funciones inteligentes opcionales. |
| FR-49, BR-21 · CU-37 | `SolicitudExterna.marcarPendienteRevision` | Lo que llega por la API se registra para revisión. Nunca modifica datos directamente |

## Consistencia con otros modelos

**Con el diagrama de casos de uso UML de la Entrega 1.** Cada paquete corresponde a un bloque (A–F) y la herencia de roles es la misma que la de los actores. Los actores externos no son clases:

| Actor | Cómo aparece en el diagrama de clases |
|---|---|
| Sistema de pagos (Stripe/Revolut) | Interfaz `SistemaPagos` y atributo `MovimientoCobro.fuente` |
| Proveedor de correo | Interfaz `CanalEnvio` |
| Planificador del sistema | Clase `EjecucionTarea`, que registra cada ejecución |
| Sistema externo (API) | Clase `SolicitudExterna` |

**Con el modelo entidad-relación**. No toda clase es una tabla ni toda tabla sale de una clase. La correspondencia actual es:

| En el diagrama de clases | En el ER | Por qué |
|---|---|---|
| `Usuario`, `UsuarioOperativo`, `Administrador`, `Superadministrador` | Una tabla `USUARIO` con columna `rol` | Las subclases casi no añaden atributos; cambiar de rol es cambiar una columna. |
| `Factura`, `FacturaRectificativa` | Una tabla `FACTURA`; es rectificativa si tiene `id_factura_original` y `motivo_rectificacion` | La rectificativa comparte numeración, PDF y cobros con el resto de facturas. |
| `SistemaPagos`, `CanalEnvio` | Sin tabla | Son comportamiento, no datos |
| `ClienteContacto` (clase asociación) | Tabla intermedia `CLIENTE_CONTACTO` con `tipo` | Relación N:M con atributo propio. |
| `Conciliacion` | Tabla `CONCILIACION`, que une `MOVIMIENTO_COBRO` y `FACTURA` | Relación N:M con importe, regla y reversión. |
| Asociación `favoritos` (`Usuario`–`Cliente`) | Tabla `FAVORITO` | N:M sin atributos |
| Asociación `menciona` (`Comentario`–`Usuario`) | Tabla `MENCION` | N:M sin atributos |
| `Cliente.etiquetas : List<String>` | Tablas `ETIQUETA` y `CLIENTE_ETIQUETA` | Un atributo multivaluado no cabe en una columna. |
| `Incidencia.adjuntos : List<String>` | Tabla `ADJUNTO` | Un atributo multivaluado no cabe en una columna. |
| Asociación «configura» de `ConfiguracionSistema` con series, impuestos y rangos | Tabla de una sola fila; `SERIE_FACTURACION`, `IMPUESTO` y `RANGO_TARIFA` sin clave ajena hacia ella | Con una única configuración, esa clave ajena no aporta nada. |
| Atributo derivado `/saldoPendiente` | Columna `FACTURA.saldo_pendiente` | Se guarda para consultar rápido (NFR-12); la aplicación la recalcula con cada cobro. |
| Operaciones de las clases | Sin reflejo en tablas | Son comportamiento; solo las reglas que protegen datos pasan a restricciones. |
| Resto de clases | Una tabla cada una (p. ej. `SolicitudDescuento` -> `SOLICITUD_DESCUENTO`) | Atributos -> columnas. asociaciones -> claves ajenas. |
| Reglas en notas (BR-09, BR-10, BR-12, FR-18…) | Restricciones del ER, descritas en Reglas y restricciones de modelo_datos.md .Las que no se pueden expresar así, estan recogidas en la aplicación | El ER impide los estados que prohíbe la Entrega 1 cuando se pueden expresar como restricción. |
| Enumeraciones (`EstadoFactura`, `TipoFactura`…) | Columna que solo admite esos valores, como se puede observar con `FACTURA.tipo IN ('PUNTUAL', 'RECURRENTE')` | No son tablas: los valores son fijos y la columna solo admite esos. |
