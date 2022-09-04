import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_handler/share_handler.dart';

import 'vcard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedMedia? media;
  String numberr = "";
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      read();
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Share Handler'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              //TextButton(onPressed: read, child: const Text("read")),
              //Text("Conversation Identifier: ${media?.conversationIdentifier}"),
              const SizedBox(height: 10),
              if (Platform.isIOS) Text("Tel Number IOS: ${media?.content}"),
              const SizedBox(height: 10),
              Text(
                  "Shared files: ${media?.attachments?.length} vcf file shared"),
              ...(media?.attachments ?? []).map((attachment) {
                final _path = attachment?.path;
                if (_path != null &&
                    attachment?.type == SharedAttachmentType.image) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ShareHandlerPlatform.instance.recordSentMessage(
                            conversationIdentifier:
                                "custom-conversation-identifier",
                            conversationName: "John Doe",
                            conversationImageFilePath: _path,
                            serviceName: "custom-service-name",
                          );
                        },
                        child: const Text("Record message"),
                      ),
                      const SizedBox(height: 10),
                      Image.file(File(_path)),
                    ],
                  );
                } else {
                  return Text(" Tel Number:  $numberr");
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final handler = ShareHandler.instance;
    media = await handler.getInitialSharedMedia();

    handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      setState(() {
        this.media = media;
      });
    });
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  read() async {
    var directory = await getApplicationDocumentsDirectory();
    File file = File(directory.absolute.parent.path + "/cache/xc.vcf");
    numberr = file.readAsStringSync();
    VCard vc = VCard(numberr);
    numberr = vc.typedTelephone.first.toString();
    setState(() {});
  }
}
