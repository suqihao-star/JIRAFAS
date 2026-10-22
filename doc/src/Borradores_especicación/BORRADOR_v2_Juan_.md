# Especificación de casos de uso

---

## CU-01 — Gestionar cliente y contactos

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-01 |
| **Nombre** | Gestionar cliente y contactos |
| **Objetivo** | Dar de alta y mantener la ficha fiscal y comercial de un cliente, sus contactos y los datos operativos relacionados, evitando duplicados y respetando el histórico. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: No hay actor externo directo; CU-02 interviene mediante «include». |

---

### 2. Precondiciones

- PRE-1. El Operador ha iniciado sesión y dispone de permiso para gestionar el cliente o crear uno nuevo.
- PRE-2. Para una modificación, el cliente ya existe y está dentro del ámbito autorizado del Operador.

---

### 3. Flujo principal

1. **Actor:** El Operador accede a la gestión de clientes y selecciona crear una ficha.
2. **Sistema:** El sistema presenta los datos fiscales (razón social, identificador fiscal, domicilio, país, moneda) y comerciales (nombre comercial, inicio, plan, tarifa, responsable y condiciones de pago).
3. **Actor:** El Operador introduce la información y los contactos que correspondan, diferenciando los destinatarios de facturas y de avisos de impago.
4. **Sistema:** El sistema propone los valores habituales de país, moneda, vencimiento y tarifa, dejando visibles los valores elegidos.
5. **Sistema:** El sistema valida los campos necesarios e incluye CU-02 «Detectar cliente duplicado» al comprobar el identificador fiscal.
6. **Sistema:** El sistema calcula y muestra el prorrateo antes de confirmar el alta cuando la suscripción empieza dentro del mes; si se aplica una excepción comercial registrada, muestra esa condición.
7. **Actor:** El Operador revisa los datos, la tarifa y las condiciones y confirma el alta.
8. **Sistema:** El sistema registra la ficha, sus contactos y condiciones comerciales; incorpora el evento a la línea temporal del cliente y muestra el resultado.

---

### 4. Flujos alternativos

#### FA-1 — Modificar datos, contactos y organización de una ficha existente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se selecciona actualizar una ficha ya existente en lugar de crear un cliente.

1. En lugar de crear una ficha, el Operador abre un cliente autorizado y modifica sus datos o contactos.
2. Si cambia el identificador fiscal, se vuelve a ejecutar CU-02; el sistema muestra las modificaciones antes de guardar.
3. Tras confirmar, el sistema conserva los eventos relevantes en la línea temporal y mantiene los destinatarios registrados en envíos históricos.

**Continuación:** Finaliza con la ficha modificada y su historial conservado.

#### FA-2 — Marcar un contacto inactivo, etiquetar o señalar favorito

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita inactivar un contacto o cambiar etiquetas o favoritos de la ficha.

1. El Operador selecciona un contacto o una opción de organización de la ficha.
2. El sistema marca al contacto como inactivo sin borrar facturas históricas, o guarda etiquetas y el estado de favorito según la acción.
3. El sistema actualiza la ficha y muestra el resultado sin modificar los permisos de acceso.

**Continuación:** Finaliza con el dato organizativo actualizado, sin alterar los permisos.

#### FA-3 — Registrar una excepción comercial

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se elige una excepción comercial durante el alta o la actualización.

1. El Operador elige una excepción expresamente prevista: inicio futuro, primer mes gratuito o ausencia de prorrateo.
2. El sistema muestra sus consecuencias económicas. Si la excepción tiene efecto económico (primer mes gratuito o sin prorrateo), queda registrada como pendiente de aprobación y no se aplica en la facturación hasta que un Administrador la apruebe; el inicio futuro no requiere aprobación y deja al cliente «pendiente de activación», sin facturas ni recordatorios hasta esa fecha.
3. El sistema presenta la excepción para confirmación; únicamente al confirmar el alta o cambio se guarda la condición comercial (inicio futuro, primer mes gratuito o sin prorrateo).

**Continuación:** Retoma el paso 7 del flujo principal para revisar y confirmar las condiciones; la excepción queda registrada.

#### FA-4 — Anonimizar un contacto cuando proceda

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un Administrador autorizado solicita anonimizar un contacto cuando legalmente procede.

1. Un Administrador autorizado accede al contacto y solicita su anonimización.
2. El sistema comprueba las restricciones legales y los datos que deben conservarse en los documentos emitidos.
3. Se anonimiza únicamente la información permitida, manteniendo intactos los documentos históricos obligatorios.

**Continuación:** Finaliza con la anonimización autorizada y con el histórico obligatorio intacto.

#### FA-5 — Datos fiscales todavía no disponibles

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Operador aún no dispone del identificador fiscal del cliente (por ejemplo, un identificador extranjero).

1. El Operador deja sin completar el identificador fiscal y continúa con el resto de la ficha.
2. El sistema permite guardar la ficha marcándola con «datos fiscales incompletos» e indica qué falta; CU-02 informa de que no puede comprobar duplicados por ese dato.
3. Mientras no se completen los datos, el cliente no puede facturarse ni activar su recurrencia.

**Continuación:** Retoma el paso 7 del flujo principal; la ficha queda guardada con la marca de datos incompletos.

---

### 5. Flujos de excepción

#### FE-1 — Datos obligatorios incompletos o inválidos

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Faltan campos obligatorios o alguno no supera la validación de datos.

1. El sistema detecta que faltan datos indispensables o que alguno no tiene un formato aceptable.
2. Señala exactamente qué campo debe corregirse y no confirma el alta o la modificación.
3. El Operador corrige la información y vuelve al paso de validación.

**Resultado:** No se crea ni actualiza la ficha; puede corregirse y repetirse la validación del paso 5.

#### FE-2 — Posible empresa duplicada

**Se produce en:** paso 5 del flujo principal.  
**Condición:** CU-02 encuentra un identificador fiscal coincidente que requiere revisión.

1. CU-02 detecta otro cliente con el mismo identificador fiscal.
2. El sistema presenta el aviso y los datos autorizados que permiten distinguir las fichas; no fusiona automáticamente.
3. El Operador revisa el registro existente y decide si debe volver a su ficha o corregir los datos antes de continuar.

**Resultado:** No se fusionan fichas; el usuario revisa la coincidencia antes de continuar o desistir.

#### FE-3 — Cliente no asignado

**Se produce en:** paso 1 de FA-1.  
**Condición:** El Operador intenta abrir o modificar un cliente que no tiene asignado.

1. El sistema comprueba la asignación en el servidor, aunque el usuario conozca la dirección de la ficha.
2. Rechaza el acceso e informa de que el cliente no está asignado al usuario.
3. No muestra ni modifica ningún dato del cliente.

**Resultado:** Se deniega el acceso y la ficha permanece sin cambios.

---

### 6. Postcondiciones

- POST-1. La ficha del cliente y sus contactos quedan creados o actualizados con los datos confirmados.
- POST-2. Las excepciones comerciales, estados de contacto, etiquetas y favoritos quedan registrados cuando proceda.
- POST-3. Los documentos y destinatarios históricos no se alteran; se preservan las restricciones de acceso.

---

## CU-02 — Detectar cliente duplicado

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-02 |
| **Nombre** | Detectar cliente duplicado |
| **Objetivo** | Comprobar si el identificador fiscal de un cliente ya figura en el sistema y advertir una posible duplicidad sin fusionar automáticamente las fichas. |
| **Actores participantes** | Sin actor iniciador propio; comprobación interna invocada obligatoriamente por CU-01 o CU-03. El Operador participa a través del caso de uso de origen. |

---

### 2. Precondiciones

- PRE-1. CU-01 o CU-03 ha solicitado validar un cliente con identificador fiscal disponible.
- PRE-2. El sistema puede consultar los identificadores fiscales ya registrados dentro de las reglas de acceso.

---

### 3. Flujo principal

1. **Sistema (caso invocante):** CU-01 o CU-03 invoca la comprobación proporcionando el identificador fiscal del cliente que se está creando o modificando.
2. **Sistema:** El sistema normaliza y comprueba el identificador según la validación disponible.
3. **Sistema:** El sistema busca posibles coincidencias entre las fichas existentes, excluyendo la misma ficha cuando se trate de una modificación.
4. **Sistema:** El sistema determina si existen coincidencias relevantes por identificador fiscal.
5. **Sistema:** El sistema devuelve el resultado «sin duplicado detectado» cuando no existen coincidencias.
6. **Sistema (caso invocante):** El caso de uso CU-01 o CU-03 continúa con el resultado obtenido.

---

### 4. Flujos alternativos

#### FA-1 — Coincidencia encontrada

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La comprobación localiza una ficha con el mismo identificador fiscal.

1. En el paso de comparación se localiza una ficha con el mismo identificador fiscal.
2. El sistema devuelve el aviso de posible duplicidad y la información permitida para revisarla.
3. El caso de uso que invocó la comprobación deja la decisión de continuar, corregir o descartar en manos del Operador; no se fusionan empresas.

**Continuación:** Devuelve el aviso a CU-01 o CU-03, que decidirá cómo continuar sin fusionar registros.

#### FA-2 — Coincidencia dentro de una importación CSV

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La comprobación la invoca CU-03 y una fila del archivo coincide con un cliente existente.

1. El sistema marca la fila con posible duplicado en la previsualización de la importación.
2. El Operador decide fila a fila si la importa como cliente nuevo, actualiza de forma explícita el cliente existente, la omite o la corrige.
3. El sistema nunca fusiona ni actualiza un cliente existente por su cuenta.

**Continuación:** Devuelve a CU-03 la decisión tomada para cada fila.

---

### 5. Flujos de excepción

#### FE-1 — Identificador fiscal no comprobable

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El identificador fiscal es ilegible, inválido o no permite una comprobación fiable.

1. El identificador proporcionado está vacío, tiene un formato inválido o no puede validarse con las reglas disponibles.
2. El sistema informa del motivo por el que no puede realizarse una comprobación fiable.
3. El caso de uso de origen solicita corregir el dato o trata su ausencia conforme a las validaciones de la operación.

**Resultado:** Se informa al caso de uso de origen; este debe corregir o tratar el dato según sus reglas.

#### FE-2 — Error al consultar las fichas

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se produce un fallo técnico al buscar coincidencias.

1. La búsqueda de coincidencias no puede completarse por un fallo técnico.
2. El sistema comunica que la comprobación ha fallado y evita presentar un falso resultado de ausencia de duplicados.
3. El proceso de origen deja pendiente la operación afectada o permite reintentar la comprobación.

**Resultado:** No se certifica falsamente la ausencia de duplicados y la operación queda pendiente o se reintenta.

---

### 6. Postcondiciones

- POST-1. Se devuelve a CU-01 o CU-03 un resultado de comprobación o una incidencia de validación.
- POST-2. No se altera ni fusiona ningún cliente existente.

---

## CU-03 — Importar datos por CSV

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-03 |
| **Nombre** | Importar datos por CSV |
| **Objetivo** | Incorporar o actualizar clientes mediante una carga masiva controlada, con previsualización, detección de duplicados, corrección de errores y resumen trazable. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: CU-02 interviene mediante «include»; para importar facturas históricas puede intervenir un Administrador autorizado. |

---

### 2. Precondiciones

- PRE-1. El Operador ha iniciado sesión y tiene permiso para importar datos en su ámbito de gestión.
- PRE-2. Dispone de un fichero CSV con los datos que pretende cargar.

---

### 3. Flujo principal

1. **Actor:** El Operador abre la función de importación y selecciona el CSV.
2. **Sistema:** El sistema lee el fichero y presenta una previsualización de las filas y columnas reconocidas.
3. **Actor:** El Operador confirma la correspondencia entre las columnas del archivo y los campos de cliente.
4. **Sistema:** El sistema valida las filas y ejecuta CU-02 para comprobar duplicados por identificador fiscal en cada registro aplicable.
5. **Sistema:** El sistema presenta las filas válidas, las incidencias detectadas y los posibles registros nuevos o existentes.
6. **Actor:** El Operador revisa las advertencias, corrige la asignación de campos o decide qué filas admitidas va a importar.
7. **Sistema:** Antes de aplicar la operación, el sistema muestra el resultado previsto y solicita confirmación.
8. **Sistema:** El sistema crea o actualiza los registros autorizados, registra la ejecución y muestra el resumen de creados, actualizados y rechazados con sus motivos.

---

### 4. Flujos alternativos

#### FA-1 — Importar solo filas válidas o corregir errores

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Existen filas inválidas, dudas de correspondencia de columnas o se opta por importar solo registros válidos.

1. Durante la revisión se detectan filas rechazadas o columnas mal interpretadas.
2. El Operador corrige el mapeo, sustituye el fichero o confirma únicamente las filas permitidas por la política de importación.
3. El sistema repite las comprobaciones necesarias y conserva en el resumen las filas no importadas y sus motivos.

**Continuación:** Retoma el paso 4 para revalidar los datos y después el paso 7 para confirmar lo permitido.

#### FA-2 — Importación administrativa de facturas históricas

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un Administrador autorizado solicita migrar facturas históricas en vez de clientes.

1. Un Administrador con permiso selecciona importar el histórico de facturas, en lugar de clientes.
2. El sistema distingue cada factura como migrada, conserva su número y documento original cuando estén disponibles y muestra una previsualización.
3. Al confirmar, guarda las facturas históricas sin emitirlas de nuevo, sin consumir numeración de nuevas emisiones y sin enviar comunicaciones a clientes.

**Continuación:** Finaliza con las facturas registradas como migradas, sin nueva emisión ni aviso al cliente.

#### FA-3 — Cancelar antes de confirmar

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El Operador decide no continuar tras revisar el resultado previsto.

1. El Operador cancela la importación.
2. El sistema descarta la carga sin crear ni modificar registros.

**Continuación:** Finaliza sin cambios en los datos.

#### FA-4 — Filas sin identificador fiscal

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Una o varias filas del CSV no incluyen identificador fiscal.

1. CU-02 informa de que no puede comprobar duplicados en esas filas.
2. El sistema las marca como «datos fiscales incompletos» en la previsualización y permite importarlas.
3. Los clientes importados así no pueden facturarse hasta completar sus datos fiscales.

**Continuación:** Retoma el paso 5 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Archivo ilegible o estructura incompatible

**Se produce en:** paso 2 del flujo principal.  
**Condición:** No es posible leer el CSV o faltan columnas necesarias.

1. El sistema no puede interpretar el CSV o faltan columnas necesarias.
2. Informa de las columnas o del formato problemáticos sin crear registros.
3. El Operador selecciona un archivo corregido y reinicia la validación.

**Resultado:** No se importan registros; el usuario puede aportar un archivo válido y volver al paso 2.

#### FE-2 — Fila duplicada o datos incorrectos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Una o varias filas contienen datos inválidos o posibles duplicidades.

1. La validación localiza una fila incompatible, datos obligatorios ausentes o una posible duplicidad.
2. La fila queda señalada con su motivo; las duplicidades no se fusionan automáticamente.
3. El Operador corrige o excluye la fila antes de confirmar el conjunto permitido.

**Resultado:** Se señalan las filas; solo se importarán las aceptadas después de su revisión.

#### FE-3 — Error parcial durante la carga

**Se produce en:** paso 8 del flujo principal.  
**Condición:** Algunas filas fallan durante el procesamiento de la carga.

1. Una parte de las filas no puede procesarse.
2. El sistema registra qué filas se aplicaron y cuáles fallaron, sin ocultar el resultado de la operación.
3. El Operador consulta el resumen y puede preparar una nueva importación de los registros pendientes.

**Resultado:** Se conserva el detalle de éxitos y errores, y los registros fallidos pueden reintentarse sin ocultar los aplicados.

#### FE-4 — Ninguna fila válida

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Todas las filas del archivo han sido rechazadas en la validación.

1. El sistema no permite confirmar la importación.
2. Muestra el motivo de rechazo de cada fila.
3. El Operador corrige el archivo y vuelve a cargarlo.

**Resultado:** No se importa ningún registro.

---

### 6. Postcondiciones

- POST-1. Los clientes o facturas históricas admitidos quedan almacenados según la modalidad autorizada.
- POST-2. Existe un registro de importación con balance de registros creados, actualizados y rechazados, y sus causas.
- POST-3. Las facturas migradas no provocan notificaciones ni nuevas emisiones.

---

## CU-04 — Gestionar tareas del cliente

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-04 |
| **Nombre** | Gestionar tareas del cliente |
| **Objetivo** | Crear y mantener tareas pendientes asociadas a la ficha de un cliente, de forma que su seguimiento sobreviva a los cambios de responsable. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). |

---

### 2. Precondiciones

- PRE-1. El Operador ha iniciado sesión y solicita acceder a las tareas de un cliente.
- PRE-2. La ficha del cliente existe.

---

### 3. Flujo principal

1. **Actor:** El Operador abre la ficha de un cliente y entra en sus tareas.
2. **Sistema:** El sistema muestra las tareas pendientes y su situación actual.
3. **Actor:** El Operador selecciona crear una tarea e introduce la descripción del asunto pendiente y la información de seguimiento aplicable.
4. **Sistema:** El sistema comprueba que la tarea pertenece a una ficha existente y que el actor puede gestionarla.
5. **Actor:** El Operador confirma el registro.
6. **Sistema:** El sistema vincula la tarea al cliente y la incorpora al trabajo pendiente del responsable que tenga asignado el cliente.
7. **Sistema:** El sistema confirma que la tarea ha quedado registrada.

---

### 4. Flujos alternativos

#### FA-1 — Actualizar o resolver una tarea

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Operador selecciona una tarea existente en vez de crear una nueva.

1. El Operador selecciona una tarea existente del cliente.
2. Modifica su información o registra que ha quedado resuelta.
3. El sistema actualiza su estado, registra quién y cuándo la resolvió y deja de mostrarla como pendiente en la ficha y en la pantalla de trabajo diario.

**Continuación:** Finaliza con la tarea modificada o resuelta.

#### FA-2 — Cambio de responsable del cliente

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Un Administrador cambia la asignación del cliente mediante CU-31.

1. Un Administrador cambia la asignación del cliente mediante CU-31.
2. Las tareas pendientes siguen vinculadas al cliente, sin transferir su propiedad al usuario anterior.
3. El sistema las presenta al nuevo responsable manteniendo el historial de actuaciones.

**Continuación:** Finaliza conservando la asociación de las tareas al cliente y presentándolas al nuevo responsable.

---

### 5. Flujos de excepción

#### FE-1 — Cliente o tarea sin acceso

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El usuario intenta intervenir sobre un cliente o tarea no autorizado.

1. El usuario intenta modificar una tarea de un cliente que no tiene asignado o no puede consultar.
2. El sistema rechaza la operación por falta de autorización.
3. No se modifica ninguna tarea.

