import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayoutScreen extends StatefulWidget {
  const HomeLayoutScreen({Key? key}) : super(key: key);

  @override
  State<HomeLayoutScreen> createState() => _HomeLayoutScreenState();
}

class _HomeLayoutScreenState extends State<HomeLayoutScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var formKey = GlobalKey<FormState>();

  var titleControler = TextEditingController();

  var dateControler = TextEditingController();

  var timeControler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(context),
      child: BlocConsumer<AppCubit, AppCubitStates>(
        listener: (context, state) {
          if (state is AppCubitInsertToDatabaseState) {
            Navigator.pop(context);

            dialog(context);
          }
        },
        builder: (context, state) {
          var cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isClicked) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertDatabase(
                      title: titleControler.text,
                      date: dateControler.text,
                      time: timeControler.text,
                      context: context,
                    );
                    titleControler.clear();
                    dateControler.clear();
                    timeControler.clear();
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet((context) => Container(
                            padding: const EdgeInsets.all(20.0),
                            color: Colors.white,
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultTextFormField(
                                    controller: titleControler,
                                    type: TextInputType.text,
                                    functionValidation: (String? value) {
                                      if (value!.isEmpty) {
                                        return "Title must not be empty";
                                      }
                                      return null;
                                    },
                                    labelText: 'Task title',
                                    prifixIcon: Icons.text_snippet_sharp,
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultTextFormField(
                                    controller: dateControler,
                                    type: TextInputType.datetime,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2030, 1, 1),
                                      ).then((DateTime? value) async {
                                        dateControler.text =
                                            DateFormat.yMMMd().format(value!);
                                      }).catchError((error) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                                    },
                                    functionValidation: (String? value) {
                                      if (value!.isEmpty) {
                                        return "Date must not be empty";
                                      }
                                      return null;
                                    },
                                    labelText: 'Task date',
                                    prifixIcon: Icons.date_range_outlined,
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultTextFormField(
                                    controller: timeControler,
                                    type: TextInputType.text,
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) {
                                        timeControler.text =
                                            value!.format(context);
                                      }).catchError((error) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                                    },
                                    functionValidation: (String? value) {
                                      if (value!.isEmpty) {
                                        return "Time must not be empty";
                                      }
                                      return null;
                                    },
                                    labelText: 'Task time',
                                    prifixIcon: Icons.watch_later_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .closed
                      .then((value) {
                    cubit.changeiconstate(
                      icon: Icons.edit,
                      isclick: false,
                    );
                  });
                  cubit.changeiconstate(
                    icon: Icons.add,
                    isclick: true,
                  );
                }
              },
              child: Icon(
                cubit.iconChoice,
              ),
            ),
            appBar: AppBar(
              title: Text(
                cubit.title[cubit.currentIndex],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changebottombavbarstate(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive,
                  ),
                  label: 'Archive',
                ),
              ],
            ),
            body: ConditionalBuilder(
              condition: state is! AppCubitloadingDatabaseState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
