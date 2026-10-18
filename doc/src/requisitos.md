
# Requisitos

## 1. Contexto y alcance

### 1.1. Objetivo del sistema

Se quiere crear una aplicación de uso privado para gestionar las facturas del producto de la empresa para evitar la carga administrativa que conlleva gestionarlo manualmente.

### 1.2. Alcance

Debe poder gestionar todas las facturas de la empresa sin gestionar los pagos en si.

### 1.3. Actores y partes interesadas

Identificar las personas, organizaciones o sistemas que interactúan con el sistema
o tienen algún interés relevante en su funcionamiento.

| Actor / stakeholder | Descripción | Intereses principales |
|---|---|---|
| Superadministrador | Personal de Turbine con permisos de gestión de la plataforma | Asignar roles y crear usuarios |
| Administrador | Usuario con permisos de edición sobre facturas y empresas | Ejecutar acciones de escritura |
| Usuario Operativo | Usuario estandar con permisos básicos | Ejecutar acciones de lectura |
| Sistema de pagos | Sistema externo en el que se reflejan los cobros | Proporcionar información que permita determinar si una factura ha sido pagada |


## 2. Requisitos de negocio

Los requisitos de negocio describen los objetivos, necesidades o resultados que
la organización pretende conseguir mediante el desarrollo del sistema. No describen
todavía funcionalidades concretas del software.

| ID | Requisito | Fuente |
|---|---|---|
| BR-01 | Eliminar la carga administrativa que se ejercía antes en la facturación manual | Cliente / Entrevista |
| BR-02 | Dar soporte a una facturación de precios variables y suscripciones recurrentes ( buscamos no requerir de hacer cálculos manuales) | Cliente / Entrevista |
| BR-03 | Gestionar los impagos de forma automática | Cliente / Entrevista |
| BR-04 | Proporcionar a los administradores reportes de la salud financiera del negocio | Cliente / Entrevista |
| BR-05 | Cumplir requisitos legales (protección de datos) | Cliente / Entrevista |

## 3. Requisitos de usuario

Los requisitos de usuario describen las necesidades, objetivos o servicios que los
usuarios esperan obtener del sistema. Deben expresarse desde el punto de vista del
usuario, evitando entrar todavía en detalles internos de implementación.

| ID | Actor | Requisito | Fuente |
|---|---|---|---|
| UR-01 | Usuario Operativo | Podrá consultar la información básica de las facturas | Cliente / Entrevista |
| UR-02 | Usuario Operativo | Podrá descargar facturas en PDF | Cliente / Entrevista |
| UR-03 | Usuario Operativo | Podrá consultar y (filtrar por) el estado de las facturas | Cliente / Entrevista |
| UR-04 | Usuario | Podrá filtrar facturas por empresa, fecha, nombre de empresa y tipo de pago | Cliente / Entrevista |
| UR-05 | Administrador | Podrá editar datos de las facturas que tiene asignadas (modificar cantidad del pago y su plazo) | Cliente / Entrevista |
| UR-06 | Administrador | Podrá asignar roles al resto de usuarios de la plataforma | Cliente / Entrevista |
| UR-07 | Administrador | Podrá invitar a usuarios a la plataforma | Cliente / Entrevista |
| UR-08 | Administrador | Podrá asignar acceso a las facturas | Cliente / Entrevista |
| UR-09 | Superadministrador | Podrá acceder a información de facturación de la empresa | Cliente / Entrevista |
| UR-10 | Usuario | Podrá emitir facturas a los clientes | Cliente / Entrevista |
| UR-11 | Administrador | Podrá añadir empresas nuevas | Cliente / Entrevista |


## 4. Requisitos del sistema

### 4.1. Requisitos funcionales

