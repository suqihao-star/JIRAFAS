
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
| Superadministrador | Personal de Turbine con configuración profunda. Tiene más permisos que el administrador | Configurar tarifas, series, plazos, cadencia de recordatorios, umbrales de aprobación, plantillas y datos del emisor. Consultar la auditoría. Reabrir periodos cerrados. Aprobar descuentos sobre el umbral |
| Administrador | Usuario de Turbine con permisos de edición sobre facturas y empresas | Gestionar clientes, facturas, cobros, asignaciones y aprobaciones. Invitar usuarios si tiene permiso. Ver el dashboard financiero global.|
| Usuario Operativo | Usuario de Turbine que trabaja sobre los clientes asignados| Dar de alta y gestionar sus clientes. Puede preparar o emitir facturas siempre que su permiso lo permita, seguir cobros, registrar incidencias, descargar documentos que tenga disponible y solicitar descuentos |
| Sistema de pagos | Sistema externo en el que se reflejan los cobros | Proporcionar información que permita determinar si una factura ha sido pagada |
| Proveedores de correos | Servicios de envió de comunicaciones | Entrega de mensaje y devuelta de resultados: enviados, rebotados o fallidos |
## 2. Requisitos de negocio

Los requisitos de negocio describen los objetivos, necesidades o resultados que la organización pretende conseguir mediante el desarrollo del sistema. No describen todavía funcionalidades concretas del softwar>

| ID | Requisito | Fuente |
| :--- | :--- | :--- |
| BR-01 | Eliminar la carga administrativa que se ejercía en la facturación manual. | Cliente / Especificación |
| BR-02 | El modelo comercial se basa en facturación mensual sin permanencia. Se debe dar soporte a una facturación de precios variables y suscripciones recurrentes, evitando requerir cálculos manuales. | Clie>
| BR-03 | Gestionar los impagos de forma automática. | Cliente / Especificación |
| BR-04 | Proporcionar a los administradores reportes de la salud financiera del negocio. | Cliente / Especificación |
| BR-05 | Cerciorarnos del debido cumplimiento de las leyes vigentes (ej. protección de datos). | Cliente / Especificación |
| BR-06 | Las integraciones externas principales (Stripe, CSV, correo y WhatsApp) deben estar encapsuladas para aislar el modelo de factura de cambios de proveedor. | Cliente / Especificación |
| BR-07 | El sistema debe exponer una API documentada y segura para que sistemas externos consulten datos o envíen solicitudes bajo las mismas reglas de negocio de la aplicación. | Cliente / Especificación |
| BR-08 | Registrar métricas de rendimiento del equipo para evaluar operaciones, sin que esto se convierta en un ranking de trabajadores ni en una herramienta de vigilancia. | Cliente / Especificación |
| BR-09 | Una factura emitida no puede modificarse, borrarse ni reescribirse. Cualquier corrección exige una factura rectificativa vinculada a la original. Los borradores nunca emitidos sí podrán eliminarse de>
| BR-10 | Cada factura tendrá un número único dentro de su serie. Ni los reintentos de envío ni las acciones simultáneas de varios usuarios generarán duplicados ni consumirán numeración nueva. | Cliente / Espe>
| BR-11 | Los cambios en tarifas, catálogo de conceptos o plantillas de correo no alterarán ni reescribirán las facturas históricas ya emitidas. | Cliente / Especificación |
| BR-12 | Todo cambio de rango de tarifa o excepciones económicas sensibles requieren validación y aprobación humana por alguien distinto a quien realizó la solicitud. | Cliente / Especificación |
| BR-13 | Una factura solo se considera “pagada” cuando existe un cobro detectado o validado. Una deuda marcada como incobrable, anulada o rectificada no equivale a "pagada" y requiere de aprobación administra>
| BR-14 | La baja comercial detiene la generación de nuevas mensualidades, pero el flujo de recobro de las facturas pendientes continúa activo. | Cliente / Especificación |
| BR-15 | La pausa de una suscripción es distinta de la baja: el cliente sigue activo y conserva sus facturas pendientes. | Cliente / Especificación |
| BR-16 | El vencimiento pactado con un cliente prevalece sobre el vencimiento general. | Cliente / Especificación |
| BR-17 | El prorrateo seguirá una regla única, documentada y consistente, incluidos los casos límite (ej. alta en el último día del mes). | Cliente / Especificación |
| BR-18 | Las excepciones comerciales (primer mes gratuito, sin prorrateo, inicio futuro) deben quedar registradas de forma explícita. | Cliente / Especificación |
| BR-19 | Desactivar, dar de baja o anonimizar a un contacto no elimina el histórico de facturas emitidas, cuyos documentos se conservan por obligación legal. | Cliente / Especificación |
| BR-20 | Los datos de facturación no se utilizarán para campañas de marketing. | Cliente / Especificación |
| BR-21 | Los comentarios internos en la plataforma nunca se envían al cliente. | Cliente / Especificación |
| BR-22 | Ningún sistema externo podrá saltarse las reglas de negocio de la aplicación ni modificar o eliminar recurrencias directamente. | Cliente / Especificación |
| BR-23 | El sistema debe operar sin dependencia crítica del componente de Inteligencia Artificial (Brain). Las funciones de IA son opcionales, no pueden saltarse permisos y toda sugerencia económica requiere >
| BR-24 | Cada factura conserva su importe en la moneda original en que se emitió. La conversión a la moneda base solo se usa para informes y no altera el total legal. | Cliente / Especificación |


