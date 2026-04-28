class ChatSource {
  const ChatSource({
    required this.title,
    required this.ref,
    this.url,
  });

  final String title;
  final String ref;
  final String? url;

  Map<String, dynamic> toJson() => {
        'title': title,
        'ref': ref,
        'url': url,
      };

  static ChatSource fromJson(Map<String, dynamic> json) => ChatSource(
        title: (json['title'] as String?) ?? '',
        ref: (json['ref'] as String?) ?? '',
        url: json['url'] as String?,
      );
}

