import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import 'suggestion_styles.dart';
import 'widget_dialog.dart';

class AddSuggestionPage extends StatelessWidget {
  const AddSuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<StudentProvider>(builder: (context, provider, _) {
        return Center(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kCardRadius),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "إضافة مقترح جديد",
                      style: kTitleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      onChanged: provider.setNewSuggestionTitle,
                      decoration: InputDecoration(
                        hintText: "عنوان المقترح",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kCardRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kCardRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      onChanged: provider.setNewSuggestionContent,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            "تفاصيل المقترح يكمنك الكتابة هنا كما تشاء ...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kCardRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kCardRadius),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    provider.suggestionUrl != ""
                        ? Center(
                            child: SizedBox(
                              width: 250,
                              height: 250,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(kCardRadius),
                                child: Image.network(provider.suggestionUrl),
                              ),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "إختيار صورة",
                          style: kBodyTextStyle,
                        ),
                        IconButton(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (pickedFile != null) {
                              final file = File(pickedFile.path);
                              final bytes = await file.readAsBytes();
                              final base64Image = base64Encode(bytes);
                              provider.setImageBase64(base64Image);
                              await provider.uploadImage();
                            }
                          },
                          icon: const Icon(
                            Icons.upload_file,
                            size: 40,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              provider.setNewSuggestion(false);
                            },
                            style: kButtonStyle,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.arrow_back_ios),
                                ),
                                Text(
                                  "رجوع",
                                  style: kBodyTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SaveConfirmationDialog(onPress: () {
                                      provider.loadingSaveSuggestion = true;
                                      provider.createProject();
                                      provider.setNewSuggestion(false);
                                    });
                                  });
                            },
                            style: kButtonStyle,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "حفظ المقترح",
                                  style: kTitleTextStyle,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.save),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
} 