**Resultado:** Se deniega la operación y las tareas quedan sin cambios.

#### FE-2 — Información esencial de tarea ausente

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Falta la información mínima para identificar la tarea.

1. Se intenta guardar una tarea sin información suficiente para identificar qué debe realizarse.
2. El sistema indica el dato que debe completarse y no guarda la tarea incompleta.
3. El Operador corrige la información y confirma de nuevo.

**Resultado:** No se guarda la tarea incompleta; se solicita corregirla y repetir el paso 4.

#### FE-3 — Tarea modificada por otro usuario

**Se produce en:** paso 2 de FA-1.  
**Condición:** Otro usuario ha modificado o resuelto la misma tarea mientras se estaba editando.

1. El sistema detecta que la tarea ha cambiado desde que se abrió.
2. Avisa del conflicto, muestra el estado actual y no sobrescribe el cambio ajeno.
3. El Operador revisa la tarea y repite la modificación si sigue siendo necesaria.

**Resultado:** No se pierde ningún cambio; la tarea conserva la versión más reciente.

---

### 6. Postcondiciones

- POST-1. La tarea queda creada, modificada o resuelta de acuerdo con la operación realizada.
- POST-2. Las tareas permanecen asociadas al cliente y se muestran al responsable vigente.

---

## CU-05 — Gestionar baja y pausa de suscripción

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-05 |
| **Nombre** | Gestionar baja y pausa de suscripción |
| **Objetivo** | Registrar y gestionar una baja comercial o una pausa de suscripción, distinguiendo sus consecuencias en la facturación futura y en la deuda ya existente. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: Planificador del sistema (aviso de fecha prevista de reactivación). |

---

### 2. Precondiciones

- PRE-1. El Operador ha iniciado sesión y solicita gestionar una suscripción; el permiso concreto se verifica al tramitar el cambio.
- PRE-2. El cliente cuenta con una relación comercial o suscripción registrada.

---

### 3. Flujo principal

1. **Actor:** El Operador abre la suscripción y selecciona registrar su baja.
2. **Sistema:** El sistema muestra el estado comercial, la fecha de efecto y las facturas pendientes del cliente.
3. **Actor:** El Operador introduce o confirma la fecha efectiva de la baja y revisa sus consecuencias.
4. **Sistema:** El sistema comprueba la autorización y muestra que desde dicha fecha no se generarán nuevas mensualidades, aunque continuará el seguimiento de facturas anteriores pendientes.
5. **Actor:** El Operador confirma la baja.
6. **Sistema:** El sistema registra el nuevo estado y la fecha efectiva sin borrar la ficha ni los documentos históricos.
7. **Sistema:** El sistema informa del resultado y mantiene las facturas impagadas en el flujo de recobro correspondiente.

---

### 4. Flujos alternativos

#### FA-1 — Pausar temporalmente la suscripción

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita una pausa temporal en vez de una baja definitiva.

1. En el paso inicial el Operador elige pausar, en lugar de dar de baja.
2. Introduce motivo y fecha de inicio, y la fecha prevista de reactivación si se conoce.
3. El sistema registra la pausa, impide generar mensualidades durante su vigencia y mantiene al cliente y sus facturas previas.
4. Si existe fecha prevista, el Planificador del sistema avisa al responsable cuando llega para que revise la reactivación.

**Continuación:** Finaliza con la suscripción pausada y la fecha de revisión o aviso registrada, si se conoce.

#### FA-2 — Registrar la reactivación

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita reactivar una suscripción pausada o dada de baja.

1. El Operador consulta una suscripción pausada o previamente dada de baja, cuando procede volver a activar la relación comercial.
2. El sistema muestra su estado previo y solicita los datos o condiciones que deban confirmarse.
3. Al confirmarse la operación autorizada, el sistema registra el cambio de estado sin crear una ficha duplicada ni alterar facturas anteriores.

**Continuación:** Finaliza con el estado actualizado y el histórico conservado.

#### FA-3 — Baja con deuda pendiente

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El cliente tiene facturas anteriores pendientes de cobro cuando se tramita la baja.

1. Al consultar el cliente, el sistema detecta facturas vencidas o pendientes de cobro.
2. El Operador comprueba el detalle y continúa con la baja si corresponde.
3. La baja detiene la recurrencia futura, pero conserva las obligaciones pendientes y sus avisos de recobro.

**Continuación:** Retoma el paso 3; la baja continúa y la deuda anterior conserva su seguimiento.

---

### 5. Flujos de excepción

#### FE-1 — Fecha o estado incompatible

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La fecha o el estado de la suscripción es incompatible con la transición.

1. La fecha introducida o el estado actual impide aplicar la transición solicitada.
2. El sistema informa del dato o transición incorrectos y no modifica la suscripción.
3. El Operador revisa la fecha y la operación.

**Resultado:** La suscripción conserva el estado anterior hasta corregir la solicitud.

#### FE-2 — Ausencia de permiso para la modificación

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El usuario no tiene permiso para ejecutar la operación solicitada.

1. El usuario carece de autorización sobre el cliente o la acción económica solicitada.
2. El sistema bloquea la actualización y deja constancia del intento cuando proceda.
3. La suscripción conserva su estado anterior.

**Resultado:** La modificación queda rechazada sin alterar la baja, pausa ni deuda previa.

#### FE-3 — Suscripción ya dada de baja o pausada

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La suscripción ya se encuentra en el estado que se pretende registrar.

1. El sistema detecta que el cliente ya está dado de baja o que la suscripción ya está pausada.
2. Impide repetir la operación e informa del estado actual.
3. El Operador puede elegir otra operación, como la reactivación (FA-2).

**Resultado:** La suscripción conserva su estado actual.

---

### 6. Postcondiciones

- POST-1. La suscripción queda de baja, pausada o reactivada según la acción confirmada.
- POST-2. Las nuevas mensualidades se generan o suspenden según el estado y la fecha efectivos.
- POST-3. Las facturas históricas y el flujo de recobro correspondiente permanecen íntegros.

---

## CU-06 — Revisar y aprobar rango de tarifa anual

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-06 |
| **Nombre** | Revisar y aprobar rango de tarifa anual |
| **Objetivo** | Revisar la facturación anual verificada de un cliente, determinar el rango de tarifa aplicable y aprobar expresamente cualquier cambio para periodos futuros. |
| **Actores participantes** | Principal: Administrador. |

---

### 2. Precondiciones

- PRE-1. El Administrador ha iniciado sesión y tiene permiso para revisar tarifas del cliente.
- PRE-2. El cliente tiene una suscripción y existe una tabla de rangos de tarifa vigente.

---

### 3. Flujo principal

1. **Actor:** El Administrador accede a la revisión anual del cliente.
2. **Sistema:** El sistema muestra la tarifa actual, el rango vigente y la información disponible de la revisión.
3. **Actor:** El Administrador introduce o confirma la facturación anual verificada del cliente.
4. **Sistema:** El sistema calcula qué rango de la tabla configurada corresponde a ese importe y propone la nueva tarifa.
5. **Sistema:** El sistema presenta la comparación entre precio anterior y propuesto para su revisión humana.
6. **Actor:** El Administrador comprueba el resultado y aprueba el cambio de rango, sin aplicar retroactivamente la nueva tarifa.
7. **Sistema:** El sistema registra la aprobación, la identidad del aprobador, la fecha y los importes anterior y nuevo.
8. **Sistema:** El sistema actualiza la tarifa aplicable a las revisiones futuras y muestra el resultado.

---

### 4. Flujos alternativos

#### FA-1 — El rango no cambia

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La cifra anual verificada corresponde al mismo rango vigente.

1. El cálculo determina que el cliente permanece en el mismo rango de tarifa.
2. El Administrador comprueba la revisión y confirma que no corresponde cambio económico.
3. El sistema registra la revisión sin cambiar el precio vigente.

**Continuación:** Finaliza con la revisión registrada y sin cambio de precio.

#### FA-2 — Revisión pendiente o rechazada

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El dato anual aún no está verificado o el Administrador rechaza la propuesta.

1. El Administrador no dispone todavía de una cifra anual verificada o no acepta el rango propuesto.
2. El sistema conserva la revisión como pendiente o registra su rechazo con la información aportada.
3. La tarifa aplicable no cambia hasta una aprobación válida.

**Continuación:** Finaliza dejando la revisión pendiente o rechazada y conservando la tarifa anterior.

#### FA-3 — Rectificación de la información de revisión

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Antes de aprobar se descubre un error en la cifra anual de la revisión.

1. Antes de aprobar, el Administrador corrige un importe anual que había introducido de forma equivocada.
2. El sistema recalcula la propuesta y vuelve a mostrar la comparación.
3. El Administrador decide sobre la nueva propuesta; el sistema conserva la trazabilidad del cambio relevante.

**Continuación:** Retoma el paso 4 para recalcular y presentar otra vez la propuesta.

---

### 5. Flujos de excepción

#### FE-1 — Importe anual inválido o tabla sin coincidencia

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La facturación anual no es válida o no existe un rango correspondiente.

1. El dato introducido es inválido o ningún rango configurado permite proponer una tarifa.
2. El sistema señala el problema y no aplica un cambio económico.
3. El Administrador corrige el dato o solicita revisar la tabla mediante la función autorizada.

**Resultado:** No se altera la tarifa; se solicita corregir el valor o la configuración por la vía autorizada.

#### FE-2 — Intento de aprobación no autorizado

**Se produce en:** paso 6 del flujo principal.  
**Condición:** La persona que intenta aprobar incumple permisos o separación de funciones.

1. La operación requiere una aprobación humana distinta o un permiso que el actor no posee.
2. El sistema impide efectuar el cambio y explica el motivo.
3. La revisión queda pendiente de una persona autorizada.

**Resultado:** La propuesta continúa sin aplicar y debe resolverla un aprobador habilitado.

---

### 6. Postcondiciones

- POST-1. La revisión anual queda registrada como aprobada, rechazada o pendiente según el flujo realizado.
- POST-2. Un cambio aprobado incorpora quién, cuándo, tarifa anterior y nueva.
- POST-3. Las facturas históricas no se reescriben por revisar la tarifa.

---

## CU-07 — Solicitar descuento

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-07 |
| **Nombre** | Solicitar descuento |
| **Objetivo** | Preparar una solicitud de descuento o excepción económica sobre un cliente sin aplicarla hasta que se conceda la aprobación requerida. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: Ninguno en el diagrama; la aprobación posterior se tramita mediante CU-08 y, si procede, CU-09. |

---

### 2. Precondiciones

- PRE-1. El Operador está autenticado y se dispone a proponer un descuento sobre un cliente; el acceso se comprueba durante el flujo.
- PRE-2. El cliente tiene una relación comercial sobre la que puede proponerse el descuento.

---

### 3. Flujo principal

1. **Actor:** El Operador abre la información comercial del cliente y selecciona solicitar descuento.
2. **Sistema:** El sistema muestra la tarifa o los importes vigentes y los datos que debe contener la propuesta.
3. **Actor:** El Operador indica el descuento solicitado, su justificación y, cuando proceda, el periodo de aplicación.
4. **Sistema:** El sistema valida los datos y comprueba si la solicitud necesita revisión de Administrador o escalado por umbral.
5. **Sistema:** El sistema muestra al Operador la propuesta y que todavía no tiene efecto económico.
6. **Actor:** El Operador confirma el envío de la solicitud.
7. **Sistema:** El sistema registra la solicitud como pendiente de aprobación e informa del motivo de su retención.
8. **Sistema:** El sistema pone la solicitud a disposición de la revisión administrativa correspondiente.

---

### 4. Flujos alternativos

#### FA-1 — Completar o modificar la propuesta antes de enviarla

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Operador decide corregir importe, duración o justificación antes de presentar la solicitud.

1. El Operador revisa el importe o las condiciones antes de confirmar.
2. El sistema actualiza la previsualización y vuelve a evaluar las reglas de aprobación.
3. El Operador confirma la versión corregida.

**Continuación:** Retoma el paso 4 para validar la versión revisada y continúa en el paso 6.

#### FA-2 — Consultar el estado de una solicitud

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se decide consultar una solicitud ya registrada, en lugar de presentar una nueva.

1. El Operador accede a una solicitud previamente registrada.
2. El sistema muestra si está pendiente, aprobada o rechazada y, cuando exista, el comentario de la decisión.
3. No permite aplicar por cuenta propia un descuento que siga pendiente o haya sido rechazado.

**Continuación:** Finaliza con el estado de la solicitud consultado; no aplica descuentos.

#### FA-3 — Descuento por encima del umbral

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El descuento solicitado supera el umbral configurable.

1. El sistema indica que, además de la revisión del Administrador, la solicitud requerirá la aprobación del Superadministrador.
2. Registra esa necesidad junto con la solicitud.
3. El Operador revisa la información y continúa.

**Continuación:** Retoma el paso 5 del flujo principal.

#### FA-4 — Cancelar una solicitud pendiente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Operador quiere retirar una solicitud que todavía no ha sido resuelta.

1. El Operador selecciona una solicitud pendiente y la cancela.
2. El sistema la marca como cancelada y registra quién y cuándo.
3. La solicitud deja de aparecer en la bandeja de aprobaciones.

**Continuación:** Finaliza con la solicitud cancelada y sin efecto económico.

---

### 5. Flujos de excepción

#### FE-1 — Datos o justificación insuficientes

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El descuento carece de valores o justificación necesarios.

1. El sistema detecta un valor de descuento inválido o una solicitud incompleta.
2. Indica el dato que debe corregirse y no registra una petición efectiva.
3. El Operador corrige la propuesta y vuelve a revisarla.

**Resultado:** No se registra una solicitud efectiva; puede corregirse y volver al paso 4.

#### FE-2 — Cliente no autorizado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El cliente está fuera del ámbito del Operador.

1. El Operador intenta solicitar una excepción sobre un cliente fuera de su ámbito.
2. El sistema deniega la operación.
3. No se genera ni aplica ningún descuento.

**Resultado:** Se rechaza la solicitud y no se genera ningún descuento.

---

### 6. Postcondiciones

- POST-1. Existe una solicitud de descuento registrada con su motivo y sus condiciones.
- POST-2. La solicitud permanece pendiente hasta que CU-08 y, en su caso, CU-09 registren la aprobación correspondiente.
- POST-3. La tarifa y las facturas existentes no se alteran por presentar la solicitud.

---

## CU-08 — Aprobar descuento

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-08 |
| **Nombre** | Aprobar descuento |
| **Objetivo** | Revisar y resolver una solicitud de descuento conforme a los permisos, las reglas de aprobación y los umbrales económicos configurados. |
| **Actores participantes** | Principal: Administrador. Otros participantes: Superadministrador si se activa la extensión CU-09. |

---

### 2. Precondiciones

- PRE-1. El Administrador ha iniciado sesión con permiso para resolver solicitudes de descuento.
- PRE-2. Existe una solicitud pendiente creada previamente, por ejemplo mediante CU-07.

---

### 3. Flujo principal

1. **Actor:** El Administrador abre la bandeja de descuentos pendientes.
2. **Sistema:** El sistema muestra la solicitud, el cliente, el descuento propuesto, su justificación y la tarifa vigente.
3. **Actor:** El Administrador revisa la documentación y los efectos económicos.
4. **Sistema:** El sistema comprueba si el Administrador es un aprobador permitido y si el importe se encuentra dentro del umbral de su competencia.
5. **Actor:** El Administrador selecciona aprobar y confirma su decisión para una solicitud que no exige escalado.
6. **Sistema:** El sistema registra la aprobación y su autor, actualiza el estado y aplica el descuento a las condiciones futuras autorizadas.
7. **Sistema:** El sistema comunica la decisión al solicitante y conserva las facturas emitidas sin reescribirlas.

---

### 4. Flujos alternativos

#### FA-1 — Rechazar el descuento

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Administrador decide denegar la solicitud tras revisarla.

1. El Administrador considera que la petición no debe aprobarse.
2. Registra el rechazo y el comentario justificativo.
3. El sistema cierra la solicitud como rechazada y notifica al solicitante, sin aplicar variaciones económicas.

**Continuación:** Finaliza con rechazo motivado, sin aplicar el descuento.

#### FA-2 — Descuento superior al umbral: extensión CU-09

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El sistema comprueba que el descuento supera el umbral de aprobación del Administrador.

1. Al comprobar las reglas, el sistema detecta que el descuento supera el umbral configurable.
2. La solicitud se mantiene pendiente y se activa CU-09 «Escalar aprobación al Superadministrador» después de la revisión administrativa.
3. La decisión de mayor nivel determina si el descuento puede aplicarse; el Administrador no lo aprueba por encima de sus atribuciones.

**Continuación:** Se ejecuta la extensión CU-09; el resultado de la decisión superior determina el estado final de la solicitud.

---

### 5. Flujos de excepción

#### FE-1 — El aprobador coincide con el solicitante en un importe sensible

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador coincide con el solicitante y debe existir separación de funciones.

1. El sistema detecta que la regla de separación de funciones impediría que la misma persona aprobase su solicitud.
2. Bloquea la aprobación y explica el motivo de la retención.
3. La solicitud sigue disponible para otra persona autorizada.

**Resultado:** La solicitud permanece pendiente para otra persona habilitada.

#### FE-2 — Solicitud ya resuelta o no accesible

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La solicitud ya ha sido resuelta o el usuario no puede acceder a ella.

1. La solicitud fue aprobada, rechazada o retirada previamente, o el actor no dispone de acceso.
2. El sistema impide una segunda decisión incompatible.
3. Informa del estado actual y no altera la tarifa.

**Resultado:** No se aplica una segunda decisión; se informa de su estado válido.

---

### 6. Postcondiciones

- POST-1. La solicitud queda aprobada, rechazada o pendiente de escalado, según corresponda.
- POST-2. Se registra quién resolvió la solicitud y qué decisión tomó.
- POST-3. Solo los descuentos debidamente aprobados producen efecto; el histórico emitido permanece intacto.

---

## CU-09 — Escalar aprobación al Superadministrador

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-09 |
| **Nombre** | Escalar aprobación al Superadministrador |
| **Objetivo** | Resolver una solicitud de descuento cuyo importe rebasa el umbral configurable y que requiere la intervención del Superadministrador. |
| **Actores participantes** | Principal: Superadministrador. Otros participantes: Administrador que revisó la solicitud en CU-08. |

---

### 2. Precondiciones

- PRE-1. CU-08 ha detectado que una solicitud pendiente supera el umbral establecido.
- PRE-2. El Superadministrador ha iniciado sesión; su permiso específico y la separación de funciones se verifican antes de aprobar.

---

### 3. Flujo principal

