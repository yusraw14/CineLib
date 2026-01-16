import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/friend_model.dart';
import '../models/avatar_model.dart';
import 'friend_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final Map<String, double> _compatibilityScores = {};

  User? get _currentUser => _authService.currentUser;

  Future<void> _loadCompatibility(String friendId) async {
    if (_compatibilityScores.containsKey(friendId)) return;

    try {
      final score = await _firestoreService.calculateCompatibility(
        _currentUser!.uid,
        friendId,
      );

      if (mounted) {
        setState(() {
          _compatibilityScores[friendId] = score;
        });

        // Score'u cache'le - hata olsa da devam et
        try {
          await _firestoreService.updateCompatibilityScore(
            _currentUser!.uid,
            friendId,
            score,
          );
        } catch (e) {
          // Cache güncelleme hatası kritik değil, sessizce yoksay
          print('Uyumluluk skoru cache hatası: $e');
        }
      }
    } catch (e) {
      // Uyumluluk hesaplama hatası - varsayılan değer kullan
      print('Uyumluluk hesaplama hatası: $e');
      if (mounted) {
        setState(() {
          _compatibilityScores[friendId] = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Arkadaşlarım'),
        elevation: 0,
      ),
      body: StreamBuilder<List<Friend>>(
        stream: _firestoreService.getFriendsList(_currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz arkadaşınız yok',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kullanıcı arayarak arkadaş ekleyin',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final friends = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              
              // Uyumluluk skorunu yükle
              if (!_compatibilityScores.containsKey(friend.userId)) {
                _loadCompatibility(friend.userId);
              }

              return _buildFriendCard(friend);
            },
          );
        },
      ),
    );
  }

  Widget _buildFriendCard(Friend friend) {
    final avatar = AvatarModel.getByIdOrDefault(friend.avatarId);
    final compatibilityScore = _compatibilityScores[friend.userId] ?? 
        friend.compatibilityScore ?? 
        0.0;

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FriendProfileScreen(friend: friend),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(avatar.imagePath, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              
              // Kullanıcı bilgisi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Uyumluluk göstergesi
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              children: [
                                const TextSpan(text: 'Uyumluluk: '),
                                TextSpan(
                                  text: '${compatibilityScore.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: _getCompatibilityColor(compatibilityScore),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: compatibilityScore / 100,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCompatibilityColor(compatibilityScore),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Chevron
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCompatibilityColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
