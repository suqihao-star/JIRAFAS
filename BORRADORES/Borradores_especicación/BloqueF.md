# Bloque F. Administración, seguridad y sistema

## CU-30 — Iniciar sesión y recuperar contraseña

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-30 |
| **Nombre** | Iniciar sesión y recuperar contraseña |
| **Objetivo** | Permitir el acceso seguro a la plataforma con cuenta corporativa y recuperar la contraseña de forma segura. |
| **Actores participantes** | Usuario operativo (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario tiene una cuenta activa creada por invitación (CU-31).

---

### 3. Flujo principal

*Escenario descrito: iniciar sesión.*

1. **Usuario operativo:** Accede a la plataforma e introduce su correo corporativo y su contraseña.
2. **Sistema:** Valida el dominio autorizado, las credenciales y que la cuenta está activa.
3. **Sistema:** Crea una sesión segura.
4. **Sistema:** Muestra la pantalla de trabajo diario (CU-29).

---

### 4. Flujos alternativos

#### FA-1 — Recuperar la contraseña

**Se produce en:** paso 1 del flujo principal.  
**Condición:** El usuario selecciona «He olvidado mi contraseña» e introduce su correo.

1. **Usuario operativo:** Selecciona «He olvidado mi contraseña» e introduce su correo.
2. **Sistema:** Envía un enlace temporal de recuperación, que caduca a la hora de enviarse (A-04), y responde de la misma forma exista o no la cuenta.
3. **Usuario operativo:** Abre el enlace e introduce una nueva contraseña.
4. **Sistema:** Guarda la contraseña, invalida el enlace y las sesiones anteriores, y registra el cambio.

**Continuación:** el caso de uso finaliza y el usuario puede iniciar sesión desde el paso 1 del flujo principal.

#### FA-2 — Doble factor opcional

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario tiene activado el doble factor.

1. **Usuario operativo:** Tiene activado el doble factor.
2. **Sistema:** Solicita el segundo factor antes de crear la sesión.

**Continuación:** el caso de uso continúa en el paso 3 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Credenciales incorrectas

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El correo o la contraseña no son correctos.

1. **Sistema:** Rechaza el acceso con un mensaje genérico que no revela qué dato falló.

**Resultado:** El usuario puede volver a intentarlo desde el paso 1 del flujo principal.

#### FE-2 — Cuenta no autorizada o desactivada

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El dominio no está autorizado o la cuenta está desactivada.

1. **Sistema:** Rechaza el acceso. No existe el autorregistro.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

#### FE-3 — Demasiados intentos fallidos

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El usuario supera el número de intentos fallidos permitido.

1. **Usuario operativo:** Supera el número de intentos fallidos permitido.
2. **Sistema:** Bloquea temporalmente el acceso y lo registra.

**Resultado:** El acceso queda bloqueado temporalmente.

#### FE-4 — Enlace caducado

**Se produce en:** FA-1 (recuperación de contraseña).  
**Condición:** El enlace de recuperación ha caducado o ya se usó.

1. **Sistema:** Lo indica y permite solicitar un nuevo enlace.

**Resultado:** El usuario puede solicitar un nuevo enlace desde el paso 1 de FA-1.

---

### 6. Postcondiciones

- POST-1. El usuario tiene una sesión activa o ha cambiado su contraseña de forma segura.
- POST-2. Los accesos fallidos y los cambios de contraseña quedan registrados.

---

## CU-31 — Gestionar usuarios, roles y asignación de clientes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-31 |
| **Nombre** | Gestionar usuarios, roles y asignación de clientes |
| **Objetivo** | Dar de alta usuarios por invitación, asignarles rol y clientes, y desactivarlos cuando proceda. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior y tiene permiso para gestionar usuarios.

---

### 3. Flujo principal

*Escenario descrito: invitar a un usuario.*

1. **Administrador:** Selecciona «Invitar usuario».
2. **Sistema:** Solicita el correo corporativo y el rol.
3. **Administrador:** Los introduce.
4. **Sistema:** Valida que el dominio está autorizado, que el usuario no existe y que el rol puede concederse.
5. **Sistema:** Envía la invitación por correo.
6. **Usuario invitado:** Activa su cuenta y define su contraseña.
7. **Administrador:** Asigna clientes al usuario.
8. **Sistema:** Guarda la asignación y la registra.

---

### 4. Flujos alternativos

#### FA-1 — Cambiar el rol

**Se produce en:** después del paso 8 del flujo principal (usuario ya creado).  
**Condición:** El Administrador cambia el rol de un usuario.

1. **Administrador:** Cambia el rol de un usuario.
2. **Sistema:** Aplica los nuevos permisos, comprobados en servidor, y lo registra.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Desactivar una cuenta

**Se produce en:** después del paso 8 del flujo principal (usuario ya creado).  
**Condición:** El Administrador desactiva una cuenta.

1. **Administrador:** Desactiva una cuenta.
2. **Sistema:** Impide nuevos accesos, invalida las sesiones activas y conserva la cuenta y su rastro histórico.

**Continuación:** el caso de uso finaliza.

#### FA-3 — Reasignar clientes

**Se produce en:** después del paso 8 del flujo principal (usuario ya creado).  
**Condición:** El Administrador reasigna clientes de un usuario a otro.

1. **Administrador:** Reasigna clientes de un usuario a otro.
2. **Sistema:** Las tareas pendientes de esos clientes pasan al nuevo responsable (CU-04, FA-3).

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Correo no corporativo

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El dominio no está autorizado.

1. **Sistema:** No envía la invitación e indica el motivo.

**Resultado:** El Administrador puede corregir el correo y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Usuario ya existente

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Ya existe una cuenta con ese correo.

1. **Sistema:** No crea un duplicado e indica el estado de la cuenta existente.

**Resultado:** El caso de uso termina sin crear un duplicado.

#### FE-3 — Rol no permitido

**Se produce en:** paso 4 del flujo principal y FA-1.  
**Condición:** El Administrador intenta conceder o modificar el rol Superadministrador.

1. **Administrador:** Intenta conceder o modificar el rol Superadministrador.
2. **Sistema:** Lo impide (A-14).

**Resultado:** El caso de uso termina sin realizar la operación.

#### FE-4 — Sin permiso para gestionar usuarios

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un Administrador sin permiso de gestión de usuarios intenta realizar la operación.

1. **Administrador:** Intenta gestionar usuarios sin tener ese permiso.
2. **Sistema:** Rechaza la operación (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. El usuario queda invitado, con rol y clientes asignados, o desactivado, según el flujo.
- POST-2. Los cambios quedan en el registro de auditoría.

---

## CU-32 — Ejecutar acción masiva

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-32 |
| **Nombre** | Ejecutar acción masiva |
| **Objetivo** | Aplicar una misma operación a varios elementos a la vez, con confirmación explícita del alcance y controles adicionales. |
| **Actores participantes** | Administrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior y tiene permiso sobre los elementos afectados.

---

### 3. Flujo principal

1. **Administrador:** Selecciona los elementos mediante filtro o selección manual.
2. **Administrador:** Elige la acción masiva (por ejemplo, reasignar clientes o etiquetarlos).
3. **Sistema:** Muestra el número exacto de elementos afectados y un resumen de la acción.
4. **Administrador:** Confirma de forma explícita.
5. **Sistema:** Ejecuta la acción sobre todos los elementos.
6. **Sistema:** Muestra el resumen del resultado.
7. **Sistema:** Registra la operación en el registro de auditoría.

---

### 4. Flujos alternativos

#### FA-1 — Cancelar

**Se produce en:** paso 4 del flujo principal.  
**Condición:** El Administrador cancela.

1. **Administrador:** Cancela.
2. **Sistema:** No modifica ningún dato.

**Continuación:** el caso de uso finaliza sin modificar ningún dato.

#### FA-2 — Acción de alto impacto económico

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La acción tiene alto impacto económico.

1. **Sistema:** Exige controles adicionales: una confirmación reforzada y la aprobación de otra persona distinta de quien la solicita (A-17).

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Selección vacía

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La selección no contiene elementos.

1. **Sistema:** No permite continuar.

**Resultado:** El Administrador debe seleccionar al menos un elemento y el caso de uso regresa al paso 1 del flujo principal.

#### FE-2 — Elementos no permitidos

**Se produce en:** paso 3 del flujo principal.  
**Condición:** La selección incluye elementos sobre los que el usuario no tiene permiso.

1. **Sistema:** Los excluye o impide la acción e indica el motivo.

**Resultado:** El caso de uso continúa en el paso 4 del flujo principal solo con los elementos permitidos, o termina si no queda ninguno.

#### FE-3 — Fallo durante la ejecución

**Se produce en:** paso 5 del flujo principal.  
**Condición:** La ejecución falla.

1. **Sistema:** Revierte la acción completa, no deja datos a medias y muestra el error (A-18).

**Resultado:** Ningún elemento queda modificado; el Administrador puede reintentar desde el paso 1 del flujo principal.

---

### 6. Postcondiciones

- POST-1. La acción se ha aplicado a todos los elementos confirmados, o a ninguno.
- POST-2. La operación queda registrada, con su alcance exacto y su responsable.

---

## CU-33 — Consultar monitorización y métricas

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-33 |
| **Nombre** | Consultar monitorización y métricas |
| **Objetivo** | Conocer el estado de las tareas automatizadas, las integraciones y las copias de seguridad, y consultar métricas agregadas del sistema. |
| **Actores participantes** | Administrador y Planificador del sistema (principales) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado con rol Administrador o superior.

---

### 3. Flujo principal

1. **Administrador:** Accede al panel de monitorización.
2. **Sistema:** Muestra la última ejecución de la generación recurrente, la cola de correos pendientes, los errores de integración recientes y la última copia de seguridad correcta.
3. **Administrador:** Selecciona un elemento con incidencia.
4. **Sistema:** Muestra su detalle con un identificador de error.
5. **Administrador:** Consulta las métricas agregadas del sistema.

---

### 4. Flujos alternativos

#### FA-1 — El Planificador registra resultados

**Se produce en:** cualquier momento (los resultados se registran al finalizar cada tarea automatizada).  
**Condición:** El Planificador del sistema finaliza una tarea automatizada.

1. **Planificador del sistema:** Finaliza una tarea automatizada.
2. **Sistema:** Registra su resultado, que queda disponible en el panel.

**Continuación:** el caso de uso finaliza.

#### FA-2 — Métricas de uso

**Se produce en:** paso 5 del flujo principal.  
**Condición:** El Administrador consulta las métricas de uso.

1. **Administrador:** Consulta las métricas de uso.
2. **Sistema:** Las muestra de forma agregada, sin vigilancia individual de empleados.

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Sin datos

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Todavía no existe ninguna ejecución registrada.

1. **Sistema:** Lo indica sin mostrar estados engañosos.

**Resultado:** El caso de uso finaliza sin datos que mostrar.

#### FE-2 — Fuente de datos no disponible

**Se produce en:** paso 2 del flujo principal.  
**Condición:** Una fuente no responde.

1. **Sistema:** Muestra el resto del panel e indica qué fuente falla.

**Resultado:** El caso de uso continúa en el paso 3 del flujo principal con las fuentes disponibles.

---

### 6. Postcondiciones

- POST-1. El Administrador conoce el estado operativo del sistema.
- POST-2. La consulta no modifica ningún dato.

---

## CU-34 — Consultar registro de auditoría

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-34 |
| **Nombre** | Consultar registro de auditoría |
| **Objetivo** | Revisar quién hizo qué y cuándo en la plataforma. |
| **Actores participantes** | Superadministrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado como Superadministrador.

---

### 3. Flujo principal

1. **Superadministrador:** Accede al registro de auditoría.
2. **Sistema:** Muestra los eventos más recientes.
3. **Superadministrador:** Filtra por usuario, acción, fecha o entidad (cliente, factura u otra).
4. **Sistema:** Muestra los eventos que cumplen los filtros.
5. **Superadministrador:** Abre un evento.
6. **Sistema:** Muestra quién lo realizó, qué se hizo, cuándo y, si procede, los valores anteriores y nuevos.

---

### 4. Flujos alternativos

#### FA-1 — Consultar el historial de una entidad

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador accede al registro desde una factura o cliente.

1. **Superadministrador:** Accede al registro desde una factura o cliente.
2. **Sistema:** Muestra los eventos de esa entidad.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

#### FA-2 — Consultar un error técnico

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador busca por un identificador de error.

1. **Superadministrador:** Busca por un identificador de error.
2. **Sistema:** Muestra los eventos relacionados.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Sin resultados

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Ningún evento cumple los filtros.

1. **Sistema:** Lo indica.

**Resultado:** El usuario puede ajustar los filtros y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Acceso no autorizado

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Un usuario con otro rol intenta acceder.

1. **Usuario sin permiso:** Intenta acceder al registro de auditoría.
2. **Sistema:** Rechaza el acceso (el control se realiza en servidor).

**Resultado:** El caso de uso termina sin realizar la operación.

---

### 6. Postcondiciones

- POST-1. El Superadministrador ha consultado los eventos.
- POST-2. El registro es de solo lectura: ningún evento puede modificarse ni borrarse.

---

## CU-35 — Configurar facturación y tarifas

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-35 |
| **Nombre** | Configurar facturación y tarifas |
| **Objetivo** | Mantener los parámetros que rigen la facturación: series, impuestos, tabla de tarifas, umbrales de aprobación y datos del emisor. |
| **Actores participantes** | Superadministrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado como Superadministrador.

---

### 3. Flujo principal

1. **Superadministrador:** Accede a la configuración de facturación.
2. **Sistema:** Muestra los parámetros vigentes (series, impuestos, tabla de tarifas, umbrales de aprobación y datos del emisor).
3. **Superadministrador:** Modifica uno o varios parámetros.
4. **Sistema:** Valida los cambios.
5. **Sistema:** Informa de que se aplicarán solo a las facturas y revisiones futuras.
6. **Superadministrador:** Confirma.
7. **Sistema:** Guarda los cambios con su fecha de efecto y registra el valor anterior y el nuevo.

---

### 4. Flujos alternativos

#### FA-1 — Modificar la tabla de tarifas

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador modifica los rangos y precios.

1. **Superadministrador:** Modifica los rangos y precios.
2. **Sistema:** Valida que los rangos son coherentes y los guarda.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

#### FA-2 — Crear una serie de facturación

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador crea una serie nueva con su numeración inicial.

1. **Superadministrador:** Crea una serie nueva con su numeración inicial.
2. **Sistema:** La guarda y la deja disponible.

**Continuación:** el caso de uso continúa en el paso 4 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Valores inválidos

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un valor no es válido (por ejemplo, rangos de tarifa solapados o con huecos).

1. **Sistema:** No guarda e indica qué corregir.

**Resultado:** El Superadministrador corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Serie en uso

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El Superadministrador intenta eliminar una serie con facturas emitidas.

1. **Superadministrador:** Intenta eliminar una serie con facturas emitidas.
2. **Sistema:** Lo impide para preservar la numeración correlativa.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

---

### 6. Postcondiciones

- POST-1. La configuración queda actualizada para las facturas y revisiones futuras.
- POST-2. Las facturas históricas no se alteran.
- POST-3. El cambio queda en el registro de auditoría.

---

## CU-36 — Configurar recordatorios y funciones inteligentes

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-36 |
| **Nombre** | Configurar recordatorios y funciones inteligentes |
| **Objetivo** | Definir la cadencia de los recordatorios de pago y activar o desactivar las funciones opcionales de IA. |
| **Actores participantes** | Superadministrador (principal) |

---

### 2. Precondiciones

- PRE-1. El usuario está autenticado como Superadministrador.

---

### 3. Flujo principal

1. **Superadministrador:** Accede a la configuración de recordatorios.
2. **Sistema:** Muestra la cadencia vigente: recordatorio previo, recordatorio de vencimiento y frecuencia de los avisos de impago.
3. **Superadministrador:** Modifica los plazos.
4. **Sistema:** Valida que son coherentes entre sí.
5. **Sistema:** Guarda los cambios, que se aplicarán en las siguientes ejecuciones (CU-20), y registra el valor anterior y el nuevo.

---

### 4. Flujos alternativos

#### FA-1 — Activar o desactivar funciones inteligentes

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El Superadministrador activa o desactiva una función inteligente.

1. **Superadministrador:** Activa o desactiva una función inteligente.
2. **Sistema:** Lo guarda y mantiene el funcionamiento normal sin ella (BR-23). Las sugerencias con efecto económico siempre requieren confirmación humana (FR-39).

**Continuación:** el caso de uso finaliza.

#### FA-2 — Vencimiento pactado

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Existen clientes con un vencimiento pactado distinto del general.

1. **Sistema:** Recuerda que el vencimiento pactado con un cliente prevalece sobre el general.
2. **Sistema:** Los clientes con vencimiento pactado no se ven afectados por el cambio del general.

**Continuación:** el caso de uso continúa en el paso 5 del flujo principal.

---

### 5. Flujos de excepción

#### FE-1 — Valores incoherentes

**Se produce en:** paso 4 del flujo principal.  
**Condición:** Un plazo es negativo o el recordatorio previo queda posterior al vencimiento.

1. **Sistema:** No guarda e indica qué corregir.

**Resultado:** El Superadministrador corrige la causa y el caso de uso regresa al paso 3 del flujo principal.

#### FE-2 — Servicio de IA no disponible

**Se produce en:** FA-1 (funciones inteligentes).  
**Condición:** El servicio de IA no responde.

1. **Sistema:** Desactiva la función de forma controlada, sigue funcionando sin ella y lo registra en la monitorización.

**Resultado:** El caso de uso continúa sin la función inteligente; el resto del sistema sigue funcionando.

---

### 6. Postcondiciones

- POST-1. La cadencia y las funciones quedan configuradas para las ejecuciones siguientes.
- POST-2. Los avisos ya enviados no se modifican.
- POST-3. El cambio queda en el registro de auditoría.

---

## CU-37 — Consultar datos y operar por API

### 1. Identificación

| Campo | Descripción |
|---|---|
| **Identificador** | CU-37 |
| **Nombre** | Consultar datos y operar por API |
| **Objetivo** | Permitir que un sistema externo autorizado consulte datos y registre solicitudes controladas sin saltarse las reglas de negocio. |
| **Actores participantes** | Sistema externo (principal) |

---

### 2. Precondiciones

- PRE-1. El sistema externo dispone de credenciales válidas y permisos concedidos.

---

### 3. Flujo principal

*Escenario descrito: consulta.*

1. **Sistema externo:** Se autentica ante la API.
2. **Sistema externo:** Solicita una consulta (por ejemplo, datos de un cliente, sus facturas o su deuda pendiente).
3. **Sistema:** Valida las credenciales y comprueba los permisos en servidor.
4. **Sistema:** Aplica las mismas reglas de negocio que en la aplicación.
5. **Sistema:** Devuelve los datos permitidos.
6. **Sistema:** Registra la petición.

---

### 4. Flujos alternativos

#### FA-1 — Registrar una solicitud controlada

**Se produce en:** paso 2 del flujo principal.  
**Condición:** El Sistema externo envía una solicitud (por ejemplo, de baja de un cliente).

1. **Sistema externo:** Envía una solicitud (por ejemplo, de baja de un cliente).
2. **Sistema:** La registra como pendiente de revisión humana y no modifica directamente los datos ni las recurrencias (BR-22).

**Continuación:** el caso de uso finaliza.

---

### 5. Flujos de excepción

#### FE-1 — Autenticación inválida

**Se produce en:** paso 1 del flujo principal.  
**Condición:** Las credenciales no son válidas o han caducado.

1. **Sistema:** Rechaza la petición.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

#### FE-2 — Sin permiso

**Se produce en:** paso 3 del flujo principal.  
**Condición:** El sistema externo no tiene permiso sobre ese dato.

1. **Sistema externo:** No tiene permiso sobre ese dato.
2. **Sistema:** Rechaza la petición.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

#### FE-3 — Operación prohibida

**Se produce en:** paso 2 del flujo principal y FA-1.  
**Condición:** El Sistema externo intenta modificar o eliminar directamente una recurrencia o saltarse una aprobación.

1. **Sistema externo:** Intenta modificar o eliminar directamente una recurrencia o saltarse una aprobación.
2. **Sistema:** Rechaza la operación y la registra.

**Resultado:** El sistema externo no obtiene datos ni efectos y el caso de uso termina.

#### FE-4 — Solicitud inválida

**Se produce en:** paso 2 del flujo principal.  
**Condición:** La solicitud está mal formada.

1. **Sistema:** La rechaza e indica el error.

**Resultado:** El caso de uso termina sin completar la operación y sin modificar datos.

---

### 6. Postcondiciones

- POST-1. El sistema externo recibe solo los datos permitidos, o su solicitud queda pendiente de revisión humana.
- POST-2. Toda petición queda registrada.

---