String formatTime(DateTime createdAt) {
  final now = DateTime.now();
  final difference = now.difference(createdAt);

  if (difference.inDays > 1) {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} giờ trước';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} phút trước';
  } else {
    return 'Vừa xong';
  }
}