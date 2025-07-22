import 'package:flutter/material.dart';
import 'package:gradpro/pages/widgets/widget_project.dart';
import 'package:gradpro/providers/admin_project_provider.dart';
import 'package:gradpro/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/student_provider.dart';

class Archive extends StatelessWidget {
  const Archive({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(builder: (context, provider, child) {
      return Expanded(
          child: provider.projectList.isNotEmpty
              ? ListView(
                  children: List.generate(provider.projectList.length, (index) {
                    final item = provider.projectList[index];
                    return ProjectWidget(
                      title: item.title,
                      image: item.image,
                    );
                  }),
                )
              : const Center(child: Text("لا توجد مشاريع لعرضها")));
    });
  }
}

class TeacherArchive extends StatefulWidget {
  const TeacherArchive({super.key});

  @override
  State<TeacherArchive> createState() => _TeacherArchiveState();
}

class _TeacherArchiveState extends State<TeacherArchive> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(builder: (context, provider, child) {
      // No need for FutureBuilder, data is loaded by parent
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "المشاريع المشرف عليها",
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            provider.teacherProjectList.isNotEmpty
                ? Column(
                    children: List.generate(
                      provider.teacherProjectList.length,
                      (index) {
                        final item = provider.teacherProjectList[index];
                        return Center(
                          child: InkWell(
                            onTap: () {
                              provider.setCurrentProject(item);
                              provider.onItemTapped(1);
                            },
                            child: ProjectMoreDetails(
                              project: item,
                              onLoad: provider.loadFilteredStudentForProject(item.id),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        "لا توجد مشاريع يتم الاشراف عليها",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                "المشاريع الممتحن عليها",
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            provider.examinedProjectDetails.isNotEmpty
                ? Column(
                    children: List.generate(
                      provider.examinedProjectDetails.length,
                      (index) {
                        final item = provider.examinedProjectDetails[index];
                        return Center(
                          child: InkWell(
                            onTap: () {
                              provider.setCurrentProject(item);
                              provider.onItemTapped(1);
                            },
                            child: ProjectWidget(
                              title: item.title,
                              image: item.image,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        "لا توجد مشاريع لإمتحانها",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
            const SizedBox(height: 32),
          ],
        ),
      );
    });
  }
}

class AdminArchive extends StatelessWidget {
  const AdminArchive({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProjectProvider>(builder: (context, provider, child) {
      return Expanded(
        child: FutureBuilder(
            future: provider.loadProjects(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  return provider.projectList.isNotEmpty
                      ? ListView(
                          children: List.generate(provider.projectList.length,
                              (index) {
                            final item = provider.projectList[index];
                            return InkWell(
                              onTap: () {
                                // provider.setCurrentProject(item);
                              },
                              child: ProjectMoreDetails(
                                project: item,
                                onLoad: provider
                                    .loadFilteredStudentForProject(item.id),
                              ),
                            );
                          }),
                        )
                      : const Center(child: Text("لا توجد مشاريع لعرضها"));
                } else {
                  return const Center(child: Text("لا توجد مشاريع لعرضها"));
                }
              }
              return const Center(child: CircularProgressIndicator());
            }),
      );
    });
  }
}
