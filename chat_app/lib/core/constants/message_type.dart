enum MessageType {
  text,
  image,
  file,
  video;

  @override
  String toString() {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.file:
        return 'file';
    }
  }
}
