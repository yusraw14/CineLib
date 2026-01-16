import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class AddReviewScreen extends StatefulWidget {
  final MediaModel media; // Hangi filme yorum yapıyoruz?

  const AddReviewScreen({super.key, required this.media});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _commentController = TextEditingController(); // Yazılan yorumu tutar
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  double _rating = 3.0; // Varsayılan puan
  bool _isSpoiler = false; // Spoiler kutusu
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir yorum yazın!")),
      );
      return;
    }

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yorum yapmak için giriş yapmalısınız!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user profile for username
      final profile = await _firestoreService.getUserProfile(currentUser.uid);
      final username = profile?['username'] ?? currentUser.email?.split('@')[0] ?? 'Kullanıcı';

      // Save comment to Firestore
      await _firestoreService.addComment(
        movieId: widget.media.id,
        userId: currentUser.uid,
        username: username,
        comment: _commentController.text,
        rating: _rating,
        isSpoiler: _isSpoiler,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      
      // Başarılı mesajı göster ve önceki sayfaya dön
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Yorumunuz kaydedildi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hata: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.media.title} - Yorumla"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Bilgilendirme
            Center(
              child: Image.network(
                widget.media.imageUrl,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            
            // 2. Puanlama Slider'ı
            const Text("Puanınız:", style: TextStyle(color: Colors.white, fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1,
                    max: 5,
                    divisions: 4, // 1, 2, 3, 4, 5 şeklinde atlar
                    label: _rating.toString(),
                    activeColor: Colors.amber,
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                ),
                Text(
                  _rating.toString(),
                  style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.star, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Yorum Alanı
            TextField(
              controller: _commentController,
              maxLines: 5, // 5 satırlık kutu
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Düşüncelerinizi buraya yazın...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Spoiler Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isSpoiler,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      _isSpoiler = value ?? false;
                    });
                  },
                ),
                const Text("Bu yorum SPOILER içerir!", style: TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 30),

            // 5. Kaydet Butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914), // Netflix Kırmızısı
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Yorumu Gönder", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}