# Requisitos

## 1. Contexto y alcance

### 1.1. Objetivo del sistema

El objetivo del proyecto es desarrollar una plataforma web/app de uso interno para TurbineH que automatice el ciclo de vida completo de su facturación. El sistema busca eliminar la carga administrativa actual mediante la gestión automatizada de suscripciones recurrentes, el seguimiento de impagos, emisión de documentos fiscales y la conciliación de cobros. Todo ello garantizando la trazabilidad financiera, seguridad y el cumplimiento normativo.


### 1.2. Alcance

El sistema abarcará exclusivamente la gestion administrativa y documental de la facturación.
El sistema incluye en su alcance:
  - Gestión integral del catálogo de clientes.
  - Automatización de facturación recurrente y emisión de facturas puntuales.
  - Seguimiento del estado de cobro, conciliación de pagos e incidencias.
  - Envio automatico de notificaciones, alertas y documentos a los clientes.
  - Exposición de una API segura para el consumo de datos por parte de sistemas externos.
    
El sistema no incluye en su alcance:
  - Procesamiento de los pagos.
  - Contabilidad en general(presentación de impuestos, nóminas, etc.)     

### 1.3. Actores y partes interesadas

Identificar las personas, organizaciones o sistemas que interactúan con el sistema
o tienen algún interés relevante en su funcionamiento.

| Actor / stakeholder | Descripción | Intereses principales |
|---|---|---|
| Superadministrador | Personal de Turbine con configuración profunda. Tiene más permisos que el administrador | Configurar tarifas, series, plazos, cadencia de recordatorios, umbrales de aprobación, plantillas y datos del emisor. Consultar la auditoría. Reabrir periodos cerrados. Aprobar descuentos sobre el umbral. |
| Administrador | Usuario de Turbine con permisos de edición sobre facturas y empresas | Gestionar clientes, facturas, cobros, asignaciones y aprobaciones. Invitar usuarios si tiene permiso. Ver el dashboard financiero global.|
| Usuario Operativo | Usuario de Turbine que trabaja sobre los clientes asignados| Dar de alta y gestionar sus clientes. Puede preparar o emitir facturas siempre que su permiso lo permita, seguir cobros, registrar incidencias, descargar documentos que tenga disponible y solicitar descuentos. |
| Sistema de pagos | Sistema externo en el que se reflejan los cobros | Proporcionar información que permita determinar si una factura ha sido pagada. |
| Proveedores de correos | Servicios de envió de comunicaciones | Entrega de mensaje y devuelta de resultados: enviados, rebotados o fallidos. |
| Planificador del sistema| Componente de software encargado de ejecutar flujos de trabajo asíncronos en el sistema basandose en eventos temporales o fechas programadas, sin necesidad de intervención manual por parte de un usuario. | Es responsable de iniciar la generación masiva de cuotas de suscripciones en sus fechas de vencimiento, realizar las comprobaciones periódicas de facturas vencidas e inciar los envíos automáticos.|
| Sistema externo | Consume la API documentada | Integración de la aplicación en sistemas externos. |
## 2. Requisitos de negocio

Los requisitos de negocio describen los objetivos, necesidades o resultados que la organización pretende conseguir mediante el desarrollo del sistema. No describen todavía funcionalidades concretas del software

