@startuml
skinparam maxMessageSize 150
skinparam ParticipantPadding 20
skinparam BoxPadding 10

title Diagrama de Secuencia: Emisión de Factura y Conciliación de Cobro

actor "Usuario Operativo" as UO
participant ": Sistema" as Sys
participant "c : Cliente" as Cliente
participant "f : Factura" as Factura
participant "lf : LineaFactura" as Linea
participant "m : Cobro\n(Movimiento)" as Cobro
participant "con : Conciliacion" as Conciliacion

== 1. Generación y Emisión de Factura ==

UO -> Sys : iniciarGeneracionFactura(idCliente)
activate Sys

Sys -> Cliente : obtenerDatosYTarifa()
activate Cliente
Cliente --> Sys : retorna (datosFiscales, tarifaAcordada)
deactivate Cliente

Sys -> Factura ** : generarBorrador(idCliente, importeTotal)
activate Factura
Sys -> Linea ** : crearLinea(concepto, cantidad, precio)
Factura -> Factura : calcularSubtotal()
Factura --> Sys : factura (Borrador)
deactivate Factura

Sys --> UO : muestra factura en estado BORRADOR

UO -> Sys : emitirFactura(idFactura)
Sys -> Factura : emitir()
activate Factura
Factura -> Factura : asignarNumeroFactura()
Factura -> Factura : cambiarEstado('EMITIDA')
Factura --> Sys : ok
deactivate Factura

Sys --> UO : confirma emisión exitosa
deactivate Sys

== 2. Registro de Cobro y Conciliación ==

UO -> Sys : registrarCobro(importe, referencia)
activate Sys

Sys -> Cobro ** : registrarMovimiento(importe, fecha, referencia)
activate Cobro
Cobro --> Sys : movimiento creado (estado='Pendiente')
deactivate Cobro

Sys -> Sys : buscarFacturasPendientes(idCliente)

UO -> Sys : conciliar(idFactura, idMovimiento, importeConciliado)
Sys -> Conciliacion ** : nuevaConciliacion(idFactura, idMovimiento)
activate Conciliacion

Conciliacion -> Cobro : actualizarEstado('Conciliado')
activate Cobro
Cobro --> Conciliacion : ok
deactivate Cobro

Conciliacion -> Factura : actualizarEstado('PAGADA')
activate Factura
Factura --> Conciliacion : ok
deactivate Factura

Conciliacion --> Sys : conciliacion registrada
deactivate Conciliacion

Sys --> UO : confirma pago conciliado
deactivate Sys
@enduml