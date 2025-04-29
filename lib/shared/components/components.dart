import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  final VoidCallback? onTap,
  required final FormFieldValidator<String> validator,
  required String label,
  required IconData prefix,
  bool readOnly = false,
}) =>
    TextFormField(
      controller: controller,
      // enabled: false,
      readOnly: readOnly,
      keyboardType: type,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        border: const OutlineInputBorder(),
      ),
    );
Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key('${model['id']}'),
      onDismissed: (direction) {
        AppCubit.get(context).deleteFromDb(
          id: model['id'],
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 7,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Center(
                        child: Text(
                          '${model['time']}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 15.0,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${model['title']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    Text(
                      '${model['date']}',
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 15.0,
              ),
              if (!(model['status'] == 'archive'))
                Checkbox(
                  value: model['status'] == 'done',
                  onChanged: (value) {
                    if (model['status'] == 'done') {
                      AppCubit.get(context).updateData(
                        status: 'new',
                        id: model['id'],
                      );
                    } else {
                      AppCubit.get(context).updateData(
                        status: 'done',
                        id: model['id'],
                      );
                    }
                  },
                  activeColor: Theme.of(context).colorScheme.primaryContainer,
                  checkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              IconButton(
                onPressed: () {
                  if (model['status'] == 'archive') {
                    AppCubit.get(context).updateData(
                      status: 'new',
                      id: model['id'],
                    );
                  } else {
                    AppCubit.get(context).updateData(
                      status: 'archive',
                      id: model['id'],
                    );
                  }
                },
                icon: const Icon(
                  Icons.archive_rounded,
                ),
                color: model['status'] == 'archive'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ],
          ),
        ),
      ),
    );

Widget tasksPageBuilder({
  required List<Map> tasks,
}) =>
    ConditionalBuilder(
      condition: tasks.isNotEmpty,
      builder: (BuildContext context) => ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
        itemCount: tasks.length,
      ),
      fallback: (BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              size: 100.0,
              color: Theme.of(context).dividerColor,
            ),
            Text(
              'No Tasks Yet',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).dividerColor),
            )
          ],
        ),
      ),
    );
