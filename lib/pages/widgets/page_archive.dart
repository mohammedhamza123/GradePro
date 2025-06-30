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

class TeacherArchive extends StatelessWidget {
  const TeacherArchive({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(builder: (context, provider, child) {
      return Expanded(
        child: FutureBuilder(
            future: provider.loadProjects(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("المشاريع المشرف عليها",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                          child: provider.teacherProjectList.isNotEmpty
                              ? ListView(
                                  children: List.generate(
                                      provider.teacherProjectList.length,
                                      (index) {
                                    final item =
                                        provider.teacherProjectList[index];
                                    return ProjectMoreDetails(
                                      project: item,
                                      onLoad: provider
                                          .loadFilteredStudentForProject(
                                              item.id),
                                    );
                                    // return Stack(
                                    //   alignment: Alignment.centerLeft,
                                    //   children: [
                                    //     InkWell(
                                    //       onTap: () {
                                    //         provider.setCurrentProject(item);
                                    //         provider.onItemTapped(1);
                                    //       },
                                    //       child: ProjectWidget(
                                    //         title: item.title,
                                    //         image: item.image,
                                    //       ),
                                    //     ),
                                    //     Padding(
                                    //       padding: const EdgeInsets.all(16.0),
                                    //       child: IconButton(
                                    //           onPressed: () {
                                    //             Provider.of<ChatProvider>(context,
                                    //                     listen: false)
                                    //                 .setProject(project: item);
                                    //             Navigator.pushNamed(
                                    //                 context, "/chat");
                                    //           },
                                    //           icon: const Icon(Icons.chat)),
                                    //     )
                                    //   ],
                                    // );
                                  }),
                                )
                              : const Center(
                                  child: Text(
                                      "لا توجد مشاريع يتم الاشراف عليها"))),
                      const Text("كل المشاريع",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Expanded(
                          child: provider.projectList.isNotEmpty
                              ? ListView(
                                  children: List.generate(
                                      provider.projectList.length, (index) {
                                    final item = provider.projectList[index];
                                    return InkWell(
                                      onTap: () {
                                        provider.setCurrentProject(item);
                                        provider.onItemTapped(1);
                                      },
                                      child: ProjectWidget(
                                        title: item.title,
                                        image: item.image,
                                      ),
                                    );
                                  }),
                                )
                              : const Center(
                                  child: Text("لا توجد مشاريع لعرضها"))),
                    ],
                  );
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
