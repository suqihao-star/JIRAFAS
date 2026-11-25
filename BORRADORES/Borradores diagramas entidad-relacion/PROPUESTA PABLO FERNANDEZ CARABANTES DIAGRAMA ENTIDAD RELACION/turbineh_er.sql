
-- USUARIO · Bloque F · origen: Usuario + UsuarioOperativo + Administrador + Superadministrador (herencia → una tabla)
CREATE TABLE usuario (
    id_usuario                     NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    nombre                         VARCHAR2(100 CHAR),
    correo_corporativo             VARCHAR2(150 CHAR) NOT NULL,
    hash_contrasena                VARCHAR2(255 CHAR),
    rol                            VARCHAR2(15 CHAR) NOT NULL,
    estado                         VARCHAR2(15 CHAR) DEFAULT 'INVITADO' NOT NULL,
    doble_factor_activo            NUMBER(1) DEFAULT 0 NOT NULL,
    intentos_fallidos              NUMBER(10) DEFAULT 0 NOT NULL,
    bloqueado_hasta                TIMESTAMP,
    preferencias_notificacion      CLOB,
    puede_gestionar_usuarios       NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo_corporativo UNIQUE (correo_corporativo),
    CONSTRAINT ck_usuario_rol CHECK (rol IN ('OPERATIVO', 'ADMIN', 'SUPERADMIN')),
    CONSTRAINT ck_usuario_estado CHECK (estado IN ('INVITADO', 'ACTIVO', 'BLOQUEADO', 'DESACTIVADO')),
    CONSTRAINT ck_usuario_doble_factor_activo CHECK (doble_factor_activo IN (0, 1)),
    CONSTRAINT ck_usuario_puede_gestionar_001 CHECK (puede_gestionar_usuarios IN (0, 1)),
    CONSTRAINT ck_usuario_permiso_rol CHECK (rol = 'ADMIN' OR puede_gestionar_usuarios = 0),
    CONSTRAINT ck_usuario_activacion CHECK (estado = 'INVITADO' OR hash_contrasena IS NOT NULL)
);

