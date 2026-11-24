-- =============================================================================
--  MODELO FÍSICO DE DATOS · Sistema de facturación de Turbine
--  Grupo JIRAFAS · Análisis y Diseño de Aplicaciones · Entrega 2
--
--  Origen: diagrama UML de clases de Pablo Fernández Carabantes (40 clases,
--  2 interfaces) y Entrega 1 (requisitos FR/NFR/BR y casos de uso CU-01..CU-37).
--  SGBD:   PostgreSQL 15 o superior (software libre, NFR-11). Supuesto de
--          diseño: la Entrega 1 no fija el SGBD (ver "Decisiones abiertas").
--
--  Convenciones
--    - Tablas y columnas en minúsculas y snake_case. PK = id_<entidad>.
--    - Importes: NUMERIC, nunca FLOAT (NFR-06). Fechas: DATE; fecha y hora:
--      TIMESTAMPTZ.
--    - Estados y tipos: VARCHAR + CHECK con los valores de la tabla «Valores
--      permitidos» del documento de clases.
--    - Borrado: RESTRICT por defecto; CASCADE solo en las partes de una
--      composición UML (línea de factura, tarea, fila de importación...).
--
--  Orden de ejecución: este fichero se puede ejecutar de una vez en una base
--  vacía:   psql -d jirafas -f modelo_datos.sql
-- =============================================================================

-- =============================================================================
--  BLOQUE F (parte 1) · Administración, seguridad y sistema
-- =============================================================================

-- Usuario + UsuarioOperativo + Administrador + Superadministrador -> una tabla
-- con la columna rol (la herencia de roles se aplana: cada rol puede hacer
-- todo lo del anterior).
CREATE TABLE usuario (
    id_usuario BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    correo_corporativo VARCHAR(255) NOT NULL,           -- FR-06, CU-30
    hash_contrasena VARCHAR(255),                       -- NFR-17: nunca en claro; NULL mientras INVITADO
    rol VARCHAR(20) NOT NULL DEFAULT 'OPERATIVO',
    estado VARCHAR(15) NOT NULL DEFAULT 'INVITADO',     -- CU-30, CU-31
    doble_factor_activo BOOLEAN NOT NULL DEFAULT FALSE, -- NFR-09 (opcional)
    intentos_fallidos INTEGER NOT NULL DEFAULT 0,       -- NFR-08
    bloqueado_hasta TIMESTAMPTZ,
    preferencias_notificacion TEXT,                     -- FR-36
    puede_gestionar_usuarios BOOLEAN NOT NULL DEFAULT FALSE, -- atributo de Administrador
    CONSTRAINT ck_usuario_rol CHECK (rol IN ('OPERATIVO', 'ADMINISTRADOR', 'SUPERADMINISTRADOR')),
    CONSTRAINT ck_usuario_estado CHECK (estado IN ('INVITADO', 'ACTIVO', 'BLOQUEADO', 'DESACTIVADO')),
    CONSTRAINT ck_usuario_intentos CHECK (intentos_fallidos >= 0),
    CONSTRAINT ck_usuario_activo_con_clave CHECK (estado <> 'ACTIVO' OR hash_contrasena IS NOT NULL),
    CONSTRAINT ck_usuario_gestion CHECK (rol <> 'OPERATIVO' OR puede_gestionar_usuarios = FALSE)
);
CREATE UNIQUE INDEX ux_usuario_correo ON usuario (lower(correo_corporativo));

-- ConfiguracionSistema: una única fila (el Superadministrador la modifica, CU-35).
CREATE TABLE configuracion_sistema (
    id_configuracion SMALLINT PRIMARY KEY DEFAULT 1,
    datos_emisor TEXT NOT NULL,
    umbral_descuento NUMERIC(14,2) NOT NULL,            -- FR-18
    umbral_importe_alto NUMERIC(14,2) NOT NULL,
    vencimiento_general_dias INTEGER NOT NULL,          -- BR-16
    dias_recordatorio_previo INTEGER NOT NULL DEFAULT 3,
    dias_recordatorio_vencimiento INTEGER NOT NULL DEFAULT 5,
    frecuencia_aviso_impago_dias INTEGER NOT NULL DEFAULT 2,
    funciones_inteligentes_activas BOOLEAN NOT NULL DEFAULT FALSE, -- BR-22, FR-39
    dominio_corporativo VARCHAR(255) NOT NULL,          -- FR-06
    dias_conservacion_informes INTEGER NOT NULL,        -- FR-37
    CONSTRAINT ck_config_unica CHECK (id_configuracion = 1),
    CONSTRAINT ck_config_importes CHECK (umbral_descuento >= 0 AND umbral_importe_alto >= 0),
    CONSTRAINT ck_config_plazos CHECK (vencimiento_general_dias >= 0 AND dias_recordatorio_previo >= 0
        AND dias_recordatorio_vencimiento >= 0 AND frecuencia_aviso_impago_dias > 0
        AND dias_conservacion_informes > 0)
);

CREATE TABLE serie_facturacion (
    id_serie BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    prefijo VARCHAR(20) NOT NULL,
    ultimo_numero INTEGER NOT NULL DEFAULT 0,           -- BR-10: se incrementa con UPDATE ... RETURNING
    CONSTRAINT ck_serie_numero CHECK (ultimo_numero >= 0)
);

CREATE TABLE impuesto (
    id_impuesto BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE,
    porcentaje NUMERIC(5,2) NOT NULL,
    CONSTRAINT ck_impuesto_porcentaje CHECK (porcentaje BETWEEN 0 AND 100)
);

CREATE TABLE rango_tarifa (
    id_rango BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    facturacion_minima NUMERIC(14,2) NOT NULL,
    facturacion_maxima NUMERIC(14,2) NOT NULL,
    precio NUMERIC(14,2) NOT NULL,
    fecha_efecto DATE NOT NULL,                         -- CU-35: solo afecta a revisiones futuras
    CONSTRAINT ck_rango_limites CHECK (facturacion_minima >= 0 AND facturacion_maxima > facturacion_minima),
    CONSTRAINT ck_rango_precio CHECK (precio >= 0)
);

