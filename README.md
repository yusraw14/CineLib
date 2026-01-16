# 🎬 CineLib - Film ve Dizi Keşif Uygulaması

CineLib, film ve dizi severler için geliştirilmiş kapsamlı bir mobil uygulamadır. TMDB API entegrasyonu ile güncel film ve dizi bilgilerine erişim sağlar, Firebase ile kullanıcı yönetimi ve sosyal özellikler sunar.

## ✨ Özellikler

### 🎯 Temel Özellikler
- **Film ve Dizi Keşfi**: TMDB API üzerinden güncel içerik bilgileri
- **Kategoriye Göre Listeleme**: Netflix tarzı yatay kaydırmalı kategoriler
- **Detaylı Medya Bilgileri**: Film/dizi bilgileri, fragmanlar ve yorumlar
- **Kitaptan Uyarlamalar**: Lord of the Rings, Dune, Harry Potter gibi kült eserlere özel bölüm
- **Arama**: Film, dizi ve kullanıcı arama özellikleri

### 👤 Kullanıcı Yönetimi
- **Firebase Authentication**: Güvenli kullanıcı kaydı ve girişi
- **Profil Yönetimi**: Avatar seçimi ve profil özelleştirme
- **Dil ve Tema**: Türkçe/İngilizce dil seçimi, açık/koyu tema desteği

### 🤝 Sosyal Özellikler
- **Arkadaşlık Sistemi**: Kullanıcı arama, arkadaş ekleme ve istekleri yönetme
- **Yorumlar ve İncelemeler**: Film ve diziler için yorum yapma ve spoiler uyarısı
- **Favoriler ve İzleme Listesi**: Kişisel medya koleksiyonu oluşturma
- **Bildirimler**: Trend filmler ve güncellemeler için bildirim sistemi

## 🛠️ Teknolojiler

### Frontend
- **Flutter**: ^3.9.2
- **Dart**: Modern ve hızlı UI geliştirme

### Backend & Servisler
- **Firebase Core**: ^3.8.1
- **Firebase Auth**: ^5.3.3 - Kullanıcı kimlik doğrulama
- **Cloud Firestore**: ^5.5.2 - NoSQL veritabanı

### State Management & Storage
- **Provider**: ^6.1.1 - State management
- **Shared Preferences**: ^2.2.2 - Lokal veri saklama

### API & Network
- **Dio**: ^5.9.0 - HTTP client
- **TMDB API**: Film ve dizi verileri

### UI & Media
- **Cached Network Image**: ^3.4.1 - Görsel önbellekleme
- **YouTube Player Flutter**: ^9.1.1 - Fragman oynatma
- **URL Launcher**: ^6.3.1 - Harici bağlantılar

## 📁 Proje Yapısı

```
lib/
├── models/                 # Veri modelleri
│   ├── avatar_model.dart
│   ├── friend_model.dart
│   ├── genre.dart
│   ├── media_model.dart
│   ├── movie.dart
│   └── review_model.dart
├── providers/             # State management
│   ├── locale_provider.dart
│   └── theme_provider.dart
├── screens/              # UI ekranları
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_screen.dart
│   ├── profile_screen.dart
│   ├── media_detail_screen.dart
│   ├── add_review_screen.dart
│   ├── search_screen.dart
│   ├── search_users_screen.dart
│   ├── friends_screen.dart
│   ├── friend_requests_screen.dart
│   ├── friend_profile_screen.dart
│   ├── favorites_screen.dart
│   ├── watchlist_screen.dart
│   └── notifications_screen.dart
├── services/             # İş mantığı
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── tmdb_service.dart
│   └── dummy_data.dart
├── widgets/              # Yeniden kullanılabilir bileşenler
│   ├── movie_card.dart
│   └── spoiler_view.dart
├── firebase_options.dart
└── main.dart            # Uygulama giriş noktası
```

## 🚀 Kurulum

### Ön Gereksinimler
- Flutter SDK (^3.9.2 veya üzeri)
- Dart SDK
- Android Studio / Xcode (platform geliştirme için)
- Firebase hesabı ve proje

### Adım 1: Depoyu Klonlayın
```bash
git clone <repository-url>
cd cinelib
```

### Adım 2: Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### Adım 3: Firebase Yapılandırması
1. Firebase Console'da yeni bir proje oluşturun
2. Android/iOS uygulamanızı Firebase projesine ekleyin
3. `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin
4. İlgili platform klasörlerine yerleştirin
5. Firebase CLI ile Flutter yapılandırması yapın:
```bash
firebase login
flutterfire configure
```

### Adım 4: TMDB API Anahtarı
1. [TMDB](https://www.themoviedb.org/) hesabı oluşturun
2. API anahtarı alın
3. `lib/services/tmdb_service.dart` dosyasında API anahtarınızı güncelleyin

### Adım 5: Avatarlar
Avatar görsellerini `assets/avatars/` klasörüne ekleyin:
- avatar1.png
- avatar2.png
- avatar3.png
- ... (ihtiyacınıza göre)

### Adım 6: Uygulamayı Çalıştırın
```bash
flutter run
```

## 🔐 Firebase Güvenlik

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /friendRequests/{requestId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Firestore İndeksler
Yorumların doğru sıralanması için gerekli indeksler:
- Collection: `reviews`
  - Fields: `mediaId` (Ascending), `timestamp` (Descending)

## 🌍 Çoklu Dil Desteği
Uygulama şu dilleri destekler:
- 🇹🇷 Türkçe
- 🇬🇧 English

Dil ayarları profil ekranından değiştirilebilir.

## 🎨 Tema
- ☀️ Light Mode
- 🌙 Dark Mode

Tema tercihi cihazda saklanır ve uygulama yeniden başlatıldığında korunur.

## 📱 Platform Desteği
- ✅ Android
- ✅ iOS
- ⚠️ Web (Beta)
- ⚠️ Windows (Beta)
- ⚠️ macOS (Beta)
- ⚠️ Linux (Beta)

## 🤝 Katkıda Bulunma
Katkılarınız memnuniyetle karşılanır! Lütfen şu adımları izleyin:
1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

## 📄 Lisans
Bu proje özel bir projedir ve henüz açık kaynak lisansı belirlenmemiştir.

## 📞 İletişim
Sorularınız veya geri bildirimleriniz için lütfen iletişime geçin.

## 🙏 Teşekkürler
- [TMDB](https://www.themoviedb.org/) - Film ve dizi verileri için
- [Firebase](https://firebase.google.com/) - Backend servisleri için
- [Flutter](https://flutter.dev/) - Harika framework için

---

**Not**: Bu uygulama TMDB API kullanır ancak TMDB tarafından onaylanmamış veya sertifikalandırılmamıştır.