-- EVENTO_AUDITORIA · Bloque F · origen: EventoAuditoria
CREATE TABLE evento_auditoria (
    id_evento                      NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_usuario                     NUMBER(10),
    fecha_hora                     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    accion                         VARCHAR2(60 CHAR) NOT NULL,
    entidad                        VARCHAR2(40 CHAR) NOT NULL,
    id_entidad                     NUMBER(10),
    valores_anteriores             CLOB,
    valores_nuevos                 CLOB,
    id_error                       VARCHAR2(40 CHAR),
    CONSTRAINT pk_evento_auditoria PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_auditoria_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

-- ACCION_MASIVA · Bloque F · origen: AccionMasiva
CREATE TABLE accion_masiva (
    id_accion                      NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_ejecutor                    NUMBER(10) NOT NULL,
    id_aprobador                   NUMBER(10),
    tipo                           VARCHAR2(40 CHAR) NOT NULL,
    numero_elementos               NUMBER(10) NOT NULL,
    alto_impacto                   NUMBER(1) DEFAULT 0 NOT NULL,
    estado                         VARCHAR2(15 CHAR) DEFAULT 'PENDIENTE' NOT NULL,
    CONSTRAINT pk_accion_masiva PRIMARY KEY (id_accion),
    CONSTRAINT fk_accion_masiva_id_ejecutor FOREIGN KEY (id_ejecutor) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_accion_masiva_id_aprobador FOREIGN KEY (id_aprobador) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_accion_masiva_alto_impacto CHECK (alto_impacto IN (0, 1)),
    CONSTRAINT ck_accion_masiva_estado CHECK (estado IN ('PENDIENTE', 'EJECUTADA', 'CANCELADA', 'REVERTIDA')),
    CONSTRAINT ck_accion_aprobador CHECK (id_aprobador IS NULL OR id_aprobador <> id_ejecutor),
    CONSTRAINT ck_accion_alto_impacto CHECK (alto_impacto = 0 OR estado <> 'EJECUTADA' OR id_aprobador IS NOT NULL)
);

-- EJECUCION_TAREA · Bloque F · origen: EjecucionTarea
CREATE TABLE ejecucion_tarea (
    id_ejecucion                   NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    tipo                           VARCHAR2(30 CHAR) NOT NULL,
    inicio                         TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    fin                            TIMESTAMP,
    estado                         VARCHAR2(30 CHAR) DEFAULT 'EN_CURSO' NOT NULL,
    resumen                        VARCHAR2(1000 CHAR),
    errores                        CLOB,
    CONSTRAINT pk_ejecucion_tarea PRIMARY KEY (id_ejecucion),
    CONSTRAINT ck_ejecucion_tarea_tipo CHECK (tipo IN ('GENERACION_RECURRENTE', 'RECORDATORIOS', 'CONSULTA_PAGOS', 'RESUMEN_DIARIO', 'COPIA_SEGURIDAD')),
    CONSTRAINT ck_ejecucion_tarea_estado CHECK (estado IN ('EN_CURSO', 'COMPLETADA', 'COMPLETADA_CON_ERRORES', 'INTERRUMPIDA')),
    CONSTRAINT ck_ejecucion_fechas CHECK (fin IS NULL OR fin >= inicio)
);

-- CONFIGURACION_SISTEMA · Bloque F · origen: ConfiguracionSistema
CREATE TABLE configuracion_sistema (
    id_configuracion               NUMBER(10) DEFAULT 1,
    datos_emisor                   VARCHAR2(1000 CHAR),
    umbral_descuento               NUMBER(15,2) NOT NULL,
    umbral_importe_alto            NUMBER(15,2) NOT NULL,
    vencimiento_general_dias       NUMBER(10) NOT NULL,
    dias_recordatorio_previo       NUMBER(10) DEFAULT 3 NOT NULL,
    dias_recordatorio_vencimiento  NUMBER(10) DEFAULT 5 NOT NULL,
    frecuencia_aviso_impago_dias   NUMBER(10) DEFAULT 2 NOT NULL,
    funciones_inteligentes_activas NUMBER(1) DEFAULT 0 NOT NULL,
    dominio_corporativo            VARCHAR2(100 CHAR) NOT NULL,
    dias_conservacion_informes     NUMBER(10),
    CONSTRAINT pk_configuracion_sistema PRIMARY KEY (id_configuracion),
    CONSTRAINT ck_configuracion_sistema_fu001 CHECK (funciones_inteligentes_activas IN (0, 1)),
    CONSTRAINT ck_config_unica CHECK (id_configuracion = 1)
);

-- SERIE_FACTURACION · Bloque F · origen: SerieFacturacion
CREATE TABLE serie_facturacion (
    id_serie                       NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    codigo                         VARCHAR2(10 CHAR) NOT NULL,
    prefijo                        VARCHAR2(10 CHAR),
    ultimo_numero                  NUMBER(10) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_serie_facturacion PRIMARY KEY (id_serie),
    CONSTRAINT uq_serie_facturacion_codigo UNIQUE (codigo),
    CONSTRAINT ck_serie_numero CHECK (ultimo_numero >= 0)
);

-- IMPUESTO · Bloque F · origen: Impuesto
CREATE TABLE impuesto (
    id_impuesto                    NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    nombre                         VARCHAR2(60 CHAR) NOT NULL,
    porcentaje                     NUMBER(5,2) NOT NULL,
    CONSTRAINT pk_impuesto PRIMARY KEY (id_impuesto),
    CONSTRAINT uq_impuesto_nombre UNIQUE (nombre),
    CONSTRAINT ck_impuesto_pct CHECK (porcentaje BETWEEN 0 AND 100)
);

-- RANGO_TARIFA · Bloque F · origen: RangoTarifa
CREATE TABLE rango_tarifa (
    id_rango                       NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    facturacion_minima             NUMBER(15,2) NOT NULL,
    facturacion_maxima             NUMBER(15,2),
    precio                         NUMBER(15,2) NOT NULL,
    fecha_efecto                   DATE NOT NULL,
    CONSTRAINT pk_rango_tarifa PRIMARY KEY (id_rango),
    CONSTRAINT ck_rango_limites CHECK (facturacion_maxima IS NULL OR facturacion_maxima >= facturacion_minima)
);

-- CENTRO_COSTE · Bloque E · origen: CentroCoste
CREATE TABLE centro_coste (
    id_centro_coste                NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    nombre                         VARCHAR2(100 CHAR) NOT NULL,
    tipo                           VARCHAR2(15 CHAR) NOT NULL,
    activo                         NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT pk_centro_coste PRIMARY KEY (id_centro_coste),
    CONSTRAINT uq_centro_coste_nombre UNIQUE (nombre),
    CONSTRAINT ck_centro_coste_tipo CHECK (tipo IN ('CENTRO_COSTE', 'PROYECTO')),
    CONSTRAINT ck_centro_coste_activo CHECK (activo IN (0, 1))
);

-- IMPORTACION_CSV · Bloque A · origen: ImportacionCSV
CREATE TABLE importacion_csv (
    id_importacion                 NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_usuario                     NUMBER(10) NOT NULL,
    nombre_archivo                 VARCHAR2(200 CHAR) NOT NULL,
    fecha                          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    incluye_facturas_historicas    NUMBER(1) DEFAULT 0 NOT NULL,
    estado                         VARCHAR2(15 CHAR) DEFAULT 'PREVISUALIZADA' NOT NULL,
    creados                        NUMBER(10) DEFAULT 0 NOT NULL,
    actualizados                   NUMBER(10) DEFAULT 0 NOT NULL,
    rechazados                     NUMBER(10) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_importacion_csv PRIMARY KEY (id_importacion),
    CONSTRAINT fk_importacion_csv_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_importacion_csv_incluye_001 CHECK (incluye_facturas_historicas IN (0, 1)),
    CONSTRAINT ck_importacion_csv_estado CHECK (estado IN ('PREVISUALIZADA', 'CONFIRMADA', 'CANCELADA'))
);

-- CLIENTE · Bloque A · origen: Cliente
CREATE TABLE cliente (
    id_cliente                     NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_responsable                 NUMBER(10) NOT NULL,
    id_centro_coste                NUMBER(10),
    id_importacion                 NUMBER(10),
    nombre_comercial               VARCHAR2(150 CHAR) NOT NULL,
    razon_social                   VARCHAR2(200 CHAR) NOT NULL,
    identificador_fiscal           VARCHAR2(30 CHAR),
    domicilio_fiscal               VARCHAR2(300 CHAR),
    pais                           CHAR(2) NOT NULL,
    moneda                         CHAR(3) NOT NULL,
    sector                         VARCHAR2(80 CHAR),
    ubicacion                      VARCHAR2(100 CHAR),
    idioma                         VARCHAR2(5 CHAR) DEFAULT 'es',
    estado                         VARCHAR2(25 CHAR) DEFAULT 'ACTIVO' NOT NULL,
    datos_fiscales_incompletos     NUMBER(1) DEFAULT 0 NOT NULL,
    fecha_inicio                   DATE NOT NULL,
    condiciones_pago               VARCHAR2(300 CHAR),
    documento_firmado              VARCHAR2(300 CHAR),
    vencimiento_pactado_dias       NUMBER(10),
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT fk_cliente_id_responsable FOREIGN KEY (id_responsable) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_cliente_id_centro_coste FOREIGN KEY (id_centro_coste) REFERENCES centro_coste (id_centro_coste),
    CONSTRAINT fk_cliente_id_importacion FOREIGN KEY (id_importacion) REFERENCES importacion_csv (id_importacion),
    CONSTRAINT ck_cliente_estado CHECK (estado IN ('ACTIVO', 'PENDIENTE_ACTIVACION', 'BAJA')),
    CONSTRAINT ck_cliente_datos_fiscales_i001 CHECK (datos_fiscales_incompletos IN (0, 1))
);

-- SOLICITUD_EXTERNA · Bloque F · origen: SolicitudExterna
CREATE TABLE solicitud_externa (
    id_solicitud_externa           NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_cliente                     NUMBER(10) NOT NULL,
    sistema_origen                 VARCHAR2(80 CHAR) NOT NULL,
    tipo                           VARCHAR2(30 CHAR) NOT NULL,
    datos                          CLOB,
    estado                         VARCHAR2(20 CHAR) DEFAULT 'PENDIENTE_REVISION' NOT NULL,
    fecha                          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_solicitud_externa PRIMARY KEY (id_solicitud_externa),
    CONSTRAINT fk_solicitud_externa_id_cli001 FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT ck_solicitud_externa_estado CHECK (estado IN ('PENDIENTE_REVISION', 'ACEPTADA', 'RECHAZADA'))
);

-- CONTACTO · Bloque A · origen: Contacto
CREATE TABLE contacto (
    id_contacto                    NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    nombre                         VARCHAR2(150 CHAR) NOT NULL,
    correo                         VARCHAR2(150 CHAR),
    idioma                         VARCHAR2(5 CHAR),
    consentimiento_whatsapp        NUMBER(1) DEFAULT 0 NOT NULL,
    activo                         NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT pk_contacto PRIMARY KEY (id_contacto),
    CONSTRAINT ck_contacto_consentimiento_001 CHECK (consentimiento_whatsapp IN (0, 1)),
    CONSTRAINT ck_contacto_activo CHECK (activo IN (0, 1))
);

-- CLIENTE_CONTACTO · Bloque A · origen: ClienteContacto (clase asociación)
CREATE TABLE cliente_contacto (
    id_cliente                     NUMBER(10),
    id_contacto                    NUMBER(10),
    tipo                           VARCHAR2(15 CHAR) NOT NULL,
    CONSTRAINT pk_cliente_contacto PRIMARY KEY (id_cliente, id_contacto),
    CONSTRAINT fk_cliente_contacto_id_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_cliente_contacto_id_cont001 FOREIGN KEY (id_contacto) REFERENCES contacto (id_contacto),
    CONSTRAINT ck_cliente_contacto_tipo CHECK (tipo IN ('CONTRATACION', 'FACTURACION', 'IMPAGOS'))
);

-- ETIQUETA · Bloque A · origen: Cliente.etiquetas (List<String>)
CREATE TABLE etiqueta (
    id_etiqueta                    NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    nombre                         VARCHAR2(50 CHAR) NOT NULL,
    CONSTRAINT pk_etiqueta PRIMARY KEY (id_etiqueta),
    CONSTRAINT uq_etiqueta_nombre UNIQUE (nombre)
);

-- CLIENTE_ETIQUETA · Bloque A · origen: Cliente.etiquetas (List<String>)
CREATE TABLE cliente_etiqueta (
    id_cliente                     NUMBER(10),
    id_etiqueta                    NUMBER(10),
    CONSTRAINT pk_cliente_etiqueta PRIMARY KEY (id_cliente, id_etiqueta),
    CONSTRAINT fk_cliente_etiqueta_id_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_cliente_etiqueta_id_etiq001 FOREIGN KEY (id_etiqueta) REFERENCES etiqueta (id_etiqueta)
);

-- FAVORITO · Bloque A · origen: Asociación Usuario–Cliente «favoritos»
CREATE TABLE favorito (
    id_usuario                     NUMBER(10),
    id_cliente                     NUMBER(10),
    CONSTRAINT pk_favorito PRIMARY KEY (id_usuario, id_cliente),
    CONSTRAINT fk_favorito_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_favorito_id_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
);

-- TAREA · Bloque A · origen: Tarea
CREATE TABLE tarea (
    id_tarea                       NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_cliente                     NUMBER(10) NOT NULL,
    id_completada_por              NUMBER(10),
    descripcion                    VARCHAR2(500 CHAR) NOT NULL,
    fecha_prevista                 DATE,
    estado                         VARCHAR2(15 CHAR) DEFAULT 'PENDIENTE' NOT NULL,
    fecha_completada               TIMESTAMP,
    CONSTRAINT pk_tarea PRIMARY KEY (id_tarea),
    CONSTRAINT fk_tarea_id_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_tarea_id_completada_por FOREIGN KEY (id_completada_por) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_tarea_estado CHECK (estado IN ('PENDIENTE', 'COMPLETADA')),
    CONSTRAINT ck_tarea_completada CHECK ((estado = 'COMPLETADA' AND id_completada_por IS NOT NULL AND fecha_completada IS NOT NULL) OR (estado = 'PENDIENTE' AND fecha_completada IS NULL))
);

-- SUSCRIPCION · Bloque B · origen: Suscripcion
CREATE TABLE suscripcion (
    id_suscripcion                 NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_cliente                     NUMBER(10) NOT NULL,
    plan                           VARCHAR2(100 CHAR) NOT NULL,
    precio_vigente                 NUMBER(15,2) NOT NULL,
    fecha_inicio                   DATE NOT NULL,
    estado                         VARCHAR2(25 CHAR) DEFAULT 'ACTIVA' NOT NULL,
    motivo_pausa                   VARCHAR2(300 CHAR),
    fecha_inicio_pausa             DATE,
    fecha_reactivacion_prevista    DATE,
    fecha_baja                     DATE,
    motivo_baja                    VARCHAR2(300 CHAR),
    CONSTRAINT pk_suscripcion PRIMARY KEY (id_suscripcion),
    CONSTRAINT fk_suscripcion_id_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT ck_suscripcion_estado CHECK (estado IN ('PENDIENTE_ACTIVACION', 'ACTIVA', 'EN_PAUSA', 'CANCELADA')),
    CONSTRAINT ck_susc_pausa CHECK (estado <> 'EN_PAUSA' OR (motivo_pausa IS NOT NULL AND fecha_inicio_pausa IS NOT NULL)),
    CONSTRAINT ck_susc_baja CHECK (estado <> 'CANCELADA' OR (fecha_baja IS NOT NULL AND motivo_baja IS NOT NULL)),
    CONSTRAINT ck_susc_fechas CHECK (fecha_baja IS NULL OR fecha_baja >= fecha_inicio)
);

-- SOLICITUD_DESCUENTO · Bloque B · origen: SolicitudDescuento
CREATE TABLE solicitud_descuento (
    id_solicitud                   NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_cliente                     NUMBER(10) NOT NULL,
    id_suscripcion                 NUMBER(10),
    id_solicitante                 NUMBER(10) NOT NULL,
    id_aprobador                   NUMBER(10),
    tipo                           VARCHAR2(15 CHAR) NOT NULL,
    valor                          NUMBER(15,2) NOT NULL,
    motivo                         VARCHAR2(300 CHAR) NOT NULL,
    fecha_vigencia                 DATE,
    estado                         VARCHAR2(25 CHAR) DEFAULT 'PENDIENTE' NOT NULL,
    motivo_decision                VARCHAR2(300 CHAR),
    fecha_decision                 TIMESTAMP,
    CONSTRAINT pk_solicitud_descuento PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_solicitud_descuento_id_c001 FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_solicitud_descuento_id_s001 FOREIGN KEY (id_suscripcion) REFERENCES suscripcion (id_suscripcion),
    CONSTRAINT fk_solicitud_descuento_id_s002 FOREIGN KEY (id_solicitante) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_solicitud_descuento_id_a001 FOREIGN KEY (id_aprobador) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_solicitud_descuento_tipo CHECK (tipo IN ('PORCENTAJE', 'IMPORTE')),
    CONSTRAINT ck_solicitud_descuento_estado CHECK (estado IN ('PENDIENTE', 'ESCALADA', 'APROBADA', 'APROBADA_CONDICIONADA', 'RECHAZADA')),
    CONSTRAINT ck_desc_valor CHECK (valor > 0 AND (tipo <> 'PORCENTAJE' OR valor <= 100)),
    CONSTRAINT ck_desc_separacion CHECK (id_aprobador IS NULL OR id_aprobador <> id_solicitante),
    CONSTRAINT ck_desc_decision CHECK (estado IN ('PENDIENTE','ESCALADA') OR (id_aprobador IS NOT NULL AND fecha_decision IS NOT NULL)),
    CONSTRAINT ck_desc_motivo CHECK (estado NOT IN ('RECHAZADA','APROBADA_CONDICIONADA') OR motivo_decision IS NOT NULL)
);

-- EXCEPCION_COMERCIAL · Bloque A · origen: ExcepcionComercial
CREATE TABLE excepcion_comercial (
    id_excepcion                   NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_cliente                     NUMBER(10) NOT NULL,
    id_solicitud_descuento         NUMBER(10),
    tipo                           VARCHAR2(20 CHAR) NOT NULL,
    fecha_inicio_futura            DATE,
    aprobada                       NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_excepcion_comercial PRIMARY KEY (id_excepcion),
    CONSTRAINT uq_excepcion_comercial_id_s001 UNIQUE (id_solicitud_descuento),
    CONSTRAINT fk_excepcion_comercial_id_c001 FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_excepcion_comercial_id_s001 FOREIGN KEY (id_solicitud_descuento) REFERENCES solicitud_descuento (id_solicitud),
    CONSTRAINT ck_excepcion_comercial_tipo CHECK (tipo IN ('INICIO_FUTURO', 'PRIMER_MES_GRATIS', 'SIN_PRORRATEO')),
    CONSTRAINT ck_excepcion_comercial_apro001 CHECK (aprobada IN (0, 1)),
    CONSTRAINT ck_excepcion_inicio CHECK (tipo <> 'INICIO_FUTURO' OR fecha_inicio_futura IS NOT NULL)
);

-- FILA_IMPORTACION · Bloque A · origen: FilaImportacion
CREATE TABLE fila_importacion (
    id_fila                        NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_importacion                 NUMBER(10) NOT NULL,
    numero_fila                    NUMBER(10) NOT NULL,
    estado                         VARCHAR2(20 CHAR) NOT NULL,
    motivo_error                   VARCHAR2(500 CHAR),
    marcada_como_actualizacion     NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_fila_importacion PRIMARY KEY (id_fila),
    CONSTRAINT fk_fila_importacion_id_impo001 FOREIGN KEY (id_importacion) REFERENCES importacion_csv (id_importacion),
    CONSTRAINT ck_fila_importacion_estado CHECK (estado IN ('VALIDA', 'ERROR', 'DUPLICADO', 'DATOS_INCOMPLETOS', 'EXCLUIDA')),
    CONSTRAINT ck_fila_importacion_marcada001 CHECK (marcada_como_actualizacion IN (0, 1))
);

-- REVISION_TARIFA_ANUAL · Bloque B · origen: RevisionTarifaAnual
CREATE TABLE revision_tarifa_anual (
    id_revision                    NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_cliente                     NUMBER(10) NOT NULL,
    id_rango_propuesto             NUMBER(10),
    id_aprobador                   NUMBER(10),
    fecha_revision                 DATE NOT NULL,
    facturacion_anual_verificada   NUMBER(15,2) NOT NULL,
    precio_anterior                NUMBER(15,2) NOT NULL,
    precio_nuevo                   NUMBER(15,2),
    fecha_decision                 TIMESTAMP,
    estado                         VARCHAR2(15 CHAR) DEFAULT 'PENDIENTE' NOT NULL,
    motivo_rechazo                 VARCHAR2(300 CHAR),
    CONSTRAINT pk_revision_tarifa_anual PRIMARY KEY (id_revision),
    CONSTRAINT fk_revision_tarifa_anual_id001 FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_revision_tarifa_anual_id002 FOREIGN KEY (id_rango_propuesto) REFERENCES rango_tarifa (id_rango),
    CONSTRAINT fk_revision_tarifa_anual_id003 FOREIGN KEY (id_aprobador) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_revision_tarifa_anual_es001 CHECK (estado IN ('PENDIENTE', 'APROBADA', 'RECHAZADA')),
    CONSTRAINT ck_revision_decision CHECK (estado = 'PENDIENTE' OR (id_aprobador IS NOT NULL AND fecha_decision IS NOT NULL))
);

-- FACTURA · Bloque C · origen: Factura + FacturaRectificativa (herencia → una tabla)
CREATE TABLE factura (
    id_factura                     NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_cliente                     NUMBER(10) NOT NULL,
    id_serie                       NUMBER(10),
    id_suscripcion                 NUMBER(10),
    id_factura_original            NUMBER(10),
    id_creada_por                  NUMBER(10),
    id_ejecucion                   NUMBER(10),
    id_solicitud_descuento         NUMBER(10),
    id_centro_coste                NUMBER(10),
    numero                         VARCHAR2(30 CHAR),
    tipo                           VARCHAR2(15 CHAR) NOT NULL,
    estado                         VARCHAR2(25 CHAR) DEFAULT 'BORRADOR' NOT NULL,
    fecha_emision                  DATE,
    fecha_vencimiento              DATE,
    periodo_facturado              CHAR(7),
    moneda                         CHAR(3) NOT NULL,
    datos_fiscales_emision         VARCHAR2(1000 CHAR),
    base_imponible                 NUMBER(15,2) DEFAULT 0 NOT NULL,
    total                          NUMBER(15,2) DEFAULT 0 NOT NULL,
    saldo_pendiente                NUMBER(15,2) DEFAULT 0 NOT NULL,
    retenida                       NUMBER(1) DEFAULT 0 NOT NULL,
    documento_pdf                  BLOB,
    migrada                        NUMBER(1) DEFAULT 0 NOT NULL,
    motivo_rectificacion           VARCHAR2(300 CHAR),
    CONSTRAINT pk_factura PRIMARY KEY (id_factura),
    CONSTRAINT fk_factura_id_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_factura_id_serie FOREIGN KEY (id_serie) REFERENCES serie_facturacion (id_serie),
    CONSTRAINT fk_factura_id_suscripcion FOREIGN KEY (id_suscripcion) REFERENCES suscripcion (id_suscripcion),
    CONSTRAINT fk_factura_id_factura_original FOREIGN KEY (id_factura_original) REFERENCES factura (id_factura),
    CONSTRAINT fk_factura_id_creada_por FOREIGN KEY (id_creada_por) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_factura_id_ejecucion FOREIGN KEY (id_ejecucion) REFERENCES ejecucion_tarea (id_ejecucion),
    CONSTRAINT fk_factura_id_solicitud_des001 FOREIGN KEY (id_solicitud_descuento) REFERENCES solicitud_descuento (id_solicitud),
    CONSTRAINT fk_factura_id_centro_coste FOREIGN KEY (id_centro_coste) REFERENCES centro_coste (id_centro_coste),
    CONSTRAINT ck_factura_tipo CHECK (tipo IN ('PUNTUAL', 'RECURRENTE')),
    CONSTRAINT ck_factura_estado CHECK (estado IN ('BORRADOR', 'APROBADA', 'EMITIDA', 'ENVIADA', 'VENCIDA', 'PAGADA', 'PARCIALMENTE_CONCILIADA', 'ANULADA', 'RECTIFICADA', 'INCOBRABLE', 'CANCELADA')),
    CONSTRAINT ck_factura_retenida CHECK (retenida IN (0, 1)),
    CONSTRAINT ck_factura_migrada CHECK (migrada IN (0, 1)),
    CONSTRAINT ck_factura_numero CHECK (estado IN ('BORRADOR','APROBADA') OR (numero IS NOT NULL AND id_serie IS NOT NULL AND fecha_emision IS NOT NULL)),
    CONSTRAINT ck_factura_serie CHECK (numero IS NULL OR id_serie IS NOT NULL),
    CONSTRAINT ck_factura_recurrente CHECK ((tipo = 'RECURRENTE' AND id_suscripcion IS NOT NULL AND periodo_facturado IS NOT NULL) OR (tipo = 'PUNTUAL' AND periodo_facturado IS NULL)),
    CONSTRAINT ck_factura_rectificativa CHECK ((id_factura_original IS NULL AND motivo_rectificacion IS NULL) OR (id_factura_original IS NOT NULL AND motivo_rectificacion IS NOT NULL)),
    CONSTRAINT ck_factura_importes CHECK (id_factura_original IS NOT NULL OR (base_imponible >= 0 AND total >= 0)),
    CONSTRAINT ck_factura_fechas CHECK (fecha_vencimiento IS NULL OR fecha_emision IS NULL OR fecha_vencimiento >= fecha_emision),
    CONSTRAINT ck_factura_emitida_datos CHECK (estado IN ('BORRADOR','APROBADA') OR migrada = 1 OR datos_fiscales_emision IS NOT NULL)
);

-- APROBACION_FACTURA · Bloque C · origen: AprobacionFactura
CREATE TABLE aprobacion_factura (
    id_aprobacion                  NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_factura                     NUMBER(10) NOT NULL,
    id_solicitante                 NUMBER(10) NOT NULL,
    id_aprobador                   NUMBER(10),
    motivo_retencion               VARCHAR2(300 CHAR) NOT NULL,
    estado                         VARCHAR2(25 CHAR) DEFAULT 'PENDIENTE' NOT NULL,
    fecha_solicitud                TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_decision                 TIMESTAMP,
    motivo_decision                VARCHAR2(300 CHAR),
    CONSTRAINT pk_aprobacion_factura PRIMARY KEY (id_aprobacion),
    CONSTRAINT fk_aprobacion_factura_id_fa001 FOREIGN KEY (id_factura) REFERENCES factura (id_factura),
    CONSTRAINT fk_aprobacion_factura_id_so001 FOREIGN KEY (id_solicitante) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_aprobacion_factura_id_ap001 FOREIGN KEY (id_aprobador) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_aprobacion_factura_estado CHECK (estado IN ('PENDIENTE', 'PENDIENTE_INFORMACION', 'APROBADA', 'RECHAZADA')),
    CONSTRAINT ck_aprob_fact_separacion CHECK (id_aprobador IS NULL OR id_aprobador <> id_solicitante),
    CONSTRAINT ck_aprob_fact_decision CHECK (estado IN ('PENDIENTE','PENDIENTE_INFORMACION') OR (id_aprobador IS NOT NULL AND fecha_decision IS NOT NULL)),
    CONSTRAINT ck_aprob_fact_motivo CHECK (estado NOT IN ('RECHAZADA','PENDIENTE_INFORMACION') OR motivo_decision IS NOT NULL),
    CONSTRAINT ck_aprob_fact_fechas CHECK (fecha_decision IS NULL OR fecha_decision >= fecha_solicitud)
);

-- LINEA_FACTURA · Bloque C · origen: LineaFactura
CREATE TABLE linea_factura (
    id_linea                       NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_factura                     NUMBER(10) NOT NULL,
    id_impuesto                    NUMBER(10) NOT NULL,
    concepto                       VARCHAR2(300 CHAR) NOT NULL,
    cantidad                       NUMBER(12,3) NOT NULL,
    precio_unitario                NUMBER(15,2) NOT NULL,
    descuento                      NUMBER(5,2) DEFAULT 0 NOT NULL,
    porcentaje_impuesto            NUMBER(5,2) NOT NULL,
    importe                        NUMBER(15,2) NOT NULL,
    CONSTRAINT pk_linea_factura PRIMARY KEY (id_linea),
    CONSTRAINT fk_linea_factura_id_factura FOREIGN KEY (id_factura) REFERENCES factura (id_factura),
    CONSTRAINT fk_linea_factura_id_impuesto FOREIGN KEY (id_impuesto) REFERENCES impuesto (id_impuesto),
    CONSTRAINT ck_linea_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_linea_descuento CHECK (descuento BETWEEN 0 AND 100)
);

-- FILTRO_GUARDADO · Bloque C · origen: FiltroGuardado
CREATE TABLE filtro_guardado (
    id_filtro                      NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_usuario                     NUMBER(10) NOT NULL,
    nombre                         VARCHAR2(80 CHAR) NOT NULL,
    criterios                      CLOB NOT NULL,
    CONSTRAINT pk_filtro_guardado PRIMARY KEY (id_filtro),
    CONSTRAINT fk_filtro_guardado_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

-- OPERACION_EXCEPCIONAL · Bloque C · origen: OperacionExcepcional
CREATE TABLE operacion_excepcional (
    id_operacion                   NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_factura                     NUMBER(10) NOT NULL,
    id_solicitante                 NUMBER(10) NOT NULL,
    id_aprobador                   NUMBER(10),
    tipo                           VARCHAR2(15 CHAR) NOT NULL,
    motivo                         VARCHAR2(300 CHAR) NOT NULL,
    estado                         VARCHAR2(15 CHAR) DEFAULT 'PENDIENTE' NOT NULL,
    CONSTRAINT pk_operacion_excepcional PRIMARY KEY (id_operacion),
    CONSTRAINT fk_operacion_excepcional_id001 FOREIGN KEY (id_factura) REFERENCES factura (id_factura),
    CONSTRAINT fk_operacion_excepcional_id002 FOREIGN KEY (id_solicitante) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_operacion_excepcional_id003 FOREIGN KEY (id_aprobador) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_operacion_excepcional_tipo CHECK (tipo IN ('RECTIFICACION', 'ANULACION', 'INCOBRABLE', 'CANCELACION')),
    CONSTRAINT ck_operacion_excepcional_es001 CHECK (estado IN ('PENDIENTE', 'APROBADA', 'RECHAZADA', 'EJECUTADA')),
    CONSTRAINT ck_operacion_separacion CHECK (id_aprobador IS NULL OR id_aprobador <> id_solicitante),
        CONSTRAINT ck_operacion_aprobada CHECK (estado IN ('PENDIENTE','RECHAZADA') OR id_aprobador IS NOT NULL)
);

-- MOVIMIENTO_COBRO · Bloque D · origen: MovimientoCobro
CREATE TABLE movimiento_cobro (
    id_movimiento                  NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_asignado_a                  NUMBER(10),
    fuente                         VARCHAR2(15 CHAR) NOT NULL,
    id_externo                     VARCHAR2(100 CHAR) NOT NULL,
    importe                        NUMBER(15,2) NOT NULL,
    fecha                          TIMESTAMP NOT NULL,
    moneda                         CHAR(3) NOT NULL,
    concepto                       VARCHAR2(300 CHAR),
    referencia                     VARCHAR2(100 CHAR),
    estado                         VARCHAR2(25 CHAR) DEFAULT 'PENDIENTE_CONCILIACION' NOT NULL,
    CONSTRAINT pk_movimiento_cobro PRIMARY KEY (id_movimiento),
    CONSTRAINT fk_movimiento_cobro_id_asig001 FOREIGN KEY (id_asignado_a) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_movimiento_cobro_fuente CHECK (fuente IN ('STRIPE', 'REVOLUT', 'OTRA')),
    CONSTRAINT ck_movimiento_cobro_estado CHECK (estado IN ('PENDIENTE_CONCILIACION', 'CONCILIADO', 'PARCIAL')),
    CONSTRAINT ck_mov_importe CHECK (importe > 0)
);

-- CONCILIACION · Bloque D · origen: Conciliacion
CREATE TABLE conciliacion (
    id_conciliacion                NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_movimiento                  NUMBER(10) NOT NULL,
    id_factura                     NUMBER(10) NOT NULL,
    id_realizada_por               NUMBER(10),
    id_revertida_por               NUMBER(10),
    importe_asignado               NUMBER(15,2) NOT NULL,
    tipo                           VARCHAR2(15 CHAR) NOT NULL,
    regla                          VARCHAR2(80 CHAR),
    fecha                          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    revertida                      NUMBER(1) DEFAULT 0 NOT NULL,
    fecha_reversion                TIMESTAMP,
    motivo_reversion               VARCHAR2(300 CHAR),
    CONSTRAINT pk_conciliacion PRIMARY KEY (id_conciliacion),
    CONSTRAINT fk_conciliacion_id_movimiento FOREIGN KEY (id_movimiento) REFERENCES movimiento_cobro (id_movimiento),
    CONSTRAINT fk_conciliacion_id_factura FOREIGN KEY (id_factura) REFERENCES factura (id_factura),
    CONSTRAINT fk_conciliacion_id_realizad001 FOREIGN KEY (id_realizada_por) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_conciliacion_id_revertid001 FOREIGN KEY (id_revertida_por) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_conciliacion_tipo CHECK (tipo IN ('AUTOMATICA', 'MANUAL')),
    CONSTRAINT ck_conciliacion_revertida CHECK (revertida IN (0, 1)),
    CONSTRAINT ck_conc_importe CHECK (importe_asignado > 0),
    CONSTRAINT ck_conc_origen CHECK ((tipo = 'MANUAL' AND id_realizada_por IS NOT NULL) OR (tipo = 'AUTOMATICA' AND regla IS NOT NULL)),
    CONSTRAINT ck_conc_reversion CHECK (revertida = 0 OR (id_revertida_por IS NOT NULL AND fecha_reversion IS NOT NULL AND motivo_reversion IS NOT NULL))
);

-- PLANTILLA_COMUNICACION · Bloque D · origen: PlantillaComunicacion
CREATE TABLE plantilla_comunicacion (
    id_plantilla                   NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    tipo                           VARCHAR2(25 CHAR) NOT NULL,
    idioma                         VARCHAR2(5 CHAR) NOT NULL,
    version                        NUMBER(10) NOT NULL,
    asunto                         VARCHAR2(200 CHAR) NOT NULL,
    contenido                      CLOB NOT NULL,
    CONSTRAINT pk_plantilla_comunicacion PRIMARY KEY (id_plantilla),
    CONSTRAINT ck_plantilla_comunicacion_tipo CHECK (tipo IN ('FACTURA', 'RECORDATORIO_PREVIO', 'VENCIMIENTO', 'AVISO_IMPAGO', 'DISPUTA_RESUELTA'))
);

-- COMUNICACION · Bloque D · origen: Comunicacion
CREATE TABLE comunicacion (
    id_comunicacion                NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_factura                     NUMBER(10),
    id_destinatario                NUMBER(10),
    id_plantilla                   NUMBER(10) NOT NULL,
    tipo                           VARCHAR2(25 CHAR) NOT NULL,
    canal                          VARCHAR2(20 CHAR) DEFAULT 'EMAIL' NOT NULL,
    idioma                         VARCHAR2(5 CHAR) NOT NULL,
    estado                         VARCHAR2(15 CHAR) DEFAULT 'EN_COLA' NOT NULL,
    fecha_envio                    TIMESTAMP,
    numero_intento                 NUMBER(10) DEFAULT 1 NOT NULL,
    correo_destinatario            VARCHAR2(150 CHAR),
    CONSTRAINT pk_comunicacion PRIMARY KEY (id_comunicacion),
    CONSTRAINT fk_comunicacion_id_factura FOREIGN KEY (id_factura) REFERENCES factura (id_factura),
    CONSTRAINT fk_comunicacion_id_destinat001 FOREIGN KEY (id_destinatario) REFERENCES contacto (id_contacto),
    CONSTRAINT fk_comunicacion_id_plantilla FOREIGN KEY (id_plantilla) REFERENCES plantilla_comunicacion (id_plantilla),
    CONSTRAINT ck_comunicacion_tipo CHECK (tipo IN ('FACTURA', 'RECORDATORIO_PREVIO', 'VENCIMIENTO', 'AVISO_IMPAGO', 'DISPUTA_RESUELTA')),
    CONSTRAINT ck_comunicacion_canal CHECK (canal IN ('EMAIL', 'WHATSAPP_SIMULADO')),
    CONSTRAINT ck_comunicacion_estado CHECK (estado IN ('EN_COLA', 'ENVIADA', 'ENTREGADA', 'REBOTADA', 'FALLIDA')),
    CONSTRAINT ck_com_intento CHECK (numero_intento >= 1)
);

-- SUSPENSION_RECORDATORIOS · Bloque D · origen: SuspensionRecordatorios
CREATE TABLE suspension_recordatorios (
    id_suspension                  NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_factura                     NUMBER(10) NOT NULL,
    motivo                         VARCHAR2(300 CHAR) NOT NULL,
    fecha_revision                 DATE NOT NULL,
    activa                         NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT pk_suspension_recordatorios PRIMARY KEY (id_suspension),
    CONSTRAINT fk_suspension_recordatorios001 FOREIGN KEY (id_factura) REFERENCES factura (id_factura),
    CONSTRAINT ck_suspension_recordatorios001 CHECK (activa IN (0, 1))
);

-- REGLA_ALERTA · Bloque E · origen: ReglaAlerta
CREATE TABLE regla_alerta (
    id_regla                       NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    tipo                           VARCHAR2(30 CHAR) NOT NULL,
    umbral                         NUMBER(15,2) NOT NULL,
    activa                         NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT pk_regla_alerta PRIMARY KEY (id_regla),
    CONSTRAINT ck_regla_alerta_tipo CHECK (tipo IN ('DIAS_VENCIDA', 'IMPORTE_PENDIENTE')),
    CONSTRAINT ck_regla_alerta_activa CHECK (activa IN (0, 1))
);

-- INCIDENCIA · Bloque E · origen: Incidencia
CREATE TABLE incidencia (
    id_incidencia                  NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_cliente                     NUMBER(10) NOT NULL,
    id_factura                     NUMBER(10),
    id_responsable                 NUMBER(10) NOT NULL,
    tipo                           VARCHAR2(20 CHAR) NOT NULL,
    descripcion                    VARCHAR2(1000 CHAR) NOT NULL,
    estado                         VARCHAR2(15 CHAR) DEFAULT 'ABIERTA' NOT NULL,
    prioridad                      VARCHAR2(10 CHAR) DEFAULT 'MEDIA' NOT NULL,
    fecha_creacion                 TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_incidencia PRIMARY KEY (id_incidencia),
    CONSTRAINT fk_incidencia_id_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT fk_incidencia_id_factura FOREIGN KEY (id_factura) REFERENCES factura (id_factura),
    CONSTRAINT fk_incidencia_id_responsable FOREIGN KEY (id_responsable) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_incidencia_tipo CHECK (tipo IN ('ENTREGA', 'COBRO', 'FACTURACION', 'OTRA')),
    CONSTRAINT ck_incidencia_estado CHECK (estado IN ('ABIERTA', 'EN_CURSO', 'RESUELTA', 'CERRADA')),
    CONSTRAINT ck_incidencia_prioridad CHECK (prioridad IN ('BAJA', 'MEDIA', 'ALTA'))
);

-- ADJUNTO · Bloque E · origen: Incidencia.adjuntos (List<String>)
CREATE TABLE adjunto (
    id_adjunto                     NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_incidencia                  NUMBER(10) NOT NULL,
    nombre_archivo                 VARCHAR2(200 CHAR) NOT NULL,
    contenido                      BLOB NOT NULL,
    CONSTRAINT pk_adjunto PRIMARY KEY (id_adjunto),
    CONSTRAINT fk_adjunto_id_incidencia FOREIGN KEY (id_incidencia) REFERENCES incidencia (id_incidencia)
);

-- COMENTARIO · Bloque E · origen: Comentario
CREATE TABLE comentario (
    id_comentario                  NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_incidencia                  NUMBER(10) NOT NULL,
    id_autor                       NUMBER(10) NOT NULL,
    texto                          CLOB NOT NULL,
    fecha                          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_id_incidencia FOREIGN KEY (id_incidencia) REFERENCES incidencia (id_incidencia),
    CONSTRAINT fk_comentario_id_autor FOREIGN KEY (id_autor) REFERENCES usuario (id_usuario)
);

-- MENCION · Bloque E · origen: Asociación Comentario–Usuario «menciona»
CREATE TABLE mencion (
    id_comentario                  NUMBER(10),
    id_usuario                     NUMBER(10),
    CONSTRAINT pk_mencion PRIMARY KEY (id_comentario, id_usuario),
    CONSTRAINT fk_mencion_id_comentario FOREIGN KEY (id_comentario) REFERENCES comentario (id_comentario),
    CONSTRAINT fk_mencion_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

-- NOTIFICACION · Bloque E · origen: Notificacion
CREATE TABLE notificacion (
    id_notificacion                NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_usuario                     NUMBER(10) NOT NULL,
    id_regla                       NUMBER(10),
    id_comentario                  NUMBER(10),
    categoria                      VARCHAR2(30 CHAR) NOT NULL,
    mensaje                        VARCHAR2(500 CHAR) NOT NULL,
    elemento_relacionado           VARCHAR2(100 CHAR),
    fecha                          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    requiere_accion                NUMBER(1) DEFAULT 0 NOT NULL,
    leida                          NUMBER(1) DEFAULT 0 NOT NULL,
    resuelta                       NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_notificacion_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT fk_notificacion_id_regla FOREIGN KEY (id_regla) REFERENCES regla_alerta (id_regla),
    CONSTRAINT fk_notificacion_id_comentario FOREIGN KEY (id_comentario) REFERENCES comentario (id_comentario),
    CONSTRAINT ck_notificacion_requiere_ac001 CHECK (requiere_accion IN (0, 1)),
    CONSTRAINT ck_notificacion_leida CHECK (leida IN (0, 1)),
    CONSTRAINT ck_notificacion_resuelta CHECK (resuelta IN (0, 1)),
    CONSTRAINT ck_notif_resuelta CHECK (resuelta = 0 OR requiere_accion = 1)
);

-- INFORME · Bloque E · origen: Informe
CREATE TABLE informe (
    id_informe                     NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_usuario                     NUMBER(10) NOT NULL,
    filtros                        CLOB NOT NULL,
    formato                        VARCHAR2(5 CHAR) NOT NULL,
    estado                         VARCHAR2(25 CHAR) DEFAULT 'PENDIENTE' NOT NULL,
    fecha_generacion               TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_caducidad                TIMESTAMP,
    CONSTRAINT pk_informe PRIMARY KEY (id_informe),
    CONSTRAINT fk_informe_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT ck_informe_formato CHECK (formato IN ('CSV', 'PDF')),
    CONSTRAINT ck_informe_estado CHECK (estado IN ('PENDIENTE', 'PROCESANDO', 'COMPLETADO', 'COMPLETADO_CON_ERRORES'))
);

-- OBJETIVO_FACTURACION · Bloque E · origen: ObjetivoFacturacion
CREATE TABLE objetivo_facturacion (
    id_objetivo                    NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_administrador               NUMBER(10) NOT NULL,
    periodo                        CHAR(7) NOT NULL,
    valor                          NUMBER(15,2) NOT NULL,
    CONSTRAINT pk_objetivo_facturacion PRIMARY KEY (id_objetivo),
    CONSTRAINT uq_objetivo_facturacion_per001 UNIQUE (periodo),
    CONSTRAINT fk_objetivo_facturacion_id_001 FOREIGN KEY (id_administrador) REFERENCES usuario (id_usuario)
);

-- ------------------------------------------------------------- 2. ÍNDICES
-- 2.1 Únicos y de consulta del modelo. Los (CASE WHEN …) son índices basados en función:
--     dan unicidad condicionada (p. ej. número único solo cuando la factura ya lo tiene).
CREATE INDEX ix_evento_entidad ON evento_auditoria (entidad, id_entidad);
CREATE INDEX ix_cliente_id_fiscal ON cliente (identificador_fiscal);
CREATE UNIQUE INDEX uq_fila_importacion ON fila_importacion (id_importacion, numero_fila);
CREATE UNIQUE INDEX uq_factura_serie_numero ON factura ((CASE WHEN numero IS NOT NULL THEN id_serie END), numero);
CREATE UNIQUE INDEX uq_factura_periodo ON factura ((CASE WHEN id_factura_original IS NULL THEN id_suscripcion END), (CASE WHEN id_factura_original IS NULL THEN periodo_facturado END));
CREATE INDEX ix_factura_cliente_estado ON factura (id_cliente, estado);
CREATE UNIQUE INDEX uq_aprob_fact_abierta ON aprobacion_factura ((CASE WHEN estado IN ('PENDIENTE','PENDIENTE_INFORMACION') THEN id_factura END));
CREATE UNIQUE INDEX uq_filtro_nombre ON filtro_guardado (id_usuario, nombre);
CREATE UNIQUE INDEX uq_mov_evento ON movimiento_cobro (fuente, id_externo);
CREATE INDEX ix_mov_referencia ON movimiento_cobro (referencia);
CREATE UNIQUE INDEX uq_conc_activa ON conciliacion ((CASE WHEN revertida = 0 THEN id_movimiento END), (CASE WHEN revertida = 0 THEN id_factura END));
CREATE UNIQUE INDEX uq_plantilla_version ON plantilla_comunicacion (tipo, idioma, version);
CREATE INDEX ix_com_factura ON comunicacion (id_factura, tipo);
CREATE INDEX ix_com_estado ON comunicacion (estado);
CREATE INDEX ix_notif_usuario ON notificacion (id_usuario, leida);

-- 2.2 Índices sobre claves ajenas (búsquedas por padre y bloqueos al borrar; NFR-12, NFR-13).
CREATE INDEX ix_evento_auditoria_id_usuario ON evento_auditoria (id_usuario);
CREATE INDEX ix_accion_masiva_id_ejecutor ON accion_masiva (id_ejecutor);
CREATE INDEX ix_accion_masiva_id_aprobador ON accion_masiva (id_aprobador);
CREATE INDEX ix_solicitud_externa_id_cli001 ON solicitud_externa (id_cliente);
CREATE INDEX ix_cliente_id_responsable ON cliente (id_responsable);
CREATE INDEX ix_cliente_id_centro_coste ON cliente (id_centro_coste);
CREATE INDEX ix_cliente_id_importacion ON cliente (id_importacion);
CREATE INDEX ix_cliente_contacto_id_cont001 ON cliente_contacto (id_contacto);
CREATE INDEX ix_cliente_etiqueta_id_etiq001 ON cliente_etiqueta (id_etiqueta);
CREATE INDEX ix_favorito_id_cliente ON favorito (id_cliente);
CREATE INDEX ix_tarea_id_cliente ON tarea (id_cliente);
CREATE INDEX ix_tarea_id_completada_por ON tarea (id_completada_por);
CREATE INDEX ix_excepcion_comercial_id_c001 ON excepcion_comercial (id_cliente);
CREATE INDEX ix_importacion_csv_id_usuario ON importacion_csv (id_usuario);
CREATE INDEX ix_suscripcion_id_cliente ON suscripcion (id_cliente);
CREATE INDEX ix_revision_tarifa_anual_id001 ON revision_tarifa_anual (id_cliente);
CREATE INDEX ix_revision_tarifa_anual_id002 ON revision_tarifa_anual (id_rango_propuesto);
CREATE INDEX ix_revision_tarifa_anual_id003 ON revision_tarifa_anual (id_aprobador);
CREATE INDEX ix_solicitud_descuento_id_c001 ON solicitud_descuento (id_cliente);
CREATE INDEX ix_solicitud_descuento_id_s001 ON solicitud_descuento (id_suscripcion);
CREATE INDEX ix_solicitud_descuento_id_s002 ON solicitud_descuento (id_solicitante);
CREATE INDEX ix_solicitud_descuento_id_a001 ON solicitud_descuento (id_aprobador);
CREATE INDEX ix_factura_id_serie ON factura (id_serie);
CREATE INDEX ix_factura_id_suscripcion ON factura (id_suscripcion);
CREATE INDEX ix_factura_id_factura_original ON factura (id_factura_original);
CREATE INDEX ix_factura_id_creada_por ON factura (id_creada_por);
CREATE INDEX ix_factura_id_ejecucion ON factura (id_ejecucion);
CREATE INDEX ix_factura_id_solicitud_des001 ON factura (id_solicitud_descuento);
CREATE INDEX ix_factura_id_centro_coste ON factura (id_centro_coste);
CREATE INDEX ix_aprobacion_factura_id_fa001 ON aprobacion_factura (id_factura);
CREATE INDEX ix_aprobacion_factura_id_so001 ON aprobacion_factura (id_solicitante);
CREATE INDEX ix_aprobacion_factura_id_ap001 ON aprobacion_factura (id_aprobador);
CREATE INDEX ix_linea_factura_id_factura ON linea_factura (id_factura);
CREATE INDEX ix_linea_factura_id_impuesto ON linea_factura (id_impuesto);
CREATE INDEX ix_operacion_excepcional_id001 ON operacion_excepcional (id_factura);
CREATE INDEX ix_operacion_excepcional_id002 ON operacion_excepcional (id_solicitante);
CREATE INDEX ix_operacion_excepcional_id003 ON operacion_excepcional (id_aprobador);
CREATE INDEX ix_movimiento_cobro_id_asig001 ON movimiento_cobro (id_asignado_a);
CREATE INDEX ix_conciliacion_id_movimiento ON conciliacion (id_movimiento);
CREATE INDEX ix_conciliacion_id_factura ON conciliacion (id_factura);
CREATE INDEX ix_conciliacion_id_realizad001 ON conciliacion (id_realizada_por);
CREATE INDEX ix_conciliacion_id_revertid001 ON conciliacion (id_revertida_por);
CREATE INDEX ix_comunicacion_id_destinat001 ON comunicacion (id_destinatario);
CREATE INDEX ix_comunicacion_id_plantilla ON comunicacion (id_plantilla);
CREATE INDEX ix_suspension_recordatorios001 ON suspension_recordatorios (id_factura);
CREATE INDEX ix_incidencia_id_cliente ON incidencia (id_cliente);
CREATE INDEX ix_incidencia_id_factura ON incidencia (id_factura);
CREATE INDEX ix_incidencia_id_responsable ON incidencia (id_responsable);
CREATE INDEX ix_adjunto_id_incidencia ON adjunto (id_incidencia);
CREATE INDEX ix_comentario_id_incidencia ON comentario (id_incidencia);
CREATE INDEX ix_comentario_id_autor ON comentario (id_autor);
CREATE INDEX ix_mencion_id_usuario ON mencion (id_usuario);
CREATE INDEX ix_notificacion_id_regla ON notificacion (id_regla);
CREATE INDEX ix_notificacion_id_comentario ON notificacion (id_comentario);
CREATE INDEX ix_informe_id_usuario ON informe (id_usuario);
CREATE INDEX ix_objetivo_facturacion_id_001 ON objetivo_facturacion (id_administrador);

-- ------------------------------------------------------------- 3. COMENTARIOS
COMMENT ON TABLE usuario IS 'Usuarios internos. La jerarquía de roles se guarda en una sola tabla con la columna rol. [clase: Usuario + UsuarioOperativo + Administrador + Superadministrador (herencia → una tabla)]';
COMMENT ON COLUMN usuario.id_usuario IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN usuario.nombre IS 'Atributo nombre';
COMMENT ON COLUMN usuario.correo_corporativo IS 'Debe pertenecer a CONFIGURACION_SISTEMA.dominio_corporativo (FR-06)';
COMMENT ON COLUMN usuario.hash_contrasena IS 'Nunca en texto plano (NFR-17)';
COMMENT ON COLUMN usuario.rol IS 'Discriminador de la herencia UsuarioOperativo ◁ Administrador ◁ Superadministrador';
COMMENT ON COLUMN usuario.estado IS 'Atributo estado';
COMMENT ON COLUMN usuario.doble_factor_activo IS '2FA opcional (NFR-09)';
COMMENT ON COLUMN usuario.intentos_fallidos IS 'Bloqueo tras intentos fallidos (NFR-08)';
COMMENT ON COLUMN usuario.bloqueado_hasta IS 'Bloqueo temporal (CU-30 FE-3)';
COMMENT ON COLUMN usuario.preferencias_notificacion IS 'Canales por categoría (FR-24, CU-23)';
COMMENT ON COLUMN usuario.puede_gestionar_usuarios IS 'Solo tiene sentido si rol = ADMIN (FR-07)';
COMMENT ON TABLE evento_auditoria IS 'Registro de auditoría no editable; también alimenta la línea temporal del cliente. [clase: EventoAuditoria]';
COMMENT ON COLUMN evento_auditoria.id_evento IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN evento_auditoria.id_usuario IS 'Autor; nulo si actúa el sistema';
COMMENT ON COLUMN evento_auditoria.fecha_hora IS 'Atributo fechaHora';
COMMENT ON COLUMN evento_auditoria.accion IS 'Atributo accion';
COMMENT ON COLUMN evento_auditoria.entidad IS 'Tabla afectada (CLIENTE, FACTURA…)';
COMMENT ON COLUMN evento_auditoria.id_entidad IS 'Registro afectado; referencia genérica, sin FK';
COMMENT ON COLUMN evento_auditoria.valores_anteriores IS 'Atributo valoresAnteriores';
COMMENT ON COLUMN evento_auditoria.valores_nuevos IS 'Atributo valoresNuevos';
COMMENT ON COLUMN evento_auditoria.id_error IS 'Identificador de error técnico (NFR-09, CU-34 FA-2)';
COMMENT ON TABLE accion_masiva IS 'Acciones sobre varios elementos con alcance confirmado (FR-31, CU-32). [clase: AccionMasiva]';
COMMENT ON COLUMN accion_masiva.id_accion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN accion_masiva.id_ejecutor IS 'Administrador que la ejecuta';
COMMENT ON COLUMN accion_masiva.id_aprobador IS 'Otra persona; obligatoria en alto impacto (CU-32 FA-2)';
COMMENT ON COLUMN accion_masiva.tipo IS 'Atributo tipo';
COMMENT ON COLUMN accion_masiva.numero_elementos IS 'Atributo numeroElementos';
COMMENT ON COLUMN accion_masiva.alto_impacto IS 'Atributo altoImpacto';
COMMENT ON COLUMN accion_masiva.estado IS 'Atributo estado';
COMMENT ON TABLE ejecucion_tarea IS 'Cada ejecución del Planificador del sistema (CU-33). [clase: EjecucionTarea]';
COMMENT ON COLUMN ejecucion_tarea.id_ejecucion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN ejecucion_tarea.tipo IS 'Atributo tipo';
COMMENT ON COLUMN ejecucion_tarea.inicio IS 'Atributo inicio';
COMMENT ON COLUMN ejecucion_tarea.fin IS 'Atributo fin';
COMMENT ON COLUMN ejecucion_tarea.estado IS 'Atributo estado';
COMMENT ON COLUMN ejecucion_tarea.resumen IS 'Atributo resumen';
COMMENT ON COLUMN ejecucion_tarea.errores IS 'Atributo errores';
COMMENT ON TABLE configuracion_sistema IS 'Parámetros globales (CU-35, CU-36). Tabla de una sola fila. [clase: ConfiguracionSistema]';
COMMENT ON COLUMN configuracion_sistema.id_configuracion IS 'Siempre 1: hay una única configuración';
COMMENT ON COLUMN configuracion_sistema.datos_emisor IS 'Atributo datosEmisor';
COMMENT ON COLUMN configuracion_sistema.umbral_descuento IS 'Por encima decide el Superadministrador (FR-18)';
COMMENT ON COLUMN configuracion_sistema.umbral_importe_alto IS 'Factura puntual retenida (FR-13)';
COMMENT ON COLUMN configuracion_sistema.vencimiento_general_dias IS 'El pactado del cliente prevalece (BR-16)';
COMMENT ON COLUMN configuracion_sistema.dias_recordatorio_previo IS 'Atributo diasRecordatorioPrevio';
COMMENT ON COLUMN configuracion_sistema.dias_recordatorio_vencimiento IS 'Atributo diasRecordatorioVencimiento';
COMMENT ON COLUMN configuracion_sistema.frecuencia_aviso_impago_dias IS 'Atributo frecuenciaAvisoImpagoDias';
COMMENT ON COLUMN configuracion_sistema.funciones_inteligentes_activas IS 'BR-22, FR-39';
COMMENT ON COLUMN configuracion_sistema.dominio_corporativo IS 'Dominio autorizado para el acceso (FR-06)';
COMMENT ON COLUMN configuracion_sistema.dias_conservacion_informes IS 'Tiempo configurable de conservación (FR-37)';
COMMENT ON TABLE serie_facturacion IS 'Series de numeración (FR-01, CU-35). [clase: SerieFacturacion]';
COMMENT ON COLUMN serie_facturacion.id_serie IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN serie_facturacion.codigo IS 'Atributo codigo';
COMMENT ON COLUMN serie_facturacion.prefijo IS 'Atributo prefijo';
COMMENT ON COLUMN serie_facturacion.ultimo_numero IS 'Contador correlativo (BR-10)';
COMMENT ON TABLE impuesto IS 'Impuestos dados de alta (FR-01). [clase: Impuesto]';
COMMENT ON COLUMN impuesto.id_impuesto IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN impuesto.nombre IS 'Atributo nombre';
COMMENT ON COLUMN impuesto.porcentaje IS 'Atributo porcentaje';
COMMENT ON TABLE rango_tarifa IS 'Tabla de tarifas por facturación anual (FR-10, FR-17). [clase: RangoTarifa]';
COMMENT ON COLUMN rango_tarifa.id_rango IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN rango_tarifa.facturacion_minima IS 'Atributo facturacionMinima';
COMMENT ON COLUMN rango_tarifa.facturacion_maxima IS 'Nulo = sin tope';
COMMENT ON COLUMN rango_tarifa.precio IS 'Atributo precio';
COMMENT ON COLUMN rango_tarifa.fecha_efecto IS 'Los cambios valen para el futuro (FR-17)';
COMMENT ON TABLE solicitud_externa IS 'Peticiones del Sistema externo vía API; nunca modifican datos directamente (BR-21, CU-37). [clase: SolicitudExterna]';
COMMENT ON COLUMN solicitud_externa.id_solicitud_externa IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN solicitud_externa.sistema_origen IS 'Atributo sistemaOrigen';
COMMENT ON COLUMN solicitud_externa.tipo IS 'P. ej. SOLICITUD_BAJA (FR-49)';
COMMENT ON COLUMN solicitud_externa.datos IS 'Atributo datos';
COMMENT ON COLUMN solicitud_externa.estado IS 'Atributo estado';
COMMENT ON COLUMN solicitud_externa.fecha IS 'Atributo fecha';
COMMENT ON TABLE cliente IS 'Empresa cliente: datos fiscales y ficha comercial (FR-03). [clase: Cliente]';
COMMENT ON COLUMN cliente.id_cliente IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN cliente.id_responsable IS 'Responsable interno (FR-24)';
COMMENT ON COLUMN cliente.id_importacion IS 'Importación que lo creó o actualizó (CU-03)';
COMMENT ON COLUMN cliente.nombre_comercial IS 'Atributo nombreComercial';
COMMENT ON COLUMN cliente.razon_social IS 'Atributo razonSocial';
COMMENT ON COLUMN cliente.identificador_fiscal IS 'Puede faltar (CU-01 FA-5)';
COMMENT ON COLUMN cliente.domicilio_fiscal IS 'Atributo domicilioFiscal';
COMMENT ON COLUMN cliente.pais IS 'ISO 3166 (modelo fiscal universal, FR-03)';
COMMENT ON COLUMN cliente.moneda IS 'ISO 4217';
COMMENT ON COLUMN cliente.sector IS 'Atributo sector';
COMMENT ON COLUMN cliente.ubicacion IS 'Clasificación por ubicación (FR-33)';
COMMENT ON COLUMN cliente.idioma IS 'Atributo idioma';
COMMENT ON COLUMN cliente.estado IS 'Atributo estado';
COMMENT ON COLUMN cliente.datos_fiscales_incompletos IS 'Bloquea la emisión (CU-12 FE-1)';
COMMENT ON COLUMN cliente.fecha_inicio IS 'Atributo fechaInicio';
COMMENT ON COLUMN cliente.condiciones_pago IS 'Atributo condicionesPago';
COMMENT ON COLUMN cliente.documento_firmado IS 'Referencia al documento firmado fuera de la plataforma (FR-03)';
COMMENT ON COLUMN cliente.vencimiento_pactado_dias IS 'Prevalece sobre el general (BR-16)';
COMMENT ON TABLE contacto IS 'Persona de contacto; puede pertenecer a varios clientes (FR-04). [clase: Contacto]';
COMMENT ON COLUMN contacto.id_contacto IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN contacto.nombre IS 'Atributo nombre';
COMMENT ON COLUMN contacto.correo IS 'Nulo si se ha anonimizado (NFR-18)';
COMMENT ON COLUMN contacto.idioma IS 'Atributo idioma';
COMMENT ON COLUMN contacto.consentimiento_whatsapp IS 'FR-46';
COMMENT ON COLUMN contacto.activo IS 'Inactivo conserva el histórico (BR-19)';
COMMENT ON TABLE cliente_contacto IS 'Relación N:M Cliente–Contacto con su tipo. [clase: ClienteContacto (clase asociación)]';
COMMENT ON COLUMN cliente_contacto.tipo IS 'Atributo tipo';
COMMENT ON TABLE etiqueta IS 'Catálogo de etiquetas (FR-33). Sale de un atributo multivaluado. [clase: Cliente.etiquetas (List<String>)]';
COMMENT ON COLUMN etiqueta.id_etiqueta IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN etiqueta.nombre IS 'estratégico, beta, partner, riesgo de cobro…';
COMMENT ON TABLE cliente_etiqueta IS 'Relación N:M Cliente–Etiqueta. [clase: Cliente.etiquetas (List<String>)]';
COMMENT ON TABLE favorito IS 'Relación N:M Usuario–Cliente (FR-44). [clase: Asociación Usuario–Cliente «favoritos»]';
COMMENT ON TABLE tarea IS 'Tareas del cliente; se heredan al cambiar de responsable (FR-32, CU-04). [clase: Tarea]';
COMMENT ON COLUMN tarea.id_tarea IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN tarea.id_cliente IS 'Composición: la tarea no existe sin su cliente';
COMMENT ON COLUMN tarea.descripcion IS 'Atributo descripcion';
COMMENT ON COLUMN tarea.fecha_prevista IS 'Atributo fechaPrevista';
COMMENT ON COLUMN tarea.estado IS 'Atributo estado';
COMMENT ON COLUMN tarea.fecha_completada IS 'CU-04 FA-2: quién y cuándo';
COMMENT ON TABLE excepcion_comercial IS 'Excepciones explícitas: inicio futuro, primer mes gratis, sin prorrateo (FR-47, BR-18). [clase: ExcepcionComercial]';
COMMENT ON COLUMN excepcion_comercial.id_excepcion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN excepcion_comercial.id_cliente IS 'Composición: va en la ficha del cliente';
COMMENT ON COLUMN excepcion_comercial.id_solicitud_descuento IS 'Aprobación de la excepción con efecto económico (CU-01 FA-4). UNIQUE → relación 1:1';
COMMENT ON COLUMN excepcion_comercial.tipo IS 'Atributo tipo';
COMMENT ON COLUMN excepcion_comercial.fecha_inicio_futura IS 'Atributo fechaInicioFutura';
COMMENT ON COLUMN excepcion_comercial.aprobada IS 'Atributo aprobada';
COMMENT ON TABLE importacion_csv IS 'Cada importación masiva y su resumen (FR-08, CU-03). [clase: ImportacionCSV]';
COMMENT ON COLUMN importacion_csv.id_importacion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN importacion_csv.nombre_archivo IS 'Atributo nombreArchivo';
COMMENT ON COLUMN importacion_csv.fecha IS 'Atributo fecha';
COMMENT ON COLUMN importacion_csv.incluye_facturas_historicas IS 'FR-08, CU-03 FA-1';
COMMENT ON COLUMN importacion_csv.estado IS 'Atributo estado';
COMMENT ON COLUMN importacion_csv.creados IS 'Atributo creados';
COMMENT ON COLUMN importacion_csv.actualizados IS 'Atributo actualizados';
COMMENT ON COLUMN importacion_csv.rechazados IS 'Atributo rechazados';
COMMENT ON TABLE fila_importacion IS 'Filas del CSV con su resultado y motivo de error. [clase: FilaImportacion]';
COMMENT ON COLUMN fila_importacion.id_fila IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN fila_importacion.id_importacion IS 'Composición';
COMMENT ON COLUMN fila_importacion.numero_fila IS 'Atributo numeroFila';
COMMENT ON COLUMN fila_importacion.estado IS 'Atributo estado';
COMMENT ON COLUMN fila_importacion.motivo_error IS 'Atributo motivoError';
COMMENT ON COLUMN fila_importacion.marcada_como_actualizacion IS 'El usuario la marca como actualización de un cliente existente (CU-03 FA-3)';
COMMENT ON TABLE suscripcion IS 'Plan mensual del cliente, con pausa y baja (FR-11, FR-16, BR-14, BR-15). [clase: Suscripcion]';
COMMENT ON COLUMN suscripcion.id_suscripcion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN suscripcion.id_cliente IS 'Composición';
COMMENT ON COLUMN suscripcion.plan IS 'Atributo plan';
COMMENT ON COLUMN suscripcion.precio_vigente IS 'Atributo precioVigente';
COMMENT ON COLUMN suscripcion.fecha_inicio IS 'Base del prorrateo (FR-11, BR-17)';
COMMENT ON COLUMN suscripcion.estado IS 'Atributo estado';
COMMENT ON COLUMN suscripcion.motivo_pausa IS 'Atributo motivoPausa';
COMMENT ON COLUMN suscripcion.fecha_inicio_pausa IS 'Atributo fechaInicioPausa';
COMMENT ON COLUMN suscripcion.fecha_reactivacion_prevista IS 'Atributo fechaReactivacionPrevista';
COMMENT ON COLUMN suscripcion.fecha_baja IS 'Atributo fechaBaja';
COMMENT ON COLUMN suscripcion.motivo_baja IS 'Atributo motivoBaja';
COMMENT ON TABLE revision_tarifa_anual IS 'Revisión anual del rango de tarifa (FR-10, CU-06). [clase: RevisionTarifaAnual]';
COMMENT ON COLUMN revision_tarifa_anual.id_revision IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN revision_tarifa_anual.fecha_revision IS 'Fecha de la revisión anual (FR-10)';
COMMENT ON COLUMN revision_tarifa_anual.facturacion_anual_verificada IS 'Atributo facturacionAnualVerificada';
COMMENT ON COLUMN revision_tarifa_anual.precio_anterior IS 'Atributo precioAnterior';
COMMENT ON COLUMN revision_tarifa_anual.precio_nuevo IS 'Atributo precioNuevo';
COMMENT ON COLUMN revision_tarifa_anual.fecha_decision IS 'Atributo fechaDecision';
COMMENT ON COLUMN revision_tarifa_anual.estado IS 'Atributo estado';
COMMENT ON COLUMN revision_tarifa_anual.motivo_rechazo IS 'Atributo motivoRechazo';
COMMENT ON TABLE solicitud_descuento IS 'Descuentos solicitados, aprobados o escalados (FR-18, CU-07…09). [clase: SolicitudDescuento]';
COMMENT ON COLUMN solicitud_descuento.id_solicitud IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN solicitud_descuento.id_aprobador IS 'Administrador; Superadministrador si supera el umbral (CU-09)';
COMMENT ON COLUMN solicitud_descuento.tipo IS 'Atributo tipo';
COMMENT ON COLUMN solicitud_descuento.valor IS 'Atributo valor';
COMMENT ON COLUMN solicitud_descuento.motivo IS 'Atributo motivo';
COMMENT ON COLUMN solicitud_descuento.fecha_vigencia IS 'Atributo fechaVigencia';
COMMENT ON COLUMN solicitud_descuento.estado IS 'Atributo estado';
COMMENT ON COLUMN solicitud_descuento.motivo_decision IS 'Atributo motivoDecision';
COMMENT ON COLUMN solicitud_descuento.fecha_decision IS 'Atributo fechaDecision';
COMMENT ON TABLE factura IS 'Facturas puntuales y recurrentes; es rectificativa si tiene id_factura_original. Emitida = inmutable (BR-09). [clase: Factura + FacturaRectificativa (herencia → una tabla)]';
COMMENT ON COLUMN factura.id_factura IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN factura.id_serie IS 'Nula en un borrador; obligatoria para emitir (CU-12)';
COMMENT ON COLUMN factura.id_suscripcion IS 'Solo recurrentes';
COMMENT ON COLUMN factura.id_factura_original IS 'Solo rectificativas (FR-45)';
COMMENT ON COLUMN factura.id_creada_por IS 'Nula si la genera el Planificador (CU-11)';
COMMENT ON COLUMN factura.id_ejecucion IS 'Ejecución del Planificador que la generó (CU-11 pasos 7-8)';
COMMENT ON COLUMN factura.numero IS 'Nulo hasta la emisión; único en su serie (BR-10)';
COMMENT ON COLUMN factura.tipo IS 'Atributo tipo';
COMMENT ON COLUMN factura.estado IS 'Atributo estado';
COMMENT ON COLUMN factura.fecha_emision IS 'Atributo fechaEmision';
COMMENT ON COLUMN factura.fecha_vencimiento IS 'Atributo fechaVencimiento';
COMMENT ON COLUMN factura.periodo_facturado IS 'AAAA-MM; evita duplicar mensualidades (NFR-15)';
COMMENT ON COLUMN factura.moneda IS 'Moneda original, no se altera (RB-02)';
COMMENT ON COLUMN factura.datos_fiscales_emision IS 'Datos fiscales del cliente copiados al emitir (BR-09)';
COMMENT ON COLUMN factura.base_imponible IS 'Atributo baseImponible';
COMMENT ON COLUMN factura.total IS 'Atributo total';
COMMENT ON COLUMN factura.saldo_pendiente IS 'Atributo derivado (total menos cobros conciliados); se guarda para consultas rápidas (NFR-12). Negativo = cobrado de más (FR-21)';
COMMENT ON COLUMN factura.retenida IS 'Tiene una APROBACION_FACTURA pendiente (FR-13)';
COMMENT ON COLUMN factura.documento_pdf IS 'PDF guardado en la base de datos (FR-12)';
COMMENT ON COLUMN factura.migrada IS 'Importada del sistema anterior (CU-03 FA-1)';
COMMENT ON COLUMN factura.motivo_rectificacion IS 'Atributo FacturaRectificativa.motivoRectificacion';
COMMENT ON TABLE aprobacion_factura IS 'Cada retención de una factura y su decisión (FR-13, FR-18, CU-13). [clase: AprobacionFactura]';
COMMENT ON COLUMN aprobacion_factura.id_aprobacion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN aprobacion_factura.id_factura IS 'Composición: una factura puede tener varias retenciones (CU-13 FA-1)';
COMMENT ON COLUMN aprobacion_factura.id_aprobador IS 'Administrador o Superadministrador (CU-13)';
COMMENT ON COLUMN aprobacion_factura.motivo_retencion IS 'Causa de la retención; se explica siempre (FR-18)';
COMMENT ON COLUMN aprobacion_factura.estado IS 'Atributo estado';
COMMENT ON COLUMN aprobacion_factura.fecha_solicitud IS 'Atributo fechaSolicitud';
COMMENT ON COLUMN aprobacion_factura.fecha_decision IS 'Atributo fechaDecision';
COMMENT ON COLUMN aprobacion_factura.motivo_decision IS 'Obligatorio al rechazar o pedir información (CU-13 FA-1, FA-2)';
COMMENT ON TABLE linea_factura IS 'Líneas de factura (FR-02). Copian el % de impuesto (BR-11). [clase: LineaFactura]';
COMMENT ON COLUMN linea_factura.id_linea IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN linea_factura.id_factura IS 'Composición';
COMMENT ON COLUMN linea_factura.concepto IS 'Atributo concepto';
COMMENT ON COLUMN linea_factura.cantidad IS 'Atributo cantidad';
COMMENT ON COLUMN linea_factura.precio_unitario IS 'Atributo precioUnitario';
COMMENT ON COLUMN linea_factura.descuento IS 'Porcentaje sobre la línea';
COMMENT ON COLUMN linea_factura.porcentaje_impuesto IS 'Copia del % al emitir (BR-11)';
COMMENT ON COLUMN linea_factura.importe IS 'Atributo importe';
COMMENT ON TABLE filtro_guardado IS 'Filtros de búsqueda guardados (FR-28, CU-15 FA-1). [clase: FiltroGuardado]';
COMMENT ON COLUMN filtro_guardado.id_filtro IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN filtro_guardado.id_usuario IS 'Composición';
COMMENT ON COLUMN filtro_guardado.nombre IS 'Atributo nombre';
COMMENT ON COLUMN filtro_guardado.criterios IS 'Atributo criterios';
COMMENT ON TABLE operacion_excepcional IS 'Rectificar, anular, incobrable o cancelar una factura (CU-14). [clase: OperacionExcepcional]';
COMMENT ON COLUMN operacion_excepcional.id_operacion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN operacion_excepcional.tipo IS 'Atributo tipo';
COMMENT ON COLUMN operacion_excepcional.motivo IS 'Atributo motivo';
COMMENT ON COLUMN operacion_excepcional.estado IS 'Atributo estado';
COMMENT ON TABLE movimiento_cobro IS 'Cobros recibidos de Stripe, Revolut u otra fuente (FR-15, CU-16). [clase: MovimientoCobro]';
COMMENT ON COLUMN movimiento_cobro.id_movimiento IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN movimiento_cobro.id_asignado_a IS 'Persona que lo concilia si hay dudas (CU-16 FA-2)';
COMMENT ON COLUMN movimiento_cobro.fuente IS 'Atributo fuente';
COMMENT ON COLUMN movimiento_cobro.id_externo IS 'Atributo idExterno';
COMMENT ON COLUMN movimiento_cobro.importe IS 'Atributo importe';
COMMENT ON COLUMN movimiento_cobro.fecha IS 'Atributo fecha';
COMMENT ON COLUMN movimiento_cobro.moneda IS 'Atributo moneda';
COMMENT ON COLUMN movimiento_cobro.concepto IS 'Atributo concepto';
COMMENT ON COLUMN movimiento_cobro.referencia IS 'Atributo referencia';
COMMENT ON COLUMN movimiento_cobro.estado IS 'Atributo estado';
COMMENT ON TABLE conciliacion IS 'Asociación cobro–factura (N:M con atributos); se revierte, no se borra (FR-21, FR-22). [clase: Conciliacion]';
COMMENT ON COLUMN conciliacion.id_conciliacion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN conciliacion.id_realizada_por IS 'Nulo si es automática';
COMMENT ON COLUMN conciliacion.importe_asignado IS 'Atributo importeAsignado';
COMMENT ON COLUMN conciliacion.tipo IS 'Atributo tipo';
COMMENT ON COLUMN conciliacion.regla IS 'Regla que la hizo si es automática';
COMMENT ON COLUMN conciliacion.fecha IS 'Atributo fecha';
COMMENT ON COLUMN conciliacion.revertida IS 'Atributo revertida';
COMMENT ON COLUMN conciliacion.fecha_reversion IS 'Atributo fechaReversion';
COMMENT ON COLUMN conciliacion.motivo_reversion IS 'Atributo motivoReversion';
COMMENT ON TABLE plantilla_comunicacion IS 'Plantillas versionadas por tipo e idioma (FR-26, CU-22). [clase: PlantillaComunicacion]';
COMMENT ON COLUMN plantilla_comunicacion.id_plantilla IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN plantilla_comunicacion.tipo IS 'Atributo tipo';
COMMENT ON COLUMN plantilla_comunicacion.idioma IS 'Atributo idioma';
COMMENT ON COLUMN plantilla_comunicacion.version IS 'Editar crea otra versión (BR-11)';
COMMENT ON COLUMN plantilla_comunicacion.asunto IS 'Atributo asunto';
COMMENT ON COLUMN plantilla_comunicacion.contenido IS 'Atributo contenido';
COMMENT ON TABLE comunicacion IS 'Cada intento, reenvío o canal de un mensaje al cliente (FR-46, CU-18). [clase: Comunicacion]';
COMMENT ON COLUMN comunicacion.id_comunicacion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN comunicacion.id_destinatario IS 'Puede faltar (CU-18 FE-3)';
COMMENT ON COLUMN comunicacion.id_plantilla IS 'Versión usada en el envío (FR-26)';
COMMENT ON COLUMN comunicacion.tipo IS 'Atributo tipo';
COMMENT ON COLUMN comunicacion.canal IS 'Atributo canal';
COMMENT ON COLUMN comunicacion.idioma IS 'Atributo idioma';
COMMENT ON COLUMN comunicacion.estado IS 'Atributo estado';
COMMENT ON COLUMN comunicacion.fecha_envio IS 'Atributo fechaEnvio';
COMMENT ON COLUMN comunicacion.numero_intento IS 'Atributo numeroIntento';
COMMENT ON COLUMN comunicacion.correo_destinatario IS 'Copia del correo usado en el envío (FR-04)';
COMMENT ON TABLE suspension_recordatorios IS 'Suspensión de avisos de una factura (FR-05, CU-21). [clase: SuspensionRecordatorios]';
COMMENT ON COLUMN suspension_recordatorios.id_suspension IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN suspension_recordatorios.motivo IS 'Atributo motivo';
COMMENT ON COLUMN suspension_recordatorios.fecha_revision IS 'Atributo fechaRevision';
COMMENT ON COLUMN suspension_recordatorios.activa IS 'Atributo activa';
COMMENT ON TABLE centro_coste IS 'Centros de coste o proyectos para informes (FR-40, CU-28). [clase: CentroCoste]';
COMMENT ON COLUMN centro_coste.id_centro_coste IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN centro_coste.nombre IS 'Renombrar no altera el histórico (FR-40)';
COMMENT ON COLUMN centro_coste.tipo IS 'Atributo tipo';
COMMENT ON COLUMN centro_coste.activo IS 'Se desactiva en vez de borrarse';
COMMENT ON TABLE regla_alerta IS 'Reglas parametrizables de alerta (FR-42, CU-24). [clase: ReglaAlerta]';
COMMENT ON COLUMN regla_alerta.id_regla IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN regla_alerta.tipo IS 'Atributo tipo';
COMMENT ON COLUMN regla_alerta.umbral IS 'Atributo umbral';
COMMENT ON COLUMN regla_alerta.activa IS 'Atributo activa';
COMMENT ON TABLE incidencia IS 'Incidencias de facturación, entrega o cobro (FR-34, CU-25). [clase: Incidencia]';
COMMENT ON COLUMN incidencia.id_incidencia IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN incidencia.tipo IS 'Atributo tipo';
COMMENT ON COLUMN incidencia.descripcion IS 'Atributo descripcion';
COMMENT ON COLUMN incidencia.estado IS 'Atributo estado';
COMMENT ON COLUMN incidencia.prioridad IS 'Atributo prioridad';
COMMENT ON COLUMN incidencia.fecha_creacion IS 'Atributo fechaCreacion';
COMMENT ON TABLE adjunto IS 'Adjuntos de una incidencia. Sale de un atributo multivaluado. [clase: Incidencia.adjuntos (List<String>)]';
COMMENT ON COLUMN adjunto.id_adjunto IS 'Clave primaria técnica (identidad)';
COMMENT ON TABLE comentario IS 'Comentarios internos; nunca se envían al cliente (BR-20). [clase: Comentario]';
COMMENT ON COLUMN comentario.id_comentario IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN comentario.id_incidencia IS 'Composición';
COMMENT ON COLUMN comentario.texto IS 'Atributo texto';
COMMENT ON COLUMN comentario.fecha IS 'Atributo fecha';
COMMENT ON TABLE mencion IS 'Relación N:M: usuarios mencionados (FR-36). [clase: Asociación Comentario–Usuario «menciona»]';
COMMENT ON TABLE notificacion IS 'Avisos internos de cada usuario; leída ≠ resuelta (FR-24, CU-23). [clase: Notificacion]';
COMMENT ON COLUMN notificacion.id_notificacion IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN notificacion.id_comentario IS 'Mención que la generó';
COMMENT ON COLUMN notificacion.categoria IS 'Atributo categoria';
COMMENT ON COLUMN notificacion.mensaje IS 'Atributo mensaje';
COMMENT ON COLUMN notificacion.elemento_relacionado IS 'Enlace al elemento (CU-23 paso 3)';
COMMENT ON COLUMN notificacion.fecha IS 'Atributo fecha';
COMMENT ON COLUMN notificacion.requiere_accion IS 'Solo estas se marcan como resueltas (FR-24)';
COMMENT ON COLUMN notificacion.leida IS 'Atributo leida';
COMMENT ON COLUMN notificacion.resuelta IS 'Atributo resuelta';
COMMENT ON TABLE informe IS 'Informes generados, exportables y con caducidad (FR-25, FR-37, CU-26). [clase: Informe]';
COMMENT ON COLUMN informe.id_informe IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN informe.filtros IS 'Permiten regenerarlo (CU-26 FA-2)';
COMMENT ON COLUMN informe.formato IS 'Atributo formato';
COMMENT ON COLUMN informe.estado IS 'Atributo estado';
COMMENT ON COLUMN informe.fecha_generacion IS 'Atributo fechaGeneracion';
COMMENT ON COLUMN informe.fecha_caducidad IS 'Atributo fechaCaducidad';
COMMENT ON TABLE objetivo_facturacion IS 'Objetivos informativos del dashboard (FR-41). Cambios en EVENTO_AUDITORIA. [clase: ObjetivoFacturacion]';
COMMENT ON COLUMN objetivo_facturacion.id_objetivo IS 'Clave primaria técnica (identidad)';
COMMENT ON COLUMN objetivo_facturacion.id_administrador IS 'Administrador que lo gestiona (CU-28)';
COMMENT ON COLUMN objetivo_facturacion.periodo IS 'AAAA-MM';
COMMENT ON COLUMN objetivo_facturacion.valor IS 'Atributo valor';