1. **Sistema:** El sistema remite al Superadministrador la solicitud elevada desde CU-08, indicando por qué requiere su intervención.
2. **Actor:** El Superadministrador abre la solicitud y consulta cliente, descuento, justificación, condiciones y revisión previa.
3. **Sistema:** El sistema comprueba que sigue pendiente y que el actor puede autorizarla.
4. **Actor:** El Superadministrador examina los efectos y decide aprobar la propuesta.
5. **Sistema:** El sistema registra su identidad, fecha y decisión de aprobación.
6. **Sistema:** El sistema actualiza el estado y aplica las condiciones aprobadas sin modificar facturas históricas.
7. **Sistema:** El sistema notifica el resultado a las personas implicadas en la solicitud.

---

### 4. Flujos alternativos

#### FA-1 — Rechazar una solicitud escalada

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Superadministrador considera improcedente el descuento escalado.

1. El Superadministrador selecciona rechazar e indica el motivo.
2. El sistema guarda la decisión y deja la solicitud rechazada.
3. Se informa al solicitante y al Administrador, sin aplicar el descuento.

**Continuación:** Finaliza con la solicitud rechazada y la notificación a las personas afectadas.

#### FA-2 — Solicitar una revisión de los datos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Superadministrador necesita datos adicionales para resolver.

1. El Superadministrador encuentra datos insuficientes para decidir.
2. El sistema mantiene la petición pendiente e informa de qué requiere revisión.
3. Tras completar los datos por la vía autorizada, la solicitud podrá revisarse nuevamente.

**Continuación:** Finaliza con la solicitud todavía pendiente hasta completar la información y revisarla de nuevo.

---

### 5. Flujos de excepción

#### FE-1 — Separación de funciones incumplida

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se incumple la separación de funciones para un importe sensible.

1. La persona que intenta aprobar es la misma que solicitó la operación y su importe exige aprobación independiente.
2. El sistema rechaza la aprobación y mantiene pendiente la propuesta.
3. Otro Superadministrador habilitado deberá resolverla cuando proceda.

**Resultado:** No se autoriza el descuento y la propuesta continúa pendiente de otro aprobador.

#### FE-2 — La solicitud no sigue pendiente

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El expediente ya fue resuelto o no requiere este escalado.

1. La solicitud ya fue resuelta o dejó de requerir escalado.
2. El sistema no permite aplicar una segunda decisión y muestra el estado registrado.
3. El proceso termina sin cambios económicos adicionales.

**Resultado:** No se registra una segunda aprobación ni un cambio económico adicional.

---

### 6. Postcondiciones

- POST-1. La solicitud escalada queda aprobada, rechazada o pendiente de información.
- POST-2. Toda decisión se registra y resulta visible para el flujo de aprobación de origen.
- POST-3. El descuento solo produce efecto tras la aprobación que exigen los umbrales configurados.

---

## CU-10 — Gestionar borrador de factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-10 |
| **Nombre** | Gestionar borrador de factura |
| **Objetivo** | Preparar, consultar y modificar una factura no emitida, con sus líneas e importes, antes de someterla a la emisión definitiva. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: Administrador cuando se cambian cuantías reservadas a ese rol. |

---

### 2. Precondiciones

- PRE-1. El Operador ha iniciado sesión y dispone de acceso al cliente al que corresponderá la factura.
- PRE-2. Existen los datos comerciales o fiscales del cliente necesarios para preparar un borrador.

---

### 3. Flujo principal

1. **Actor:** El Operador entra en facturación y selecciona crear un borrador.
2. **Sistema:** El sistema solicita seleccionar el cliente de la factura puntual; las mensualidades recurrentes no pasan por borrador manual porque las genera CU-11.
3. **Actor:** El Operador introduce las líneas: concepto, cantidad, precio unitario, descuento, si existe, e impuesto; también la descripción y las fechas necesarias.
4. **Sistema:** El sistema completa los valores habituales disponibles, como moneda, condiciones de vencimiento y tarifa, y calcula los importes con precisión decimal.
5. **Sistema:** El sistema muestra el borrador para revisión sin asignar todavía una numeración definitiva de factura emitida.
6. **Actor:** El Operador confirma que desea guardar el borrador.
7. **Sistema:** El sistema registra el borrador con estado «borrador» y permite continuar su edición mientras no se haya emitido.
8. **Sistema:** El sistema muestra el resumen guardado; el borrador queda disponible como precondición de la emisión manual (CU-12), sin relación «include» ni «extend» entre ambos casos.

---

### 4. Flujos alternativos

#### FA-1 — Editar un borrador existente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona un borrador previamente creado.

1. El Operador abre un borrador de un cliente autorizado y selecciona editar.
2. El sistema presenta los datos actuales y permite modificar los campos para los que el actor tenga permiso.
3. Tras la validación, guarda los cambios y mantiene el documento en estado de borrador.

**Continuación:** Finaliza con la nueva versión del borrador guardada; aún no se emite.

#### FA-2 — Modificar manualmente una cuantía

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Un Administrador autorizado decide modificar manualmente una cuantía.

1. Un Administrador con permiso modifica el precio, importe o descuento permitido antes de emitir.
2. El sistema recalcula las líneas y el total e identifica las modificaciones que puedan requerir aprobación posterior según FR-13.
3. La cuantía queda guardada en el borrador, pero todavía no se considera una factura emitida.

**Continuación:** Retoma el paso 4 para recalcular el borrador y sigue con su confirmación.

#### FA-3 — Eliminar borrador nunca emitido

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita eliminar un borrador que nunca llegó a emitirse.

1. El usuario autorizado selecciona eliminar un borrador que no tiene emisión definitiva.
2. El sistema advierte sobre la eliminación y solicita confirmación cuando corresponda.
3. Se elimina el borrador conforme a las restricciones aplicables, conservando la trazabilidad que proceda; no se borra ninguna factura emitida.

**Continuación:** Finaliza con el borrador eliminado conforme a las restricciones; no afecta a facturas emitidas.

#### FA-4 — Borrador con cambio sensible

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El borrador incluye un importe modificado manualmente, un descuento extraordinario, un vencimiento fuera de lo habitual o es una factura puntual de importe alto.

1. El sistema marca el borrador e informa de que quedará retenido para aprobación al emitirlo.
2. No impide guardar el borrador.
3. La retención efectiva se decide en la emisión (CU-12).

**Continuación:** Retoma el paso 5 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Datos o líneas incorrectos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Una línea o dato de factura es inválido o incompleto.

1. El sistema localiza una línea con valores no válidos o datos insuficientes.
2. Señala los campos problemáticos y no guarda el cambio solicitado.
3. El Operador corrige los valores y vuelve a confirmar.

**Resultado:** El cambio del borrador no se guarda hasta corregir los campos y revalidar.

#### FE-2 — Intento de modificar una factura emitida

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se intenta editar o borrar una factura que ya está emitida.

1. El registro seleccionado ya ha pasado a estado de factura emitida o está bloqueado por las reglas aplicables.
2. El sistema rechaza la edición o eliminación ordinaria.
3. Informa de que las correcciones posteriores deben seguir CU-14 si corresponden.

**Resultado:** Se bloquea la modificación ordinaria y se remite al procedimiento de CU-14.

#### FE-3 — Modificación simultánea incompatible

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El borrador ha sido modificado simultáneamente desde otra sesión.

1. Dos usuarios intentan conservar versiones diferentes del mismo borrador.
2. El sistema evita sobrescribir silenciosamente los cambios de otro usuario.
3. Muestra el conflicto para que se revise antes de guardar.

**Resultado:** Se impide sobrescribir cambios ajenos sin revisión; la edición queda pendiente.

---

### 6. Postcondiciones

- POST-1. El borrador queda creado, actualizado o eliminado según la acción autorizada.
- POST-2. No se modifica una factura ya emitida ni se consume una nueva numeración definitiva por guardar el borrador.
- POST-3. La emisión posterior queda fuera de este caso de uso y se realiza en CU-12.

---

## CU-11 — Generar facturas recurrentes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-11 |
| **Nombre** | Generar facturas recurrentes |
| **Objetivo** | Ejecutar la facturación mensual de las suscripciones que corresponden al periodo, asegurando que cada factura se emita una sola vez. |
| **Actores participantes** | Principal: Planificador del sistema. Otros participantes: CU-12 interviene mediante «include» y, por su intermediación, CU-18 para el envío. |

---

### 2. Precondiciones

- PRE-1. Ha llegado la fecha programada de facturación mensual o procede recuperar una ejecución interrumpida.
- PRE-2. Existen suscripciones registradas con condiciones comerciales y tarifas verificables.

---

### 3. Flujo principal

1. **Actor (Planificador):** El Planificador del sistema inicia la generación recurrente correspondiente al periodo, normalmente el día 1.
2. **Sistema:** El sistema consulta las suscripciones y determina cuáles están activas y deben facturarse en ese periodo.
3. **Sistema:** Para cada suscripción elegible, verifica las condiciones vigentes: tarifa aprobada, descuentos aplicables, fechas y vencimiento pactado cuando exista.
4. **Sistema:** El sistema calcula las líneas y el importe correspondiente con los impuestos configurados, sin cambiar documentos históricos.
5. **Sistema:** El sistema verifica que esa mensualidad no se haya emitido ya para la misma suscripción y periodo.
6. **Sistema:** El sistema invoca CU-12 «Emitir factura» para cada mensualidad válida, aplicando la emisión sin aprobación adicional cuando coincide con una suscripción aprobada.
7. **Sistema:** El sistema registra cuáles se emitieron, cuáles quedaron pendientes y los errores individuales sin detener innecesariamente la totalidad del proceso.
8. **Sistema:** El sistema cierra o actualiza el estado de la ejecución y deja disponible el resumen para monitorización.

---

### 4. Flujos alternativos

#### FA-1 — Suscripción pausada, de baja o pendiente de activación

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Una suscripción no debe facturarse por estar pausada, de baja o pendiente de activación.

1. Al comprobar la elegibilidad, una suscripción está pausada, tiene baja efectiva o aún no ha llegado su fecha futura de inicio.
2. El sistema no genera una mensualidad durante el periodo en el que no corresponde facturar.
3. Deja constancia del motivo y continúa con las demás suscripciones.

**Continuación:** Omite dicha suscripción y continúa en el paso 2 con las demás; luego cierra la ejecución.

#### FA-2 — Primera mensualidad o prorrateo

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La primera mensualidad necesita prorrateo o tiene una excepción de inicio acordada.

1. Una suscripción comienza en mitad del mes y sus condiciones requieren facturar la parte proporcional.
2. El sistema utiliza la regla de prorrateo documentada y las excepciones comerciales registradas previamente en la ficha.
3. Emite únicamente lo que corresponda al periodo, sin inventar una mensualidad completa adicional.

**Continuación:** Retoma el paso 4 y calcula exclusivamente el importe correspondiente al periodo.

#### FA-3 — Recuperación tras una interrupción

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se reejecuta una generación mensual tras una interrupción o fallo.

1. La tarea se vuelve a ejecutar porque una ejecución previa quedó incompleta.
2. El sistema comprueba qué mensualidades ya tienen factura emitida.
3. Procesa exclusivamente las pendientes; no duplica numeración ni crea dos facturas para la misma obligación.

**Continuación:** Retoma el paso 2 tras identificar el periodo, respetando las facturas ya emitidas.

#### FA-4 — Suscripción con excepción comercial

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La suscripción tiene una excepción comercial registrada en la ficha del cliente.

1. El sistema comprueba si la excepción con efecto económico está aprobada.
2. Si está aprobada, la aplica: con «primer mes gratuito» no cobra la primera mensualidad y con «sin prorrateo» empieza a facturar la mensualidad completa desde el mes siguiente.
3. Si sigue pendiente de aprobación, no la aplica y la señala al responsable del cliente.

**Continuación:** Retoma el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Datos imprescindibles o aprobación pendiente

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Faltan datos fiscales imprescindibles o una condición económica aprobada.

1. Una suscripción carece de información fiscal necesaria o tiene una condición económica que no está aprobada.
2. El sistema deja esa factura sin emitir o retenida según la causa e identifica al cliente afectado.
3. Registra la incidencia para que una persona autorizada la resuelva y continúa con las demás suscripciones.

**Resultado:** La mensualidad afectada no se emite; queda identificada para resolver, sin detener todo el lote.

#### FE-2 — Fallo durante una emisión

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Falla la emisión individual ejecutada mediante CU-12.

1. CU-12 devuelve un error de emisión para un cliente determinado.
2. El sistema registra el error con identificador y estado de la operación, evitando generar un duplicado al reintentar.
3. La ejecución puede continuar con el resto de clientes y recuperar después la emisión pendiente.

**Resultado:** Se registra el fallo, se conservan los éxitos anteriores y el reintento no crea duplicados.

---

### 6. Postcondiciones

- POST-1. Las mensualidades elegibles quedan emitidas exactamente una vez o registradas como pendientes o fallidas.
- POST-2. Queda un resumen de ejecución que permite identificar éxitos y excepciones.
- POST-3. Las suscripciones suspendidas o dadas de baja no generan nuevas mensualidades durante el periodo afectado.

---

## CU-12 — Emitir factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-12 |
| **Nombre** | Emitir factura |
| **Objetivo** | Validar, numerar, generar y conservar una factura definitiva y activar su envío al cliente, garantizando la inmutabilidad e idempotencia de la emisión. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: Planificador del sistema si CU-11 invoca este caso; Proveedor de correo a través de CU-18; Administrador en la extensión CU-13. |

---

### 2. Precondiciones

- PRE-1. El actor autorizado dispone de un borrador no emitido o de los datos de una mensualidad preparados por CU-11.
- PRE-2. Se ha seleccionado el cliente y están disponibles las reglas de impuestos y series aplicables.

---

### 3. Flujo principal

1. **Actor:** El Operador solicita emitir un borrador o CU-11 invoca la emisión automática de una mensualidad.
2. **Sistema:** El sistema valida los datos fiscales, las líneas y los impuestos y comprueba si la operación ya fue emitida anteriormente.
3. **Sistema:** En la emisión manual, el sistema presenta una vista previa con importes, datos fiscales y condiciones de pago.
4. **Actor:** El Operador confirma la emisión manual; para una mensualidad aprobada, el proceso automático utiliza la autorización de la suscripción.
5. **Sistema:** El sistema comprueba si existe alguna condición económica que requiera retener la factura para revisión antes del envío.
6. **Sistema:** El sistema asigna de forma segura el número correlativo único dentro de la serie cuando la factura esté autorizada para su emisión.
7. **Sistema:** El sistema genera el PDF, conserva los datos emitidos y el documento y bloquea su modificación ordinaria.
8. **Sistema:** El sistema invoca CU-18 «Enviar comunicación al cliente» para efectuar el envío automático por el canal que corresponda.
9. **Sistema:** El sistema registra el estado de emisión y el resultado del intento de envío y presenta o devuelve la confirmación de la operación.

---

### 4. Flujos alternativos

#### FA-1 — Factura con cambio sensible: extensión CU-13

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La factura contiene una modificación económica o condición sensible que exige revisión.

1. En la comprobación previa se detecta importe modificado, descuento extraordinario, vencimiento atípico o factura puntual de importe elevado.
2. El sistema registra la causa de la retención y activa CU-13 «Aprobar factura retenida» antes de permitir su envío.
3. Tras la aprobación, continúa la emisión y el envío si aún están pendientes; si se rechaza, mantiene la factura sin enviar para su corrección autorizada.

**Continuación:** Activa CU-13 y solo retoma el paso 6 cuando la operación puede emitirse; si es rechazada, no se completa la emisión.

#### FA-2 — Emisión recurrente desde CU-11

**Se produce en:** paso 1 del flujo principal.  
**Condición:** CU-11 invoca la emisión de una mensualidad exactamente ajustada a condiciones aprobadas.

1. La emisión se ejecuta desde una suscripción cuyas condiciones ya han sido aprobadas y no presentan cambios sensibles.
2. El sistema valida automáticamente los datos, asigna numeración y conserva el PDF sin exigir una aprobación humana por cada mensualidad.
3. El resultado se devuelve a CU-11 y el envío se intenta mediante CU-18.

**Continuación:** Omite la confirmación manual del paso 4 y continúa con la validación y emisión automática.

#### FA-3 — Fallo de envío posterior a la emisión

**Se produce en:** paso 8 del flujo principal.  
**Condición:** CU-18 informa de un fallo de envío posterior a la emisión.

1. CU-18 devuelve un error una vez que la factura ya se ha emitido.
2. El sistema conserva la factura, su número y su PDF, y registra que el envío está pendiente o ha fallado; la factura permanece «emitida» y no pasa a «enviada» hasta que el envío se complete.
3. Un reintento utiliza la misma factura y el mismo número, sin volver a emitirla.

**Continuación:** Retoma el paso 9 registrando el error de entrega, sin modificar la factura ya emitida.

---

### 5. Flujos de excepción

#### FE-1 — Falta un dato fiscal imprescindible

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Falta información fiscal necesaria o existe un dato inválido.

1. La validación detecta un campo fiscal obligatorio ausente o incorrecto.
2. El sistema bloquea la emisión antes de asignar número y especifica qué falta.
3. El actor corrige los datos por la vía autorizada y repite la validación.

**Resultado:** Se bloquea la emisión antes de asignar número y se indican los datos a corregir.

#### FE-2 — Duplicidad o concurrencia durante la emisión

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Dos intentos pretenden emitir la misma obligación o emplear el mismo número.

1. Dos solicitudes intentan emitir la misma obligación o generar numeración simultáneamente.
2. El sistema verifica la operación y la serie y evita duplicar facturas o números.
3. Devuelve la factura ya emitida, o mantiene la operación pendiente de completar, según corresponda.

**Resultado:** Se evita la duplicación y se recupera el resultado válido de la operación ya registrada.

#### FE-3 — No se puede generar o conservar el PDF

**Se produce en:** paso 7 del flujo principal.  
**Condición:** No puede producirse o conservarse el PDF legal de la factura.

1. Se produce un fallo antes de completar la emisión y la conservación del documento.
2. El sistema registra la incidencia e impide confirmar una factura como emitida sin documento válido.
3. Permite recuperar el intento sin crear una segunda factura ni consumir indebidamente numeración.

**Resultado:** No se confirma una nueva emisión incompleta y queda disponible un reintento seguro.

---

### 6. Postcondiciones

- POST-1. Si finaliza correctamente, la factura posee serie y número únicos, importes calculados y PDF conservado.
- POST-2. La factura emitida queda protegida contra cambios ordinarios y su envío se ha intentado mediante CU-18.
- POST-3. Los fallos de envío o validación quedan diferenciados de una emisión correcta y no producen duplicados.
- POST-4. El saldo pendiente del cliente incluye la nueva factura emitida.

