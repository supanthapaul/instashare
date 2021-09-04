import 'package:flutter/material.dart';
import 'package:instashare/widgets/custom_image.dart';
import 'package:instashare/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("showing post"),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
