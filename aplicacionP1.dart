import 'package:dam_practica_agenda/controlador/materiaDB.dart';
import 'package:dam_practica_agenda/controlador/tareaDB.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'modelo/materia.dart';
import 'modelo/tarea.dart';

class AppP1 extends StatefulWidget {
  const AppP1({super.key});

  @override
  State<AppP1> createState() => _AppP1State();
}

class _AppP1State extends State<AppP1> {
  String titulo = "Mi agenda";



  List<String> opcionesSemestre = ["ENE-JUN2024", "AGO-DIC2024","ENE-JUN2025","AGO-DIC2025","ENE-JUN2026","AGO-DIC2026"];
  String semestreSeleccionado = "ENE-JUN2024";


  final id_materia = TextEditingController();
  final nombre = TextEditingController();
  final semestre = TextEditingController();
  final docente = TextEditingController();

  final id_tarea = TextEditingController();
  final fe_entrega = TextEditingController();
  final t_descripcion = TextEditingController();

  Materia estGlobalMatera = Materia(idmateria: "", nombre: "", semestre: "", docente: "");
  List<Materia> data =[];
  Tarea estGlobalTarea = Tarea(idtarea: 0, idmateria: "", f_entrega: "", descripcion: "");
  List<Tarea> dataT =[];

  void actualizarListaMatera() async {
    List<Materia> temp = await DBmateria.mostrarMateria();
    setState(() {
      data = temp;
    });
  }