---

## CU-13 — Aprobar factura retenida

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-13 |
| **Nombre** | Aprobar factura retenida |
| **Objetivo** | Resolver la revisión humana de una factura que contiene una modificación o excepción económica sensible antes de permitir su envío. |
| **Actores participantes** | Principal: Administrador. Otros participantes: Operador que solicitó la factura; CU-12 es el caso de uso extendido. |

---

### 2. Precondiciones

- PRE-1. CU-12 ha identificado una causa de retención y la factura está pendiente de aprobación.
- PRE-2. El Administrador ha iniciado sesión; sus permisos de aprobación se comprueban al resolver la solicitud.

---

### 3. Flujo principal

1. **Actor:** El Administrador accede a la bandeja de facturas pendientes de aprobación.
2. **Sistema:** El sistema muestra la factura, su cliente, los importes, la condición excepcional detectada y el motivo de la retención.
3. **Actor:** El Administrador consulta el detalle y verifica las condiciones fiscales y económicas propuestas.
4. **Sistema:** El sistema comprueba que la solicitud sigue pendiente y que la persona tiene permiso para decidir.
5. **Actor:** El Administrador selecciona aprobar y confirma su decisión.
6. **Sistema:** El sistema registra quién aprobó y cuándo y deja la factura lista para completar el procedimiento de emisión y envío de CU-12.
7. **Sistema:** El sistema actualiza el estado y comunica al solicitante el resultado de la revisión.

---

### 4. Flujos alternativos

#### FA-1 — Rechazar la factura

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Administrador concluye que la factura retenida no debe aprobarse.

1. El Administrador selecciona rechazar e indica el motivo.
2. El sistema registra el rechazo y mantiene bloqueado el envío de la factura retenida.
3. La factura vuelve a estado «borrador» y el solicitante recibe el resultado para corregirla antes de volver a emitirla.

**Continuación:** Finaliza con la decisión de rechazo y la factura sin enviarse.

#### FA-2 — Aprobación pendiente por falta de información

**Se produce en:** paso 3 del flujo principal.  
**Condición:** No hay información suficiente para decidir todavía.

1. El Administrador necesita aclarar un importe, descuento o vencimiento antes de decidir.
2. El sistema mantiene la retención y registra el motivo por el que no se ha aprobado.
3. Cuando se complete la información, el expediente volverá a estar disponible para su revisión.

**Continuación:** Finaliza con la solicitud pendiente y los datos requeridos identificados.

---

### 5. Flujos de excepción

#### FE-1 — Aprobación incompatible con los permisos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador no tiene permiso o incumple la separación de funciones requerida.

1. El Administrador no tiene la autorización requerida o es el solicitante cuando la separación de funciones lo prohíbe.
2. El sistema bloquea la decisión y muestra el motivo.
3. La factura permanece retenida hasta que intervenga una persona habilitada.

**Resultado:** La factura continúa retenida a la espera de otro aprobador.

#### FE-2 — Factura resuelta por otro usuario

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La factura retenida fue resuelta por otra persona antes de confirmar.

1. La factura ya se aprobó, rechazó o cambió de estado antes de registrar la decisión.
2. El sistema evita registrar otra aprobación contradictoria.
3. Muestra el estado actual y no provoca un envío duplicado.

**Resultado:** No se duplica la decisión y se muestra su estado actualizado.

#### FE-3 — Faltan datos fiscales al retomar la emisión

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Tras la aprobación, la emisión detecta que falta un dato fiscal imprescindible.

1. CU-12 bloquea la emisión antes de asignar número e indica qué falta.
2. La aprobación queda registrada y no es necesario repetirla.
3. Se completan los datos y se reintenta la emisión.

**Resultado:** La factura queda aprobada pero sin emitir hasta completar los datos.

---

### 6. Postcondiciones

- POST-1. La factura queda aprobada, rechazada o todavía retenida según la decisión.
- POST-2. La decisión y su autor se registran de forma trazable.
- POST-3. Únicamente una aprobación válida permite continuar el envío correspondiente desde CU-12.

---

## CU-14 — Rectificar, anular o declarar incobrable una factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-14 |
| **Nombre** | Rectificar, anular o declarar incobrable una factura |
| **Objetivo** | Gestionar las correcciones y decisiones excepcionales sobre una factura emitida sin borrar su histórico ni equiparar anulaciones o deudas incobrables a cobros. |
| **Actores participantes** | Principal: Administrador. Otros participantes: ninguno en el diagrama. La aprobación adicional que exige la regla económica es un flujo interno (FA-3), no un actor ni un caso de uso aparte; quién aprueba queda pendiente (Q-12). |

---

### 2. Precondiciones

- PRE-1. El Administrador está autenticado y tiene permiso administrativo sobre la factura.
- PRE-2. La factura de origen existe y está emitida; se conoce su situación actual.

---

### 3. Flujo principal

1. **Actor:** El Administrador localiza una factura emitida y selecciona la operación excepcional que necesita realizar.
2. **Sistema:** El sistema presenta el documento original, sus importes y estado, y comprueba si la acción es admisible.
3. **Sistema:** Para una rectificación, el sistema propone los datos que se rectificarán y solicita el motivo.
4. **Actor:** El Administrador revisa los cambios y los importes resultantes.
5. **Sistema:** El sistema comprueba los permisos y determina si el importe o la naturaleza de la operación exigen aprobación adicional.
6. **Actor:** El Administrador confirma la rectificación y obtiene, si procede, la aprobación requerida.
7. **Sistema:** El sistema emite o registra la rectificativa conforme al procedimiento aplicable, vinculándola a la factura original sin reescribir su documento.
8. **Sistema:** El sistema actualiza el estado y el saldo correspondiente teniendo en cuenta el documento corrector, y registra la acción realizada.

---

### 4. Flujos alternativos

#### FA-1 — Anular una factura cuando legalmente proceda

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita anular una factura en un supuesto legalmente permitido.

1. El Administrador solicita anular la factura en lugar de rectificarla.
2. El sistema comprueba las condiciones legales y los permisos y requiere motivo y aprobación cuando corresponda.
3. Registra la anulación o el documento que la formalice, mantiene el histórico y no convierte la factura en pagada.

**Continuación:** Finaliza con la anulación registrada y trazable, sin reescribir el documento emitido.

#### FA-2 — Declarar una deuda incobrable o cancelarla administrativamente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita cancelar o declarar incobrable una obligación pendiente.

1. El Administrador selecciona una deuda pendiente y solicita declararla incobrable o cancelarla.
2. El sistema solicita el motivo y somete la decisión a la aprobación administrativa necesaria.
3. Tras su validación, registra la situación especial de la deuda, detiene los recordatorios de impago de esa factura y nunca cambia su estado a «pagada» por ese motivo.

**Continuación:** Finaliza con la deuda en su estado administrativo correcto, nunca como pagada por este motivo.

#### FA-3 — Operación pendiente de aprobación

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La operación supera las reglas económicas que exigen otra aprobación.

1. El importe o la regla sensible exigen que otra persona revise la solicitud.
2. El sistema mantiene la operación sin efecto definitivo e informa del motivo de la espera.
3. La persona autorizada aprueba o rechaza antes de registrar el cambio excepcional.

**Continuación:** Se reanuda en el paso 6 cuando se obtiene la autorización; sin ella la operación continúa pendiente.

---

### 5. Flujos de excepción

#### FE-1 — Operación no permitida para la factura

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El estado de la factura o las reglas aplicables impiden la operación.

1. La factura, su estado o las restricciones legales no permiten la anulación o rectificación propuesta.
2. El sistema bloquea la acción, conserva el original e informa de la causa.
3. Si la factura no llegó a emitirse, el sistema indica que el borrador puede editarse o eliminarse; si lo que no procede es la anulación, ofrece generar una rectificativa.

**Resultado:** La factura original y sus saldos permanecen sin cambios.

#### FE-2 — Falta motivo o aprobación

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Falta el motivo o una aprobación necesaria.

1. Se intenta completar una rectificación o cancelación sin el motivo o la autorización exigidos.
2. El sistema no registra la decisión como definitiva.
3. El Administrador completa la justificación o solicita la aprobación faltante.

**Resultado:** La operación excepcional no se completa y permanece pendiente hasta ser autorizada.

#### FE-3 — Factura ya rectificada o anulada

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La factura ya está en estado «rectificada» o «anulada».

1. El sistema detecta el estado de la factura.
2. Impide repetir la operación e informa del estado y del documento vinculado.
3. El Administrador consulta el documento existente si necesita revisarlo.

**Resultado:** No se genera ningún documento nuevo y la factura conserva su estado.

---

### 6. Postcondiciones

- POST-1. La factura original y su PDF permanecen conservados y vinculados a cualquier rectificativa correspondiente.
- POST-2. Los estados y saldos reflejan la operación excepcional autorizada.
- POST-3. La acción y su motivación quedan auditadas; «incobrable», «anulada» y «rectificada» no equivalen a «pagada».

---

## CU-15 — Buscar y consultar facturas y clientes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-15 |
| **Nombre** | Buscar y consultar facturas y clientes |
| **Objetivo** | Localizar rápidamente las fichas y facturas a las que puede acceder el usuario, consultar sus estados y descargar los documentos correspondientes. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). |

---

### 2. Precondiciones

- PRE-1. El Operador está autenticado y tiene permisos de lectura sobre al menos parte de la información del sistema.
- PRE-2. Existen datos de clientes o facturas que pueden consultarse.

---

### 3. Flujo principal

1. **Actor:** El Operador abre la búsqueda global o el listado autorizado.
2. **Sistema:** El sistema ofrece criterios de consulta, como nombre comercial, razón social, NIF, contacto, correo o número de factura.
3. **Actor:** El Operador escribe un término y aplica filtros disponibles, como empresa, fechas, sector o estado de factura.
4. **Sistema:** El sistema ejecuta la búsqueda respetando las asignaciones y permisos del actor.
5. **Sistema:** El sistema muestra los resultados autorizados y su información básica relevante.
6. **Actor:** El Operador selecciona un cliente o factura para examinar sus datos y estado.
7. **Sistema:** El sistema muestra el detalle permitido y, para las facturas, la opción de descargar el PDF conservado.
8. **Actor:** El Operador consulta el detalle o descarga el documento cuando lo necesita.

---

### 4. Flujos alternativos

#### FA-1 — Guardar y reutilizar filtros

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Operador decide guardar los filtros para consultas posteriores.

1. El Operador configura una combinación de filtros habitual.
2. Selecciona guardar la vista o el filtro para futuras consultas.
3. El sistema conserva esa preferencia y la aplica respetando los permisos vigentes al volver a usarla.

**Continuación:** Retoma el paso 4 o finaliza dejando guardada la vista sin modificar datos de negocio.

#### FA-2 — Descargar el PDF de una factura

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El Operador solicita descargar el documento PDF de una factura autorizada.

1. El Operador abre una factura autorizada y solicita su PDF.
2. El sistema vuelve a comprobar que dispone de permiso para el documento.
3. Facilita la descarga de la versión emitida sin modificar el documento histórico.

**Continuación:** Finaliza con el documento entregado por un acceso autorizado.

#### FA-3 — Resultados sin coincidencias

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No se encuentran registros correspondientes a la consulta.

1. No existe ningún registro accesible que cumpla los términos y filtros introducidos.
2. El sistema informa de que no hay resultados y conserva los criterios introducidos.
3. El Operador ajusta la búsqueda si desea ampliarla.

**Continuación:** Finaliza mostrando un resultado vacío y permitiendo reformular la búsqueda.

#### FA-4 — Acceso desde favoritos o recientes

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Operador abre un cliente o factura desde sus favoritos o elementos recientes.

1. El Operador selecciona el elemento en su lista de favoritos o recientes.
2. El sistema comprueba los permisos igualmente, porque estas listas no son un mecanismo de autorización.
3. Si el acceso está permitido, muestra el detalle.

**Continuación:** Retoma el paso 7 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Acceso denegado a un registro o documento

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Se intenta abrir o descargar un elemento al que no se tiene derecho.

1. El actor intenta abrir mediante enlace una ficha o factura que no está dentro de su ámbito de autorización.
2. El servidor impide la lectura o descarga aunque el actor conozca el identificador.
3. Se informa de que la operación no está permitida.

**Resultado:** Se deniega el acceso y no se entrega información no autorizada.

#### FE-2 — Criterios o documento no disponibles

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Los criterios no son válidos o el documento solicitado no está disponible.

1. La consulta no puede ejecutarse o el archivo PDF solicitado no está accesible por un fallo.
2. El sistema informa del problema sin exponer datos de otras empresas.
3. El usuario puede reintentar la consulta o comunicar la incidencia.

**Resultado:** Se informa del problema; puede corregirse la búsqueda o revisar la disponibilidad.

---

### 6. Postcondiciones

- POST-1. Se obtiene la información y, en su caso, el PDF autorizado sin modificar los datos de negocio.
- POST-2. Los filtros guardados permanecen disponibles para el usuario.
- POST-3. No se revela información de clientes o facturas fuera de los permisos del actor.

---

## CU-16 — Registrar movimiento de cobro

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-16 |
| **Nombre** | Registrar movimiento de cobro |
| **Objetivo** | Recibir y registrar los movimientos procedentes de sistemas externos de pago, evitando eventos duplicados e iniciando su conciliación. |
| **Actores participantes** | Principal: Sistema de pagos (Stripe/Revolut). Otros participantes: Planificador del sistema (consulta programada de pagos); CU-17 mediante «include». |

---

### 2. Precondiciones

- PRE-1. Existe una integración de pagos habilitada, al menos de forma simulada.
- PRE-2. El sistema puede identificar el origen de los eventos y almacenar movimientos para su seguimiento.

---

### 3. Flujo principal

1. **Actor (Sistema de pagos):** El Sistema de pagos comunica un evento que representa un movimiento de cobro.
2. **Sistema:** El sistema de facturación identifica el origen y obtiene los datos disponibles: importe, fecha, moneda, concepto y referencia.
3. **Sistema:** El sistema verifica si el evento o movimiento ya fue procesado previamente.
4. **Sistema:** Si es nuevo, registra el movimiento con su identidad y los datos recibidos.
5. **Sistema:** El sistema invoca CU-17 «Conciliar pagos» para comprobar las posibles correspondencias; si la identificación no es inequívoca, el movimiento pasa a conciliación manual.
6. **Sistema:** Si la coincidencia es clara y la política lo permite, se registra el resultado de la conciliación automática.
7. **Sistema:** El sistema actualiza la situación de la factura según el importe efectivamente asociado y registra el resultado del evento.
8. **Sistema:** El sistema confirma el procesamiento y deja el movimiento trazable para consultas posteriores.

---

### 4. Flujos alternativos

#### FA-1 — Consulta periódica de cobros

**Se produce en:** paso 1 del flujo principal.  
**Condición:** La obtención del movimiento procede de una consulta programada y no de una notificación.

1. El Planificador del sistema solicita a la integración consultar nuevos pagos, en vez de recibir una notificación.
2. Los movimientos obtenidos pasan por la misma comprobación de duplicados y registro.
3. Cada movimiento nuevo se procesa y se somete al intento de conciliación de CU-17.

**Continuación:** Retoma el paso 2 y procesa el movimiento con los mismos controles de duplicidad.

#### FA-2 — Coincidencia dudosa: conciliación manual

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Los datos no permiten determinar de forma segura una factura correspondiente.

1. Al ejecutar CU-17, los datos del movimiento no permiten determinar con claridad una sola factura.
2. El sistema deja el movimiento pendiente de conciliación manual, sin dar por pagada ninguna factura dudosa.
3. El movimiento se asigna al responsable del cliente, aparece en su pantalla de trabajo diario y queda disponible para que lo resuelva en CU-17.

**Continuación:** Finaliza con el movimiento pendiente de conciliación manual en CU-17.

#### FA-3 — Evento duplicado

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El evento ya ha sido registrado y reconocido previamente.

1. La comprobación detecta que el mismo evento ya se registró.
2. El sistema reconoce el duplicado y no suma nuevamente el cobro ni altera dos veces el saldo.
3. Conserva, cuando proceda, constancia técnica del reintento y termina el procesamiento.

**Continuación:** Finaliza sin volver a contabilizar el cobro ni actualizar saldos.

---

### 5. Flujos de excepción

#### FE-1 — Datos de movimiento inválidos

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El movimiento carece de información que permite registrarlo correctamente.

1. El evento carece de información suficiente o contiene un importe no interpretable.
2. El sistema registra el fallo de integración y evita contabilizar un cobro no fiable.
3. El movimiento queda pendiente de revisión o del reenvío correcto, según lo disponible.

**Resultado:** No se contabiliza un cobro inválido; se señala la incidencia de integración.

#### FE-2 — Fallo al registrar el evento

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un error impide conservar de forma consistente un evento nuevo.

1. Se interrumpe el procesamiento por error técnico.
2. El sistema registra el error de forma que pueda reintentarse el evento sin duplicarlo.
3. No da por abonada una factura sin haber registrado correctamente el movimiento.

**Resultado:** El evento queda pendiente o fallido para reintento, sin contabilización doble.

#### FE-3 — Sistema de pagos no disponible

**Se produce en:** paso 1 de FA-1.  
**Condición:** El sistema de pagos no responde o devuelve un error en la consulta periódica.

1. El sistema registra el error de integración, visible en el panel de monitorización.
2. No registra ningún movimiento a partir de esa consulta.
3. Reintenta en la siguiente ejecución programada.

**Resultado:** No se pierden ni se duplican movimientos; la consulta se repite más tarde.

---

### 6. Postcondiciones

- POST-1. Cada movimiento nuevo queda registrado una sola vez con sus datos disponibles.
- POST-2. El movimiento está conciliado cuando existe coincidencia fiable, o queda pendiente de conciliación manual.
- POST-3. Las actualizaciones de deuda y estados se apoyan en movimientos verificables.

---

## CU-17 — Conciliar pagos

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-17 |
| **Nombre** | Conciliar pagos |
| **Objetivo** | Relacionar un movimiento de cobro con la factura correcta, de forma automática cuando sea inequívoco o con intervención humana cuando existan dudas. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: ninguno en el diagrama. El Sistema de pagos no se asocia a este caso: sus movimientos llegan por CU-16, que incluye CU-17 («include») para el intento de conciliación automática. |

---

### 2. Precondiciones

- PRE-1. Existe al menos un movimiento de cobro registrado o recibido desde CU-16.
- PRE-2. Para la intervención manual, el Operador ha iniciado sesión y tiene autorización sobre los datos afectados.

---

### 3. Flujo principal