| ID | Requisito | Fuente |
| :--- | :--- | :--- |
| BR-01 | Reducir la carga administrativa que se ejercía en la facturación manual y el seguimiento de cobros. | Cliente / Especificación |
| BR-02 | El modelo comercial se basa en facturación mensual sin permanencia. Se debe dar soporte a una facturación de precios variables y suscripciones recurrentes, evitando requerir cálculos manuales. | Cliente / Especificación |
| BR-03 | Gestionar los impagos de forma automática. | Cliente / Especificación |
| BR-04 | Proporcionar a los administradores reportes de la salud financiera del negocio. | Cliente / Especificación |
| BR-05 | Facilitar el cumplimiento de las obligaciones legales vigentes (ej. protección de datos), cuyas reglas concretas marca la gestoría. | Cliente / Especificación |
| BR-06 | Las integraciones externas principales (Stripe, CSV, correo y WhatsApp) deben estar encapsuladas para aislar el modelo de factura de cambios de proveedor. | Cliente / Especificación |
| BR-07 | El sistema debe exponer una API documentada y segura para que sistemas externos consulten datos o envíen solicitudes bajo las mismas reglas de negocio de la aplicación. | Cliente / Especificación |
| BR-08 | Registrar métricas de rendimiento del equipo para evaluar operaciones, sin que esto se convierta en un ranking de trabajadores ni en una herramienta de vigilancia. | Cliente / Especificación |
| BR-09 | Una factura emitida no puede modificarse, borrarse ni reescribirse. Cualquier corrección exige una factura rectificativa vinculada a la original. Los borradores nunca emitidos sí podrán eliminarse definitivamente | Cliente / Especificación |
| BR-10 | Cada factura tendrá un número único dentro de su serie. Ni los reintentos de envío ni las acciones simultáneas de varios usuarios generarán duplicados ni consumirán numeración nueva. | Cliente / Especificación |
| BR-11 | Los cambios en tarifas, catálogo de conceptos o plantillas de correo no alterarán ni reescribirán las facturas históricas ya emitidas. | Cliente / Especificación |
| BR-12 | Todo cambio de rango de tarifa o excepciones económicas sensibles requieren validación y aprobación humana. En importes sensibles, el aprobador no puede ser quien realizo la solicitud.| Cliente / Especificación |
| BR-13 | Una factura solo se considera “pagada” cuando existe un cobro detectado o validado. Una deuda marcada como incobrable, anulada o rectificada no equivale a "pagada" y requiere de aprobación administrativa | Cliente / Especificación |
| BR-14 | La baja comercial detiene la generación de nuevas mensualidades, pero el flujo de recobro de las facturas pendientes continúa activo. | Cliente / Especificación |
| BR-15 | La pausa de una suscripción es distinta de la baja: el cliente sigue activo y conserva sus facturas pendientes. | Cliente / Especificación |
| BR-16 | El vencimiento pactado con un cliente prevalece sobre el vencimiento general. | Cliente / Especificación |
| BR-17 | El prorrateo seguirá una regla única, documentada y consistente, incluidos los casos límite (ej. alta en el último día del mes). | Cliente / Especificación |
| BR-18 | Las excepciones comerciales (primer mes gratuito, sin prorrateo, inicio futuro) deben quedar registradas de forma explícita. | Cliente / Especificación |
| BR-19 | Desactivar, dar de baja o anonimizar a un contacto no elimina el histórico de facturas emitidas, cuyos documentos se conservan por obligación legal. | Cliente / Especificación |
| BR-20 | Los comentarios internos en la plataforma nunca se envían al cliente. | Cliente / Especificación |
| BR-21 | Ningún sistema externo podrá saltarse las reglas de negocio de la aplicación ni modificar o eliminar recurrencias directamente. | Cliente / Especificación |
| BR-22 | Las funciones de IA son opcionales, no pueden saltarse permisos y toda sugerencia económica requiere autorización  | Cliente / Especificación |


## 3. Requisitos de usuario

Los requisitos de usuario describen las necesidades, objetivos o servicios que los usuarios esperan obtener del sistema. Deben expresarse desde el punto de vista del usuario, evitando entrar todavía en detalles
| ID | Actor | Requisito | Fuente |
| :--- | :--- | :--- | :--- |
| UR-01 | Todos | El sistema contará con tres perfiles: Superadministrador (configuración profunda del sistema), Administrador (permisos amplios sobre la operación, configurables) y Usuario Operativo (trabaja sobre los clientes que tiene asignados).| Cliente / Especificación |
| UR-02 | Usuario Operativo | Podrá descargar las facturas en PDF. | Cliente / Especificación |
| UR-03 | Usuario Operativo | Podrá consultar la información básica de las facturas de sus clientes asignados y filtrarlas por estado, empresa y fecha. | Cliente / Especificación |
| UR-04 | Administrador | Podrá interactuar con el dashboard financiero haciendo clic en métricas (ej. importes pendientes) para desplegar el detalle exacto que compone la cifra, y filtrar por empresa o fecha|
| UR-05 | Administrador | Podrá proponer, generar y modificar datos o cuantías de facturas. | Cliente / Especificación |
| UR-06 | Superadministrador / Administrador | Podrán invitar a nuevos usuarios, asignarles roles y desactivar cuentas, el administrador tiene que tener permiso. | Cliente / Especificación |
| UR-07 | Todos | Podrán localizar rápidamente a cualquier cliente, usuario o factura mediante un buscador. | Cliente / Especificación |
| UR-08 | Administrador | Podrá visualizar un panel de monitorización sencillo con el estado de las tareas automatizadas, colas y errores recientes. | Cliente / Especificación |
| UR-09 | Superadministrador / Administrador | Podrán acceder a la información de facturación global y reportes financieros completos de la empresa. | Cliente / Especificación |
| UR-10 | Usuario Operativo | Podrá emitir y enviar facturas a los clientes. | Cliente / Especificación |
|UR-11| Todos | Podran iniciar sesion con su correo corporativo y recuperar su contraseña mediante un enlace temporal. | Cliente / Especificación |
|UR-12| Usuario Operativo/Administrador | Administrador	Podrán dar de alta y gestionar sus clientes y contactos (etiquetas, favoritos, línea temporal, tareas, aviso de duplicados, importación CSV), registrar su baja o pausa y solicitar descuentos o excepciones comerciales. | Cliente / Especificación |
|UR-13| Administrador/Superadministrador | Podrán revisar el rango de tarifa de un cliente, aprobar o rechazar descuentos y facturas retenidas y emitir rectificativas. El Superadministrador podrá además cambiar la tabla de tarifas, las series y los tiempos de recordatorio. | Cliente / Especificación |
|UR-14| Usuario Opeativo/Administrador | Podran seguir los cobros de sus clientes, conciliar pagos, recibir las notificaciones y alertas relevantes y registrar incidencias y comentarios internos | Cliente / Especificación |
|UR-15| Administrador | Podrá gestionar las plantillas de comunicación y obtener informes, objetivos y clasificaciones por centro de coste. | Cliente / Especificación |

