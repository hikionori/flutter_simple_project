import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey[700]!),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int characters = 0;
  int exclamatioMarks = 0;
  late File file;
  double fileSize = 0;
  String fileType = '';
  int paragraph = 0;
  int questionMarks = 0;
  int sentences = 0;
  String text = '';
  int words = 0;

  bool countParagraph = false;
  bool countWords = false;
  bool countSentences = false;
  bool countCharacters = false;
  bool countQuestionMarks = false;
  bool countExclamationMarks = false;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
        ),
      ),
    );
  }

  Future<void> pickFile() async {
    setState(() {
      text = '';
      fileSize = 0;
      // reset all values
      paragraph = 0;
      words = 0;
      sentences = 0;
      characters = 0;
      questionMarks = 0;
      exclamatioMarks = 0;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'doc', 'docx']);
    if (result != null) {
      file = File(result.files.single.path!);
      fileSize = file.lengthSync() / 1024;
      fileType = result.files.single.extension!;

      switch (fileType) {
        case "txt":
          text = await file.readAsString();
          break;
        case "pdf":
          try {
            text = await readPdfText(file);
          } catch (e) {
            showSnackBar("Can't read pdf file");
          }
          break;
        case "doc" || "docx":
          final bytes = await file.readAsBytes();
          text = docxToText(bytes);
          break;
        default:
          showSnackBar("Can't read this file", isError: true);
      }
    }
  }

  Future<String> readPdfText(File file) async {
    final PdfDocument document =
        PdfDocument(inputBytes: await file.readAsBytes());
    String text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }

  void _count() {
    _countCharacters();
    _countExclamationMarks();
    _countParagraph();
    _countQuestionMarks();
    _countSentences();
    _countWords();
  }

  void _countParagraph() {
    setState(() {
      paragraph = text.split('\n').length;
    });
  }

  void _countWords() {
    setState(() {
      words = text.split(' ').length;
    });
  }

  void _countSentences() {
    setState(() {
      sentences = text.split('.').length;
    });
  }

  void _countCharacters() {
    setState(() {
      characters = text.length;
    });
  }

  void _countQuestionMarks() {
    setState(() {
      questionMarks = text.split('?').length;
    });
  }

  void _countExclamationMarks() {
    setState(() {
      exclamatioMarks = text.split('!').length;
    });
  }

  @override
  void initState() {
    super.initState();
    // show modal with warning about work with pdf is not stable
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Warning"),
          backgroundColor: Colors.amber[100],
          content: const Text(
              "Work with pdf is not stable. If you want to count pdf file, you need to convert it to txt file. If you ignore this warning, some may work incorrectly."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const SizedBox(height: 50),
            const Text(
              'Welcome to Doc Counter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // checkboxes for counting. checked = count
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                      value: countWords,
                      title: const Text(
                        'Count Words',
                        style: TextStyle(),
                      ),
                      onChanged: (value) => {
                            setState(() {
                              countWords = !countWords;
                            }),
                          }),
                  CheckboxListTile(
                      value: countSentences,
                      title: const Text('Count Sentences'),
                      onChanged: (value) => {
                            setState(() {
                              countSentences = !countSentences;
                            }),
                          }),
                  CheckboxListTile(
                      value: countCharacters,
                      title: const Text('Count Characters'),
                      onChanged: (value) => {
                            setState(() {
                              countCharacters = !countCharacters;
                            }),
                          }),
                  CheckboxListTile(
                      value: countQuestionMarks,
                      title: const Text('Count Question Marks'),
                      onChanged: (value) => {
                            setState(() {
                              countQuestionMarks = !countQuestionMarks;
                            }),
                          }),
                  CheckboxListTile(
                      value: countExclamationMarks,
                      title: const Text('Count Exclamation Marks'),
                      onChanged: (value) => {
                            setState(() {
                              countExclamationMarks = !countExclamationMarks;
                            }),
                          }),
                  CheckboxListTile(
                      value: countParagraph,
                      title: const Text('Count Paragraph'),
                      onChanged: (value) => {
                            setState(() {
                              countParagraph = !countParagraph;
                            }),
                          }),
                ],
              ),
            ),

            const Text(
              "Result:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            fileSize > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                            'File size: ${fileSize.toStringAsFixed(2)} KB'),
                      ),
                      // matching checkboxes with counting
                      countWords
                          ? ListTile(
                              title: Text('Words: ${words.toString()}'),
                            )
                          : const SizedBox(),
                      countSentences
                          ? ListTile(
                              title: Text('Sentences: ${sentences.toString()}'),
                            )
                          : const SizedBox(),
                      countCharacters
                          ? ListTile(
                              title:
                                  Text('Characters: ${characters.toString()}'),
                            )
                          : const SizedBox(),
                      countQuestionMarks
                          ? ListTile(
                              title: Text(
                                  'Question Marks: ${questionMarks.toString()}'),
                            )
                          : const SizedBox(),
                      countExclamationMarks
                          ? ListTile(
                              title: Text(
                                  'Exclamation Marks: ${exclamatioMarks.toString()}'),
                            )
                          : const SizedBox(),
                      countParagraph
                          ? ListTile(
                              title: Text('Paragraph: ${paragraph.toString()}'),
                            )
                          : const SizedBox(),
                    ],
                  )
                : const Text('No file selected'),
            GestureDetector(
              onTap: () {
                if (fileSize > 0) {
                  _count();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: fileSize > 0
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Count',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            if (fileSize > 0) const SizedBox(height: 50),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            // button for selecting file
            onPressed: () async {
              await pickFile();
              setState(() {});
            },
            tooltip: 'Pick File',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () => {
              // show preview of file
              // with srollable text
              if (fileSize > 0)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Preview of ${file.path}"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                    content: SingleChildScrollView(
                      child: Text(text.trim()),
                    ),
                  ),
                )
              else
                showSnackBar("No file selected")
            },
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Icon(
              Icons.preview,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          FloatingActionButton.small(
            onPressed: () => {
              // remove all data
              if (fileSize > 0)
                setState(() {
                  text = '';
                  fileSize = 0;

                  // reset all values
                  paragraph = 0;
                  words = 0;
                  sentences = 0;
                  characters = 0;
                  questionMarks = 0;
                  exclamatioMarks = 0;
                })
              else
                showSnackBar("No file selected")
            },
            tooltip: 'Clear',
            backgroundColor: fileSize > 0
                ? Theme.of(context).colorScheme.error
                : Colors.grey,
            child: Icon(
              Icons.clear,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}
