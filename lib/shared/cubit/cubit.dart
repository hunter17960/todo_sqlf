import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/modules/settings_/settings_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:todo_app/shared/network/local/cache_helper.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitial());

  static AppCubit get(context) => BlocProvider.of(context);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeTextController = TextEditingController();
  final TextEditingController dateTextController = TextEditingController();
  TimeOfDay? timeController;
  DateTime? dateController;
  bool isBottomSheetShown = false;
  bool isDark = false;
  IconData addTaskIcon = Icons.add_rounded;
  late Database database;
  int currentIndex = 0;
  List<Widget> screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
    const SettingsScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
    'Settings',
  ];
  List<Map> tasks = [];
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBar());
  }

  void clearFormField() {
    titleController.clear();
    timeTextController.clear();
    dateTextController.clear();
    dateController = null;
    timeController = null;
  }

  void toggleTheme({bool? storedIsDark}) {
    if (storedIsDark != null) {
      isDark = storedIsDark;
      emit(AppToggleTheme());
    } else {
      isDark = !isDark;
      CacheHelper.saveData(key: 'isDark', value: isDark).then((value) {
        emit(AppToggleTheme());
      });
    }
  }

  void bottomSheetToggle(bool value, IconData icon) {
    isBottomSheetShown = value;
    addTaskIcon = icon;
    emit(AppBottomSheetToggle());
  }

  void createDb() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (db, version) {
        db
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {})
            .catchError((error) {
          // print(error.toString());
        });
      },
      onOpen: (db) {
        getDataFromDb(db);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDb());
    });
  }

  void insertToDb({
    required String title,
    required String date,
    required String time,
  }) async {
    await database.transaction((txn) => txn
            .rawInsert(
                'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","new")')
            .then((value) {
          emit(AppInsertToDb());
          getDataFromDb(database);
        }).catchError((error) {
          // print(error.toString());
        }));
  }

  void getDataFromDb(Database db) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetFromDbLoading());
    db.rawQuery('SELECT * FROM tasks').then((value) {
      for (var element in value) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      }
      tasks = value;
      emit(AppGetFromDb());
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async {
    database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?', [
      status,
      id,
    ]).then((value) {
      getDataFromDb(database);
      emit(AppUpdateDb());
    });
  }

  void deleteFromDb({
    required int id,
  }) {
    database.rawDelete('DELETE FROM tasks WHERE id=?', [id]).then((value) {
      getDataFromDb(database);
      emit(AppDeleteFromDb());
    });
  }
}
