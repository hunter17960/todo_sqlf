// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AppInsertToDb) {
          Navigator.pop(context);
          AppCubit.get(context).clearFormField();
        }
      },
      builder: (context, state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: cubit.scaffoldKey,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              cubit.titles[cubit.currentIndex],
            ),
          ),
          body: state is AppGetFromDbLoading
              ? const Center(child: CircularProgressIndicator())
              : cubit.screens[cubit.currentIndex],
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (cubit.isBottomSheetShown) {
                if (cubit.formKey.currentState!.validate()) {
                  cubit.insertToDb(
                    title: cubit.titleController.text,
                    date: cubit.dateTextController.text,
                    time: cubit.timeTextController.text,
                  );
                }
              } else {
                cubit.scaffoldKey.currentState
                    ?.showBottomSheet((context) => Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: cubit.formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  controller: cubit.titleController,
                                  type: TextInputType.text,
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'title must not be empty';
                                    }

                                    return null;
                                  },
                                  label: 'Task Title',
                                  prefix: Icons.title,
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: cubit.timeController ??
                                          TimeOfDay.now(),
                                    ).then((value) {
                                      if (value != null) {
                                        cubit.timeController = value;
                                        cubit.timeTextController.text =
                                            value.format(context);
                                      }
                                    }).catchError((error) {
                                      print(error.toString());
                                    });
                                  },
                                  child: AbsorbPointer(
                                    absorbing: true,
                                    child: defaultFormField(
                                      controller: cubit.timeTextController,
                                      readOnly: true,
                                      type: TextInputType.datetime,
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'time must not be empty';
                                        }
                                        return null;
                                      },
                                      label: 'Task Time',
                                      prefix: Icons.watch_later_outlined,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: cubit.dateController ??
                                          DateTime.now(),
                                      firstDate: DateTime.now().copyWith(
                                        year: DateTime.now().year - 5,
                                      ),
                                      lastDate: DateTime.now().copyWith(
                                        year: DateTime.now().year + 10,
                                      ),
                                    ).then((value) {
                                      if (value != null) {
                                        cubit.dateController = value;
                                        cubit.dateTextController.text =
                                            DateFormat.yMMMMd().format(value);
                                      }
                                    }).catchError((error) {
                                      print(error.toString());
                                    });
                                  },
                                  child: AbsorbPointer(
                                    absorbing: true,
                                    child: defaultFormField(
                                      controller: cubit.dateTextController,
                                      readOnly: true,
                                      type: TextInputType.datetime,
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'date must not be empty';
                                        }
                                        return null;
                                      },
                                      label: 'Task date',
                                      prefix: Icons.calendar_today,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .closed
                    .then((value) {
                  cubit.bottomSheetToggle(false, Icons.add_rounded);
                  cubit.clearFormField();
                });
                cubit.bottomSheetToggle(true, Icons.check_rounded);
                cubit.clearFormField();
              }
            },
            child: Icon(
              cubit.addTaskIcon,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: cubit.currentIndex,
            onTap: (value) {
              AppCubit.get(context).changeIndex(value);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.task_alt),
                label: 'Done',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.archive_outlined),
                label: 'Archived',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
