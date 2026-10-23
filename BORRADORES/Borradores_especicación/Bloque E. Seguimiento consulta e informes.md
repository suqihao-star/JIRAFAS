# Bloque E. Seguimiento, consulta e informes

---

## CU-23 — Gestionar notificaciones y canales

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-23 |
| **Nombre** | Gestionar notificaciones y canales |
| **Objetivo** | Consultar y atender notificaciones internas y configurar cómo recibe cada usuario los avisos, diferenciando el estado leído del resuelto. |
| **Actores participantes** | Principal: Usuario operativo. Otros participantes: Planificador del sistema para notificaciones y resúmenes automáticos. |

---

### 2. Precondiciones

- PRE-1. El usuario tiene una sesión válida y un perfil de notificaciones disponible.
- PRE-2. Existen eventos de negocio que pueden generar avisos al responsable del cliente.

---

### 3. Flujo principal

1. **Usuario operativo:** Abre su bandeja de notificaciones.
2. **Sistema:** Muestra los avisos permitidos, relacionados con pagos, vencimientos, incidencias, aprobaciones o tareas, con su estado correspondiente.
3. **Usuario operativo:** Selecciona una notificación y consulta su contenido y la referencia al elemento relacionado.
4. **Sistema:** Presenta el detalle autorizado y permite marcar el aviso como leído.
5. **Usuario operativo:** Cuando la notificación requiere una actuación, accede al elemento que debe resolver.
6. **Usuario operativo:** Una vez atendido el asunto, marca el aviso como resuelto si el tipo de notificación lo permite.
7. **Sistema:** Actualiza el estado, manteniendo la diferencia entre leído y resuelto.
8. **Sistema:** Conserva las preferencias de recepción aplicables al usuario.

---

### 4. Flujos alternativos

#### FA-1 — Configurar canales de recepción

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario decide cambiar su modo de recepción de notificaciones.

1. El Usuario operativo entra en sus preferencias de notificación.
2. Selecciona qué categorías desea recibir dentro de la aplicación, por correo o en un resumen diario, dentro de lo permitido.
3. El sistema guarda las preferencias, que usarán los siguientes avisos y resúmenes programados.

**Continuación:** Finaliza con las preferencias válidas guardadas.

#### FA-2 — Consultar la bandeja global como Administrador

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un Administrador autorizado solicita consultar la bandeja global.

1. Un Administrador autorizado entra en la bandeja global de avisos.
2. El sistema muestra las notificaciones generales que puede supervisar además de las propias.
3. El Administrador consulta o gestiona las permitidas sin alterar las asignaciones de los usuarios.

**Continuación:** Finaliza con la consulta global autorizada; no cambia estados por el mero acceso.

#### FA-3 — Notificación por mención o alerta programada

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Se recibe una notificación generada por mención o por alerta programada.

1. Un comentario menciona al usuario, o el Planificador detecta una condición de alerta configurada.
2. El sistema genera la notificación para su destinatario y aplica sus preferencias de canal.
3. La notificación queda disponible y se gestiona con las mismas reglas de lectura y resolución.

**Continuación:** El caso de uso continúa en el paso 2 del flujo principal y muestra el aviso en la bandeja del destinatario correspondiente.

#### FA-4 — Resumen diario

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Llega la hora del resumen diario y el usuario lo tiene activado.

1. El Planificador del sistema inicia la generación del resumen.
2. El sistema reúne las notificaciones pendientes de las categorías elegidas por cada usuario.
3. Las envía por correo y registra el envío.

**Continuación:** Finaliza; las notificaciones incluidas conservan su estado en la bandeja.

---

### 5. Flujos de excepción

#### FE-1 — Notificación sin acceso al contenido

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La notificación apunta a un recurso cuyo acceso no corresponde al usuario.

1. El usuario sigue teniendo una notificación pero perdió permiso sobre el cliente o documento relacionado.
2. El sistema permite ver únicamente lo que corresponda y bloquea el acceso al elemento restringido.
3. No expone información fuera del alcance del actor.

**Resultado:** No se expone el contenido del recurso; la notificación puede conservar su estado.

#### FE-2 — Error al cambiar el estado o preferencias

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Falla la actualización del estado o de las preferencias de recepción.

