# Bloque A. Clientes y contactos

## CU-01 - Gestionar cliente y contactos

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-01 |
| Nombre | Gestionar cliente y contactos |
| Objetivo | Dar de alta y mantener la ficha comercial y fiscal de un cliente y sus contactos, para poder asociarle suscripciones y facturarle. |
| Actores participantes | Usuario operativo |

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso sobre la gestión de clientes.
- PRE-2. Para editar un cliente existente, este debe estar asignado al usuario (o el usuario ser Administrador o superior).

### 3. Flujo principal

1. Actor: El Usuario operativo selecciona "Añadir cliente" en el módulo de clientes.
2. Sistema: El sistema muestra el formulario de alta, autocompletando los campos recurrentes (país, moneda, vencimiento, tarifa) cuando es posible.
3. Actor: El Usuario operativo introduce los datos fiscales (nombre comercial, razón social, NIF o identificador fiscal, domicilio fiscal, país, moneda de trabajo) y la ficha comercial (fecha de inicio, plan o servicio, tarifa acordada, responsable interno, condiciones de pago y, si existe, documento firmado fuera de la plataforma).
4. Sistema: El sistema valida el formato de los datos, comprueba posibles duplicados y, si el alta es a mitad de mes, muestra el cálculo del prorrateo de la primera factura antes de confirmar. En caso de no haber error, se guarda el cliente y sus contactos, se registra el alta y se confirma la operación. El sistema muestra el cliente creado.

### 4. Flujos alternativos

#### FA-1. Editar un cliente existente

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona editar cliente.

1. En el paso 1, el Usuario operativo abre la ficha de un cliente asignado y selecciona "Editar".
2. El sistema muestra los datos actuales modificables.
3. El usuario los modifica y confirma los cambios.
4. El sistema valida y guarda los cambios, y los registra en la línea temporal.

**Resultado:** Cliente existente editado.

#### FA-2. Gestionar contactos

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona gestionar contactos.

1. Desde la ficha, el usuario añade, modifica o marca como inactivo un contacto.
2. El sistema permite que un contacto pertenezca a varios clientes.
3. Al marcar un contacto como inactivo, el sistema conserva su histórico y los destinatarios de las facturas ya enviadas.

**Resultado:** Contactos modificados de los clientes.

#### FA-3. Etiquetar y marcar como favorito

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona "añadir etiqueta" o marcar como favorito.

1. El usuario asigna etiquetas al cliente (por ejemplo: estratégico, beta, partner, riesgo de cobro), además del sector y la ubicación, o lo marca como favorito.
2. El sistema guarda la clasificación. El acceso rápido por favoritos no sustituye la comprobación de permisos.

**Resultado:** Clientes etiquetados y marcados en el sistema.

#### FA-4. Excepción comercial explícita

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario selecciona una excepción comercial.

1. El usuario registra una excepción comercial: primer mes gratuito, inicio futuro u otra excepción.
2. El sistema guarda la excepción de forma explícita en la ficha del cliente. Si tiene efecto económico (primer mes gratuito o facturación sin prorrateo), queda pendiente de aprobación (CU-07 y CU-08) y no se aplica en la facturación hasta ser aprobada.
3. Si es un inicio futuro, el sistema deja al cliente en estado "pendiente de activación": no genera facturas ni recordatorios hasta esa fecha.

**Resultado:** Clientes registrados con excepciones comerciales.

#### FA-5. Datos fiscales aún no disponibles

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El usuario no dispone todavía del identificador fiscal.

1. El sistema permite guardar el cliente, lo marca con "datos fiscales incompletos" e indica qué falta.

**Resultado:** El sistema no podrá emitir facturas hasta que se completen los datos fiscales faltantes.

### 5. Flujos de excepción

#### FE-1. Posible cliente duplicado

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El sistema detecta datos duplicados en la introducción de datos.

1. El sistema avisa al usuario y ofrece abrir la ficha existente, sin fusionar nada, además de modificar la ficha actual para corregir un posible error.