## 4. Requisitos del sistema

### 4.1. Requisitos funcionales

Los requisitos funcionales describen comportamientos, servicios u operaciones que
debe proporcionar el sistema. Siempre que sea posible, deben formularse de manera
clara, precisa y verificable.
| ID | Requisito | Relacionado con |
|---|---|---|
| FR-01 | El sistema permitirá gestionar y crear facturas válidas, con numeración correlativa y única dentro de su serie, datos fiscales correspondientes y cálculo del IVA con los impuestos configurados. El superadministrador configurará las series, y los impuestos de una factura podrán configurarse o seleccionarse entre los dados de alta. | UR-5, UR-10, UR-13, BR-02, BR-10 |
| FR-02 | El sistema permitirá registrar facturas nuevas, que podrán ser puntuales o recurrentes. Una factura puntual podrá tener varias líneas, cada una con concepto, cantidad, precio unitario, descuento (si aplica) e impuesto, y se podrán ajustar el precio y la descripción. | UR-05, UR10, BR-02 |
| FR-03 | El sistema permitirá dar de alta clientes con una ficha comercial(fecha de inicio, plan o servicio, tarifa acordada, responsable interno, condiciones de pago y documento firmado fuera de la plataforma, si existe) y sus datos fiscales: nombre comercial, razón social, NIF o identificador fiscal, domicilio fiscal, país, moneda de trabajo y datos de contacto. El modelo de datos fiscales será universal (NIF y monedas de varios países). | UR-12, BR-02 |
| FR-04 | Un cliente podrá tener múltiples contactos (contratación, recepción de facturas, impagos), con su nombre y correo, y un contacto podrá pertenecer a varias empresas. Un contacto podrá marcarse como inactivo conservando el histórico, y el sistema conservará los destinatarios de cada factura enviada.| UR-12, BR-19 |
| FR-05 | El sistema perseguirá el cobro por sí mismo: enviará un recordatorio previo (alrededor el día tres) y otro al vencimiento (por defecto es cinco dias) y, tras el vencimiento, avisos de impago por defecto cada 2 días hasta que se detecte el pago o intervenga una persona. El superadministrador podrá configurar estos tiempos y el vencimiento pactado con un cliente prevalecerá sobre el general. Se podrán suspender temporalmente los recordatorios de una factura concreta, indicando motivo y fecha de revisión. | UR-13, UR-14, BR-03, BR-16 |
| FR-06 | El sistema permitirá el login mediante correo y contraseña. El correo deberá pertenecer al dominio corporativo autorizado. No hay autorregistro. Los usuarios podrán recuperar su contraseña mediante el uso de un enlace temporal el cual caducará pasado un tiempo razonable.| UR-01, UR-11, BR-05 |
| FR-07 | El sistema tendrá tres roles: Superadministrador, Administrador y Usuario operativo. El superadministrador o un administrador con permiso, podrán crear o invitar usuarios, asignarles rol y desactivar cuentas sin borrar el rastro de sus acciones. El administrador podrá asignar y desasignar clientes a los usuarios operativos. | UR-01, UR-06 |
| FR-08 | El sistema permitirá importar datos de clientes de forma masiva mediante CSV, con previsualización antes de confirmar, posibilidad de corregir errores y registro de la operación, con el resumen de registros creados, actualizados y rechazados y sus motivos. De forma opcional, podrá importar facturas históricas, que quedarán marcadas como migradas, con su número y documento original, sin enviar notificación al cliente. | UR-12, BR-01, BR-06 |
| FR-09 | El sistema permitirá registrar la baja de un cliente. Desde la fecha de baja dejará de generar mensualidades pero, si tiene facturas pendientes, mantendrá activo el flujo de recobro. La información del cliente dado de baja se mantendrá el tiempo que la ley permita. | UR-12, BR-14, BR-19 |
| FR-10 | El sistema permitirá actualizar anualmente el plan de precios de un cliente en función de su facturación: se introducirá la facturación anual verificada y el sistema propondrá el rango de tarifa que corresponde. Cuando el responsable apruebe el cambio, quedará registrado quién lo aprobó, cuándo, y el precio anterior y el nuevo. | UR-13, BR-12 |
| FR-11 | El sistema debe emitir facturas el día 1 de cada mes. En caso de contratar a mitad de mes, se facturará proporcionalmente con una regla de prorrateo única y documentada, además el calculo se mostrará antes de confirmar el alta. | UR-10, BR-02, BR-17 |
| FR-12 | Las facturas se generarán en PDF y se guardarán en la base de datos. | UR-02, BR-09, BR-11 |
| FR-13 | Un administrador podrá cambiar la cuantía de una factura antes de emitirla. La factura generada exactamente desde una suscripción ya aprobada se emitirá sin aprobación. Si alguien modifica manualmente el importe, añade un descuento extraordinario, cambia una fecha de vencimiento fuera de lo habitual o crea una factura puntual de importe muy alto, la factura quedará retenida para su revisión por un administrador antes de enviarse.| UR-05, UR-13, BR-12 |
| FR-14 | El sistema debe bloquear la edición ordinaria de una factura una vez emitida y en todo caso, pasada su fecha de presentación trimestral. Después cualquier corrección se hará mediante factura rectificativa. | UR-05, BR-09 |
| FR-15 | El sistema debe conectarse con Stripe o Revolut para el seguimiento del pago: podrá consultar pagos, recibir notificaciones de pago simuladas y permitirá incorporar otras fuentes de pago. Cada movimiento podrá incluir importe, fecha, moneda, concepto y referencia. Cada movimiento se asociará a una factura de forma automática si la coincidencia es clara o se asocia a una persona si hay dudas. Un evento duplicado no se contabilizará dos veces y un cobro sin referencia clara quedará pendiente de conciliación manual.| 	UR-14, BR-06, BR-13 |
| FR-16 | El sistema permitirá pausar una suscripción indicando motivo, fecha de inicio y, si se conoce, fecha prevista de reactivación. Durante la pausa no se generarán mensualidades y al llegar a la fecha prevista, se avisará al responsable.| 	UR-12, BR-15 |
| FR-17 | El Superadministrador debe poder cambiar la tabla de tarifas para futuras revisiones sin que esto reescriba ni afecte a las facturas históricas ya emitidas. | UR-13, BR-11 |
| FR-18 | El usuario que gestiona el cliente podrá solicitar o preparar un descuento. Un administrador lo aprobará y, si supera un umbral configurable, lo aprobará el Superadministrador. En importes sensibles, el aprobador no podrá ser quien realizo la solicitud. El sistema deberá explicar siempre el motivo por el cual una factura o descuento queda pendiente de aprobación. | UR-12, UR-13, BR-12 |
| FR-19 | Las facturas tendrán estados (borrador, aprobada, emitida, enviada, vencida, pagada, parcialmente conciliada, anulada, rectificada). Una deuda solo podrá cancelarse o declararse incobrable por decisión administrativa con motivo y aprobación, y nunca pasará a pagada por ello.| UR-03, UR-13, BR-13 |
| FR-20 | El sistema mostrará una vista previa antes de emitir una factura. Si falta un dato fiscal imprescindible, bloqueará la emisión e indicará qué falta. | UR-10, BR-01 |
| FR-21 | El sistema detectará si una factura no está totalmente saldada o si se ha pagado de más, sin marcarla como pagada y señalando la diferencia para su revisión. | UR-14, BR-13 |
| FR-22 | Cuando se deshaga una conciliación automática por un error, el sistema no borrará el evento y dejará constancia de quien o que regla la realizó, quien la revirtió, cuando y por qué. | UR-14, BR-13 |
| FR-23 | Si un correo rebota, el sistema no marcará la factura como notificada, avisará al responsable del cliente, creará una incidencia de entrega y permitirá corregir el contacto y reenviar. | UR-14, BR-03 |
| FR-24 | Cada cliente tendrá un responsable interno que recibirá los eventos relevantes. El administrador verá una bandeja global y cada usuario la suya. Cada usuario incluido el superadministrador podrá elegir que notificaciones se muestran dentro de la aplicación, cuáles se envían por email y cuáles en un resumen diario. Las notificaciones se podrán marcar como leídas y, las que requieran accion como resueltas. | UR-14, BR-03 |
| FR-25 | El sistema generará informes que se podrán filtrar por periodo, cliente, responsable interno, país, sector, estado de factura, tipo (recurrente o puntual) y moneda. Se podrán exportar a CSV y a un informe legible en PDF, respetando los permisos del usuario, y serán accesibles también mediante enlace autenticado. | UR-09, UR-15, BR-04 |
| FR-26 | El sistema usará mensajes distintos según se trate de la emisión de una factura recurrente o de un aviso de impago. Los emails de factura, recordatorio previo, vencimiento, impago, disputa resuelta tendrán plantillas editables por quien tenga permiso, con variables dinámicas (nombre de empresa, nº de factura, importe, responsable, etc.). Si falta una variable, la previsualización avisará mediante una alerta. Se guardará el historial de qué plantilla se usó en cada envío. Las comunicaciones al cliente podrán elegir idioma por cliente o contacto. | UR-15, BR-11 |
| FR-27 | El sistema detectará posibles clientes duplicados por identificador fiscal y avisará al usuario, sin fusionarlos automaticamente. | UR-12, BR-01 |
| FR-28 | El sistema incluirá un buscador para buscar y filtrar por nombre comercial, razón social, NIF, persona de contacto, número de factura y correo, y para filtrar clientes por sector y por estado de la factura (pagada, impagada, pendiente). Se podrán guardar filtros. |	UR-03, UR-07 |
| FR-29 | El administrador puede ver un dashboard con la lista  actual de cifras. Cada cifra permitirá ver el detalle que la compone.| UR-04, UR-09, BR-04 |
| FR-30 | El sistema debe autocompletar campos recurrentes (como el país, la moneda, el vencimiento o la tarifa). |	UR-10, BR-01 |
| FR-31 | Toda acción masiva mostrará de forma explícita el numero exacto de elementos afectados antes de ejecutarse y requerirá confirmación y controles cuando sea sensible o destructiva. No se permitirán acciones masivas de alto impacto económico sin controles. | UR-12, BR-12 |
| FR-32 | El sistema permitirá asociar tareas pendientes a los clientes (no a los usuarios), que se heredarán si cambia el responsable. | UR-06, UR-12 |
| FR-33 | El sistema permitirá etiquetar clientes (por ejemplo, estratégico, beta, partner, riesgo de cobro), además de por sector y ubicación. | UR-12 |
| FR-34 | Las incidencias de facturación tendrán responsable, estado, prioridad, comentarios internos y adjuntos. | UR-14 |
| FR-35 | Canales para comunicación tanto internamente como para facturas adjuntas. | UR-14, BR-20 |
| FR-36 | Una mención a un usuario en un comentario generará una notificación. | UR-14 |
| FR-37 | Los informes y exportaciones generados se conservarán un tiempo configurable y podrán regenerarse si los datos y permisos lo permiten. Las facturas tendrán una política de conservación distinta. |UR-15, BR-04 |
| FR-38 | El sistema podrá registrar métricas agregadas de rendimiento como tiempos de generación y fallos, sin identificar ni clasificar a los empleados. | UR-08, BR-08 |
| FR-39 | Las funciones inteligentes opcionales podrán desactivarse y nunca se saltarán los permisos. Las sugerencias económicas requerirán confirmación humana. | BR-22 |
| FR-40 | El sistema permitirá clasificar clientes y facturas mediante centros de coste o proyectos, con categorías administrables para su uso en informes, sin implementar una contabilidad completa. La modificación del nombre de una categoría no alterará ni eliminará la información histórica asociada. | UR-15, BR-04 |
| FR-41 | El sistema permitirá definir y modificar objetivos de facturación que se visualizarán en el dashboard. Cada modificación deberá quedar registrada, indicando el usuario que la realizó, la fecha y los valores anteriores y nuevos. Estos objetivos son solo informativos, no alteran facturas y los gestionan los administradores.|	UR-15, BR-04 |
| FR-42 | El sistema permitirá a los administradores configurar alertas mediante un conjunto cerrado de reglas parametrizables, como facturas con más de un número determinado de días vencidas o clientes que acumulen un importe pendiente determinado. Cada usuario podrá configurar los canales por los que recibirá dichas alertas, sin incorporar un motor de procesos BPMN.|	UR-14, BR-03 |
| FR-43 | El sistema mostrará una línea temporal por cliente con los eventos relevantes de su actividad, incluyendo altas, bajas, emisión de facturas y pagos, ordenados cronológicamente. | UR-12 |
| FR-44 | El sistema permitirá marcar clientes como favoritos para acceder rápidamente a sus fichas El acceso rápido no sustituirá la comprobación de permisos | UR-07, UR-12 |
| FR-45 | El sistema permitirá generar una factura rectificativa a partir de una factura emitida, proponiendo los datos que se rectifican y manteniendo el vínculo con la original. También permitirá anularla cuando legalmente proceda. Requerirá permiso administrativo y, según el importe, aprobación. | UR-13, BR-09 |
| FR-46 | El sistema enviará automáticamente la factura emitida por correo electrónico al contacto de facturación (y por WhatsApp, de forma simulada, si hay consentimiento), registrando canal, intento, resultado, fecha y destinatario. Un fallo de envío no deshará la emisión y un reintento no creará otra factura ni otro número. | UR-10, BR-10 |
| FR-47 | El sistema permitirá registrar excepciones comerciales explícitas: inicio futuro (el cliente queda pendiente de activación, sin facturas ni recordatorios hasta esa fecha), primer mes gratuito o facturación sin prorrateo.      |UR-12, BR-18|
| FR-48 | El sistema mostrará un panel de monitorización con la última ejecución de la generación recurrente, la cola de correos pendientes, los errores de integración recientes y la última copia de seguridad correcta.|	UR-08, BR-03 |
| FR-49 | El sistema expondrá una API documentada y autenticada para consultar clientes, facturas y deuda pendiente y registrar solicitudes controladas (por ejemplo, una solicitud de baja), aplicando las mismas reglas y permisos que la interfaz. | BR-07, BR-21 |
| FR-50 | El sistema mostrará a cada usuario al entrar, una pantalla de trabajo diario con las facturas que vencen pronto o vencidas, los pagos pendientes de conciliar, los problemas de entrega, las aprobaciones pendientes y sus tareas asignadas, con acceso directo a cada elemento. | UR-14, BR-03 |