1. No puede guardarse una marca de leído, resolución o preferencia de canal.
2. El sistema informa del fallo y conserva el último estado confirmado.
3. El Usuario operativo puede reintentar la actualización.

**Resultado:** El sistema mantiene el último estado confirmado y ofrece reintentar.

#### FE-3 — Notificación ya resuelta por otro usuario

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Otro usuario ha resuelto el asunto de la notificación mientras tanto.

1. El sistema detecta que la notificación ya está resuelta.
2. Informa del estado actual y no duplica la acción.

**Resultado:** La notificación conserva el estado registrado.

---

### 6. Postcondiciones

- POST-1. Las notificaciones consultadas mantienen un estado coherente de lectura y resolución.
- POST-2. Las preferencias de canal quedan guardadas para posteriores comunicaciones internas.
- POST-3. Los avisos no sustituyen la gestión efectiva de deudas o incidencias asociadas.

---

## CU-24 — Configurar alertas

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-24 |
| **Nombre** | Configurar alertas |
| **Objetivo** | Definir reglas parametrizables para advertir sobre situaciones relevantes de cobro o seguimiento, sin implantar un motor general de procesos. |
| **Actores participantes** | Principal: Administrador. Otros participantes: ninguno en el diagrama; la evaluación de las reglas y la entrega de alertas pertenecen a CU-23, donde participa el Planificador. |

---

### 2. Precondiciones

- PRE-1. El Administrador ha iniciado sesión y solicita configurar reglas; sus permisos efectivos se verifican antes de guardar.
- PRE-2. Existe el conjunto de tipos de regla y parámetros admitidos por el sistema.

---

### 3. Flujo principal

1. **Administrador:** Abre la configuración de alertas.
2. **Sistema:** Presenta las reglas disponibles, por ejemplo antigüedad del vencimiento o importe pendiente acumulado.
3. **Administrador:** Elige un tipo de regla y establece los valores de sus parámetros.
4. **Sistema:** Valida que los valores y la condición pertenecen al conjunto de reglas admitido.
5. **Sistema:** Muestra cómo quedará definida la alerta y solicita confirmación.
6. **Administrador:** Confirma la configuración.
7. **Sistema:** Guarda la regla para que se evalúe cuando corresponda.
8. **Sistema:** Muestra la alerta configurada y la deja disponible para su administración futura.

---

### 4. Flujos alternativos

#### FA-1 — Modificar o desactivar una regla existente

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador elige editar o desactivar una regla ya registrada.

1. El Administrador selecciona una alerta previamente configurada.
2. Cambia un umbral permitido o desactiva la regla, según sus permisos.
3. El sistema valida y registra el nuevo estado sin convertirlo en un proceso BPMN abierto.

**Continuación:** El caso de uso continúa en el paso 4 del flujo principal para validar y después guardar el cambio.

---

### 5. Flujos de excepción

#### FE-1 — Parámetro inválido o regla no admitida

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Los parámetros no son válidos o se solicita un tipo de regla no admitido.

1. El Administrador introduce un umbral que no es válido o intenta definir un tipo de condición no contemplado.
2. El sistema rechaza la configuración y explica la restricción.
3. El Administrador corrige los parámetros o selecciona otra regla disponible.

**Resultado:** No se registra la configuración inválida.

#### FE-2 — Falta permiso para cambiar la alerta

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El usuario carece de permisos para modificar las reglas corporativas.

1. El usuario intenta alterar una regla corporativa sin tener autorización.
2. El sistema bloquea el cambio.
3. La configuración vigente no se modifica.

**Resultado:** La configuración existente se conserva sin cambios.

---

### 6. Postcondiciones

- POST-1. La regla de alerta queda creada, modificada o desactivada según la decisión válida.
- POST-2. Las evaluaciones posteriores utilizarán los parámetros vigentes.
- POST-3. La evaluación de las reglas por el Planificador, la entrega de alertas y los canales personales se gestionan en CU-23.

---

## CU-25 — Gestionar incidencias y comentarios

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-25 |
| **Nombre** | Gestionar incidencias y comentarios |
| **Objetivo** | Registrar y resolver incidencias administrativas asociadas a clientes o facturas, con responsables, prioridad, comentarios internos y adjuntos. |
| **Actores participantes** | Principal: Usuario operativo. Otros participantes: CU-19 invoca este caso mediante «include» cuando un correo rebota. |

