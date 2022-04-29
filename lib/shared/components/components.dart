import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color color = Colors.blue,
  bool isUpperCase = false,
  required Function()? function,
  required String text,
}) =>
    Padding(
      padding: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
      ),
      child: SizedBox(
        width: double.infinity,
        child: MaterialButton(
          color: color,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 18.0,
              bottom: 18.0,
            ),
            child: Text(
              isUpperCase ? text.toUpperCase() : text,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          onPressed: function,
        ),
      ),
    );

Widget defaultTextFormField({
  required TextEditingController? controller,
  required TextInputType type,
  required String? Function(String? value)? functionValidation,
  required String labelText,
  required IconData prifixIcon,
  bool isPassword = false,
  IconData? suffix,
  Function()? suffixFunction,
  Function()? onTap,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      validator: functionValidation,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          prifixIcon,
        ),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixFunction,
                icon: Icon(
                  suffix,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );

Widget defaultListText(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.blue,
              child: Text(
                '${model['time']}',
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 30.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    '${model['date']}',
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 30.0,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateinDataBase(
                  status: 'Done',
                  id: model['id'],
                );
              },
              icon: const Icon(
                Icons.done_all_rounded,
                color: Colors.red,
              ),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateinDataBase(
                  status: 'Archive',
                  id: model['id'],
                );
              },
              icon: const Icon(
                Icons.archive,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteinDataBase(
          id: model['id'],
        );
      },
    );

Widget defaultTaskTypeConBuilder({
  required List<Map> tasks,
}) =>
    ConditionalBuilder(
      condition: tasks.isNotEmpty,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) => defaultListText(tasks[index], context),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 20.0,
          ),
          child: Container(
            height: 1.0,
            width: double.infinity,
            color: Colors.grey[300],
          ),
        ),
        itemCount: tasks.length,
      ),
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.menu,
              size: 100.0,
              color: Colors.grey,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'There is no task , please enter the task..',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

void dialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    animType: AnimType.TOPSLIDE,
    dialogType: DialogType.SUCCES,
    btnOkIcon: Icons.check_circle,
    btnOkColor: Colors.green.shade900,
    body: Column(
      children: [
        const Text(
          "The task successfuly has been adding",
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 11.0,
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.green.shade500,
            primary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "OK",
          ),
        ),
      ],
    ),
  ).show();
}
