@startuml
skinparam classAttributeIconSize 0
skinparam linetype ortho
skinparam nodesep 50
skinparam ranksep 50

title Diagrama UML de Clases - Sistema TurbineH

' --- CLASES Y GENERALIZACIONES (ACTORES) ---
abstract class Usuario {
  - idUsuario: int
  - correoCorporativo: String
  - passwordHash: String
  - activo: boolean
  + iniciarSesion(): boolean
  + recuperarPassword(): void
  + consultarNotificaciones(): void
}

class Superadministrador {
  + configurarFacturacionYTarifas(): void
  + configurarRecordatorios(): void
  + consultarAuditoria(): void
  + escalarAprobacion(): void
}

class Administrador {
  + gestionarUsuarios(): void
  + aprobarDescuento(): void
  + aprobarFacturaRetenida(): void
  + ejecutarAccionMasiva(): void
  + configurarAlertas(): void
}

class UsuarioOperativo {
  + gestionarClienteYContactos(): void
  + solicitarDescuento(): void
  + gestionarTareas(): void
  + conciliarPagos(): void
}

Usuario <|-- Superadministrador
Usuario <|-- Administrador
Usuario <|-- UsuarioOperativo

' --- CLASES PRINCIPALES DE NEGOCIO ---
class Cliente {
  - idCliente: int
  - razonSocial: String
  - nif: String
  - estadoComercial: String
  - tarifaAcordada: float
  - etiquetas: List<String>
  + darDeAlta(): void
  + marcarBaja(): void
  + solicitarDescuento(): void
}

class Contacto {
  - idContacto: int
  - nombre: String
  - correo: String
  - inactivo: boolean
  + actualizarDatos(): void
}

class Suscripcion {
  - idSuscripcion: int
  - estado: String
  - fechaEfecto: Date
  - fechaReactivacion: Date
  + pausar(): void
  + darDeBaja(): void
}

class Factura {
  - idFactura: int
  - numeroFactura: int
  - estado: String
  - fechaEmision: Date
  - fechaVencimiento: Date
  - importeTotal: float
  + generarBorrador(): void
  + emitir(): void
  + anular(): void
  + suspenderRecordatorios(): void
  + declararIncobrable(): void
}

class FacturaRectificativa {
  - motivoRectificacion: String
  + rectificarOriginal(): void
}
Factura <|-- FacturaRectificativa

class LineaFactura {
  - idLinea: int
  - concepto: String
  - cantidad: float
  - precioUnitario: float
  - impuesto: float
  + calcularSubtotal(): float
}

class Cobro {
  - idMovimiento: int
  - importe: float
  - fecha: Date
  - referencia: String
  - conciliado: boolean
  + registrarMovimiento(): void
}

class Conciliacion {
  - fechaConciliacion: Date
  - importeConciliado: float
  + revertirConciliacion(): void
}

class EnvioComunicacion {
  - idEnvio: int
  - canal: String
  - resultado: String
  - fechaIntento: Date
  + gestionarRebote(): void
  + reintentarEnvio(): void
}

class Incidencia {
  - idIncidencia: int
  - descripcion: String
  - estado: String
  - prioridad: String
  + resolverIncidencia(): void
  + añadirComentarioInterno(): void
}

class Tarea {
  - idTarea: int
  - descripcion: String
  - estado: String
  + completarTarea(): void
}

' --- RELACIONES, ASOCIACIONES Y MULTIPLICIDADES ---

Usuario "1" -- "0..*" Cliente : gestiona >
Cliente "1..*" -- "1..*" Contacto : tiene asociados >
Cliente "1" o-- "0..*" Suscripcion : contrata >
Cliente "1" -- "0..*" Factura : recibe >
Cliente "1" -- "0..*" Tarea : asignada a >
Cliente "1" -- "0..*" Incidencia : afecta a >

Factura "1" *-- "1..*" LineaFactura : contiene >
Factura "1" -- "0..1" FacturaRectificativa : rectificada por >
Factura "1" -- "0..*" EnvioComunicacion : genera >

Factura "1" -- "0..*" Conciliacion : saldada mediante >
Cobro "1" -- "1..*" Conciliacion : distribuido en >

Incidencia "0..*" -- "0..1" Factura : vinculada a >
Incidencia "0..*" -- "1" Usuario : asignada a >

@enduml