---

### 2. Precondiciones

- PRE-1. El Usuario operativo está autenticado y puede acceder al cliente o factura de la incidencia.
- PRE-2. Existe una ficha de cliente y, si corresponde, una factura con la que relacionar la incidencia.

---

### 3. Flujo principal

1. **Usuario operativo:** Entra en la ficha o factura y selecciona crear incidencia.
2. **Sistema:** Solicita descripción, responsable, estado, prioridad y datos de seguimiento de la incidencia.
3. **Usuario operativo:** Introduce los datos y asocia la incidencia con el elemento correspondiente.
4. **Sistema:** Valida la información y el ámbito de permisos.
5. **Usuario operativo:** Confirma el registro.
6. **Sistema:** Crea la incidencia, la vincula con el cliente y, cuando proceda, con la factura, y la muestra entre los asuntos pendientes.
7. **Usuario operativo:** Puede incorporar comentarios internos y adjuntos permitidos; las menciones a usuarios generan sus notificaciones.
8. **Sistema:** Guarda las actuaciones y muestra el estado actualizado de la incidencia.

---

### 4. Flujos alternativos

#### FA-1 — Incidencia de entrega incluida desde CU-19

**Se produce en:** paso 1 del flujo principal.  
**Condición:** CU-19 requiere crear una incidencia de entrega a partir de un rebote de correo.

1. CU-19 detecta un rebote y solicita registrar una incidencia de entrega.
2. El sistema crea la incidencia con la factura, el destinatario y la información del fallo que conoce.
3. La incidencia queda disponible para que el responsable la consulte y la resuelva desde este caso de uso.

**Continuación:** El caso de uso continúa en el paso 4 del flujo principal con los datos del fallo ya disponibles y registra la incidencia.

#### FA-2 — Añadir comentario con mención

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El Usuario operativo menciona a un usuario en un comentario interno.

1. El Usuario operativo abre una incidencia o elemento autorizado y escribe un comentario interno.
2. Incluye una mención a otro usuario cuando corresponda.
3. El sistema conserva el comentario sin enviarlo al cliente y genera la notificación interna prevista por FR-36.

**Continuación:** El caso de uso continúa en el paso 8 del flujo principal tras guardar el comentario y generar la notificación de la mención.

#### FA-3 — Actualizar o cerrar una incidencia

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se selecciona una incidencia existente para modificarla o cerrarla.

1. El Usuario operativo selecciona una incidencia existente y modifica su estado, prioridad, responsable o información de seguimiento.
2. Cuando procede, registra que la incidencia ha quedado resuelta.
3. El sistema guarda la actualización y mantiene el historial relevante del asunto.

**Continuación:** Finaliza con su estado y resolución registrados, cuando proceda.

---

### 5. Flujos de excepción

#### FE-1 — Adjunto no permitido o no accesible

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Un adjunto supera las restricciones de tipo, tamaño o autorización.

1. El actor intenta subir un adjunto incompatible con las restricciones aplicables o acceder a uno que no puede consultar.
2. El sistema rechaza la operación e informa de la causa sin divulgar documentos ajenos.
3. La incidencia permanece sin cambios en ese adjunto.

**Resultado:** Se rechaza el archivo; la incidencia puede mantenerse sin él.

#### FE-2 — Datos imprescindibles insuficientes

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No se identifican cliente, asunto o datos esenciales de la incidencia.

1. La incidencia no tiene información mínima para identificar el asunto, responsable o estado que exige el formulario.
2. El sistema señala los campos pendientes y no confirma el alta.
3. El Usuario operativo corrige la información y vuelve a guardarla.

**Resultado:** No se registra una incidencia incompleta; se solicita corrección.

---

### 6. Postcondiciones

- POST-1. La incidencia queda creada, actualizada o resuelta, vinculada a su cliente y factura cuando corresponda.
- POST-2. Los comentarios permanecen internos y las menciones generan avisos a los usuarios autorizados.
- POST-3. Los adjuntos e incidencias conservan sus restricciones de acceso.

---

## CU-26 — Generar, exportar y conservar informes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-26 |
| **Nombre** | Generar, exportar y conservar informes |
| **Objetivo** | Obtener informes de facturación y cobros filtrados, exportarlos y consultarlos durante el periodo de conservación permitido, siempre según los permisos del usuario. |
| **Actores participantes** | Principal: Usuario operativo. |

