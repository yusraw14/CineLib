import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../models/avatar_model.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'favorites_screen.dart';
import 'watchlist_screen.dart';
import 'friends_screen.dart';
import 'friend_requests_screen.dart';
import 'search_users_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  User? get _currentUser => _authService.currentUser;
  String _username = '';
  String? _avatarId;
  int _favoritesCount = 0;
  int _watchlistCount = 0;
  int _friendRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    // Load user profile
    final profile = await _firestoreService.getUserProfile(_currentUser!.uid);
    if (profile != null && mounted) {
      setState(() {
        _username = profile['username'] ?? 'Kullanıcı';
        _avatarId = profile['avatarId'];
      });
    }

    // Listen to favorites count
    _firestoreService.getFavoritesCount(_currentUser!.uid).listen((count) {
      if (mounted) {
        setState(() {
          _favoritesCount = count;
        });
      }
    });

    // Listen to watchlist count
    _firestoreService.getWatchlistCount(_currentUser!.uid).listen((count) {
      if (mounted) {
        setState(() {
          _watchlistCount = count;
        });
      }
    });

    // Listen to friend requests count
    _firestoreService.getReceivedFriendRequests(_currentUser!.uid).listen((requests) {
      if (mounted) {
        setState(() {
          _friendRequestsCount = requests.length;
        });
      }
    });
  }

  // Avatar seçim dialogu
  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Avatar Seç',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.maxFinite,
                height: 400,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: AvatarModel.predefinedAvatars.length,
                  itemBuilder: (context, index) {
                    final avatar = AvatarModel.predefinedAvatars[index];
                    final isSelected = _avatarId == avatar.id;
                    
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          _avatarId = avatar.id;
                        });
                        
                        // Firestore'da güncelle
                        await _firestoreService.updateUserAvatar(
                          _currentUser!.uid,
                          avatar.id,
                        );
                        
                        Navigator.pop(context);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Avatar güncellendi: ${avatar.name}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.red, width: 3)
                              : Border.all(color: Colors.grey.shade800, width: 1),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            avatar.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  // Dil seçimi dialog'u
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Dil Seçin', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocaleProvider.supportedLocales.map((lang) {
            final isSelected = Provider.of<LocaleProvider>(context, listen: false)
                .locale.languageCode == lang['code'];
            return ListTile(
              leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
              title: Text(
                lang['name']!,
                style: TextStyle(
                  color: isSelected ? Colors.red : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.red)
                  : null,
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(lang['code']!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dil değiştirildi: ${lang['name']}')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // Tema seçimi dialog'u
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Tema Seçin', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Koyu Tema', ThemeMode.dark, Icons.dark_mode),
            _buildThemeOption('Açık Tema', ThemeMode.light, Icons.light_mode),
            _buildThemeOption('Sistem', ThemeMode.system, Icons.brightness_auto),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String title, ThemeMode mode, IconData icon) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isSelected = themeProvider.themeMode == mode;
        return ListTile(
          leading: Icon(icon, color: isSelected ? Colors.red : Colors.grey),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: isSelected ? const Icon(Icons.check, color: Colors.red) : null,
          onTap: () {
            themeProvider.setThemeMode(mode);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tema değiştirildi: $title')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(
        child: Text('Kullanıcı bulunamadı', style: TextStyle(color: Colors.white)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User Profile Card
        Card(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                GestureDetector(
                  onTap: _showAvatarPicker,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Builder(
                            builder: (context) {
                              final avatar = AvatarModel.getByIdOrDefault(_avatarId);
                              return Image.asset(
                                avatar.imagePath,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1E1E1E),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  _username.isNotEmpty ? _username : 'Kullanıcı',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser!.email ?? 'email@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Statistics
        const Text(
          'İstatistikler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('İzlenen', '0', Icons.check_circle)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Favoriler',
                _favoritesCount.toString(),
                Icons.favorite,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Liste',
                _watchlistCount.toString(),
                Icons.bookmark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WatchlistScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Settings
        const Text(
          'Ayarlar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          Icons.people_outlined,
          'Arkadaşlar',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FriendsScreen(),
              ),
            );
          },
        ),
        _buildSettingItem(
          Icons.person_add_outlined,
          'Arkadaşlık İstekleri',
          badge: _friendRequestsCount > 0 ? _friendRequestsCount.toString() : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FriendRequestsScreen(),
              ),
            );
          },
        ),
        _buildSettingItem(
          Icons.person_search_outlined,
          'Arkadaş Ara',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchUsersScreen(),
              ),
            );
          },
        ),
        _buildSettingItem(
          Icons.notifications_outlined,
          'Bildirimler',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        _buildSettingItem(
          Icons.language_outlined,
          'Dil',
          onTap: _showLanguageDialog,
        ),
        _buildSettingItem(
          Icons.dark_mode_outlined,
          'Tema',
          onTap: _showThemeDialog,
        ),
        _buildSettingItem(Icons.privacy_tip_outlined, 'Gizlilik'),
        _buildSettingItem(Icons.help_outline, 'Yardım'),
        const SizedBox(height: 24),
        
        // Logout Button
        ElevatedButton(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Çıkış Yap',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {VoidCallback? onTap, String? badge}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[400]),
        title: Flexible(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
        onTap: onTap ?? () {
          // Placeholder for other settings
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title - Yakında eklenecek')),
          );
        },
      ),
    );
  }
}