CREATE TABLE ejecucion_tarea (                          -- registro del Planificador (NFR-15)
    id_ejecucion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo VARCHAR(30) NOT NULL,
    inicio TIMESTAMPTZ NOT NULL DEFAULT now(),
    fin TIMESTAMPTZ,
    estado VARCHAR(25) NOT NULL DEFAULT 'EN_CURSO',
    resumen TEXT,
    errores TEXT,
    CONSTRAINT ck_ejecucion_tipo CHECK (tipo IN ('GENERACION_RECURRENTE', 'RECORDATORIOS', 'CONSULTA_PAGOS',
        'RESUMEN_DIARIO', 'COPIA_SEGURIDAD')),
    CONSTRAINT ck_ejecucion_estado CHECK (estado IN ('EN_CURSO', 'COMPLETADA', 'COMPLETADA_CON_ERRORES', 'INTERRUMPIDA')),
    CONSTRAINT ck_ejecucion_fechas CHECK (fin IS NULL OR fin >= inicio),
    CONSTRAINT ck_ejecucion_fin CHECK (estado NOT IN ('COMPLETADA', 'COMPLETADA_CON_ERRORES') OR fin IS NOT NULL)
);

-- =============================================================================
--  BLOQUE E (parte 1) · Catálogos de seguimiento
-- =============================================================================

CREATE TABLE centro_coste (
    id_centro_coste BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(15) NOT NULL,                          -- FR-40
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_centro_tipo CHECK (tipo IN ('CENTRO_COSTE', 'PROYECTO')),
    CONSTRAINT uq_centro_nombre UNIQUE (tipo, nombre)
);

CREATE TABLE regla_alerta (
    id_regla BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo VARCHAR(20) NOT NULL,                          -- FR-42: conjunto cerrado de reglas
    umbral NUMERIC(14,2) NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_regla_tipo CHECK (tipo IN ('DIAS_VENCIDA', 'IMPORTE_PENDIENTE')),
    CONSTRAINT ck_regla_umbral CHECK (umbral > 0)
);

-- =============================================================================
--  BLOQUE D (parte 1) · Plantillas de comunicación
-- =============================================================================

CREATE TABLE plantilla_comunicacion (                   -- CU-22: versionadas (BR-11)
    id_plantilla BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo VARCHAR(25) NOT NULL,
    idioma VARCHAR(10) NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    asunto VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    CONSTRAINT ck_plantilla_tipo CHECK (tipo IN ('FACTURA', 'RECORDATORIO_PREVIO', 'VENCIMIENTO',
        'AVISO_IMPAGO', 'DISPUTA_RESUELTA')),
    CONSTRAINT ck_plantilla_version CHECK (version >= 1),
    CONSTRAINT uq_plantilla_version UNIQUE (tipo, idioma, version)
);

-- =============================================================================
--  BLOQUE A · Clientes y contactos
-- =============================================================================

CREATE TABLE etiqueta (                                 -- de Cliente.etiquetas : List<String> (1FN)
    id_etiqueta BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE importacion_csv (                          -- CU-03
    id_importacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario BIGINT NOT NULL REFERENCES usuario (id_usuario),
    nombre_archivo VARCHAR(255) NOT NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT now(),
    incluye_facturas_historicas BOOLEAN NOT NULL DEFAULT FALSE,
    estado VARCHAR(15) NOT NULL DEFAULT 'PREVISUALIZADA',
    creados INTEGER NOT NULL DEFAULT 0,
    actualizados INTEGER NOT NULL DEFAULT 0,
    rechazados INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT ck_importacion_estado CHECK (estado IN ('PREVISUALIZADA', 'CONFIRMADA', 'CANCELADA')),
    CONSTRAINT ck_importacion_contadores CHECK (creados >= 0 AND actualizados >= 0 AND rechazados >= 0)
);

CREATE TABLE fila_importacion (
    id_importacion BIGINT NOT NULL REFERENCES importacion_csv (id_importacion) ON DELETE CASCADE,
    numero_fila INTEGER NOT NULL,
    estado VARCHAR(20) NOT NULL,
    motivo_error TEXT,                                  -- CU-03: motivo de rechazo
    marcada_como_actualizacion BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id_importacion, numero_fila),
    CONSTRAINT ck_fila_numero CHECK (numero_fila > 0),
    CONSTRAINT ck_fila_estado CHECK (estado IN ('VALIDA', 'ERROR', 'DUPLICADO', 'DATOS_INCOMPLETOS', 'EXCLUIDA')),
    CONSTRAINT ck_fila_motivo CHECK (estado NOT IN ('ERROR', 'DUPLICADO', 'DATOS_INCOMPLETOS') OR motivo_error IS NOT NULL)
);

CREATE TABLE cliente (                                  -- CU-01
    id_cliente BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_responsable BIGINT NOT NULL REFERENCES usuario (id_usuario),            -- responsableInterno
    id_centro_coste BIGINT REFERENCES centro_coste (id_centro_coste),
    id_importacion BIGINT REFERENCES importacion_csv (id_importacion),         -- "crea/actualiza"
    nombre_comercial VARCHAR(150) NOT NULL,
    razon_social VARCHAR(200),
    identificador_fiscal VARCHAR(40),                   -- NO único: el duplicado solo se avisa (CU-01)
    domicilio_fiscal VARCHAR(300),
    pais VARCHAR(60),
    moneda CHAR(3),                                     -- ISO 4217 (FR-03: varias monedas)
    sector VARCHAR(80),
    ubicacion VARCHAR(150),
    idioma VARCHAR(10) NOT NULL DEFAULT 'es',
    estado VARCHAR(25) NOT NULL DEFAULT 'PENDIENTE_ACTIVACION',
    datos_fiscales_incompletos BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_inicio DATE,
    condiciones_pago TEXT,
    documento_firmado VARCHAR(500),                     -- referencia al documento firmado fuera de la plataforma
    vencimiento_pactado_dias INTEGER,                   -- BR-16: prevalece sobre el general
    fecha_baja DATE,                                    -- operación darDeBaja(fecha)
    CONSTRAINT ck_cliente_estado CHECK (estado IN ('ACTIVO', 'PENDIENTE_ACTIVACION', 'BAJA')),
    CONSTRAINT ck_cliente_moneda CHECK (moneda IS NULL OR moneda ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_cliente_vencimiento CHECK (vencimiento_pactado_dias IS NULL OR vencimiento_pactado_dias >= 0),
    CONSTRAINT ck_cliente_datos_fiscales CHECK (datos_fiscales_incompletos
        OR (razon_social IS NOT NULL AND identificador_fiscal IS NOT NULL AND domicilio_fiscal IS NOT NULL
            AND pais IS NOT NULL AND moneda IS NOT NULL)),
    CONSTRAINT ck_cliente_baja CHECK (estado <> 'BAJA' OR fecha_baja IS NOT NULL)
);

CREATE TABLE cliente_etiqueta (
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente) ON DELETE CASCADE,
    id_etiqueta BIGINT NOT NULL REFERENCES etiqueta (id_etiqueta),
    PRIMARY KEY (id_cliente, id_etiqueta)
);

