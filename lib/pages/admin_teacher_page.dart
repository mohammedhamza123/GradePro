import 'package:flutter/material.dart';
import 'package:gradpro/pages/widgets/widget_admin_base_page.dart';
import 'package:gradpro/pages/widgets/widget_confirm_delete.dart';
import 'package:gradpro/pages/widgets/widget_searchbar.dart';
import 'package:gradpro/providers/admin_teacher_provider.dart';
import 'package:gradpro/providers/edit_teacher_provider.dart';
import 'package:provider/provider.dart';

import '../models/widget_FormTextField.dart';
import '../providers/register_provider.dart';

class AdminTeacherListPage extends StatefulWidget {
  const AdminTeacherListPage({super.key});

  @override
  State<AdminTeacherListPage> createState() => _AdminTeacherListPageState();
}

class _AdminTeacherListPageState extends State<AdminTeacherListPage> {
  @override
  void initState() {
    super.initState();
    // تحميل الأساتذة عند فتح الصفحة - مرة واحدة فقط
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminTeacherProvider>().loadTeachers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(child:
        Consumer<AdminTeacherProvider>(builder: (context, provider, child) {
      return Expanded(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("قائمة الأساتذة",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    "بحث",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )
                ],
              ),
            ),
            AdminSearchbar(
                onChanged: (String val) {
                  provider.filterTeacherList();
                },
                editingController: provider.searchbarController),
            Expanded(
              child: _buildTeacherList(provider),
            ),
          ],
        ),
      );
    }));
  }

  Widget _buildTeacherList(AdminTeacherProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.refreshTeachers();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final teachers = provider.teacherList;
    
    if (teachers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا يوجد أساتذة مسجلين',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // عرض القائمة المفلترة أو القائمة الكاملة
    final displayList = provider.filterList.isNotEmpty ? provider.filterList : teachers;
    
    return ListView(
      children: List.generate(displayList.length, (index) {
        final item = displayList[index];
        return TeacherListItem(
            imageLink: "",
            firstName: item.user.firstName,
            lastName: item.user.lastName,
            userName: item.user.username);
      }),
    );
  }
}