1. **Actor:** El Operador abre los movimientos de sus clientes pendientes de conciliación o revisa una asociación que necesita atención.
2. **Sistema:** El sistema muestra importe, fecha, moneda, concepto, referencia y posibles facturas relacionadas.
3. **Actor:** El Operador consulta el movimiento y selecciona la factura cuyo cobro puede justificar.
4. **Sistema:** El sistema compara referencias, moneda e importes, y presenta la coincidencia y cualquier diferencia detectada.
5. **Actor:** El Operador confirma la asociación manual cuando la información es suficiente.
6. **Sistema:** El sistema registra la conciliación y quién la ha realizado, conservando el evento original.
7. **Sistema:** El sistema actualiza el importe cobrado y el saldo pendiente de la factura, sin marcarla pagada salvo que esté completamente saldada por cobros válidos.
8. **Sistema:** El sistema comunica el resultado y conserva la trazabilidad necesaria para una posible reversión.

---

### 4. Flujos alternativos

#### FA-1 — Conciliación automática incluida desde CU-16

**Se produce en:** paso 1 del flujo principal.  
**Condición:** CU-16 solicita la comprobación automática de una coincidencia clara.

1. CU-16 invoca la comprobación de conciliación al registrar un movimiento.
2. El sistema busca una factura inequívoca a partir de los datos disponibles y la política aplicable.
3. Si la asociación es clara, registra la conciliación automática y la regla que la justificó; si no lo es, deja el movimiento pendiente de revisión humana.

**Continuación:** Finaliza con la conciliación automática válida o con el movimiento pendiente para intervención humana.

#### FA-2 — Pago parcial o importe superior al debido

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El pago asociado es inferior o superior al importe que queda por saldar.

1. El importe vinculado no salda completamente la factura, o supera el importe pendiente.
2. El sistema conserva la diferencia y la señala para revisión, con el movimiento relacionado.
3. Si el importe es inferior, la factura queda «parcialmente conciliada» con la diferencia pendiente; si es superior, se señala el excedente. En ningún caso se marca como pagada mientras exista una diferencia por revisar.

**Continuación:** Retoma el paso 6 registrando lo cobrado y señalando la diferencia sin dar por pagada la factura incorrectamente.

#### FA-3 — Deshacer una conciliación errónea

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Operador solicita revertir una conciliación anterior errónea.

1. El Operador autorizado selecciona una conciliación incorrecta y solicita revertirla.
2. Indica el motivo y confirma la reversión.
3. El sistema deshace la asociación o sus efectos y conserva el evento, quién o qué regla lo concilió, quién lo revirtió, cuándo y por qué.

**Continuación:** Finaliza con la reversión auditada, el movimiento conservado y el saldo corregido.

#### FA-4 — Un cobro para varias facturas

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El movimiento corresponde a varias facturas del mismo cliente.

1. El Operador reparte el importe del movimiento entre las facturas.
2. El sistema valida que la suma repartida coincide con el importe del movimiento.
3. Registra cada asociación por separado.

**Continuación:** Retoma el paso 6 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Posibles facturas indistinguibles

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Varias facturas podrían coincidir y no existe evidencia suficiente para decidir.

1. Los datos no permiten determinar qué factura corresponde al cobro.
2. El sistema bloquea la asociación automática y presenta la incertidumbre.
3. El Operador deja pendiente el movimiento hasta disponer de pruebas suficientes.

**Resultado:** No se marca ninguna factura como pagada y el movimiento queda pendiente.

#### FE-2 — Asociación incompatible o sin permiso

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El usuario carece de permiso o la asociación contradice las reglas de cobro.

1. La factura pertenece a un ámbito no autorizado, o la información contradice las comprobaciones de conciliación.
2. El sistema rechaza la operación y explica el motivo.
3. No cambia el saldo ni registra una conciliación válida.

**Resultado:** La conciliación se rechaza sin alterar saldos ni borrar el evento original.

#### FE-3 — Movimiento ya conciliado

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El movimiento seleccionado ya está asociado a una factura.

1. El sistema impide asociarlo de nuevo.
2. Muestra la conciliación existente.
3. Si la asociación anterior es errónea, el Operador debe revertirla primero (FA-3).

**Resultado:** No se registra una segunda conciliación del mismo movimiento.

---

### 6. Postcondiciones

- POST-1. El movimiento queda conciliado, pendiente o con su conciliación revertida según el resultado.
- POST-2. El estado de las facturas refleja cobros validados y diferencias pendientes.
- POST-3. Las asociaciones y reversiones conservan su historial y nunca eliminan el evento original.

---

## CU-18 — Enviar comunicación al cliente

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-18 |
| **Nombre** | Enviar comunicación al cliente |
| **Objetivo** | Transmitir la factura o un aviso administrativo al destinatario correspondiente y registrar de forma trazable cada intento y su resultado. |
| **Actores participantes** | Proveedor de correo (email/WhatsApp simulado), actor externo participante en el diagrama; el envío lo inicia CU-12 o CU-20. |

---

### 2. Precondiciones

- PRE-1. CU-12 ha emitido una factura o CU-20 ha determinado que corresponde enviar un recordatorio.
- PRE-2. Se encuentra configurado un canal de comunicación; la existencia y validez del destinatario se comprueban antes de enviar.

---

### 3. Flujo principal

1. **Sistema:** El sistema recibe la solicitud de comunicación desde CU-12 o CU-20.
2. **Sistema:** El sistema identifica el tipo de mensaje: factura, recordatorio previo, vencimiento o impago.
3. **Sistema:** Selecciona la plantilla correspondiente y el idioma establecido para el cliente o contacto.
4. **Sistema:** El sistema incorpora las variables de la comunicación, identifica al destinatario y adjunta el documento cuando se trate de una factura.
5. **Sistema:** El sistema registra el intento y envía la solicitud al Proveedor de correo; para WhatsApp, utiliza el canal simulado solo cuando existe el consentimiento necesario.
6. **Actor (Proveedor de correo):** El Proveedor de correo comunica el resultado técnico disponible del intento.
7. **Sistema:** El sistema conserva canal, destinatario, fecha, intento, plantilla utilizada y resultado comunicado por el proveedor.
8. **Sistema:** El sistema actualiza el estado de envío o notificación de la factura cuando procede y comunica el resultado al caso de uso de origen.

---

### 4. Flujos alternativos

#### FA-1 — Canal complementario WhatsApp simulado

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Se utiliza WhatsApp simulado como canal complementario y el contacto ha consentido ese canal.

1. El sistema determina que está configurado el canal de WhatsApp y existe consentimiento del contacto.
2. Prepara el mensaje correspondiente y lo envía mediante la integración simulada.
3. Registra el resultado y el canal utilizado sin atribuir lectura o recepción que el proveedor no haya confirmado.

**Continuación:** Retoma el paso 6 tras cursar el intento y registra el resultado del canal seleccionado.

#### FA-2 — Reintentar un envío fallido

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita repetir un intento de comunicación ya fallido.

1. Una comunicación anterior quedó fallida o pendiente de envío.
2. El sistema reutiliza la factura y su número, crea un nuevo intento de comunicación y vuelve a enviar al destino autorizado.
3. Guarda la relación entre el intento original y el reintento, sin generar una factura duplicada.

**Continuación:** Retoma el paso 2 manteniendo la factura y la numeración originales.

#### FA-3 — Rebote posterior: extensión CU-19

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El proveedor informa posteriormente de que el correo rebotó.

1. El Proveedor de correo comunica un rebote asociado al envío realizado.
2. El sistema incorpora el resultado y activa CU-19 «Gestionar rebote de correo» bajo la condición reflejada en el UML.
3. La factura no se considera correctamente notificada por un correo rebotado.

**Continuación:** Se activa CU-19 y se registra que ese envío no constituye una notificación correcta.

---

### 5. Flujos de excepción

#### FE-1 — Destinatario inexistente o plantilla incompleta

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No existe destinatario válido o faltan datos de plantilla imprescindibles.

1. No se encuentra un contacto de facturación válido o falta una variable imprescindible para preparar el mensaje.
2. El sistema registra la incidencia y no afirma haber enviado correctamente la comunicación.
3. Notifica al responsable del cliente para que se corrijan los datos o la plantilla.

**Resultado:** Se evita un envío incorrecto; queda registrada la incidencia para corrección y nuevo intento.

#### FE-2 — Fallo del proveedor de comunicaciones

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El proveedor no puede tramitar la comunicación.

1. El proveedor rechaza la solicitud o devuelve un error.
2. El sistema registra el intento fallido, sus datos y la causa disponible; el mensaje queda en la cola de envíos pendientes y el error es visible en el panel de monitorización.
3. Si se trataba de una factura ya emitida, conserva su emisión y permite un reintento posterior con el mismo número.

**Resultado:** El intento se registra como fallido o pendiente sin duplicar la factura emitida.

---

### 6. Postcondiciones

- POST-1. Existe un registro de cada intento con canal, destinatario, fecha, plantilla y resultado.
- POST-2. La comunicación queda enviada, pendiente o fallida según la evidencia disponible.
- POST-3. Un fallo de envío no revierte la emisión de la factura ni modifica su numeración.

---

## CU-19 — Gestionar rebote de correo

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-19 |
| **Nombre** | Gestionar rebote de correo |
| **Objetivo** | Detectar y resolver entregas fallidas de facturas por correo, notificando al responsable y registrando una incidencia para facilitar el reenvío. |
| **Actores participantes** | Principal: Operador (Usuario Operativo), que resuelve el rebote. Otros participantes: Proveedor de correo, que inicia el caso al comunicar el rebote. Relaciones: extiende CU-18 (condición: el correo rebota) e incluye CU-25. |

---

### 2. Precondiciones

- PRE-1. Se ha intentado enviar una factura o comunicación por CU-18.
- PRE-2. El proveedor ha devuelto un rebote identificable y existe un responsable del cliente asociado.

---

### 3. Flujo principal

1. **Actor (Proveedor de correo):** El Proveedor de correo comunica que un mensaje previamente enviado ha rebotado.
2. **Sistema:** El sistema identifica la comunicación, el cliente y la factura afectados.
3. **Sistema:** El sistema registra el rebote y evita marcar la factura como notificada correctamente por ese intento.
4. **Sistema:** El sistema avisa al responsable del cliente y ejecuta CU-25 para registrar una incidencia de entrega con los datos del fallo.
5. **Actor:** El Operador abre la incidencia y revisa el destinatario o la información del rebote.
6. **Actor:** El Operador corrige el contacto de facturación cuando procede y confirma que debe reintentarse el envío.
7. **Sistema:** El sistema tramita el nuevo intento mediante CU-18, conservando separados el envío original y los reintentos.
8. **Sistema:** El sistema actualiza la incidencia y muestra el estado de entrega disponible.

---

### 4. Flujos alternativos

#### FA-1 — Utilizar otro contacto de facturación autorizado

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El cliente dispone de otro contacto de facturación autorizado para un nuevo intento.

1. El contacto original no está disponible y la ficha tiene otro destinatario de facturación válido.
2. El Operador selecciona o corrige el destinatario conforme a la configuración del cliente.
3. El sistema realiza el nuevo intento, registra a quién se dirigió y mantiene el histórico del rebote inicial.

**Continuación:** Retoma el paso 7 utilizando el contacto alternativo.

#### FA-2 — Rebote pendiente de resolver

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El responsable no dispone todavía de un destinatario válido o no puede resolver el rebote.

1. El Operador no dispone todavía de un correo correcto.
2. El sistema mantiene la incidencia abierta y la factura sin constancia de notificación correcta.
3. El seguimiento continúa hasta poder corregir el destinatario y reenviar.

**Continuación:** Finaliza con la incidencia pendiente y sin marcar la factura como notificada.

#### FA-3 — Cerrar la incidencia sin reenviar

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El contacto se resuelve por otra vía y no es necesario reenviar el correo.

1. El Operador cierra la incidencia indicando la resolución en un comentario.
2. El sistema registra el cierre y quién lo realizó.
3. La factura no figura como notificada por correo.

**Continuación:** Finaliza con la incidencia cerrada y su resolución registrada.

---

### 5. Flujos de excepción

#### FE-1 — El rebote no puede asociarse a un envío

**Se produce en:** paso 2 del flujo principal.  
**Condición:** No es posible asociar el rebote a una comunicación registrada.

1. El proveedor devuelve información que no permite identificar con certeza la comunicación afectada.
2. El sistema registra el error sin cambiar arbitrariamente el estado de una factura.
3. Deja la incidencia para comprobación manual cuando disponga de más datos.

**Resultado:** El error se conserva como incidencia de entrega a investigar; no se inventa un destinatario.

#### FE-2 — Nuevo intento de entrega fallido

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El intento de reenvío vuelve a fallar.

1. El reenvío solicitado devuelve otro error o rebote.
2. El sistema guarda el nuevo intento con su resultado y mantiene visible el problema de entrega.
3. El Operador revisa de nuevo los contactos o conserva la incidencia abierta.

**Resultado:** La incidencia sigue abierta y el historial de intentos se conserva.

#### FE-3 — Sin contacto alternativo válido

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El cliente no tiene ningún contacto con un correo válido.

1. El sistema no permite reintentar el envío.
2. La incidencia permanece abierta.
3. El cliente queda señalado como «contacto pendiente de corregir».

**Resultado:** La factura sigue sin notificar y la incidencia continúa abierta.

---

### 6. Postcondiciones

- POST-1. El rebote y sus intentos de solución quedan registrados y ligados a la comunicación original.
- POST-2. Existe una incidencia de entrega asociada, creada mediante CU-25.
- POST-3. La factura solo se presenta como correctamente notificada cuando existe un resultado que lo justifique.

---

## CU-20 — Ejecutar flujo de recordatorios e impago

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-20 |
| **Nombre** | Ejecutar flujo de recordatorios e impago |
| **Objetivo** | Enviar los avisos de cobro que correspondan según las fechas, vencimientos y condiciones pactadas, hasta que el pago se detecte o se suspenda el seguimiento. |
| **Actores participantes** | Principal: Planificador del sistema. Otros participantes: Proveedor de correo mediante CU-18; Operador en la extensión CU-21 cuando suspende recordatorios. |

---

### 2. Precondiciones

- PRE-1. Existen facturas emitidas pendientes de seguimiento y reglas de recordatorio configuradas.
- PRE-2. Ha llegado el momento de comprobar los avisos programados.

---

### 3. Flujo principal

1. **Actor (Planificador):** El Planificador del sistema inicia la revisión de facturas con seguimiento de cobro.
2. **Sistema:** El sistema consulta para cada factura el vencimiento aplicable, dando prioridad al plazo pactado con el cliente sobre el general.
3. **Sistema:** El sistema comprueba el estado de cobro, los avisos previos y si existe suspensión temporal o intervención que impida continuar el envío.
4. **Sistema:** Para las facturas elegibles determina el aviso procedente: previo alrededor del día tres, de vencimiento o de impago tras el plazo aplicable.
5. **Sistema:** El sistema prepara el mensaje y ejecuta CU-18 «Enviar comunicación al cliente».
6. **Sistema:** El sistema registra la fecha y el resultado de cada intento y calcula el siguiente aviso según la cadencia vigente, que por defecto es cada dos días tras el vencimiento.
7. **Sistema:** El sistema continúa el tratamiento de las demás facturas sin interrumpir todo el flujo por una incidencia individual.
8. **Sistema:** Al terminar, conserva los resultados para su seguimiento y monitorización.

---

### 4. Flujos alternativos

#### FA-1 — Factura ya pagada o sin saldo pendiente

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se detecta que la factura está totalmente saldada o no conserva deuda reclamable.

1. Al comprobar el estado de una factura, el sistema identifica un cobro válido que deja saldada la deuda.
2. Omite nuevos avisos de impago para esa factura.
3. Continúa con la siguiente factura del conjunto.

**Continuación:** Omite el aviso para esa factura y continúa revisando las restantes en el paso 2.

#### FA-2 — Seguimiento suspendido: extensión CU-21

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La factura tiene una suspensión temporal de recordatorios tramitada mediante CU-21.

1. La factura tiene una suspensión vigente por disputa o seguimiento pausado.
2. El sistema aplica la decisión registrada en CU-21 y no emite mensajes automáticos durante el periodo de suspensión.
3. Mantiene la deuda pendiente visible y el aviso interno de revisión en la fecha acordada.

**Continuación:** Omite los envíos durante la suspensión y continúa con la siguiente factura.

#### FA-3 — Vencimiento específico del cliente

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El cliente posee un vencimiento específicamente pactado distinto del general.

1. La factura tiene un plazo pactado distinto al vencimiento general.
2. El sistema utiliza ese vencimiento para clasificar la factura y programar el aviso.
3. No envía un aviso de impago antes del vencimiento pactado.

**Continuación:** Retoma el paso 3 utilizando la fecha pactada para calcular los avisos.

#### FA-4 — Factura de un cliente dado de baja

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La factura pendiente pertenece a un cliente cuya baja ya es efectiva.

1. El sistema incluye la factura igualmente en el flujo de avisos.
2. La baja comercial no detiene el recobro de las facturas anteriores.

**Continuación:** Retoma el paso 4 del flujo principal.

#### FA-5 — Factura anulada o declarada incobrable

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La factura ha sido anulada o su deuda declarada incobrable.

1. El sistema excluye la factura del flujo de avisos.
2. No envía recordatorios de impago sobre ella.

**Continuación:** Continúa con la siguiente factura.

---

### 5. Flujos de excepción

#### FE-1 — No se puede enviar un recordatorio

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El envío del aviso falla a través de CU-18.

1. Falta un destinatario válido o CU-18 comunica un fallo del proveedor.
2. El sistema registra el error y el aviso como no enviado correctamente.
3. Notifica al responsable o deja la incidencia disponible sin considerar completado el envío.

**Resultado:** El error queda registrado y las demás facturas pueden continuar procesándose.

#### FE-2 — No puede determinarse el vencimiento

**Se produce en:** paso 2 del flujo principal.  
**Condición:** No existe vencimiento aplicable o los datos para calcularlo son insuficientes.

1. La factura carece de un dato válido para decidir cuándo corresponde avisar.
2. El sistema evita enviar un recordatorio potencialmente erróneo.
3. Registra la incidencia para revisión y continúa con las demás facturas.

**Resultado:** No se envía un aviso de impago indebido; la factura queda para revisión.

#### FE-3 — Ejecución interrumpida

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Una ejecución anterior se interrumpió antes de terminar.

1. El sistema identifica qué avisos llegaron a enviarse.
2. Completa solo los pendientes, sin enviar dos veces el mismo aviso.
3. Registra la interrupción en el panel de monitorización.

**Resultado:** Los avisos pendientes se recuperan sin duplicados.