### 4.2. Requisitos no funcionales

Los requisitos no funcionales describen propiedades de calidad, restricciones o
condiciones que debe satisfacer el sistema. Cuando sea posible, deberán incluir
algún criterio que permita determinar si el requisito se cumple.

| ID | Categoría | Requisito |
|---|---|---|
| NFR-01 | Usabilidad | Las tareas habituales como el alta de un cliente estándar, la factura normal y el chequeo de cobros, deberán poder completarse en menos de un minuto. |
| NFR-02 | Usabilidad | Acceder a la información de uso frecuente en el menor número de clics posible. |
| NFR-03 | Usabilidad | Mantener una interfaz limpia y consistente, con mensajes de error que indiquen que falta, estados con etiquetas claras y confirmaciones solo donde aporten seguridad.|
| NFR-04 | Portabilidad | La aplicacion ha de ser una aplicación web responsive usable en ordenador, móvil y tablet, en navegadores de escritorio, Android e iOS.|
| NFR-05 | Diseño | Respetar la identidad visual corporativa con colores y logotipos del cliente |
| NFR-06 | Fiabilidad / Exactitud | Gestionar los importes con precisión decimal y evitar pérdidas de céntimos por uso de float |
| NFR-07 | Seguridad | Controlar acceso y autorización en servidor para rechazar rutas o recursos no permitidos |
| NFR-08 | Seguridad | Garantizar sesiones seguras, caducidad razonable, invalidación al desactivar usuarios y protección básica frente a intentos fallidos |
| NFR-09 | Seguridad / Auditoría | Registrar las acciones relevantes en un registro de auditoría no editable y consultable por el superadministrador, y registrar los errores técnicos con identificador. La autenticación de doble factor será opcional. |
| NFR-10 | Documentación | 	Proporcionar documentación breve y útil para el usuario y documentación técnica |
| NFR-11 | Tecnología / Despliegue | Usar software libre o razonablemente accesible y disponer de una forma reproducible de desplegarlo, con la configuración y los secretos separados del código. |
| NFR-12 | Rendimiento | Hacer que búsquedas y aperturas habituales sean prácticamente inmediatas, dejando tareas pesadas en segundo plano |
| NFR-13 | Escalabilidad / Concurrencia | El sistema debe de poder escalar a miles de clientes, cientos de miles de facturas y decenas/centenares de usuarios, y evitar conflictos con ediciones simultáneas. |
| NFR-14 | Fiabilidad | Realizar copias de seguridad automáticas y validar la restauración de datos en pruebas prácticas |
| NFR-15 | Tolerancia a fallos | Recuperar la generación de facturas sin duplicarlas tras interrupciones o fallos del sistema |
| NFR-16 | Mantenibilidad | Contar con un entorno de pruebas independiente para validar cambios antes de desplegarse |
| NFR-17 | seguridad de datos | Las comunicaciones deberán ir cifradas, las contraseñas no se almacenarán en texto plano, los secretos no se guardarán en el repositorio y los documentos no serán accesibles por URLs públicas adivinables, con enlaces temporales que caduquen.|
| NFR-18 | Privacidad | El sistema permitirá localizar los datos personales de un contacto y anonimizarlos, siempre y  cuando legalmente se pueda hacer, sin invalidar las facturas ya emitidas. |
| NFR-19 | Accesibilidad | La interfaz podrá usarse con teclado y con posibilidad de hacer zoom, con contraste y etiquetas.|


