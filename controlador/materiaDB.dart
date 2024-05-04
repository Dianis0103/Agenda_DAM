import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../modelo/materia.dart';
import 'conexion.dart';

class DBmateria{
  static Future<int> insertarMateria(Materia m) async{
    Database db = await Conexion.abrirDB();
    return db.insert("MATERIA", m.toJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Materia>> mostrarMateria() async{
    Database db = await Conexion.abrirDB();
    List<Map<String, dynamic>> resultado = await db.query("MATERIA");

    return List.generate(resultado.length, (index) {
      return Materia(
        idmateria: resultado[index]["IDMATERIA"],
        nombre:resultado[index]["NOMBRE"],
        semestre: resultado[index]["SEMESTRE"],
        docente: resultado[index]["DOCENTE"],
      );
    });
  }

  static Future<int> actulizarMateria(Materia m)async{
    Database db = await Conexion.abrirDB();

    return db.update("MATERIA", m.toJSON(), where: "IDMATERIA=?", whereArgs: [m.idmateria]);
  }

  static Future<int> eliminarMateria(String idmateria)async{
    Database db = await Conexion.abrirDB();

    return db.delete("MATERIA", where: "IDMATERIA=?", whereArgs: [idmateria]);
  }
}