---

### 6. Postcondiciones

- POST-1. Cada aviso procedente queda registrado con fecha, tipo y resultado de envío.
- POST-2. No se remiten recordatorios automáticos a facturas pagadas o con suspensión vigente.
- POST-3. Los impagos siguen identificados hasta un cobro válido o una intervención autorizada.

---

## CU-21 — Suspender recordatorios de una factura

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-21 |
| **Nombre** | Suspender recordatorios de una factura |
| **Objetivo** | Pausar temporalmente los avisos automáticos de una factura concreta cuando exista una incidencia o disputa, sin eliminar la deuda ni su seguimiento interno. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: ninguno en el diagrama. Relación: extiende CU-20 (condición: una factura concreta está en disputa o con seguimiento pausado); el Planificador solo respeta la suspensión cuando ejecuta CU-20. |

---

### 2. Precondiciones

- PRE-1. El Operador está autenticado y solicita gestionar los recordatorios de una factura; el acceso se comprueba antes de aplicar cambios.
- PRE-2. La factura tiene un flujo de recordatorios activo o potencialmente aplicable.
- PRE-3. La factura está en disputa o su seguimiento debe pausarse (condición de la extensión sobre CU-20).

---

### 3. Flujo principal

1. **Actor:** El Operador abre una factura y consulta su situación de cobro y recordatorios.
2. **Sistema:** El sistema muestra los avisos previstos y permite registrar una pausa de seguimiento.
3. **Actor:** El Operador selecciona suspender recordatorios e indica el motivo y la fecha de revisión.
4. **Sistema:** El sistema valida que la información esté completa y presenta el alcance de la suspensión para esa factura.
5. **Actor:** El Operador confirma la pausa.
6. **Sistema:** El sistema registra la suspensión y su motivo, conserva el saldo pendiente y evita programar envíos automáticos durante su vigencia.
7. **Sistema:** El sistema incorpora la fecha de revisión al seguimiento interno.
8. **Sistema:** El sistema confirma la suspensión y deja el cambio disponible para las próximas ejecuciones de CU-20.

---

### 4. Flujos alternativos

#### FA-1 — Reanudar los recordatorios

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El responsable autorizado solicita terminar una suspensión vigente.

1. El Operador revisa una factura cuyo seguimiento estaba pausado.
2. Una vez resuelta la razón de la pausa, selecciona finalizar la suspensión.
3. El sistema registra la reanudación y permite que CU-20 vuelva a comprobar si corresponden avisos en función del estado de cobro.

**Continuación:** Finaliza con el seguimiento reanudado para futuras ejecuciones de CU-20.

#### FA-2 — Modificar la fecha de revisión

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se modifica la fecha prevista para revisar una suspensión vigente.

1. El Operador accede a una suspensión vigente e introduce una fecha de revisión actualizada con el motivo pertinente.
2. El sistema valida la modificación y la guarda con trazabilidad.
3. Los avisos continúan suspendidos durante el intervalo autorizado, sin alterar el importe debido.

**Continuación:** Finaliza con la nueva fecha registrada y su motivo conservado.

#### FA-3 — Llega la fecha de revisión

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Se alcanza la fecha de revisión de una suspensión vigente.

1. El sistema avisa al responsable del cliente de que debe revisar la factura.
2. La suspensión se mantiene hasta que se reanude (FA-1) o se cambie la fecha de revisión (FA-2).
3. La factura sigue figurando internamente como pendiente de cobro.

**Continuación:** Finaliza con el aviso enviado y la suspensión vigente.

---

### 5. Flujos de excepción

#### FE-1 — Motivo o fecha de revisión ausentes

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Falta el motivo o la fecha obligatoria de revisión.

1. Se intenta confirmar una suspensión sin motivo o sin fecha de revisión.
2. El sistema indica qué falta y no registra una pausa incompleta.
3. El Operador completa los datos antes de confirmar.

**Resultado:** No se activa la suspensión hasta completar los datos y revalidar.

#### FE-2 — Factura sin acceso o estado incompatible

**Se produce en:** paso 1 del flujo principal.  
**Condición:** La factura no es accesible o su estado impide suspender recordatorios.

1. El usuario no puede gestionar la factura o el estado no admite el cambio solicitado.
2. El sistema rechaza la suspensión y explica la causa.
3. La configuración anterior permanece sin cambios.

**Resultado:** No cambia la cadencia ni el estado del seguimiento de cobro.

---

### 6. Postcondiciones

- POST-1. La factura queda con recordatorios suspendidos, reanudados o con fecha de revisión actualizada.
- POST-2. La decisión, el motivo y el seguimiento interno quedan registrados.
- POST-3. La suspensión no transforma una deuda pendiente en pagada ni elimina documentos históricos.

---

## CU-22 — Gestionar plantillas de comunicación

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-22 |
| **Nombre** | Gestionar plantillas de comunicación |
| **Objetivo** | Crear o modificar las plantillas utilizadas para mensajes de facturación, recordatorios e incidencias, con variables y registro de la versión utilizada en cada comunicación. |
| **Actores participantes** | Principal: Administrador. |

---

### 2. Precondiciones

- PRE-1. El Administrador ha iniciado sesión y solicita gestionar las plantillas; la autorización sobre cada edición se valida en el flujo.
- PRE-2. El sistema dispone de los tipos de comunicación admitidos y sus variables disponibles.

---

### 3. Flujo principal

1. **Actor:** El Administrador abre la gestión de plantillas de comunicaciones.
2. **Sistema:** El sistema muestra las plantillas correspondientes a facturas, avisos previos, vencimiento, impago y disputa resuelta, con sus idiomas configurados.
3. **Actor:** El Administrador selecciona una plantilla e introduce o modifica el asunto y el contenido con variables admitidas.
4. **Sistema:** El sistema presenta una previsualización del mensaje aplicando valores de ejemplo o de contexto.
5. **Sistema:** El sistema comprueba la coherencia de las variables y muestra avisos sobre las que no puedan resolverse.
6. **Actor:** El Administrador revisa y confirma los cambios autorizados.
7. **Sistema:** El sistema guarda la plantilla o su nueva versión para los envíos posteriores.
8. **Sistema:** El sistema confirma la operación y mantiene en los registros de comunicación la identificación de las plantillas utilizadas previamente.

---

### 4. Flujos alternativos

#### FA-1 — Gestionar versión para otro idioma

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se crea o actualiza una versión de la plantilla para otro idioma.

1. El Administrador selecciona el idioma de comunicación correspondiente.
2. El sistema muestra la versión de la plantilla para ese idioma o permite configurar su texto.
3. Al guardar, esa versión queda disponible para futuros envíos de clientes o contactos que utilicen el idioma correspondiente.

**Continuación:** Retoma el paso 4 para previsualizar, validar y confirmar esa versión.

#### FA-2 — Advertencia de variable no disponible

**Se produce en:** paso 5 del flujo principal.  
**Condición:** En la vista previa falta una variable dinámica requerida.

1. La previsualización señala una variable que no podrá completarse con la información prevista.
2. El Administrador corrige el texto o revisa la variable antes de confirmar un uso válido.
3. El sistema vuelve a mostrar la previsualización y conserva la información sobre la versión usada en cada envío.

**Continuación:** Retoma el paso 3 si el Administrador decide corregirla; no se guarda una versión inválida.

#### FA-3 — Consultar la versión usada en un envío

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El Administrador necesita saber qué versión de plantilla se utilizó en una comunicación concreta.

1. El Administrador selecciona la plantilla y el envío que quiere revisar.
2. El sistema muestra la versión utilizada en ese envío.

**Continuación:** Finaliza sin modificar ninguna plantilla.

---

### 5. Flujos de excepción

#### FE-1 — Plantilla no autorizada o inexistente

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La plantilla no existe o el Administrador carece de permiso para editarla.

1. El Administrador no tiene permiso para modificar la plantilla o el tipo elegido no está disponible.
2. El sistema rechaza el guardado y mantiene la versión vigente.
3. Informa de la causa para su revisión.

**Resultado:** La plantilla vigente se mantiene sin alteraciones.

#### FE-2 — Error al guardar la nueva versión

**Se produce en:** paso 7 del flujo principal.  
**Condición:** Un error impide guardar la nueva versión.

1. Ocurre un problema técnico durante el registro de la plantilla.
2. El sistema comunica el fallo y no presenta los cambios como publicados.
3. El Administrador podrá revisar o reintentar la operación sin alterar los envíos históricos.

**Resultado:** Permanece disponible la versión anterior y se comunica el fallo.

---

### 6. Postcondiciones

- POST-1. Las plantillas autorizadas quedan actualizadas para nuevas comunicaciones.
- POST-2. Los registros de envíos históricos conservan la referencia a la plantilla empleada.
- POST-3. Las facturas emitidas anteriormente no se reescriben al cambiar una plantilla.

---

## CU-23 — Gestionar notificaciones y canales

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-23 |
| **Nombre** | Gestionar notificaciones y canales |
| **Objetivo** | Consultar y atender notificaciones internas y configurar cómo recibe cada usuario los avisos, diferenciando el estado leído del resuelto. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: Planificador del sistema para notificaciones y resúmenes automáticos. |

---

### 2. Precondiciones

- PRE-1. El usuario tiene una sesión válida y un perfil de notificaciones disponible.
- PRE-2. Existen eventos de negocio que pueden generar avisos al responsable del cliente.

---

### 3. Flujo principal

1. **Actor:** El Operador abre su bandeja de notificaciones.
2. **Sistema:** El sistema muestra los avisos permitidos, relacionados con pagos, vencimientos, incidencias, aprobaciones o tareas, con su estado correspondiente.
3. **Actor:** El Operador selecciona una notificación y consulta su contenido y la referencia al elemento relacionado.
4. **Sistema:** El sistema presenta el detalle autorizado y permite marcar el aviso como leído.
5. **Actor:** Cuando la notificación requiere una actuación, el Operador accede al elemento que debe resolver.
6. **Actor:** Una vez atendido el asunto, el Operador marca el aviso como resuelto si el tipo de notificación lo permite.
7. **Sistema:** El sistema actualiza el estado, manteniendo la diferencia entre leído y resuelto.
8. **Sistema:** El sistema conserva las preferencias de recepción aplicables al usuario.

---

### 4. Flujos alternativos

#### FA-1 — Configurar canales de recepción

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario decide cambiar su modo de recepción de notificaciones.

1. El Operador entra en sus preferencias de notificación.
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

**Continuación:** Retoma el paso 2 y muestra el aviso en la bandeja del destinatario correspondiente.

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
3. El Operador puede reintentar la actualización.

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

1. **Actor:** El Administrador abre la configuración de alertas.
2. **Sistema:** El sistema presenta las reglas disponibles, por ejemplo antigüedad del vencimiento o importe pendiente acumulado.
3. **Actor:** El Administrador elige un tipo de regla y establece los valores de sus parámetros.
4. **Sistema:** El sistema valida que los valores y la condición pertenecen al conjunto de reglas admitido.
5. **Sistema:** El sistema muestra cómo quedará definida la alerta y solicita confirmación.
6. **Actor:** El Administrador confirma la configuración.
7. **Sistema:** El sistema guarda la regla para que se evalúe cuando corresponda.
8. **Sistema:** El sistema muestra la alerta configurada y la deja disponible para su administración futura.

---

### 4. Flujos alternativos

#### FA-1 — Modificar o desactivar una regla existente

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador elige editar o desactivar una regla ya registrada.

1. El Administrador selecciona una alerta previamente configurada.
2. Cambia un umbral permitido o desactiva la regla, según sus permisos.
3. El sistema valida y registra el nuevo estado sin convertirlo en un proceso BPMN abierto.

**Continuación:** Retoma el paso 4 para validar y después guardar el cambio.

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
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: CU-19 invoca este caso mediante «include» cuando un correo rebota. |

---

### 2. Precondiciones

- PRE-1. El Operador está autenticado y puede acceder al cliente o factura de la incidencia.
- PRE-2. Existe una ficha de cliente y, si corresponde, una factura con la que relacionar la incidencia.

---

### 3. Flujo principal

1. **Actor:** El Operador entra en la ficha o factura y selecciona crear incidencia.
2. **Sistema:** El sistema solicita descripción, responsable, estado, prioridad y datos de seguimiento de la incidencia.
3. **Actor:** El Operador introduce los datos y asocia la incidencia con el elemento correspondiente.
4. **Sistema:** El sistema valida la información y el ámbito de permisos.
5. **Actor:** El Operador confirma el registro.
6. **Sistema:** El sistema crea la incidencia, la vincula con el cliente y, cuando proceda, con la factura, y la muestra entre los asuntos pendientes.
7. **Actor:** El Operador puede incorporar comentarios internos y adjuntos permitidos; las menciones a usuarios generan sus notificaciones.
8. **Sistema:** El sistema guarda las actuaciones y muestra el estado actualizado de la incidencia.

---

### 4. Flujos alternativos

#### FA-1 — Incidencia de entrega incluida desde CU-19

**Se produce en:** paso 1 del flujo principal.  
**Condición:** CU-19 requiere crear una incidencia de entrega a partir de un rebote de correo.

1. CU-19 detecta un rebote y solicita registrar una incidencia de entrega.
2. El sistema crea la incidencia con la factura, el destinatario y la información del fallo que conoce.
3. La incidencia queda disponible para que el responsable la consulte y la resuelva desde este caso de uso.

**Continuación:** Retoma el paso 4 con los datos del fallo ya disponibles y registra la incidencia.

#### FA-2 — Añadir comentario con mención

**Se produce en:** paso 7 del flujo principal.  
**Condición:** El Operador menciona a un usuario en un comentario interno.

1. El Operador abre una incidencia o elemento autorizado y escribe un comentario interno.
2. Incluye una mención a otro usuario cuando corresponda.
3. El sistema conserva el comentario sin enviarlo al cliente y genera la notificación interna prevista por FR-36.

**Continuación:** Retoma el paso 8 tras guardar el comentario y generar la notificación de la mención.

#### FA-3 — Actualizar o cerrar una incidencia

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se selecciona una incidencia existente para modificarla o cerrarla.

1. El Operador selecciona una incidencia existente y modifica su estado, prioridad, responsable o información de seguimiento.
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
3. El Operador corrige la información y vuelve a guardarla.

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
| **Actores participantes** | Principal: Operador (Usuario Operativo). |

---

### 2. Precondiciones

- PRE-1. El Operador está autenticado; los datos solicitados y la exportación quedan sujetos a comprobación de permisos.
- PRE-2. Existen datos de facturación para el periodo solicitado.

---

### 3. Flujo principal

1. **Actor:** El Operador entra en el apartado de informes.
2. **Sistema:** El sistema presenta filtros por periodo, cliente, responsable, país, sector, estado de factura, tipo y moneda.
3. **Actor:** El Operador selecciona los filtros y solicita generar el informe.
4. **Sistema:** El sistema valida los criterios y delimita los datos al ámbito autorizado del usuario.
5. **Sistema:** El sistema calcula los resultados y genera una presentación consultable del informe.
6. **Sistema:** El sistema muestra las cifras y el detalle permitido, junto con las opciones de exportación.
7. **Actor:** El Operador selecciona CSV o PDF legible y confirma la exportación.
8. **Sistema:** El sistema crea el archivo autorizado, lo pone a disposición mediante acceso autenticado y registra el informe con su periodo de conservación.

---

### 4. Flujos alternativos

#### FA-1 — Consultar un informe previamente generado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Operador abre un informe conservado, en lugar de crear uno nuevo.

1. El Operador accede a la relación de informes que puede consultar.
2. Selecciona un informe existente dentro de su plazo de conservación.
3. El sistema comprueba de nuevo sus permisos y ofrece el archivo o un enlace autenticado válido.

**Continuación:** Finaliza con el informe accesible según sus permisos actuales.

#### FA-2 — Regenerar un informe expirado o no conservado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Se solicita regenerar un informe cuyo archivo temporal ya no se conserva.

1. El informe generado ya no está almacenado por haberse cumplido el plazo configurable.
2. El sistema comprueba si conserva los datos necesarios y si el Operador mantiene los permisos.
3. Cuando ambas condiciones se cumplen, regenera el informe a partir de los criterios pertinentes.

**Continuación:** Retoma el paso 3 con los filtros autorizados guardados y genera una versión nueva cuando procede.

#### FA-3 — Informe de alcance global para administradores

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un Administrador autorizado requiere datos de facturación global.

1. Un Administrador o Superadministrador autorizado aplica filtros al conjunto global de facturación.
2. El sistema permite los resultados completos propios de sus permisos.
3. La exportación incluye únicamente los datos que puede consultar ese rol.

**Continuación:** Retoma el paso 5 con el ámbito global habilitado para ese usuario.

#### FA-4 — Informe pesado en segundo plano

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El informe requiere un procesamiento largo.

1. El sistema lo genera en segundo plano y el Operador puede seguir trabajando.
2. Muestra su estado: pendiente, procesando o completado con errores.
3. Notifica al Operador cuando está listo; la tarea no depende de que la pestaña siga abierta.

**Continuación:** Retoma el paso 6 del flujo principal cuando el informe está disponible.

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

1. **Actor:** El Administrador abre el dashboard financiero.
2. **Sistema:** El sistema obtiene los importes y estados de facturación y cobro que corresponde mostrar.
3. **Sistema:** El sistema presenta las cifras actuales, entre ellas importes facturados, cobrados, pendientes o vencidos, según los indicadores disponibles.
4. **Actor:** El Administrador selecciona un periodo o filtro de empresa cuando lo necesita.
5. **Sistema:** El sistema recalcula las cifras a partir de los datos incluidos en el filtro, respetando moneda y reglas de suma aplicables.
6. **Actor:** El Administrador selecciona una cifra para consultar qué registros contribuyen a ella.
7. **Sistema:** El sistema muestra el desglose de facturas o cobros que componen el indicador.
8. **Actor:** El Administrador examina los registros y vuelve al resumen cuando termina.

---

### 4. Flujos alternativos

#### FA-1 — Consultar otra métrica o desglosarla

**Se produce en:** paso 6 del flujo principal.  
**Condición:** El Administrador selecciona otra cifra o un desglose distinto del dashboard.

1. El Administrador selecciona un indicador diferente o modifica los filtros.
2. El sistema actualiza tanto el importe agregado como los detalles subyacentes.
3. Las cifras continúan derivándose de los mismos datos que componen el desglose mostrado.

**Continuación:** Retoma el paso 7 para presentar el detalle seleccionado.

#### FA-2 — Presentar cifras de distintas monedas

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La información a representar incluye importes emitidos en distintas monedas.

