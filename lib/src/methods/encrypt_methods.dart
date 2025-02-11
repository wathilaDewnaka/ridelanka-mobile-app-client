import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

class EncryptMethods {
  static const String _key = "thisisridelanka!"; // 16-byte key for AES-128

  static String encryptText(String plainText) {
    final key = encrypt.Key.fromUtf8(_key);
    final iv = encrypt.IV.fromLength(16); // IV should be 16 bytes for AES-CBC

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return "${base64Encode(iv.bytes)}:${encrypted.base64}";
  }

  static String decryptText(String encryptedText) {
    final key = encrypt.Key.fromUtf8(_key);

    final parts = encryptedText.split(":");
    if (parts.length != 2) {
      return "Invalid encrypted data";
    }

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    return encrypter.decrypt(encryptedData, iv: iv);
  }
}
