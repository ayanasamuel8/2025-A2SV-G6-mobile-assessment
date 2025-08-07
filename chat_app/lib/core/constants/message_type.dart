enum MessageType {
  text,
  image,
  file,
  video;

  @override
  String toString() {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.video:
        return 'Video';
      case MessageType.file:
        return 'File';
    }
  }
}
