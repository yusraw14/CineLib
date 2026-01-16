import 'dart:ui';
import 'package:flutter/material.dart';

class SpoilerView extends StatefulWidget {
  final String text;
  final bool isSpoiler;

  const SpoilerView({
    super.key,
    required this.text,
    this.isSpoiler = false,
  });

  @override
  State<SpoilerView> createState() => _SpoilerViewState();
}

class _SpoilerViewState extends State<SpoilerView> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    // Eğer spoiler yoksa veya kullanıcı açtıysa normal text
    if (!widget.isSpoiler || _isRevealed) {
      return Text(
        widget.text,
        style: const TextStyle(color: Colors.white70),
      );
    }

    // Spoiler varsa - sadece uyarı göster (metni gizle)
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRevealed = true;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Text(
              "SPOILER - Görmek için dokun",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}