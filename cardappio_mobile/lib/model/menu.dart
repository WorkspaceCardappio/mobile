class Menu {
  final String id;
  final String name;
  final String note;
  final bool active;
  final String theme;

  Menu({
    required this.id,
    required this.name,
    required this.note,
    required this.active,
    required this.theme,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    final String selfLink = json['_links']['self']['href'];
    final String id = selfLink.substring(selfLink.lastIndexOf('/') + 1);

    return Menu(
      id: id,
      name: json['name'] ?? 'Cardápio sem Nome',
      note: json['note'] ?? 'Sem descrição.',
      active: json['active'] ?? false,
      theme: json['theme'] ?? 'Padrão',
    );
  }
}