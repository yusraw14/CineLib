class AvatarModel {
  final String id;
  final String name;
  final String imagePath;

  const AvatarModel({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  // Önceden tanımlanmış avatar modelleri
  static const List<AvatarModel> predefinedAvatars = [
    AvatarModel(
      id: 'director',
      name: 'Film Yönetmeni',
      imagePath: 'assets/avatars/avatar_director.png',
    ),
    AvatarModel(
      id: 'actress',
      name: 'Aktris',
      imagePath: 'assets/avatars/avatar_actress.png',
    ),
    AvatarModel(
      id: 'critic',
      name: 'Film Eleştirmeni',
      imagePath: 'assets/avatars/avatar_critic.png',
    ),
    AvatarModel(
      id: 'cameraman',
      name: 'Kameraman',
      imagePath: 'assets/avatars/avatar_cameraman.png',
    ),
    AvatarModel(
      id: 'producer',
      name: 'Yapımcı',
      imagePath: 'assets/avatars/avatar_producer.png',
    ),
    AvatarModel(
      id: 'award',
      name: 'Ödül Kazanan',
      imagePath: 'assets/avatars/avatar_award.png',
    ),
    AvatarModel(
      id: 'screenwriter',
      name: 'Senarist',
      imagePath: 'assets/avatars/avatar_screenwriter.png',
    ),
    AvatarModel(
      id: 'fan',
      name: 'Sinema Hayranı',
      imagePath: 'assets/avatars/avatar_fan.png',
    ),
    AvatarModel(
      id: 'editor',
      name: 'Editör',
      imagePath: 'assets/avatars/avatar_editor.png',
    ),
    AvatarModel(
      id: 'usher',
      name: 'Sinema Görevlisi',
      imagePath: 'assets/avatars/avatar_usher.png',
    ),
    AvatarModel(
      id: 'cinephile',
      name: 'Sinemasever',
      imagePath: 'assets/avatars/avatar_cinephile.png',
    ),
    AvatarModel(
      id: 'stunt',
      name: 'Aksiyon Dublörü',
      imagePath: 'assets/avatars/avatar_stunt.png',
    ),
  ];

  // ID'ye göre avatar bul
  static AvatarModel? getById(String id) {
    try {
      return predefinedAvatars.firstWhere((avatar) => avatar.id == id);
    } catch (e) {
      return null;
    }
  }

  // ID'ye göre avatar bul veya varsayılan döndür
  static AvatarModel getByIdOrDefault(String? id) {
    if (id == null) return predefinedAvatars.first;
    return getById(id) ?? predefinedAvatars.first;
  }
}
