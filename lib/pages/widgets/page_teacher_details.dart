import 'package:flutter/material.dart';
import 'package:gradpro/providers/teacher_provider.dart';
import 'package:provider/provider.dart';
import 'package:gradpro/pages/widgets/widget_dialog.dart';
import 'package:gradpro/pages/widgets/widget_requirements.dart';
import '../../models/requirement_list.dart';

class TeacherProjectDetails extends StatelessWidget {
  const TeacherProjectDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<TeacherProvider>(builder: (context, provider, child) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("تفاصيل المشروع",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Spacer(flex: 1),
            ProjectDetailsElevatedButton(title: "مقترحات المشروع"),
            ProjectDetailsElevatedButton(title: "نسبة الانجاز"),
            Spacer(flex: 3),
          ],
        );
      }),
    );
  }
}

class ProjectDetailsElevatedButton extends StatelessWidget {
  final void Function()? onPress;
  final String title;

  const ProjectDetailsElevatedButton(
      {super.key, this.onPress, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 50,
        width: 250,
        child: ElevatedButton(
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.white),
                elevation: MaterialStatePropertyAll(4),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))))),
            onPressed: onPress,
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black),
            )),
      ),
    );
  }
}

class TeacherDetails extends StatelessWidget {
  const TeacherDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(builder: (context, provider, child) {
      return provider.currentProject != null
          ? provider.selectedSuggestion != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 165),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Image.asset(
                                        provider.selectedSuggestion != null
                                            ? "assets/pdfImage.png"
                                            : "assets/incomplete.png",
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            "assets/missing_image_icon.png",
                                            fit: BoxFit.contain,
                                            height: 165,
                                          );
                                        },
                                        fit: BoxFit.cover,
                                        height: 165,
                                    ),
                                    // Image.network(
                                    //     provider.selectedSuggestion != null
                                    //         ? provider.selectedSuggestion!.image
                                    //         : ""),
                                    )),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  shadowColor: MaterialStateProperty.all(
                                      Colors.grey.withOpacity(0.8)),
                                  elevation: MaterialStateProperty.all(2)),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              provider.selectedSuggestion!.title,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          // IconButton(
                          //     style: ButtonStyle(
                          //         backgroundColor:
                          //             MaterialStateProperty.all(Colors.white),
                          //         shadowColor: MaterialStateProperty.all(
                          //             Colors.grey.withOpacity(0.8)),
                          //         elevation: MaterialStateProperty.all(2)),
                          //     onPressed: () {
                          //       provider.deleteSuggestion();
                          //     },
                          //     icon: const Icon(
                          //       Icons.delete,
                          //     )),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Container(
                          constraints: const BoxConstraints(
                              maxHeight: 100, minHeight: 50),
                          child: SingleChildScrollView(
                            child: Text(
                              provider.selectedSuggestion!.content,
                              maxLines: null,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            "متطلبات المشروع",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            FutureBuilder(
                              future: provider.loadRequirementsIfNeeded(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return Consumer<TeacherProvider>(
                                    builder: (context, provider, child) {
                                      if (provider.requirementList.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                "لا توجد متطلبات لهذا المقترح"));
                                      } else {
                                        return ListView(
                                          children: List.generate(
                                            provider.requirementList.length,
                                            (index) {
                                              final item =
                                                  provider.requirementList[index];
                                              return RequirementWidget(
                                                title: item.name,
                                                onDelete: () {
                                                  provider
                                                      .deleteRequirement(index);
                                                },
                                                onEdit: () {
                                                  showEditRequirementDialog(
                                                    context,
                                                    (id, requirement) {
                                                      provider.editRequirement(
                                                          id, requirement);
                                                    },
                                                    item.id,
                                                  );
                                                },
                                                status: item.status,
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    },
                                  );
                                }
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: IconButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                      shadowColor: MaterialStateProperty.all(
                                          Colors.grey.withOpacity(0.8)),
                                      elevation:
                                          MaterialStateProperty.all(2)),
                                  onPressed: () {
                                    showAddRequirementDialog(
                                        context, provider.createRequirement);
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 40,
                                    color: Color(0xff00577B),
                                  )),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                        "لم يضف الطالب مقترح بعد أو لم تتم الموافقة علي مقترحه"),
                  ),
                )
          : const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text("لم يتم إختيار مشروع"),
              ),
            );
    });
  }

  void showAddRequirementDialog(
      BuildContext context, void Function(String) add) async {
    String? enteredText = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return RequirementDialog(
          onDonePressed: (value) {
            Navigator.of(context).pop(value);
          },
        );
      },
    );

    if (enteredText != null) {
      if (enteredText.isNotEmpty) {
        add(enteredText);
      }
    }
  }

  void showEditRequirementDialog(BuildContext context,
      void Function(int, Requirement) edit, int id) async {
    Requirement? requirement = await showDialog<Requirement>(
      context: context,
      builder: (BuildContext context) {
        return RequirementEditDialog(
          onDonePressed: (value) {
            Navigator.of(context).pop(value);
          },
        );
      },
    );
    if (requirement != null) {
      edit(id, requirement);
    }
  }
}
