class MediaModel {
  final String id;          // Filmin veya kitabın benzersiz kimliği
  final String title;       // Adı (Örn: Harry Potter)
  final String type;        // Türü: 'movie', 'series', 'book'
  final String imageUrl;    // Afiş resmi linki
  final String description; // Konusu / Özeti
  final double rating;      // Genel puanı (Örn: 4.5)
  final String? adaptationId; // Eğer uyarlama ise diğer eserin ID'si (Burası önemli!)

  MediaModel({
    required this.id,
    required this.title,
    required this.type,
    required this.imageUrl,
    required this.description,
    required this.rating,
    this.adaptationId,
  });

  // Veritabanından (Firebase/API) gelen veriyi uygulamaya çevirir
  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? 'İsimsiz Eser',
      type: map['type'] ?? 'movie',
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150', // Resim yoksa boş kutu göster
      description: map['description'] ?? 'Açıklama yok.',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      adaptationId: map['adaptationId'],
    );
  }

  // Uygulamadan veritabanına veri gönderirken pakete çevirir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'adaptationId': adaptationId,
    };
  }
}