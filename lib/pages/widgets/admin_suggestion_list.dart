import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_project_provider.dart'; // Keep this for accessing the provider
import 'suggestion_styles.dart'; // Styles for suggestions (unchanged)
import 'widget_suggestion.dart'; // Custom widget for suggestions (unchanged)
import 'accept_suggestion_dialog.dart'; // Dialog for suggestion actions (unchanged)

class AdminSuggestionList extends StatelessWidget {
  const AdminSuggestionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProjectProvider>(builder: (context, provider, _) {
      return FutureBuilder<bool>(
        future: provider.loadProjects(),
        // Make sure the return type matches (bool)
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While loading, show Circular Progress Indicator
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // In case of error, show an error message
            return const Center(child: Text("حدث خطأ أثناء تحميل البيانات"));
          } else if (snapshot.hasData && provider.projectList.isNotEmpty) {
            // When data is loaded and the project list is not empty
            return !provider.refreshing
                ? Expanded(
                    child: ListView.builder(
                      itemCount: provider.projectList.length,
                      itemBuilder: (context, index) {
                        final project = provider.projectList[index];
                        return Suggestion(
                          onPress: () {
                            // Show dialog and handle the suggestion status change
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AcceptSuggestionDialog();
                              },
                            ).then((value) async {
                              final suggestion = project.mainSuggestion;
                              if (suggestion == null) return;
                              if (value == 'Done') {
                                await provider.changeSuggestionStatus(
                                    suggestion, "a");
                              } else if (value == 'Reject') {
                                await provider.changeSuggestionStatus(
                                    suggestion, "r");
                              } else if (value == 'Wait') {
                                await provider.changeSuggestionStatus(
                                    suggestion, "w");
                              }
                            });
                          },
                          title: project.mainSuggestion?.title ?? "No Title",
                          content:
                              project.mainSuggestion?.content ?? "No Content",
                          status: project.mainSuggestion?.status ?? "w",
                          image: project.mainSuggestion?.image ?? "",
                        );
                      },
                    ),
                  )
                : const Center(child: CircularProgressIndicator());
          } else {
            // If no projects, show a message
            return const Center(child: Text("لا توجد مشاريع"));
          }
        },
      );
    });
  }
}