---

### 2. Precondiciones

- PRE-1. El Usuario operativo está autenticado; los datos solicitados y la exportación quedan sujetos a comprobación de permisos.
- PRE-2. Existen datos de facturación para el periodo solicitado.

---

### 3. Flujo principal

1. **Usuario operativo:** Entra en el apartado de informes.
2. **Sistema:** Presenta filtros por periodo, cliente, responsable, país, sector, estado de factura, tipo y moneda.
3. **Usuario operativo:** Selecciona los filtros y solicita generar el informe.
4. **Sistema:** Valida los criterios y delimita los datos al ámbito autorizado del usuario.
5. **Sistema:** Calcula los resultados y genera una presentación consultable del informe.
6. **Sistema:** Muestra las cifras y el detalle permitido, junto con las opciones de exportación.
7. **Usuario operativo:** Selecciona CSV o PDF legible y confirma la exportación.
8. **Sistema:** Crea el archivo autorizado, lo pone a disposición mediante acceso autenticado y registra el informe con su periodo de conservación.

---

### 4. Flujos alternativos

#### FA-1 — Consultar un informe previamente generado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Usuario operativo abre un informe conservado, en lugar de crear uno nuevo.

1. El Usuario operativo accede a la relación de informes que puede consultar.
2. Selecciona un informe existente dentro de su plazo de conservación.
3. El sistema comprueba de nuevo sus permisos y ofrece el archivo o un enlace autenticado válido.

**Continuación:** Finaliza con el informe accesible según sus permisos actuales.

#### FA-2 — Regenerar un informe expirado o no conservado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita regenerar un informe cuyo archivo temporal ya no se conserva.

1. El informe generado ya no está almacenado por haberse cumplido el plazo configurable.
2. El sistema comprueba si conserva los datos necesarios y si el Usuario operativo mantiene los permisos.
3. Cuando ambas condiciones se cumplen, regenera el informe a partir de los criterios pertinentes.

**Continuación:** El caso de uso continúa en el paso 3 del flujo principal con los filtros autorizados guardados y genera una versión nueva cuando procede.

#### FA-3 — Informe de alcance global para administradores

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un Administrador autorizado requiere datos de facturación global.

1. Un Administrador o Superadministrador autorizado aplica filtros al conjunto global de facturación.
2. El sistema permite los resultados completos propios de sus permisos.
3. La exportación incluye únicamente los datos que puede consultar ese rol.

**Continuación:** El caso de uso continúa en el paso 5 del flujo principal con el ámbito global habilitado para ese usuario.

#### FA-4 — Informe pesado en segundo plano

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El informe requiere un procesamiento largo.

1. El sistema lo genera en segundo plano y el Usuario operativo puede seguir trabajando.
2. Muestra su estado: pendiente, procesando o completado con errores.
3. Notifica al Usuario operativo cuando está listo; la tarea no depende de que la pestaña siga abierta.

**Continuación:** El caso de uso continúa en el paso 6 del flujo principal cuando el informe está disponible.

---

### 5. Flujos de excepción

#### FE-1 — Intento de exportar información no autorizada

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La exportación incluye datos ajenos a los permisos del solicitante.

1. El usuario solicita clientes o datos que exceden su ámbito de acceso.
2. El sistema restringe o rechaza la consulta y la exportación en el servidor.
3. No entrega información ajena aunque se alteren manualmente los parámetros del filtro o el enlace.

**Resultado:** Se restringe o deniega la información no autorizada y no se genera una filtración.

#### FE-2 — No puede regenerarse el informe

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Los datos o permisos actuales impiden regenerar un informe antiguo.

1. El informe ha caducado y ya no existen los datos necesarios, o el actor ha perdido permisos.
2. El sistema informa de que no es posible regenerarlo en esas condiciones.
3. No muestra un archivo histórico al que el actor ya no está autorizado a acceder.

**Resultado:** No se genera un informe sin soporte válido y se explica el motivo.

#### FE-3 — Sin datos para los filtros

**Se produce en:** paso 5 del flujo principal.  
**Condición:** No existen datos que cumplan los filtros elegidos.

1. El sistema lo indica y sugiere ampliar los filtros.
2. No genera ningún archivo.