CREATE TABLE contacto (
    id_contacto BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    correo VARCHAR(255) NOT NULL,
    idioma VARCHAR(10) NOT NULL DEFAULT 'es',
    consentimiento_whatsapp BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE                -- BR-19: desactivar no borra histórico
);

-- ClienteContacto (clase asociación): N:M Cliente-Contacto con el tipo (FR-04).
-- Regla "todo cliente tiene al menos un contacto" (1..*): no la expresa una FK; la valida la aplicación.
CREATE TABLE cliente_contacto (
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente) ON DELETE CASCADE,
    id_contacto BIGINT NOT NULL REFERENCES contacto (id_contacto),
    tipo VARCHAR(15) NOT NULL,
    PRIMARY KEY (id_cliente, id_contacto),
    CONSTRAINT ck_cc_tipo CHECK (tipo IN ('CONTRATACION', 'FACTURACION', 'IMPAGOS'))
);

CREATE TABLE favorito (                                 -- asociación "favoritos" Usuario-Cliente (FR-28)
    id_usuario BIGINT NOT NULL REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente) ON DELETE CASCADE,
    PRIMARY KEY (id_usuario, id_cliente)
);

CREATE TABLE tarea (                                    -- CU-04
    id_tarea BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente) ON DELETE CASCADE,
    id_completada_por BIGINT REFERENCES usuario (id_usuario),
    descripcion TEXT NOT NULL,
    fecha_prevista DATE NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE',
    fecha_completada TIMESTAMPTZ,
    CONSTRAINT ck_tarea_estado CHECK (estado IN ('PENDIENTE', 'COMPLETADA')),
    CONSTRAINT ck_tarea_completada CHECK ((estado = 'COMPLETADA') = (fecha_completada IS NOT NULL))
);

-- =============================================================================
--  BLOQUE B · Suscripciones, tarifas y descuentos
-- =============================================================================

CREATE TABLE suscripcion (                              -- CU-05
    id_suscripcion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente) ON DELETE CASCADE,
    plan VARCHAR(100) NOT NULL,
    precio_vigente NUMERIC(14,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    estado VARCHAR(25) NOT NULL DEFAULT 'PENDIENTE_ACTIVACION',
    motivo_pausa TEXT,
    fecha_inicio_pausa DATE,
    fecha_reactivacion_prevista DATE,
    fecha_baja DATE,
    motivo_baja TEXT,
    CONSTRAINT ck_susc_estado CHECK (estado IN ('PENDIENTE_ACTIVACION', 'ACTIVA', 'EN_PAUSA', 'CANCELADA')),
    CONSTRAINT ck_susc_precio CHECK (precio_vigente >= 0),
    CONSTRAINT ck_susc_pausa CHECK (estado <> 'EN_PAUSA' OR (fecha_inicio_pausa IS NOT NULL AND motivo_pausa IS NOT NULL)),
    CONSTRAINT ck_susc_reactivacion CHECK (fecha_reactivacion_prevista IS NULL OR fecha_inicio_pausa IS NULL
        OR fecha_reactivacion_prevista >= fecha_inicio_pausa),
    CONSTRAINT ck_susc_baja CHECK (estado <> 'CANCELADA' OR fecha_baja IS NOT NULL)   -- BR-14, BR-15
);

CREATE TABLE revision_tarifa_anual (                    -- CU-06
    id_revision BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente),
    id_rango_propuesto BIGINT REFERENCES rango_tarifa (id_rango),
    id_aprobador BIGINT REFERENCES usuario (id_usuario),                       -- aprobadaPor (Administrador)
    fecha_revision DATE NOT NULL,
    facturacion_anual_verificada NUMERIC(14,2) NOT NULL,
    precio_anterior NUMERIC(14,2) NOT NULL,
    precio_nuevo NUMERIC(14,2) NOT NULL,
    fecha_decision TIMESTAMPTZ,
    estado VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE',
    motivo_rechazo TEXT,
    CONSTRAINT ck_revision_estado CHECK (estado IN ('PENDIENTE', 'APROBADA', 'RECHAZADA')),
    CONSTRAINT ck_revision_importes CHECK (facturacion_anual_verificada >= 0 AND precio_anterior >= 0 AND precio_nuevo >= 0),
    CONSTRAINT ck_revision_decision CHECK ((estado = 'PENDIENTE') = (fecha_decision IS NULL)),
    CONSTRAINT ck_revision_aprobador CHECK (estado = 'PENDIENTE' OR id_aprobador IS NOT NULL),  -- BR-12
    CONSTRAINT ck_revision_rechazo CHECK (estado <> 'RECHAZADA' OR motivo_rechazo IS NOT NULL)
);

CREATE TABLE solicitud_descuento (                      -- CU-07, CU-08, CU-09
    id_solicitud BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente),
    id_suscripcion BIGINT REFERENCES suscripcion (id_suscripcion),
    id_solicitante BIGINT NOT NULL REFERENCES usuario (id_usuario),
    id_aprobador BIGINT REFERENCES usuario (id_usuario),
    tipo VARCHAR(12) NOT NULL,
    valor NUMERIC(14,2) NOT NULL,
    motivo TEXT NOT NULL,
    fecha_vigencia DATE,
    estado VARCHAR(25) NOT NULL DEFAULT 'PENDIENTE',
    motivo_decision TEXT,
    fecha_decision TIMESTAMPTZ,
    CONSTRAINT ck_sd_tipo CHECK (tipo IN ('PORCENTAJE', 'IMPORTE')),
    CONSTRAINT ck_sd_estado CHECK (estado IN ('PENDIENTE', 'ESCALADA', 'APROBADA', 'APROBADA_CONDICIONADA', 'RECHAZADA')),
    CONSTRAINT ck_sd_valor CHECK (valor > 0 AND (tipo <> 'PORCENTAJE' OR valor <= 100)),
    CONSTRAINT ck_sd_separacion CHECK (id_aprobador IS NULL OR id_aprobador <> id_solicitante),   -- BR-12
    CONSTRAINT ck_sd_decidida CHECK (estado NOT IN ('APROBADA', 'APROBADA_CONDICIONADA', 'RECHAZADA')
        OR (id_aprobador IS NOT NULL AND fecha_decision IS NOT NULL)),
    CONSTRAINT ck_sd_rechazo CHECK (estado <> 'RECHAZADA' OR motivo_decision IS NOT NULL)
);

