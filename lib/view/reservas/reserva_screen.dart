import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/utils/utiles.dart';

class ReservaScreen extends StatelessWidget {
  final controller = Get.put(ReservaController());

  ReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Reservar lugar",
          style: TextStyle(color: Colors.greenAccent),
        ),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Seleccionar auto",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade900,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Auto>(
                      isExpanded: true,
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.greenAccent),
                      value: controller.autoSeleccionado.value,
                      hint: const Text("Seleccionar auto",
                          style: TextStyle(color: Colors.green)),
                      onChanged: (auto) {
                        controller.autoSeleccionado.value = auto;
                      },
                      items: controller.autosCliente.map((a) {
                        final nombre = "${a.chapa} - ${a.marca} ${a.modelo}";
                        return DropdownMenuItem(
                            value: a,
                            child: Text(nombre,
                                style: const TextStyle(
                                    color: Colors.greenAccent)));
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar piso",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade900,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.greenAccent),
                      value: controller.pisoSeleccionado.value?.codigo,
                      hint: const Text("Seleccionar piso",
                          style: TextStyle(color: Colors.green)),
                      onChanged: (codigoPiso) {
                        if (codigoPiso != null) {
                          final piso = controller.pisos
                              .firstWhere((p) => p.codigo == codigoPiso);
                          controller.seleccionarPiso(piso);
                        }
                      },
                      items: controller.pisos
                          .map((p) => DropdownMenuItem(
                              value: p.codigo,
                              child: Text(p.descripcion,
                                  style: const TextStyle(
                                      color: Colors.greenAccent))))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar lugar",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: Obx(() {
                    final lugaresFiltrados = controller.lugaresDisponibles
                        .where((l) =>
                            l.codigoPiso ==
                            controller.pisoSeleccionado.value?.codigo)
                        .toList();

                    if (lugaresFiltrados.isEmpty) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.greenAccent),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Selecciona un piso para ver lugares disponibles",
                            style: TextStyle(color: Colors.greenAccent),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return GridView.count(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: lugaresFiltrados.map((lugar) {
                        final seleccionado = lugar.codigoLugar ==
                            controller.lugarSeleccionado.value?.codigoLugar;
                        final color = lugar.estado == "RESERVADO"
                            ? Colors.red
                            : seleccionado
                                ? Colors.greenAccent.shade400
                                : Colors.grey.shade800;

                        return GestureDetector(
                          onTap: lugar.estado == "DISPONIBLE"
                              ? () => controller.lugarSeleccionado.value = lugar
                              : null,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                  color: seleccionado
                                      ? Colors.green
                                      : Colors.green.shade900),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lugar.codigoLugar,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lugar.estado == "RESERVADO"
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar horarios",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade400,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date == null) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time == null) return;
                          controller.horarioInicio.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        },
                        icon: const Icon(Icons.access_time),
                        label: Obx(() => Text(
                              controller.horarioInicio.value == null
                                  ? "Inicio"
                                  : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioInicio.value!)} ${TimeOfDay.fromDateTime(controller.horarioInicio.value!).format(context)}",
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade400,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: controller.horarioInicio.value ??
                                DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date == null) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time == null) return;
                          controller.horarioSalida.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        },
                        icon: const Icon(Icons.timer_off),
                        label: Obx(() => Text(
                              controller.horarioSalida.value == null
                                  ? "Salida"
                                  : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioSalida.value!)} ${TimeOfDay.fromDateTime(controller.horarioSalida.value!).format(context)}",
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Duración rápida",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 4, 6, 8].map((horas) {
                    final seleccionada =
                        controller.duracionSeleccionada.value == horas;
                    return ChoiceChip(
                      label: Text("$horas h",
                          style: const TextStyle(color: Colors.black)),
                      selected: seleccionada,
                      selectedColor: Colors.greenAccent.shade400,
                      backgroundColor: Colors.grey.shade800,
                      onSelected: (_) {
                        controller.duracionSeleccionada.value = horas;
                        final inicio =
                            controller.horarioInicio.value ?? DateTime.now();
                        controller.horarioInicio.value = inicio;
                        controller.horarioSalida.value =
                            inicio.add(Duration(hours: horas));
                      },
                    );
                  }).toList(),
                ),
                Obx(() {
                  final inicio = controller.horarioInicio.value;
                  final salida = controller.horarioSalida.value;

                  if (inicio == null || salida == null) return const SizedBox();

                  final minutos = salida.difference(inicio).inMinutes;
                  final horas = minutos / 60;
                  final monto = (horas * 10000).round();

                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.greenAccent),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade900,
                      ),
                      child: Text(
                        "Monto estimado: ₲${UtilesApp.formatearGuaranies(monto)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                            fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      // Mostrar loading
                      Get.dialog(
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.greenAccent,
                          ),
                        ),
                        barrierDismissible: false,
                      );

                      final confirmada = await controller.confirmarReserva();

                      // Cerrar loading
                      Get.back();

                      if (confirmada) {
                        Get.snackbar(
                          "✅ Reserva Exitosa",
                          "Tu reserva se registró correctamente",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black,
                          colorText: Colors.greenAccent,
                          icon: const Icon(Icons.check_circle,
                              color: Colors.greenAccent),
                        );

                        // Resetear campos después de exitoso
                        controller.resetearCampos();

                        await Future.delayed(
                            const Duration(milliseconds: 1500));
                        Get.back();
                      } else {
                        Get.snackbar(
                          "❌ Error",
                          "Verificá que todos los campos estén completos",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.shade700,
                          colorText: Colors.white,
                          icon: const Icon(Icons.error, color: Colors.white),
                        );
                      }
                    },
                    child: const Text(
                      "Confirmar Reserva",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