**Resultado:** No se crea el informe; pueden ajustarse los filtros.

---

### 6. Postcondiciones

- POST-1. El informe queda generado o consultado conforme a los filtros y al ámbito autorizado.
- POST-2. Las exportaciones admitidas se ofrecen como CSV o PDF con acceso autenticado.
- POST-3. Los archivos de informe siguen una conservación configurable distinta de la de las facturas emitidas.

---

## CU-27 — Consultar dashboard financiero

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-27 |
| **Nombre** | Consultar dashboard financiero |
| **Objetivo** | Permitir al Administrador comprobar indicadores de facturación y cobro y acceder al detalle que justifica cada cifra. |
| **Actores participantes** | Principal: Administrador. |

---

### 2. Precondiciones

- PRE-1. El Administrador ha iniciado sesión; el acceso a indicadores financieros globales se verifica al abrir el panel.
- PRE-2. Existen datos de facturas y cobros que permitan calcular los indicadores.

---

### 3. Flujo principal

1. **Administrador:** Abre el dashboard financiero.
2. **Sistema:** Obtiene los importes y estados de facturación y cobro que corresponde mostrar.
3. **Sistema:** Presenta las cifras actuales, entre ellas importes facturados, cobrados, pendientes o vencidos, según los indicadores disponibles.
4. **Administrador:** Selecciona un periodo o filtro de empresa cuando lo necesita.
5. **Sistema:** Recalcula las cifras a partir de los datos incluidos en el filtro, respetando moneda y reglas de suma aplicables.
6. **Administrador:** Selecciona una cifra para consultar qué registros contribuyen a ella.
7. **Sistema:** Muestra el desglose de facturas o cobros que componen el indicador.
8. **Administrador:** Examina los registros y vuelve al resumen cuando termina.

---

### 4. Flujos alternativos

#### FA-1 — Consultar otra métrica o desglosarla

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El Administrador selecciona otra cifra o un desglose distinto del dashboard.

1. El Administrador selecciona un indicador diferente o modifica los filtros.
2. El sistema actualiza tanto el importe agregado como los detalles subyacentes.
3. Las cifras continúan derivándose de los mismos datos que componen el desglose mostrado.

**Continuación:** El caso de uso continúa en el paso 7 del flujo principal para presentar el detalle seleccionado.

#### FA-2 — Presentar cifras de distintas monedas

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La información a representar incluye importes emitidos en distintas monedas.

1. Los registros consultados contienen facturas emitidas en monedas diferentes.
2. El sistema conserva los importes legales en su moneda original y, si aplica conversiones para el informe, utiliza las referencias registradas para reporting.
3. La presentación no modifica ni reescribe los importes originales de ninguna factura.

**Continuación:** El caso de uso continúa en el paso 6 del flujo principal después de aplicar las reglas de reporting y conservar las monedas originales.

#### FA-3 — Comparar con objetivos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador activa la comparación con los objetivos de facturación o cobro.

1. El sistema muestra las cifras reales junto al objetivo vigente para el periodo.
2. La comparación es informativa y no altera ningún dato.

**Continuación:** El caso de uso continúa en el paso 5 del flujo principal.

#### FA-4 — Agrupar por centro de coste

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador quiere ver las cifras por centro de coste o proyecto.

1. El sistema agrupa las cifras por categoría.
2. Cada grupo mantiene el desglose hasta las facturas que lo componen.

**Continuación:** El caso de uso continúa en el paso 6 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Información insuficiente para una cifra

**Se produce en:** paso 5 del flujo principal.  
**Condición:** No pueden reconciliarse los datos que componen un indicador.

1. El sistema carece de los datos necesarios para calcular un indicador de forma fiable.
2. Muestra la limitación en lugar de presentar una cifra inventada.
3. El Administrador puede consultar los registros o comunicar la incidencia.

**Resultado:** Se advierte que el valor no está disponible o requiere revisión y no se presenta como exacto.

#### FE-2 — Acceso no autorizado al dashboard global

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario no tiene acceso al dashboard financiero global.

1. Un usuario sin permisos globales intenta abrir el panel o su detalle por enlace directo.
2. El sistema deniega el acceso.
3. No revela información financiera del conjunto de clientes.

**Resultado:** No se revela información financiera global.

