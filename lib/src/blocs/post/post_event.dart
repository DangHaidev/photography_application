import 'package:flutter/material.dart';

abstract class PostEvent {}

class FetchPostsEvent extends PostEvent {
  final bool isFollowingTab;
  final BuildContext? context;

  FetchPostsEvent({this.isFollowingTab = false, this.context});
}

class FetchMorePostsEvent extends PostEvent {
  final bool isFollowingTab;
  final BuildContext context;

  FetchMorePostsEvent({this.isFollowingTab = false, required this.context});
}

class LikePostEvent extends PostEvent {
  final String postId;

  LikePostEvent(this.postId);
}

class RefreshPostsEvent extends PostEvent {}