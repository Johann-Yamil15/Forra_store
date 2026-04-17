class UsoProducto {
  final int? idUsoProducto;
  final String strNombre;
  final String? strDescripcion;
  final bool bitActivo;

  UsoProducto({
    this.idUsoProducto,
    required this.strNombre,
    this.strDescripcion,
    required this.bitActivo,
  });

  factory UsoProducto.fromJson(Map<String, dynamic> json) => UsoProducto(
    idUsoProducto: json['idUsoProducto'],
    strNombre: json['strNombre'],
    strDescripcion: json['strDescripcion'],
    bitActivo: json['bitActivo'] == 1 || json['bitActivo'] == true,
  );

  Map<String, dynamic> toJson() => {
    'idUsoProducto': idUsoProducto,
    'strNombre': strNombre,
    'strDescripcion': strDescripcion,
    'bitActivo': bitActivo,
  };
}