#### FE-3 — Filtro inválido

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador introduce un rango de fechas u otro criterio no válido.

1. El sistema detecta que el filtro no es válido.
2. No aplica el filtro e indica qué debe corregirse.
3. Mantiene las cifras que se estaban mostrando.

**Resultado:** El caso de uso regresa al paso 4 del flujo principal sin alterar la vista anterior.

---

### 6. Postcondiciones

- POST-1. El Administrador consulta indicadores financieros y sus desgloses correspondientes.
- POST-2. No se modifica ningún importe ni factura mediante esta consulta.
- POST-3. Cada cifra presentada se corresponde con un conjunto identificable de registros de origen.

---

## CU-28 — Gestionar objetivos y centros de coste

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-28 |
| **Nombre** | Gestionar objetivos y centros de coste |
| **Objetivo** | Definir objetivos informativos de facturación y clasificaciones de clientes o facturas por centros de coste o proyectos para su uso posterior en informes. |
| **Actores participantes** | Principal: Administrador. |

---

### 2. Precondiciones

- PRE-1. El Administrador ha iniciado sesión; el permiso para cambiar objetivos o categorías se verifica al guardar.
- PRE-2. El sistema dispone del área de configuración de informes y categorías.

---

### 3. Flujo principal

1. **Administrador:** Abre la gestión de objetivos y centros de coste.
2. **Sistema:** Muestra los objetivos de facturación vigentes y las categorías o proyectos existentes.
3. **Administrador:** Selecciona establecer o modificar un objetivo de facturación.
4. **Administrador:** Introduce el valor y el periodo aplicable y revisa su finalidad exclusivamente informativa.
5. **Sistema:** Valida el dato y presenta la comparación con el objetivo anterior cuando existe.
6. **Administrador:** Confirma la operación.
7. **Sistema:** Conserva quién realizó el cambio, la fecha y los valores anterior y nuevo.
8. **Sistema:** Muestra el objetivo actualizado, que podrá visualizarse en el dashboard sin alterar las facturas.

---

### 4. Flujos alternativos

#### FA-1 — Crear o modificar un centro de coste o proyecto

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador quiere mantener centros de coste o proyectos, en vez de objetivos.

1. El Administrador selecciona la gestión de categorías y crea o edita el nombre de una categoría.
2. El sistema valida y guarda la modificación.
3. Las facturas y clientes previamente clasificados mantienen su asociación histórica aunque cambie el nombre visible.

**Continuación:** Finaliza con la categoría creada o modificada conservando su histórico.

#### FA-2 — Clasificar un cliente o factura

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se solicita asignar un centro de coste o proyecto a una ficha o factura.

1. El Administrador autorizado selecciona un cliente o factura y una categoría de centro de coste o proyecto.
2. El sistema registra la clasificación para su posterior filtrado en informes.
3. No cambia importes, impuestos ni el documento original por el hecho de clasificarlo.

**Continuación:** Finaliza con la clasificación registrada sin alterar el total legal de la factura.

---

### 5. Flujos de excepción

#### FE-1 — Objetivo o categoría inválidos

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El objetivo o categoría contiene valores inválidos.

1. El valor del objetivo o los datos de la categoría no son admisibles.
2. El sistema informa de la validación fallida y no guarda el dato incorrecto.
3. El Administrador revisa y corrige la propuesta.

**Resultado:** No se guarda el cambio y se solicita corregir los parámetros.

#### FE-2 — Modificación sin autorización

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El actor carece de permiso para modificar el objetivo o categoría.

1. El actor intenta cambiar objetivos o categorías sin permiso.
2. El sistema rechaza la operación.
3. Se conservan los valores vigentes y las asociaciones existentes.

**Resultado:** Se mantiene la configuración previa sin afectar facturas.

#### FE-3 — Eliminar una categoría con información asociada

**Se produce en:** paso 1 de FA-1.  
**Condición:** Se intenta eliminar un centro de coste o proyecto que tiene clientes o facturas asociados.

1. El sistema impide la eliminación.
2. Ofrece desactivar la categoría en su lugar.
3. Las asociaciones históricas se conservan.

**Resultado:** La categoría no se elimina y el histórico permanece intacto.

---

### 6. Postcondiciones

