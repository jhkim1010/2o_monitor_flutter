// [2026-11-18 usuario] Pantalla del cliente (modo nuevo del monitor). Mismo diseño que el POS web:
//   ① escaneo: lista completa (la nueva abajo, resaltada) + lectura actual a la derecha + Importe Final
//   ② cobro:   Importe Final grande + en letras + QR a app.coolsistema.com («by Ventago»)
//   ③ espera:  sin lecturas — fecha/hora + QR
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/reading.dart';
import 'pantalla_cliente_logica.dart';

const _fondo = Color(0xFF0F1A2E);
const _acento = Color(0xFF1E3A8A);
const _urlQr = 'https://app.coolsistema.com';

class PantallaCliente extends StatefulWidget {
  final List<Reading> lecturas;
  final Reading? ultima;
  final double total;
  final DateTime? cambioEn;
  final String Function(double) enLetras;
  final String Function(double) formatear;
  final String titulo;

  const PantallaCliente({
    super.key,
    required this.lecturas,
    required this.ultima,
    required this.total,
    required this.cambioEn,
    required this.enLetras,
    required this.formatear,
    required this.titulo,
  });

  @override
  State<PantallaCliente> createState() => _PantallaClienteState();
}

class _PantallaClienteState extends State<PantallaCliente> {
  Timer? _reloj;
  DateTime _ahora = DateTime.now();

