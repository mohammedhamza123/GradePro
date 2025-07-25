import 'package:flutter/material.dart';
import 'package:gradpro/providers/pdf_viewer_provider.dart';
import 'package:provider/provider.dart';

import '../../models/project_details_list.dart';
import '../../models/student_details_list.dart';
import '../../providers/chat_provider.dart';
import 'student_list_item.dart';
import '../../providers/admin_teacher_provider.dart';

class ProjectWidget extends StatelessWidget {
  final String title;
  final String image;
  final double bottomPadding;

  const ProjectWidget(
      {super.key,
      required this.title,
      required this.image,
      this.bottomPadding = 16.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, bottomPadding),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 97,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.0),
                  child: Image.asset("assets/pdfImage.png"),
                )),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow
                          .fade, // Handle overflowed text with an ellipsis
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectMoreDetails extends StatefulWidget {
  final ProjectDetail project;
  final void Function()? onExtend;
  final Future<List<StudentDetail>>? onLoad;

  const ProjectMoreDetails({
    super.key,
    this.onExtend,
    this.onLoad,
    required this.project,
  });

  @override
  State<ProjectMoreDetails> createState() => _ProjectMoreDetailsState();
}

class _ProjectMoreDetailsState extends State<ProjectMoreDetails> {
  bool _showMore = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: _showMore
                  ? const BorderRadius.all(Radius.circular(32))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32)),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {},
                  child: SizedBox(
                      height: 97,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32.0),
                        child: Image.asset(
                          "assets/pdfImage.png",
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/missing_image_icon.png",
                              fit: BoxFit.contain,
                              height: 97,
                            );
                          },
                          fit: BoxFit.cover,
                          height: 97,
                        ),
                      )),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.project.title,
                      maxLines: 3,
                      overflow: TextOverflow
                          .fade, // Handle overflowed text with an ellipsis
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _showMore = !_showMore;
                      if (widget.onExtend != null) {
                        widget.onExtend!();
                      }
                      setState(() {});
                    },
                    icon: Icon(_showMore
                        ? Icons.arrow_drop_down
                        : Icons.arrow_drop_up))
              ],
            ),
          ),
          _showMore
              ? Container()
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<PdfViewerProvider>(
                          builder: (context, provider, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: widget.project.examiner1Raw != null
                                  ? "عرض التقييم الأول"
                                  : "لا يوجد تقييم أول",
                              child: IconButton(
                                  onPressed: () {
                                    if (widget.project.examiner1Raw != null) {
                                      provider.setPdf(widget
                                          .project.examiner1Raw!
                                          .toString());
                                      Navigator.pushNamed(
                                          context, "/pdfViewer");
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "لا يوجد تقييم أول محفوظ")),
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.picture_as_pdf,
                                      color: widget.project.examiner1Raw != null
                                          ? Colors.blue
                                          : Colors.grey)),
                            ),
                            Tooltip(
                              message: widget.project.examiner2Raw != null
                                  ? "عرض التقييم الثاني"
                                  : "لا يوجد تقييم ثاني",
                              child: IconButton(
                                  onPressed: () {
                                    if (widget.project.examiner2Raw != null) {
                                      provider.setPdf(widget
                                          .project.examiner2Raw!
                                          .toString());
                                      Navigator.pushNamed(
                                          context, "/pdfViewer");
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "لا يوجد تقييم ثاني محفوظ")),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.picture_as_pdf,
                                    color: widget.project.examiner2Raw != null
                                        ? Colors.green
                                        : Colors.grey,
                                  )),
                            ),
                            Tooltip(
                                message: widget.project.supervisorRaw != null
                                    ? "عرض تقييم المشرف"
                                    : "لا يوجد تقييم مشرف محفوظ",
                                child: IconButton(
                                    onPressed: () {
                                      if (widget.project.supervisorRaw !=
                                          null) {
                                        provider.setPdf(widget
                                            .project.supervisorRaw!
                                            .toString());
                                        Navigator.pushNamed(
                                            context, "/pdfViewer");
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "لا يوجد تقييم مشرف محفوظ")),
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.picture_as_pdf,
                                        color:
                                            widget.project.supervisorRaw != null
                                                ? Colors.orange
                                                : Colors.grey))),
                          ],
                        );
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          widget.project.teacher != null
                              ? Text(
                                  " المشرف: ${widget.project.teacher?.user.firstName} ${widget.project.teacher?.user.lastName}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              : const Text(
                                  "لا يوجد مشرف للمشروع",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Text(
                              "نسبة الانجاز",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                                child: LinearProgressIndicator(
                                    value: widget.project.progression))
                          ],
                        ),
                      ),
                      FutureBuilder<List<StudentDetail>>(
                          future: widget.onLoad,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SizedBox(
                                height: 150,
                                child: ListView(
                                  children: List.generate(snapshot.data!.length,
                                      (index) {
                                    final item = snapshot.data![index];
                                    return StudentListItem(
                                      firstName: item.user.firstName,
                                      imageLink: '',
                                      lastName: item.user.lastName,
                                      userName: item.user.username,
                                    );
                                  }),
                                ),
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                            onPressed: () {
                              Provider.of<ChatProvider>(context, listen: false)
                                  .setProject(item: widget.project);
                              Navigator.pushNamed(context, "/chat");
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("الدخول للمحادثة"),
                                Icon(Icons.message)
                              ],
                            )),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
