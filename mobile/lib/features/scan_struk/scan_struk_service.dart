import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../ui/widgets/app_toast.dart';

// ---------------------------------------------------------------------------
// Result model
// ---------------------------------------------------------------------------

class ScanResult {
  const ScanResult({this.amount, this.note, this.date});

  /// Parsed amount in IDR (whole rupiah, no decimal).
  final int? amount;

  /// Merchant name — first meaningful line of the receipt.
  final String? note;

  /// Parsed date from the receipt.
  final DateTime? date;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class ScanStrukService {
  final _picker = ImagePicker();

  /// Pick an image from camera (falls back to gallery on denial) then run OCR.
  /// Returns [ScanResult] when parsing yields at least one field, or null if
  /// the user cancelled or OCR found nothing usable.
  Future<ScanResult?> scan(BuildContext context) async {
    XFile? image;

    // 1. Try camera first.
    try {
      image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
    } catch (_) {
      // Camera permission denied or unavailable → fall back to gallery.
      if (context.mounted) {
        AppToast.show(
          context,
          'Kamera tidak tersedia, pilih dari galeri',
          success: false,
        );
      }
      try {
        image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );
      } catch (_) {
        if (context.mounted) {
          AppToast.show(
            context,
            'Akses galeri ditolak',
            success: false,
          );
        }
        return null;
      }
    }

    if (image == null) return null; // user cancelled

    // 2. Run ML Kit text recognition.
    final inputImage = InputImage.fromFilePath(image.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final String fullText;
    try {
      final result = await recognizer.processImage(inputImage);
      fullText = result.text;
    } finally {
      await recognizer.close();
    }

    if (fullText.trim().isEmpty) {
      if (context.mounted) {
        AppToast.show(
          context,
          'Tidak ada teks terbaca di struk',
          success: false,
        );
      }
      return null;
    }

    // 3. Parse fields.
    final amount = _parseAmount(fullText);
    final date = _parseDate(fullText);
    final note = _parseMerchant(fullText);

    if (amount == null && date == null && note == null) {
      if (context.mounted) {
        AppToast.show(
          context,
          'Tidak dapat membaca data struk',
          success: false,
        );
      }
      return null;
    }

    return ScanResult(amount: amount, date: date, note: note);
  }

  // -------------------------------------------------------------------------
  // Amount parser
  // -------------------------------------------------------------------------

  /// Strategy (tried in order):
  /// 1. Look for a line with "GRAND TOTAL" — take the number on that line.
  /// 2. Look for a line with "TOTAL" (but NOT "SUB" before it) — same.
  /// 3. Look for a line with "Rp" followed by a number.
  /// 4. Fallback: pick the largest plain integer found in the whole text
  ///    that is >= 1000 (to skip quantities/counts).
  int? _parseAmount(String text) {
    final lines = text.split('\n');

    // Helpers
    int? extractNumber(String line) {
      // Remove common currency symbols and separators, then parse.
      final cleaned = line
          .replaceAll(RegExp(r'[Rr][Pp]\.?\s*'), '')
          .replaceAll(RegExp(r'[.,]'), '')
          .replaceAll(RegExp(r'\s'), '');
      final match = RegExp(r'\d{4,}').firstMatch(cleaned);
      if (match == null) return null;
      return int.tryParse(match.group(0)!);
    }

    // 1. GRAND TOTAL
    for (final line in lines) {
      if (RegExp(r'GRAND\s*TOTAL', caseSensitive: false).hasMatch(line)) {
        final v = extractNumber(line);
        if (v != null) return v;
      }
    }

    // 2. TOTAL (not subtotal)
    for (final line in lines) {
      if (RegExp(r'\bTOTAL\b', caseSensitive: false).hasMatch(line) &&
          !RegExp(r'SUB', caseSensitive: false).hasMatch(line)) {
        final v = extractNumber(line);
        if (v != null) return v;
      }
    }

    // 3. Rp prefix
    for (final line in lines) {
      if (RegExp(r'Rp', caseSensitive: false).hasMatch(line)) {
        final v = extractNumber(line);
        if (v != null) return v;
      }
    }

    // 4. Largest number >= 1000 in the entire text.
    int? largest;
    final allNumbers = RegExp(r'\b\d[\d.,]{3,}\b').allMatches(text);
    for (final m in allNumbers) {
      final raw = m.group(0)!.replaceAll(RegExp(r'[.,]'), '');
      final n = int.tryParse(raw);
      if (n != null && n >= 1000) {
        if (largest == null || n > largest) largest = n;
      }
    }
    return largest;
  }

  // -------------------------------------------------------------------------
  // Date parser
  // -------------------------------------------------------------------------

  /// Tries Indonesian receipt date formats: dd/MM/yyyy, dd-MM-yyyy,
  /// dd/MM/yy, dd-MM-yy, yyyy-MM-dd, dd MMM yyyy (e.g. "27 Jun 2026").
  DateTime? _parseDate(String text) {
    // dd/MM/yyyy or dd-MM-yyyy or dd/MM/yy or dd-MM-yy
    final dmy = RegExp(r'\b(\d{1,2})[/\-](\d{1,2})[/\-](\d{2,4})\b');
    for (final m in dmy.allMatches(text)) {
      final d = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      var y = int.tryParse(m.group(3)!);
      if (d == null || mo == null || y == null) continue;
      if (y < 100) y += 2000;
      if (mo < 1 || mo > 12 || d < 1 || d > 31) continue;
      return DateTime(y, mo, d);
    }

    // yyyy-MM-dd (ISO-ish)
    final iso = RegExp(r'\b(20\d{2})[/\-](\d{1,2})[/\-](\d{1,2})\b');
    for (final m in iso.allMatches(text)) {
      final y = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      final d = int.tryParse(m.group(3)!);
      if (y == null || mo == null || d == null) continue;
      if (mo < 1 || mo > 12 || d < 1 || d > 31) continue;
      return DateTime(y, mo, d);
    }

    // dd MMM yyyy  (e.g. "27 Jun 2026")
    const monthMap = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
      'mei': 5, 'may': 5, 'jun': 6,
      'jul': 7, 'agu': 8, 'aug': 8, 'sep': 9,
      'okt': 10, 'oct': 10, 'nov': 11, 'des': 12, 'dec': 12,
    };
    final named = RegExp(
        r'\b(\d{1,2})\s+([A-Za-z]{3})\s+(20\d{2})\b',
        caseSensitive: false);
    for (final m in named.allMatches(text)) {
      final d = int.tryParse(m.group(1)!);
      final mo = monthMap[m.group(2)!.toLowerCase()];
      final y = int.tryParse(m.group(3)!);
      if (d == null || mo == null || y == null) continue;
      return DateTime(y, mo, d);
    }

    return null;
  }

  // -------------------------------------------------------------------------
  // Merchant parser
  // -------------------------------------------------------------------------

  /// First non-empty, non-numeric-only line of the receipt, capped at 50 chars.
  String? _parseMerchant(String text) {
    final lines = text.split('\n');
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      // Skip lines that are purely digits/symbols (e.g. a barcode row).
      if (RegExp(r'^[\d\s\-\*\#\.\/\\]+$').hasMatch(line)) continue;
      return line.length > 50 ? line.substring(0, 50) : line;
    }
    return null;
  }
}