  void actualizarListaTarea() async {
    List<Tarea> temp = await DBTarea.mostrarTarea();
    setState(() {
      dataT = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    actualizarListaMatera();
    actualizarListaTarea();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("${titulo}"),
            backgroundColor: Colors.indigo[300],
            centerTitle: true,
            bottom: TabBar(
              labelColor: Colors.white, // Color del texto de la etiqueta seleccionada
              unselectedLabelColor: Colors.grey[400], // Color del texto no seleccionado
              tabs: [
                Tab(
                  icon: Icon(Icons.assignment),
                  text: "Tareas",
                ),
                Tab(
                  icon: Icon(Icons.book),
                  text: "Materias",
                ),
                Tab(
                  icon: Icon(Icons.add),
                  text: "Agregar",
                ),
              ],
            ),

          ),

          body: TabBarView(
              children: [
                mostrarLista(),
                mostrarListaMateria(),
                capturarMateria(),
              ]
          ),
          floatingActionButton: FloatingActionButton(
            onPressed:(){
              mostarcapturarTarea();
              id_tarea.text = "";
              id_materia.text = "";
              fe_entrega.text = "";
              t_descripcion.text = "";
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.indigo[300],
          ),
        )
    );
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      duration: Duration(seconds: 2), // Duración del SnackBar
    ));
  }


  Widget mostrarLista() {
    dataT.sort((a, b) {
      final dateFormat = DateFormat('MM/dd/yyyy');
      final dateA = dateFormat.parse(a.f_entrega);
      final dateB = dateFormat.parse(b.f_entrega);
      return dateA.compareTo(dateB);
    });

    return ListView.builder(
      itemCount: dataT.length,
      itemBuilder: (context, index) {
        Tarea tarea = dataT[index];

        DateTime fechaEntrega = DateFormat('MM/dd/yyyy').parse(tarea.f_entrega);
        DateTime fechaActual = DateTime.now();
        Color fondoColor;

        // Comparacion de la fecha y de la tarea con la fecha actual
        // Para asignar el color de fondo.
        if (fechaEntrega.year == fechaActual.year &&
            fechaEntrega.month == fechaActual.month &&
            fechaEntrega.day == fechaActual.day) {
          fondoColor = Colors.yellowAccent; // Fondo amarillo para tareas de hoy
        } else if (fechaEntrega.isBefore(fechaActual)) {
          fondoColor = Colors.redAccent; // Fondo rojo para tareas vencidas
        } else {
          fondoColor = Colors.greenAccent; // Fondo verde para tareas futuras
        }

        return ListTile(
          tileColor: fondoColor, // Establece el color de fondo en tileColor
          title: Text("${dataT[index].descripcion}"),
          subtitle: Text("Materia: ${data[index].idmateria}, Fecha: ${tarea.f_entrega}"),
          leading: CircleAvatar(child: Text("${index + 1}")),
          trailing: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.error),
                        SizedBox(width: 8),
                        Text("¡CUIDADO!"),
                      ],
                    ),
                    content: Text("¿Estás seguro que deseas eliminar el registro?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          DBTarea.eliminarTarea(dataT[index].idtarea.toString()).then((value) {
                            setState(() {
                              mostrarMensaje("SE ELIMINÓ CORRECTAMENTE");
                            });
                            actualizarListaTarea();
                            Navigator.pop(context);
                          });
                        },
                        child: const Text("Sí"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.delete),
          ),
          onTap: () {
            estGlobalTarea = dataT[index];
            mostrarEditarTarea();
          },
        );
      },
    );
  }

  Widget mostrarListaMateria() {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        Materia materia = data[index];
        return ListTile(
          title: Text("${data[index].nombre}"),
          subtitle: Text("Materia: ${materia.idmateria}, Semestre: ${materia.semestre}"),
          leading: CircleAvatar(child: Text("${index + 1}")),
          trailing: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.error),
                        SizedBox(width: 8),
                        Text("¡CUIDADO!"),
                      ],
                    ),
                    content: Text("¿Estás seguro que deseas eliminar el registro?"),
                    actions: [
                      TextButton(
                        onPressed: (){
                          DBmateria.eliminarMateria(data[index].idmateria).then((value){
                            setState(() {
                              mostrarMensaje("SE ELIMINÓ CORRECTAMENTE");
                            });
                            actualizarListaMatera();
                            Navigator.pop(context);
                          });
                        },
                        child: const Text("Sí"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.delete),
          ),
          onTap: () {
            estGlobalMatera = data[index];
            semestre.text = estGlobalMatera.semestre;
            mostrarEditarMateria();
          },
        );
      },
    );
  }

  Widget capturarMateria() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 15,
        left: 30,
        right: 30,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: id_materia,
            decoration: InputDecoration(
              labelText: "id_Materia:",
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: nombre,
            decoration: InputDecoration(
              labelText: "Nombre:",
            ),
          ),
          SizedBox(height: 10),
          // Menú desplegable para el campo del semestre
          DropdownButtonFormField<String>(
            value: semestreSeleccionado,
            items: opcionesSemestre.map((String semestre) {
              return DropdownMenuItem<String>(
                value: semestre,
                child: Text(semestre),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                semestreSeleccionado = newValue!;
              });
            },
            decoration: InputDecoration(
              labelText: "Semestre:",
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: docente,
            decoration: InputDecoration(
              labelText: "Docente:",
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () {
                  var temporal = Materia(
                    idmateria: id_materia.text,
                    nombre: nombre.text,
                    semestre: semestreSeleccionado,
                    docente: docente.text,
                  );
                  setState(() {
                    DBmateria.insertarMateria(temporal).then((value) {
                      mostrarMensaje("SE INSERTÓ CORRECTAMENTE");
                    });
                    id_materia.text = "";
                    nombre.text = "";
                    semestreSeleccionado = "ENE-JUN2024";
                    docente.text = "";
                    actualizarListaMatera();
                  });
                },
                child: const Text("Guardar"),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    id_materia.text = "";
                    nombre.text = "";
                    semestreSeleccionado = "ENE-JUN2024";
                    docente.text = "";
                  });
                },
                child: Text("Cancelar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void mostarcapturarTarea() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      builder: (builder) {
        return capturarTarea();
      },
    );
  }

  Widget capturarTarea() {
    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        final formattedDate = DateFormat('MM/dd/yyyy').format(picked);
        setState(() {
          fe_entrega.text = formattedDate;
        });
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 15,
        left: 30,
        right: 30,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10,),
          // Menú desplegable para seleccionar la materia
          DropdownButtonFormField<String>(
            value: id_materia.text.isEmpty ? data.isNotEmpty ? data.first.idmateria : "" : id_materia.text,
            items: data.map((Materia materia) {
              return DropdownMenuItem<String>(
                value: materia.idmateria,
                child: Text(materia.nombre),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                id_materia.text = newValue ?? "";
              });
            },
            decoration: InputDecoration(
              labelText: "Materia:",
            ),
          ),

          SizedBox(height: 10,),
          GestureDetector(
            onTap: () {
              _selectDate(context);
            },
            child: AbsorbPointer(
              child: TextField(
                controller: fe_entrega,
                decoration: InputDecoration(
                  labelText: "Fecha de entrega:",
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),
          TextField(
            controller: t_descripcion,
            decoration: InputDecoration(
              labelText: "Descripcion",
            ),
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () {
                  bool materiaValida = data.any((materia) => materia.idmateria == id_materia.text);
                  if (materiaValida) {
                    var temporal = Tarea(
                      idtarea: -1,
                      idmateria: id_materia.text,
                      f_entrega: fe_entrega.text,
                      descripcion: t_descripcion.text,
                    );
                    DBTarea.insertarTarea(temporal).then((value) {
                      setState(() {
                        mostrarMensaje("SE AGREGÓ CORRECTAMENTE");
                      });
                      id_tarea.text = "";
                      id_materia.text = "";
                      fe_entrega.text = "";
                      t_descripcion.text = "";
                      actualizarListaTarea();
                    });
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text("La materia seleccionada no existe."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Aceptar"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text("Guardar"),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
                child: Text("Cancelar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void mostarcapturarMateria(){
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 5,
        builder: (builder){
          return capturarMateria();
        }
    );
  }

  void mostrarEditarTarea() {
    id_tarea.text = estGlobalTarea.idtarea.toString();
    id_materia.text = estGlobalTarea.idmateria;
    fe_entrega.text = estGlobalTarea.f_entrega;
    t_descripcion.text = estGlobalTarea.descripcion;

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        final formattedDate = DateFormat.yMd().format(picked) ;
        setState(() {
          fe_entrega.text = formattedDate;
        });
      }
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 15,
            left: 30,
            right: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom+50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Tarea: ${estGlobalTarea.idtarea}", style: TextStyle(fontSize: 20),),
              SizedBox(height: 10,),
              DropdownButtonFormField<String>(
                value: id_materia.text.isEmpty ? data.isNotEmpty ? data.first.idmateria : "" : id_materia.text,
                items: data.map((Materia materia) {
                  return DropdownMenuItem<String>(
                    value: materia.idmateria,
                    child: Text(materia.nombre),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    id_materia.text = newValue ?? "";
                  });
                },
                decoration: InputDecoration(
                  labelText: "Materia:",
                ),
              ),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: () {
                  _selectDate(context);
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: fe_entrega,
                    decoration: InputDecoration(
                      labelText: "Fecha de entrega:",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: t_descripcion,
                decoration: InputDecoration(
                  labelText: "Descripcion",
                ),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      estGlobalTarea.idtarea = int.parse(id_tarea.text);
                      estGlobalTarea.idmateria = id_materia.text;
                      estGlobalTarea.f_entrega = fe_entrega.text;
                      estGlobalTarea.descripcion = t_descripcion.text;

                      DBTarea.actulizarTarea(estGlobalTarea).then((value) {
                        if(value > 0) {
                          setState(() {
                            mostrarMensaje("SE ACTUALIZÓ CORRECTAMENTE");

                          });
                          actualizarListaTarea();
                          id_tarea.text = "";
                          id_materia.text = "";
                          fe_entrega.text = "";
                          t_descripcion.text = "";
                          estGlobalTarea = Tarea(idtarea: 0, idmateria: "", f_entrega: "", descripcion: "");
                        }
                      });
                    },
                    child: const Text("Actualizar"),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      id_tarea.text = "";
                      id_materia.text = "";
                      fe_entrega.text = "";
                      t_descripcion.text = "";
                    },
                    child: Text("Cancelar"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void mostrarEditarMateria() {
    id_materia.text = estGlobalMatera.idmateria;
    nombre.text = estGlobalMatera.nombre;
    semestre.text = estGlobalMatera.semestre;
    docente.text = estGlobalMatera.docente;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 15,
            left: 30,
            right: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom+50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Materia: ${estGlobalMatera.idmateria}", style: TextStyle(fontSize: 20),),
              SizedBox(height: 20,),
              TextField(
                controller: id_materia,
                decoration: InputDecoration(
                  labelText: "id_Materia:",
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: nombre,
                decoration: InputDecoration(
                  labelText: "Nombre:",
                ),
              ),
              SizedBox(height: 10,),
              DropdownButtonFormField<String>(
                value: semestreSeleccionado,
                items: opcionesSemestre.map((String semestre) {
                  return DropdownMenuItem<String>(
                    value: semestre,
                    child: Text(semestre),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    semestreSeleccionado = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Semestre:",
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: docente,
                decoration: InputDecoration(
                  labelText: "Docente:",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      estGlobalMatera.idmateria = id_materia.text;
                      estGlobalMatera.nombre = nombre.text;
                      estGlobalMatera.semestre = semestreSeleccionado;
                      estGlobalMatera.docente = docente.text;

                      DBmateria.actulizarMateria(estGlobalMatera).then((value) {
                        if(value > 0) {
                          setState(() {
                            mostrarMensaje("SE ACTUALIZÓ CORRECTAMENTE");
                          });
                          id_materia.text = "";
                          nombre.text = "";
                          semestreSeleccionado = "ENE-JUN2024";
                          docente.text = "";
                          estGlobalMatera = Materia(idmateria: "", nombre: "", semestre: "", docente: "");
                        }
                      });
                    },
                    child: const Text("Actualizar"),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      id_materia.text = "";
                      nombre.text = "";
                      semestreSeleccionado = "ENE-JUN2024";
                      docente.text = "";
                    },
                    child: Text("Cancelar"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}
