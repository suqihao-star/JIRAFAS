
# Requisitos

## 1. Contexto y alcance

### 1.1. Objetivo del sistema

Se quiere crear una aplicación de uso privado para gestionar las facturas del producto de la empresa para evitar la carga administrativa que conlleva gestionarlo manualmente.

### 1.2. Alcance

Debe poder gestionar todas las facturas de la empresa sin gestionar los pagos en si.

### 1.3. Actores y partes interesadas

Identificar las personas, organizaciones o sistemas que interactúan con el sistema
o tienen algún interés relevante en su funcionamiento.

<!--
EJEMPLO:

| Actor / stakeholder | Descripción | Intereses principales |
|---|---|---|
| Personal administrativo | Personal de Turbine encargado de gestionar clientes, facturas y cobros | Realizar las tareas administrativas de forma rápida y disponer de información actualizada |
| Administrador | Usuario con permisos sobre la gestión del sistema y sus usuarios | Gestionar usuarios, permisos y configuración |
| Cliente de Turbine | Empresa a la que Turbine presta sus servicios y factura periódicamente | Recibir correctamente sus facturas y comunicaciones relacionadas con los pagos |
| Sistema de pagos | Sistema externo en el que se reflejan los cobros | Proporcionar información que permita determinar si una factura ha sido pagada |

Los elementos anteriores son únicamente un ejemplo de cómo documentar esta sección.
El equipo debe identificar y justificar los actores y stakeholders que considere
adecuados a partir de la información del caso.
-->

| Actor / stakeholder | Descripción | Intereses principales |
|---|---|---|
| ... | ... | ... |


## 2. Requisitos de negocio

Los requisitos de negocio describen los objetivos, necesidades o resultados que
la organización pretende conseguir mediante el desarrollo del sistema. No describen
todavía funcionalidades concretas del software.

| ID | Requisito | Fuente |
|---|---|---|
| BR-01 | Eliminar la carga administrativa que se ejercía antes en la facturación manual | Cliente / entrevista |
| BR-02 | Dar soporte a una facturación de precios variables y suscripciones recurrentes ( buscamos no requerir de hacer cálculos manuales) | Cliente / entrevista |
| BR-03 | Gestionar los impagos de forma automática | Cliente / entrevista |
| BR-04 | Proporcionar a los administradores reportes de la salud financiera del negocio | Cliente / entrevista |
| BR-05 | Cumplir requisitos legales (protección de datos) | Cliente / entrevista |

## 3. Requisitos de usuario

Los requisitos de usuario describen las necesidades, objetivos o servicios que los
usuarios esperan obtener del sistema. Deben expresarse desde el punto de vista del
usuario, evitando entrar todavía en detalles internos de implementación.

| ID | Actor | Requisito | Fuente |
|---|---|---|---|
| UR-01 | Lector | Podrá consultar la información básica de las facturas | Cliente / Entrevista |
| UR-02 | Lector | Podrá descargar facturas en PDF | Cliente / Entrevista |
| UR-03 | Lector | Podrá consultar y (filtrar por) el estado de las facturas | Cliente / Entrevista |
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
| FR-01 | El sistema debe gestionar y crear facturas válidas, con numeración correlativa, datos fiscales correspondientes y cálculo de IVA automáticamente | UR-01 |
| FR-02 | El sistema debe gestionar factures puntuales o recurrentes | UR-01 |
| FR-03 | El sistema debe incluir clientes nuevos y facturas nuevas registrando su nombre, correo y datos fiscales | UR-11 |
| FR-04 | El sistema debe perseguir el cobro por sí mismo a través de un flujo de impago | BR-03 |
| FR-05 | El sistema debe permitir el registro de administradores o usuarios a través de correo y contraseña secreta | UR-07 |
| FR-06 | El sistema debe asegurarse que el correo introducido es de dominio @turbineh.com | UR-07 |
| FR-07 | El sistema debe tener 2 roles diferentes: Administrador y usuario (PENDIENTE TRANSCRIPCION) <-- Ver punto 7 del markdown | UR-06 |
| FR-08 | El sistema debe poder incluir la importación de datos de clientes de forma masiva a través de un .csv | UR-07 |
| FR-09 | El sistema debe mantener la información de un cliente dado de baja el tiempo que la ley permita | BR-05 |
| FR-10 | El sistema debe impedir que un cliente se dé de baja si tiene algún impago | BR-03 |
| FR-11 | El sistema debe permitir la actualización del plan de precios de un cliente anualmente en función de su facturación | BR-02 |
| FR-12 | El sistema debe emitir facturas el día 1 de cada mes. En caso de contratar a mitad de mes, facturarse proporcionalmente| BR-02 |
| FR-13 | El sistema debe permitir exportar facturas en formato PDF | UR-02 |
| FR-14 | El sistema debe permitir cambiar la cuantía de las facturas | UR-05 |
| FR-15 | El sistema debe bloquear la edición de facturas una vez pasada su fecha de presentación trimestral | UR-05 |
| FR-16 | El sistema debe conectarse con Stripe (o Revolut) para el seguimiento del pago | UR-01, BR-01 |
| FR-17 | El sistema debe usar mensajes distintos en la notificación según si es por emisión de factura recurrente o aviso de impago | BR-03 |
| FR-18 | El sistema debe incluir un buscador que permita filtrar clientes por nicho y por estado de la factura: (pagada, impagada, pendiente) | UR-03 |
| FR-19 | El sistema debe mostrar la relación de facturación del cliente a nivel semanal, mensual y anual | UR-04 |
| FR-20 | El sistema debe dejar editar las plantillas de correo electrónico de factura, recordatorio previo, vencimiento, impago, disputa resuelta | BR-01 |



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
| A-02 | ... | ... | ... |


## 7. Dudas, ambigüedades y cuestiones pendientes

Se incluirán aquí aspectos de la información proporcionada por el cliente que sean
ambiguos, incompletos, contradictorios o que requieran aclaración.

| ID | Cuestión | Origen | Impacto | Estado / resolución |
|---|---|---|---|---|
| Q-01 | ¿Qué roles hay en el sistema? | Entrevista | Los roles del sistema están ambiguos. El rol de usuario está claro, pero no está claro si admin y superadmin son el mismo rol o son cosas diferentes | Pendiente |


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