Los requisitos funcionales describen comportamientos, servicios u operaciones que
debe proporcionar el sistema. Siempre que sea posible, deben formularse de manera
clara, precisa y verificable.
| ID | Requisito | Relacionado con |
|---|---|---|
| FR-01 | El sistema permitirá gestionar y crear facturas válidas, con numeración correlativa y única dentro de su serie, datos fiscales correspondientes y cálculo del IVA con los impuestos configurados. El superadministrador configurará las series, y los impuestos de una factura podrán configurarse o seleccionarse entre los dados de alta. | UR10 |
| FR-02 | El sistema permitirá registrar facturas nuevas, que podrán ser puntuales o recurrentes. Una factura puntual podrá tener varias líneas, cada una con concepto, cantidad, precio unitario, descuento (si aplica) e impuesto, y se podrán ajustar el precio y la descripción. | UR10 |
| FR-03 | El sistema permitirá dar de alta clientes con una ficha comercial y sus datos fiscales: nombre comercial, razón social, NIF o identificador fiscal, domicilio fiscal, país, moneda de trabajo y datos de contacto. El modelo de datos fiscales será universal (NIF y monedas de varios países). | — |
| FR-04 | Un cliente podrá tener múltiples contactos (contratación, recepción de facturas, impagos), con su nombre y correo, y un contacto podrá pertenecer a varias empresas. | — |
| FR-05 | El sistema perseguirá el cobro por sí mismo mediante un flujo de recordatorios e impago, con notificaciones al cliente por defecto cada 2 días. El superadministrador podrá configurar los tiempos de recordatorio e impago, y el vencimiento pactado con un cliente prevalecerá sobre el general. Se podrán suspender temporalmente los recordatorios de una factura concreta. | — |
| FR-06 | El sistema permitirá el login mediante correo y contraseña. El correo deberá pertenecer al dominio corporativo de TurbineH autorizado. | UR7 |
| FR-07 | El sistema tendrá tres roles: Superadministrador, Administrador y Usuario operativo. | UR6 |
| FR-08 | El sistema permitirá importar datos de clientes de forma masiva mediante CSV, con previsualización antes de confirmar, posibilidad de corregir errores y registro de la operación, con el resumen de registros creados, actualizados y rechazados y sus motivos. De forma opcional, podrá importar facturas históricas, que quedarán marcadas como migradas, con su número y documento original, sin enviar notificación al cliente. | — |
| FR-9 | El sistema permitirá registrar la baja de un cliente. Desde la fecha de baja dejará de generar mensualidades pero, si tiene facturas pendientes, mantendrá activo el flujo de recobro. La información del cliente dado de baja se mantendrá el tiempo que la ley permita. | — |
| FR-10 | El sistema permitirá actualizar anualmente el plan de precios de un cliente en función de su facturación: se introducirá la facturación anual verificada y el sistema propondrá el rango de tarifa que corresponde. Cuando el responsable apruebe el cambio, quedará registrado quién lo aprobó, cuándo, y el precio anterior y el nuevo. | — |
| FR-11 | El sistema debe emitir facturas el día 1 de cada mes. En caso de contratar a mitad de mes, se facturará proporcionalmente. | — |
| FR-12 | Las facturas se generarán en PDF y se guardarán en la base de datos. | UR2 |
| FR-13 | El administrador podrá cambiar la cuantía de las facturas. Las facturas idénticas al mes anterior se aprueban solas. Si alguien modifica algo de importancia (como el importe, un descuento extraordinario, una fecha de vencimiento fuera de lo habitual, o crea una factura puntual con importe muy alto), la factura quedará retenida para revisión. | UR5 |
| FR-14 | El sistema debe bloquear la edición de facturas una vez pasada su fecha de presentación trimestral. | UR5 |
| FR-15 | El sistema debe conectarse con Stripe o Revolut para el seguimiento del pago: podrá consultar pagos, recibir notificaciones de pago simuladas y permitirá incorporar otras fuentes de pago. Cada movimiento podrá incluir importe, fecha, moneda, concepto y referencia. | — |
| FR-16 | El sistema permitirá pausar una suscripción indicando motivo, fecha de inicio y, si se conoce, fecha prevista de reactivación. | — |
| FR-17 | El Superadministrador debe poder cambiar la tabla de tarifas para futuras revisiones sin que esto reescriba ni afecte a las facturas históricas ya emitidas. | — |
| FR-18 | El usuario que gestiona el cliente podrá solicitar o preparar un descuento. Un administrador lo aprobará y, si supera un umbral configurable, lo aprobará el Superadministrador. El sistema deberá explicar siempre el motivo por el cual una factura o descuento queda pendiente de aprobación. | — |
| FR-19 | Las facturas tendrán estados (borrador, aprobada, emitida, enviada, vencida, pagada, parcialmente conciliada, anulada, rectificada). | UR3 |
| FR-20 | El sistema mostrará una vista previa antes de emitir una factura. Si falta un dato fiscal imprescindible, bloqueará la emisión e indicará qué falta. | UR10 |
| FR-21 | El sistema detectará si una factura no está totalmente saldada o si se ha pagado de más. | — |
| FR-22 | Cuando se deshaga una conciliación automática por un error, el sistema dejará constancia de ello. | — |
| FR-23 | Si un correo rebota, el sistema no marcará la factura como notificada, avisará al responsable del cliente, creará una incidencia de entrega y permitirá corregir el contacto y reenviar. | — |
| FR-24 | Cada cliente tendrá un responsable interno que recibirá los eventos relevantes. El administrador verá una bandeja global y cada usuario la suya. El superadministrador podrá elegir qué notificaciones se muestran dentro de la aplicación, cuáles se envían por email y cuáles en un resumen diario. Las notificaciones se podrán marcar como leídas. | — |
| FR-25 | El sistema generará informes que se podrán filtrar por periodo, cliente, responsable interno, país, sector, estado de factura, tipo (recurrente o puntual) y moneda. Se podrán exportar a CSV y a un informe legible en PDF, respetando los permisos del usuario, y serán accesibles también mediante enlace autenticado. | UR9 |
| FR-26 | El sistema usará mensajes distintos según se trate de la emisión de una factura recurrente o de un aviso de impago. Los emails de factura, recordatorio previo, vencimiento, impago, disputa resuelta y, quizá, revisión de datos tendrán plantillas editables por quien tenga permiso, con variables dinámicas (nombre de empresa, nº de factura, importe, responsable, etc.). Si falta una variable, la previsualización avisará mediante una alerta. Se guardará el historial de qué plantilla se usó en cada envío. Las comunicaciones al cliente podrán elegir idioma por cliente o contacto. | — |
| FR-27 | El sistema detectará posibles clientes duplicados por identificador fiscal y avisará al usuario. | — |
| FR-28 | El sistema incluirá un buscador para buscar y filtrar por nombre comercial, razón social, NIF, persona de contacto, número de factura y correo, y para filtrar clientes por nicho y por estado de la factura (pagada, impagada, pendiente). Se podrán guardar filtros. | UR3, UR4, UR07 |
| FR-29 | El administrador puede ver un dashboard que muestre la relación de facturación del cliente a nivel semanal, mensual y anual, y con lo facturado en la semana, el mes, el trimestre y el año; lo cobrado, pendiente y vencido; el tiempo medio de cobro; su evolución; los clientes con mayor deuda; los ingresos recurrentes esperados del mes; la facturación puntual y una previsión sencilla basada en las recurrencias activas. | UR9, UR-04 |
| FR-30 | El sistema debe autocompletar campos recurrentes (como el país, la moneda, el vencimiento o la tarifa). | — |
| FR-31 | Se prohíben categóricamente acciones masivas de alto impacto económico sin controles estrictos. Toda acción masiva debe mostrar de forma explícita el número exacto de elementos afectados antes de ejecutar el proceso. | — |
| FR-32 | El sistema permitirá asociar tareas pendientes a los clientes (no a los usuarios), que se heredarán si cambia el responsable. | — |
| FR-33 | El sistema permitirá etiquetar clientes (por ejemplo, estratégico, beta, partner, riesgo de cobro), además de por sector y ubicación. | — |
| FR-34 | Las incidencias de facturación deben tener responsable, estado, prioridad, comentarios adjuntos e internos. | — |
| FR-35 | Canales para comunicación tanto internamente como para facturas adjuntas. | — |
| FR-36 | Una mención en un comentario o en una factura puede generar una notificación. | — |
| FR-37 | Retención de informes temporales, conservarlos en un tiempo configurable y regenerarlos si los datos lo permiten, las facturas tienen otra política diferente. | — |
| FR-38 | Registrar cuánto tarda el equipo en ciertas operaciones pero que no sea una vigilancia. | — |
| FR-39 | Funciones inteligentes opcionales debe poder ser desactivado por el usuario. Las sugerencias económicas deben de ser confirmadas por el usuario. | — |



