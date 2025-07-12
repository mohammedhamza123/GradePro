import 'package:flutter/material.dart';
import 'package:gradpro/pages/widgets/page_suggestion_list.dart';
import 'package:gradpro/pages/widgets/widget_confirm_delete.dart';
import 'package:gradpro/pages/widgets/widget_dialog.dart';
import 'package:gradpro/pages/widgets/widget_requirements.dart';
import 'package:gradpro/providers/student_provider.dart';
import 'package:provider/provider.dart';

import '../../models/requirement_list.dart';
import '../../models/suggestion_list.dart';

class StudentDetails extends StatelessWidget {
  const StudentDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(builder: (context, provider, child) {
      return Expanded(
        child: FutureBuilder<Suggestion?>(
            future: provider.getCurrentProject(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                return snapshot.data != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            provider.onSaveSuggestionError != null
                                ? Text(
                                    "${provider.onSaveSuggestionError}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent),
                                  )
                                : Container(),
                            Center(
                              child: Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  Container(
                                      constraints:
                                          const BoxConstraints(maxHeight: 165),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        child: Image.network(
                                            snapshot.data != null
                                                ? snapshot.data!.image
                                                : ""),
                                      )),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                        shadowColor: MaterialStateProperty.all(
                                            Colors.grey.withOpacity(0.8)),
                                        elevation:
                                            MaterialStateProperty.all(2)),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Text(
                                    snapshot.data!.title,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 7,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ]),
                                    child: snapshot.data!.status == "w"
                                        ? const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.access_time,
                                              color: Colors.orangeAccent,
                                            ),
                                          )
                                        : snapshot.data!.status == "a"
                                            ? const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.done,
                                                  color: Colors.greenAccent,
                                                ),
                                              )
                                            : const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.cancel_outlined,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                  ),
                                ),
                                IconButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                        shadowColor: MaterialStateProperty.all(
                                            Colors.grey.withOpacity(0.8)),
                                        elevation:
                                            MaterialStateProperty.all(2)),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return DeleteConfirmationDialog(
                                            onConfirm: () {
                                              provider.deleteSuggestion();
                                            },
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                    )),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Container(
                                constraints: const BoxConstraints(
                                    maxHeight: 100, minHeight: 50),
                                child: SingleChildScrollView(
                                  child: Text(
                                    snapshot.data!.content,
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
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            // عرض الدرجة النهائية المحسوبة
                            Consumer<StudentProvider>(
                              builder: (context, studentProvider, _) {
                                // سيتم إضافة عرض الدرجة النهائية لاحقاً عندما يتم إضافة currentProjectDetail
                                return const SizedBox.shrink();
                              },
                            ),
                            Flexible(
                              flex: 3,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ListView(
                                    children: List.generate(
                                        provider.requirementList.length,
                                        (index) {
                                      final item =
                                          provider.requirementList[index];
                                      return RequirementWidget(
                                        title: item.name,
                                        onDelete: () {
                                          provider.deleteRequirement(index);
                                        },
                                        onEdit: () {
                                          showEditRequirementDialog(context,
                                              (id, requirement) {
                                            provider.editRequirement(
                                                id, requirement);
                                          }, item.id);
                                        },
                                        status: item.status,
                                      );
                                    }),
                                  ),
                                  // Align(
                                  //   alignment: Alignment.bottomCenter,
                                  //   child: IconButton(
                                  //       style: ButtonStyle(
                                  //           backgroundColor:
                                  //               MaterialStateProperty.all(
                                  //                   Colors.white),
                                  //           shadowColor:
                                  //               MaterialStateProperty.all(Colors
                                  //                   .grey
                                  //                   .withOpacity(0.8)),
                                  //           elevation:
                                  //               MaterialStateProperty.all(2)),
                                  //       onPressed: () {
                                  //         showAddRequirementDialog(context,
                                  //             provider.createRequirement);
                                  //       },
                                  //       icon: const Icon(
                                  //         Icons.add_circle_outline,
                                  //         size: 40,
                                  //         color:  Color(0xff00577B),
                                  //       )),
                                  // )
                                ],
                              ),
                            ),
                            const Spacer()
                          ],
                        ),
                      )
                    : const AddSuggestionPage();
              }
              return const AddSuggestionPage();
            }),
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
