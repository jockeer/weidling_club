import 'dart:io';

import 'package:weidling/models/pedido.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
export 'package:weidling/models/pedido.dart';


class DBProvider {

  static Database _database; 
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {

    if ( _database != null ) return _database;

    _database = await initDB();
    return _database;
  }


  initDB() async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join( documentsDirectory.path, 'PedidosDB.db' );

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: ( Database db, int version ) async {
        await db.execute(
          'CREATE TABLE Pedido ('
          ' id              TEXT PRIMARY KEY,'
          ' nombre_producto TEXT,'
          ' precio_unitario TEXT,'
          ' cantidad        TEXT,'
          ' total_por_producto TEXT'
          ')'
        );
      }
    
    );

  }

  // CREAR Registros
  nuevoPedidoRaw( Pedido nuevoPedido ) async {

    final db  = await database;

    final res = await db.rawInsert(
      "INSERT Into Pedido (id, nombre_producto, precio_unitario, cantidad, total_por_producto  ) "
      "VALUES ( ${ nuevoPedido.id }, '${ nuevoPedido.nombreProducto }', '${ nuevoPedido.precioUnitario }', '${ nuevoPedido.cantidad }', '${ nuevoPedido.totalPorProducto }' )"
    );
    return res;

  }

  Future<int> nuevoPedido( Pedido nuevoPedido ) async {

    final db  = await database;
    var res;
     
     try {
      res = await db.insert('Pedido', nuevoPedido.toJson() );  
     } catch (e) {
       res = 0;
       updatePedido(nuevoPedido);
       return res;
     }

    return res;
  }


  // SELECT - Obtener información
  Future<Pedido> getPedidoId( String id ) async {

    final db  = await database;
    final res = await db.query('Pedido', where: 'id = ?', whereArgs: [id]  );
    return res.isNotEmpty ? Pedido.fromJson( res.first ) : null;

  }

  Future<List<Pedido>> getAllPedidos() async {

    final db  = await database;
    final res = await db.query('Pedido');

    List<Pedido> list = res.isNotEmpty 
                              ? res.map( (pedido) => Pedido.fromJson(pedido) ).toList()
                              : [];
    return list;
  }

  /*Future<List<ScanModel>> getScansPorTipo( String tipo ) async {

    final db  = await database;
    final res = await db.rawQuery("SELECT * FROM Scans WHERE tipo='$tipo'");

    List<ScanModel> list = res.isNotEmpty 
                              ? res.map( (c) => ScanModel.fromJson(c) ).toList()
                              : [];
    return list;
  } */

  // Actualizar Registros
  Future<int> updatePedido( Pedido nuevoPedido ) async {

    final db  = await database;
    final res = await db.update('Pedido', nuevoPedido.toJson(), where: 'id = ?', whereArgs: [nuevoPedido.id] );

    return res;
  }

  // Eliminar registros
  Future<int> deletePedido( String id ) async {

    final db  = await database;
    final res = await db.delete('Pedido', where: 'id = ?', whereArgs: [id]);
    return res;
  }

  Future<int> deleteAll() async {

    final db  = await database;
    final res = await db.rawDelete('DELETE FROM Pedido');
    return res;

  }

}