**Resultado:** El usuario decide entre modificar la actual o la existente.

#### FE-2. Datos obligatorios o formato inválido

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El sistema detecta datos malformateados en la introducción de datos.

1. El sistema detecta datos malformateados y señala los campos a corregir.

**Resultado:** El usuario puede corregir los datos antes de completar la ficha.

#### FE-3. Cliente no asignado

**Se produce en:** FA-1 o FA-2.  
**Condición:** El usuario intenta acceder a un cliente que no tiene asignado.

1. En FA-1 o FA-2, el usuario intenta acceder a un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor) e informa de que el cliente no está asignado al usuario.

**Resultado:** Acceso denegado.

### Postcondiciones

- POST-1. El cliente y sus contactos quedan registrados con su responsable interno y su clasificación.
- POST-2. La línea temporal del cliente refleja el alta o la modificación.
- POST-3. El cliente queda "activo" (o "pendiente de activación" si tiene inicio futuro) y es elegible para suscripciones y facturación.
- POST-4. La acción queda registrada en el registro de auditoría.

---

## CU-02 - Detectar cliente duplicado

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-02 |
| Nombre | Detectar cliente duplicado |
| Objetivo | Avisar al usuario cuando un cliente que se va a crear o importar puede ya existir, evitando duplicidades sin fusionar registros automáticamente. |
| Actores participantes | Usuario operativo (a través de CU-01 o CU-03) |

### 2. Precondiciones

- PRE-1. Se está creando o importando un cliente (CU-01 o CU-03).

### 3. Flujo principal

1. Actor: El proceso o Usuario operativo (a través de CU-01 o CU-03) entrega al sistema el identificador fiscal del cliente.
2. Sistema: El sistema normaliza el identificador (mayúsculas, sin espacios ni guiones) y lo compara con los clientes existentes.
3. Sistema: El sistema no encuentra coincidencias y devuelve "sin duplicados" al caso de uso que lo invocó, el cual continúa su flujo.

### 4. Flujos alternativos

#### FA-1. Coincidencia encontrada

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El sistema encuentra uno o varios clientes con el mismo identificador fiscal.

1. En el paso 3, el sistema encuentra uno o varios clientes con el mismo identificador fiscal.
2. El sistema avisa de la posible duplicidad y muestra un enlace a la ficha de cada coincidencia.
3. El usuario decide: cancelar, corregir el identificador o confirmar que es un cliente distinto. El sistema nunca fusiona automáticamente.

**Resultado:** El usuario gestiona la coincidencia sin fusionar registros automáticamente.

#### FA-2. Detección dentro de una importación CSV

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El caso de uso es invocado desde una importación masiva en CSV (CU-03).

1. Cuando lo invoca CU-03, el sistema marca cada fila con posible duplicado en la previsualización.
2. El usuario decide fila a fila si la importa como cliente nuevo, actualiza de forma explícita el cliente existente, la omite o la corrige. El sistema nunca fusiona ni actualiza por su cuenta.

**Resultado:** Detección y decisión manual sobre duplicados fila por fila durante la importación.

### 5. Flujos de excepción

#### FE-1. Cliente sin identificador fiscal

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El cliente no dispone de identificador fiscal (por ejemplo, identificador extranjero aún no disponible).

1. El cliente no tiene identificador fiscal (p. ej. un identificador extranjero aún no disponible).
2. El sistema no puede comprobar duplicados por ese campo y lo indica al usuario.
3. El usuario puede continuar, asumiendo que la comprobación no se ha realizado.

**Resultado:** El usuario continúa el registro con la advertencia de comprobación no realizada.

### Postcondiciones

- POST-1. El usuario conoce las posibles duplicidades antes de guardar.
- POST-2. No se ha fusionado ni modificado ningún cliente existente.

---

## CU-03 - Importar datos por CSV

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-03 |
| Nombre | Importar datos por CSV |
| Objetivo | Cargar de forma masiva clientes (y opcionalmente facturas históricas) desde un archivo CSV, controlando errores antes de confirmar. |
| Actores participantes | Usuario operativo |