1. Los registros consultados contienen facturas emitidas en monedas diferentes.
2. El sistema conserva los importes legales en su moneda original y, si aplica conversiones para el informe, utiliza las referencias registradas para reporting.
3. La presentación no modifica ni reescribe los importes originales de ninguna factura.

**Continuación:** Retoma el paso 6 después de aplicar las reglas de reporting y conservar las monedas originales.

#### FA-3 — Comparar con objetivos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador activa la comparación con los objetivos de facturación o cobro.

1. El sistema muestra las cifras reales junto al objetivo vigente para el periodo.
2. La comparación es informativa y no altera ningún dato.

**Continuación:** Retoma el paso 5 del flujo principal.

#### FA-4 — Agrupar por centro de coste

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador quiere ver las cifras por centro de coste o proyecto.

1. El sistema agrupa las cifras por categoría.
2. Cada grupo mantiene el desglose hasta las facturas que lo componen.

**Continuación:** Retoma el paso 6 del flujo principal.

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

1. **Actor:** El Administrador abre la gestión de objetivos y centros de coste.
2. **Sistema:** El sistema muestra los objetivos de facturación vigentes y las categorías o proyectos existentes.
3. **Actor:** El Administrador selecciona establecer o modificar un objetivo de facturación.
4. **Actor:** Introduce el valor y el periodo aplicable y revisa su finalidad exclusivamente informativa.
5. **Sistema:** El sistema valida el dato y presenta la comparación con el objetivo anterior cuando existe.
6. **Actor:** El Administrador confirma la operación.
7. **Sistema:** El sistema conserva quién realizó el cambio, la fecha y los valores anterior y nuevo.
8. **Sistema:** El sistema muestra el objetivo actualizado, que podrá visualizarse en el dashboard sin alterar las facturas.

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
| **Actores participantes** | Principal: Operador (Usuario Operativo). |

---

### 2. Precondiciones

- PRE-1. El Operador ha iniciado sesión y tiene asignaciones y permisos que determinan su ámbito de trabajo.
- PRE-2. El sistema dispone de los estados actuales de facturas, cobros, entregas, aprobaciones y tareas.

---

### 3. Flujo principal

1. **Actor:** El Operador inicia sesión y accede a su pantalla de trabajo diario.
2. **Sistema:** El sistema consulta las facturas próximas a vencer o vencidas que el usuario puede atender.
3. **Sistema:** El sistema reúne pagos pendientes de conciliación, problemas de entrega, solicitudes de aprobación y tareas según sus permisos.
4. **Sistema:** El sistema muestra los asuntos con información suficiente para reconocer su tipo y situación.
5. **Actor:** El Operador identifica una tarea o incidencia que necesita revisar.
6. **Actor:** Selecciona el acceso directo al cliente, factura, pago o asunto correspondiente.
7. **Sistema:** El sistema comprueba la autorización actual y abre el elemento en la función que lo gestiona.
8. **Actor:** El Operador continúa su actuación en el caso de uso correspondiente, sin que la navegación cambie automáticamente el estado del asunto.

---

### 4. Flujos alternativos

#### FA-1 — Vista de un Administrador

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario que consulta la pantalla tiene rol de Administrador y permiso global.

1. Un Administrador abre su pantalla de trabajo diario.
2. El sistema puede incluir asuntos de su ámbito, como aprobaciones pendientes, además de los elementos operativos permitidos.
3. Los accesos directos llevan a la función correspondiente con comprobación de permisos.

**Continuación:** Retoma el paso 2 con la información adicional de su bandeja global.

#### FA-2 — No existen asuntos pendientes

**Se produce en:** paso 4 del flujo principal.  
**Condición:** No existen asuntos que el usuario deba atender.

1. No se encuentra ninguna factura, pago, tarea o incidencia que requiera atención del usuario.
2. El sistema muestra la pantalla sin elementos pendientes y lo indica claramente.
3. El Operador puede continuar consultando otras funciones autorizadas.

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

---

## CU-30 — Iniciar sesión y recuperar contraseña

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-30 |
| **Nombre** | Iniciar sesión y recuperar contraseña |
| **Objetivo** | Permitir el acceso de usuarios internos mediante credenciales corporativas y ofrecer recuperación segura de contraseña cuando sea necesario. |
| **Actores participantes** | Principal: Operador (Usuario Operativo). Otros participantes: Los roles Administrador y Superadministrador heredan este acceso según el UML. |

---

### 2. Precondiciones

- PRE-1. El usuario dispone de una cuenta interna creada o invitada por una persona autorizada.
- PRE-2. El sistema de autenticación se encuentra disponible.

---

### 3. Flujo principal

1. **Actor:** El usuario accede a la pantalla de inicio de sesión.
2. **Sistema:** El sistema solicita correo corporativo y contraseña.
3. **Actor:** El usuario introduce sus credenciales.
4. **Sistema:** El sistema verifica que el correo pertenezca al dominio corporativo autorizado y que la cuenta exista y esté activa.
5. **Sistema:** El sistema comprueba la contraseña y aplica las protecciones de sesión correspondientes.
6. **Sistema:** Si los datos son correctos, establece una sesión segura con los permisos del rol y las asignaciones del usuario.
7. **Sistema:** El sistema abre la pantalla inicial de trabajo permitida para su perfil.
8. **Actor:** El usuario puede utilizar las funciones a las que está autorizado hasta cerrar sesión o hasta que esta caduque.

---

### 4. Flujos alternativos

#### FA-1 — Recuperar contraseña mediante enlace temporal

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario selecciona recuperar su contraseña en lugar de introducirla.

1. En la pantalla de acceso, el usuario selecciona recuperar contraseña e indica su correo corporativo.
2. El sistema envía un enlace temporal de recuperación asociado a la cuenta y responde de la misma forma exista o no la cuenta, sin permitir autorregistro.
3. El usuario utiliza un enlace válido e introduce una nueva contraseña conforme a las reglas aplicables.
4. El sistema actualiza la credencial, invalida el enlace utilizado y las sesiones anteriores, registra el cambio y permite iniciar sesión con la nueva contraseña.

**Continuación:** Finaliza tras establecer una contraseña válida y poder volver al paso 1 para iniciar sesión.

#### FA-2 — Verificación adicional opcional

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El perfil tiene habilitada una comprobación de identidad adicional.

1. Si la cuenta tiene activado un mecanismo de doble factor, el sistema solicita su verificación tras validar las credenciales básicas.
2. El usuario completa correctamente la comprobación.
3. El sistema permite crear la sesión solo después de superar el control requerido.

**Continuación:** Retoma el paso 6 cuando la verificación se ha completado correctamente.

#### FA-3 — Cerrar sesión

**Se produce en:** paso 8 del flujo principal.  
**Condición:** Un usuario con sesión iniciada solicita cerrarla.

1. El usuario selecciona cerrar sesión.
2. El sistema invalida la sesión activa y vuelve a la pantalla de acceso.
3. Las funciones protegidas dejan de estar disponibles sin una nueva autenticación.

**Continuación:** Finaliza con la sesión invalidada y la cuenta sin modificarse.

---

### 5. Flujos de excepción

#### FE-1 — Credenciales incorrectas o dominio no autorizado

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Las credenciales no coinciden o el correo está fuera del dominio autorizado.

1. El sistema detecta un correo de dominio no admitido, una cuenta inexistente o contraseña incorrecta.
2. Rechaza el acceso sin revelar información sensible sobre otras cuentas.
3. El usuario puede volver a introducir sus datos sujeto a los controles frente a intentos repetidos.

**Resultado:** No se inicia sesión; se permite un nuevo intento sujeto a las protecciones del sistema.

#### FE-2 — Cuenta desactivada o sesión caducada

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La cuenta está desactivada o una sesión deja de ser válida.

1. El usuario está desactivado o intenta operar con una sesión inválida o caducada.
2. El sistema deniega el acceso protegido e invalida las sesiones que correspondan.
3. Para continuar, el usuario debe disponer de cuenta activa y autenticarse de nuevo.

**Resultado:** No se permite el acceso con esa sesión.

#### FE-3 — Enlace de recuperación vencido o inválido

**Se produce en:** paso 3 de FA-1.  
**Condición:** El enlace de recuperación no existe, ha caducado o ya se utilizó.

1. El usuario abre un enlace de restablecimiento que ha caducado, ya se utilizó o no es válido.
2. El sistema no cambia la contraseña y muestra que no puede utilizarse el enlace.
3. El usuario puede iniciar una nueva solicitud de recuperación.

**Resultado:** No se cambia la contraseña y debe solicitarse un enlace válido.

#### FE-4 — Demasiados intentos fallidos

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El usuario supera el número de intentos fallidos permitido.

1. El sistema bloquea temporalmente nuevos intentos para esa cuenta.
2. Registra los intentos fallidos.
3. Pasado el tiempo de bloqueo, el usuario puede volver a intentarlo o recuperar la contraseña (FA-1).

**Resultado:** No se inicia sesión durante el bloqueo temporal.

---

### 6. Postcondiciones

- POST-1. El usuario obtiene una sesión con los permisos adecuados o mantiene el acceso denegado según el resultado.
- POST-2. Una contraseña recuperada se actualiza mediante un enlace temporal válido y no mediante autorregistro.
- POST-3. Las sesiones se protegen y pueden cerrarse, caducar o invalidarse al desactivar usuarios.

---

## CU-31 — Gestionar usuarios, roles y asignación de clientes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-31 |
| **Nombre** | Gestionar usuarios, roles y asignación de clientes |
| **Objetivo** | Administrar las cuentas internas, sus roles y las asignaciones de clientes a Operadores, preservando el historial de actuaciones. |
| **Actores participantes** | Principal: Administrador. Otros participantes: Superadministrador cuando ejerce permisos superiores o un Administrador carece del permiso requerido. |

---

### 2. Precondiciones

- PRE-1. El Administrador está autenticado; cada cambio de usuarios, roles o asignaciones requiere validar sus permisos específicos.
- PRE-2. El sistema tiene definidos los tres roles: Operador, Administrador y Superadministrador.

---

### 3. Flujo principal

1. **Actor:** El Administrador autorizado abre la gestión de usuarios.
2. **Sistema:** El sistema muestra las cuentas existentes, su rol, estado y asignaciones permitidas.
3. **Actor:** El Administrador selecciona invitar o crear un usuario.
4. **Actor:** Introduce el correo del dominio autorizado y el rol que se le permitirá asignar.
5. **Sistema:** El sistema comprueba las restricciones de dominio, los permisos de administración y que la cuenta no exista ya de forma incompatible.
6. **Actor:** El Administrador confirma la creación o invitación.
7. **Sistema:** El sistema registra la cuenta o invitación, el rol autorizado y la acción administrativa correspondiente.
8. **Sistema:** El sistema muestra el resultado y permite continuar con la gestión de sus clientes asignados.

---

### 4. Flujos alternativos

#### FA-1 — Asignar o desasignar clientes a un Operador

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Administrador decide asignar o desasignar clientes a un Operador ya creado.

1. El Administrador selecciona un Operador y los clientes que debe gestionar.
2. El sistema verifica que puede realizar esas asignaciones y presenta su situación actual.
3. Tras la confirmación, guarda la nueva asignación; las tareas siguen asociadas a cada cliente y quedan accesibles para el nuevo responsable permitido.

**Continuación:** Finaliza con las asignaciones registradas y las tareas pendientes asociadas al cliente.

#### FA-2 — Modificar rol o permisos autorizados

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se solicita modificar el rol o los permisos de una cuenta existente.

1. El Administrador con permiso selecciona una cuenta y propone un rol distinto o una modificación permitida.
2. El sistema comprueba que la acción entra en su ámbito de administración.
3. Registra el cambio autorizado sin borrar el historial de actuaciones previas.

**Continuación:** Finaliza con los permisos válidos modificados y la actuación auditada.

#### FA-3 — Desactivar una cuenta

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se solicita desactivar una cuenta existente.

1. El Administrador autorizado solicita desactivar un usuario.
2. El sistema muestra las consecuencias sobre su acceso y solicita confirmación.
3. Desactiva la cuenta, invalida las sesiones correspondientes y conserva los registros de operaciones realizadas anteriormente.

**Continuación:** Finaliza con la cuenta desactivada, sesiones invalidadas e historial conservado.

---

### 5. Flujos de excepción

#### FE-1 — Usuario o correo ya existente

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El correo ya está asignado a una cuenta incompatible con el alta pretendida.

1. La creación utiliza un correo que ya identifica una cuenta existente o no cumple el dominio autorizado.
2. El sistema indica la incompatibilidad y no crea una cuenta duplicada.
3. El Administrador revisa el correo o gestiona la cuenta ya existente.

**Resultado:** No se crea una cuenta duplicada y se indica cómo revisar la existente.

#### FE-2 — Permisos insuficientes para gestionar un rol

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Administrador carece de autorización para el rol o cambio solicitado.

1. Un Administrador intenta conceder un rol o cambiar una cuenta sin poseer el permiso necesario.
2. El sistema bloquea la operación y no aumenta sus privilegios.
3. La acción solo podrá realizarla una persona con autorización adecuada.

**Resultado:** No se aplican roles, asignaciones ni desactivaciones fuera de sus permisos.

#### FE-3 — Intento de conceder el rol Superadministrador

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Un Administrador intenta conceder o modificar el rol Superadministrador.

1. El sistema impide la operación para evitar la escalada de privilegios.
2. Informa de que solo un Superadministrador puede gestionar ese rol.

**Resultado:** No se modifica ningún rol.

---

### 6. Postcondiciones

- POST-1. Las cuentas, roles y asignaciones quedan actualizados únicamente conforme a los permisos aplicables.
- POST-2. Las desactivaciones impiden nuevos accesos y conservan el historial de acciones.
- POST-3. Las tareas continúan vinculadas a los clientes, incluso tras reasignarlos.

---

## CU-32 — Ejecutar acción masiva

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-32 |
| **Nombre** | Ejecutar acción masiva |
| **Objetivo** | Aplicar de manera controlada una operación autorizada a varios elementos, mostrando previamente su alcance y registrando resultados y errores. |
| **Actores participantes** | Principal: Administrador. |

---

### 2. Precondiciones

- PRE-1. El Administrador está autenticado y posee permiso para realizar la operación masiva seleccionada.
- PRE-2. Existe un conjunto de elementos sobre el que puede aplicarse dicha operación.

---

### 3. Flujo principal

1. **Actor:** El Administrador accede a una función que admite operación sobre varios elementos.
2. **Sistema:** El sistema permite identificar el conjunto concreto de registros afectados.
3. **Actor:** El Administrador selecciona la acción masiva disponible y los elementos destinatarios.
4. **Sistema:** El sistema comprueba los permisos y las restricciones de cada elemento y calcula cuántos quedarían afectados.
5. **Sistema:** El sistema muestra de manera explícita el número exacto de elementos y el tipo de cambio previsto.
6. **Sistema:** Si la operación es sensible o destructiva, el sistema exige la confirmación y los controles aplicables antes de actuar.
7. **Actor:** El Administrador confirma la operación dentro de sus atribuciones.
8. **Sistema:** El sistema procesa los elementos autorizados y muestra un resumen de acciones completadas, rechazadas y sus motivos.

---

### 4. Flujos alternativos

#### FA-1 — Acción masiva con elementos no válidos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La selección contiene registros no autorizados o incompatibles con la operación.

1. Durante la comprobación se localizan elementos que no admiten la acción o están fuera del ámbito autorizado.
2. El sistema los identifica y permite confirmar únicamente el conjunto aplicable cuando las reglas lo permiten.
3. El resumen final distingue los elementos completados de los rechazados.

**Continuación:** Retoma el paso 5 mostrando el alcance permitido y los elementos rechazados.

#### FA-2 — Operación sensible que requiere control adicional

**Se produce en:** paso 6 del flujo principal.  
**Condición:** La operación tiene impacto económico elevado o carácter sensible.

1. La acción elegida tiene impacto económico sensible o carácter destructivo.
2. El sistema advierte de sus efectos y requiere las autorizaciones o confirmaciones previstas antes de ejecutarla.
3. La ejecución no comienza mientras falten controles obligatorios.

**Continuación:** Retoma el paso 7 solo cuando se completan los controles adicionales.

#### FA-3 — Cancelación antes de confirmar

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Administrador decide no ejecutar la operación tras revisar el alcance.

1. El Administrador revisa el número de elementos y decide no continuar.
2. El sistema cancela la operación antes de aplicar cambios.
3. No se modifican registros.

**Continuación:** Finaliza sin efectuar cambios en los registros seleccionados.

---

### 5. Flujos de excepción

#### FE-1 — Intento de eludir controles económicos

**Se produce en:** paso 6 del flujo principal.  
**Condición:** La operación intenta eludir controles de confirmación o aprobación económica.

1. El actor propone una acción masiva de alto impacto económico sin las salvaguardas requeridas.
2. El sistema impide ejecutar la operación.
3. Informa de que debe seguirse el procedimiento autorizado correspondiente.

**Resultado:** Se bloquea su ejecución y ningún cambio no autorizado se aplica.

#### FE-2 — Fallo parcial durante el procesamiento

**Se produce en:** paso 8 del flujo principal.  
**Condición:** Una parte de los elementos no puede procesarse.

1. Algunos elementos no pueden procesarse aunque otros sí.
2. El sistema registra qué operaciones tuvieron éxito y cuáles fallaron, evitando afirmar que se procesaron todas.
3. El Administrador examina el resultado antes de reintentar únicamente los elementos pendientes.

**Resultado:** Se informa del resultado individual y no se ocultan fallos ni se repiten éxitos.

#### FE-3 — Selección vacía

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La selección no contiene ningún elemento.

1. El sistema indica que no hay elementos sobre los que actuar.
2. No permite continuar.

**Resultado:** No se ejecuta ninguna acción.

---

### 6. Postcondiciones

- POST-1. Se han modificado solo los elementos autorizados y efectivamente procesados.
- POST-2. Existe un resultado visible con cantidad de elementos y éxito o motivo de rechazo cuando corresponda.
- POST-3. Las acciones sensibles cumplen sus controles y no ejecutan modificaciones económicas desprotegidas.

---

## CU-33 — Consultar monitorización y métricas

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-33 |
| **Nombre** | Consultar monitorización y métricas |
| **Objetivo** | Permitir al Administrador supervisar el estado de los procesos automáticos y las métricas agregadas de funcionamiento sin clasificar individualmente a los empleados. |
| **Actores participantes** | Principal: Administrador. Otros participantes: Planificador del sistema (registra resultados de ejecuciones y métricas técnicas). |

---

### 2. Precondiciones

- PRE-1. El Administrador está autenticado; el acceso a monitorización se valida antes de mostrar datos.
- PRE-2. El sistema dispone de los registros actuales o históricos de ejecución que haya podido recopilar.

