import 'package:sqflite/sqflite.dart';
import 'package:dam_practica_agenda/modelo/tarea.dart';
import 'conexion.dart';

class DBTarea{
  static Future<int> insertarTarea(Tarea t) async{
    Database db = await Conexion.abrirDB();
    return db.insert("TAREA", t.toJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Tarea>> mostrarTarea() async{
    Database db = await Conexion.abrirDB();
    List<Map<String, dynamic>> resultado = await db.query("TAREA");

    return List.generate(resultado.length, (index) {
      return Tarea(
        idtarea: resultado[index]["IDTAREA"],
        idmateria:resultado[index]["IDMATERIA"],
        f_entrega: resultado[index]["F_ENTREGA"],
        descripcion: resultado[index]["DESCRIPCION"],
      );
    });
  }

  static Future<int> actulizarTarea(Tarea t)async{
    Database db = await Conexion.abrirDB();

    return db.update("TAREA", t.toJSON(), where: "IDTAREA=?", whereArgs: [t.idtarea]);
  }

  static Future<int> eliminarTarea(String idtarea)async{
    Database db = await Conexion.abrirDB();

    return db.delete("TAREA", where: "IDTAREA=?", whereArgs: [idtarea]);

  }
}