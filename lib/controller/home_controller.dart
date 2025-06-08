// ignore_for_file: deprecated_member_use
import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<TransactionModel> transactionList = List<TransactionModel>.empty().obs;
  RxBool isWeek = true.obs;
  RxBool isMonth = false.obs;
  RxBool isYear = false.obs;
  RxBool isAdd = false.obs;
  RxList<Pago> pagosPrevios = <Pago>[].obs;

  // NUEVAS VARIABLES PARA ESTADÍSTICAS DEL ESTACIONAMIENTO
  RxInt pagosDelMes = 0.obs;
  RxInt pagosPendientes = 0.obs;
  RxInt totalAutos = 0.obs;
  RxBool cargandoEstadisticas = false.obs;

  final db = LocalDBService();
  String codigoClienteActual = 'cliente_1';

  customInit() async {
    cargarPagosPrevios();
    await cargarEstadisticasEstacionamiento(); // Nueva función
    isWeek.value = true;
    isMonth.value = false;
    isYear.value = false;
    transactionList = [
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        DefaultImages.transaction4,
        "Apple Store",
        "iPhone 12 Case",
        "- \$120,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction3,
        "Ilya Vasil",
        "Wise • 5318",
        "- \$50,90",
        "05:39 AM",
      ),
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        "",
        "Burger King",
        "Cheeseburger XL",
        "- \$5,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction1,
        "Claudia Sarah",
        "Finpay Card • 5318",
        "- \$50,90",
        "04:39 AM",
      ),
    ];
  }

  Future<void> cargarPagosPrevios() async {
    final data = await db.getAll("pagos.json");
    pagosPrevios.value = data.map((json) => Pago.fromJson(json)).toList();
  }

  // NUEVA FUNCIÓN PARA CARGAR ESTADÍSTICAS DEL ESTACIONAMIENTO
  Future<void> cargarEstadisticasEstacionamiento() async {
    cargandoEstadisticas.value = true;

    try {
      print("📊 Cargando estadísticas del estacionamiento...");

      // 1. Cargar autos del cliente
      await _cargarTotalAutos();

      // 2. Cargar pagos del mes actual
      await _cargarPagosDelMes();

      // 3. Cargar pagos pendientes
      await _cargarPagosPendientes();

      print(
          "✅ Estadísticas cargadas - Autos: ${totalAutos.value}, Pagos mes: ${pagosDelMes.value}, Pendientes: ${pagosPendientes.value}");
    } catch (e) {
      print("❌ Error al cargar estadísticas: $e");
    } finally {
      cargandoEstadisticas.value = false;
    }
  }

  Future<void> _cargarTotalAutos() async {
    try {
      final rawAutos = await db.getAll("autos.json");
      final autosCliente = rawAutos
          .map((e) => Auto.fromJson(e))
          .where((a) => a.clienteId == codigoClienteActual)
          .toList();

      totalAutos.value = autosCliente.length;
      print("🚗 Total autos del cliente: ${totalAutos.value}");
    } catch (e) {
      print("❌ Error al cargar autos: $e");
      totalAutos.value = 0;
    }
  }

  Future<void> _cargarPagosDelMes() async {
    try {
      // Obtener chapas del cliente
      final rawAutos = await db.getAll("autos.json");
      final autosCliente = rawAutos
          .map((e) => Auto.fromJson(e))
          .where((a) => a.clienteId == codigoClienteActual)
          .toList();
      final chapasCliente = autosCliente.map((a) => a.chapa).toSet();

      // Obtener reservas del cliente
      final rawReservas = await db.getAll("reservas.json");
      final reservasCliente = rawReservas
          .map((e) => Reserva.fromJson(e))
          .where((r) => chapasCliente.contains(r.chapaAuto))
          .toList();
      final codigosReservasCliente =
          reservasCliente.map((r) => r.codigoReserva).toSet();

      // Obtener pagos del mes actual
      final rawPagos = await db.getAll("pagos.json");
      final ahora = DateTime.now();
      final inicioMes = DateTime(ahora.year, ahora.month, 1);
      final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

      final pagosDelMesActual = rawPagos
          .map((e) => Pago.fromJson(e))
          .where((p) =>
              codigosReservasCliente.contains(p.codigoReservaAsociada) &&
              p.fechaPago.isAfter(inicioMes) &&
              p.fechaPago.isBefore(finMes))
          .toList();

      pagosDelMes.value = pagosDelMesActual.length;
      print("💳 Pagos del mes actual: ${pagosDelMes.value}");
    } catch (e) {
      print("❌ Error al cargar pagos del mes: $e");
      pagosDelMes.value = 0;
    }
  }

  Future<void> _cargarPagosPendientes() async {
    try {
      // Obtener chapas del cliente
      final rawAutos = await db.getAll("autos.json");
      final autosCliente = rawAutos
          .map((e) => Auto.fromJson(e))
          .where((a) => a.clienteId == codigoClienteActual)
          .toList();
      final chapasCliente = autosCliente.map((a) => a.chapa).toSet();

      // Obtener reservas pendientes del cliente
      final rawReservas = await db.getAll("reservas.json");
      final reservasPendientes = rawReservas
          .map((e) => Reserva.fromJson(e))
          .where((r) =>
              chapasCliente.contains(r.chapaAuto) &&
              r.estadoReserva == "PENDIENTE")
          .toList();

      // Obtener pagos existentes
      final rawPagos = await db.getAll("pagos.json");
      final codigosReservasConPago = rawPagos
          .map((e) => Pago.fromJson(e))
          .map((p) => p.codigoReservaAsociada)
          .toSet();

      // Contar reservas pendientes sin pago
      final reservasSinPago = reservasPendientes
          .where((r) => !codigosReservasConPago.contains(r.codigoReserva))
          .toList();

      pagosPendientes.value = reservasSinPago.length;
      print("⏳ Pagos pendientes: ${pagosPendientes.value}");
    } catch (e) {
      print("❌ Error al cargar pagos pendientes: $e");
      pagosPendientes.value = 0;
    }
  }

  // Método para refrescar estadísticas manualmente
  Future<void> refrescarEstadisticas() async {
    print("🔄 Refrescando estadísticas manualmente...");
    await cargarEstadisticasEstacionamiento();
  }

  // Métodos helper para obtener información adicional
  String obtenerMesActual() {
    final meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return meses[DateTime.now().month - 1];
  }

  String obtenerTextoAutos() {
    if (totalAutos.value == 0) return "Sin autos";
    if (totalAutos.value == 1) return "1 auto";
    return "${totalAutos.value} autos";
  }

  String obtenerTextoPagosDelMes() {
    if (pagosDelMes.value == 0) return "Sin pagos";
    if (pagosDelMes.value == 1) return "1 pago";
    return "${pagosDelMes.value} pagos";
  }

  String obtenerTextoPagosPendientes() {
    if (pagosPendientes.value == 0) return "Sin pendientes";
    if (pagosPendientes.value == 1) return "1 pendiente";
    return "${pagosPendientes.value} pendientes";
  }
}