## 5. Reglas de negocio

Reglas del dominio o de la organización que condicionan el comportamiento del sistema
pero que no representan por sí mismas una funcionalidad.

| ID | Regla |
|---|---|
| RB-01 | Los datos de facturación no se utilizarán para campañas de marketing. |
| RB-02 | Cada factura conserva su importe en la moneda original en que se emitió. La conversión a la moneda base solo se usa para informes y no altera el total legal. |
| RB-03 | El sistema debe operar sin dependencia crítica del componente de Inteligencia Artificial (Brain). |

## 6. Suposiciones y decisiones de análisis

En esta sección se documentarán las decisiones tomadas por el equipo cuando la
información proporcionada por el cliente no sea suficiente para determinar unívocamente
un requisito.

| ID | Suposición o decisión | Justificación | Requisitos afectados |
|---|---|---|---|
| A-01 | Se ha de usar un dominio corportativo de TurbineH autorizado, por motivo de seguridad | Se habla de email de turbineh y luego de dominio corporativo autorizado | FR-06 |
| A-02 | El rol lector pasa a llamarse Usuario Operativo | El cliente dijo en la amplaición de requisitos que no usaramos lector | FR-07 |
| A-03 | Los enlaces temporales caducan a la hora de ser enviados | En la ampliación habla de enlaces temporales pero no determina el tiempo en el que estos funcionan, suponemos esta medida por seguridad | FR-37, NFR-17| 
| A-04 | En BR-02 se habla de precios variables | El motivo es porque se puede dar el caso de que un cliente se da de alta a mitad de mes, entonces no se le cobra el mes entero sino la parte proporcional. Además se pueden aplicar ciertos descuentos y excepciones. | | BR-02, FR-18, BR-18 |
| A-05 | Se ha aumentado la sección de trazabilidad de la plantilla orginal | Debido a que no contemplaba todos los casos para todos los FR | Sección 8 |


