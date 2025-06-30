import 'package:flutter/material.dart';

class StudentListItem extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String userName;
  final String imageLink;

  const StudentListItem({
    super.key,
    required this.imageLink,
    required this.firstName,
    required this.lastName,
    required this.userName,
  });

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
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
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