  @override
  void initState() {
    super.initState();
    // reloj de ③ y paso ① → ② sin escanear
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _ahora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  Widget _qr({required double size, required bool oscuro}) {
    final color = oscuro ? const Color(0xFFC7D2E3) : const Color(0xFF374151);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('by Ventago', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 4),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(6),
          child: QrImageView(data: _urlQr, version: QrVersions.auto, size: size),
        ),
        const SizedBox(height: 4),
        Text('app.coolsistema.com', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _marca(double opacidad) => Opacity(
        opacity: opacidad,
        child: Center(
          child: Text(
            widget.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: Color(0xFFE8EDF5)),
          ),
        ),
      );

  String get _articulos {
    final n = widget.lecturas.fold<int>(0, (a, r) => a + r.rcant);

    return '$n ${n == 1 ? 'artículo' : 'artículos'}';
  }

  @override
  Widget build(BuildContext context) {
    final vista = vistaCliente(cantidadLecturas: widget.lecturas.length, cambioEn: widget.cambioEn, ahora: _ahora);

    if (vista == VistaCliente.espera) return _espera();

    final u = widget.ultima;

    return Container(
      color: _fondo,
      child: Stack(
        children: [
          _marca(0.3),
          Container(color: const Color(0x8C050A14)),
          if (vista == VistaCliente.escaneo && u != null) ..._escaneo(u) else _cobro(),
        ],
      ),
    );
  }

  Widget _espera() {
    final fecha = DateFormat("EEEE, d 'de' MMMM 'de' y", 'es').format(_ahora);
    final hora = DateFormat('HH:mm:ss').format(_ahora);

    return Container(
      color: _fondo,
      child: Stack(
        children: [
          _marca(1),
          Positioned(
            left: 24,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hora, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xFFE8EDF5))),
                Text(
                  fecha.isEmpty ? '' : fecha[0].toUpperCase() + fecha.substring(1),
                  style: const TextStyle(fontSize: 18, color: Color(0xFFC7D2E3)),
                ),
              ],
            ),
          ),
          Positioned(right: 24, bottom: 20, child: _qr(size: 96, oscuro: true)),
        ],
      ),
    );
  }

  static const double _altoFila = 44;

  Widget _fila(Reading r, bool activa) {
    final estilo = TextStyle(
      fontSize: activa ? 20 : 19,
      fontWeight: activa ? FontWeight.w800 : FontWeight.w400,
      color: activa ? _acento : const Color(0xFF111827),
    );

    return Container(
      height: _altoFila,
      padding: EdgeInsets.only(left: activa ? 14 : 20, right: 20),
      decoration: BoxDecoration(
        color: activa ? const Color(0xFFDBEAFE) : null,
        border: Border(
          top: const BorderSide(color: Color(0xFFF3F4F6)),
          left: activa ? const BorderSide(color: _acento, width: 6) : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text('${r.rcant}', style: estilo)),
          Expanded(
            child: Text(r.rexp.isEmpty ? r.rcodigo : r.rexp, maxLines: 1, overflow: TextOverflow.ellipsis, style: estilo),
          ),
          SizedBox(
            width: 130,
            child: Text('\$ ${widget.formatear(r.rtotal ?? r.rprecio * r.rcant)}', textAlign: TextAlign.right, style: estilo),
          ),
        ],
      ),
    );
  }

  /// [2026-11-18 usuario — mockup ①' aprobado] lista completa (la más nueva abajo) + artículo actual.
  ///   Sin foto: ACE III no tiene las fotos de Ventago (usuario: «사진 없으면 칸 없애고»).
  ///   id_reading 0 = la última lectura → orden de id dado vuelta = la nueva abajo.
  List<Widget> _escaneo(Reading u) {
    final lineas = widget.lecturas.reversed.toList();
    const cabecera = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563));

    final lista = Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFFF3F4F6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Row(children: [
              SizedBox(width: 56, child: Text('Cant.', style: cabecera)),
              Expanded(child: Text('Artículo', style: cabecera)),
              SizedBox(width: 130, child: Text('Subtotal', textAlign: TextAlign.right, style: cabecera)),
            ]),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              // entran N filas; si sobran, se ven las últimas y arriba «▲ N más arriba»
              var caben = (c.maxHeight / _altoFila).floor();
              var ocultas = lineas.length - caben;
              if (ocultas > 0) {
                caben = ((c.maxHeight - 26) / _altoFila).floor();
                ocultas = lineas.length - caben;
              }
              final visibles = ocultas > 0 ? lineas.sublist(ocultas) : lineas;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (ocultas > 0)
                    SizedBox(
                      height: 26,
                      child: Center(
                        child: Text('▲ $ocultas ${ocultas == 1 ? 'artículo' : 'artículos'} más arriba',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ),
                    ),
                  for (final r in visibles) _fila(r, identical(r, u) || r.idReading == u.idReading),
                ],
              );
            }),
          ),
        ],
      ),
    );

    const gris = Color(0xFFC7D2E3);
    final actual = Container(
      color: _fondo,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('AHORA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1, color: gris)),
          const SizedBox(height: 8),
          Text('${u.rcant} ×', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
          const SizedBox(height: 8),
          Text(u.rcodigo, style: const TextStyle(fontSize: 16, color: gris)),
          const SizedBox(height: 14),
          Text(u.rexp,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Precio unitario', style: TextStyle(fontSize: 20, color: gris)),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('\$ ${widget.formatear(u.rprecio)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: gris)),
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: Color(0xFF33415A)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: gris)),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('\$ ${widget.formatear(u.rtotal ?? u.rprecio * u.rcant)}',
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return [
      Positioned.fill(
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Expanded(flex: 55, child: lista), Expanded(flex: 45, child: actual)],
              ),
            ),
            Container(
              height: 84,
              color: _acento,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Importe Final · $_articulos',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(width: 16),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('\$ ${widget.formatear(widget.total)}',
                          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _cobro() {
    return Center(
      child: Container(
        width: 720,
        height: 460,
        margin: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 60, offset: Offset(0, 24))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 24, 36, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Importe Final · $_articulos',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                  FittedBox(
                    alignment: Alignment.centerRight,
                    fit: BoxFit.scaleDown,
                    child: Text('\$ ${widget.formatear(widget.total)}',
                        style: const TextStyle(fontSize: 84, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 40,
                    child: Container(
                      color: _acento,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        child: Text(widget.enLetras(widget.total),
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, height: 1.25)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 14,
                    child: Container(
                      color: const Color(0xFFF3F4F6),
                      alignment: Alignment.center,
                      child: _qr(size: 120, oscuro: false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
