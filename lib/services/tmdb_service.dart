import 'package:dio/dio.dart';
import '../models/movie.dart';
import '../models/genre.dart';

class TMDBService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
  ));

  // TODO: Buraya kendi API anahtarınızı girin.
  final String _apiKey = 'fa5012fe6ba926a411c2e2e5569beb10';

  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'tr-TR', // Türkçe sonuçlar için
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Filmler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  Future<List<Genre>> getGenres() async {
    try {
      final response = await _dio.get(
        '/genre/movie/list',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'tr-TR',
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['genres'];
        return results.map((e) => Genre.fromJson(e)).toList();
      } else {
        throw Exception('Türler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'tr-TR',
          'with_genres': genreId,
          'sort_by': 'popularity.desc',
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Filmler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'tr-TR',
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Arama başarısız');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  // Gündemdeki filmler
  Future<List<Movie>> getTrendingMovies() async {
    try {
      final response = await _dio.get(
        '/trending/movie/day',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'tr-TR',
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Gündem filmleri yüklenemedi');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  // Yakında çıkacak filmler
  Future<List<Movie>> getUpcomingMovies() async {
    try {
      final response = await _dio.get(
        '/movie/upcoming',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'tr-TR',
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Yaklaşan filmler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  // Kitaptan uyarlama filmler
  Future<List<Movie>> getBookAdaptations() async {
    try {
      // Kült kitap uyarlamalarının TMDB ID'leri
      final List<int> cultClassicIds = [
        120,    // The Lord of the Rings: The Fellowship of the Ring
        121,    // The Lord of the Rings: The Two Towers
        122,    // The Lord of the Rings: The Return of the King
        438631, // Dune (2021)
        671,    // Harry Potter and the Philosopher's Stone
        672,    // Harry Potter and the Chamber of Secrets
        673,    // Harry Potter and the Prisoner of Azkaban
        550,    // Fight Club
        278,    // The Shawshank Redemption
        497,    // The Green Mile
        13,     // Forrest Gump
        329,    // Jurassic Park
      ];

      // Önce kült filmleri ID'ye göre getir
      final List<Movie> cultMovies = [];
      for (int movieId in cultClassicIds) {
        try {
          final response = await _dio.get(
            '/movie/$movieId',
            queryParameters: {
              'api_key': _apiKey,
              'language': 'tr-TR',
            },
          );
          
          if (response.statusCode == 200) {
            cultMovies.add(Movie.fromJson(response.data));
          }
        } catch (e) {
          // Bir film getirilemezse devam et
          print('Film ID $movieId getirilemedi: $e');
        }
      }

      // Sonra diğer popüler kitap uyarlamalarını ekle
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'tr-TR',
          'with_keywords': '818', // based-on-novel keyword
          'sort_by': 'popularity.desc',
          'vote_count.gte': 100,
          'page': 1,
        },
      );

      List<Movie> allMovies = List.from(cultMovies);

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        final otherMovies = results.map((e) => Movie.fromJson(e)).toList();
        
        // Kült filmlerle çakışmayanları ekle
        for (var movie in otherMovies) {
          if (!cultClassicIds.contains(movie.id)) {
            allMovies.add(movie);
          }
        }
      }

      return allMovies;
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  // Benzer filmler
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/similar',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'tr-TR',
          'page': 1,
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Benzer filmler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  // Film fragmanlarını getir
  Future<List<Map<String, String>>> getMovieTrailers(int movieId) async {
    try {
      // Önce Türkçe dene
      var response = await _dio.get(
        '/movie/$movieId/videos',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'tr-TR',
        },
      );

      if (response.statusCode == 200) {
        var results = response.data['results'] as List;
        
        // Sadece YouTube videolarını filtrele
        var trailers = results
            .where((video) => 
                video['site'] == 'YouTube' && 
                (video['type'] == 'Trailer' || video['type'] == 'Teaser'))
            .map((video) => {
                  'key': video['key'] as String,
                  'name': video['name'] as String,
                  'type': video['type'] as String,
                })
            .toList();
        
        // Eğer Türkçe fragman yoksa İngilizce dene
        if (trailers.isEmpty) {
          response = await _dio.get(
            '/movie/$movieId/videos',
            queryParameters: {
              'api_key': _apiKey,
              'language': 'en-US',
            },
          );
          
          if (response.statusCode == 200) {
            results = response.data['results'] as List;
            trailers = results
                .where((video) => 
                    video['site'] == 'YouTube' && 
                    (video['type'] == 'Trailer' || video['type'] == 'Teaser'))
                .map((video) => {
                      'key': video['key'] as String,
                      'name': video['name'] as String,
                      'type': video['type'] as String,
                    })
                .toList();
          }
        }
        
        return trailers;
      } else {
        throw Exception('Fragmanlar yüklenemedi');
      }
    } catch (e) {
      return []; // Hata durumunda boş liste döndür
    }
  }
}
