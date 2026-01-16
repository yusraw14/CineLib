import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/media_model.dart';
import '../services/tmdb_service.dart';
import 'media_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _tmdbService = TMDBService();
  List<Movie> _trendingMovies = [];
  List<Movie> _upcomingMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final trending = await _tmdbService.getTrendingMovies();
      final upcoming = await _tmdbService.getUpcomingMovies();
      
      if (mounted) {
        setState(() {
          _trendingMovies = trending;
          _upcomingMovies = upcoming;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Filmler yüklenemedi: $e')),
        );
      }
    }
  }

  MediaModel _movieToMedia(Movie movie) {
    return MediaModel(
      id: movie.id.toString(),
      title: movie.title,
      type: 'movie',
      imageUrl: movie.posterPath != null
          ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
          : 'https://via.placeholder.com/500x750?text=No+Image',
      description: movie.overview,
      rating: movie.voteAverage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Bildirimler', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMovies,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Gündemdeki Filmler
                  const Text(
                    '🔥 Gündemdeki Filmler',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_trendingMovies.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Gündemdeki film bulunamadı',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._trendingMovies.take(10).map((movie) => _buildMovieCard(movie)),

                  const SizedBox(height: 24),

                  // Yakında Çıkacak Filmler
                  const Text(
                    '🎬 Yakında Çıkacak Filmler',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_upcomingMovies.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Yaklaşan film bulunamadı',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._upcomingMovies.take(10).map((movie) => _buildMovieCard(movie)),
                ],
              ),
            ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaDetailScreen(media: _movieToMedia(movie)),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie.posterPath != null
                      ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
                      : 'https://via.placeholder.com/100x150?text=No+Image',
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 120,
                    color: Colors.grey[800],
                    child: const Icon(Icons.movie, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Film bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty)
                      Text(
                        '📅 ${movie.releaseDate}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
