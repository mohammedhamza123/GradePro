import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_project_provider.dart';
import 'suggestion_styles.dart';
import 'widget_suggestion.dart';
import 'accept_suggestion_dialog.dart';

class AdminSuggestionList extends StatelessWidget {
  const AdminSuggestionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProjectProvider>(builder: (context, provider, _) {
      return FutureBuilder(
        future: provider.loadProjects(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return Expanded(
                  child: ListView(
                children: List.generate(provider.projectList.length, (index) {
                  final project = provider.projectList[index];
                  return Suggestion(
                    onPress: () {
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
                        } else if (value == 'Cancel') {
                          await provider.changeSuggestionStatus(
                              suggestion, "r");
                        } else if (value == 'Waiting') {
                          await provider.changeSuggestionStatus(
                              suggestion, "w");
                        }
                      });
                    },
                    title: "${project.mainSuggestion?.title}",
                    content: "${project.mainSuggestion?.content}",
                    status: project.mainSuggestion?.status == null
                        ? "w"
                        : project.mainSuggestion!.status,
                    image: "${project.mainSuggestion?.image}",
                  );
                }),
              ));
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text("لا توجد عناصر"));
        },
      );
    });
  }
}
