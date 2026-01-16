import '../models/media_model.dart';
import '../models/review_model.dart';

class DummyData {
  // --- KİTAPLAR ---
  static final List<MediaModel> books = [
    MediaModel(
      id: 'book_1',
      title: 'Harry Potter ve Felsefe Taşı',
      type: 'book',
      // Amazon görseli (Kesin çalışır)
      imageUrl: 'https://m.media-amazon.com/images/I/51HSkTKlauL._AC_SY445_SX342_.jpg', 
      description: 'J.K. Rowling tarafından yazılan, genç büyücü Harry Potter\'ın hikayesi.',
      rating: 4.8,
    ),
    MediaModel(
      id: 'book_2',
      title: 'Dune',
      type: 'book',
      // Amazon görseli
      imageUrl: 'https://m.media-amazon.com/images/I/81ym3QUd3KL._AC_UF1000,1000_QL80_.jpg',
      description: 'Frank Herbert\'in bilimkurgu şaheseri. Çöl gezegeni Arrakis.',
      rating: 4.9,
    ),
  ];

  // --- FİLMLER ---
  static final List<MediaModel> movies = [
    MediaModel(
      id: 'movie_1',
      title: 'Harry Potter (Film)',
      type: 'movie',
      // Efsane film afişi (Harry, Ron, Hermione üçlüsü)
      imageUrl: 'https://m.media-amazon.com/images/M/MV5BNjQ3NWNlNmQtMTE5ZS00MDdmLTlkZjUtZTBlM2UxMGFiMTU3XkEyXkFqcGdeQXVyNjUwNzk3NDc@._V1_FMjpg_UX1000_.jpg',
      description: 'Hogwarts Cadılık ve Büyücülük Okulu\'na kabul edilen yetim bir çocuğun hikayesi.',
      rating: 4.5,
      adaptationId: 'book_1', 
    ),
    MediaModel(
      id: 'movie_2',
      title: 'Dune: Çöl Gezegeni',
      type: 'movie',
      // Çok daha sağlam ve hızlı bir link (TMDB)
      imageUrl: 'https://image.tmdb.org/t/p/original/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
      description: 'Paul Atreides, evrenin en tehlikeli gezegenine gitmek zorundadır.',
      rating: 4.6,
      adaptationId: 'book_2', 
    ),
  ];
  // --- YORUMLAR ---
  static final List<ReviewModel> reviews = [
    ReviewModel(
      id: 'r1',
      userName: 'Ahmet Yılmaz',
      mediaId: 'movie_1',
      comment: 'Kitaba sadık kalmışlar ama bazı sahneler eksik.',
      rating: 4.0,
      isSpoiler: false,
      loyaltyScore: 85,
    ),
    ReviewModel(
      id: 'r2',
      userName: 'Spoiler Canavarı',
      mediaId: 'movie_1',
      comment: 'Filmin sonunda Profesör Quirrell\'ın kafasının arkasında Voldemort var!',
      rating: 5.0,
      isSpoiler: true, 
      loyaltyScore: 90,
    ),
  ];
  
  static List<MediaModel> get allMedia => [...books, ...movies];
}