class ReviewModel {
  final String id;
  final String userName;    // Yorumu yapan kişinin adı
  final String mediaId;     // Hangi filme/kitaba yorum yapıldı?
  final String comment;     // Yorum metni
  final double rating;      // Verilen yıldız (1-5 arası)
  final bool isSpoiler;     // 🔥 İşte senin spoiler özelliği! (True ise bulanıklaşacak)
  final int loyaltyScore;   // 🛡️ Uyarlama Sadakat Puanı (0-100 arası). Sadece uyarlamalar için.

  ReviewModel({
    required this.id,
    required this.userName,
    required this.mediaId,
    required this.comment,
    required this.rating,
    this.isSpoiler = false, // Varsayılan olarak spoiler yok diyelim
    this.loyaltyScore = 0,
  });

  // Veritabanından gelen veriyi okur
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id']?.toString() ?? '',
      userName: map['userName'] ?? 'Anonim',
      mediaId: map['mediaId'] ?? '',
      comment: map['comment'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      isSpoiler: map['isSpoiler'] ?? false,
      loyaltyScore: map['loyaltyScore'] ?? 0,
    );
  }

  // Veritabanına kaydeder
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'mediaId': mediaId,
      'comment': comment,
      'rating': rating,
      'isSpoiler': isSpoiler,
      'loyaltyScore': loyaltyScore,
    };
  }
}