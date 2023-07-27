import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import '../database/table_config.dart';
import '../services/config/config.dart';
import '../services/utils/mcrypt_utils.dart';

class DatabaseHelper {
  static final _databaseName = "sqlite_koperasi.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase(); // only initialize if not created already
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    if (!(await databaseExists(path))) {
      ByteData data =
          await rootBundle.load(join("assets/database", _databaseName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new io.File(path).writeAsBytes(bytes);
    }
    return await openDatabase(path, version: _databaseVersion);
  }

  //QUERY

  String _decrypt(String val) {
    return McryptUtils.instance.decrypt(val);
  }

  String _encrypt(String val) {
    return McryptUtils.instance.encrypt(val);
  }

  Future getLasIdTbTarns() async {
    Database db = await instance.database;
    Map<String, dynamic> result;

    var row = await db.rawQuery(
        "SELECT trans_id FROM t_trans_simpanan order by trans_id desc LIMIT 1");
    if (row.length == 0) {
      result = {"trans_id": 0, "pesan": "No data transaction"};
    } else {
      result = row.first;
    }
    print("last trx data : " + result.toString());
    return result;
  }

  Future<int> queryRowCount(String tbName) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tbName'),
    );
  }

  Future<int> queryRowCountWithClause(
    String tbName,
    String whereClause,
    String whereParam,
  ) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery(
          'SELECT COUNT(*) FROM $tbName WHERE $whereClause = $whereParam'),
    );
  }

  Future<bool> deleteDataGlobal(String table) async {
    Database db = await instance.database;
    bool isSukses = false;
    try {
      await db.delete(table);
      isSukses = true;
    } catch (e) {
      print(e);
    }

    return isSukses;
  }

  Future<bool> deleteDataGlobalWithCLause(
      String table, String columnId, int id) async {
    Database db = await instance.database;
    Map<String, dynamic> result;
    bool isSukses = false;
    //return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
    try {
      await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
      isSukses = true;
    } catch (e) {
      print(e);
    }

    return isSukses;
  }

  Future<bool> updateDataGlobal(
    String table,
    Map<String, dynamic> dataUpdate,
    String whereColumn,
    int wahereParam,
  ) async {
    Database db = await instance.database;

    bool isSukses = false;
    try {
      await db.update(
        table,
        dataUpdate,
        where: '$whereColumn = ?',
        whereArgs: [wahereParam],
      );
      isSukses = true;
    } catch (e) {
      print(e);
    }

    return isSukses;
  }

  Future<bool> insertDataGlobal(
    String table,
    Map<String, dynamic> insertVal,
  ) async {
    Database db = await instance.database;
    bool isSukses = false;
    try {
      await db.insert(table, insertVal);
      isSukses = true;
    } catch (e) {
      print(e);
    }

    return isSukses;
  }

  Future getLoginOffline(Map<String, dynamic> dataParse) async {
    Database db = await instance.database;
    Map<String, dynamic> result, resultFinal;

    var row = await db.rawQuery(
        "SELECT 'Y' as status,username,password,IFNULL(imei,'0') as imei,IFNULL(sn_number,'0') as sn_number,username as nama,kolektor_id as id_user,apk_version FROM s_user_kolektor WHERE username ='" +
            _decrypt(dataParse['username']) +
            "'");
    if (row.length == 0) {
      result = {"status": "Gagal", "pesan": "Username tidak ditemukan"};
    } else {
      if (row.first['password'] != _decrypt(dataParse['pwd'])) {
        result = {
          "status": "Gagal",
          "pesan": "Username atau password tidak valid"
        };
      } else {
        if (row.first['imei'] != _decrypt(dataParse['imei'])) {
          result = {
            "status": "Gagal",
            "pesan":
                "Upaya masuk gagal, perangkat ini telah terdaftar dengan akun lain. silakan login menggunakan akun yang biasa anda gunakan"
          };
        } else {
          result = {"status": "Sukses", "pesan": "Auth sukses"};
        }
      }
    }

    if (result['status'] == 'Gagal') {
      resultFinal = {'responLogin': result};
    } else {
      bool imeiAlvaible = true;

      resultFinal = {
        "responLogin": row.first,
        'dataSetting': {
          'min_setoran_tabungan': '10000',
          'min_setoran_wajib': '20000',
          'min_saldo_pengendapan': '30000'
        },
        'dataUser': {
          'username': row.first['username'],
          'nama': row.first['nama'],
          'tipe_akun': 'KOLEKTOR',
        },
        'mode': 'KOLEKTOR'
      };
    }

    return resultFinal;
  }

  Future testGetData() async {
    Database db = await instance.database;
    List<Map<String, Object>> result;

    var row = await db
        .rawQuery("SELECT * FROM t_trans_simpanan order by trans_id desc");
    if (row.length == 0) {
      result = [
        {"status": "Gagal", "pesan": "Data tidak ditemukan"}
      ];
    } else {
      result = row;
    }
    print(result.toString());
    return result;
  }

  Future<dynamic> getIconProdukOffline({
    Map<String, dynamic> dataParse,
  }) async {
    Database db = await instance.database;
    List<Map<String, Object>> result;

    var row = await db.rawQuery(
        "SELECT nama_menu as nama,remark as slug,rek_cd,icon,min_setoran,min_tarikan,rek_shortcut,urut_menu FROM s_menu_mobkol WHERE active_flag='Y' ORDER BY urut_menu ASC");
    if (row.length == 0) {
      result = [
        {"status": "Gagal", "pesan": "Data tidak ditemukan"}
      ];
    } else {
      result = row;
    }
    return json.encode(result);
  }

  Future getDataGroupProduk(String produkCd, String rekCd) async {
    Database db = await instance.database;
    Map<String, dynamic> result;

    var row = await db.rawQuery(
        "SELECT * FROM s_menu_mobkol WHERE group_menu='" +
            produkCd +
            "' AND rek_cd='" +
            rekCd +
            "'");
    if (row.length == 0) {
      result = {"status": "Gagal", "pesan": "Data tidak ditemukan"};
    } else {
      result = row.first;
    }
    return result;
  }

  Future<dynamic> getDataProduk({
    Map<String, dynamic> dataParse,
  }) async {
    Database db = await instance.database;
    String groupProduk = _decrypt(dataParse['groupProduk']);
    String rekCd = _decrypt(dataParse['rekCd']);
    String norek = formatNorekProduk(_decrypt(dataParse['norek']));
    String rekDesc = groupProduk == 'ANGGOTA' ? 'anggota' : 'rekening';
    List<Map<String, Object>> result;
    var row;
    var val = await getDataGroupProduk(groupProduk, rekCd);

    if (groupProduk == 'TABUNGAN')
      row = await db.rawQuery(
          "SELECT xx.*, '0' AS remark from (SELECT 'Sukses' as res_status, A." +
              val['id_tb_nas'] +
              " AS tab_id, A.NASABAH_ID AS nas_id, A.NO_REK AS norek, '0' AS saldo, '0' AS val_blokir, '0' AS trx_date, TRIM(TRIM(IFNULL(B.nama_depan,''))||' '||TRIM(IFNULL(B.nama_belakang,''))) as nama, B.ALAMAT AS alamat, IFNULL((SELECT description FROM s_lov_value WHERE CODE='WILAYAH_CD' AND ACTIVE_FLAG='Y' AND code_val = A.`WILAYAH_CD` ),'-') AS wilayah, '' AS alamat_pelayanan, IFNULL(A.GROUP_CD,'0') as group_cd, IFNULL(A.WILAYAH_CD,'0') as wilayah_cd, IFNULL(A.WILAYAH_CD,'0') as wilayah_cd_asli, IFNULL(A.TGL_DAFTAR ,'0') as tgl_daftar, IFNULL(A.SETORAN_AWAL,'0') as setoran_awal, IFNULL(A.STATUS,'0') as sts, IFNULL((SELECT CASE WHEN A.STATUS='A' THEN ('AKTIF') WHEN A.STATUS='D' THEN ('DAFTAR') WHEN A.STATUS='T' THEN ('TUTUP') END ),'-' )AS `status`, IFNULL(A.REMARK,'-')AS remark1 FROM " +
              val['tb_nas'] +
              " A, m_nasabah B WHERE NO_REK='" +
              norek +
              "'AND A.`NASABAH_ID`=B.`NASABAH_ID` LIMIT 1 )xx");

    if (groupProduk == 'ANGGOTA')
      row = await db.rawQuery(
          "SELECT A.NASABAH_ANGGOTA_ID AS tab_id, A.NASABAH_ID AS nas_id, ('ANGGOTA') AS rek_cd, A.NO_ANGGOTA AS norek, '0' AS saldo, '-' AS trx_date, TRIM(TRIM(IFNULL(B.nama_depan,''))||' '||TRIM(IFNULL(B.nama_belakang,''))) AS nama, B.ALAMAT AS alamat, IFNULL((SELECT description FROM s_lov_value WHERE CODE='WILAYAH_CD' AND ACTIVE_FLAG='Y' AND code_val = A.`WILAYAH_CD` limit 1),'-') AS wilayah, IFNULL(A.GROUP_CD,'0') AS group_cd, IFNULL(A.WILAYAH_CD,'0') as wilayah_cd, IFNULL(A.WILAYAH_CD,'0') as wilayah_cd_asli, IFNULL((SELECT CASE WHEN A.STATUS='A' THEN ('AKTIF') WHEN A.STATUS='D' THEN ('DAFTAR') WHEN A.STATUS='T' THEN ('TUTUP') END ),'-' )AS `status`, IFNULL(A.POKOK,'-')AS pokok, IFNULL(A.STATUS,'-')AS sts, IFNULL(A.WAJIB_AWAL,'-')AS wajib_awal, IFNULL(A.REMARK,'-')AS remark FROM m_nasabah_anggota A, m_nasabah B WHERE A.NO_ANGGOTA='" +
              norek +
              "'AND A.`NASABAH_ID`=B.`NASABAH_ID` and A.STATUS='A'");

    if (groupProduk == 'BERENCANA')
      row = await db.rawQuery(
          "SELECT xx.*, startDate1 as tglReal, endDate1 as tglJatem from (SELECT 'Sukses' as res_status,ifnull(ROUND(setoran_awal),'0') as setoranAwal,IFNULL(ROUND(jumlah_diterima),'0') as jmlDiterima,IFNULL(suku_bunga,'0') as sb, IFNULL(" +
              val['id_tb_nas'] +
              ",0)  AS tab_id, IFNULL(NASABAH_ID,0)  AS nasabahId, (SELECT TRIM((TRIM(IFNULL(NAMA_DEPAN,'')) || ' ' ||TRIM(IFNULL(NAMA_BELAKANG,'')))) FROM m_nasabah B WHERE A.NASABAH_ID=B.NASABAH_ID)AS nama, (SELECT ALAMAT FROM m_nasabah B WHERE A.NASABAH_ID=B.NASABAH_ID)AS alamat, IFNULL((SELECT description FROM s_lov_value WHERE CODE='KABUPATEN' AND ACTIVE_FLAG='Y' AND CODE_VAL = A.`WILAYAH_CD` ),'-') AS wilayah, ifnull(WILAYAH_CD,'00') as wilayahCd, IFNULL(NO_REK,'')  AS norek, ifnull(JANGKA_WAKTU,'0') || ' Bulan' AS jw,IFNULL(ROUND(setoran_per_bulan),'0') as setoranPerBulan, IFNULL((CASE START_DATE WHEN '0000-00-00 00:00:00' THEN '1900-01-01 01:00:00'ELSE START_DATE END ),'1900-01-01 01:00:00') AS startDate1, IFNULL((CASE END_DATE WHEN '0000-00-00 00:00:00' THEN '1900-01-01 01:00:00'ELSE END_DATE END ),'1900-01-01 01:00:00') AS endDate1, IFNULL((SELECT description FROM s_lov_value WHERE CODE='STATUS_PRODUCT_DEPOSITO' AND CODE_VAL =A.STATUS),'-') AS status, '0' AS saldo, '0' AS tunggakan, '0' AS kali_nunggak, IFNULL(REMARK,'-')  AS remark from " +
              val['tb_nas'] +
              " A where NO_REK='" +
              norek +
              "')xx");

    if (row.length == 0) {
      result = [
        {
          "res_status": "Gagal",
          "pesan": "Tidak ditemukan data dengan nomor " + rekDesc + " " + norek
        }
      ];
    } else {
      result = row;
    }

    return json.encode(result);
  }

  Future<dynamic> getKladOffline({
    Map<String, dynamic> dataParse,
  }) async {
    Database db = await instance.database;
    String groupProduk = _decrypt(dataParse['groupProduk']);
    String rekCd = _decrypt(dataParse['rekCd']);
    String trxDate = DateSystem;
    String kolektor = _decrypt(dataParse['user']);
    String tglAwal = _decrypt(dataParse['tglAwal']);
    String tglAkhir = _decrypt(dataParse['tglAkhir']);
    String rekDesc = groupProduk == 'ANGGOTA' ? 'no_anggota' : 'no_rek';
    List<Map<String, Object>> result;
    var val = await getDataGroupProduk(groupProduk, rekCd);
    var row;

    // if (groupProduk == 'TABUNGAN')
    //   row = await db.rawQuery(
    //       "SELECT IFNULL(A.REFERENSI_ID,'-') AS refId, IFNULL((CASE WHEN A.trans_cd='STT' THEN ('Setoran Tunai Simpanan Simpanan Sukarela') WHEN A.trans_cd='TTT' THEN ('Tarikan Tunai Tabungan Simpanan Sukarela') END ),'-' )AS `kode`, B.NO_REK AS norek, A.trans_cd AS trans_cd_asli, A.trx_type AS dbcr, A.JUMLAH AS jumlah, A.SALDO AS saldo, A.CREATE_DATE AS tgl, IFNULL(A.REMARK,'-') AS remark, TRIM((TRIM(IFNULL(C.NAMA_DEPAN,'')) || ' ' ||TRIM(IFNULL(C.NAMA_BELAKANG,''))))  AS nama FROM " +
    //           val['tb_trans'] +
    //           " A, " +
    //           val['tb_nas'] +
    //           " B, m_nasabah C WHERE A." +
    //           val['id_tb_nas'] +
    //           "=B.`" +
    //           val['id_tb_nas'] +
    //           "` AND B.NASABAH_ID=C.NASABAH_ID AND A.TRX_DATE='" +
    //           trxDate +
    //           "'AND A.CREATE_WHO='" +
    //           kolektor +
    //           "' AND A.trans_cd!='STA'ORDER BY " +
    //           val['id_tb_trans'] +
    //           " desc");

    row = await db.rawQuery(
        "SELECT a.*,trans_id, ('-') as refId, ifnull((SELECT DESCRIPTION FROM s_lov_value WHERE CODE='" +
            val['code_trans_cd'] +
            "' AND CODE_VAL=a.TRANS_CD),'-') AS kode, a.no_rek as norek, a.trans_cd as trans_cd_asli, a.jumlah as jumlah, '0' as saldo,'CR' as dbcr,a.uploaded as isUpload, (strftime('%d-%m-%Y %H:%M:%S',a.create_date))as tgl, ifnull(a.remark,'-') as remark, ifnull((case when a.uploaded='Y' then'Sudah Terupload' else 'Belum Terupload' end ),'-')as uploaded, (select count(trans_id) from t_trans_simpanan where trx_date='" +
            trxDate +
            "' and create_who = '" +
            kolektor +
            "' and rek_cd='" +
            rekCd +
            "' ) as total_trans, (select count(trans_id) from t_trans_simpanan where trx_date='" +
            trxDate +
            "' and create_who = '" +
            kolektor +
            "' and rek_cd='" +
            rekCd +
            "' and uploaded='Y' ) as total_trans_uploaded, (select count(trans_id) from t_trans_simpanan where trx_date='" +
            trxDate +
            "' and create_who = '" +
            kolektor +
            "' and rek_cd='" +
            rekCd +
            "' and uploaded='N' ) as total_trans_blm_uploaded, TRIM((TRIM(IFNULL(c.NAMA_DEPAN,'')) || ' ' ||TRIM(IFNULL(c.NAMA_BELAKANG,'')))) as nama from t_trans_simpanan a, " +
            val['tb_nas'] +
            " b,m_nasabah c where a.`no_rek`=b." +
            rekDesc +
            " and b.`nasabah_id`=c.nasabah_id and a.trx_date BETWEEN '" +
            tglAwal +
            "' and '" +
            tglAkhir +
            "' and a.create_who='" +
            kolektor +
            "' and a.rek_cd='" +
            rekCd +
            "'order by trans_id desc");

    if (row == null || row.length == 0) {
      result = [
        {"res_status": "Gagal", "pesan": "Data klad tidak ditemukan"}
      ];
    } else {
      result = row;
    }

    return json.encode(result);
  }

  Future<dynamic> getSaldoKolOffline({
    Map<String, dynamic> dataParse,
  }) async {
    Database db = await instance.database;
    String groupProduk = _decrypt(dataParse['groupProduk']);
    String rekCd = _decrypt(dataParse['rekCd']);
    String trxDate = DateSystem;
    String kolektor = _decrypt(dataParse['user']);
    List<Map<String, Object>> result;
    var row;

    row = await db.rawQuery("SELECT xx.*, ifnull( debet_tab, 0 ) AS tot_debet, ifnull( kredit_anggota + kredit_tab + kredit_duo + kredit_lestari + kredit_sihari + kredit_sirena, 0 ) AS tot_kredit, ifnull( kredit_anggota + kredit_tab + kredit_duo + kredit_lestari + kredit_sihari + kredit_sirena, 0 ) AS tot_saldo FROM (SELECT '0' AS debet_tab, ifnull( sum( jumlah ), 0 ) AS kredit_tab, ifnull( sum( jumlah ), 0 ) AS saldo_tab, ifnull(( SELECT sum( jumlah ) FROM t_trans_simpanan WHERE create_who LIKE '%" +
        kolektor +
        "%' AND uploaded = 'N' AND rek_cd = 'TABDUO' AND trx_date = '" +
        trxDate +
        "' ), 0 ) AS kredit_duo, '0' AS debet_duo, ifnull(( SELECT sum( jumlah ) FROM t_trans_simpanan WHERE create_who LIKE '%" +
        kolektor +
        "%' AND uploaded = 'N' AND rek_cd = 'TABLESTARI' AND trx_date = '" +
        trxDate +
        "' ), 0 ) AS kredit_lestari, '0' AS debet_lestari, ifnull(( SELECT sum( jumlah ) FROM t_trans_simpanan WHERE create_who LIKE '%" +
        kolektor +
        "%' AND uploaded = 'N' AND rek_cd = 'SIHARI' AND trx_date = '" +
        trxDate +
        "' ), 0 ) AS kredit_sihari, '0' AS debet_sihari, ifnull(( SELECT sum( jumlah ) FROM t_trans_simpanan WHERE create_who LIKE '%" +
        kolektor +
        "%' AND uploaded = 'N' AND rek_cd = 'SIMP_ANGGOTA' AND trx_date = '" +
        trxDate +
        "' ), 0 ) AS kredit_anggota, '0' AS debet_anggota, ifnull(( SELECT sum( jumlah ) FROM t_trans_simpanan WHERE create_who LIKE '%" +
        kolektor +
        "%' AND uploaded = 'N' AND rek_cd = 'SIMP_ANGGOTA' AND trx_date = '" +
        trxDate +
        "' ), 0 ) AS saldo_anggota, ifnull(( SELECT sum( jumlah ) FROM t_trans_simpanan WHERE create_who LIKE '%" +
        kolektor +
        "%' AND uploaded = 'N' AND rek_cd = 'SIRENA' AND trx_date = '" +
        trxDate +
        "' ), 0 ) AS kredit_sirena, '0' AS debet_sirena, ifnull(( SELECT sum( jumlah ) FROM t_trans_simpanan WHERE create_who LIKE '%" +
        kolektor +
        "%' AND uploaded = 'N' AND rek_cd = 'SIRENA' AND trx_date = '" +
        trxDate +
        "' ), 0 ) AS saldo_sirena, '0' AS kredit_kredit, '0' AS debet_kredit, '0' AS saldo_kredit, '0' AS kas_awal, '0' AS kas_keluar2, '0' AS kas_keluar1, '0' AS kas_sisa FROM t_trans_simpanan WHERE create_who LIKE '%" +
        kolektor +
        "%'AND uploaded = 'N'AND trans_cd IN ( 'STT', 'TTT' ) AND rek_cd = 'TABRELA'AND trx_date = '" +
        trxDate +
        "') xx");

    if (row.length == 0) {
      result = [
        {"res_status": "Gagal", "pesan": "Data klad tidak ditemukan"}
      ];
    } else {
      result = row;
    }

    return json.encode(result);
  }

  Future<dynamic> pencarianNasabahTabOffline({
    Map<String, dynamic> dataParse,
  }) async {
    Database db = await instance.database;
    String groupProduk = _decrypt(dataParse['groupProduk']);
    String rekCd = _decrypt(dataParse['rekCd']);
    String keyword = _decrypt(dataParse['keyword']);
    String norek = groupProduk == 'ANGGOTA' ? 'no_anggota' : 'no_rek';
    List<Map<String, Object>> result;
    var row;

    var val = await getDataGroupProduk(groupProduk, rekCd);

    row = await db.rawQuery("SELECT 'Sukses' AS res_status, A." +
        val['id_tb_nas'] +
        " AS tab_id, A." +
        norek +
        " AS norek, TRIM(TRIM(IFNULL(nama_depan,''))||' '||TRIM(IFNULL(nama_belakang,''))) as nama,'-' AS alamat_pelayanan, B.ALAMAT AS alamat, IFNULL((SELECT CASE WHEN A.STATUS='A' THEN ('AKTIF') WHEN A.STATUS='D' THEN ('DAFTAR') WHEN A.STATUS='T' THEN ('TUTUP') END ),'-' )AS `status` FROM " +
        val['tb_nas'] +
        " A, m_nasabah B WHERE TRIM(TRIM(IFNULL(nama_depan,''))||' '||TRIM(IFNULL(nama_belakang,''))) LIKE '%" +
        keyword +
        "%'AND A.`NASABAH_ID`=B.`NASABAH_ID` AND A.STATUS IN ('A','D')");

    if (row.length == 0) {
      result = [
        {
          "res_status": "Gagal",
          "pesan": "Tidak ditemukan data nasabah dengan nama " + keyword
        }
      ];
    } else {
      result = row;
    }

    return json.encode(result);
  }

  Future insertTransaksiOffline(
    Map<String, dynamic> dataParse,
    String table,
  ) async {
    Database db = await instance.database;
    Map<String, dynamic> insertVal;
    List<Map<String, Object>> result;
    bool isSukses = false;
    String tipeTrx = _decrypt(dataParse['tipeTrans']);
    String groupProduk = _decrypt(dataParse['groupProduk']);
    String norek = formatNorekProduk(_decrypt(dataParse['norek']));
    String transCd = _getTransCd(groupProduk, tipeTrx);

    var getLasIdTrx = await getLasIdTbTarns();
    dynamic counRow = getLasIdTrx['trans_id'] + 1;

    insertVal = {
      'trans_id': counRow,
      'produk_id': _decrypt(dataParse['produkId']),
      'no_rek': norek,
      'trans_cd': transCd,
      'rek_cd': _decrypt(dataParse['rekCd']),
      'jumlah': _decrypt(dataParse['jumlah']),
      'trx_type': _decrypt(dataParse['tipeTrans']),
      'trx_date': DateSystem,
      'remark': _decrypt(dataParse['trx_remark']),
      'group_cd': groupProduk,
      'create_who': _decrypt(dataParse['kolektor']),
      'create_date': DateTime.now().toString(),
      'uploaded': 'N',
      'latitude': _decrypt(dataParse['lat']),
      'longitude': _decrypt(dataParse['longi']),
    };
    print(insertVal.toString());
    try {
      await db.insert(table, insertVal);
      isSukses = true;
    } catch (e) {
      print(e);
    }

    if (!isSukses) {
      result = [
        {
          "status": "Gagal",
          "pesan": "Terjadi kesalahan saat menginput transaksi [QUERY_ERR]"
        }
      ];
    } else {
      //int lastId = await queryRowCount(table);
      var getLasIdTrx2 = await getLasIdTbTarns();
      result = [
        {
          "status": "Sukses",
          "pesan": "Data transaksi berhasil disimpan",
          "jumlah": insertVal['jumlah'],
          "pokok": "0",
          "bunga": "0",
          "denda": "0",
          "groupProduk": _decrypt(dataParse['groupProduk']),
          "keterangan":
              insertVal['remark'] == '' ? '-' : insertVal['remark'] ?? '-',
          "kode": "-",
          "trx_date": "-",
          "no_referensi": "-",
          "norek": insertVal['no_rek'],
          "nama": "-",
          "no_hp": "-",
          "saldo_awal": "0",
          "saldo_akhir": "0",
          "terbilang": "-",
          "who": insertVal['create_who'],
          'lastId': getLasIdTrx2['trans_id'],
        }
      ];
    }

    return json.encode(result);
  }

  Future manageDataMigrationProduct(
      dynamic dataParse, groupProduk, rekCd) async {
    int isDataExist = 0, rowEffectedAdd = 0, rowEffectedEdit = 0;
    bool actionQuery = false;
    String actionType = '';
    var dataVal = Map<String, dynamic>();
    var groupPrdk = await getDataGroupProduk(groupProduk, rekCd);
    var jsonData = json.decode(dataParse);
    await Future.forEach(
      jsonData,
      (val) async {
        isDataExist = await queryRowCountWithClause(
          groupPrdk['tb_nas'],
          groupPrdk['id_tb_nas'],
          val['produk_id'],
        );

        if (groupProduk == 'ANGGOTA')
          dataVal['no_anggota'] = val['no_rek'];
        else
          dataVal['no_rek'] = val['no_rek'];

        dataVal['' + groupPrdk['id_tb_nas'] + ''] = val['produk_id'];

        if (groupProduk == 'ANGGOTA')
          dataVal['wajib_awal'] = val['setoran_awal'];
        else
          dataVal['setoran_awal'] = val['setoran_awal'];

        dataVal['nasabah_id'] = val['nasabah_id'];
        dataVal['wilayah_cd'] = val['wilayah_cd'];
        dataVal['group_cd'] = val['group_cd'];
        dataVal['status'] = val['status'];

        if (groupProduk == 'BERENCANA') {
          dataVal['jangka_waktu'] = val['jangka_waktu'];
          dataVal['start_date'] = val['start_date'];
          dataVal['end_date'] = val['end_date'];
          dataVal['setoran_awal'] = val['setoran_awal'];
          dataVal['setoran_per_bulan'] = val['setoran_per_bulan'];
          dataVal['jumlah_diterima'] = val['jumlah_diterima'];
          dataVal['suku_bunga'] = val['suku_bunga'];
        }

        print('jml diterima :' + val['jumlah_diterima']);

        dataVal['create_who'] = val['create_who'];
        dataVal['create_date'] = val['create_date'];

        if (isDataExist != 0) {
          actionType = 'UPDATE';
          actionQuery = await updateDataGlobal(
            groupPrdk['tb_nas'],
            dataVal,
            groupPrdk['id_tb_nas'],
            val['produkId'],
          );
        } else {
          actionType = 'INSERT';
          actionQuery = await insertDataGlobal(groupPrdk['tb_nas'], dataVal);
        }

        if (actionQuery && actionType == 'INSERT') rowEffectedAdd++;
        if (actionQuery && actionType == 'UPDATE') rowEffectedEdit++;
      },
    );
    return {'row_edit': rowEffectedEdit ?? 0, 'row_add': rowEffectedAdd ?? 0};
  }

  Future manageDataMigrationAccount(
      dynamic dataParse, groupProduk, rekCd) async {
    int isDataExist = 0, rowEffectedAdd = 0, rowEffectedEdit = 0;
    bool actionQuery = false;
    String actionType = '';
    var dataVal = Map<String, dynamic>();
    var jsonData = json.decode(dataParse);
    await Future.forEach(
      jsonData,
      (val) async {
        isDataExist = await queryRowCountWithClause(
          's_user_kolektor',
          'kolektor_id',
          val['user_id'],
        );

        dataVal['kolektor_id'] = val['user_id'];
        dataVal['username'] = val['username'];
        dataVal['password'] = val['pwd'];
        dataVal['imei'] = val['imei'];
        dataVal['sn_number'] = val['sn_number'];
        dataVal['apk_version'] = val['apk_version'];
        dataVal['status'] = val['status'];

        if (isDataExist != 0) {
          actionType = 'UPDATE';
          actionQuery = await updateDataGlobal(
            's_user_kolektor',
            dataVal,
            'kolektor_id',
            int.parse(val['user_id']),
          );
        } else {
          actionType = 'INSERT';
          actionQuery = await insertDataGlobal('s_user_kolektor', dataVal);
        }

        if (actionQuery && actionType == 'INSERT') rowEffectedAdd++;
        if (actionQuery && actionType == 'UPDATE') rowEffectedEdit++;
      },
    );
    return {'row_edit': rowEffectedEdit ?? 0, 'row_add': rowEffectedAdd ?? 0};
  }

  Future manageDataMigrationNasabah(
      dynamic dataParse, groupProduk, rekCd) async {
    int isDataExist = 0, rowEffectedAdd = 0, rowEffectedEdit = 0;
    bool actionQuery = false;
    String actionType = '';
    var dataVal = Map<String, dynamic>();
    var jsonData = json.decode(dataParse);
    await Future.forEach(
      jsonData,
      (val) async {
        isDataExist = await queryRowCountWithClause(
          tb_master_nasabah,
          'nasabah_id',
          val['nasabah_id'],
        );

        dataVal['nasabah_id'] = val['nasabah_id'];
        dataVal['no_master'] = val['no_master'];
        dataVal['nama_depan'] = val['nama_depan'];
        dataVal['nama_belakang'] = val['nama_belakang'];
        dataVal['alamat'] = val['alamat'];
        dataVal['nama_ibu'] = val['nama_ibu'];
        dataVal['tmp_lahir'] = val['tmp_lahir'];
        dataVal['tgl_lahir'] = val['tgl_lahir'];
        dataVal['nik'] = val['nik'];
        dataVal['hp'] = val['hp'];
        dataVal['status'] = val['status'];

        if (isDataExist != 0) {
          actionType = 'UPDATE';
          actionQuery = await updateDataGlobal(
            tb_master_nasabah,
            dataVal,
            'nasabah_id',
            int.parse(val['nasabah_id']),
          );
        } else {
          actionType = 'INSERT';
          actionQuery = await insertDataGlobal(tb_master_nasabah, dataVal);
        }

        if (actionQuery && actionType == 'INSERT') rowEffectedAdd++;
        if (actionQuery && actionType == 'UPDATE') rowEffectedEdit++;
      },
    );
    return {'row_edit': rowEffectedEdit ?? 0, 'row_add': rowEffectedAdd ?? 0};
  }

  Future manageDataMigrationConfig(dynamic dataParse) async {
    int rowEffectedAdd = 0, rowEffectedEdit = 0;
    bool actionQuery = false, actionDell;
    String actionType = '';
    var dataVal = Map<String, dynamic>();
    var jsonData = json.decode(dataParse);
    actionDell = await deleteDataGlobal(tb_menu_mobkol);
    if (actionDell)
      await Future.forEach(
        jsonData,
        (val) async {
          dataVal['id_menu'] = val['id_menu'];
          dataVal['group_menu'] = val['group_menu'];
          dataVal['rek_cd'] = val['rek_cd'];
          dataVal['kode_produk'] = val['kode_produk'];
          dataVal['code_trans_cd'] = val['code_trans_cd'];
          dataVal['tb_nas'] = val['tb_nas'];
          dataVal['id_tb_nas'] = val['id_tb_nas'];
          dataVal['tb_trans'] = val['id_tb_trans'];
          dataVal['fnSaldo'] = val['fnSaldo'];
          dataVal['nama_menu'] = val['nama_menu'];
          dataVal['icon'] = val['icon'];
          dataVal['rek_shortcut'] = val['rek_shortcut'];
          dataVal['remark'] = val['remark'];
          dataVal['min_setoran'] = val['min_setoran'];
          dataVal['min_tarikan'] = val['min_tarikan'];
          dataVal['urut_menu'] = val['urut_menu'];
          dataVal['active_flag'] = val['active_flag'];
          dataVal['create_who'] = val['create_who'];
          dataVal['create_date'] = val['create_date'];

          actionType = 'INSERT';
          actionQuery = await insertDataGlobal(tb_menu_mobkol, dataVal);

          if (actionQuery && actionType == 'INSERT') rowEffectedAdd++;
          if (actionQuery && actionType == 'UPDATE') rowEffectedEdit++;
        },
      );
    return {'row_edit': rowEffectedEdit ?? 0, 'row_add': rowEffectedAdd ?? 0};
  }

  String formatNorekProduk(String norekParse) {
    //SET FORMAT NOREK LOGIC OR JUST RETURN norekParse

    // String formated = "0";
    // var arrStr = norekParse.split('.');
    // String kodeRek = arrStr[0];
    // String noUrut = arrStr[1];
    // int strLen = 5 - noUrut.length;
    // String zero = "";
    // for (var i = 0; i < strLen; i++) {
    //   zero += "0";
    // }
    // formated = kodeRek + "." + zero + noUrut;

    // return formated;

    return norekParse;
  }

  String _getTransCd(String groupProduk, String tipeTrans) {
    String transCd = '-';
    if (groupProduk == 'TABUNGAN') {
      if (tipeTrans == 'SETOR')
        transCd = 'STT';
      else
        transCd = 'TTT';
    } else if (groupProduk == 'ANGGOTA') {
      if (tipeTrans == 'SETOR')
        transCd = 'STW';
      else
        transCd = 'TTW';
    } else if (groupProduk == 'DEPOSITO' || groupProduk == 'BERENCANA') {
      if (tipeTrans == 'SETOR')
        transCd = 'STJ';
      else
        transCd = 'PTJ';
    } else if (groupProduk == 'KREDIT') {
      transCd = 'PKT';
    }

    return transCd;
  }

  // Future<int> update(Todo todo) async {
  //   return await db.update(tableTodo, todo.toMap(),
  //       where: '$columnId = ?', whereArgs: [todo.id]);
  // }

  Future getDataGlobal({String table, String whereClause, int id}) async {
    Database db = await instance.database;
    Map<String, dynamic> result;
    //var maps = await db.query(table, where: 'kolektor_id = ?', whereArgs: [id]);
    var maps = await db.query(table);
    if (maps.length > 0) {
      result = maps.first;
    } else {
      result = {'status': 'Gagal', 'pesan': 'Query ERR'};
    }

    return result;
  }

  // Future<Todo> getTodo(int id) async {
  //   Database db = await instance.database;
  //   List<Map> maps = db.rawQuery('SELECT COUNT(*) FROM $tb_auth');
  //   if (maps.length > 0) {
  //     return Todo.fromMap(maps.first);
  //   }
  //   return null;
  // }
}
