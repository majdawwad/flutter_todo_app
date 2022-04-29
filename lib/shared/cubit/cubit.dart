import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import 'package:todo_app/modules/archived_layout/archived_layout_screen.dart';
import 'package:todo_app/modules/done_layout/done_layout_screen.dart';
import 'package:todo_app/modules/task_layout/task_layout_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppCubitStates> {
  AppCubit() : super(AppCubitInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  static late Database database;
  bool isClicked = false;
  IconData iconChoice = Icons.edit;
  List<Map> newtasks = [];
  List<Map> donetasks = [];
  List<Map> archivedtasks = [];

  List<Widget> screens = [
    const TaskLayoutScreen(),
    const DoneLayoutScreen(),
    const ArchivedLayoutScreen(),
  ];

  List<String> title = [
    'New Tasks',
    'New Done',
    'New Archived',
  ];

  void changebottombavbarstate(index) {
    currentIndex = index;
    emit(ApppCubitButtomNavBarState());
  }

  void changeiconstate({bool? isclick, IconData? icon}) {
    iconChoice = icon!;
    isClicked = isclick!;
    emit(AppCubitChangeIconState());
  }

  void createDatabase(BuildContext ctx) async {
    await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (Database database, context) {
        database
            .execute(
                "CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)")
            .then((value) {})
            .catchError((error) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                error.toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  Navigator.pop(ctx);
                },
              ),
            ),
          );
        });
      },
      onOpen: (database) {
        getFromDatabase(database);
      },
    ).then((value) {
      database = value;
      emit(AppCubitCreatedDatabaseState());
    });
  }

  void insertDatabase({
    required String title,
    required String date,
    required String time,
    required BuildContext context,
  }) async {
    await database.transaction((txn) async {
      await txn
          .rawInsert(
              "INSERT INTO tasks(title, date, time, status) VALUES('$title','$date','$time', 'new')")
          .then((value) {
        emit(AppCubitInsertToDatabaseState());

        getFromDatabase(database);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      });
    });
  }

  void updateinDataBase({
    required String status,
    required int id,
  }) async {
    await database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      emit(AppCubitUpdateToDatabaseState());

      getFromDatabase(database);
    });
  }

  void deleteinDataBase({
    required int id,
  }) async {
    await database
        .rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      emit(AppCubitDeleteFromDatabaseState());

      getFromDatabase(database);
    });
  }

  void getFromDatabase(database) async {
    newtasks = [];
    donetasks = [];
    archivedtasks = [];
    emit(AppCubitloadingDatabaseState());
    await database.rawQuery("SELECT * FROM tasks").then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newtasks.add(element);
        } else if (element['status'] == 'Done') {
          donetasks.add(element);
        } else {
          archivedtasks.add(element);
        }
      });

      emit(AppCubitGetFromDatabaseState());
    });
  }
}
