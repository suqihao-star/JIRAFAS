-- TABLA DE USUARIOS Y ROLES
CREATE TABLE usuario (
    id_usuario NUMBER PRIMARY KEY,
    correo_corporativo VARCHAR2(150) NOT NULL UNIQUE,
    password_hash VARCHAR2(255) NOT NULL,
    rol VARCHAR2(50) NOT NULL, -- Superadministrador, Administrador, Usuario Operativo
    activo NUMBER(1) DEFAULT 1
);

-- TABLA DE CLIENTES (Ficha comercial y fiscal)
CREATE TABLE cliente (
    id_cliente NUMBER PRIMARY KEY,
    nombre_comercial VARCHAR2(150),
    razon_social VARCHAR2(150) NOT NULL,
    nif VARCHAR2(50) NOT NULL,
    domicilio_fiscal VARCHAR2(255),
    pais VARCHAR2(100),
    moneda VARCHAR2(10),
    fecha_inicio DATE,
    plan_servicio VARCHAR2(100),
    tarifa_acordada NUMBER(10,2),
    condiciones_pago VARCHAR2(255),
    estado_comercial VARCHAR2(50), -- Activo, Baja, Pendiente
    id_responsable_interno NUMBER
);

-- TABLA DE CONTACTOS
CREATE TABLE contacto (
    id_contacto NUMBER PRIMARY KEY,
    nombre VARCHAR2(150) NOT NULL,
    correo VARCHAR2(150) NOT NULL,
    inactivo NUMBER(1) DEFAULT 0
);

-- RELACIÓN N:M CLIENTES Y CONTACTOS
CREATE TABLE cliente_contacto (
    id_cliente NUMBER,
    id_contacto NUMBER,
    tipo_contacto VARCHAR2(50), -- Facturación, Impagos
    PRIMARY KEY (id_cliente, id_contacto)
);

-- TABLA DE SUSCRIPCIONES
CREATE TABLE suscripcion (
    id_suscripcion NUMBER PRIMARY KEY,
    id_cliente NUMBER NOT NULL,
    estado VARCHAR2(50) NOT NULL, -- Activa, Pausa, Baja
    fecha_efecto DATE,
    fecha_reactivacion DATE,
    motivo_pausa_baja VARCHAR2(255)
);

-- TABLA DE SERIES DE FACTURACIÓN
CREATE TABLE serie_facturacion (
    id_serie NUMBER PRIMARY KEY,
    nombre_serie VARCHAR2(50) NOT NULL,
    prefijo VARCHAR2(10),
    numeracion_actual NUMBER NOT NULL
);

-- TABLA DE FACTURAS
CREATE TABLE factura (
    id_factura NUMBER PRIMARY KEY,
    id_serie NUMBER,
    numero_factura NUMBER,
    id_cliente NUMBER NOT NULL,
    tipo VARCHAR2(50), -- Recurrente, Puntual
    estado VARCHAR2(50) NOT NULL, -- Borrador, Emitida, Pagada, Anulada, Rectificada...
    fecha_emision DATE,
    fecha_vencimiento DATE,
    importe_total NUMBER(10,2),
    moneda_original VARCHAR2(10),
    motivo_retencion VARCHAR2(255),
    ruta_pdf VARCHAR2(255),
    id_factura_original NUMBER -- Autorreferencia para facturas rectificativas
);

-- TABLA DE LÍNEAS DE FACTURA
CREATE TABLE linea_factura (
    id_linea NUMBER PRIMARY KEY,
    id_factura NUMBER NOT NULL,
    concepto VARCHAR2(255) NOT NULL,
    cantidad NUMBER(10,2) NOT NULL,
    precio_unitario NUMBER(10,2) NOT NULL,
    descuento NUMBER(10,2),
    impuesto NUMBER(10,2)
);

-- TABLA DE MOVIMIENTOS DE COBRO (Stripe/Revolut)
CREATE TABLE movimiento_cobro (
    id_movimiento NUMBER PRIMARY KEY,
    importe NUMBER(10,2) NOT NULL,
    fecha DATE NOT NULL,
    moneda VARCHAR2(10),
    concepto VARCHAR2(255),
    referencia VARCHAR2(150),
    estado_conciliacion VARCHAR2(50) -- Conciliado, Pendiente
);

