import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevanam_mobkol/services/config/config.dart' as config;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sevanam_mobkol/services/utils/mcrypt_utils.dart';

class FirestoreCollectionServices {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> getBaseURL() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String clientPackageName = packageInfo.packageName;

    String baseURL = config.baseURL;
    final docRef = db.collection("mobkol_template").doc(clientPackageName);
    const source = Source.server;

    await docRef.get(const GetOptions(source: source)).then(
      (DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) return false;
        if (data['base_url'] == null || data['base_url'] == '') return false;

        baseURL = McryptUtils.instance.decrypt(data['base_url']);
        return true;
      },
      onError: (e) => print("Firestore: Error completing $e"),
    );

    return baseURL;
  }
}
