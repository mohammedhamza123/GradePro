import 'package:flutter/material.dart';
import 'package:gradpro/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/student_provider.dart';

class BottomNavigator extends StatelessWidget {
  const BottomNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(builder: (context, provider, _) {
      return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'المواعيد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'المقترحات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.short_text_outlined),
            label: 'تفاصيل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'الإرشيف',
          ),
        ],
        currentIndex: provider.selectedIndex,
        selectedItemColor: const Color(0xff00577B),
        unselectedItemColor: Colors.grey,
        onTap: provider.onItemTapped,
      );
    });
  }
}

class StudentBottomNavigator extends StatelessWidget {
  const StudentBottomNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(builder: (context, provider, _) {
      return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'المواعيد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.short_text_outlined),
            label: 'تفاصيل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'الإرشيف',
          ),
        ],
        currentIndex: provider.selectedIndex,
        selectedItemColor: const Color(0xff00577B),
        unselectedItemColor: Colors.grey,
        onTap: provider.onItemTapped,
      );
    });
  }
}

class TeacherBottomNavigator extends StatelessWidget {
  const TeacherBottomNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(builder: (context, provider, _) {
      return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'المواعيد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.short_text_outlined),
            label: 'تفاصيل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'المشاريع',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            label: 'التقييم',
          ),
        ],
        currentIndex: provider.selectedIndex,
        selectedItemColor: const Color(0xff00577B),
        unselectedItemColor: Colors.grey,
        onTap: provider.onItemTapped,
      );
    });
  }
}
