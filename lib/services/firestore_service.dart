import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import '../models/friend_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Profile
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? username,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'username': username ?? email.split('@')[0],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Avatar güncelleme
  Future<void> updateUserAvatar(String userId, String avatarId) async {
    await _firestore.collection('users').doc(userId).update({
      'avatarId': avatarId,
    });
  }

  // Favorites
  Future<void> addToFavorites({
    required String userId,
    required Movie movie,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(movie.id.toString())
        .set({
      'movieId': movie.id,
      'title': movie.title,
      'posterPath': movie.posterPath,
      'voteAverage': movie.voteAverage,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromFavorites({
    required String userId,
    required int movieId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(movieId.toString())
        .delete();
  }

  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<bool> isInFavorites({
    required String userId,
    required int movieId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(movieId.toString())
        .get();

    return doc.exists;
  }

  Stream<int> getFavoritesCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Watchlist
  Future<void> addToWatchlist({
    required String userId,
    required Movie movie,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movie.id.toString())
        .set({
      'movieId': movie.id,
      'title': movie.title,
      'posterPath': movie.posterPath,
      'voteAverage': movie.voteAverage,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromWatchlist({
    required String userId,
    required int movieId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId.toString())
        .delete();
  }

  Future<List<Map<String, dynamic>>> getWatchlist(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<int> getWatchlistCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<bool> isInWatchlist({
    required String userId,
    required int movieId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId.toString())
        .get();

    return doc.exists;
  }

  // Comments/Reviews
  Future<void> addComment({
    required String movieId,
    required String userId,
    required String username,
    required String comment,
    required double rating,
    required bool isSpoiler,
  }) async {
    await _firestore.collection('comments').add({
      'movieId': movieId,
      'userId': userId,
      'username': username,
      'comment': comment,
      'rating': rating,
      'isSpoiler': isSpoiler,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getComments(String movieId) {
    return _firestore
        .collection('comments')
        .where('movieId', isEqualTo: movieId)
        // orderBy geçici olarak kaldırıldı - Firestore index hatası için
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }

  // Movie Discussions (Chat)
  Future<void> sendMessage({
    required String movieId,
    required String userId,
    required String username,
    required String message,
  }) async {
    await _firestore.collection('discussions').add({
      'movieId': movieId,
      'userId': userId,
      'username': username,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getDiscussions(String movieId) {
    return _firestore
        .collection('discussions')
        .where('movieId', isEqualTo: movieId)
        // orderBy geçici olarak kaldırıldı - Firestore index hatası için
        // .orderBy('createdAt', descending: false) // Eski mesajlar üstte
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('discussions').doc(messageId).delete();
  }

  // Friendship System

  // Kullanıcı arama
  Future<List<Map<String, dynamic>>> searchUsers(String query, String currentUserId) async {
    if (query.isEmpty) return [];

    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: query + 'z')
        .limit(20)
        .get();

    // Mevcut kullanıcıyı filtrele
    return snapshot.docs
        .where((doc) => doc.id != currentUserId)
        .map((doc) {
          final data = doc.data();
          data['userId'] = doc.id;
          return data;
        })
        .toList();
  }

  // Arkadaşlık isteği gönder
  Future<void> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
    required String fromUsername,
    required String toUsername,
    String? fromAvatarId,
    String? toAvatarId,
  }) async {
    // Zaten istek var mı kontrol et
    final existingRequest = await _firestore
        .collection('friendRequests')
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingRequest.docs.isNotEmpty) {
      throw Exception('Zaten bir arkadaşlık isteği gönderildi');
    }

    // Zaten arkadaş mı kontrol et
    final alreadyFriends = await _firestore
        .collection('users')
        .doc(fromUserId)
        .collection('friends')
        .doc(toUserId)
        .get();

    if (alreadyFriends.exists) {
      throw Exception('Zaten arkadaşsınız');
    }

    await _firestore.collection('friendRequests').add({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUsername': fromUsername,
      'toUsername': toUsername,
      'fromAvatarId': fromAvatarId,
      'toAvatarId': toAvatarId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Gelen arkadaşlık istekleri
  Stream<List<FriendRequest>> getReceivedFriendRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequest.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Gönderilen arkadaşlık istekleri
  Stream<List<FriendRequest>> getSentFriendRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('fromUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequest.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Arkadaşlık isteğini kabul et
  Future<void> acceptFriendRequest(String requestId) async {
    final requestDoc = await _firestore.collection('friendRequests').doc(requestId).get();
    if (!requestDoc.exists) return;

    final request = FriendRequest.fromMap(requestId, requestDoc.data()!);

    // İsteği kabul edildi olarak güncelle
    await _firestore.collection('friendRequests').doc(requestId).update({
      'status': 'accepted',
    });

    // İki yönlü arkadaşlık ekle
    final batch = _firestore.batch();

    // fromUser'ın arkadaşları listesine toUser'ı ekle
    batch.set(
      _firestore
          .collection('users')
          .doc(request.fromUserId)
          .collection('friends')
          .doc(request.toUserId),
      {
        'userId': request.toUserId,
        'username': request.toUsername,
        'avatarId': request.toAvatarId,
        'addedAt': FieldValue.serverTimestamp(),
      },
    );

    // toUser'ın arkadaşları listesine fromUser'ı ekle
    batch.set(
      _firestore
          .collection('users')
          .doc(request.toUserId)
          .collection('friends')
          .doc(request.fromUserId),
      {
        'userId': request.fromUserId,
        'username': request.fromUsername,
        'avatarId': request.fromAvatarId,
        'addedAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  // Arkadaşlık isteğini reddet
  Future<void> rejectFriendRequest(String requestId) async {
    await _firestore.collection('friendRequests').doc(requestId).update({
      'status': 'rejected',
    });
  }

  // Arkadaş listesi
  Stream<List<Friend>> getFriendsList(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Friend.fromMap(doc.data())).toList());
  }

  // Arkadaşı sil
  Future<void> removeFriend(String userId, String friendId) async {
    final batch = _firestore.batch();

    // Her iki taraftan da arkadaşlığı sil
    batch.delete(
      _firestore.collection('users').doc(userId).collection('friends').doc(friendId),
    );

    batch.delete(
      _firestore.collection('users').doc(friendId).collection('friends').doc(userId),
    );

    await batch.commit();
  }

  // Uyumluluk hesapla
  Future<double> calculateCompatibility(String userId1, String userId2) async {
    // İki kullanıcının favori filmlerini getir
    final favorites1 = await getFavorites(userId1);
    final favorites2 = await getFavorites(userId2);

    if (favorites1.isEmpty && favorites2.isEmpty) return 0.0;

    // Film ID'lerini al - null değerleri güvenli şekilde filtrele
    final movieIds1 = favorites1
        .map((f) => f['movieId'] as int?)
        .where((id) => id != null)
        .cast<int>()
        .toSet();
    final movieIds2 = favorites2
        .map((f) => f['movieId'] as int?)
        .where((id) => id != null)
        .cast<int>()
        .toSet();

    // Ortak filmleri bul
    final commonMovies = movieIds1.intersection(movieIds2).length;

    // Total unique filmleri bul
    final totalMovies = movieIds1.union(movieIds2).length;

    if (totalMovies == 0) return 0.0;

    return (commonMovies / totalMovies) * 100;
  }

  // Ortak favori filmleri getir
  Future<List<Map<String, dynamic>>> getCommonFavorites(String userId1, String userId2) async {
    final favorites1 = await getFavorites(userId1);
    final favorites2 = await getFavorites(userId2);

    final movieIds1 = favorites1
        .map((f) => f['movieId'] as int?)
        .where((id) => id != null)
        .cast<int>()
        .toSet();
    final movieIds2 = favorites2
        .map((f) => f['movieId'] as int?)
        .where((id) => id != null)
        .cast<int>()
        .toSet();

    final commonIds = movieIds1.intersection(movieIds2);

    // Null-safe filtering - sadece movieId'si olan ve ortak listede bulunan filmleri döndür
    return favorites1
        .where((f) => f['movieId'] != null && commonIds.contains(f['movieId']))
        .toList();
  }

  // Uyumluluk skorunu güncelle (cache için)
  Future<void> updateCompatibilityScore(String userId, String friendId, double score) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friendId)
        .update({'compatibilityScore': score});
  }

  // Bekleme durumunda istek var mı
  Future<bool> hasPendingRequest(String fromUserId, String toUserId) async {
    final requests = await _firestore
        .collection('friendRequests')
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .where('status', isEqualTo: 'pending')
        .get();

    return requests.docs.isNotEmpty;
  }

  // Arkadaş mı kontrol et
  Future<bool> areFriends(String userId1, String userId2) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId1)
        .collection('friends')
        .doc(userId2)
        .get();

    return doc.exists;
  }
}