-- RELACIÓN N:M CONCILIACIONES (Un cobro puede pagar varias facturas)
CREATE TABLE conciliacion (
    id_conciliacion NUMBER PRIMARY KEY,
    id_factura NUMBER NOT NULL,
    id_movimiento NUMBER NOT NULL,
    importe_conciliado NUMBER(10,2) NOT NULL,
    fecha_conciliacion DATE NOT NULL,
    id_usuario_conciliador NUMBER
);

-- TABLA DE INCIDENCIAS
CREATE TABLE incidencia (
    id_incidencia NUMBER PRIMARY KEY,
    descripcion VARCHAR2(500) NOT NULL,
    estado VARCHAR2(50),
    prioridad VARCHAR2(50),
    id_responsable NUMBER,
    id_cliente NUMBER,
    id_factura NUMBER
);

-- TABLA DE TAREAS
CREATE TABLE tarea (
    id_tarea NUMBER PRIMARY KEY,
    descripcion VARCHAR2(255) NOT NULL,
    fecha_prevista DATE,
    estado VARCHAR2(50) NOT NULL,
    id_cliente NUMBER NOT NULL
);

-- TABLA DE PLANTILLAS DE COMUNICACIÓN
CREATE TABLE plantilla_comunicacion (
    id_plantilla NUMBER PRIMARY KEY,
    tipo_comunicacion VARCHAR2(100),
    idioma VARCHAR2(20),
    contenido CLOB
);

-- TABLA DE ENVÍOS DE COMUNICACIÓN / HISTORIAL
CREATE TABLE envio_comunicacion (
    id_envio NUMBER PRIMARY KEY,
    id_factura NUMBER,
    id_plantilla NUMBER NOT NULL,
    canal VARCHAR2(50), -- Email, WhatsApp
    resultado VARCHAR2(50), -- Enviado, Rebotado
    fecha_intento DATE,
    destinatario VARCHAR2(150)
);

-- RESTRICCIONES DE CLAVES FORÁNEAS (RELACIONES)
ALTER TABLE cliente ADD CONSTRAINT fk_cliente_usuario FOREIGN KEY (id_responsable_interno) REFERENCES usuario(id_usuario);
ALTER TABLE cliente_contacto ADD CONSTRAINT fk_cc_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);
ALTER TABLE cliente_contacto ADD CONSTRAINT fk_cc_contacto FOREIGN KEY (id_contacto) REFERENCES contacto(id_contacto);
ALTER TABLE suscripcion ADD CONSTRAINT fk_suscripcion_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);
ALTER TABLE factura ADD CONSTRAINT fk_factura_serie FOREIGN KEY (id_serie) REFERENCES serie_facturacion(id_serie);
ALTER TABLE factura ADD CONSTRAINT fk_factura_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);
ALTER TABLE factura ADD CONSTRAINT fk_factura_original FOREIGN KEY (id_factura_original) REFERENCES factura(id_factura);
ALTER TABLE linea_factura ADD CONSTRAINT fk_linea_factura FOREIGN KEY (id_factura) REFERENCES factura(id_factura);
ALTER TABLE conciliacion ADD CONSTRAINT fk_conciliacion_factura FOREIGN KEY (id_factura) REFERENCES factura(id_factura);
ALTER TABLE conciliacion ADD CONSTRAINT fk_conciliacion_movimiento FOREIGN KEY (id_movimiento) REFERENCES movimiento_cobro(id_movimiento);
ALTER TABLE conciliacion ADD CONSTRAINT fk_conciliacion_usuario FOREIGN KEY (id_usuario_conciliador) REFERENCES usuario(id_usuario);
ALTER TABLE incidencia ADD CONSTRAINT fk_incidencia_responsable FOREIGN KEY (id_responsable) REFERENCES usuario(id_usuario);
ALTER TABLE incidencia ADD CONSTRAINT fk_incidencia_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);
ALTER TABLE incidencia ADD CONSTRAINT fk_incidencia_factura FOREIGN KEY (id_factura) REFERENCES factura(id_factura);
ALTER TABLE tarea ADD CONSTRAINT fk_tarea_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);
ALTER TABLE envio_comunicacion ADD CONSTRAINT fk_envio_factura FOREIGN KEY (id_factura) REFERENCES factura(id_factura);
ALTER TABLE envio_comunicacion ADD CONSTRAINT fk_envio_plantilla FOREIGN KEY (id_plantilla) REFERENCES plantilla_comunicacion(id_plantilla);