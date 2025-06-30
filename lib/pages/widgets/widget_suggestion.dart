import 'package:flutter/material.dart';

class Suggestion extends StatelessWidget {
  final String content;
  final String status;
  final String title;
  final String image;
  final void Function()? onPress;

  const Suggestion(
      {super.key,
      required this.content,
      required this.status,
      this.onPress,
      required this.title,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: 97,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32.0),
                    child: Image.network(image),
                  )),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        content,
                        maxLines: 3,
                        overflow: TextOverflow
                            .fade, // Handle overflowed text with an ellipsis
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ]),
                  child: status == "w"
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.access_time,
                            color: Colors.orangeAccent,
                          ),
                        )
                      : status == "a"
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.done,
                                color: Colors.blue,
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
            ],
          ),
        ),
      ),
    );
  }
}