### 4.2. Requisitos no funcionales

Los requisitos no funcionales describen propiedades de calidad, restricciones o
condiciones que debe satisfacer el sistema. Cuando sea posible, deberán incluir
algún criterio que permita determinar si el requisito se cumple.

| ID | Categoría | Requisito | Criterio verificable |
|---|---|---|---|
| NFR-01 | Usabilidad | Crear facturas rápidamente | Se podría poder completar en aproximadamente menos de un minuto |
| NFR-02 | Usabilidad | Se debe poder llegar a la información en el menor número de clicks | Una operación estándar, como consultar las facturas de una empresa, se debería hacer en máximo dos clicks |
| NFR-03 | Usabilidad | Debe tener una interfaz limpia | TODO |
| NFR-04 | Portabilidad / Usabilidad | La aplicación deberá poder utilizarse desde distintos tipos de dispositivo | Las principales funcionalidades deberán ser utilizables desde ordenador, tableta y teléfono móvil |
| NFR-05 | Diseño | Debe respetar el diseño corporativo del cliente | Debe utilizar colores corporativos y sus logos |


## 5. Reglas de negocio

Reglas del dominio o de la organización que condicionan el comportamiento del sistema
pero que no representan por sí mismas una funcionalidad.

| ID | Regla |
|---|---|
| RB-01 | ... |
| RB-02 | ... |