CREATE TABLE excepcion_comercial (                      -- FR-47, BR-18
    id_excepcion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente) ON DELETE CASCADE,
    id_solicitud BIGINT UNIQUE REFERENCES solicitud_descuento (id_solicitud),  -- "se aprueba mediante" (0..1 : 0..1)
    tipo VARCHAR(20) NOT NULL,
    fecha_inicio_futura DATE,
    aprobada BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT ck_excepcion_tipo CHECK (tipo IN ('INICIO_FUTURO', 'PRIMER_MES_GRATIS', 'SIN_PRORRATEO')),
    CONSTRAINT ck_excepcion_inicio CHECK (tipo <> 'INICIO_FUTURO' OR fecha_inicio_futura IS NOT NULL)
);

-- =============================================================================
--  BLOQUE C · Facturación
-- =============================================================================

-- Factura + FacturaRectificativa -> una tabla con tipo = 'RECTIFICATIVA' e
-- id_factura_original (comparten numeración, PDF y cobros).
CREATE TABLE factura (                                  -- CU-10..CU-14
    id_factura BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente),
    id_suscripcion BIGINT REFERENCES suscripcion (id_suscripcion),             -- "genera"
    id_serie BIGINT REFERENCES serie_facturacion (id_serie),                   -- "numera"
    id_ejecucion BIGINT REFERENCES ejecucion_tarea (id_ejecucion),             -- ejecución que la generó (CU-11)
    id_creada_por BIGINT REFERENCES usuario (id_usuario),                      -- NULL: la crea el Planificador
    id_centro_coste BIGINT REFERENCES centro_coste (id_centro_coste),
    id_descuento_aplicado BIGINT REFERENCES solicitud_descuento (id_solicitud),
    id_factura_original BIGINT REFERENCES factura (id_factura),               -- rectificaA (FR-45)
    numero VARCHAR(40),                                 -- vacío en BORRADOR (CU-10)
    tipo VARCHAR(15) NOT NULL DEFAULT 'PUNTUAL',
    estado VARCHAR(25) NOT NULL DEFAULT 'BORRADOR',
    fecha_emision DATE,
    fecha_vencimiento DATE NOT NULL,
    periodo_facturado VARCHAR(7),                       -- 'AAAA-MM'
    moneda CHAR(3) NOT NULL,
    datos_fiscales_emision JSONB,                       -- copia de los datos fiscales al emitir (BR-09)
    base_imponible NUMERIC(14,2) NOT NULL DEFAULT 0,
    total NUMERIC(14,2) NOT NULL DEFAULT 0,
    saldo_pendiente NUMERIC(14,2) NOT NULL DEFAULT 0,   -- derivado /saldoPendiente, guardado (NFR-12)
    retenida BOOLEAN NOT NULL DEFAULT FALSE,            -- tiene AprobacionFactura abierta (FR-13)
    documento_pdf BYTEA,                                -- FR-12: el PDF se guarda en la base de datos
    migrada BOOLEAN NOT NULL DEFAULT FALSE,             -- CU-03: factura histórica importada
    motivo_rectificacion TEXT,
    CONSTRAINT uq_factura_numero UNIQUE (id_serie, numero),                    -- BR-10
    CONSTRAINT ck_factura_tipo CHECK (tipo IN ('PUNTUAL', 'RECURRENTE', 'RECTIFICATIVA')),
    CONSTRAINT ck_factura_estado CHECK (estado IN ('BORRADOR', 'APROBADA', 'EMITIDA', 'ENVIADA', 'VENCIDA', 'PAGADA',
        'PARCIALMENTE_CONCILIADA', 'ANULADA', 'RECTIFICADA', 'INCOBRABLE', 'CANCELADA')),
    CONSTRAINT ck_factura_moneda CHECK (moneda ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_factura_periodo CHECK (periodo_facturado IS NULL OR periodo_facturado ~ '^[0-9]{4}-(0[1-9]|1[0-2])$'),
    CONSTRAINT ck_factura_rectificativa CHECK ((tipo = 'RECTIFICATIVA') = (id_factura_original IS NOT NULL)),
    CONSTRAINT ck_factura_motivo_rect CHECK (tipo <> 'RECTIFICATIVA' OR motivo_rectificacion IS NOT NULL),
    CONSTRAINT ck_factura_recurrente CHECK (tipo <> 'RECURRENTE' OR (id_suscripcion IS NOT NULL AND periodo_facturado IS NOT NULL)),
    CONSTRAINT ck_factura_numeracion CHECK ((numero IS NULL) = (fecha_emision IS NULL)
        AND (numero IS NULL OR id_serie IS NOT NULL)),
    CONSTRAINT ck_factura_borrador CHECK (estado <> 'BORRADOR' OR fecha_emision IS NULL),
    CONSTRAINT ck_factura_emitida CHECK (estado NOT IN ('EMITIDA', 'ENVIADA', 'VENCIDA', 'PAGADA',
        'PARCIALMENTE_CONCILIADA', 'INCOBRABLE', 'RECTIFICADA')
        OR (fecha_emision IS NOT NULL AND datos_fiscales_emision IS NOT NULL)),
    CONSTRAINT ck_factura_vencimiento CHECK (fecha_emision IS NULL OR fecha_vencimiento >= fecha_emision)
);

CREATE TABLE linea_factura (
    id_linea BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_factura BIGINT NOT NULL REFERENCES factura (id_factura) ON DELETE CASCADE,
    id_impuesto BIGINT NOT NULL REFERENCES impuesto (id_impuesto),
    concepto VARCHAR(255) NOT NULL,
    cantidad NUMERIC(12,3) NOT NULL,
    precio_unitario NUMERIC(14,2) NOT NULL,
    descuento NUMERIC(14,2) NOT NULL DEFAULT 0,
    porcentaje_impuesto NUMERIC(5,2) NOT NULL,          -- copia al emitir (BR-11)
    importe NUMERIC(14,2) NOT NULL,
    CONSTRAINT ck_linea_cantidad CHECK (cantidad <> 0),
    CONSTRAINT ck_linea_descuento CHECK (descuento >= 0),
    CONSTRAINT ck_linea_porcentaje CHECK (porcentaje_impuesto BETWEEN 0 AND 100)
);

