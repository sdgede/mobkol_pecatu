import 'package:get_it/get_it.dart';

import 'services/utils/location_utils.dart';
import 'services/collection/global_collection.dart';
import 'services/collection/produk_collection.dart';
import 'services/collection/transaksi_collection.dart';

GetIt setup = GetIt.instance;
void setupApp() async {
  //* Register as singleton
  await setup.registerSingleton(LocationUtils());
  await setup.registerSingleton(GlobalCollectionServices());
  await setup.registerSingleton(ProdukCollectionServices());
  await setup.registerSingleton(TransaksiCollectionServices());
}
