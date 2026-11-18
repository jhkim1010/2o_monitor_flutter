// [2026-11-18 usuario] Pantalla del cliente — mismo diseño que la ventana de Alt+Q del POS web
//   (mockup «2º Monitor — modal pequeño»): ① escaneo · ② cobro · ③ espera.
// Lógica pura (testeable): test/pantalla_cliente_logica_test.dart
import '../models/reading.dart';

enum ModoMonitor { clasico, cliente }

enum VistaCliente { escaneo, cobro, espera }

/// Sin escanear durante este tiempo, ① escaneo pasa a ② cobro (total + en letras + QR).
const Duration tiempoEscaneo = Duration(seconds: 20);

const String claveModoMonitor = 'modo_monitor';

ModoMonitor modoDesdeTexto(String? v) => v == 'cliente' ? ModoMonitor.cliente : ModoMonitor.clasico;

String modoATexto(ModoMonitor m) => m == ModoMonitor.cliente ? 'cliente' : 'clasico';

ModoMonitor alternar(ModoMonitor m) => m == ModoMonitor.cliente ? ModoMonitor.clasico : ModoMonitor.cliente;

/// Qué muestra la pantalla del cliente.
VistaCliente vistaCliente({required int cantidadLecturas, required DateTime? cambioEn, required DateTime ahora}) {
  if (cantidadLecturas == 0) return VistaCliente.espera;
  if (cambioEn == null) return VistaCliente.cobro;

  return ahora.difference(cambioEn) < tiempoEscaneo ? VistaCliente.escaneo : VistaCliente.cobro;
}

/// Huella de las lecturas: cambia si se agrega, quita o modifica una (cantidad o total), no sólo el id.
/// ★ La comparación vieja (sólo id_reading) no veía «2 ×» sobre el mismo renglón.
String firmaLecturas(List<Reading> rs) =>
    rs.map((r) => '${r.idReading}:${r.rcant}:${r.rcodigo}:${r.rtotal ?? ''}').join('|');
