import 'package:flutter/material.dart';
import 'package:gradpro/pages/widgets/page_important_dates.dart';
import 'package:gradpro/pages/widgets/page_suggestion_list.dart';
import 'package:gradpro/pages/widgets/page_teacher_details.dart';
import 'package:gradpro/pages/widgets/widget_appbar.dart';
import 'package:gradpro/pages/widgets/page_archive.dart';
import 'package:gradpro/pages/widgets/widget_buttom_navigator.dart';
import 'package:gradpro/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  late Future<List<dynamic>> _initFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TeacherProvider>(context, listen: false);
    _initFuture = Future.wait([
      provider.loadTeacher(),
      provider.loadProjects(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(builder: (context, provider, child) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          bottomNavigationBar: const TeacherBottomNavigator(),
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              BaseAppBar(content: [
                FutureBuilder(
                    future: provider.user,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 70,
                                height: 70,
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundImage:
                                      AssetImage('assets/default_profile.jpg'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "${snapshot.data?.firstName} ${snapshot.data?.lastName}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
              ]),
              Expanded(
                child: FutureBuilder(
                  future: _initFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data?[0] == true && snapshot.data?[1] == true) {
                        return provider.selectedIndex == 0
                            ? const TeacherImportantDatesListWidget()
                            : provider.selectedIndex == 1
                                ? const TeacherDetails()
                                : provider.selectedIndex == 2
                                    ? const TeacherArchive()
                                    : const TeacherGradingView();
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