CREATE TABLE aprobacion_factura (                       -- CU-13: una fila por cada retención
    id_aprobacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_factura BIGINT NOT NULL REFERENCES factura (id_factura) ON DELETE CASCADE,
    id_solicitante BIGINT NOT NULL REFERENCES usuario (id_usuario),
    id_aprobador BIGINT REFERENCES usuario (id_usuario),
    motivo_retencion TEXT NOT NULL,                     -- FR-18
    estado VARCHAR(25) NOT NULL DEFAULT 'PENDIENTE',
    fecha_solicitud TIMESTAMPTZ NOT NULL DEFAULT now(),
    fecha_decision TIMESTAMPTZ,
    motivo_decision TEXT,
    CONSTRAINT ck_af_estado CHECK (estado IN ('PENDIENTE', 'PENDIENTE_INFORMACION', 'APROBADA', 'RECHAZADA')),
    CONSTRAINT ck_af_separacion CHECK (id_aprobador IS NULL OR id_aprobador <> id_solicitante),   -- BR-12
    CONSTRAINT ck_af_decidida CHECK (estado NOT IN ('APROBADA', 'RECHAZADA')
        OR (id_aprobador IS NOT NULL AND fecha_decision IS NOT NULL)),
    CONSTRAINT ck_af_info CHECK (estado <> 'PENDIENTE_INFORMACION' OR motivo_decision IS NOT NULL),   -- CU-13 FA-2
    CONSTRAINT ck_af_fechas CHECK (fecha_decision IS NULL OR fecha_decision >= fecha_solicitud)
);

CREATE TABLE operacion_excepcional (                    -- CU-14
    id_operacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_factura BIGINT NOT NULL REFERENCES factura (id_factura),
    id_solicitante BIGINT NOT NULL REFERENCES usuario (id_usuario),
    id_aprobador BIGINT REFERENCES usuario (id_usuario),
    tipo VARCHAR(15) NOT NULL,
    motivo TEXT NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE',
    CONSTRAINT ck_oe_tipo CHECK (tipo IN ('RECTIFICACION', 'ANULACION', 'INCOBRABLE', 'CANCELACION')),
    CONSTRAINT ck_oe_estado CHECK (estado IN ('PENDIENTE', 'APROBADA', 'RECHAZADA', 'EJECUTADA')),
    CONSTRAINT ck_oe_separacion CHECK (id_aprobador IS NULL OR id_aprobador <> id_solicitante),   -- BR-12
    CONSTRAINT ck_oe_aprobada CHECK (estado NOT IN ('APROBADA', 'EJECUTADA') OR id_aprobador IS NOT NULL)   -- BR-13
);

CREATE TABLE filtro_guardado (                          -- CU-15
    id_filtro BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario BIGINT NOT NULL REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    criterios JSONB NOT NULL,
    CONSTRAINT uq_filtro_nombre UNIQUE (id_usuario, nombre)
);

-- =============================================================================
--  BLOQUE D · Cobros y comunicaciones
-- =============================================================================
-- Las interfaces SistemaPagos y CanalEnvio no tienen tabla: son comportamiento (BR-06).

CREATE TABLE movimiento_cobro (                         -- CU-16
    id_movimiento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_asignado_a BIGINT REFERENCES usuario (id_usuario),                      -- cobro con dudas -> persona
    fuente VARCHAR(10) NOT NULL,
    id_externo VARCHAR(100) NOT NULL,
    importe NUMERIC(14,2) NOT NULL,
    fecha TIMESTAMPTZ NOT NULL,
    moneda CHAR(3) NOT NULL,
    concepto VARCHAR(255),
    referencia VARCHAR(100),
    estado VARCHAR(25) NOT NULL DEFAULT 'PENDIENTE_CONCILIACION',
    CONSTRAINT uq_movimiento_externo UNIQUE (fuente, id_externo),              -- evento duplicado (FR-15)
    CONSTRAINT ck_mov_fuente CHECK (fuente IN ('STRIPE', 'REVOLUT', 'OTRA')),
    CONSTRAINT ck_mov_estado CHECK (estado IN ('PENDIENTE_CONCILIACION', 'PARCIAL', 'CONCILIADO')),
    CONSTRAINT ck_mov_importe CHECK (importe > 0),
    CONSTRAINT ck_mov_moneda CHECK (moneda ~ '^[A-Z]{3}$')
);

-- Conciliacion: N:M entre MovimientoCobro y Factura con importe, regla y reversión.
CREATE TABLE conciliacion (                             -- CU-16, CU-17
    id_conciliacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_movimiento BIGINT NOT NULL REFERENCES movimiento_cobro (id_movimiento),
    id_factura BIGINT NOT NULL REFERENCES factura (id_factura),
    id_realizada_por BIGINT REFERENCES usuario (id_usuario),                   -- NULL si es automática
    id_revertida_por BIGINT REFERENCES usuario (id_usuario),
    importe_asignado NUMERIC(14,2) NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    regla VARCHAR(100),
    fecha TIMESTAMPTZ NOT NULL DEFAULT now(),
    revertida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_reversion TIMESTAMPTZ,
    motivo_reversion TEXT,
    CONSTRAINT ck_conc_tipo CHECK (tipo IN ('AUTOMATICA', 'MANUAL')),
    CONSTRAINT ck_conc_importe CHECK (importe_asignado > 0),
    CONSTRAINT ck_conc_manual CHECK (tipo <> 'MANUAL' OR id_realizada_por IS NOT NULL),
    CONSTRAINT ck_conc_reversion CHECK (revertida = (fecha_reversion IS NOT NULL)
        AND (NOT revertida OR motivo_reversion IS NOT NULL))
);

