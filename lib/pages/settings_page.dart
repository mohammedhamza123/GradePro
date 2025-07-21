import 'package:flutter/material.dart';
import 'package:gradpro/pages/widgets/widget_appbar.dart';
import 'package:gradpro/providers/user_provider.dart';
import 'package:gradpro/services/login_services.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Consumer<UserProvider>(builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BaseAppBar(
                content: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          "الإعدادات",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      customText('تغيير الإسم الأول'),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(64, 8, 8, 8),
                            child: TextFormField(
                              onChanged: (value) {
                                provider.firstNameController.text = value;
                              },
                              decoration: InputDecoration(
                                  hintText: provider.user?.firstName,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32))),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: saveIconButton(() {
                              provider.updateUserFirstName();
                              provider.firstNameController.text = "";
                            }),
                          ),
                        ],
                      ),
                      customDivider(),
                      customText("تغيير الاسم الأخير"),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(64, 8, 8, 8),
                            child: TextFormField(
                              onChanged: (value) {
                                provider.lastNameController.text = value;
                              },
                              decoration: InputDecoration(
                                  hintText: provider.user?.lastName,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32))),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: saveIconButton(() {
                              provider.updateUserLastName();
                              provider.lastNameController.text = "";
                            }),
                          ),
                        ],
                      ),
                      customDivider(),
                      customText("تغيير كلمة  المرور"),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(64, 8, 8, 8),
                        child: TextFormField(
                          controller: provider.changeOldPasswordController,
                          decoration: InputDecoration(
                              hintText: "كلمة المرور القديمة",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32))),
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(64, 8, 8, 8),
                            child: TextFormField(
                              controller: provider.changePasswordController,
                              decoration: InputDecoration(
                                  hintText: "********",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32))),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: saveIconButton(() async {
                              await provider.changePassword();
                              if (provider.passwordChanged) {
                                provider.changeOldPasswordController.text = "";
                                provider.changePasswordController.text = "";
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("تم تغيير كلمة المرور بنجاح"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("فشل في تغيير كلمة المرور"),
                                  ),
                                );
                              }
                            }),
                          ),
                        ],
                      ),
                      customDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                print('DEBUG: Logout button pressed');
                                provider.logout();
                                print('DEBUG: Logout completed, navigating to login');
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              child: const Text("تسجيل الخروج", style: TextStyle(color: Color(0xff00577B)))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

Widget customDivider() => const Divider(
      color: Color(0xff00577B), // color of the separator
      thickness: 1, // thickness of the separator
      indent: 16, // adjust the indent as needed
      endIndent: 16, // adjust the end indent as needed
    );

Widget customText(title) => Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );

Widget saveIconButton(void Function()? onPress) {
  return IconButton(
    onPressed: onPress,
    icon: const Icon(Icons.save),
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        shadowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.8)),
        elevation: MaterialStateProperty.all(2)),
  );
}
