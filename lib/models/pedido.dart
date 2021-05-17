class Pedido {
    Pedido({
        this.id,
        this.nombreProducto,
        this.precioUnitario,
        this.cantidad,
        this.totalPorProducto,
    });

    String id;
    String nombreProducto;
    String precioUnitario;
    String cantidad;
    String totalPorProducto;

    factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
        id: json["id"],
        nombreProducto: json["nombre_producto"],
        precioUnitario: json["precio_unitario"],
        cantidad: json["cantidad"],
        totalPorProducto: json["total_por_producto"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre_producto": nombreProducto,
        "precio_unitario": precioUnitario,
        "cantidad": cantidad,
        "total_por_producto": totalPorProducto,
    };
}