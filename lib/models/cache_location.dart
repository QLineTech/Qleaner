class CacheLocation {
  final String id;
  final String path;
  final String name;
  final String description;
  final String category;
  final String hint;
  final String impact;
  final String risk;
  int size;
  String sizeHuman;
  bool selected;
  bool exists;

  CacheLocation({
    required this.id,
    required this.path,
    required this.name,
    required this.description,
    required this.category,
    required this.hint,
    required this.impact,
    required this.risk,
    this.size = 0,
    this.sizeHuman = "0B",
    this.selected = false,
    this.exists = false,
  });

  factory CacheLocation.fromJson(Map<String, dynamic> json) {
    return CacheLocation(
      id: json['id'],
      path: json['path'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      hint: json['hint'],
      impact: json['impact'],
      risk: json['risk'],
      size: json['size'] ?? 0,
      sizeHuman: json['size_human'] ?? "0B",
      selected: json['selected'] ?? false,
      exists: json['exists'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'description': description,
      'category': category,
      'hint': hint,
      'impact': impact,
      'risk': risk,
      'size': size,
      'size_human': sizeHuman,
      'selected': selected,
      'exists': exists,
    };
  }
}