class TeacherListItem extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String userName;
  final String imageLink;

  const TeacherListItem(
      {super.key,
      required this.imageLink,
      required this.firstName,
      required this.lastName,
      required this.userName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Container(
        decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(32))),
        child: Row(
          children: [
            imageLink.isEmpty
                ? const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage("assets/default_profile.jpg"),
                  )
                : CircleAvatar(backgroundImage: NetworkImage(imageLink)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    '$firstName $lastName',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                  Text(
                    userName,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.normal,
                      height: 0,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AdminTeacherAddPage extends StatelessWidget {
  const AdminTeacherAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
        child: Expanded(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("تسجيل أستاذ جديد",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Consumer<RegisterProvider>(
                  builder: (context, provider, child) {
                return Form(
                  key: provider.formKey,
                  onChanged: provider.onFromStateChanged,
                  child: Column(
                    children: [
                      provider.error.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(provider.error,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.redAccent)),
                            )
                          : provider.success.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(provider.success,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.greenAccent)),
                                )
                              : Container(),
                      FormTextField(
                        hint: "البريد الالكتروني",
                        icon: Icons.alternate_email_outlined,
                        isPassword: false,
                        validator: provider.validateEmail,
                        onChanged: (value) {
                          if (provider.validateEmail(value) == null) {
                            provider.email.text = value;
                          }
                        },
                      ),
                      FormTextField(
                        hint: "اسم المستخدم",
                        icon: Icons.person,
                        isPassword: false,
                        validator: provider.validateUserName,
                        onChanged: (value) {
                          if (provider.validateUserName(value) == null) {
                            provider.userName.text = value;
                          }
                        },
                      ),
                      FormTextField(
                        hint: "الإسم الاول",
                        icon: Icons.person,
                        isPassword: false,
                        validator: provider.validateName,
                        onChanged: (value) {
                          if (provider.validateName(value) == null) {
                            provider.firstName.text = value;
                          }
                        },
                      ),
                      FormTextField(
                        hint: "الإسم الأخير",
                        icon: Icons.person,
                        isPassword: false,
                        validator: provider.validateName,
                        onChanged: (value) {
                          if (provider.validateName(value) == null) {
                            provider.lastName.text = value;
                          }
                        },
                      ),
                      FormTextField(
                        hint: "كلمة المرور",
                        icon: Icons.password,
                        isPassword: true,
                        validator: provider.validatePassword,
                        onChanged: (value) {
                          if (provider.validatePassword(value) == null) {
                            provider.password.text = value;
                          }
                        },
                      ),
                      FormTextField(
                        hint: "تأكيد كلمة المرور",
                        icon: Icons.password,
                        isPassword: true,
                        validator: provider.validateConfirmPassword,
                        onChanged: (value) {
                          if (provider.validateConfirmPassword(value) == null) {
                            provider.confirmPassword.text = value;
                          }
                        },
                      ),
                      !provider.isLoading
                          ? SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: provider.canRegister
                                    ? () {
                                        provider.register(true, null);
                                      }
                                    : null,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
                                      return Colors
                                          .grey; // Change disabled button background color
                                    }
                                    return const Color(
                                        0xff00577B); // Change enabled button background color
                                  }),
                                ),
                                // backgroundColor:
                                //     MaterialStatePropertyAll()),
                                child: const Text(
                                  "تسجيل",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ));
  }
}

class AdminTeacherEditPage extends StatelessWidget {
  const AdminTeacherEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(child: Expanded(
      child: Consumer<AdminEditTeacherProvider>(
          builder: (context, provider, child) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("تعديل بيانات الاستاذ",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            provider.teacher == null
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          "بحث",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      ],
                    ),
                  )
                : Container(),
            provider.teacher == null
                ? AdminSearchbar(
                    onChanged: (String val) {
                      provider.filterTeacherList();
                    },
                    editingController: provider.searchbarController)
                : Container(),
            Expanded(
              child: provider.teacher == null
                  ? _buildEditTeacherList(provider)
                  : SingleChildScrollView(
                      child: Form(
                        key: provider.formKey,
                        onChanged: provider.onFromStateChanged,
                        child: Column(
                          children: [
                            provider.error.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(provider.error,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.red)),
                                  )
                                : Container(),
                            FormTextField(
                              hint: "اسم المستخدم",
                              icon: Icons.person,
                              isPassword: false,
                              validator: provider.validateUserName,
                              onChanged: (value) {
                                if (provider.validateUserName(value) == null) {
                                  provider.userName.text = value;
                                }
                              },
                            ),
                            FormTextField(
                              hint: "الإسم الاول",
                              icon: Icons.person,
                              isPassword: false,
                              validator: provider.validateName,
                              onChanged: (value) {
                                if (provider.validateName(value) == null) {
                                  provider.firstName.text = value;
                                }
                              },
                            ),
                            FormTextField(
                              hint: "الإسم الأخير",
                              icon: Icons.person,
                              isPassword: false,
                              validator: provider.validateName,
                              onChanged: (value) {
                                if (provider.validateName(value) == null) {
                                  provider.lastName.text = value;
                                }
                              },
                            ),
                            !provider.isLoading
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            provider.setTeacher(null);
                                          },
                                          style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Color(0xff00577B))),
                                          child: const Text(
                                            "رجوع لقائمة الاساتذة",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: provider.canEdit
                                              ? () {
                                                  provider.updateTeacher();
                                                }
                                              : null,
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                                        (states) {
                                              if (states.contains(
                                                  MaterialState.disabled)) {
                                                return Colors
                                                    .grey; // Change disabled button background color
                                              }
                                              return const Color(
                                                  0xFF0000FF); // Change enabled button background color
                                            }),
                                          ),
                                          child: const Text(
                                            "حفظ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        );
      }),
    ));
  }

  Widget _buildEditTeacherList(AdminEditTeacherProvider provider) {
    final teachers = provider.teacherList;
    if (teachers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا يوجد أساتذة مسجلين',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    final displayList = provider.filterList.isNotEmpty ? provider.filterList : teachers;
    return ListView(
      children: List.generate(displayList.length, (index) {
        final item = displayList[index];
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            InkWell(
              onTap: () {
                provider.setTeacher(item);
              },
              child: TeacherListItem(
                  imageLink: "",
                  firstName: item.user.firstName,
                  lastName: item.user.lastName,
                  userName: item.user.username),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: IconButton(
                  onPressed: () {
                    provider.setTeacher(item);
                  },
                  icon: const Icon(Icons.edit)),
            )
          ],
        );
      }),
    );
  }
}

class AdminTeacherDeletePage extends StatefulWidget {
  const AdminTeacherDeletePage({super.key});

  @override
  State<AdminTeacherDeletePage> createState() => _AdminTeacherDeletePageState();
}

class _AdminTeacherDeletePageState extends State<AdminTeacherDeletePage> {
  @override
  void initState() {
    super.initState();
    // تحميل الأساتذة عند فتح الصفحة - مرة واحدة فقط
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminEditTeacherProvider>().loadTeachers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(child: Expanded(child:
        Consumer<AdminEditTeacherProvider>(builder: (context, provider, child) {
      return Column(children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("حذف حساب استاذ",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                "بحث",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )
            ],
          ),
        ),
        AdminSearchbar(
            onChanged: (String val) {
              provider.filterTeacherList();
            },
            editingController: provider.searchbarController),
        Expanded(
          child: _buildDeleteTeacherList(provider),
        ),
      ]);
    })));
  }

  Widget _buildDeleteTeacherList(AdminEditTeacherProvider provider) {
    final teachers = provider.teacherList;
    
    if (teachers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا يوجد أساتذة مسجلين',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // عرض القائمة المفلترة أو القائمة الكاملة
    final displayList = provider.filterList.isNotEmpty ? provider.filterList : teachers;
    
    return ListView(
      children: List.generate(displayList.length, (index) {
        final item = displayList[index];
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            TeacherListItem(
                imageLink: "",
                firstName: item.user.firstName,
                lastName: item.user.lastName,
                userName: item.user.username),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DeleteConfirmationDialog(
                          onConfirm: () {
                            provider.deleteTeacher(item.id, index, false);
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete)),
            )
          ],
        );
      }),
    );
  }
}
