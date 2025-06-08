import 'package:finpay/model/sitema_reservas.dart';
import 'package:get/get.dart';
import 'package:finpay/api/local.db.service.dart';

class ReservaController extends GetxController {
  RxList<Piso> pisos = <Piso>[].obs;
  Rx<Piso?> pisoSeleccionado = Rx<Piso?>(null);
  RxList<Lugar> lugaresDisponibles = <Lugar>[].obs;
  Rx<Lugar?> lugarSeleccionado = Rx<Lugar?>(null);
  Rx<DateTime?> horarioInicio = Rx<DateTime?>(null);
  Rx<DateTime?> horarioSalida = Rx<DateTime?>(null);
  RxInt duracionSeleccionada = 0.obs;
  final db = LocalDBService();
  RxList<Auto> autosCliente = <Auto>[].obs;
  Rx<Auto?> autoSeleccionado = Rx<Auto?>(null);
  String codigoClienteActual = 'cliente_1';

  @override
  void onInit() {
    super.onInit();
    resetearCampos();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      await cargarAutosDelCliente();
      await cargarPisosYLugares();
    } catch (e) {
      print("Error al cargar datos: $e");
    }
  }

  Future<void> cargarPisosYLugares() async {
    try {
      final rawPisos = await db.getAll("pisos.json");
      final rawLugares = await db.getAll("lugares.json");

      print("Pisos cargados: ${rawPisos.length}");
      print("Lugares cargados: ${rawLugares.length}");

      final todosLugares = rawLugares.map((e) => Lugar.fromJson(e)).toList();

      // Crear pisos únicos
      final pisosUnicos = <String, Map<String, dynamic>>{};
      for (var pJson in rawPisos) {
        pisosUnicos[pJson['codigo']] = pJson;
      }

      pisos.value = pisosUnicos.values.map((pJson) {
        final codigoPiso = pJson['codigo'];
        final lugaresDelPiso =
            todosLugares.where((l) => l.codigoPiso == codigoPiso).toList();

        return Piso(
          codigo: codigoPiso,
          descripcion: pJson['descripcion'],
          lugares: lugaresDelPiso,
        );
      }).toList();

      lugaresDisponibles.value = todosLugares;

      print("Pisos procesados: ${pisos.length}");
    } catch (e) {
      print("Error en cargarPisosYLugares: $e");
      // Datos de fallback
      pisos.value = [
        Piso(codigo: 'P1', descripcion: 'Piso 1 - Planta Baja', lugares: []),
        Piso(codigo: 'P2', descripcion: 'Piso 2 - Primer Piso', lugares: []),
      ];
      lugaresDisponibles.value = [];
    }
  }

  Future<void> seleccionarPiso(Piso piso) {
    pisoSeleccionado.value = piso;
    lugarSeleccionado.value = null;
    lugaresDisponibles.refresh();
    return Future.value();
  }

  Future<bool> confirmarReserva() async {
    if (pisoSeleccionado.value == null ||
        lugarSeleccionado.value == null ||
        horarioInicio.value == null ||
        horarioSalida.value == null ||
        autoSeleccionado.value == null) {
      print("Faltan datos para confirmar reserva");
      return false;
    }

    final duracionEnHoras =
        horarioSalida.value!.difference(horarioInicio.value!).inMinutes / 60;

    if (duracionEnHoras <= 0) {
      print("Duración inválida");
      return false;
    }

    final montoCalculado = (duracionEnHoras * 10000).roundToDouble();

    final nuevaReserva = Reserva(
      codigoReserva: "RES-${DateTime.now().millisecondsSinceEpoch}",
      horarioInicio: horarioInicio.value!,
      horarioSalida: horarioSalida.value!,
      monto: montoCalculado,
      estadoReserva: "PENDIENTE",
      chapaAuto: autoSeleccionado.value!.chapa,
      codigoLugar: lugarSeleccionado.value!.codigoLugar,
    );

    try {
      await db.add("reservas.json", nuevaReserva.toJson());
      await actualizarEstadoLugar(
          lugarSeleccionado.value!.codigoLugar, "RESERVADO");
      await cargarPisosYLugares();

      print("Reserva creada exitosamente: ${nuevaReserva.codigoReserva}");
      return true;
    } catch (e) {
      print("Error al guardar reserva: $e");
      return false;
    }
  }

  Future<void> actualizarEstadoLugar(
      String codigoLugar, String nuevoEstado) async {
    try {
      final lugares = await db.getAll("lugares.json");
      final index = lugares.indexWhere((l) => l['codigoLugar'] == codigoLugar);

      if (index != -1) {
        lugares[index]['estado'] = nuevoEstado;
        await db.saveAll("lugares.json", lugares);
        print("Estado del lugar $codigoLugar actualizado a $nuevoEstado");
      }
    } catch (e) {
      print("Error al actualizar estado del lugar: $e");
    }
  }

  void resetearCampos() {
    pisoSeleccionado.value = null;
    lugarSeleccionado.value = null;
    horarioInicio.value = null;
    horarioSalida.value = null;
    duracionSeleccionada.value = 0;
    autoSeleccionado.value = null;
  }

  Future<void> cargarAutosDelCliente() async {
    try {
      final rawAutos = await db.getAll("autos.json");
      final autos = rawAutos.map((e) => Auto.fromJson(e)).toList();

      autosCliente.value =
          autos.where((a) => a.clienteId == codigoClienteActual).toList();

      print("Autos del cliente cargados: ${autosCliente.length}");
    } catch (e) {
      print("Error al cargar autos: $e");
      // Datos de fallback
      autosCliente.value = [
        Auto(
          chapa: "ABC123",
          marca: "Toyota",
          modelo: "Corolla",
          chasis: "CHX123456789",
          clienteId: codigoClienteActual,
        ),
      ];
    }
  }

  @override
  void onClose() {
    resetearCampos();
    super.onClose();
  }
}