---

### 3. Flujo principal

1. **Actor:** El Administrador abre el panel de monitorización.
2. **Sistema:** El sistema consulta la última ejecución de la generación de facturas recurrentes.
3. **Sistema:** El sistema reúne el estado de la cola de correos pendientes, los errores de integración recientes y la última copia de seguridad correcta.
4. **Sistema:** El sistema muestra estos indicadores junto con las métricas agregadas permitidas, como tiempos de generación y fallos.
5. **Actor:** El Administrador identifica un proceso o un error que requiere atención.
6. **Actor:** Selecciona el elemento para examinar la información de ejecución disponible.
7. **Sistema:** El sistema presenta datos que permiten distinguir tareas correctas, pendientes y fallidas sin exponer información técnica sensible innecesaria.
8. **Actor:** El Administrador vuelve al resumen o consulta otro indicador para realizar seguimiento.

---

### 4. Flujos alternativos

#### FA-1 — Registro de una nueva ejecución por el Planificador

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El Planificador registra una nueva ejecución de una tarea automática.

1. El Planificador completa o falla una operación automática.
2. El sistema registra el resultado, los errores y las métricas agregadas correspondientes.
3. La siguiente consulta del Administrador refleja el dato actualizado.

**Continuación:** Retoma el paso 3 cuando se refresca el panel con el resultado disponible.

#### FA-2 — Consulta de un fallo reciente

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Administrador selecciona analizar un fallo de integración o tarea.

1. El Administrador selecciona una integración o ejecución que aparece con error.
2. El sistema muestra la fecha, el estado y el identificador de incidencia disponible.
3. La información permite localizar el proceso afectado sin convertir el panel en una clasificación de trabajadores.

**Continuación:** Retoma el paso 6 para consultar los datos de la incidencia.

---

### 5. Flujos de excepción

#### FE-1 — Datos de monitorización no disponibles

**Se produce en:** paso 3 del flujo principal.  
**Condición:** No existen datos actualizados o un origen de monitorización falla.

1. Una fuente técnica no devuelve datos o no ha ejecutado todavía su proceso.
2. El sistema muestra explícitamente que la información no está disponible o está desactualizada.
3. No presenta una ejecución inexistente como correcta.

**Resultado:** Se informa de la falta de disponibilidad y no se muestra un éxito inventado.

#### FE-2 — Acceso sin autorización

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario no puede acceder a la monitorización corporativa.

1. Un usuario sin permisos de administración intenta consultar el panel o sus detalles.
2. El sistema deniega la consulta.
3. No revela registros restringidos de los procesos internos.

**Resultado:** Se deniega el acceso sin revelar información técnica protegida.

---

### 6. Postcondiciones

- POST-1. El Administrador conoce los estados de ejecución y las incidencias técnicas visibles.
- POST-2. La consulta no altera los procesos monitorizados.
- POST-3. Las métricas utilizadas permanecen agregadas y no sirven para identificar ni clasificar empleados.

---

## CU-34 — Consultar registro de auditoría

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-34 |
| **Nombre** | Consultar registro de auditoría |
| **Objetivo** | Permitir al Superadministrador examinar las actuaciones relevantes del sistema mediante un historial de auditoría protegido contra modificaciones. |
| **Actores participantes** | Principal: Superadministrador. |

---

### 2. Precondiciones

- PRE-1. El Superadministrador ha iniciado sesión y posee permiso de consulta de auditoría.
- PRE-2. El sistema dispone de eventos auditados de operaciones relevantes.

---

### 3. Flujo principal

1. **Actor:** El Superadministrador abre el registro de auditoría.
2. **Sistema:** El sistema presenta los eventos disponibles, con la acción realizada, la persona o proceso responsable y su fecha cuando consten.
3. **Actor:** El Superadministrador selecciona criterios de búsqueda o filtrado para localizar actuaciones concretas.
4. **Sistema:** El sistema comprueba el ámbito del permiso y ejecuta la consulta sobre el registro protegido.
5. **Sistema:** El sistema presenta los eventos coincidentes en orden consultable.
6. **Actor:** El Superadministrador selecciona un evento para conocer los detalles auditados disponibles, como operación afectada o valores registrados.
7. **Sistema:** El sistema muestra la información del evento sin habilitar su modificación o eliminación.
8. **Actor:** El Superadministrador finaliza la consulta o ajusta los filtros.

---

### 4. Flujos alternativos

#### FA-1 — Auditar una modificación económica o administrativa

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se buscan cambios económicos o administrativos concretos en el registro.

1. El Superadministrador filtra por una operación relevante, como aprobación de descuento, cambio de vencimiento, reasignación o conciliación.
2. El sistema muestra la sucesión de eventos registrada para esa actuación.
3. La consulta permite identificar el cambio y su responsable sin reescribir eventos previos.

**Continuación:** Retoma el paso 4 aplicando los filtros seleccionados.

#### FA-2 — Consulta sin coincidencias

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La consulta no devuelve eventos de auditoría coincidentes.

1. No hay eventos que cumplan los filtros elegidos.
2. El sistema lo indica sin alterar el registro.
3. El Superadministrador modifica los criterios si desea ampliar la búsqueda.

**Continuación:** Finaliza mostrando una consulta sin resultados, sin modificar el registro.

#### FA-3 — Consultar el historial de una entidad

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El Superadministrador accede al registro desde la ficha de un cliente o una factura.

1. El sistema filtra automáticamente los eventos de esa entidad.
2. Los muestra en orden cronológico.

**Continuación:** Retoma el paso 6 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Intento de modificar el historial

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un usuario intenta modificar o eliminar el historial de auditoría.

1. Se intenta reescribir o eliminar directamente un evento registrado.
2. El sistema rechaza la operación incluso cuando la consulta la realiza un Superadministrador.
3. El historial original permanece íntegro.

**Resultado:** Se rechaza la operación y no se altera el registro.

#### FE-2 — Registro no disponible

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El registro no puede consultarse temporalmente.

1. No puede consultarse temporalmente la fuente de auditoría.
2. El sistema comunica el error sin presentar datos incompletos como definitivos.
3. El Superadministrador podrá repetir la consulta cuando la fuente vuelva a estar disponible.

**Resultado:** Se informa del fallo y no se presentan eventos como si la consulta hubiera sido completa.

---

### 6. Postcondiciones

- POST-1. Se consulta el historial autorizado de eventos y decisiones relevantes.
- POST-2. Ningún evento se modifica ni elimina como resultado de la consulta.
- POST-3. La información auditada permanece protegida y diferenciada de los errores técnicos operativos.

---

## CU-35 — Configurar facturación y tarifas

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-35 |
| **Nombre** | Configurar facturación y tarifas |
| **Objetivo** | Mantener la configuración global necesaria para facturar, incluidas tablas de tarifas, series, impuestos y umbrales de aprobación, sin alterar documentos históricos. |
| **Actores participantes** | Principal: Superadministrador. |

---

### 2. Precondiciones

- PRE-1. El Superadministrador ha iniciado sesión y dispone del permiso de configuración global.
- PRE-2. El sistema tiene habilitadas las opciones de facturación y tarifas que se van a administrar.

---

### 3. Flujo principal

1. **Actor:** El Superadministrador abre la configuración de facturación.
2. **Sistema:** El sistema presenta la tabla de rangos y precios vigentes, las series disponibles, los impuestos configurados y las opciones globales aplicables.
3. **Actor:** El Superadministrador elige modificar los rangos o precios de tarifa para futuras revisiones.
4. **Actor:** Introduce los nuevos valores y revisa desde cuándo deberán utilizarse.
5. **Sistema:** El sistema comprueba la validez de los rangos y muestra el efecto previsto sobre las revisiones futuras.
6. **Actor:** El Superadministrador confirma los cambios.
7. **Sistema:** El sistema guarda la configuración y registra quién la modificó y cuándo.
8. **Sistema:** El sistema muestra la nueva tabla vigente, conservando íntegros los importes y PDF de las facturas previamente emitidas.

---

### 4. Flujos alternativos

#### FA-1 — Configurar series y numeración de facturas

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador decide modificar series y reglas de numeración.

1. El Superadministrador selecciona el apartado de series de facturación.
2. El sistema muestra las series definidas y permite introducir o actualizar los datos de configuración autorizados.
3. Tras validar y confirmar, las nuevas emisiones utilizarán la configuración aplicable, sin reasignar números a facturas históricas.

**Continuación:** Retoma el paso 5 para validar antes de confirmar la configuración.

#### FA-2 — Configurar impuestos y datos fiscales del emisor

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se solicita mantener impuestos o datos fiscales del emisor.

1. El Superadministrador abre la información fiscal de facturación.
2. Configura los impuestos disponibles para las nuevas facturas o los datos fiscales de Turbine que correspondan.
3. El sistema valida los datos y conserva la configuración para nuevas operaciones, sin editar facturas ya emitidas.

**Continuación:** Retoma el paso 5 y valida los nuevos valores antes del guardado.

#### FA-3 — Modificar umbral de aprobación económica

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Se modifica el umbral configurado para aprobaciones económicas sensibles.

1. El Superadministrador selecciona la regla configurable de umbral económico.
2. Introduce el límite que determinará cuándo se requiere su propia aprobación.
3. El sistema valida y guarda el umbral para solicitudes futuras; las decisiones y documentos históricos conservan su trazabilidad.

**Continuación:** Retoma el paso 5 y registra el cambio validado para decisiones futuras.

---

### 5. Flujos de excepción

#### FE-1 — Rangos solapados o configuración incoherente

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Los rangos se solapan, faltan parámetros o la configuración es inconsistente.

1. La propuesta contiene intervalos de tarifa incompatibles o valores inválidos.
2. El sistema impide aplicar la configuración y señala qué debe corregirse.
3. El Superadministrador revisa los rangos antes de confirmar.

**Resultado:** Los valores previos continúan vigentes hasta corregir el error.

#### FE-2 — Configuración que alteraría una factura histórica

**Se produce en:** paso 5 del flujo principal.  
**Condición:** Una modificación pretende reescribir el contenido legal de facturas antiguas.

1. La operación pretende cambiar el número, importe o documento de una factura ya emitida mediante la configuración global.
2. El sistema no permite reescribir ese histórico.
3. El Superadministrador aplica cambios únicamente a nuevas operaciones o utiliza los procedimientos legales pertinentes para corregir documentos.

**Resultado:** Se bloquea el efecto retroactivo y se conservan los documentos históricos.

#### FE-3 — Serie con facturas emitidas

**Se produce en:** paso 2 de FA-1.  
**Condición:** Se intenta eliminar o reiniciar una serie que ya tiene facturas emitidas.

1. El sistema impide la operación para preservar la numeración correlativa.
2. Ofrece crear una serie nueva si se necesita otra numeración.

**Resultado:** La serie y su numeración se conservan.

---

### 6. Postcondiciones

- POST-1. La configuración válida de tarifas, series, impuestos o umbrales queda registrada y disponible para los flujos que la utilizan.
- POST-2. Los cambios de configuración se auditan cuando corresponde.
- POST-3. Las facturas históricas conservan su número, datos legales, importe y PDF originales.

---

## CU-36 — Configurar recordatorios y funciones inteligentes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-36 |
| **Nombre** | Configurar recordatorios y funciones inteligentes |
| **Objetivo** | Administrar las reglas globales de recordatorios de cobro y habilitar o deshabilitar funciones inteligentes opcionales sin comprometer las reglas ni los permisos del sistema. |
| **Actores participantes** | Principal: Superadministrador. |

---

### 2. Precondiciones

- PRE-1. El Superadministrador ha iniciado sesión y puede cambiar parámetros globales.
- PRE-2. El sistema dispone de la configuración de avisos y, si existen, de funciones inteligentes opcionales.

---

### 3. Flujo principal

1. **Actor:** El Superadministrador abre la configuración de automatizaciones y recordatorios.
2. **Sistema:** El sistema muestra los tiempos vigentes de recordatorio previo, vencimiento e impago.
3. **Actor:** El Superadministrador modifica los intervalos permitidos y revisa cómo se utilizarán en futuras ejecuciones.
4. **Sistema:** El sistema valida que los valores sean coherentes con las reglas de vencimiento y aviso.
5. **Actor:** El Superadministrador confirma los cambios.
6. **Sistema:** El sistema registra la nueva cadencia y deja disponible la configuración para CU-20.
7. **Sistema:** El sistema muestra los parámetros finalmente guardados y conserva las reglas pactadas específicamente con cada cliente.
8. **Actor:** El Superadministrador finaliza la configuración.

---

### 4. Flujos alternativos

#### FA-1 — Activar o desactivar una función inteligente opcional

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El Superadministrador selecciona activar o desactivar una función inteligente opcional.

1. El Superadministrador selecciona una funcionalidad inteligente disponible.
2. El sistema muestra que se trata de una opción no esencial para emitir, calcular o seguir facturas.
3. Tras confirmar su activación o desactivación, el sistema registra el cambio; la función nunca puede saltarse permisos y cualquier sugerencia económica que produzca requerirá confirmación humana.

**Continuación:** Finaliza con la disponibilidad de la función actualizada, sin alterar los permisos.

---

### 5. Flujos de excepción

#### FE-1 — Cadencia de aviso no válida

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Los intervalos de recordatorio no son coherentes o válidos.

1. El Superadministrador introduce un intervalo o una configuración incompatible con las reglas admitidas.
2. El sistema señala el error y rechaza la modificación.
3. Los parámetros anteriores siguen vigentes hasta guardar una configuración correcta.

**Resultado:** No se activa la cadencia incorrecta; se mantiene la configuración anterior.

#### FE-2 — Error al guardar la configuración

**Se produce en:** paso 6 del flujo principal.  
**Condición:** Un fallo técnico impide registrar la nueva cadencia o el cambio de una función inteligente.

1. El sistema no puede guardar la configuración confirmada.
2. Comunica el fallo y no presenta los cambios como aplicados.
3. El Superadministrador puede reintentar la operación.

**Resultado:** Se mantiene la configuración anterior y CU-20 sigue usando la cadencia vigente.

---

### 6. Postcondiciones

- POST-1. Los intervalos configurados quedan disponibles para los próximos ciclos de recordatorios autorizados.
- POST-2. Las funciones inteligentes permanecen habilitadas o deshabilitadas según la decisión válida.
- POST-3. El sistema de facturación sigue operando sin IA, y toda acción económica importante requiere confirmación humana.

---

## CU-37 — Consultar datos y operar por API

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-37 |
| **Nombre** | Consultar datos y operar por API |
| **Objetivo** | Permitir que un sistema externo autenticado consulte información autorizada y registre solicitudes controladas mediante la API, aplicando las mismas reglas de negocio que la interfaz. |
| **Actores participantes** | Principal: Sistema externo (consumidor de la API). |

---

### 2. Precondiciones

- PRE-1. Existe una API documentada y accesible al sistema externo.
- PRE-2. El consumidor envía credenciales para autenticarse y solicita una operación sujeta a verificación de permisos.

---

### 3. Flujo principal

1. **Actor (Sistema externo):** El Sistema externo realiza una petición autenticada a un recurso documentado de la API.
2. **Sistema:** El sistema de facturación autentica la petición y verifica los permisos asociados al consumidor.
3. **Sistema:** El sistema determina el tipo de operación solicitada: consulta de clientes, facturas o deuda pendiente, o registro de una solicitud permitida.
4. **Sistema:** El sistema valida los parámetros y vuelve a aplicar las reglas de acceso y de negocio correspondientes.
5. **Sistema:** Para una consulta autorizada, obtiene únicamente los datos que el consumidor puede conocer.
6. **Sistema:** El sistema prepara la respuesta con el resultado y el estado de la operación.
7. **Sistema:** Devuelve la respuesta al Sistema externo sin exponer información de ámbitos no autorizados.
8. **Sistema:** Registra las llamadas o actuaciones relevantes para mantener la trazabilidad exigida.

---

### 4. Flujos alternativos

#### FA-1 — Consultar deuda pendiente de un cliente

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La petición de API solicita consultar la deuda de un cliente autorizado.

1. El Sistema externo envía una consulta autorizada del estado de deuda de un cliente identificado.
2. La API aplica las comprobaciones de identidad y permisos y calcula las obligaciones pendientes disponibles.
3. El sistema responde con los datos mínimos autorizados para esa consulta, sin modificar facturas ni recurrencias.

**Continuación:** Retoma el paso 4 y devuelve solo los importes y datos permitidos.

#### FA-2 — Registrar solicitud controlada de baja

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La petición requiere registrar una solicitud de baja u otra acción controlada permitida.

1. El Sistema externo comunica que un cliente ha solicitado una baja comercial.
2. El sistema valida la solicitud y los permisos y registra la petición para el procedimiento de baja del sistema.
3. La API devuelve el resultado de la recepción; la recurrencia no se borra directamente desde el sistema externo.

**Continuación:** Finaliza con la solicitud registrada conforme a las reglas y sin modificar recurrencias directamente.

---

### 5. Flujos de excepción

#### FE-1 — Fallo de autenticación o autorización

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La credencial del sistema externo no es válida o carece del permiso necesario.

1. El consumidor envía credenciales inválidas o solicita recursos fuera de su ámbito permitido.
2. El sistema rechaza la operación con la respuesta de error correspondiente.
3. No entrega datos privados ni ejecuta modificaciones en la aplicación.

**Resultado:** Se devuelve rechazo de autenticación o autorización sin divulgar datos.

#### FE-2 — Solicitud de acción prohibida

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Se solicita modificar o borrar recurrencias directamente u otra operación prohibida.

1. El consumidor intenta modificar o eliminar directamente recurrencias, o eludir una aprobación exigida.
2. La API aplica las mismas restricciones que la interfaz y deniega la acción.
3. Puede utilizarse únicamente el procedimiento controlado permitido, si existe.

**Resultado:** No se ejecuta el cambio y se devuelve una respuesta de rechazo.

#### FE-3 — Datos inválidos o recurso inexistente

**Se produce en:** paso 4 del flujo principal.  
**Condición:** La petición usa parámetros erróneos o un recurso inexistente.

1. La petición contiene campos incorrectos o hace referencia a un registro que no existe o no es accesible.
2. La API devuelve un error controlado sin ejecutar cambios parciales indebidos.
3. El Sistema externo puede corregir la solicitud y volver a enviarla.

**Resultado:** Se devuelve un error controlado sin crear datos incorrectos.

---

### 6. Postcondiciones

- POST-1. Se ha respondido únicamente con datos autorizados o se ha registrado una solicitud controlada válida.
- POST-2. Las solicitudes rechazadas no alteran las facturas ni las recurrencias.
- POST-3. La API mantiene las reglas de autorización, negocio y trazabilidad de la aplicación.
