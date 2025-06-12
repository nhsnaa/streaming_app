import 'package:flutter/material.dart';
import 'tv_widget.dart';

class TVType extends StatelessWidget {
  final String title;
  final Future<List<dynamic>> Function() fetchTV;

  const TVType({
    Key? key,
    required this.title,
    required this.fetchTV,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TVWidget(
      title: title,
      fetchTVShows: fetchTV,
    );
  }
}