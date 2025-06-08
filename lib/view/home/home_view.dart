// ignore_for_file: deprecated_member_use

import 'package:card_swiper/card_swiper.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/view/home/top_up_screen.dart';
import 'package:finpay/view/home/transfer_screen.dart';
import 'package:finpay/view/home/widget/circle_card.dart';
import 'package:finpay/view/home/widget/custom_card.dart';
import 'package:finpay/view/home/widget/transaction_list.dart';
// IMPORTS PARA ESTACIONAMIENTO
import 'package:finpay/view/reservas/reserva_screen.dart';
import 'package:finpay/view/reservas/mis_reservas_screen.dart';
import 'package:finpay/controller/pago_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController;

  const HomeView({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.isLightTheme == false
          ? const Color(0xff15141F)
          : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                    ),
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 28,
                      width: 69,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6A609).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            DefaultImages.ranking,
                          ),
                          Text(
                            "Gold",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: const Color(0xffF6A609),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(
                        DefaultImages.avatar,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.isLightTheme == false
                              ? HexColor('#15141f')
                              : Theme.of(context).appBarTheme.backgroundColor,
                          border: Border.all(
                            color: HexColor(AppTheme.primaryColorString!)
                                .withOpacity(0.05),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              customContainer(
                                title: "USD",
                                background: AppTheme.primaryColorString,
                                textColor: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              customContainer(
                                title: "IDR",
                                background: AppTheme.isLightTheme == false
                                    ? '#211F32'
                                    : "#FFFFFF",
                                textColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: HexColor(AppTheme.primaryColorString!),
                            size: 20,
                          ),
                          Text(
                            "Add Currency",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: HexColor(AppTheme.primaryColorString!),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                    height: 180,
                    width: Get.width,
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return SvgPicture.asset(
                          DefaultImages.debitcard,
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: 3,
                      viewportFraction: 1,
                      scale: 0.9,
                      autoplay: true,
                      itemWidth: Get.width,
                      itemHeight: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // *** NUEVA SECCIÓN DE ESTADÍSTICAS DEL ESTACIONAMIENTO ***
                _buildEstadisticasEstacionamiento(context),
                const SizedBox(height: 20),

                // SECCIÓN DE ACCIONES ORIGINALES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.to(const TopUpSCreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: circleCard(
                        image: DefaultImages.topup,
                        title: "Top-up",
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {},
                      child: circleCard(
                        image: DefaultImages.withdraw,
                        title: "Withdraw",
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.to(const TransferScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: circleCard(
                        image: DefaultImages.transfer,
                        title: "Transfer",
                      ),
                    )
                  ],
                ),

                // SECCIÓN DE ESTACIONAMIENTO
                const SizedBox(height: 30),
                _buildEstacionamientoSection(context),
                const SizedBox(height: 30),

                // SECCIÓN DE TRANSACCIONES ORIGINAL
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withOpacity(0.10),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Transactions",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              Text(
                                "See all",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: HexColor(
                                            AppTheme.primaryColorString!)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            for (var i = 0;
                                i < homeController.transactionList.length;
                                i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: transactionList(
                                  homeController.transactionList[i].image,
                                  homeController.transactionList[i].background,
                                  homeController.transactionList[i].title,
                                  homeController.transactionList[i].subTitle,
                                  homeController.transactionList[i].price,
                                  homeController.transactionList[i].time,
                                ),
                              )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // *** NUEVA SECCIÓN DE ESTADÍSTICAS ***
  Widget _buildEstadisticasEstacionamiento(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.isLightTheme == false
              ? const Color(0xff211F32)
              : const Color(0xffFFFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff000000).withOpacity(0.10),
              blurRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con botón de refresh
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Estadísticas del Estacionamiento",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Obx(() => GestureDetector(
                        onTap: homeController.cargandoEstadisticas.value
                            ? null
                            : () => homeController.refrescarEstadisticas(),
                        child: Icon(
                          Icons.refresh,
                          color: homeController.cargandoEstadisticas.value
                              ? Colors.grey
                              : HexColor(AppTheme.primaryColorString!),
                          size: 20,
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // Estadísticas en tres columnas
              Obx(() {
                if (homeController.cargandoEstadisticas.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                return Row(
                  children: [
                    // Pagos del mes
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.payment,
                        iconColor: Colors.green,
                        backgroundColor: Colors.green.withOpacity(0.1),
                        title: "Pagos ${homeController.obtenerMesActual()}",
                        value: homeController.pagosDelMes.value.toString(),
                        subtitle: homeController.obtenerTextoPagosDelMes(),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Pagos pendientes
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.pending_actions,
                        iconColor: Colors.orange,
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        title: "Pendientes",
                        value: homeController.pagosPendientes.value.toString(),
                        subtitle: homeController.obtenerTextoPagosPendientes(),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Total autos
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.directions_car,
                        iconColor: Colors.blue,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        title: "Mis Autos",
                        value: homeController.totalAutos.value.toString(),
                        subtitle: homeController.obtenerTextoAutos(),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.isLightTheme == false
            ? const Color(0xff15141F)
            : const Color(0xffF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Ícono con fondo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),

          // Valor principal
          Text(
            value,
            style: TextStyle(
              color: iconColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),

          // Título
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).textTheme.bodySmall!.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),

          // Subtítulo
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).textTheme.bodySmall!.color,
                  fontSize: 9,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // FUNCIÓN DE ESTACIONAMIENTO EXISTENTE
  Widget _buildEstacionamientoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.isLightTheme == false
              ? const Color(0xff211F32)
              : const Color(0xffFFFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff000000).withOpacity(0.10),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Estacionamiento",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Navegando a Mis Reservas");
                      Get.to(() => MisReservasScreen());
                    },
                    child: Text(
                      "Ver todas",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: HexColor(AppTheme.primaryColorString!)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      "Nueva Reserva",
                      "Reservar lugar",
                      Icons.add_location_alt,
                      HexColor(AppTheme.primaryColorString!),
                      () {
                        print("Navegando a Nueva Reserva");
                        Get.to(() => ReservaScreen());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      "Mis Reservas",
                      "Gestionar",
                      Icons.receipt_long,
                      Colors.blueAccent,
                      () {
                        print("Navegando a Mis Reservas");
                        Get.to(() => MisReservasScreen());
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Resumen de reservas
            _buildResumenReservas(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.isLightTheme == false
              ? const Color(0xff15141F)
              : const Color(0xffF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenReservas(BuildContext context) {
    try {
      final pagoController = Get.put(PagoController());

      return Obx(() {
        final resumen = pagoController.obtenerResumenReservas();
        final total = resumen.values.fold(0, (sum, value) => sum + value);

        if (total == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.isLightTheme == false
                    ? const Color(0xff15141F)
                    : const Color(0xffF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      HexColor(AppTheme.primaryColorString!).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: HexColor(AppTheme.primaryColorString!),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "No tenés reservas registradas",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                            fontSize: 14,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.isLightTheme == false
                  ? const Color(0xff15141F)
                  : const Color(0xffF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: HexColor(AppTheme.primaryColorString!).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Resumen de Reservas",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: HexColor(AppTheme.primaryColorString!),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResumenItem(context, "Pendientes",
                        resumen['PENDIENTE'] ?? 0, Colors.orange),
                    _buildResumenItem(context, "Pagadas",
                        resumen['PAGADA'] ?? 0, Colors.green),
                    _buildResumenItem(context, "Canceladas",
                        resumen['CANCELADA'] ?? 0, Colors.red),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    } catch (e) {
      print("Error en resumen de reservas: $e");
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          "Error al cargar resumen",
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  Widget _buildResumenItem(
      BuildContext context, String label, int cantidad, Color color) {
    return Column(
      children: [
        Text(
          cantidad.toString(),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}
