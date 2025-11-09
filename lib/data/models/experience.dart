class Experience {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String imageUrl;
  final String iconUrl;

  Experience({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.iconUrl,
  });

  factory Experience.fromJson(Map<String, dynamic> j) => Experience(
    id: j['id'] ?? 0,
    name: j['name'] ?? '',
    tagline: j['tagline'] ?? '',
    description: j['description'] ?? '',
    imageUrl: j['image_url'] ?? '',
    iconUrl: j['icon_url'] ?? '',
  );
}
