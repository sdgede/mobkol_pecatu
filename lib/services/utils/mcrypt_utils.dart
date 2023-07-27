import 'package:steel_crypt/steel_crypt.dart';
import '../config/config.dart' as config;

class McryptUtils {
  static McryptUtils instance = McryptUtils();

  final String secretKey = config.secretKey;
  final String iv = config.iv;
  final String secretKeyMerchant = config.secretKeyMerchant;
  final String ivMerchant = config.ivMerchant;

  String encrypt(String value) {
    if (value == "") return "";
    var aesEncrypter = AesCrypt(this.secretKey, 'cbc', 'pkcs7');
    String encrypted;
    try {
      encrypted = aesEncrypter.encrypt(value, this.iv);
    } on Exception {
      print("Error encrypt");
    } catch (e) {
      print("Error encrypt");
    }
    return encrypted;
  }

  String decrypt(String encrypted) {
    if (encrypted == "") return "";
    var aesEncrypter = AesCrypt(this.secretKey, 'cbc', 'pkcs7');
    String decrypted;
    try {
      decrypted = aesEncrypter.decrypt(encrypted, this.iv);
    } on Exception {
      print("Error decrypt");
    } catch (e) {
      print("Error encrypt");
    }
    return decrypted;
  }

  String encryptMerchant(String value) {
    if (value == "") return "";
    var aesEncrypter = AesCrypt(this.secretKeyMerchant, 'cbc', 'pkcs7');
    String encrypted;
    try {
      encrypted = aesEncrypter.encrypt(value, this.ivMerchant);
    } on Exception {
      print("Error encrypt");
    } catch (e) {
      print("Error encrypt");
    }
    return encrypted;
  }

  String decryptMerchant(String encrypted) {
    if (encrypted == "") return "";
    var aesEncrypter = AesCrypt(this.secretKeyMerchant, 'cbc', 'pkcs7');
    String decrypted;
    try {
      decrypted = aesEncrypter.decrypt(encrypted, this.ivMerchant);
    } on Exception {
      print("Error decrypt");
    } catch (e) {
      print("Error encrypt");
    }
    return decrypted;
  }
}
