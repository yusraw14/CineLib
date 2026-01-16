import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../models/movie.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/spoiler_view.dart';
import 'add_review_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaDetailScreen extends StatefulWidget {
  final MediaModel media;

  const MediaDetailScreen({super.key, required this.media});

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _tmdbService = TMDBService();
  bool _isFavorite = false;
  bool _isInWatchlist = false;
  bool _isLoading = true;
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final user = _authService.currentUser;
    print('🔍 Status kontrol ediliyor...');
    print('👤 Kullanıcı: ${user?.uid ?? "Giriş yapılmamış"}');
    print('🎬 Film ID: ${widget.media.id}');
    
    if (user != null) {
      final isFav = await _firestoreService.isInFavorites(
        userId: user.uid,
        movieId: int.parse(widget.media.id),
      );
      final isInWatch = await _firestoreService.isInWatchlist(
        userId: user.uid,
        movieId: int.parse(widget.media.id),
      );
      print('❤️ Favori durumu: $isFav');
      print('🔖 Watchlist durumu: $isInWatch');
      setState(() {
        _isFavorite = isFav;
        _isInWatchlist = isInWatch;
        _isLoading = false;
      });
    } else {
      print('⚠️ Kullanıcı giriş yapmamış');
      setState(() {
        _isLoading = false;
      });
    }
    print('✅ Loading tamamlandı, _isLoading: $_isLoading');
  }

  Future<void> _toggleFavorite() async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorilere eklemek için giriş yapmalısınız')),
      );
      return;
    }

    try {
      if (_isFavorite) {
        await _firestoreService.removeFromFavorites(
          userId: user.uid,
          movieId: int.parse(widget.media.id),
        );
        setState(() => _isFavorite = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favorilerden çıkarıldı')),
          );
        }
      } else {
        await _firestoreService.addToFavorites(
          userId: user.uid,
          movie: _mediaToMovie(widget.media),
        );
        setState(() => _isFavorite = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favorilere eklendi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Movie _mediaToMovie(MediaModel media) {
    return Movie(
      id: int.parse(media.id),
      title: media.title,
      overview: media.description,
      posterPath: media.imageUrl,
      voteAverage: media.rating,
      releaseDate: null,
    );
  }

  Future<void> _toggleWatchlist() async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İzleneceklere eklemek için giriş yapmalısınız')),
      );
      return;
    }

    try {
      if (_isInWatchlist) {
        await _firestoreService.removeFromWatchlist(
          userId: user.uid,
          movieId: int.parse(widget.media.id),
        );
        setState(() => _isInWatchlist = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İzleneceklerden çıkarıldı')),
          );
        }
      } else {
        await _firestoreService.addToWatchlist(
          userId: user.uid,
          movie: _mediaToMovie(widget.media),
        );
        setState(() => _isInWatchlist = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İzleneceklere eklendi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      
      // SAĞ ALTTAKİ YORUM YAP BUTONU
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReviewScreen(media: widget.media),
            ),
          );
        },
        label: const Text("Yorum Yap", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.edit, color: Colors.white),
        backgroundColor: const Color(0xFFE50914), // Kırmızı
      ),

      body: CustomScrollView(
        slivers: [
          // 1. Üstteki Büyük Resim
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: Icon(
                  _isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                  color: _isInWatchlist ? Colors.amber : Colors.white,
                ),
                onPressed: _toggleWatchlist,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.media.title, 
                style: const TextStyle(fontSize: 14, shadows: [Shadow(blurRadius: 10, color: Colors.black)])
              ),
              background: Image.network(
                widget.media.imageUrl, 
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[900], child: const Icon(Icons.error)),
              ),
            ),
          ),

          // 2. İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Özet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(widget.media.description, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        widget.media.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- FRAGMANLAR ---
                  _buildTrailersSection(),
                  const SizedBox(height: 30),

                  // --- YORUMLAR VE TARTIŞMALAR (TAB BAR) ---
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          indicatorColor: const Color(0xFFE50914),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(text: "💬 Yorumlar"),
                            Tab(text: "🗨️ Tartışmalar"),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Yorumlar Tab
                              _buildCommentsTab(),
                              // Tartışmalar Tab
                              _buildDiscussionsTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Benzer Filmler Bölümü
                  _buildSimilarMoviesSection(),

                  const SizedBox(height: 80), // Buton için altta boşluk
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '🎬 Bunları da beğenebilirsin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Movie>>(
          future: _tmdbService.getSimilarMovies(int.parse(widget.media.id)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return const SizedBox.shrink(); // Hata durumunda bölümü gizle
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Benzer film bulunamadı',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            final similarMovies = snapshot.data!;

            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: similarMovies.length,
                itemBuilder: (context, index) {
                  return _buildSimilarMovieCard(similarMovies[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSimilarMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        // MediaModel'e dönüştür
        final media = MediaModel(
          id: movie.id.toString(),
          title: movie.title,
          type: 'movie',
          imageUrl: movie.posterPath != null
              ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
              : 'https://via.placeholder.com/500x750?text=No+Image',
          description: movie.overview,
          rating: movie.voteAverage,
        );

        // Yeni film detayına git (mevcut sayfayı değiştir)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MediaDetailScreen(media: media),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  movie.posterPath != null
                      ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                      : 'https://via.placeholder.com/500x750?text=No+Image',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.movie, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Film adı
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            // Puan
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 3),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fragmanlar bölümü
  Widget _buildTrailersSection() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _tmdbService.getMovieTrailers(int.parse(widget.media.id)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Fragman yoksa bölümü gizle
        }

        final trailers = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🎬 Fragmanlar",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trailers.length,
                itemBuilder: (context, index) {
                  return _buildTrailerCard(trailers[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrailerCard(Map<String, String> trailer) {
    final youtubeKey = trailer['key'] ?? '';
    final thumbnailUrl = 'https://img.youtube.com/vi/$youtubeKey/hqdefault.jpg';

    return GestureDetector(
      onTap: () => _openYoutubeVideo(youtubeKey),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.play_circle_outline, size: 60, color: Colors.white),
                      ),
                    ),
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Trailer adı
            Text(
              trailer['name'] ?? 'Fragman',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openYoutubeVideo(String videoKey) async {
    final youtubeUrl = Uri.parse('https://www.youtube.com/watch?v=$videoKey');
    
    try {
      if (await canLaunchUrl(youtubeUrl)) {
        await launchUrl(
          youtubeUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video açılamadı')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  // Yorumlar Tab İçeriği
  Widget _buildCommentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getComments(widget.media.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text(
              'Yorumlar yüklenemedi: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            );
          }

          final comments = snapshot.data ?? [];

          if (comments.isEmpty) {
            return const Center(
              child: Text(
                "Henüz yorum yok. İlk yorumu sen yap!",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final commentData = comments[index];
              final username = commentData['username'] ?? 'Anonim';
              final comment = commentData['comment'] ?? '';
              final rating = (commentData['rating'] as num?)?.toDouble() ?? 0.0;
              final isSpoiler = commentData['isSpoiler'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            username,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SpoilerView(text: comment, isSpoiler: isSpoiler),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Tartışmalar Tab İçeriği
  Widget _buildDiscussionsTab() {
    final user = _authService.currentUser;

    return Column(
      children: [
        // Mesajlar Listesi
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.getDiscussions(widget.media.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Mesajlar yüklenemedi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final messages = snapshot.data ?? [];

              if (messages.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Henüz mesaj yok. Sohbeti sen başlat! 💬",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final messageData = messages[index];
                  final username = messageData['username'] ?? 'Anonim';
                  final message = messageData['message'] ?? '';
                  final isCurrentUser = user != null && messageData['userId'] == user.uid;

                  return Align(
                    alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isCurrentUser 
                            ? const Color(0xFFE50914) 
                            : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isCurrentUser)
                            Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                                fontSize: 12,
                              ),
                            ),
                          if (!isCurrentUser) const SizedBox(height: 4),
                          Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Mesaj Gönderme Alanı
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF2A2A2A),
            border: Border(
              top: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Mesajınızı yazın...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Color(0xFFE50914)),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesaj göndermek için giriş yapmalısınız')),
      );
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      final userProfile = await _firestoreService.getUserProfile(user.uid);
      final username = userProfile?['username'] ?? 'Kullanıcı';

      await _firestoreService.sendMessage(
        movieId: widget.media.id,
        userId: user.uid,
        username: username,
        message: message,
      );

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesaj gönderilemedi: $e')),
        );
      }
    }
  }
}