## 3. Requisitos de usuario

Los requisitos de usuario describen las necesidades, objetivos o servicios que los usuarios esperan obtener del sistema. Deben expresarse desde el punto de vista del usuario, evitando entrar todavía en detalle>

| ID | Actor | Requisito | Fuente |
| :--- | :--- | :--- | :--- |
| UR-01 | Todos | El sistema contará con tres perfiles delimitados: Superadministrador (acceso total), Administrador (permisos amplios y edición) y Usuario Operativo (funciones limitadas a sus clientes asignad>
| UR-02 | Usuario Operativo | Podrá descargar las facturas en PDF. | Cliente / Especificación |
| UR-03 | Usuario Operativo | Podrá consultar la información básica y filtrar por el estado de las facturas. | Cliente / Especificación |
| UR-04 | Usuario Operativo | Podrá interactuar con el dashboard financiero haciendo clic en métricas (ej. importes pendientes) para desplegar el detalle exacto que compone la cifra, y filtrar por empresa o fe>
| UR-05 | Administrador | Podrá proponer, generar y modificar datos o cuantías de facturas que tiene asignadas. | Cliente / Especificación |
| UR-06 | Superadministrador / Administrador | Podrán invitar a nuevos usuarios, asignarles roles, asignar accesos a facturas y desactivar cuentas. | Cliente / Especificación |
| UR-07 | Todos | Podrán localizar rápidamente a cualquier cliente, usuario o factura mediante un buscador, y recuperar su contraseña mediante un enlace temporal. | Cliente / Especificación |
| UR-08 | Administrador | Podrá visualizar un panel de monitorización sencillo con el estado de las tareas automatizadas, colas y errores recientes. | Cliente / Especificación |
| UR-09 | Superadministrador / Administrador | Podrán acceder a la información de facturación global y reportes financieros completos de la empresa. | Cliente / Especificación |
| UR-10 | Usuario Operativo | Podrá emitir y enviar facturas a los clientes. | Cliente / Especificación |


## 4. Requisitos del sistema

### 4.1. Requisitos funcionales

Los requisitos funcionales describen comportamientos, servicios u operaciones que
debe proporcionar el sistema. Siempre que sea posible, deben formularse de manera
clara, precisa y verificable.
| ID | Requisito | Relacionado con |
|---|---|---|
| FR-01 | El sistema permitirá gestionar y crear facturas válidas, con numeración correlativa y única dentro de su serie, datos fiscales correspondientes y cálculo del IVA con los impuestos configurados. El superadministrador configurará las series, y los impuestos de una factura podrán configurarse o seleccionarse entre los dados de alta. | UR-10, UR-05, BR-10 |
| FR-02 | El sistema permitirá registrar facturas nuevas, que podrán ser puntuales o recurrentes. Una factura puntual podrá tener varias líneas, cada una con concepto, cantidad, precio unitario, descuento (si aplica) e impuesto, y se podrán ajustar el precio y la descripción. | UR10, BR-02 |
| FR-03 | El sistema permitirá dar de alta clientes con una ficha comercial y sus datos fiscales: nombre comercial, razón social, NIF o identificador fiscal, domicilio fiscal, país, moneda de trabajo y datos de contacto. El modelo de datos fiscales será universal (NIF y monedas de varios países). | UR-05, UR-10, BR-05 |
| FR-04 | Un cliente podrá tener múltiples contactos (contratación, recepción de facturas, impagos), con su nombre y correo, y un contacto podrá pertenecer a varias empresas. | UR-05 |
| FR-05 | El sistema perseguirá el cobro por sí mismo mediante un flujo de recordatorios e impago, con notificaciones al cliente por defecto cada 2 días. El superadministrador podrá configurar los tiempos de recordatorio e impago, y el vencimiento pactado con un cliente prevalecerá sobre el general. Se podrán suspender temporalmente los recordatorios de una factura concreta. | UR-05, BR-03, BR-16 |
| FR-06 | El sistema permitirá el login mediante correo y contraseña. El correo deberá pertenecer al dominio corporativo de TurbineH autorizado. | UR-01, UR-07 |
| FR-07 | El sistema tendrá tres roles: Superadministrador, Administrador y Usuario operativo. | UR-01 |
| FR-08 | El sistema permitirá importar datos de clientes de forma masiva mediante CSV, con previsualización antes de confirmar, posibilidad de corregir errores y registro de la operación, con el resumen de registros creados, actualizados y rechazados y sus motivos. De forma opcional, podrá importar facturas históricas, que quedarán marcadas como migradas, con su número y documento original, sin enviar notificación al cliente. | UR-06, BR-01 |
| FR-9 | El sistema permitirá registrar la baja de un cliente. Desde la fecha de baja dejará de generar mensualidades pero, si tiene facturas pendientes, mantendrá activo el flujo de recobro. La información del cliente dado de baja se mantendrá el tiempo que la ley permita. | BR-14, BR-19 |
| FR-10 | El sistema permitirá actualizar anualmente el plan de precios de un cliente en función de su facturación: se introducirá la facturación anual verificada y el sistema propondrá el rango de tarifa que corresponde. Cuando el responsable apruebe el cambio, quedará registrado quién lo aprobó, cuándo, y el precio anterior y el nuevo. | BR-12 |
| FR-11 | El sistema debe emitir facturas el día 1 de cada mes. En caso de contratar a mitad de mes, se facturará proporcionalmente. | BR-17 |
| FR-12 | Las facturas se generarán en PDF y se guardarán en la base de datos. | UR-02, BR-06 |
| FR-13 | El administrador podrá cambiar la cuantía de las facturas. Las facturas idénticas al mes anterior se aprueban solas. Si alguien modifica algo de importancia (como el importe, un descuento extraordinario, una fecha de vencimiento fuera de lo habitual, o crea una factura puntual con importe muy alto), la factura quedará retenida para revisión. | UR-05, BR-12 |
| FR-14 | El sistema debe bloquear la edición de facturas una vez pasada su fecha de presentación trimestral. | BR-09 |
| FR-15 | El sistema debe conectarse con Stripe o Revolut para el seguimiento del pago: podrá consultar pagos, recibir notificaciones de pago simuladas y permitirá incorporar otras fuentes de pago. Cada movimiento podrá incluir importe, fecha, moneda, concepto y referencia. | BR-06, BR-13 |
| FR-16 | El sistema permitirá pausar una suscripción indicando motivo, fecha de inicio y, si se conoce, fecha prevista de reactivación. | BR-15 |
| FR-17 | El Superadministrador debe poder cambiar la tabla de tarifas para futuras revisiones sin que esto reescriba ni afecte a las facturas históricas ya emitidas. | BR-11 |
| FR-18 | El usuario que gestiona el cliente podrá solicitar o preparar un descuento. Un administrador lo aprobará y, si supera un umbral configurable, lo aprobará el Superadministrador. El sistema deberá explicar siempre el motivo por el cual una factura o descuento queda pendiente de aprobación. | UR-05, BR-12 |
| FR-19 | Las facturas tendrán estados (borrador, aprobada, emitida, enviada, vencida, pagada, parcialmente conciliada, anulada, rectificada). | UR-03, BR-13 |
| FR-20 | El sistema mostrará una vista previa antes de emitir una factura. Si falta un dato fiscal imprescindible, bloqueará la emisión e indicará qué falta. | UR-10 |
| FR-21 | El sistema detectará si una factura no está totalmente saldada o si se ha pagado de más. | BR-13 |
| FR-22 | Cuando se deshaga una conciliación automática por un error, el sistema dejará constancia de ello. | UR-08, BR-04 |
| FR-23 | Si un correo rebota, el sistema no marcará la factura como notificada, avisará al responsable del cliente, creará una incidencia de entrega y permitirá corregir el contacto y reenviar. | UR-05, UR-08 |
| FR-24 | Cada cliente tendrá un responsable interno que recibirá los eventos relevantes. El administrador verá una bandeja global y cada usuario la suya. El superadministrador podrá elegir qué notificaciones se muestran dentro de la aplicación, cuáles se envían por email y cuáles en un resumen diario. Las notificaciones se podrán marcar como leídas. | UR-08, BR-04 |
| FR-25 | El sistema generará informes que se podrán filtrar por periodo, cliente, responsable interno, país, sector, estado de factura, tipo (recurrente o puntual) y moneda. Se podrán exportar a CSV y a un informe legible en PDF, respetando los permisos del usuario, y serán accesibles también mediante enlace autenticado. | UR-09, BR-04 |
| FR-26 | El sistema usará mensajes distintos según se trate de la emisión de una factura recurrente o de un aviso de impago. Los emails de factura, recordatorio previo, vencimiento, impago, disputa resuelta y, quizá, revisión de datos tendrán plantillas editables por quien tenga permiso, con variables dinámicas (nombre de empresa, nº de factura, importe, responsable, etc.). Si falta una variable, la previsualización avisará mediante una alerta. Se guardará el historial de qué plantilla se usó en cada envío. Las comunicaciones al cliente podrán elegir idioma por cliente o contacto. | BR-11 |
| FR-27 | El sistema detectará posibles clientes duplicados por identificador fiscal y avisará al usuario. | UR-05 |
| FR-28 | El sistema incluirá un buscador para buscar y filtrar por nombre comercial, razón social, NIF, persona de contacto, número de factura y correo, y para filtrar clientes por nicho y por estado de la factura (pagada, impagada, pendiente). Se podrán guardar filtros. | UR-07, UR-03 |
| FR-29 | El administrador puede ver un dashboard que muestre la relación de facturación del cliente a nivel semanal, mensual y anual, y con lo facturado en la semana, el mes, el trimestre y el año; lo cobrado, pendiente y vencido; el tiempo medio de cobro; su evolución; los clientes con mayor deuda; los ingresos recurrentes esperados del mes; la facturación puntual y una previsión sencilla basada en las recurrencias activas. | UR-04, UR-09, BR-04 |
| FR-30 | El sistema debe autocompletar campos recurrentes (como el país, la moneda, el vencimiento o la tarifa). | BR-01 |
| FR-31 | Se prohíben categóricamente acciones masivas de alto impacto económico sin controles estrictos. Toda acción masiva debe mostrar de forma explícita el número exacto de elementos afectados antes de ejecutar el proceso. | UR-06, BR-12 |
| FR-32 | El sistema permitirá asociar tareas pendientes a los clientes (no a los usuarios), que se heredarán si cambia el responsable. | UR-05 |
| FR-33 | El sistema permitirá etiquetar clientes (por ejemplo, estratégico, beta, partner, riesgo de cobro), además de por sector y ubicación. | UR-03 |
| FR-34 | Las incidencias de facturación deben tener responsable, estado, prioridad, comentarios adjuntos e internos. | UR-05 |
| FR-35 | Canales para comunicación tanto internamente como para facturas adjuntas. | UR-05 |
| FR-36 | Una mención en un comentario o en una factura puede generar una notificación. | UR-05 |
| FR-37 | Retención de informes temporales, conservarlos en un tiempo configurable y regenerarlos si los datos lo permiten, las facturas tienen otra política diferente. | BR-19 |
| FR-38 | Registrar cuánto tarda el equipo en ciertas operaciones pero que no sea una vigilancia. | BR-08 |
| FR-39 | Funciones inteligentes opcionales debe poder ser desactivado por el usuario. Las sugerencias económicas deben de ser confirmadas por el usuario. | BR-23 |
| FR-40 | El sistema permitirá clasificar clientes y facturas mediante centros de coste o proyectos, con categorías administrables para su uso en informes, sin implementar una contabilidad completa. La modificación del nombre de una categoría no alterará ni eliminará la información histórica asociada. | UR-09, BR-11 |
| FR-41 | El sistema permitirá definir y modificar objetivos de facturación que se visualizarán en el dashboard. Cada modificación deberá quedar registrada, indicando el usuario que la realizó, la fecha y los valores anteriores y nuevos. | UR-09, BR-04 |
| FR-42 | El sistema permitirá configurar alertas mediante un conjunto cerrado de reglas parametrizables, como facturas con más de un número determinado de días de vencimiento o clientes que acumulen un número determinado de facturas impagadas. Cada usuario podrá configurar los canales por los que recibirá dichas alertas, como notificaciones internas o correo electrónico, sin incorporar un motor de procesos BPMN. | UR-08 |
| FR-43 | El sistema mostrará una línea temporal por cliente con los eventos relevantes de su actividad, incluyendo altas, bajas, emisión de facturas y pagos, ordenados cronológicamente. | UR-03, UR-04 |
| FR-44 | El sistema permitirá marcar clientes como favoritos para acceder rápidamente a sus fichas desde una sección de acceso rápido, sin utilizar un historial automático de clientes recientes. | UR-03 |


### 4.2. Requisitos no funcionales

Los requisitos no funcionales describen propiedades de calidad, restricciones o
condiciones que debe satisfacer el sistema. Cuando sea posible, deberán incluir
algún criterio que permita determinar si el requisito se cumple.

| ID | Categoría | Requisito |
|---|---|---|
| NFR-01 | Usabilidad | Crear facturas rápidamente, en un flujo estándar de menos de un minuto |
| NFR-02 | Usabilidad | Acceder a la información en el menor número de clics posible, con operaciones clave en dos clics o menos |
| NFR-03 | Usabilidad | Mantener una interfaz limpia, comprensible y consistente en la navegación |
| NFR-04 | Portabilidad | Hacer que la aplicación sea usable desde ordenador, tableta y móvil |
| NFR-05 | Diseño | Respetar la identidad visual corporativa con colores y logotipos del cliente |
| NFR-06 | Fiabilidad / Exactitud | Gestionar los importes con precisión decimal y evitar pérdidas de céntimos por uso de float |
| NFR-07 | Seguridad | Controlar acceso y autorización en servidor para rechazar rutas o recursos no permitidos |
| NFR-08 | Seguridad | Garantizar sesiones seguras, caducidad razonable, invalidación al desactivar usuarios y protección básica frente a intentos fallidos |
| NFR-09 | Seguridad / Auditoría | Registrar errores y cambios críticos con trazabilidad, y permitir autenticación de doble factor cuando sea necesario |
| NFR-10 | Documentación | Proporcionar una documentación breve, clara y útil para el usuario |
| NFR-11 | Tecnología / Despliegue | Usar software libre o razonablemente accesible, con una web y app responsive compatibles con navegadores habituales, iOS y Android |
| NFR-12 | Rendimiento | Hacer que búsquedas y aperturas habituales sean prácticamente inmediatas, dejando tareas pesadas en segundo plano |
| NFR-13 | Escalabilidad / Concurrencia | Permitir escalabilidad por encima de 10 usuarios y evitar conflictos con ediciones simultáneas |
| NFR-14 | Fiabilidad | Realizar copias de seguridad automáticas y validar la restauración de datos en pruebas prácticas |
| NFR-15 | Tolerancia a fallos | Recuperar la generación de facturas sin duplicarlas tras interrupciones o fallos del sistema |
| NFR-16 | Mantenibilidad | Contar con un entorno de pruebas independiente para validar cambios antes de desplegarse |


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
| A-04 | Los enlaces temporales caducan a la hora de ser enviados | En la ampliación habla de enlaces temporales pero no determina el tiempo en el que estos funcionan, suponemos esta medida por seguridad | FR-37, NFR-17| 

## 7. Dudas, ambigüedades y cuestiones pendientes

Se incluirán aquí aspectos de la información proporcionada por el cliente que sean
ambiguos, incompletos, contradictorios o que requieran aclaración.

| ID | Cuestión | Origen | Impacto | Estado / resolución |
|---|---|---|---|---|
| Q-01 | ¿Qué roles hay en el sistema? | Entrevista | Los roles del sistema están ambiguos. El rol de usuario está claro, pero no está claro si admin y superadmin son el mismo rol o son cosas diferentes | Resuelto, hay tres roles. Usuario, admin y superadmin |
| Q-02 | Baja de un cliente con deuda. El cliente dijo en la charla inicial que no puedes darte de baja hasta que pagues y en la ampliación se habla de que la deuda no bloquea la baja comercial. | Charla y requisistos ampliados | FR-9, BR-14. | Tomamos la información de la ampliación de requisistos. |

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
