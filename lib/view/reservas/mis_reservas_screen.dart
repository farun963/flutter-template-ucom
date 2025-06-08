import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/pago_controller.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/utils/utiles.dart';

class MisReservasScreen extends StatelessWidget {
  final controller = Get.put(PagoController());

  MisReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Mis Reservas",
          style: TextStyle(color: Colors.greenAccent),
        ),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.greenAccent),
            onPressed: () async {
              print("🔄 Refrescando datos manualmente...");
              await controller.refrescar();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.greenAccent),
                SizedBox(height: 16),
                Text(
                  "Cargando reservas...",
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ],
            ),
          );
        }

        print(
            "🔍 Total reservas a mostrar: ${controller.reservasDelCliente.length}");

        if (controller.reservasDelCliente.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  "No tenés reservas registradas",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Creá tu primera reserva desde el home",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    print("🔄 Recargando datos...");
                    await controller.refrescar();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Recargar"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          backgroundColor: Colors.black,
          color: Colors.greenAccent,
          onRefresh: () async {
            await controller.refrescar();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.reservasDelCliente.length,
            itemBuilder: (context, index) {
              final reserva = controller.reservasDelCliente[index];
              final estado = controller.obtenerEstadoReserva(reserva);
              final colorEstado = controller.obtenerColorEstado(estado);
              final tienePago = controller.tienePago(reserva.codigoReserva);

              return Card(
                color: Colors.grey.shade900,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.greenAccent.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con código y estado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              reserva.codigoReserva,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorEstado,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              estado,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Información de la reserva
                      _buildInfoRow("Auto:", reserva.chapaAuto),
                      if (reserva.codigoLugar != null)
                        _buildInfoRow("Lugar:", reserva.codigoLugar!),
                      _buildInfoRow(
                        "Inicio:",
                        "${UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio)} ${TimeOfDay.fromDateTime(reserva.horarioInicio).format(context)}",
                      ),
                      _buildInfoRow(
                        "Salida:",
                        "${UtilesApp.formatearFechaDdMMAaaa(reserva.horarioSalida)} ${TimeOfDay.fromDateTime(reserva.horarioSalida).format(context)}",
                      ),
                      _buildInfoRow(
                        "Monto:",
                        UtilesApp.formatearGuaranies(reserva.monto),
                      ),

                      const SizedBox(height: 16),

                      // Botones de acción
                      Row(
                        children: [
                          if (!tienePago && estado != "CANCELADA") ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () =>
                                    _mostrarDialogoPago(context, reserva),
                                icon: const Icon(Icons.payment, size: 18),
                                label: const Text("Pagar"),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (estado == "PENDIENTE") ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _mostrarDialogoCancelacion(
                                    context, reserva),
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text("Cancelar"),
                              ),
                            ),
                          ],
                          if (estado == "PAGADA" || estado == "CANCELADA")
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colorEstado.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colorEstado),
                                ),
                                child: Text(
                                  estado == "PAGADA"
                                      ? "✓ Reserva pagada"
                                      : "✗ Reserva cancelada",
                                  style: TextStyle(
                                    color: colorEstado,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoPago(BuildContext context, Reserva reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.greenAccent.withOpacity(0.3),
          ),
        ),
        title: const Text(
          "💳 Confirmar Pago",
          style: TextStyle(color: Colors.greenAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¿Estás seguro de que querés pagar esta reserva?",
              style: TextStyle(color: Colors.grey.shade300),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reserva: ${reserva.codigoReserva}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Monto: ${UtilesApp.formatearGuaranies(reserva.monto)}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Método: Tarjeta de Crédito",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Get.back();

              // Mostrar loading
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(color: Colors.greenAccent),
                ),
                barrierDismissible: false,
              );

              await Future.delayed(
                  const Duration(seconds: 2)); // Simular procesamiento
              final exito = await controller.procesarPago(reserva);

              Get.back(); // Cerrar loading

              if (exito) {
                Get.snackbar(
                  "✅ Pago Exitoso",
                  "El pago se procesó correctamente",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.black,
                  colorText: Colors.greenAccent,
                  icon:
                      const Icon(Icons.check_circle, color: Colors.greenAccent),
                );
              } else {
                Get.snackbar(
                  "❌ Error",
                  "No se pudo procesar el pago",
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade900,
                  icon: const Icon(Icons.error, color: Colors.red),
                );
              }
            },
            child: const Text("Confirmar Pago"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCancelacion(BuildContext context, Reserva reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.red.withOpacity(0.3),
          ),
        ),
        title: const Text(
          "🚫 Cancelar Reserva",
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¿Estás seguro de que querés cancelar esta reserva?",
              style: TextStyle(color: Colors.grey.shade300),
            ),
            const SizedBox(height: 12),
            Text(
              "⚠️ Esta acción no se puede deshacer y el lugar de estacionamiento será liberado.",
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reserva: ${reserva.codigoReserva}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (reserva.codigoLugar != null)
                    Text(
                      "Lugar: ${reserva.codigoLugar}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "No cancelar",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();

              // Mostrar loading
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                ),
                barrierDismissible: false,
              );

              final exito = await controller.cancelarReserva(reserva);

              Get.back(); // Cerrar loading

              if (exito) {
                Get.snackbar(
                  "✅ Reserva Cancelada",
                  "La reserva fue cancelada y el lugar liberado",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.black,
                  colorText: Colors.greenAccent,
                  icon:
                      const Icon(Icons.check_circle, color: Colors.greenAccent),
                );
              } else {
                Get.snackbar(
                  "❌ Error",
                  "No se pudo cancelar la reserva",
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade900,
                  icon: const Icon(Icons.error, color: Colors.red),
                );
              }
            },
            child: const Text("Confirmar Cancelación"),
          ),
        ],
      ),
    );
  }
}