### 2. Precondiciones

- PRE-1. El usuario está autenticado y tiene permiso de importación.
- PRE-2. El usuario dispone de un archivo CSV con el formato esperado.

### 3. Flujo principal

1. Actor: El Usuario operativo selecciona "Importar CSV" y sube el archivo.
2. Sistema: El sistema valida la estructura (columnas y codificación) y analiza cada fila.
3. Sistema: El sistema comprueba posibles duplicados por identificador fiscal invocando CU-02.
4. Sistema: El sistema muestra una previsualización con filas válidas, filas con error (y su motivo) y posibles duplicados.
5. Actor: El Usuario operativo corrige los errores o excluye las filas problemáticas.
6. Sistema: El sistema indica el número exacto de registros que se van a crear o actualizar y solicita confirmación.
7. Actor: El Usuario operativo confirma la operación.
8. Sistema: El sistema crea los clientes nuevos y actualiza únicamente aquellos que el usuario marcó explícitamente como actualización de un cliente existente (CU-02, FA-2).
9. Sistema: El sistema muestra un resumen con registros creados, actualizados y rechazados, con sus motivos, y registra la operación.

### 4. Flujos alternativos

#### FA-1. Importar facturas históricas

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario indica que el archivo CSV incluye facturas históricas.

1. En el paso 1, el usuario indica que el archivo incluye facturas históricas.
2. El sistema las importa marcadas como "migradas", con su número y documento original, y sin enviar ninguna notificación al cliente.

**Resultado:** Facturas históricas importadas y marcadas como migradas.

#### FA-2. Cancelar antes de confirmar

**Se produce en:** cualquier momento anterior al paso 7 del flujo principal.  
**Condición:** El usuario decide cancelar el proceso de importación.

1. En cualquier momento anterior al paso 7, el usuario cancela.
2. El sistema descarta la carga sin modificar datos.

**Resultado:** Importación cancelada sin alterar los datos existentes.

#### FA-3. Filas sin identificador fiscal

**Se produce en:** paso 3 del flujo principal.  
**Condición:** Una o varias filas no incluyen identificador fiscal.

1. En el paso 3, una fila no incluye identificador fiscal.
2. El sistema no puede comprobar duplicados en esa fila (CU-02, FE-1), la marca como "datos fiscales incompletos" en la previsualización y permite importarla.
3. Esa fila no podrá facturarse hasta completar los datos.

**Resultado:** Fila importada y marcada con datos fiscales incompletos.

### 5. Flujos de excepción

#### FE-1. Archivo inválido

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El archivo no es un CSV válido o faltan columnas obligatorias.

1. En el paso 2, el archivo no es un CSV válido o faltan columnas obligatorias.
2. El sistema rechaza la carga e indica qué falta.
3. El usuario corrige el archivo y vuelve a subirlo.

**Resultado:** Carga rechazada hasta que se corrija la estructura del archivo.

#### FE-2. Todas las filas rechazadas

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Ninguna fila del archivo resulta válida tras la comprobación.

1. En el paso 4, ninguna fila es válida.
2. El sistema no permite confirmar y muestra los motivos de rechazo.

**Resultado:** Proceso de importación bloqueado hasta corregir los datos.

#### FE-3. Fallo durante la importación

**Se produce en:** paso 8 del flujo principal.  
**Condición:** Se produce un error técnico durante la persistencia de datos.

1. En el paso 8 se produce un error técnico.
2. El sistema revierte la operación completa para no dejar registros a medias, registra el error con identificador y lo muestra al usuario.
3. El usuario puede corregir la causa y volver a lanzar la importación.

**Resultado:** Transacción revertida completamente sin cambios en la base de datos.

### Postcondiciones

- POST-1. Los clientes válidos quedan creados, y los marcados explícitamente como actualización quedan actualizados.
- POST-2. La operación queda registrada en el registro de auditoría con su resumen y el usuario que la realizó.
- POST-3. Las facturas históricas importadas quedan marcadas como migradas y no generan notificaciones.

