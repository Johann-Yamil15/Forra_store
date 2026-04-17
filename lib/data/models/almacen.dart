class Almacen {
  final int? idAlmacen;
  final String strNombre;
  final String? strUbicacion;

  Almacen({this.idAlmacen, required this.strNombre, this.strUbicacion});

  factory Almacen.fromJson(Map<String, dynamic> json) => Almacen(
    idAlmacen: json['idAlmacen'],
    strNombre: json['strNombre'],
    strUbicacion: json['strUbicacion'],
  );

  Map<String, dynamic> toJson() => {
    'idAlmacen': idAlmacen,
    'strNombre': strNombre,
    'strUbicacion': strUbicacion,
  };
}