## 6. Suposiciones y decisiones de análisis

En esta sección se documentarán las decisiones tomadas por el equipo cuando la
información proporcionada por el cliente no sea suficiente para determinar unívocamente
un requisito.

| ID | Suposición o decisión | Justificación | Requisitos afectados |
|---|---|---|---|
| A-01 | ... | ... | FR-... |
| A-02 | Se ha de usar un dominio corportativo de TurbineH autorizado | Se habla de email de turbineh y luego de dominio corporativo autorizado | FR-06 |
| A-03 | El rol lector pasa a llamarse Usuario Operativo | El cliente dijo en la amplaición de requisitos que no usaramos lector | FR-07 |

## 7. Dudas, ambigüedades y cuestiones pendientes

Se incluirán aquí aspectos de la información proporcionada por el cliente que sean
ambiguos, incompletos, contradictorios o que requieran aclaración.

| ID | Cuestión | Origen | Impacto | Estado / resolución |
|---|---|---|---|---|
| Q-01 | ¿Qué roles hay en el sistema? | Entrevista | Los roles del sistema están ambiguos. El rol de usuario está claro, pero no está claro si admin y superadmin son el mismo rol o son cosas diferentes | Resuelto, hay tres roles. Usuario, admin y superadmin |


## 8. Trazabilidad

La tabla permitirá comprobar la relación entre las necesidades de negocio,
los requisitos de usuario y los requisitos del sistema.

| Requisito de negocio | Requisito de usuario | Requisito funcional / no funcional |
|---|---|---|
| BR-01 | UR-01 | FR-16 |
| BR-02 | UR-05 | FR-11 |
| BR-03 | UR-10 | FR-04 |
| BR-04 | UR-09 | - |
| BR-05 | - | FR-09 |



## 9. Glosario

| Término | Definición |
|---|---|
| ... | ... |