CREATE TABLE comunicacion (                             -- CU-18, CU-19: una fila por intento/canal
    id_comunicacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_factura BIGINT REFERENCES factura (id_factura),
    id_contacto BIGINT REFERENCES contacto (id_contacto),                      -- destinatario
    id_plantilla BIGINT NOT NULL REFERENCES plantilla_comunicacion (id_plantilla),   -- usa
    tipo VARCHAR(25) NOT NULL,
    canal VARCHAR(20) NOT NULL,
    idioma VARCHAR(10) NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'EN_COLA',
    fecha_envio TIMESTAMPTZ,
    numero_intento INTEGER NOT NULL DEFAULT 1,
    correo_destinatario VARCHAR(255),                   -- copia del correo usado (BR-19, FR-46)
    CONSTRAINT ck_com_tipo CHECK (tipo IN ('FACTURA', 'RECORDATORIO_PREVIO', 'VENCIMIENTO', 'AVISO_IMPAGO', 'DISPUTA_RESUELTA')),
    CONSTRAINT ck_com_canal CHECK (canal IN ('EMAIL', 'WHATSAPP_SIMULADO')),
    CONSTRAINT ck_com_estado CHECK (estado IN ('EN_COLA', 'ENVIADA', 'ENTREGADA', 'REBOTADA', 'FALLIDA')),
    CONSTRAINT ck_com_intento CHECK (numero_intento >= 1),
    CONSTRAINT ck_com_enviada CHECK (estado NOT IN ('ENVIADA', 'ENTREGADA', 'REBOTADA') OR fecha_envio IS NOT NULL),
    CONSTRAINT ck_com_correo CHECK (canal <> 'EMAIL' OR correo_destinatario IS NOT NULL)
);

CREATE TABLE suspension_recordatorios (                 -- CU-21
    id_suspension BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_factura BIGINT NOT NULL REFERENCES factura (id_factura),
    motivo TEXT NOT NULL,
    fecha_revision DATE NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE
);

-- =============================================================================
--  BLOQUE E · Seguimiento, consulta e informes
-- =============================================================================

CREATE TABLE incidencia (                               -- CU-25
    id_incidencia BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente),
    id_factura BIGINT REFERENCES factura (id_factura),
    id_responsable BIGINT NOT NULL REFERENCES usuario (id_usuario),
    tipo VARCHAR(15) NOT NULL,
    descripcion TEXT NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'ABIERTA',
    prioridad VARCHAR(10) NOT NULL DEFAULT 'MEDIA',
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_inc_tipo CHECK (tipo IN ('ENTREGA', 'COBRO', 'FACTURACION', 'OTRA')),
    CONSTRAINT ck_inc_estado CHECK (estado IN ('ABIERTA', 'EN_CURSO', 'RESUELTA', 'CERRADA')),
    CONSTRAINT ck_inc_prioridad CHECK (prioridad IN ('BAJA', 'MEDIA', 'ALTA'))
);

CREATE TABLE adjunto (                                  -- de Incidencia.adjuntos : List<String> (1FN)
    id_adjunto BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_incidencia BIGINT NOT NULL REFERENCES incidencia (id_incidencia) ON DELETE CASCADE,
    referencia VARCHAR(500) NOT NULL                    -- NFR-17: acceso por enlaces temporales
);

