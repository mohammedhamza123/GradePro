import 'package:flutter/material.dart';
import 'package:gradpro/pages/widgets/widget_important_date.dart';
import 'package:gradpro/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

import '../../models/important_date_list.dart';
import '../../providers/student_provider.dart';

class ImportantDatesListWidget extends StatelessWidget {
  const ImportantDatesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(builder: (context, provider, _) {
      return Expanded(
        child: Column(
          children: [
            FutureBuilder<List<ImportantDate>>(
              future: provider.importantDates,
              builder: (BuildContext context,
                  AsyncSnapshot<List<ImportantDate>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                      child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data!.isNotEmpty
                      ? Expanded(
                          child: ListView(
                          children:
                              List.generate(snapshot.data!.length, (index) {
                            final item = snapshot.data![index];
                            return ImportantDateWidget(
                                date:
                                    "${item.date.year}-${item.date.month}-${item.date.day}",
                                time: "10:30 ص",
                                dateDesc: item.dateType);
                          }),
                        ))
                      : const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("لا توجد مواعيد"),
                        );
                }
              },
            ),
          ],
        ),
      );
    });
  }
}

class TeacherImportantDatesListWidget extends StatelessWidget {
  const TeacherImportantDatesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(builder: (context, provider, _) {
      return Column(

        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("المواعيد الهامة",style:TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
          ),
          FutureBuilder<List<ImportantDate>>(
            future: provider.importantDates,
            builder: (BuildContext context,
                AsyncSnapshot<List<ImportantDate>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return snapshot.data!.isNotEmpty
                    ? Expanded(
                        child: ListView(
                        children:
                            List.generate(snapshot.data!.length, (index) {
                          final item = snapshot.data![index];
                          return ImportantDateWidget(
                              date:
                                  "${item.date.year}-${item.date.month}-${item.date.day}",
                              time: "10:30 ص",
                              dateDesc: item.dateType);
                        }),
                      ))
                    : const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("لا توجد مواعيد"),
                      );
              }
            },
          ),
        ],
      );
    });
  }
}
