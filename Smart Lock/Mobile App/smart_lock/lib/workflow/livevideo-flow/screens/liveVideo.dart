import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveVideo_Screen extends StatefulWidget {
  const LiveVideo_Screen({Key? key}) : super(key: key);

  @override
  State<LiveVideo_Screen> createState() => _LiveVideo_ScreenState();
}

class _LiveVideo_ScreenState extends State<LiveVideo_Screen> {
  final Uri _url = Uri.parse('http://192.168.29.99:5012/video_feed');

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Center(
          child: ElevatedButton(
            onPressed: _launchUrl,
            child: Text('Show Flutter homepage'),
          ),
        ),
      ),
    );
  }
}