-- Comentario: siempre interno. No existe ninguna FK de COMENTARIO hacia COMUNICACION,
-- así que estructuralmente nunca se envía al cliente (BR-20).
CREATE TABLE comentario (
    id_comentario BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_incidencia BIGINT NOT NULL REFERENCES incidencia (id_incidencia) ON DELETE CASCADE,
    id_autor BIGINT NOT NULL REFERENCES usuario (id_usuario),
    texto TEXT NOT NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE mencion (                                  -- asociación "menciona" Comentario-Usuario (FR-35)
    id_comentario BIGINT NOT NULL REFERENCES comentario (id_comentario) ON DELETE CASCADE,
    id_usuario BIGINT NOT NULL REFERENCES usuario (id_usuario),
    PRIMARY KEY (id_comentario, id_usuario)
);

CREATE TABLE notificacion (                             -- CU-23
    id_notificacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario BIGINT NOT NULL REFERENCES usuario (id_usuario),               -- recibe
    id_regla BIGINT REFERENCES regla_alerta (id_regla),                       -- genera (CU-24)
    id_comentario BIGINT REFERENCES comentario (id_comentario),               -- genera (mención)
    categoria VARCHAR(40) NOT NULL,
    mensaje TEXT NOT NULL,
    elemento_relacionado VARCHAR(100),
    fecha TIMESTAMPTZ NOT NULL DEFAULT now(),
    requiere_accion BOOLEAN NOT NULL DEFAULT FALSE,
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    resuelta BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE informe (                                  -- CU-26
    id_informe BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario BIGINT NOT NULL REFERENCES usuario (id_usuario),               -- solicita
    filtros JSONB,
    formato VARCHAR(5) NOT NULL,
    estado VARCHAR(25) NOT NULL DEFAULT 'PENDIENTE',
    fecha_generacion TIMESTAMPTZ,
    fecha_caducidad TIMESTAMPTZ,                        -- FR-37
    CONSTRAINT ck_informe_formato CHECK (formato IN ('CSV', 'PDF')),
    CONSTRAINT ck_informe_estado CHECK (estado IN ('PENDIENTE', 'PROCESANDO', 'COMPLETADO', 'COMPLETADO_CON_ERRORES')),
    CONSTRAINT ck_informe_caducidad CHECK (fecha_caducidad IS NULL OR fecha_generacion IS NULL
        OR fecha_caducidad > fecha_generacion)
);

CREATE TABLE objetivo_facturacion (                     -- CU-28
    id_objetivo BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_administrador BIGINT NOT NULL REFERENCES usuario (id_usuario),         -- gestiona
    periodo VARCHAR(10) NOT NULL,
    valor NUMERIC(14,2) NOT NULL,
    CONSTRAINT ck_objetivo_valor CHECK (valor >= 0)
);

-- =============================================================================
--  BLOQUE F (parte 2) · Auditoría, acciones masivas y API externa
-- =============================================================================

CREATE TABLE evento_auditoria (                         -- CU-34, NFR-09: solo se inserta
    id_evento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_autor BIGINT REFERENCES usuario (id_usuario),                          -- NULL: Planificador o sistema
    fecha_hora TIMESTAMPTZ NOT NULL DEFAULT now(),
    accion VARCHAR(80) NOT NULL,
    entidad VARCHAR(60) NOT NULL,
    id_entidad BIGINT,
    valores_anteriores JSONB,
    valores_nuevos JSONB,
    id_error VARCHAR(60)                                -- errores técnicos con identificador (NFR-09)
);

CREATE TABLE accion_masiva (                            -- CU-32
    id_accion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_administrador BIGINT NOT NULL REFERENCES usuario (id_usuario),         -- ejecuta
    id_aprobador BIGINT REFERENCES usuario (id_usuario),
    tipo VARCHAR(60) NOT NULL,
    numero_elementos INTEGER NOT NULL,
    alto_impacto BOOLEAN NOT NULL DEFAULT FALSE,
    estado VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE',
    CONSTRAINT ck_am_estado CHECK (estado IN ('PENDIENTE', 'EJECUTADA', 'CANCELADA', 'REVERTIDA')),
    CONSTRAINT ck_am_elementos CHECK (numero_elementos >= 0),
    CONSTRAINT ck_am_separacion CHECK (id_aprobador IS NULL OR id_aprobador <> id_administrador),   -- BR-12
    CONSTRAINT ck_am_alto_impacto CHECK (NOT alto_impacto OR estado NOT IN ('EJECUTADA', 'REVERTIDA') OR id_aprobador IS NOT NULL)
);

CREATE TABLE solicitud_externa (                        -- CU-37, BR-21: nunca modifica datos directamente
    id_solicitud_externa BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente BIGINT NOT NULL REFERENCES cliente (id_cliente),
    sistema_origen VARCHAR(80) NOT NULL,
    tipo VARCHAR(60) NOT NULL,
    datos JSONB NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE_REVISION',
    fecha TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_se_estado CHECK (estado IN ('PENDIENTE_REVISION', 'ACEPTADA', 'RECHAZADA'))
);

-- =============================================================================
--  ÍNDICES
-- =============================================================================

-- Búsqueda y filtros (FR-28, NFR-12)
CREATE INDEX ix_cliente_nombre ON cliente (lower(nombre_comercial));
CREATE INDEX ix_cliente_razon ON cliente (lower(razon_social));
CREATE INDEX ix_cliente_fiscal ON cliente (identificador_fiscal);
CREATE INDEX ix_cliente_sector ON cliente (sector);
CREATE INDEX ix_cliente_responsable ON cliente (id_responsable);
CREATE INDEX ix_contacto_correo ON contacto (lower(correo));
CREATE INDEX ix_factura_cliente ON factura (id_cliente);
CREATE INDEX ix_factura_estado_venc ON factura (estado, fecha_vencimiento);
CREATE INDEX ix_factura_numero ON factura (numero);
CREATE INDEX ix_factura_suscripcion ON factura (id_suscripcion);
CREATE INDEX ix_linea_factura ON linea_factura (id_factura);
CREATE INDEX ix_conciliacion_factura ON conciliacion (id_factura);
CREATE INDEX ix_conciliacion_movimiento ON conciliacion (id_movimiento);
CREATE INDEX ix_movimiento_estado ON movimiento_cobro (estado);
CREATE INDEX ix_comunicacion_factura ON comunicacion (id_factura, fecha_envio);   -- historial (FR-46)
CREATE INDEX ix_comunicacion_cola ON comunicacion (estado) WHERE estado = 'EN_COLA';
CREATE INDEX ix_notificacion_usuario ON notificacion (id_usuario, leida);
CREATE INDEX ix_incidencia_cliente ON incidencia (id_cliente);
CREATE INDEX ix_tarea_cliente ON tarea (id_cliente, estado);
CREATE INDEX ix_auditoria_entidad ON evento_auditoria (entidad, id_entidad);
CREATE INDEX ix_auditoria_fecha ON evento_auditoria (fecha_hora);

-- Reglas de unicidad parcial
-- BR-17 / NFR-15: una sola mensualidad vigente por suscripción y periodo (sin duplicados tras un fallo)
CREATE UNIQUE INDEX ux_factura_recurrente_periodo ON factura (id_suscripcion, periodo_facturado)
    WHERE tipo = 'RECURRENTE' AND estado NOT IN ('ANULADA', 'CANCELADA');
-- Una retención abierta por factura (CU-13)
CREATE UNIQUE INDEX ux_aprobacion_abierta ON aprobacion_factura (id_factura)
    WHERE estado IN ('PENDIENTE', 'PENDIENTE_INFORMACION');
-- Un mismo cobro no se asigna dos veces a la misma factura mientras esté vigente (CU-17)
CREATE UNIQUE INDEX ux_conciliacion_vigente ON conciliacion (id_movimiento, id_factura) WHERE NOT revertida;
-- Una suspensión de recordatorios activa por factura (CU-21)
CREATE UNIQUE INDEX ux_suspension_activa ON suspension_recordatorios (id_factura) WHERE activa;

-- =============================================================================
--  DISPARADORES: reglas que las restricciones declarativas no pueden expresar
-- =============================================================================

-- BR-12: aprobadores, solicitantes de operaciones excepcionales y gestores
-- deben tener rol ADMINISTRADOR o SUPERADMINISTRADOR (la herencia de roles
-- hace que el Superadministrador también cuente como Administrador).
CREATE FUNCTION fn_exigir_rol_admin() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_id  BIGINT;
    v_rol VARCHAR(20);
BEGIN
    v_id := (to_jsonb(NEW) ->> TG_ARGV[0])::BIGINT;
    IF v_id IS NOT NULL THEN
        SELECT rol INTO v_rol FROM usuario WHERE id_usuario = v_id;
        IF v_rol IS NULL OR v_rol NOT IN ('ADMINISTRADOR', 'SUPERADMINISTRADOR') THEN
            RAISE EXCEPTION 'BR-12: % en % debe ser Administrador o Superadministrador (usuario %)',
                TG_ARGV[0], TG_TABLE_NAME, v_id USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER trg_sd_aprobador BEFORE INSERT OR UPDATE ON solicitud_descuento
    FOR EACH ROW EXECUTE FUNCTION fn_exigir_rol_admin('id_aprobador');
CREATE TRIGGER trg_revision_aprobador BEFORE INSERT OR UPDATE ON revision_tarifa_anual
    FOR EACH ROW EXECUTE FUNCTION fn_exigir_rol_admin('id_aprobador');
CREATE TRIGGER trg_af_aprobador BEFORE INSERT OR UPDATE ON aprobacion_factura
    FOR EACH ROW EXECUTE FUNCTION fn_exigir_rol_admin('id_aprobador');
CREATE TRIGGER trg_oe_solicitante BEFORE INSERT OR UPDATE ON operacion_excepcional
    FOR EACH ROW EXECUTE FUNCTION fn_exigir_rol_admin('id_solicitante');
CREATE TRIGGER trg_oe_aprobador BEFORE INSERT OR UPDATE ON operacion_excepcional
    FOR EACH ROW EXECUTE FUNCTION fn_exigir_rol_admin('id_aprobador');
CREATE TRIGGER trg_am_administrador BEFORE INSERT OR UPDATE ON accion_masiva
    FOR EACH ROW EXECUTE FUNCTION fn_exigir_rol_admin('id_administrador');
CREATE TRIGGER trg_am_aprobador BEFORE INSERT OR UPDATE ON accion_masiva
    FOR EACH ROW EXECUTE FUNCTION fn_exigir_rol_admin('id_aprobador');
CREATE TRIGGER trg_objetivo_administrador BEFORE INSERT OR UPDATE ON objetivo_facturacion
    FOR EACH ROW EXECUTE FUNCTION fn_exigir_rol_admin('id_administrador');

-- BR-09: una factura emitida no se modifica ni se borra. Solo cambian estado,
-- saldo pendiente, retención, centro de coste y el PDF (una única vez).
CREATE FUNCTION fn_factura_inmutable() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        IF OLD.fecha_emision IS NOT NULL THEN
            RAISE EXCEPTION 'BR-09: la factura % está emitida y no puede borrarse', OLD.numero
                USING ERRCODE = 'restrict_violation';
        END IF;
        RETURN OLD;
    END IF;

    IF OLD.fecha_emision IS NOT NULL THEN
        IF NEW.id_cliente IS DISTINCT FROM OLD.id_cliente
           OR NEW.id_serie IS DISTINCT FROM OLD.id_serie
           OR NEW.id_suscripcion IS DISTINCT FROM OLD.id_suscripcion
           OR NEW.id_descuento_aplicado IS DISTINCT FROM OLD.id_descuento_aplicado
           OR NEW.id_factura_original IS DISTINCT FROM OLD.id_factura_original
           OR NEW.numero IS DISTINCT FROM OLD.numero
           OR NEW.tipo IS DISTINCT FROM OLD.tipo
           OR NEW.fecha_emision IS DISTINCT FROM OLD.fecha_emision
           OR NEW.fecha_vencimiento IS DISTINCT FROM OLD.fecha_vencimiento
           OR NEW.periodo_facturado IS DISTINCT FROM OLD.periodo_facturado
           OR NEW.moneda IS DISTINCT FROM OLD.moneda
           OR NEW.datos_fiscales_emision IS DISTINCT FROM OLD.datos_fiscales_emision
           OR NEW.base_imponible IS DISTINCT FROM OLD.base_imponible
           OR NEW.total IS DISTINCT FROM OLD.total
           OR NEW.migrada IS DISTINCT FROM OLD.migrada
           OR NEW.motivo_rectificacion IS DISTINCT FROM OLD.motivo_rectificacion
           OR (OLD.documento_pdf IS NOT NULL AND NEW.documento_pdf IS DISTINCT FROM OLD.documento_pdf) THEN
            RAISE EXCEPTION 'BR-09: la factura % está emitida y no puede modificarse; use una rectificativa', OLD.numero
                USING ERRCODE = 'restrict_violation';
        END IF;
        IF NEW.estado = 'BORRADOR' THEN
            RAISE EXCEPTION 'BR-09: una factura emitida no puede volver a BORRADOR'
                USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER trg_factura_inmutable BEFORE UPDATE OR DELETE ON factura
    FOR EACH ROW EXECUTE FUNCTION fn_factura_inmutable();

-- BR-09: las líneas de una factura emitida tampoco cambian.
CREATE FUNCTION fn_linea_factura_bloqueada() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_emitida BOOLEAN;
BEGIN
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        SELECT fecha_emision IS NOT NULL INTO v_emitida FROM factura WHERE id_factura = OLD.id_factura;
        IF COALESCE(v_emitida, FALSE) THEN
            RAISE EXCEPTION 'BR-09: las líneas de la factura % pertenecen a una factura emitida', OLD.id_factura
                USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        SELECT fecha_emision IS NOT NULL INTO v_emitida FROM factura WHERE id_factura = NEW.id_factura;
        IF COALESCE(v_emitida, FALSE) THEN
            RAISE EXCEPTION 'BR-09: no se pueden añadir líneas a la factura % porque está emitida', NEW.id_factura
                USING ERRCODE = 'restrict_violation';
        END IF;
    END IF;
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END $$;

CREATE TRIGGER trg_linea_factura_bloqueada BEFORE INSERT OR UPDATE OR DELETE ON linea_factura
    FOR EACH ROW EXECUTE FUNCTION fn_linea_factura_bloqueada();

-- BR-13: una factura solo pasa a PAGADA / PARCIALMENTE_CONCILIADA si existe un
-- cobro conciliado vigente (salvo las históricas migradas, CU-03).
CREATE FUNCTION fn_factura_pagada_requiere_cobro() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.estado IN ('PAGADA', 'PARCIALMENTE_CONCILIADA') AND NOT NEW.migrada
       AND NOT EXISTS (SELECT 1 FROM conciliacion c
                       WHERE c.id_factura = NEW.id_factura AND NOT c.revertida) THEN
        RAISE EXCEPTION 'BR-13: la factura % no puede pasar a % sin un cobro conciliado', NEW.id_factura, NEW.estado
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER trg_factura_pagada BEFORE INSERT OR UPDATE OF estado ON factura
    FOR EACH ROW EXECUTE FUNCTION fn_factura_pagada_requiere_cobro();

-- NFR-09: el registro de auditoría no es editable (ni se vacía).
CREATE FUNCTION fn_auditoria_solo_insercion() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'NFR-09: el registro de auditoría es de solo inserción'
        USING ERRCODE = 'restrict_violation';
END $$;

CREATE TRIGGER trg_auditoria_fila BEFORE UPDATE OR DELETE ON evento_auditoria
    FOR EACH ROW EXECUTE FUNCTION fn_auditoria_solo_insercion();
CREATE TRIGGER trg_auditoria_truncate BEFORE TRUNCATE ON evento_auditoria
    FOR EACH STATEMENT EXECUTE FUNCTION fn_auditoria_solo_insercion();
