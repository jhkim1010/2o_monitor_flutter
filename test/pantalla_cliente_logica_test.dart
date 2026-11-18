import 'package:flutter_monitor/models/reading.dart';
import 'package:flutter_monitor/screens/pantalla_cliente_logica.dart';
import 'package:flutter_test/flutter_test.dart';

Reading r(int id, int cant, double? total) =>
    Reading(rcant: cant, rcodigo: 'C$id', rexp: 'x', rprecio: 10, rtotal: total, idReading: id);

void main() {
  test('modo: alterna y se guarda como texto', () {
    expect(alternar(ModoMonitor.clasico), ModoMonitor.cliente);
    expect(alternar(ModoMonitor.cliente), ModoMonitor.clasico);
    expect(modoDesdeTexto(null), ModoMonitor.clasico);
    expect(modoDesdeTexto(modoATexto(ModoMonitor.cliente)), ModoMonitor.cliente);
  });

  test('vista: vacío → espera; recién escaneado → escaneo; 20 s sin escanear → cobro', () {
    final t0 = DateTime(2026, 11, 18, 12);
    expect(vistaCliente(cantidadLecturas: 0, cambioEn: t0, ahora: t0), VistaCliente.espera);
    expect(vistaCliente(cantidadLecturas: 2, cambioEn: t0, ahora: t0.add(const Duration(seconds: 19))),
        VistaCliente.escaneo);
    expect(vistaCliente(cantidadLecturas: 2, cambioEn: t0, ahora: t0.add(const Duration(seconds: 20))),
        VistaCliente.cobro);
  });

  test('★ firma: cambia con la cantidad del mismo renglón (antes sólo se miraba el id)', () {
    expect(firmaLecturas([r(0, 1, 10)]), isNot(firmaLecturas([r(0, 2, 20)])));
    expect(firmaLecturas([r(0, 1, 10)]), firmaLecturas([r(0, 1, 10)]));
  });
}
