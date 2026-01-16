import 'package:flutter/material.dart';
import '../screens/media_detail_screen.dart';
import '../models/media_model.dart';

class MovieCard extends StatelessWidget {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;

  const MovieCard({
    super.key,
    required this.id,
    required this.title,
    this.posterPath,
    required this.voteAverage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // MediaModel'e dönüştür
        final media = MediaModel(
          id: id.toString(),
          title: title,
          type: 'movie',
          imageUrl: posterPath != null 
              ? 'https://image.tmdb.org/t/p/w500$posterPath'
              : 'https://via.placeholder.com/500x750?text=No+Image',
          description: '', // Favori verilerinde overview yok
          rating: voteAverage,
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaDetailScreen(media: media),
          ),
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: posterPath != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500$posterPath',
                      height: 180,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: 140,
                          color: Colors.grey[800],
                          child: Icon(Icons.movie, color: Colors.grey[600], size: 40),
                        );
                      },
                    )
                  : Container(
                      height: 180,
                      width: 140,
                      color: Colors.grey[800],
                      child: Icon(Icons.movie, color: Colors.grey[600], size: 40),
                    ),
            ),
            const SizedBox(height: 8),
            // Title - wrapped in Flexible to prevent overflow
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Rating - constrained to prevent overflow
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    voteAverage.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
