class Reading {
  final int rcant;
  final String rcodigo;
  final String rexp;
  final double rprecio;
  final double? rtotal;
  final int idReading;

  Reading({
    required this.rcant,
    required this.rcodigo,
    required this.rexp,
    required this.rprecio,
    this.rtotal,
    required this.idReading,
  });

  factory Reading.fromMap(Map<String, dynamic> map) {
    return Reading(
      rcant: map['rcant'] as int,
      rcodigo: map['rcodigo'] as String? ?? '',
      rexp: map['rexp'] as String? ?? '',
      rprecio: (map['rprecio'] as num).toDouble(),
      rtotal: map['rtotal'] != null ? (map['rtotal'] as num).toDouble() : null,
      idReading: map['id_reading'] as int,
    );
  }
}