## 7. Dudas, ambigüedades y cuestiones pendientes

Se incluirán aquí aspectos de la información proporcionada por el cliente que sean
ambiguos, incompletos, contradictorios o que requieran aclaración.

| ID | Cuestión | Origen | Impacto | Estado / resolución |
|---|---|---|---|---|
| Q-01 | ¿Qué roles hay en el sistema? | Entrevista | Los roles del sistema están ambiguos. El rol de usuario está claro, pero no está claro si admin y superadmin son el mismo rol o son cosas diferentes | Resuelto, hay tres roles. Usuario, admin y superadmin |
| Q-02 | Baja de un cliente con deuda. El cliente dijo en la charla inicial que no puedes darte de baja hasta que pagues y en la ampliación se habla de que la deuda no bloquea la baja comercial. | Charla y requisistos ampliados | FR-9, BR-14. | Tomamos la información de la ampliación de requisistos. |
| Q-03 | ¿Es realmente un caso de uso que un cliente esté duplicado?| Inicialmente teníamos como caso de uso la duplicidad de un cliente, resultante de un include entre dos casos de uso: gestionar cliente y contactos y gestionar tareas del cliente. | Dudas acerca de si era necesario | Eliminado. Tras consultarlo con el profesor en la clase práctica nos comentó que efectivamente no era necesario. |

