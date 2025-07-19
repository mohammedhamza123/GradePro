import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import 'widget_suggestion.dart';
import 'suggestion_styles.dart';
import 'page_suggestion_list.dart';

class StudentSuggestionList extends StatelessWidget {
  const StudentSuggestionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(builder: (context, provider, _) {
      return Expanded(
        child: !provider.newSuggestion
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                        style: kButtonStyle,
                        onPressed: () async {
                          final project = await provider.currentProject;
                          if (project != null) {
                            provider.setNewSuggestion(true);
                          } else {
                            final scaffold = ScaffoldMessenger.of(context);
                            scaffold.showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "لم يتم تعين مشروع لك لا يمكنك اضافة مقترح"),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "إضافة مقترح للمشروع",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        )),
                  ),
                  provider.suggestionList.isNotEmpty
                      ? Expanded(
                          child: ListView(
                          children: List.generate(
                              provider.suggestionList.length, (index) {
                            final suggestion = provider.suggestionList[index];
                            return Suggestion(
                              onPress: () {
                                // provider.setSelectedSuggestion(index);
                                provider.onItemTapped(2);
                              },
                              title: suggestion.title,
                              content: suggestion.content,
                              status: suggestion.status,
                              image: suggestion.image,
                            );
                          }),
                        ))
                      : const Center(
                          child: Text("لا توجد عناصر"),
                        )
                ],
              )
            : const AddSuggestionPage(),
      );
    });
  }
} 