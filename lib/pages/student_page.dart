import 'package:flutter/material.dart';
import 'package:gradpro/pages/widgets/page_important_dates.dart';
import 'package:gradpro/pages/widgets/widget_appbar.dart';
import 'package:gradpro/pages/widgets/page_archive.dart';
import 'package:gradpro/pages/widgets/widget_buttom_navigator.dart';
import 'package:gradpro/pages/widgets/page_details.dart';
import 'package:gradpro/pages/widgets/widget_retry_button.dart';
import 'package:gradpro/pages/widgets/switchcase_widget.dart';
import 'package:provider/provider.dart';

import '../providers/student_provider.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  WidgetSwitchCase switchCase(int index) {
    switch (index) {
      case 1:
        return StudentDetailsLoadedCase();
      // case 1:
      //   return StudentSuggestionListLoadedCase();
      case 0:
        return StudentImportantDatesLoadedCase();
      case 2:
        return StudentArchiveLoadedCase();
      default:
        return LoadingWidgetCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<StudentProvider>(builder: (context, provider, child) {
        return Scaffold(
          bottomNavigationBar: const StudentBottomNavigator(),
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
              child: const Icon(Icons.chat)),
          body: Column(
            children: [
              provider.selectedIndex == 0
                  ? const StudentProgressionAppBar()
                  : const StudentAppBar(),
              SwitchCaseWidget<WidgetSwitchCase>(
                  activeState: switchCase(provider.selectedIndex),
                  stateBuilder: (WidgetSwitchCase? value) {
                    if (provider.isError) {
                      return Expanded(
                        child: Column(
                          children: [
                            Text(provider.errorMessage),
                            Center(
                                child: RetryButton(
                              onPress: () {
                                provider.retry();
                                provider.onItemTapped(provider.selectedIndex);
                              },
                              errorMessege: "",
                            )),
                          ],
                        ),
                      );
                    }
                    if (value is ErrorWidgetCase) {
                      return Center(
                          child: RetryButton(
                        onPress: () {
                          provider.retry();
                          provider.onItemTapped(provider.selectedIndex);
                        },
                        errorMessege: provider.errorMessage,
                      ));
                    }
                    if (value is LoadingWidgetCase) {
                      return const Expanded(
                          child: Center(child: CircularProgressIndicator()));
                    }
                    if (value is StudentDetailsLoadedCase) {
                      return const StudentDetails();
                    }
                    // if (value is StudentSuggestionListLoadedCase) {
                    //   return const StudentSuggestionList();
                    // }
                    if (value is StudentImportantDatesLoadedCase) {
                      return const ImportantDatesListWidget();
                    }
                    if (value is StudentArchiveLoadedCase) {
                      return const Archive();
                    }
                    return null;
                  }),
            ],
          ),
        );
      }),
    );
  }
}