## 8. Trazabilidad

La tabla permitirá comprobar la relación entre las necesidades de negocio,
los requisitos de usuario y los requisitos del sistema.

| Requisito de negocio | Requisito de usuario | Requisito funcional / no funcional |
|---|---|---|
| BR-01 | UR-10, UR-12 | FR-08, FR-20, FR-27, FR-30 | 
| BR-02 | UR-05, UR-10, UR-12, UR-13 | FR-01, FR-02, FR-03, FR-11 | 
| BR-03 | UR-08, UR-13, UR-14 | FR-05, FR-23, FR-24, FR-42, FR-48, FR-50 | 
| BR-04 | UR-04, UR-09, UR-15 | FR-25, FR-29, FR-37, FR-40, FR-41 | 
| BR-05 | UR-01, UR-11 | FR-06 | 
| BR-06 | UR-12, UR-14 | FR-08, FR-15 | 
| BR-07 | — | FR-49 | 
| BR-08 | UR-08 | FR-38 | 
| BR-09 | UR-02, UR-05, UR-13 | FR-12, FR-14, FR-45 | 
| BR-10 | UR-05, UR-10, UR-13 | FR-01, FR-46 | 
| BR-11 | UR-02, UR-13, UR-15 | FR-12, FR-17, FR-26 | 
| BR-12 | UR-05, UR-12, UR-13 | FR-10, FR-13, FR-18, FR-31 | 
| BR-13 | UR-03, UR-13, UR-14 | FR-15, FR-19, FR-21, FR-22 | 
| BR-14 | UR-12 | FR-09 | 
| BR-15 | UR-12 | FR-16 | 
| BR-16 | UR-13, UR-14 | FR-05 | 
| BR-17 | UR-10 | FR-11 | 
| BR-18 | UR-12 | FR-47 | 
| BR-19 | UR-12 | FR-04, FR-09 | 
| BR-20 | UR-14 | FR-35 | 
| BR-21 | — | FR-49 | 
| BR-22 | - | FR-39 | 