- POST-1. Los objetivos y categorías quedan actualizados conforme a la autorización.
- POST-2. Los cambios de objetivos tienen registro de autor, fecha y valores anterior y nuevo.
- POST-3. La clasificación se refleja en informes sin reconstruir ni alterar facturas históricas.

---

## CU-29 — Consultar pantalla de trabajo diario

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-29 |
| **Nombre** | Consultar pantalla de trabajo diario |
| **Objetivo** | Ofrecer a cada usuario un resumen de los asuntos de facturación y seguimiento que requieren su atención, con acceso al registro correspondiente. |
| **Actores participantes** | Principal: Usuario operativo. |

---

### 2. Precondiciones

- PRE-1. El Usuario operativo ha iniciado sesión y tiene asignaciones y permisos que determinan su ámbito de trabajo.
- PRE-2. El sistema dispone de los estados actuales de facturas, cobros, entregas, aprobaciones y tareas.

---

### 3. Flujo principal

1. **Usuario operativo:** Inicia sesión y accede a su pantalla de trabajo diario.
2. **Sistema:** Consulta las facturas próximas a vencer o vencidas que el usuario puede atender.
3. **Sistema:** Reúne pagos pendientes de conciliación, problemas de entrega, solicitudes de aprobación y tareas según sus permisos.
4. **Sistema:** Muestra los asuntos con información suficiente para reconocer su tipo y situación.
5. **Usuario operativo:** Identifica una tarea o incidencia que necesita revisar.
6. **Usuario operativo:** Selecciona el acceso directo al cliente, factura, pago o asunto correspondiente.
7. **Sistema:** Comprueba la autorización actual y abre el elemento en la función que lo gestiona.
8. **Usuario operativo:** Continúa su actuación en el caso de uso correspondiente, sin que la navegación cambie automáticamente el estado del asunto.

---

### 4. Flujos alternativos

#### FA-1 — Vista de un Administrador

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario que consulta la pantalla tiene rol de Administrador y permiso global.

1. Un Administrador abre su pantalla de trabajo diario.
2. El sistema puede incluir asuntos de su ámbito, como aprobaciones pendientes, además de los elementos operativos permitidos.
3. Los accesos directos llevan a la función correspondiente con comprobación de permisos.

**Continuación:** El caso de uso continúa en el paso 2 del flujo principal con la información adicional de su bandeja global.

#### FA-2 — No existen asuntos pendientes

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No existen asuntos que el usuario deba atender.

1. No se encuentra ninguna factura, pago, tarea o incidencia que requiera atención del usuario.
2. El sistema muestra la pantalla sin elementos pendientes y lo indica claramente.
3. El Usuario operativo puede continuar consultando otras funciones autorizadas.

**Continuación:** Finaliza mostrando la bandeja vacía sin generar tareas nuevas.

---

### 5. Flujos de excepción

#### FE-1 — Elemento reasignado o sin acceso

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El usuario ya no dispone de acceso por una reasignación o cambio de permisos.

1. El usuario pulsa un acceso directo a un asunto cuya asignación o autorización ha cambiado.
2. El sistema vuelve a comprobar permisos antes de mostrarlo.
3. Si ya no tiene acceso, rechaza la apertura sin divulgar su contenido.

**Resultado:** Se deniega la apertura y se actualiza la vista permitida.

#### FE-2 — Error al actualizar la pantalla

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La información de la bandeja no puede actualizarse.

1. No pueden obtenerse temporalmente los estados de una o varias fuentes.
2. El sistema muestra el resto de secciones e indica cuál no ha podido cargarse.
3. El usuario puede reintentar la consulta sin modificar el estado de los asuntos.

**Resultado:** Se muestra el error sin dar por resueltos asuntos que siguen pendientes.

#### FE-3 — Elemento ya resuelto

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Otro usuario ha resuelto el asunto mientras tanto.

1. El sistema informa del estado actual del elemento.
2. Lo retira de la lista de pendientes.

**Resultado:** La pantalla se actualiza sin abrir un asunto ya cerrado.

---

### 6. Postcondiciones

- POST-1. El usuario obtiene una vista de los asuntos que puede atender con accesos directos autorizados.
- POST-2. Consultar o navegar no implica resolver automáticamente una tarea ni una incidencia.
- POST-3. El alcance de los datos está limitado por el rol y las asignaciones vigentes.