---

## CU-04 - Gestionar tareas del cliente

### 1. Identificación

| Campo | Contenido |
|---|---|
| Identificador | CU-04 |
| Nombre | Gestionar tareas del cliente |
| Objetivo | Registrar y seguir tareas pendientes asociadas a un cliente, de modo que no se pierdan cuando cambie su responsable. |
| Actores participantes | Usuario operativo |

### 2. Precondiciones

- PRE-1. El usuario está autenticado.
- PRE-2. El cliente está asignado al usuario (o el usuario es Administrador o superior).

### 3. Flujo principal

1. Actor: El Usuario operativo abre la ficha de un cliente asignado y accede a la sección de tareas.
2. Sistema: El sistema muestra las tareas pendientes y completadas del cliente.
3. Actor: El Usuario operativo selecciona "Añadir tarea".
4. Actor: El Usuario operativo introduce la descripción de la tarea y, opcionalmente, una fecha prevista.
5. Sistema: El sistema valida los datos.
6. Sistema: El sistema guarda la tarea asociada al cliente (no al usuario) y la registra en la línea temporal del cliente.
7. Sistema: El sistema muestra la tarea en la ficha y en la pantalla de trabajo diario del responsable interno del cliente.

### 4. Flujos alternativos

#### FA-1. Editar una tarea

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario selecciona una tarea pendiente y elige editarla.

1. En el paso 2, el usuario selecciona una tarea pendiente y la edita.
2. El sistema valida y guarda los cambios, y los registra en la línea temporal.

**Resultado:** Tarea del cliente modificada y cambios registrados.

#### FA-2. Completar una tarea

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario marca una tarea como completada.

1. En el paso 2, el usuario marca una tarea como completada.
2. El sistema la conserva como completada, registrando quién y cuándo, y la retira de la pantalla de trabajo diario.

**Resultado:** Tarea guardada como completada y retirada de la pantalla de trabajo diario.

#### FA-3. Cambio de responsable del cliente

**Se produce en:** cualquier momento de la gestión del cliente.  
**Condición:** Un Administrador reasigna el cliente a un nuevo responsable interno.

1. Un Administrador cambia el responsable interno del cliente.
2. Las tareas pendientes, al estar asociadas al cliente, pasan automáticamente a su nuevo responsable sin intervención del usuario.

**Resultado:** Tareas pendientes reasignadas automáticamente al nuevo responsable.

### 5. Flujos de excepción

#### FE-1. Datos inválidos

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La descripción está vacía o la fecha prevista no es válida.

1. En el paso 5, la descripción está vacía o la fecha prevista no es válida.
2. El sistema no guarda e indica qué campo hay que corregir.
3. El usuario corrige y reenvía.

**Resultado:** El usuario corrige los datos antes de completar la tarea.

#### FE-2. Cliente no asignado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario intenta acceder a las tareas de un cliente que no tiene asignado.

1. El usuario intenta acceder a las tareas de un cliente que no tiene asignado.
2. El sistema rechaza el acceso (el control se realiza en servidor) e informa de la restricción.

**Resultado:** Acceso denegado a las tareas del cliente.

#### FE-3. Tarea modificada por otro usuario

**Se produce en:** FA-1 o FA-2.  
**Condición:** Otro usuario ha modificado o completado la misma tarea de forma concurrente.

1. En FA-1 o FA-2, otro usuario ha modificado o completado la misma tarea mientras tanto.
2. El sistema avisa del conflicto, muestra el estado actual y no sobrescribe el cambio ajeno.

**Resultado:** Se informa del conflicto y se previene la sobrescritura no deseada.

### Postcondiciones

- POST-1. La tarea queda asociada al cliente con su estado (pendiente o completada).
- POST-2. La línea temporal del cliente refleja la creación, edición o cierre de la tarea.
- POST-3. Las tareas pendientes son visibles para el responsable interno actual del cliente.