| FR | Casos de uso | UR / BR |
|---|---|---|
| FR-01 | CU-12, CU-35 | UR-05, UR-10, UR-13, BR-02, BR-10 |
| FR-02 | CU-10 | UR-05, UR-10, BR-02 |
| FR-03 | CU-01 | UR-12, BR-02 |
| FR-04 | CU-01 | UR-12, BR-19 |
| FR-05 | CU-20, CU-21, CU-36 | UR-13, UR-14, BR-03, BR-16 |
| FR-06 | CU-30 | UR-01, UR-11, BR-05 |
| FR-07 | CU-31 | UR-01, UR-06 |
| FR-08 | CU-03 | UR-12, BR-01, BR-06 |
| FR-09 | CU-05 | UR-12, BR-14, BR-19 |
| FR-10 | CU-06 | UR-13, BR-12 |
| FR-11 | CU-01, CU-11 | UR-10, BR-02, BR-17 |
| FR-12 | CU-12, CU-15 | UR-02, BR-09, BR-11 |
| FR-13 | CU-10, CU-13 | UR-05, UR-13, BR-12 |
| FR-14 | CU-10, CU-12, CU-14 | UR-05, BR-09 |
| FR-15 | CU-16, CU-17 | UR-14, BR-06, BR-13 |
| FR-16 | CU-05 | UR-12, BR-15 |
| FR-17 | CU-35 | UR-13, BR-11 |
| FR-18 | CU-07, CU-08, CU-09, CU-13, CU-35 | UR-12, UR-13, BR-12 |
| FR-19 | CU-12, CU-14, CU-15 | UR-03, UR-13, BR-13 |
| FR-20 | CU-12 | UR-10, BR-01 |
| FR-21 | CU-17 | UR-14, BR-13 |
| FR-22 | CU-17 | UR-14, BR-13 |
| FR-23 | CU-19 | UR-14, BR-03 |
| FR-24 | CU-23 | UR-14, BR-03 |
| FR-25 | CU-26 | UR-09, UR-15, BR-04 |
| FR-26 | CU-18, CU-22 | UR-15, BR-11 |
| FR-27 | CU-01, CU-03 | UR-12, BR-01 |
| FR-28 | CU-15 | UR-03, UR-07 |
| FR-29 | CU-27 | UR-04, UR-09, BR-04 |
| FR-30 | CU-01, CU-10 | UR-10, BR-01 |
| FR-31 | CU-32 | UR-12, BR-12 |
| FR-32 | CU-04, CU-31 | UR-06, UR-12 |
| FR-33 | CU-01 | UR-12 |
| FR-34 | CU-25 | UR-14 |
| FR-35 | CU-25 | UR-14, BR-20 |
| FR-36 | CU-23, CU-25 | UR-14 |
| FR-37 | CU-26 | UR-15, BR-04 |
| FR-38 | CU-33 | UR-08, BR-08 |
| FR-39 | CU-36 | BR-22 |
| FR-40 | CU-28 | UR-15, BR-04 |
| FR-41 | CU-28 | UR-15, BR-04 |
| FR-42 | CU-23, CU-24 | UR-14, BR-03 |
| FR-43 | CU-01 | UR-12 |
| FR-44 | CU-01 | UR-07, UR-12 |
| FR-45 | CU-14 | UR-13, BR-09 |
| FR-46 | CU-18 | UR-10, BR-10 |
| FR-47 | CU-01 | UR-12, BR-18 |
| FR-48 | CU-33 | UR-08, BR-03 |
| FR-49 | CU-37 | BR-07, BR-21 |
| FR-50 | CU-29 | UR-14, BR-03 |
| NFR-09 | CU-34  | - |
| NFR-18 | CU-01  | BR-19 |
| NFR-08, NFR-17 | CU-30 CU-31 CU-26 | UR-11 |

## 9. Glosario

| Término | Definición |
|---|---|
| Descuento extraordinario | Reducción económica aplicada a un cliente que supera un cierto umbral configurable, requiriendo la aprobación del Superadministrador. |
| Factura rectificativa| Documento legal emitido exclusivamente para corregir errores fiscales en una factura emitida anteriorimente. |
| Rebote de correo| Acción de devolver un correo debido a que no ha podido ser entregado al destinatario, lo que dispara la apertura automática de una incidencia. |
| Prorrateo | Cálculo económico proporcional que se realiza automáticamente cuando un cliente activa una suscripción a mitad de un ciclo de facturación. |

