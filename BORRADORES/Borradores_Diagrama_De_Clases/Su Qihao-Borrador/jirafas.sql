-- =====================================================================
--  JIRAFAS - Sistema de facturación de TurbineH
--  Esquema de base de datos para SQLite (DBeaver)
--  Derivado del diagrama de clases (doc/src/requisitos.md)
--
--  Notas:
--   * Enumeraciones -> columnas TEXT con CHECK (SQLite no tiene ENUM).
--   * Identificadores -> TEXT generado con randomblob() (SQLite no tiene UUID).
--   * Jerarquías (Usuario, Factura, Aprobacion, Comunicacion):
--       tabla única con columna discriminadora.
--   * Facturas emitidas inmutables (BR-09) y auditoría no editable (NFR-09)
--       mediante triggers.
--   * Ejecutar como script completo en DBeaver (Alt+X).
--   * Sección 11 (triggers): se ejecutan APARTE, uno a uno, con Ctrl+Enter.
--     DBeaver corta los triggers de SQLite en el primer ';' al usar Alt+X.
--   * Alt+X sobre el archivo entero crea las tablas; en los triggers dará error
--     'incomplete input': pulse Skip all (las tablas ya estarán creadas).
-- =====================================================================

-- Limpieza previa: permite ejecutar el script varias veces (borra las tablas JIRAFAS existentes)
PRAGMA foreign_keys = OFF;
DROP TABLE IF EXISTS solicitud_externa;
DROP TABLE IF EXISTS cliente_api;
DROP TABLE IF EXISTS metrica_rendimiento;
DROP TABLE IF EXISTS tarea_programada;
DROP TABLE IF EXISTS importacion_csv;
DROP TABLE IF EXISTS objetivo_facturacion;
DROP TABLE IF EXISTS informe;
DROP TABLE IF EXISTS adjunto;
DROP TABLE IF EXISTS comentario_mencion;
DROP TABLE IF EXISTS comentario;
DROP TABLE IF EXISTS incidencia;
DROP TABLE IF EXISTS regla_alerta;
DROP TABLE IF EXISTS notificacion;
DROP TABLE IF EXISTS comunicacion;
DROP TABLE IF EXISTS conciliacion;
DROP TABLE IF EXISTS pago;
DROP TABLE IF EXISTS fuente_pago;
DROP TABLE IF EXISTS aprobacion;
DROP TABLE IF EXISTS suspension_recordatorio;
DROP TABLE IF EXISTS linea_factura;
DROP TABLE IF EXISTS factura;
DROP TABLE IF EXISTS pausa_suscripcion;
DROP TABLE IF EXISTS suscripcion;
DROP TABLE IF EXISTS excepcion_comercial;
DROP TABLE IF EXISTS evento_linea_temporal;
DROP TABLE IF EXISTS tarea;
DROP TABLE IF EXISTS cliente_favorito;
DROP TABLE IF EXISTS cliente_usuario_asignado;
DROP TABLE IF EXISTS cliente_etiqueta;
DROP TABLE IF EXISTS etiqueta;
DROP TABLE IF EXISTS cliente_contacto;
DROP TABLE IF EXISTS contacto;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS registro_auditoria;
DROP TABLE IF EXISTS preferencia_notificacion;
DROP TABLE IF EXISTS filtro_guardado;
DROP TABLE IF EXISTS token_recuperacion;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS centro_coste;
DROP TABLE IF EXISTS plantilla_comunicacion;
DROP TABLE IF EXISTS concepto_catalogo;
DROP TABLE IF EXISTS rango_tarifa;
DROP TABLE IF EXISTS impuesto;
DROP TABLE IF EXISTS serie_factura;
DROP TABLE IF EXISTS configuracion_sistema;

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------
-- 2. CONFIGURACIÓN Y CATÁLOGOS (gestionados por el Superadministrador)
-- ---------------------------------------------------------------------
CREATE TABLE configuracion_sistema (               -- singleton
    id                          SMALLINT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    dias_recordatorio_previo    INTEGER NOT NULL DEFAULT 3  CHECK (dias_recordatorio_previo >= 0),
    dias_vencimiento_general    INTEGER NOT NULL DEFAULT 5  CHECK (dias_vencimiento_general >= 0),
    frecuencia_impago_dias      INTEGER NOT NULL DEFAULT 2  CHECK (frecuencia_impago_dias > 0),
    umbral_descuento            NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (umbral_descuento >= 0),
    umbral_importe_alto         NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (umbral_importe_alto >= 0),
    dominio_corporativo         VARCHAR(255) NOT NULL,
    datos_emisor                TEXT NOT NULL DEFAULT '{}',
    retencion_informes_dias     INTEGER NOT NULL DEFAULT 90 CHECK (retencion_informes_dias > 0),
    actualizado_en              TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE serie_factura (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    codigo           VARCHAR(20) NOT NULL UNIQUE,
    prefijo          VARCHAR(20) NOT NULL,
    ultimo_numero    INTEGER NOT NULL DEFAULT 0 CHECK (ultimo_numero >= 0),
    activa           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE impuesto (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    nombre           VARCHAR(80) NOT NULL UNIQUE,
    porcentaje       NUMERIC(5,2) NOT NULL CHECK (porcentaje >= 0),
    activo           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE rango_tarifa (
    id                   TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    desde_facturacion    NUMERIC(14,2) NOT NULL CHECK (desde_facturacion >= 0),
    hasta_facturacion    NUMERIC(14,2),
    precio_mensual       NUMERIC(14,2) NOT NULL CHECK (precio_mensual >= 0),
    vigente_desde        DATE NOT NULL,
    vigente_hasta        DATE,
    CHECK (hasta_facturacion IS NULL OR hasta_facturacion > desde_facturacion),
    CHECK (vigente_hasta IS NULL OR vigente_hasta >= vigente_desde)
);

CREATE TABLE concepto_catalogo (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    nombre           VARCHAR(150) NOT NULL UNIQUE,
    precio_base      NUMERIC(14,2) NOT NULL CHECK (precio_base >= 0),
    activo           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE plantilla_comunicacion (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    tipo             TEXT CHECK (tipo IN ('FACTURA', 'RECORDATORIO_PREVIO', 'VENCIMIENTO', 'IMPAGO', 'DISPUTA_RESUELTA')) NOT NULL,
    idioma           VARCHAR(5) NOT NULL DEFAULT 'es',
    asunto           VARCHAR(255) NOT NULL,
    cuerpo           TEXT NOT NULL,
    version          INTEGER NOT NULL DEFAULT 1 CHECK (version > 0),
    activa           BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (tipo, idioma, version)
);

CREATE TABLE centro_coste (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    nombre           VARCHAR(120) NOT NULL UNIQUE,
    activo           BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------
-- 3. USUARIOS, SEGURIDAD Y AUDITORÍA
-- ---------------------------------------------------------------------
CREATE TABLE usuario (                             -- Usuario <|-- Operativo <|-- Admin <|-- Superadmin
    id                         TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    nombre                     VARCHAR(150) NOT NULL,
    email                      VARCHAR(255) NOT NULL UNIQUE,
    password_hash              VARCHAR(255) NOT NULL,   -- nunca en texto plano (NFR-17)
    rol                        TEXT CHECK (rol IN ('OPERATIVO', 'ADMINISTRADOR', 'SUPERADMINISTRADOR')) NOT NULL DEFAULT 'OPERATIVO',
    puede_invitar_usuarios     BOOLEAN NOT NULL DEFAULT FALSE,
    activo                     BOOLEAN NOT NULL DEFAULT TRUE,  -- se desactiva, no se borra
    doble_factor_activo        BOOLEAN NOT NULL DEFAULT FALSE,
    ultimo_acceso              TEXT,
    creado_en                  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (puede_invitar_usuarios = FALSE OR rol = 'ADMINISTRADOR')
);

CREATE TABLE token_recuperacion (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    usuario_id       TEXT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    hash             VARCHAR(255) NOT NULL UNIQUE,
    expiracion       TEXT NOT NULL,
    usado            BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE filtro_guardado (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    usuario_id       TEXT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    nombre           VARCHAR(100) NOT NULL,
    criterios        TEXT NOT NULL,
    UNIQUE (usuario_id, nombre)
);

CREATE TABLE preferencia_notificacion (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    usuario_id       TEXT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    tipo_evento      VARCHAR(80) NOT NULL,
    en_app           BOOLEAN NOT NULL DEFAULT TRUE,
    por_email        BOOLEAN NOT NULL DEFAULT FALSE,
    resumen_diario   BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (usuario_id, tipo_evento)
);

CREATE TABLE registro_auditoria (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id       TEXT REFERENCES usuario(id) ON DELETE RESTRICT,  -- NULL = sistema
    fecha            TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    accion           VARCHAR(80) NOT NULL,
    entidad          VARCHAR(80) NOT NULL,
    id_entidad       VARCHAR(64),
    valor_anterior   TEXT,
    valor_nuevo      TEXT
);

-- ---------------------------------------------------------------------
-- 4. CLIENTES Y CONTACTOS
-- ---------------------------------------------------------------------
CREATE TABLE cliente (
    id                          TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    nombre_comercial            VARCHAR(200) NOT NULL,
    razon_social                VARCHAR(200) NOT NULL,
    nif                         VARCHAR(40)  NOT NULL,        -- identificador fiscal universal
    domicilio_fiscal            VARCHAR(300) NOT NULL,
    pais                        CHAR(2) NOT NULL,             -- ISO 3166-1
    moneda                      CHAR(3) NOT NULL DEFAULT 'EUR',-- ISO 4217
    sector                      VARCHAR(100),
    idioma                      VARCHAR(5) NOT NULL DEFAULT 'es',
    fecha_inicio                DATE,
    fecha_baja                  DATE,
    estado                      TEXT CHECK (estado IN ('PENDIENTE_ACTIVACION', 'ACTIVO', 'PAUSADO', 'BAJA')) NOT NULL DEFAULT 'PENDIENTE_ACTIVACION',
    tarifa_acordada             NUMERIC(14,2) CHECK (tarifa_acordada >= 0),
    dias_vencimiento_pactado    INTEGER CHECK (dias_vencimiento_pactado >= 0),  -- prevalece (BR-16)
    condiciones_pago            TEXT,
    documento_firmado           VARCHAR(500),
    responsable_id              TEXT NOT NULL REFERENCES usuario(id),
    centro_coste_id             TEXT REFERENCES centro_coste(id),
    creado_en                   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (fecha_baja IS NULL OR fecha_inicio IS NULL OR fecha_baja >= fecha_inicio)
);
-- Duplicados por NIF: se avisa pero no se bloquea ni fusiona (FR-27)
CREATE INDEX idx_cliente_nif ON cliente (pais, nif);

CREATE TABLE contacto (
    id                          TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    nombre                      VARCHAR(150) NOT NULL,
    email                       VARCHAR(255) NOT NULL,
    telefono                    VARCHAR(40),
    idioma                      VARCHAR(5) NOT NULL DEFAULT 'es',
    consentimiento_whatsapp     BOOLEAN NOT NULL DEFAULT FALSE,
    activo                      BOOLEAN NOT NULL DEFAULT TRUE,
    anonimizado                 BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE cliente_contacto (                    -- clase de asociación RolContacto
    cliente_id       TEXT NOT NULL REFERENCES cliente(id)  ON DELETE CASCADE,
    contacto_id      TEXT NOT NULL REFERENCES contacto(id) ON DELETE RESTRICT,
    tipo             TEXT CHECK (tipo IN ('CONTRATACION', 'RECEPCION_FACTURAS', 'IMPAGOS')) NOT NULL,
    PRIMARY KEY (cliente_id, contacto_id, tipo)
);

CREATE TABLE etiqueta (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    nombre           VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE cliente_etiqueta (
    cliente_id       TEXT NOT NULL REFERENCES cliente(id)  ON DELETE CASCADE,
    etiqueta_id      TEXT NOT NULL REFERENCES etiqueta(id) ON DELETE CASCADE,
    PRIMARY KEY (cliente_id, etiqueta_id)
);

CREATE TABLE cliente_usuario_asignado (            -- clientes asignados a usuarios operativos
    cliente_id       TEXT NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    usuario_id       TEXT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    PRIMARY KEY (cliente_id, usuario_id)
);

CREATE TABLE cliente_favorito (
    cliente_id       TEXT NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    usuario_id       TEXT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    PRIMARY KEY (cliente_id, usuario_id)
);

CREATE TABLE tarea (                               -- pertenece al cliente, no al usuario (FR-32)
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    cliente_id       TEXT NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    descripcion      TEXT NOT NULL,
    fecha_limite     DATE,
    completada       BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE evento_linea_temporal (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    cliente_id       TEXT NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    fecha            TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo             VARCHAR(60) NOT NULL,
    descripcion      TEXT
);

CREATE TABLE excepcion_comercial (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    cliente_id       TEXT NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    tipo             TEXT CHECK (tipo IN ('INICIO_FUTURO', 'PRIMER_MES_GRATIS', 'SIN_PRORRATEO')) NOT NULL,
    fecha_inicio     DATE,
    motivo           TEXT NOT NULL
);

-- ---------------------------------------------------------------------
-- 5. SUSCRIPCIONES Y TARIFAS
-- ---------------------------------------------------------------------
CREATE TABLE suscripcion (
    id                TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    cliente_id        TEXT NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    rango_tarifa_id   TEXT NOT NULL REFERENCES rango_tarifa(id),
    fecha_inicio      DATE NOT NULL,
    fecha_fin         DATE,
    importe_mensual   NUMERIC(14,2) NOT NULL CHECK (importe_mensual >= 0),
    estado            TEXT CHECK (estado IN ('ACTIVA', 'PAUSADA', 'BAJA')) NOT NULL DEFAULT 'ACTIVA',
    CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

CREATE TABLE pausa_suscripcion (
    id                            TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    suscripcion_id                TEXT NOT NULL REFERENCES suscripcion(id) ON DELETE CASCADE,
    motivo                        TEXT NOT NULL,
    fecha_inicio                  DATE NOT NULL,
    fecha_prevista_reactivacion   DATE,
    CHECK (fecha_prevista_reactivacion IS NULL OR fecha_prevista_reactivacion >= fecha_inicio)
);

-- ---------------------------------------------------------------------
-- 6. FACTURACIÓN
-- ---------------------------------------------------------------------
CREATE TABLE factura (                             -- Factura <|-- Puntual / Recurrente / Rectificativa
    id                      TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    tipo                    TEXT CHECK (tipo IN ('PUNTUAL', 'RECURRENTE', 'RECTIFICATIVA')) NOT NULL,
    cliente_id              TEXT NOT NULL REFERENCES cliente(id),
    serie_id                TEXT NOT NULL REFERENCES serie_factura(id),
    numero                  INTEGER,                      -- NULL mientras es borrador
    fecha_emision           DATE,
    fecha_vencimiento       DATE,
    estado                  TEXT CHECK (estado IN ('BORRADOR', 'APROBADA', 'RETENIDA', 'EMITIDA', 'ENVIADA', 'VENCIDA', 'PAGADA', 'PARCIALMENTE_CONCILIADA', 'ANULADA', 'RECTIFICADA', 'INCOBRABLE')) NOT NULL DEFAULT 'BORRADOR',
    moneda                  CHAR(3) NOT NULL DEFAULT 'EUR',   -- se conserva la original (RB-02)
    base_imponible          NUMERIC(14,2) NOT NULL DEFAULT 0,
    total_impuestos         NUMERIC(14,2) NOT NULL DEFAULT 0,
    total                   NUMERIC(14,2) NOT NULL DEFAULT 0,
    migrada                 BOOLEAN NOT NULL DEFAULT FALSE,
    pdf                     BLOB,                        -- FR-12
    centro_coste_id         TEXT REFERENCES centro_coste(id),
    creada_por              TEXT NOT NULL REFERENCES usuario(id),
    creada_en               TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- FacturaRecurrente
    suscripcion_id          TEXT REFERENCES suscripcion(id),
    periodo                 CHAR(7),                      -- 'YYYY-MM'
    prorrateada             BOOLEAN,
    -- FacturaRectificativa
    factura_rectificada_id  TEXT REFERENCES factura(id),
    motivo_rectificacion    TEXT,
    -- Numeración única por serie (BR-10), no consume número si no se emite
    UNIQUE (serie_id, numero),
    CHECK (fecha_vencimiento IS NULL OR fecha_emision IS NULL OR fecha_vencimiento >= fecha_emision),
    CHECK (ABS(total - (base_imponible + total_impuestos)) < 0.005),
    -- Coherencia de los subtipos
    CHECK (tipo <> 'RECURRENTE'
           OR (suscripcion_id IS NOT NULL AND periodo GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]')),
    CHECK (tipo <> 'RECTIFICATIVA'
           OR (factura_rectificada_id IS NOT NULL AND motivo_rectificacion IS NOT NULL)),
    CHECK (tipo = 'RECURRENTE'    OR (suscripcion_id IS NULL AND periodo IS NULL AND prorrateada IS NULL)),
    CHECK (tipo = 'RECTIFICATIVA' OR (factura_rectificada_id IS NULL AND motivo_rectificacion IS NULL))
);
-- Una única factura recurrente por suscripción y periodo: evita duplicados al reintentar (NFR-15)
CREATE UNIQUE INDEX uq_factura_recurrente_periodo
    ON factura (suscripcion_id, periodo) WHERE tipo = 'RECURRENTE';
CREATE INDEX idx_factura_cliente_estado ON factura (cliente_id, estado);
CREATE INDEX idx_factura_vencimiento    ON factura (fecha_vencimiento) WHERE estado IN ('ENVIADA','VENCIDA');

CREATE TABLE linea_factura (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    factura_id       TEXT NOT NULL REFERENCES factura(id) ON DELETE CASCADE,
    concepto_id      TEXT REFERENCES concepto_catalogo(id),
    impuesto_id      TEXT NOT NULL REFERENCES impuesto(id),
    concepto         VARCHAR(255) NOT NULL,                -- copia: no cambia si cambia el catálogo (BR-11)
    cantidad         NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(14,4) NOT NULL,
    descuento        NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    porcentaje_impuesto NUMERIC(5,2) NOT NULL              -- copia histórica del % aplicado
);

CREATE TABLE suspension_recordatorio (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    factura_id       TEXT NOT NULL REFERENCES factura(id) ON DELETE CASCADE,
    motivo           TEXT NOT NULL,
    fecha_revision   DATE NOT NULL,
    activa           BOOLEAN NOT NULL DEFAULT TRUE
);

-- Aprobaciones: Aprobacion <|-- SolicitudDescuento / RevisionTarifa / RetencionFactura
CREATE TABLE aprobacion (
    id                           TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    tipo                         TEXT CHECK (tipo IN ('DESCUENTO', 'REVISION_TARIFA', 'RETENCION_FACTURA')) NOT NULL,
    estado                       TEXT CHECK (estado IN ('PENDIENTE', 'APROBADA', 'RECHAZADA')) NOT NULL DEFAULT 'PENDIENTE',
    motivo_pendiente             TEXT NOT NULL,               -- siempre se explica (FR-18)
    solicitada_por               TEXT NOT NULL REFERENCES usuario(id),
    resuelta_por                 TEXT REFERENCES usuario(id),
    fecha_solicitud              TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion             TEXT,
    -- SolicitudDescuento
    cliente_id                   TEXT REFERENCES cliente(id),
    porcentaje                   NUMERIC(5,2) CHECK (porcentaje BETWEEN 0 AND 100),
    importe                      NUMERIC(14,2) CHECK (importe >= 0),
    -- RevisionTarifa
    facturacion_anual_verificada NUMERIC(14,2),
    rango_propuesto_id           TEXT REFERENCES rango_tarifa(id),
    precio_anterior              NUMERIC(14,2),
    precio_nuevo                 NUMERIC(14,2),
    -- RetencionFactura
    factura_id                   TEXT REFERENCES factura(id),
    causa                        TEXT CHECK (causa IN ('IMPORTE_MODIFICADO', 'DESCUENTO_EXTRAORDINARIO', 'VENCIMIENTO_ATIPICO', 'IMPORTE_ELEVADO')),
    -- Reglas generales
    CHECK (resuelta_por IS NULL OR resuelta_por <> solicitada_por),        -- BR-12
    CHECK ((estado = 'PENDIENTE') = (resuelta_por IS NULL)),
    CHECK (tipo <> 'DESCUENTO'         OR (cliente_id IS NOT NULL AND (porcentaje IS NOT NULL OR importe IS NOT NULL))),
    CHECK (tipo <> 'REVISION_TARIFA'   OR (cliente_id IS NOT NULL AND facturacion_anual_verificada IS NOT NULL
                                           AND rango_propuesto_id IS NOT NULL)),
    CHECK (tipo <> 'RETENCION_FACTURA' OR (factura_id IS NOT NULL AND causa IS NOT NULL))
);
CREATE INDEX idx_aprobacion_pendiente ON aprobacion (tipo) WHERE estado = 'PENDIENTE';

-- ---------------------------------------------------------------------
-- 7. COBROS Y CONCILIACIÓN
-- ---------------------------------------------------------------------
CREATE TABLE fuente_pago (                         -- implementaciones de la interfaz FuentePago
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    tipo             TEXT CHECK (tipo IN ('STRIPE', 'REVOLUT', 'CSV')) NOT NULL,
    nombre           VARCHAR(80) NOT NULL UNIQUE,
    activa           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE pago (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    fuente_id        TEXT NOT NULL REFERENCES fuente_pago(id),
    id_externo       VARCHAR(120) NOT NULL,
    importe          NUMERIC(14,2) NOT NULL CHECK (importe > 0),
    moneda           CHAR(3) NOT NULL,
    fecha            DATE NOT NULL,
    concepto         VARCHAR(255),
    referencia       VARCHAR(120),
    estado           TEXT CHECK (estado IN ('PENDIENTE', 'CONCILIADO', 'PARCIAL', 'REVERTIDO')) NOT NULL DEFAULT 'PENDIENTE',
    UNIQUE (fuente_id, id_externo)                     -- evento duplicado no cuenta dos veces (FR-15)
);

CREATE TABLE conciliacion (
    id                TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    pago_id           TEXT NOT NULL REFERENCES pago(id),
    factura_id        TEXT NOT NULL REFERENCES factura(id),
    fecha             TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    importe_aplicado  NUMERIC(14,2) NOT NULL CHECK (importe_aplicado > 0),
    origen            TEXT CHECK (origen IN ('AUTOMATICA', 'MANUAL')) NOT NULL,
    regla_aplicada    VARCHAR(120),
    realizada_por     TEXT REFERENCES usuario(id),     -- NULL si fue automática
    revertida         BOOLEAN NOT NULL DEFAULT FALSE,  -- no se borra, se revierte (FR-22)
    revertida_por     TEXT REFERENCES usuario(id),
    fecha_reversion   TEXT,
    motivo_reversion  TEXT,
    CHECK (origen = 'MANUAL' OR regla_aplicada IS NOT NULL),
    CHECK (revertida = (fecha_reversion IS NOT NULL)),
    CHECK (NOT revertida OR (revertida_por IS NOT NULL AND motivo_reversion IS NOT NULL))
);
CREATE INDEX idx_conciliacion_factura ON conciliacion (factura_id) WHERE revertida = 0;

-- ---------------------------------------------------------------------
-- 8. COMUNICACIONES, NOTIFICACIONES Y ALERTAS
-- ---------------------------------------------------------------------
CREATE TABLE comunicacion (                        -- Comunicacion <|-- EnvioFactura / Recordatorio
    id                 TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    tipo               TEXT CHECK (tipo IN ('ENVIO_FACTURA', 'RECORDATORIO')) NOT NULL,
    factura_id         TEXT NOT NULL REFERENCES factura(id),
    contacto_id        TEXT NOT NULL REFERENCES contacto(id),   -- se conserva el destinatario real
    plantilla_id       TEXT NOT NULL REFERENCES plantilla_comunicacion(id),
    canal              TEXT CHECK (canal IN ('EMAIL', 'WHATSAPP')) NOT NULL DEFAULT 'EMAIL',
    intento            INTEGER NOT NULL DEFAULT 1 CHECK (intento >= 1),
    resultado          TEXT CHECK (resultado IN ('PENDIENTE', 'ENVIADO', 'REBOTADO', 'FALLIDO')) NOT NULL DEFAULT 'PENDIENTE',
    fecha              TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Recordatorio
    tipo_recordatorio  TEXT CHECK (tipo_recordatorio IN ('PREVIO', 'VENCIMIENTO', 'IMPAGO')),
    fecha_programada   DATE,
    CHECK (tipo <> 'RECORDATORIO' OR tipo_recordatorio IS NOT NULL),
    CHECK (tipo =  'RECORDATORIO' OR (tipo_recordatorio IS NULL AND fecha_programada IS NULL))
);
CREATE INDEX idx_comunicacion_factura ON comunicacion (factura_id);

CREATE TABLE notificacion (
    id                TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    usuario_id        TEXT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    tipo              VARCHAR(80) NOT NULL,
    mensaje           TEXT NOT NULL,
    fecha             TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    leida             BOOLEAN NOT NULL DEFAULT FALSE,
    requiere_accion   BOOLEAN NOT NULL DEFAULT FALSE,
    resuelta          BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (NOT resuelta OR requiere_accion)
);
CREATE INDEX idx_notificacion_usuario ON notificacion (usuario_id, leida);

CREATE TABLE regla_alerta (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    administrador_id TEXT NOT NULL REFERENCES usuario(id),
    tipo             TEXT CHECK (tipo IN ('DIAS_VENCIDA', 'IMPORTE_PENDIENTE_CLIENTE')) NOT NULL,
    parametro        NUMERIC(14,2) NOT NULL CHECK (parametro > 0),
    activa           BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------
-- 9. INCIDENCIAS Y COMENTARIOS
-- ---------------------------------------------------------------------
CREATE TABLE incidencia (
    id                   TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    cliente_id           TEXT NOT NULL REFERENCES cliente(id),
    factura_id           TEXT REFERENCES factura(id),
    comunicacion_id      TEXT UNIQUE REFERENCES comunicacion(id),  -- rebote que la originó
    responsable_id       TEXT NOT NULL REFERENCES usuario(id),
    titulo               VARCHAR(200) NOT NULL,
    tipo                 TEXT CHECK (tipo IN ('ENTREGA', 'IMPAGO', 'COBRO', 'FACTURACION', 'OTRA')) NOT NULL,
    estado               TEXT CHECK (estado IN ('ABIERTA', 'EN_CURSO', 'RESUELTA', 'CERRADA')) NOT NULL DEFAULT 'ABIERTA',
    prioridad            TEXT CHECK (prioridad IN ('BAJA', 'MEDIA', 'ALTA', 'CRITICA')) NOT NULL DEFAULT 'MEDIA',
    fecha_apertura       TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comentario (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    incidencia_id    TEXT NOT NULL REFERENCES incidencia(id) ON DELETE CASCADE,
    autor_id         TEXT NOT NULL REFERENCES usuario(id),
    texto            TEXT NOT NULL,
    fecha            TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    interno          BOOLEAN NOT NULL DEFAULT TRUE CHECK (interno = 1)   -- nunca se envían al cliente (BR-20)
);

CREATE TABLE comentario_mencion (
    comentario_id    TEXT NOT NULL REFERENCES comentario(id) ON DELETE CASCADE,
    usuario_id       TEXT NOT NULL REFERENCES usuario(id),
    PRIMARY KEY (comentario_id, usuario_id)
);

CREATE TABLE adjunto (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    incidencia_id    TEXT NOT NULL REFERENCES incidencia(id) ON DELETE CASCADE,
    nombre           VARCHAR(255) NOT NULL,
    ruta             VARCHAR(500) NOT NULL,
    tamano           BIGINT NOT NULL CHECK (tamano >= 0)
);

-- ---------------------------------------------------------------------
-- 10. INFORMES, OBJETIVOS, IMPORTACIÓN, TAREAS PROGRAMADAS Y API
-- ---------------------------------------------------------------------
CREATE TABLE informe (
    id                TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    usuario_id        TEXT NOT NULL REFERENCES usuario(id),
    tipo              VARCHAR(80) NOT NULL,
    filtros           TEXT NOT NULL DEFAULT '{}',
    formato           TEXT CHECK (formato IN ('CSV', 'PDF')) NOT NULL,
    fecha_generacion  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_caducidad   TEXT
);

CREATE TABLE objetivo_facturacion (
    id                TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    administrador_id  TEXT NOT NULL REFERENCES usuario(id),
    centro_coste_id   TEXT REFERENCES centro_coste(id),
    periodo           CHAR(7) NOT NULL,                -- 'YYYY-MM'
    importe           NUMERIC(14,2) NOT NULL CHECK (importe >= 0),
    UNIQUE (periodo, centro_coste_id)
    -- Los cambios quedan en registro_auditoria (FR-41)
);

CREATE TABLE importacion_csv (
    id                TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    usuario_id        TEXT NOT NULL REFERENCES usuario(id),
    fecha             TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    archivo           VARCHAR(255) NOT NULL,
    creados           INTEGER NOT NULL DEFAULT 0,
    actualizados      INTEGER NOT NULL DEFAULT 0,
    rechazados        INTEGER NOT NULL DEFAULT 0,
    motivos_rechazo   TEXT
);

CREATE TABLE tarea_programada (
    id                TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    nombre            VARCHAR(100) NOT NULL UNIQUE,
    ultima_ejecucion  TEXT,
    estado            VARCHAR(30) NOT NULL DEFAULT 'PENDIENTE',
    errores           INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE metrica_rendimiento (                 -- agregada: sin identificar usuarios (BR-08)
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    tarea_programada_id TEXT NOT NULL REFERENCES tarea_programada(id) ON DELETE CASCADE,
    nombre              VARCHAR(80) NOT NULL,
    valor               NUMERIC(14,3) NOT NULL,
    fecha               TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cliente_api (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    client_id        VARCHAR(80) NOT NULL UNIQUE,
    secret_hash      VARCHAR(255) NOT NULL,
    alcance          VARCHAR(255) NOT NULL,
    activo           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE solicitud_externa (
    id               TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    cliente_api_id   TEXT NOT NULL REFERENCES cliente_api(id) ON DELETE CASCADE,
    cliente_id       TEXT NOT NULL REFERENCES cliente(id),
    tipo             VARCHAR(60) NOT NULL,             -- p. ej. SOLICITUD_BAJA (no modifica directamente)
    estado           VARCHAR(30) NOT NULL DEFAULT 'PENDIENTE',
    fecha            TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);