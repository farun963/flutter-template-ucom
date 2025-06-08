import 'package:finpay/model/sitema_reservas.dart';
import 'package:get/get.dart';
import 'package:finpay/api/local.db.service.dart';
import 'package:flutter/material.dart';

class PagoController extends GetxController {
  final db = LocalDBService();
  RxList<Reserva> reservasDelCliente = <Reserva>[].obs;
  RxList<Pago> pagosDelCliente = <Pago>[].obs;
  RxBool isLoading = false.obs;

  String codigoClienteActual = 'cliente_1';

  @override
  void onInit() {
    super.onInit();
    cargarReservasYPagosDelCliente();
  }

  Future<void> cargarReservasYPagosDelCliente() async {
    isLoading.value = true;

    try {
      print("🔄 Cargando reservas y pagos del cliente...");

      // Cargar autos del cliente para filtrar reservas
      final rawAutos = await db.getAll("autos.json");
      final autosCliente = rawAutos
          .map((e) => Auto.fromJson(e))
          .where((a) => a.clienteId == codigoClienteActual)
          .toList();

      final chapasCliente = autosCliente.map((a) => a.chapa).toSet();
      print("🚗 Chapas del cliente: $chapasCliente");

      // Cargar TODAS las reservas y filtrar por chapa
      final rawReservas = await db.getAll("reservas.json");
      print("📋 Total reservas en BD: ${rawReservas.length}");

      reservasDelCliente.value =
          rawReservas.map((e) => Reserva.fromJson(e)).where((r) {
        final pertenece = chapasCliente.contains(r.chapaAuto);
        print(
            "📝 Reserva ${r.codigoReserva} - Chapa: ${r.chapaAuto} - Pertenece: $pertenece");
        return pertenece;
      }).toList();

      print("✅ Reservas del cliente encontradas: ${reservasDelCliente.length}");

      // Ordenar por fecha más reciente primero
      reservasDelCliente
          .sort((a, b) => b.horarioInicio.compareTo(a.horarioInicio));

      // Cargar pagos del cliente
      final rawPagos = await db.getAll("pagos.json");
      final codigosReservasCliente =
          reservasDelCliente.map((r) => r.codigoReserva).toSet();

      pagosDelCliente.value = rawPagos
          .map((e) => Pago.fromJson(e))
          .where(
              (p) => codigosReservasCliente.contains(p.codigoReservaAsociada))
          .toList();

      print("💳 Pagos del cliente encontrados: ${pagosDelCliente.length}");
    } catch (e) {
      print("❌ Error al cargar datos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  bool tienePago(String codigoReserva) {
    final tiene =
        pagosDelCliente.any((p) => p.codigoReservaAsociada == codigoReserva);
    print("💰 Reserva $codigoReserva tiene pago: $tiene");
    return tiene;
  }

  Future<bool> procesarPago(Reserva reserva) async {
    if (tienePago(reserva.codigoReserva)) {
      print("❌ La reserva ya tiene pago");
      return false;
    }

    try {
      print("💳 Procesando pago para reserva: ${reserva.codigoReserva}");

      // Crear el nuevo pago
      final nuevoPago = Pago(
        codigoPago: "PAG-${DateTime.now().millisecondsSinceEpoch}",
        codigoReservaAsociada: reserva.codigoReserva,
        montoPagado: reserva.monto,
        fechaPago: DateTime.now(),
        metodoPago: "TARJETA",
        estado: "COMPLETADO",
      );

      // Guardar el pago
      await db.add("pagos.json", nuevoPago.toJson());
      print("✅ Pago guardado: ${nuevoPago.codigoPago}");

      // Actualizar el estado de la reserva a PAGADA
      await actualizarEstadoReserva(reserva.codigoReserva, "PAGADA");

      // Recargar datos
      await cargarReservasYPagosDelCliente();

      return true;
    } catch (e) {
      print("❌ Error al procesar pago: $e");
      return false;
    }
  }

  Future<bool> cancelarReserva(Reserva reserva) async {
    try {
      print("🚫 Cancelando reserva: ${reserva.codigoReserva}");

      // Actualizar estado de la reserva a CANCELADA
      await actualizarEstadoReserva(reserva.codigoReserva, "CANCELADA");

      // Liberar el lugar de estacionamiento específico
      if (reserva.codigoLugar != null) {
        await liberarLugarEspecifico(reserva.codigoLugar!);
        print("🅿️ Lugar ${reserva.codigoLugar} liberado");
      }

      // Recargar datos
      await cargarReservasYPagosDelCliente();

      return true;
    } catch (e) {
      print("❌ Error al cancelar reserva: $e");
      return false;
    }
  }

  Future<void> actualizarEstadoReserva(
      String codigoReserva, String nuevoEstado) async {
    try {
      final reservas = await db.getAll("reservas.json");
      final index =
          reservas.indexWhere((r) => r['codigoReserva'] == codigoReserva);

      if (index != -1) {
        reservas[index]['estadoReserva'] = nuevoEstado;
        await db.saveAll("reservas.json", reservas);
        print("📝 Estado de reserva $codigoReserva actualizado a $nuevoEstado");
      }
    } catch (e) {
      print("❌ Error al actualizar estado de reserva: $e");
    }
  }

  Future<void> liberarLugarEspecifico(String codigoLugar) async {
    try {
      final lugares = await db.getAll("lugares.json");
      final index = lugares.indexWhere((l) => l['codigoLugar'] == codigoLugar);

      if (index != -1) {
        lugares[index]['estado'] = "DISPONIBLE";
        await db.saveAll("lugares.json", lugares);
        print("🅿️ Lugar $codigoLugar liberado en BD");
      }
    } catch (e) {
      print("❌ Error al liberar lugar: $e");
    }
  }

  String obtenerEstadoReserva(Reserva reserva) {
    if (tienePago(reserva.codigoReserva)) {
      return "PAGADA";
    }
    return reserva.estadoReserva;
  }

  Color obtenerColorEstado(String estado) {
    switch (estado) {
      case "PAGADA":
        return const Color(0xFF4CAF50); // Verde
      case "PENDIENTE":
        return const Color(0xFFFF9800); // Naranja
      case "CANCELADA":
        return const Color(0xFFF44336); // Rojo
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  Map<String, int> obtenerResumenReservas() {
    final resumen = <String, int>{
      'PENDIENTE': 0,
      'PAGADA': 0,
      'CANCELADA': 0,
    };

    for (final reserva in reservasDelCliente) {
      final estado = obtenerEstadoReserva(reserva);
      resumen[estado] = (resumen[estado] ?? 0) + 1;
    }

    print("📊 Resumen: $resumen");
    return resumen;
  }

  double obtenerTotalPagado() {
    final total =
        pagosDelCliente.fold(0.0, (total, pago) => total + pago.montoPagado);
    print("💰 Total pagado: ₲$total");
    return total;
  }

  // Método para refrescar datos manualmente
  Future<void> refrescar() async {
    await cargarReservasYPagosDelCliente();
  }
}
