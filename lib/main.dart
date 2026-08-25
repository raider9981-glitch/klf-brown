// ============================================================
// KLF-棕化
// 版本：v1.3.0
//
// 本次版本修改內容：
// 1. A線／B線加入各槽槽體積
// 2. 酸洗槽、清潔槽、預浸槽、棕化槽顯示槽體積
// 3. 修正預浸槽 CBBA-A 添加算法
// 4. A線預浸槽 CBBA-A：每 0.1 濃度差添加 1.0 L
// 5. B線預浸槽 CBBA-A：每 0.1 濃度差添加 0.5 L
// 6. 化驗成果顯示藥品所屬槽別
// 7. 保留原本化驗計算公式
// 8. 保留原本化驗存檔功能
// 9. 保留原本化驗修改功能
// 10. 保留登入、Firebase、管理者、QR Code 功能
// 11. 桌面版功能與其他計算邏輯不變
// 12. 主畫面新增 C線、D線、E線，顯示「待開發」且不可進入化驗
// 13. 化驗存檔管理者密碼只驗證一次；開啟管理模式後可直接刪除各筆紀錄
// 14. 授權人員最後登入時間由 Firebase 背景更新，管理者後台顯示到分鐘
// 15. 化驗存檔需添加量改存數值／狀態，顯示時依目前中文／泰文切換
// 16. 最後登入使用固定授權文件 ID + merge 背景更新，避免時間被空值覆蓋
// 13. 化驗畫面手機版改為緊湊表格式，減少垂直高度
// 14. 保留原本計算公式、槽體積、Firebase 與存檔功能
// 15. 化驗頁上方新增管理者按鈕
// 16. 強化主畫面 Web App 自動更新機制由 web/index.html 處理
// 17. 化驗存檔單筆資料改為獨立完整化驗結果頁
// 18. 獨立結果頁沿用化驗頁版型並填滿手機畫面
// 19. 主畫面手機版生產線卡片改為緊湊排版，減少上下空白
// 20. 主畫面化驗週期區塊改為緊湊排版，減少高度
// 21. 化驗存檔單筆結果頁縮小生產線、操作員、時間等資訊區塊
// 22. 化驗結果頁改為更緊湊的一頁式排列，保留所有化驗資料與功能
// 23. A／B／D／E 四條線加入正式建浴／配槽量
// 24. B線酸洗槽 50% H₂SO₄ 建浴量以 85 L 為準
//
// 23. v1.2.7 新增 D線／E線 VS棕化線，兩線各 5 槽
// 24. v1.2.8 修正中文／泰文翻譯編譯問題
// 25. v1.2.8 主畫面六條生產線下方新增「各線藥水建浴比例」與「濾心更換頻率」兩格，皆待開發
// 24. D線槽體積：470 / 450 / 300 / 1350 / 445 L
// 25. E線槽體積：420 / 390 / 450 / 1200 / 580 L
// 26. D/E 線硫酸 × 0.702、雙氧水 × 0.49、ALK × 0.05
// 27. D/E 活化槽：吸收值 ÷ 0.538 × 20
// 28. D/E 銅離子 × 3.177
// 29. D/E HF1000：分析值 ÷ 0.544 × 65 = B；銅離子濃度 × 0.78 = A；A－B
// 30. D/E VS：(分析值 + 0.0067) ÷ 0.1392 × 2.5
// 31. D/E 中值依指定條件加入，添加量依槽體積每 0.1 濃度差為 0.5 / 1.0 / 1.5 L，最後取整數
// 32. 新增 F線，標示待開發
// 33. 新增全系統中文／泰文一鍵同步切換
// 34. 登入頁與各頁面加入語言切換按鈕；切換後所有頁面同步
// 35. 泰文模式下所有介面文字翻譯，數字與化學式維持原樣
// 36. DE 線 ALK 修正為：分析值 × 0.5
// 37. DE 線 HF1000 修正為：A = 分析值 ÷ 0.544 × 6.5；B = 銅離子濃度 × 0.078；HF1000 = A − B
// 38. 單線 D/E 與 DE 合併化驗同步使用最新公式
// 39. 化驗步驟按鈕放在藥品名稱右側，保留原按鈕底色，僅將 🧪 圖示改為綠色
// 40. 化驗步驟按鈕位置與其他計算功能不變
// 41. A線化驗頁試作新版排版：每種藥水清楚分開顯示滴定值、中值、濃度、需添加量
// 42. A線手機版改為 2×2 資訊區塊，讓「中值」更容易查看；B/D/E 維持原版
// 43. 四線化驗頁文字微放大 1～2 px，不改格子大小與間距
// 44. 全網站文字與數字微放大，不改格子大小、間距與版面結構
// 45. 登入速度優化：已記住使用者直接進入主畫面，Firebase 背景確認
// 46. 最後登入時間背景寫入，不阻塞進入
// 47. 授權名單姓名與最後登入時間一次讀取
// 48. 最後登入時間只顯示到分鐘
// 49. 最後登入保存修正：使用 merge 寫入，保留既有時間
// 50. 管理者名單刷新不以空值覆蓋已存在的最後登入時間
// 51. 快速登入背景更新最後登入時間，不等待寫入完成
// 52. 一般化驗人員只能查看存檔，只有管理者可修改
// 53. 管理者修改後保留原本化驗人員名稱
// 54. 存檔中的中文／泰文顯示依目前系統語言同步切換
// 55. v1.3.0 G站化驗流程 2.0：手機導引、今日狀態、7日趨勢、防誤輸入、結果總覽與操作優化
// 56. 保留既有 Firebase、化驗公式、槽體積、存檔與中文／泰文功能
// ============================================================

import 'dart:convert';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(KLFApp());
}

class FirebaseUserManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = 'authorized_users';

  static Future<List<Map<String, dynamic>>> getUsersWithLoginTime() async {
    final snapshot = await _firestore
        .collection(collectionName)
        .orderBy('name')
        .get();

    final byName = <String, Map<String, dynamic>>{};

    for (final doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      final name = (data['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      data['name'] = name;

      final rawLastLogin = data['lastLoginAt'];
      final lastLogin = rawLastLogin is Timestamp
          ? rawLastLogin.toDate()
          : rawLastLogin is DateTime
          ? rawLastLogin
          : null;
      data['lastLoginAt'] = lastLogin;

      final existing = byName[name];
      final existingTime = existing?['lastLoginAt'];

      if (existing == null ||
          (lastLogin is DateTime &&
              (existingTime is! DateTime || lastLogin.isAfter(existingTime)))) {
        byName[name] = data;
      }
    }

    return byName.values.toList();
  }

  static Future<List<String>> getUsers() async {
    final users = await getUsersWithLoginTime();
    return users
        .map((data) => (data['name'] ?? '').toString().trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  static Future<void> updateLastLoginInBackground(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('name', isEqualTo: cleanName)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      final loginTime = FieldValue.serverTimestamp();

      for (final doc in snapshot.docs) {
        // 只更新 lastLoginAt，其餘授權資料全部保留。
        batch.set(doc.reference, {
          'lastLoginAt': loginTime,
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (_) {
      // 最後登入時間只是管理資訊，寫入失敗不影響使用者登入。
    }
  }

  static Future<String?> findUserDocumentId(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return null;

    final snapshot = await _firestore
        .collection(collectionName)
        .where('name', isEqualTo: cleanName)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  static Future<bool> isAuthorized(String name) async {
    return (await findUserDocumentId(name)) != null;
  }

  static Future<bool> addUser(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return false;

    if (await isAuthorized(cleanName)) {
      return false;
    }

    await _firestore.collection(collectionName).add({
      'name': cleanName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  static Future<void> deleteUser(String name) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .where('name', isEqualTo: name.trim())
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}

class FirebaseAnalysisManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = 'analysis_records';

  static Future<void> addRecord(Map<String, dynamic> record) async {
    final data = Map<String, dynamic>.from(record);

    data.remove('id');
    data.remove('time');
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection(collectionName).add(data);
  }

  static Future<List<Map<String, dynamic>>> getRecords() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      // 強制從 Firebase Server 讀取，避免 Web 空快取被誤判成沒有資料。
      snapshot = await _firestore
          .collection(collectionName)
          .get(const GetOptions(source: Source.server));
    } catch (serverError) {
      try {
        // Server 暫時不可用時，再嘗試本機 Firestore 快取。
        snapshot = await _firestore
            .collection(collectionName)
            .get(const GetOptions(source: Source.cache));
      } catch (cacheError) {
        throw Exception(
          'Firestore 讀取失敗。Server: $serverError；Cache: $cacheError',
        );
      }
    }

    final records = snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;

      final createdAt = data['createdAt'];
      final updatedAt = data['updatedAt'];

      data['time'] = createdAt is Timestamp
          ? createdAt.toDate().toIso8601String()
          : (data['time']?.toString() ?? '');

      if (createdAt is Timestamp) {
        data['createdAt'] = createdAt.toDate().toIso8601String();
      }

      if (updatedAt is Timestamp) {
        data['updatedAt'] = updatedAt.toDate().toIso8601String();
      }

      return data;
    }).toList();

    records.sort((a, b) {
      final aTime = DateTime.tryParse(a['time']?.toString() ?? '');
      final bTime = DateTime.tryParse(b['time']?.toString() ?? '');

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime);
    });

    return records;
  }

  static Future<void> updateRecord(
    String id,
    Map<String, dynamic> record,
  ) async {
    final data = Map<String, dynamic>.from(record);

    data.remove('id');
    data.remove('time');
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection(collectionName).doc(id).update(data);
  }

  static Future<void> deleteRecord(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }
}

class KLFConfig {
  static const String appName = 'KLF-棕化';
  static const String version = 'v1.3.0';

  static const String adminPassword = '0';

  static const String websiteUrl = 'https://klf-brown.web.app';

  static const String storageDeviceUser = 'klf_device_user';
  static const String storageAnalysisRecords = 'klf_analysis_records';
  static const String storageAuthorizedUsers = 'klf_authorized_users';
}

class LocalStorageHelper {
  static String? get(String key) => html.window.localStorage[key];

  static void set(String key, String value) {
    html.window.localStorage[key] = value;
  }

  static void remove(String key) {
    html.window.localStorage.remove(key);
  }

  // Firestore 的 Timestamp / DateTime 不能直接 jsonEncode。
  // 快取前遞迴轉成可保存的字串，避免「Converting object to an encodable object failed」。
  static dynamic _jsonSafe(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), _jsonSafe(item)),
      );
    }

    if (value is Iterable) {
      return value.map(_jsonSafe).toList();
    }

    if (value is num || value is String || value is bool || value == null) {
      return value;
    }

    // 其他 Firebase / Web 特殊物件不要讓快取寫入把整個讀取流程打斷。
    return value.toString();
  }

  static String? getDeviceUser() {
    return get(KLFConfig.storageDeviceUser);
  }

  static void saveDeviceUser(String userName) {
    set(KLFConfig.storageDeviceUser, userName);
  }

  static void clearDeviceUser() {
    remove(KLFConfig.storageDeviceUser);
  }

  static List<Map<String, dynamic>> getRecords() {
    final data = get(KLFConfig.storageAnalysisRecords);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(data);

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  static void saveRecords(List<Map<String, dynamic>> records) {
    final safeRecords = _jsonSafe(records);
    set(KLFConfig.storageAnalysisRecords, jsonEncode(safeRecords));
  }
}

class KLFGlobalLanguage {
  static bool isThai = false;
  static final ValueNotifier<bool> notifier = ValueNotifier<bool>(false);

  static void toggle() {
    isThai = !isThai;
    notifier.value = isThai;
  }

  static void notify() {
    notifier.value = isThai;
  }
}

class LanguageRoot extends StatelessWidget {
  final Widget child;

  LanguageRoot({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, __, ___) => child,
    );
  }
}

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isThai = KLFGlobalLanguage.isThai;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8A5A44), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _languageChoice(
            context,
            label: '中文',
            selected: !isThai,
            onTap: () {
              if (isThai) {
                KLFGlobalLanguage.isThai = false;
                KLFGlobalLanguage.notify();
              }
            },
          ),
          _languageChoice(
            context,
            label: 'ไทย',
            selected: isThai,
            onTap: () {
              if (!isThai) {
                KLFGlobalLanguage.isThai = true;
                KLFGlobalLanguage.notify();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _languageChoice(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2D7E3) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: selected ? const Color(0xFF5A2038) : const Color(0xFF4A4A4A),
          ),
        ),
      ),
    );
  }
}

String tr(String text) {
  if (!KLFGlobalLanguage.isThai) return text;

  final m = <String, String>{
    'KLF-棕化': 'KLF-การทำสีน้ำตาล',
    '名稱未授權，無法登入': 'ชื่อไม่ได้รับอนุญาต ไม่สามารถเข้าสู่ระบบได้',
    '刪除後所有裝置都將無法再使用此名稱登入。':
        'หลังลบแล้ว อุปกรณ์ทั้งหมดจะไม่สามารถใช้ชื่อนี้เข้าสู่ระบบได้',
    '已刪除：': 'ลบแล้ว: ',
    '已新增授權人員：': 'เพิ่มผู้ได้รับอนุญาตแล้ว: ',
    '找不到雲端存檔識別碼': 'ไม่พบรหัสบันทึกบนคลาวด์',
    '例如：王小明': 'เช่น: 王小明',
    '硫酸、雙氧水': 'กรดซัลฟิวริก、ไฮโดรเจนเปอร์ออกไซด์',
    '硫酸、雙氧水、CBBA-A、銅離子': 'กรดซัลฟิวริก、ไฮโดรเจนเปอร์ออกไซด์、CBBA-A、ไอออนทองแดง',
    '硫酸、VS': 'กรดซัลฟิวริก、VS',
    '雙氧水、CBBA-A': 'ไฮโดรเจนเปอร์ออกไซด์、CBBA-A',
    'HF1000、硫酸、雙氧水、銅離子': 'HF1000、กรดซัลฟิวริก、ไฮโดรเจนเปอร์ออกไซด์、ไอออนทองแดง',
    '第二槽｜鹼洗槽': 'ถังที่ 2｜ถังล้างด่าง',
    '第三槽｜活化槽': 'ถังที่ 3｜ถังแอคทิเวเตอร์',
    '第五槽｜後浸槽': 'ถังที่ 5｜ถังโพสต์ดิป',

    'A線': 'สาย A',
    'B線': 'สาย B',
    'C線': 'สาย C',
    'D線': 'สาย D',
    'E線': 'สาย E',
    'F線': 'สาย F',
    'VS棕化線': 'สายการทำสีน้ำตาล VS',
    '各線藥水建浴比例': 'อัตราส่วนการสร้างน้ำยาของแต่ละสาย',
    '濾心更換頻率': 'ความถี่ในการเปลี่ยนไส้กรอง',
    '棕化藥水分析管理系統': 'ระบบวิเคราะห์น้ำยาการทำสีน้ำตาล',
    '授權人員名稱': 'ชื่อผู้ได้รับอนุญาต',
    '請輸入已授權名稱': 'กรุณาป้อนชื่อที่ได้รับอนุญาต',
    '登入': 'เข้าสู่ระบบ',
    '首次登入需輸入已授權名稱登入': 'การเข้าสู่ระบบครั้งแรกต้องใช้ชื่อที่ได้รับอนุญาต',
    '管理者登入': 'เข้าสู่ระบบผู้ดูแล',
    '管理者密碼': 'รหัสผ่านผู้ดูแล',
    '登入管理者': 'เข้าสู่ระบบผู้ดูแล',
    '管理者密碼錯誤': 'รหัสผ่านผู้ดูแลไม่ถูกต้อง',
    '管理模式已開啟': 'โหมดผู้ดูแลเปิดอยู่',
    '管理模式已關閉': 'ปิดโหมดผู้ดูแลแล้ว',
    '關閉管理模式': 'ปิดโหมดผู้ดูแล',
    '請先開啟管理模式': 'โปรดเปิดโหมดผู้ดูแลก่อน',

    '管理者設定': 'การตั้งค่าผู้ดูแล',
    '管理者驗證': 'ยืนยันผู้ดูแล',
    '管理者': 'ผู้ดูแล',
    '重新整理': 'รีเฟรช',
    '新增授權人員': 'เพิ่มผู้ได้รับอนุญาต',
    '請輸入授權人員名稱': 'กรุณาป้อนชื่อผู้ได้รับอนุญาต',
    '請輸入授權名稱': 'กรุณาป้อนชื่อที่ได้รับอนุญาต',
    '新增': 'เพิ่ม',
    '新增後會同步到 Firebase，其他手機也可以使用。':
        'หลังจากเพิ่มแล้วจะซิงค์กับ Firebase และโทรศัพท์เครื่องอื่นสามารถใช้งานได้',
    '已授權人員': 'ผู้ได้รับอนุญาต',
    'Firebase 雲端授權': 'การอนุญาตผ่าน Firebase Cloud',
    '最後登入：': 'เข้าสู่ระบบล่าสุด: ',
    '尚未登入': 'ยังไม่เคยเข้าสู่ระบบ',
    '這個名稱已經存在': 'ชื่อนี้มีอยู่แล้ว',
    '新增失敗，請確認 Firebase 連線': 'เพิ่มไม่สำเร็จ โปรดตรวจสอบการเชื่อมต่อ Firebase',
    '刪除授權人員': 'ลบผู้ได้รับอนุญาต',
    '確定要刪除「': 'ยืนยันการลบ “',
    '嗎？': '” หรือไม่?',
    '取消': 'ยกเลิก',
    '刪除': 'ลบ',
    '確認': 'ยืนยัน',
    '刪除失敗，請確認 Firebase 連線': 'ลบไม่สำเร็จ โปรดตรวจสอบการเชื่อมต่อ Firebase',
    '本設備登入記錄': 'บันทึกการเข้าสู่ระบบของอุปกรณ์นี้',
    '目前沒有記錄': 'ไม่มีบันทึก',
    '清除': 'ล้าง',
    '本設備登入記錄已清除': 'ล้างบันทึกการเข้าสู่ระบบของอุปกรณ์นี้แล้ว',
    '授權資料來源': 'แหล่งข้อมูลการอนุญาต',
    '雲端同步': 'ซิงค์บนคลาวด์',
    '系統版本': 'เวอร์ชันระบบ',
    '棕化水平生產線': 'สายการผลิตแนวนอนการทำสีน้ำตาล',
    '生產線選擇': 'เลือกสายการผลิต',
    '各線藥水建浴比例': 'อัตราส่วนการสร้างน้ำยาของแต่ละสายการผลิต',
    '各線藥水建浴比例規劃': 'การวางแผนอัตราส่วนการสร้างน้ำยา',
    '藥水建浴比例': 'อัตราส่วนการสร้างน้ำยา',
    '請選擇生產線': 'กรุณาเลือกสายการผลิต',
    '配槽量目前待提供，之後再補上實際數量': 'ปริมาณผสมยังรอข้อมูล จะเติมจำนวนจริงภายหลัง',
    '待提供': 'รอข้อมูล',
    '請選擇生產線進行藥水分析': 'กรุณาเลือกสายการผลิตเพื่อวิเคราะห์น้ำยา',
    '生產線相關功能': 'ฟังก์ชันที่เกี่ยวข้องกับสายการผลิต',
    '進入查看': 'เข้าสู่การดูข้อมูล',
    '查看、搜尋、修改歷史化驗資料': 'ดู ค้นหา และแก้ไขข้อมูลการวิเคราะห์ย้อนหลัง',
    '提供各生產線藥水建浴比例參考': 'อัตราส่วนการสร้างน้ำยาสำหรับแต่ละสายการผลิต',
    '提供濾心更換頻率參考建議': 'คำแนะนำความถี่ในการเปลี่ยนไส้กรอง',
    '請選擇需要進行藥水分析的生產線': 'กรุณาเลือกสายการผลิตที่ต้องการวิเคราะห์น้ำยา',
    '選擇生產線進行藥水分析': 'เลือกสายการผลิตเพื่อวิเคราะห์น้ำยา',
    '棕化水平生產線 A': 'สายการผลิตแนวนอนการทำสีน้ำตาล A',
    '棕化水平生產線 B': 'สายการผลิตแนวนอนการทำสีน้ำตาล B',
    '進入化驗': 'เข้าสู่การวิเคราะห์',
    '待開發': 'อยู่ระหว่างการพัฒนา',
    '邀請開啟網站': 'เชิญเปิดเว็บไซต์',
    'KLF-棕化網站 QR Code': 'QR Code เว็บไซต์ KLF-棕化',
    '使用手機掃描 QR Code 即可開啟 KLF-棕化網站':
        'สแกน QR Code ด้วยโทรศัพท์เพื่อเปิดเว็บไซต์ KLF-棕化',
    '掃描後仍需使用已授權名稱登入': 'หลังสแกนยังต้องเข้าสู่ระบบด้วยชื่อที่ได้รับอนุญาต',
    '關閉': 'ปิด',
    '化驗步驟': 'ขั้นตอนการวิเคราะห์',
    'A／B 共用標準': 'มาตรฐานร่วม A／B',
    'D／E 共用標準': 'มาตรฐานร่วม D／E',
    '化驗存檔': 'บันทึกการวิเคราะห์',
    '化驗結果': 'ผลการวิเคราะห์',
    '藥水化驗': 'การวิเคราะห์น้ำยา',
    '修改化驗資料': 'แก้ไขข้อมูลการวิเคราะห์',
    '查看、修改歷史化驗資料': 'ดูและแก้ไขข้อมูลการวิเคราะห์ย้อนหลัง',
    '查看化驗存檔': 'ดูบันทึกการวิเคราะห์',
    '化驗週期：每 4 小時進行一次藥水分析': 'รอบการวิเคราะห์: วิเคราะห์น้ำยาทุก 4 ชั่วโมง',
    '重新讀取': 'โหลดใหม่',
    '目前沒有化驗存檔': 'ยังไม่มีบันทึกการวิเคราะห์',
    '化驗完成': 'วิเคราะห์เสร็จแล้ว',
    '尚未完成': 'ยังไม่เสร็จ',
    '確認化驗存檔': 'ยืนยันการบันทึกผลการวิเคราะห์',
    '確認目前化驗結果並存檔嗎？': 'ยืนยันผลการวิเคราะห์ปัจจุบันและบันทึกหรือไม่?',
    '以下藥水尚未輸入：': 'น้ำยาต่อไปนี้ยังไม่ได้ป้อน:',
    '仍要存檔嗎？': 'ยังต้องการบันทึกหรือไม่?',
    '確認存檔': 'ยืนยันการบันทึก',
    '確認合併化驗存檔': 'ยืนยันการบันทึกผลการวิเคราะห์ร่วม',
    '確認 A/B 或 D/E 兩條線的化驗結果都正確，並一起存檔嗎？':
        'ยืนยันว่าผลการวิเคราะห์ของ A/B หรือ D/E ถูกต้อง และบันทึกพร้อมกันหรือไม่?',
    '搜尋化驗紀錄': 'ค้นหาบันทึกการวิเคราะห์',
    '搜尋線別、合併化驗、操作員或日期':
        'ค้นหาสายการผลิต การวิเคราะห์ร่วม ผู้ปฏิบัติงาน หรือวันที่',
    '沒有符合條件的化驗紀錄': 'ไม่พบบันทึกการวิเคราะห์ที่ตรงเงื่อนไข',

    '生產線': 'สายการผลิต',
    '操作員': 'ผู้ปฏิบัติงาน',
    '時間': 'เวลา',
    '咬食量': 'ปริมาณการกัด',
    '化驗人員：': 'ผู้วิเคราะห์: ',
    '化驗完成並存檔': 'วิเคราะห์เสร็จและบันทึก',
    '化驗資料已儲存至雲端': 'บันทึกข้อมูลการวิเคราะห์ไปยังคลาวด์แล้ว',
    '化驗資料已刪除': 'ลบข้อมูลการวิเคราะห์แล้ว',
    '雲端存檔失敗，請確認網路與 Firebase 權限':
        'บันทึกบนคลาวด์ไม่สำเร็จ โปรดตรวจสอบเครือข่ายและสิทธิ์ Firebase',
    '無法連線 Firebase，請確認網路連線': 'ไม่สามารถเชื่อมต่อ Firebase โปรดตรวจสอบเครือข่าย',
    '無法讀取 Firebase 授權名單': 'ไม่สามารถอ่านรายชื่อผู้ได้รับอนุญาตจาก Firebase',
    '無法讀取雲端化驗資料，請確認網路與 Firebase 權限':
        'ไม่สามารถอ่านข้อมูลการวิเคราะห์บนคลาวด์ โปรดตรวจสอบเครือข่ายและสิทธิ์ Firebase',
    '雲端修改失敗，請稍後再試': 'แก้ไขบนคลาวด์ไม่สำเร็จ โปรดลองอีกครั้งภายหลัง',
    '只有管理者可以修改化驗紀錄': 'เฉพาะผู้ดูแลเท่านั้นที่สามารถแก้ไขบันทึกการวิเคราะห์ได้',
    '修改': 'แก้ไข',
    '修改後會重新計算濃度、需添加量及咬食量':
        'หลังแก้ไขจะคำนวณความเข้มข้น ปริมาณเติม และปริมาณการกัดใหม่',
    '儲存修改': 'บันทึกการแก้ไข',
    '修改已儲存至雲端': 'บันทึกการแก้ไขไปยังคลาวด์แล้ว',
    '刪除存檔': 'ลบบันทึก',
    '確定要永久刪除這筆化驗資料嗎？': 'ยืนยันการลบข้อมูลการวิเคราะห์นี้ถาวรหรือไม่?',
    '刪除化驗資料需要管理者權限。': 'การลบข้อมูลการวิเคราะห์ต้องใช้สิทธิ์ผู้ดูแล',
    '刪除失敗，請確認網路連線': 'ลบไม่สำเร็จ โปรดตรวจสอบการเชื่อมต่อเครือข่าย',
    '管理者密碼錯誤，無法刪除': 'รหัสผ่านผู้ดูแลไม่ถูกต้อง ไม่สามารถลบได้',
    '輸入': 'ป้อนค่า',
    '分析值': 'ค่าการวิเคราะห์',
    '吸收值': 'ค่าการดูดกลืน',
    '中值': 'ค่ากลาง',
    '濃度': 'ความเข้มข้น',
    '需添加量': 'ปริมาณที่ต้องเติม',
    '不用添加': 'ไม่ต้องเติม',
    '無中值': 'ไม่มีค่ากลาง',
    '輸入滴定值': 'ป้อนค่าการไตเตรต',
    '直接輸入濃度': 'ป้อนความเข้มข้นโดยตรง',
    '未棕化重量': 'น้ำหนักก่อนการทำสีน้ำตาล',
    '已棕化重量': 'น้ำหนักหลังการทำสีน้ำตาล',
    '未棕化重量、已棕化重量由化驗人員輸入，系統自動計算。':
        'ผู้วิเคราะห์ป้อนน้ำหนักก่อนและหลังการทำสีน้ำตาล ระบบจะคำนวณอัตโนมัติ',
    '硫酸': 'กรดซัลฟิวริก',
    '雙氧水': 'ไฮโดรเจนเปอร์ออกไซด์',
    '銅離子': 'ไอออนทองแดง',
    '第一槽｜酸洗槽': 'ถังที่ 1｜ถังล้างกรด',
    '第二槽｜清潔槽': 'ถังที่ 2｜ถังทำความสะอาด',
    '第三槽｜預浸槽': 'ถังที่ 3｜ถังพรีดิป',
    '第四槽｜棕化槽': 'ถังที่ 4｜ถังทำสีน้ำตาล',
    '第五槽｜後浸槽': 'ถังที่ 5｜ถังโพสต์ดิป',
    '酸洗槽': 'ถังล้างกรด',
    '鹼洗槽': 'ถังล้างด่าง',
    '活化槽': 'ถังแอคทิเวเตอร์',
    '後浸槽': 'ถังโพสต์ดิป',

    '一般棕化線': 'สายการผลิตบราวนิ่งทั่วไป',
    '濾心及藥水更換頻率': 'ความถี่ในการเปลี่ยนไส้กรองและน้ำยา',
    '各項保養日期': 'วันที่บำรุงรักษาแต่ละรายการ',
    'AB合併化驗': 'วิเคราะห์ร่วม AB',
    'DE合併化驗': 'วิเคราะห์ร่วม DE',
    '合併化驗成果': 'ผลการวิเคราะห์ร่วม',
    '合併化驗資料已儲存至雲端': 'บันทึกข้อมูลการวิเคราะห์ร่วมไปยังคลาวด์แล้ว',
    '合併化驗存檔失敗，請確認網路與 Firebase 權限':
        'บันทึกการวิเคราะห์ร่วมไม่สำเร็จ โปรดตรวจสอบเครือข่ายและสิทธิ์ Firebase',
    '儲存中': 'กำลังบันทึก',
    '儲存合併化驗結果': 'บันทึกผลการวิเคราะห์ร่วม',
    '需添加值': 'ปริมาณที่ต้องเติม',
    '計算公式': 'สูตรการคำนวณ',
    '選擇語言': 'เลือกภาษา',
    '兩條線同時化驗': 'วิเคราะห์สองสายพร้อมกัน',
    '配槽量：': 'ปริมาณผสม: ',

    '槽體積：': 'ปริมาตรถัง: ',
    '公式：(未棕化重量－已棕化重量) ÷ 100 × 21910':
        'สูตร: (น้ำหนักก่อนการทำสีน้ำตาล－น้ำหนักหลังการทำสีน้ำตาล) ÷ 100 × 21910',
    '例如：王小明': 'เช่น: 王小明',
    '請輸入管理者密碼': 'กรุณาป้อนรหัสผ่านผู้ดูแล',
    '輸入管理者密碼': 'ป้อนรหัสผ่านผู้ดูแล',
    '目前尚未建立授權人員': 'ยังไม่มีการสร้างผู้ได้รับอนุญาต',
    '新增授權人員': 'เพิ่มผู้ได้รับอนุญาต',
    '目前沒有記錄': 'ไม่มีบันทึก',

    '槽體積：': 'ปริมาตรถัง: ',
    '今日化驗狀態': 'สถานะการวิเคราะห์วันนี้',
    '今日化驗': 'การวิเคราะห์วันนี้',
    '已完成': 'เสร็จแล้ว',
    '未完成': 'ยังไม่เสร็จ',
    '尚無今日紀錄': 'ยังไม่มีบันทึกวันนี้',
    '最近 7 天化驗趨勢': 'แนวโน้มการวิเคราะห์ 7 วันล่าสุด',
    '化驗趨勢': 'แนวโน้มการวิเคราะห์',
    '流程模式': 'โหมดขั้นตอน',
    '完整模式': 'โหมดเต็ม',
    '第': 'ขั้นตอนที่ ',
    '步': '',
    '下一步': 'ขั้นตอนถัดไป',
    '上一步': 'ขั้นตอนก่อนหน้า',
    '開始化驗': 'เริ่มการวิเคราะห์',
    '檢查結果': 'ตรวจสอบผล',
    '全部完成': 'เสร็จทั้งหมด',
    '目前步驟': 'ขั้นตอนปัจจุบัน',
    '請完成目前步驟後再繼續': 'กรุณาทำขั้นตอนปัจจุบันให้เสร็จก่อนดำเนินการต่อ',
    '輸入值不能為負數': 'ค่าที่ป้อนไม่สามารถติดลบได้',
    '請輸入有效數值': 'กรุณาป้อนค่าตัวเลขที่ถูกต้อง',
    '化驗流程 2.0': 'ขั้นตอนการวิเคราะห์ 2.0',
    '結果總覽': 'ภาพรวมผลลัพธ์',
    '今日狀態': 'สถานะวันนี้',
    '已輸入': 'ป้อนแล้ว',
    '尚未輸入': 'ยังไม่ได้ป้อน',
    '正常': 'ปกติ',
    '異常': 'ผิดปกติ',
    '請確認數值': 'โปรดตรวจสอบค่า',
  };

  return m[text] ?? text;
}

// 儲存資料中的「不用添加」可能來自舊版中文或泰文存檔。
// 顯示時一律依目前系統語言呈現，數值資料不受影響。
String displayStoredAddAmount(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return '';

  // 舊資料可能存中文、新資料可能存代碼；觀看時一律依目前語言顯示。
  if (clean == 'NO_ADD' || clean == '不用添加' || clean == 'ไม่ต้องเติม') {
    return tr('不用添加');
  }

  return clean;
}

class KLFApp extends StatelessWidget {
  KLFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, isThai, __) {
        return MaterialApp(
          key: ValueKey(isThai),
          debugShowCheckedModeBanner: false,
          title: KLFConfig.appName,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6B3F22)),
            scaffoldBackgroundColor: Color(0xFFF5F6F7),
          ),
          home: StartupPage(),
        );
      },
    );
  }
}

class StartupPage extends StatefulWidget {
  StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDevice();
    });
  }

  Future<void> _checkDevice() async {
    final deviceUser = LocalStorageHelper.getDeviceUser();

    if (deviceUser == null || deviceUser.trim().isEmpty) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
      return;
    }

    final cleanName = deviceUser.trim();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(userName: cleanName)),
    );

    // 已記住使用者時也直接進入首頁，最後登入時間背景更新。
    FirebaseUserManager.updateLastLoginInBackground(cleanName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();

  String _errorMessage = '';
  bool _loading = false;

  Future<void> _login() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = tr('請輸入授權名稱');
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final documentId = await FirebaseUserManager.findUserDocumentId(name);

      if (!mounted) return;

      if (documentId != null) {
        LocalStorageHelper.saveDeviceUser(name);

        // 先進入主畫面，最後登入時間在背景更新，不阻塞登入速度。
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(userName: name)),
        );

        // 故意不 await。
        FirebaseUserManager.updateLastLoginInBackground(name);
      } else {
        setState(() {
          _errorMessage = tr('名稱未授權，無法登入');
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = tr('無法連線 Firebase，請確認網路連線');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _openAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminLoginPage()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: LanguageToggleButton(),
                      ),
                      Icon(
                        Icons.science_outlined,
                        size: 70,
                        color: Color(0xFF6B3F22),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'KLF-棕化',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        tr('棕化藥水分析管理系統'),
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 35),
                      TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        enabled: !_loading,
                        decoration: InputDecoration(
                          labelText: tr('授權人員名稱'),
                          hintText: tr('請輸入已授權名稱'),
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(tr('登入'), style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        tr('首次登入需輸入已授權名稱登入'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      if (_errorMessage.isNotEmpty) ...[
                        SizedBox(height: 15),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                      SizedBox(height: 25),
                      TextButton.icon(
                        onPressed: _openAdminLogin,
                        icon: Icon(Icons.admin_panel_settings_outlined),
                        label: Text(tr('管理者登入')),
                      ),
                      SizedBox(height: 10),
                      Text(
                        KLFConfig.version,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminLoginPage extends StatefulWidget {
  AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  void _login() {
    final password = _passwordController.text;

    if (password == KLFConfig.adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminPage()),
      );
    } else {
      setState(() {
        _errorMessage = tr('管理者密碼錯誤');
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('管理者登入'))),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.admin_panel_settings, size: 65),
                    SizedBox(height: 20),
                    Text(
                      tr('管理者登入'),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 25),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: tr('管理者密碼'),
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: Text(tr('登入管理者')),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      SizedBox(height: 15),
                      Text(_errorMessage, style: TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminPage extends StatefulWidget {
  AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _nameController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();

    // 先顯示快取；Firebase 一律背景更新。
    _users = _readCachedUsers();
    _loading = false;

    _loadUsers();
  }

  List<Map<String, dynamic>> _readCachedUsers() {
    final raw = LocalStorageHelper.get(KLFConfig.storageAuthorizedUsers);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map((item) {
            final data = Map<String, dynamic>.from(item);
            final rawTime = data['lastLoginAt'];
            data['lastLoginAt'] = rawTime is String
                ? DateTime.tryParse(rawTime)
                : null;
            return data;
          })
          .where((data) => (data['name'] ?? '').toString().isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _saveCachedUsers(List<Map<String, dynamic>> users) {
    try {
      final serializable = users.map((user) {
        final data = Map<String, dynamic>.from(user);
        final time = data['lastLoginAt'];
        if (time is DateTime) {
          data['lastLoginAt'] = time.toIso8601String();
        }
        return data;
      }).toList();

      LocalStorageHelper.set(
        KLFConfig.storageAuthorizedUsers,
        jsonEncode(serializable),
      );
    } catch (_) {
      // 快取只是加速用途，失敗不影響 Firebase。
    }
  }

  Future<void> _loadUsers() async {
    final hasCachedUsers = _users.isNotEmpty;

    if (mounted) {
      setState(() {
        // 不阻塞管理後台；即使沒有快取也直接顯示頁面。
        _loading = false;
      });
    }

    try {
      final users = await FirebaseUserManager.getUsersWithLoginTime().timeout(
        const Duration(seconds: 8),
      );

      if (!mounted) return;

      if (_users.isNotEmpty) {
        final oldByName = <String, Map<String, dynamic>>{
          for (final oldUser in _users)
            (oldUser['name'] ?? '').toString(): oldUser,
        };

        for (final user in users) {
          final name = (user['name'] ?? '').toString();
          if (user['lastLoginAt'] == null &&
              oldByName[name]?['lastLoginAt'] != null) {
            user['lastLoginAt'] = oldByName[name]!['lastLoginAt'];
          }
        }
      }

      _saveCachedUsers(users);

      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      // 已有快取就保留畫面資料，不顯示無限 loading。
      setState(() {
        _loading = false;
      });

      if (_users.isEmpty) {
        _showMessage(tr('目前無法讀取 Firebase 授權名單，請稍後重新整理'));
      }
    }
  }

  Future<void> _addUser() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage(tr('請輸入授權人員名稱'));
      return;
    }

    setState(() {
      _adding = true;
    });

    try {
      final added = await FirebaseUserManager.addUser(name);

      if (!mounted) return;

      if (!added) {
        _showMessage(tr('這個名稱已經存在'));
        return;
      }

      _nameController.clear();

      await _loadUsers();

      if (!mounted) return;

      _showMessage('${tr('已新增授權人員：')}$name');
    } catch (_) {
      if (!mounted) return;

      _showMessage('新增失敗，請確認 Firebase 連線');
    } finally {
      if (mounted) {
        setState(() {
          _adding = false;
        });
      }
    }
  }

  Future<void> _deleteUser(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(tr('刪除授權人員')),
          content: Text(
            '${tr('確定要刪除「')}$name${tr('」嗎？\n\n')}${tr('刪除後所有裝置都將無法再使用此名稱登入。')}',
          ),
          actions: [
            LanguageToggleButton(),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr('取消')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(tr('刪除')),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await FirebaseUserManager.deleteUser(name);

      if (!mounted) return;

      await _loadUsers();

      if (!mounted) return;

      _showMessage('${tr('已刪除：')}$name');
    } catch (_) {
      if (!mounted) return;

      _showMessage('刪除失敗，請確認 Firebase 連線');
    }
  }

  void _clearCurrentDevice() {
    LocalStorageHelper.clearDeviceUser();
    _showMessage(tr('本設備登入記錄已清除'));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('管理者設定')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          LanguageToggleButton(),
          IconButton(
            tooltip: tr('重新整理'),
            icon: Icon(Icons.refresh),
            onPressed: _loading ? null : _loadUsers,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (_users.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Text(tr('目前沒有可顯示的授權人員資料'), textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadUsers,
                          child: Text(tr('重新讀取')),
                        ),
                      ],
                    ),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('新增授權人員'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        tr('新增後會同步到 Firebase，其他手機也可以使用。'),
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              enabled: !_adding,
                              onSubmitted: (_) => _addUser(),
                              decoration: InputDecoration(
                                labelText: tr('授權人員名稱'),
                                hintText: tr('例如：王小明'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _adding ? null : _addUser,
                              icon: _adding
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.add),
                              label: Text(tr('新增')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tr('已授權人員'),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_loading)
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      SizedBox(height: 15),
                      if (!_loading && _users.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              tr('目前尚未建立授權人員'),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ..._users.map((user) {
                        final name = (user['name'] ?? '').toString();
                        final lastLoginAt = user['lastLoginAt'];

                        String loginText;
                        if (lastLoginAt is DateTime) {
                          final local = lastLoginAt.toLocal();
                          final y = local.year.toString().padLeft(4, '0');
                          final m = local.month.toString().padLeft(2, '0');
                          final d = local.day.toString().padLeft(2, '0');
                          final h = local.hour.toString().padLeft(2, '0');
                          final min = local.minute.toString().padLeft(2, '0');
                          loginText = '${tr('最後登入：')}$y-$m-$d $h:$min';
                        } else {
                          loginText = tr('尚未登入');
                        }

                        return ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('Firebase 雲端授權'),
                                style: TextStyle(color: Colors.green),
                              ),
                              Text(
                                loginText,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              _deleteUser(name);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: Icon(Icons.devices),
                  title: Text(tr('本設備登入記錄')),
                  subtitle: Text(
                    LocalStorageHelper.getDeviceUser() ?? tr('目前沒有記錄'),
                  ),
                  trailing: TextButton(
                    onPressed: _clearCurrentDevice,
                    child: Text(tr('清除')),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: Icon(Icons.cloud_done, color: Colors.green),
                  title: Text(tr('授權資料來源')),
                  subtitle: Text('Firebase Cloud Firestore'),
                  trailing: Text(tr('雲端同步')),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(tr('系統版本')),
                  trailing: Text(KLFConfig.version),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BathRatioLinePage extends StatelessWidget {
  final String userName;

  const BathRatioLinePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B2714),
        foregroundColor: Colors.white,
        title: Text(
          tr('各線藥水建浴比例'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [LanguageToggleButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    tr('請選擇生產線'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4B2714),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.6,
                      children: [
                        _lineCard(context, 'A線', '一般棕化線', true),
                        _lineCard(context, 'B線', '一般棕化線', true),
                        _lineCard(context, 'C線', '待開發', false),
                        _lineCard(context, 'D線', 'VS棕化線', true),
                        _lineCard(context, 'E線', 'VS棕化線', true),
                        _lineCard(context, 'F線', '待開發', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lineCard(
    BuildContext context,
    String lineName,
    String subtitle,
    bool enabled,
  ) {
    final colors = <String, Color>{
      'A線': const Color(0xFF2F6FC4),
      'B線': const Color(0xFF3B963D),
      'C線': const Color(0xFFE97816),
      'D線': const Color(0xFF6B43A4),
      'E線': const Color(0xFF2C8D89),
      'F線': const Color(0xFFD93636),
    };

    final accent = colors[lineName] ?? const Color(0xFF6B3F22);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BathRatioPage(lineName: lineName, userName: userName),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  lineName.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(lineName),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: enabled ? accent : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(subtitle),
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled ? Colors.grey.shade700 : Colors.orange,
                        fontWeight: enabled
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.arrow_forward_ios : Icons.lock_outline,
                size: 16,
                color: enabled ? accent : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BathRatioPage extends StatelessWidget {
  final String lineName;
  final String userName;

  const BathRatioPage({
    super.key,
    required this.lineName,
    required this.userName,
  });

  List<Map<String, dynamic>> _tanks() {
    switch (lineName) {
      case 'A線':
        return [
          {
            'tank': '第一槽｜酸洗槽',
            'volume': 500,
            'chemicals': [
              {'name': '硫酸', 'bath': '50% H₂SO₄：120 L'},
              {'name': '雙氧水', 'bath': 'H₂O₂：2.5 L'},
            ],
          },
          {
            'tank': '第二槽｜清潔槽',
            'volume': 800,
            'chemicals': [
              {'name': 'HL-II', 'bath': 'HL II：60 L'},
            ],
          },
          {
            'tank': '第三槽｜預浸槽',
            'volume': 700,
            'chemicals': [
              {'name': 'CBBA-A', 'bath': 'Cbb A：10 L'},
              {'name': '雙氧水', 'bath': '35% H₂O₂：12 L'},
            ],
          },
          {
            'tank': '第四槽｜棕化槽',
            'volume': 1300,
            'chemicals': [
              {'name': 'CBBA-A', 'bath': 'Cbb A：50 L'},
              {'name': 'CBBA-B', 'bath': 'Cbb B：50 L'},
              {'name': '雙氧水', 'bath': 'H₂O₂：40 L'},
              {'name': '硫酸', 'bath': '50% H₂SO₄：140 L'},
            ],
          },
        ];
      case 'B線':
        return [
          {
            'tank': '第一槽｜酸洗槽',
            'volume': 246,
            'chemicals': [
              {'name': '硫酸', 'bath': '50% H₂SO₄：85 L'},
              {'name': '雙氧水', 'bath': 'H₂O₂：1.3 L'},
            ],
          },
          {
            'tank': '第二槽｜清潔槽',
            'volume': 582,
            'chemicals': [
              {'name': 'HL-II', 'bath': 'HL II：40 L'},
            ],
          },
          {
            'tank': '第三槽｜預浸槽',
            'volume': 440,
            'chemicals': [
              {'name': 'CBBA-A', 'bath': 'Cbb A：11 L'},
              {'name': '雙氧水', 'bath': '35% H₂O₂：7 L'},
            ],
          },
          {
            'tank': '第四槽｜棕化槽',
            'volume': 1560,
            'chemicals': [
              {'name': 'CBBA-A', 'bath': 'Cbb A：86 L'},
              {'name': 'CBBA-B', 'bath': 'Cbb B：78 L'},
              {'name': '雙氧水', 'bath': 'H₂O₂：59 L'},
              {'name': '硫酸', 'bath': '50% H₂SO₄：180 L'},
            ],
          },
        ];
      case 'D線':
        return [
          {
            'tank': '第一槽｜酸洗槽',
            'volume': 470,
            'chemicals': [
              {'name': '硫酸', 'bath': '50% H₂SO₄：117.5 L'},
            ],
          },
          {
            'tank': '第二槽｜鹼洗槽',
            'volume': 450,
            'chemicals': [
              {'name': 'ALK', 'bath': 'ALK：54 L'},
            ],
          },
          {
            'tank': '第三槽｜活化槽',
            'volume': 300,
            'chemicals': [
              {'name': 'Bondfilm Activator', 'bath': 'Activator：6 L'},
            ],
          },
          {
            'tank': '第四槽｜棕化槽',
            'volume': 1350,
            'chemicals': [
              {'name': 'HF1000', 'bath': 'HF1000：87.8 L'},
              {'name': '雙氧水', 'bath': 'H₂O₂：56.7 L'},
              {'name': '硫酸', 'bath': '50% H₂SO₄：156.6 L'},
            ],
          },
          {
            'tank': '第五槽｜後浸槽',
            'volume': 445,
            'chemicals': [
              {'name': 'VS', 'bath': 'VS Promotor：45 L'},
              {'name': '硫酸', 'bath': '50% H₂SO₄：45 L'},
            ],
          },
        ];
      case 'E線':
        return [
          {
            'tank': '第一槽｜酸洗槽',
            'volume': 420,
            'chemicals': [
              {'name': '硫酸', 'bath': '50% H₂SO₄：105 L'},
            ],
          },
          {
            'tank': '第二槽｜鹼洗槽',
            'volume': 390,
            'chemicals': [
              {'name': 'ALK', 'bath': 'ALK：47 L'},
            ],
          },
          {
            'tank': '第三槽｜活化槽',
            'volume': 450,
            'chemicals': [
              {'name': 'Bondfilm Activator', 'bath': 'Activator：10 L'},
            ],
          },
          {
            'tank': '第四槽｜棕化槽',
            'volume': 1200,
            'chemicals': [
              {'name': 'HF1000', 'bath': 'HF1000：78 L'},
              {'name': '雙氧水', 'bath': 'H₂O₂：54 L'},
              {'name': '硫酸', 'bath': '50% H₂SO₄：140 L'},
            ],
          },
          {
            'tank': '第五槽｜後浸槽',
            'volume': 580,
            'chemicals': [
              {'name': 'VS', 'bath': 'VS Promotor：58 L'},
              {'name': '硫酸', 'bath': '50% H₂SO₄：58 L'},
            ],
          },
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tanks = _tanks();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B2714),
        foregroundColor: Colors.white,
        title: Text(
          '$lineName｜${tr('藥水建浴比例')}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [LanguageToggleButton()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      color: Color(0xFFE68A17),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr('各槽實際建浴／配槽量'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...tanks.map(
              (tank) => _buildTankBlock(
                context,
                tank['tank'] as String,
                tank['volume'] as int,
                List<Map<String, dynamic>>.from(
                  (tank['chemicals'] as List).map(
                    (e) => Map<String, dynamic>.from(e as Map),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTankBlock(
    BuildContext context,
    String tankName,
    int volume,
    List<Map<String, dynamic>> chemicals,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE68A17),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    tr(tankName),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4B2714),
                    ),
                  ),
                ),
                Text(
                  '${tr('槽體積：')}$volume L',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            ...chemicals.map(
              (chemical) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.water_drop_outlined,
                      size: 18,
                      color: Color(0xFFE68A17),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(chemical['name'] as String),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chemical['bath'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE68A17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CombinedAnalysisPage extends StatefulWidget {
  final String userName;
  final String mergeType;
  final String? recordId;
  final Map<String, dynamic>? initialRecord;
  final bool adminMode;

  const CombinedAnalysisPage({
    super.key,
    required this.userName,
    required this.mergeType,
    this.recordId,
    this.initialRecord,
    this.adminMode = false,
  });

  bool get isEditing => recordId != null && initialRecord != null;

  @override
  State<CombinedAnalysisPage> createState() => _CombinedAnalysisPageState();
}

class _CombinedAnalysisPageState extends State<CombinedAnalysisPage> {
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  bool get isAB => widget.mergeType == 'AB合併化驗';
  String get leftLine => isAB ? 'A線' : 'D線';
  String get rightLine => isAB ? 'B線' : 'E線';
  String get resultType => isAB ? 'AB合併化驗' : 'DE合併化驗';

  @override
  void initState() {
    super.initState();

    final record = widget.initialRecord;
    if (record != null) {
      final allChemicals = Map<String, dynamic>.from(record['chemicals'] ?? {});
      for (final line in [leftLine, rightLine]) {
        final chemicals = Map<String, dynamic>.from(allChemicals[line] ?? {});
        for (final entry in chemicals.entries) {
          final data = Map<String, dynamic>.from(entry.value ?? {});
          _controller('$line|${entry.key}').text =
              data['input']?.toString() ?? '';
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(String key) =>
      _controllers.putIfAbsent(key, () => TextEditingController());

  double? _parse(String value) => double.tryParse(value.trim());

  bool _isVS(String line) => line == 'D線' || line == 'E線';

  double? _concentration(String line, String key, String value) {
    final setting = getSettings(line)[key];
    if (setting == null) return null;
    final number = _parse(value);
    if (number == null) return null;

    if (_isVS(line)) {
      if (key == 'brown_copper') {
        return roundToTenth(number * 3.177);
      }
      if (key == 'brown_hf1000') {
        final copperInput = _parse(_controller('$line|brown_copper').text);
        if (copperInput == null) return null;
        final copperConcentration = copperInput * 3.177;
        final a = number / 0.544 * 6.5;
        final b = copperConcentration * 0.078;
        return roundToTenth(a - b);
      }
      if (key == 'post_vs') {
        return roundToTenth((number + 0.0067) / 0.1392 * 2.5);
      }
      if (key == 'vs_activator') {
        return roundToTenth(number / 0.538 * 2);
      }
      if (key == 'acid_sulfuric' ||
          key == 'brown_sulfuric' ||
          key == 'post_sulfuric') {
        return roundToTenth(number * 0.702);
      }
      if (key == 'brown_h2o2') {
        return roundToTenth(number * 0.49);
      }
      if (key == 'vs_alk') {
        return roundToTenth(number * 0.5);
      }
    }

    if (setting.direct) return roundToTenth(number);
    return roundToTenth(number * setting.factor);
  }

  double? _addAmount(String line, String key, String value) {
    final setting = getSettings(line)[key];
    if (setting == null || setting.middle == null) return null;

    final current = _concentration(line, key, value);
    if (current == null) return null;

    final middle = roundToTenth(setting.middle!);
    final actual = roundToTenth(current);
    if (actual >= middle) return 0;

    final deficit = roundToTenth(middle - actual);
    final steps = (deficit * 10).round();
    if (steps <= 0) return 0;

    if (_isVS(line)) {
      final tank = getTankInfo(line).firstWhere(
        (t) => t.keys.contains(key),
        orElse: () => TankInfo(name: '', description: '', volume: 0, keys: []),
      );
      final perPoint = tank.volume > 1000
          ? 1.5
          : tank.volume > 500
          ? 1.0
          : 0.5;
      return (steps * perPoint).roundToDouble();
    }

    if (setting.addPerPoint <= 0) return null;

    if (key == 'pre_cbba') {
      final perPoint = line == 'A線' ? 1.0 : 0.5;
      return roundToTenth(steps * perPoint);
    }

    return roundToTenth(steps * setting.addPerPoint);
  }

  String _displayMiddle(String line, String key) {
    final setting = getSettings(line)[key];
    if (setting == null) return '-';
    if (setting.middle == null) return tr('無中值');
    return formatNumber(roundToTenth(setting.middle!));
  }

  String _displayConcentration(String line, String key) {
    final value = _controller('$line|$key').text;
    final result = _concentration(line, key, value);
    return result == null ? '-' : formatNumber(result);
  }

  String _displayAddAmount(String line, String key) {
    final setting = getSettings(line)[key];
    if (setting == null || setting.middle == null) return '-';
    final amount = _addAmount(line, key, _controller('$line|$key').text);
    if (amount == null) return '-';
    if (amount <= 0) return tr('不用添加');
    return _isVS(line)
        ? '${amount.toInt()} ${setting.unit}'
        : '${formatNumber(amount)} ${setting.unit}';
  }

  List<Map<String, dynamic>> _tanks(String line) {
    if (line == 'A線' || line == 'B線') {
      final isA = line == 'A線';
      return [
        {
          'tank': '第一槽｜酸洗槽',
          'volume': isA ? 500 : 246,
          'keys': ['acid_sulfuric', 'acid_h2o2'],
        },
        {
          'tank': '第二槽｜清潔槽',
          'volume': isA ? 800 : 582,
          'keys': ['clean_hl2'],
        },
        {
          'tank': '第三槽｜預浸槽',
          'volume': isA ? 700 : 440,
          'keys': ['pre_h2o2', 'pre_cbba'],
        },
        {
          'tank': '第四槽｜棕化槽',
          'volume': isA ? 1400 : 1560,
          'keys': [
            'brown_sulfuric',
            'brown_h2o2',
            'brown_cbba',
            'brown_copper',
          ],
        },
      ];
    }

    final isD = line == 'D線';
    return [
      {
        'tank': '第一槽｜酸洗槽',
        'volume': isD ? 470 : 420,
        'keys': ['acid_sulfuric'],
      },
      {
        'tank': '第二槽｜鹼洗槽',
        'volume': isD ? 450 : 390,
        'keys': ['vs_alk'],
      },
      {
        'tank': '第三槽｜活化槽',
        'volume': isD ? 300 : 450,
        'keys': ['vs_activator'],
      },
      {
        'tank': '第四槽｜棕化槽',
        'volume': isD ? 1200 : 1200,
        'keys': [
          'brown_hf1000',
          'brown_sulfuric',
          'brown_h2o2',
          'brown_copper',
        ],
      },
      {
        'tank': '第五槽｜後浸槽',
        'volume': isD ? 445 : 580,
        'keys': ['post_sulfuric', 'post_vs'],
      },
    ];
  }

  Future<void> _confirmAndSaveCombined() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('確認合併化驗存檔')),
        content: Text(tr('確認 A/B 或 D/E 兩條線的化驗結果都正確，並一起存檔嗎？')),
        actions: [
          LanguageToggleButton(),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('取消')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('確認存檔')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _saveCombined();
    }
  }

  Future<void> _saveCombined() async {
    if (_saving) return;
    setState(() => _saving = true);

    Map<String, dynamic> collect(String line) {
      final chemicals = <String, dynamic>{};
      for (final tank in _tanks(line)) {
        for (final key in List<String>.from(tank['keys'] as List)) {
          final controller = _controller('$line|$key');
          final setting = getSettings(line)[key];
          final concentration = _concentration(line, key, controller.text);
          final add = _addAmount(line, key, controller.text);
          chemicals[key] = {
            'input': controller.text.trim(),
            'concentration': concentration == null
                ? ''
                : formatNumber(concentration),
            'addAmountValue': add,
            'addAmountNoNeed': add != null && add <= 0,
            'addAmount': add == null
                ? ''
                : add <= 0
                ? 'NO_ADD'
                : '${formatNumber(add)} ${setting?.unit ?? 'L'}',
            'tank': tank['tank'],
          };
        }
      }
      return chemicals;
    }

    if (widget.isEditing && !widget.adminMode) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr('只有管理者可以修改化驗紀錄'))));
      }
      setState(() => _saving = false);
      return;
    }

    final originalUser = widget.initialRecord?['user']?.toString().trim();

    final record = <String, dynamic>{
      'line': resultType,
      'mergeType': resultType,
      'leftLine': leftLine,
      'rightLine': rightLine,
      // 修改既有紀錄時，永遠保留原本化驗人員。
      'user':
          widget.isEditing && originalUser != null && originalUser.isNotEmpty
          ? originalUser
          : widget.userName,
      'recordType': 'combined',
      'chemicals': {leftLine: collect(leftLine), rightLine: collect(rightLine)},
    };

    try {
      if (widget.isEditing) {
        await FirebaseAnalysisManager.updateRecord(widget.recordId!, record);
      } else {
        await FirebaseAnalysisManager.addRecord(record);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? tr('修改已儲存至雲端') : tr('合併化驗資料已儲存至雲端')),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (widget.isEditing) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('合併化驗存檔失敗，請確認網路與 Firebase 權限')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !widget.adminMode) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('化驗結果'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              tr('只有管理者可以修改化驗紀錄'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B2714),
        foregroundColor: Colors.white,
        title: Text(
          tr(resultType),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [LanguageToggleButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildLineColumn(leftLine)),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: isAB ? 900 : 1100,
                    color: Colors.brown.shade200,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildLineColumn(rightLine)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _confirmAndSaveCombined,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? tr('儲存中') : tr('儲存合併化驗結果')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  leftLine,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isAB
                        ? const Color(0xFF2F6FC4)
                        : const Color(0xFF6B43A4),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF4B2714),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tr(resultType),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  rightLine,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isAB
                        ? const Color(0xFF3B963D)
                        : const Color(0xFF2C8D89),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineColumn(String line) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _tanks(line)
          .map(
            (tank) => _buildTankBlock(
              line,
              tank['tank'] as String,
              tank['volume'] as int,
              List<String>.from(tank['keys'] as List),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTankBlock(
    String line,
    String tankName,
    int volume,
    List<String> keys,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(tankName),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4B2714),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${tr('槽體積：')}$volume L',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
            const Divider(height: 10),
            ...keys.map((key) {
              final setting = getSettings(line)[key];
              if (setting == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(setting.name),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${tr('中值')}：${_displayMiddle(line, key)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 3),
                      TextField(
                        controller: _controller('$line|$key'),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText:
                              (key == 'brown_hf1000' ||
                                  key == 'post_vs' ||
                                  key == 'vs_activator' ||
                                  key == 'brown_cbba' ||
                                  key == 'pre_cbba')
                              ? tr('分析值')
                              : tr('滴定值'),
                          hintText:
                              ((line == 'D線' || line == 'E線') &&
                                  (key == 'brown_hf1000' ||
                                      key == 'post_vs' ||
                                      key == 'vs_activator'))
                              ? tr('分析值')
                              : tr('滴定值'),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tr('濃度')}：${_displayConcentration(line, key)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Builder(
                        builder: (_) {
                          final addText = _displayAddAmount(line, key);
                          Color? addColor;

                          if (addText == tr('不用添加')) {
                            addColor = Colors.green;
                          } else if (addText != '-') {
                            addColor = Colors.red;
                          }

                          return Text(
                            '${tr('需添加值')}：$addText',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: addColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class DailyAnalysisStatusPanel extends StatefulWidget {
  final String userName;
  const DailyAnalysisStatusPanel({super.key, required this.userName});

  @override
  State<DailyAnalysisStatusPanel> createState() =>
      _DailyAnalysisStatusPanelState();
}

class _DailyAnalysisStatusPanelState extends State<DailyAnalysisStatusPanel> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  final List<String> _lines = const ['A線', 'B線', 'D線', 'E線'];

  @override
  void initState() {
    super.initState();
    _records = LocalStorageHelper.getRecords();
    _loading = false;
    _load();
  }

  Future<void> _load() async {
    try {
      final records = await FirebaseAnalysisManager.getRecords().timeout(
        const Duration(seconds: 6),
      );
      if (!mounted) return;
      setState(() {
        _records = records;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _hasToday(String line) {
    final now = DateTime.now();
    return _records.any((r) {
      final recordLine = r['line']?.toString() ?? '';
      final merge = r['mergeType']?.toString() ?? '';
      final time = DateTime.tryParse(r['time']?.toString() ?? '');
      if (time == null) return false;
      final sameDay =
          time.toLocal().year == now.year &&
          time.toLocal().month == now.month &&
          time.toLocal().day == now.day;
      return sameDay && (recordLine == line || merge == line);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 650;
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(mobile ? 10 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined, color: Color(0xFF4B2714)),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    tr('今日化驗狀態'),
                    style: TextStyle(
                      fontSize: mobile ? 16 : 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (_loading)
                  const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 9),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: mobile ? 2 : 4,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
              childAspectRatio: mobile ? 3.1 : 3.0,
              children: _lines.map((line) {
                final done = _hasToday(line);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: done
                        ? Colors.green.withOpacity(.10)
                        : Colors.orange.withOpacity(.08),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: done
                          ? Colors.green.withOpacity(.25)
                          : Colors.orange.withOpacity(.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        done ? Icons.check_circle : Icons.schedule,
                        size: 18,
                        color: done ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tr(line),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        done ? tr('已完成') : tr('未完成'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: done ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String userName;

  HomePage({super.key, required this.userName});

  void showWebsiteQrCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.qr_code_2),
              SizedBox(width: 10),
              Text(tr('KLF-棕化網站 QR Code')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('使用手機掃描 QR Code 即可開啟 KLF-棕化網站'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  color: Colors.white,
                  child: QrImageView(
                    data: KLFConfig.websiteUrl,
                    version: QrVersions.auto,
                    size: 250,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  tr('掃描後仍需使用已授權名稱登入'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            LanguageToggleButton(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('關閉')),
            ),
          ],
        );
      },
    );
  }

  void openAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminLoginPage()),
    );
  }

  void openRecords(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecordsPage(userName: userName)),
    );
  }

  void openBathRatio(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BathRatioLinePage(userName: userName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color(0xFF4B2714),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Text(
              'KLF-棕化',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 21,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Container(width: 1, height: 25, color: Colors.white54),
            SizedBox(width: 10),
            Text(
              KLFConfig.version,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: tr('管理者'),
            icon: Icon(Icons.admin_panel_settings_outlined, size: 21),
            onPressed: () => openAdmin(context),
          ),
          IconButton(
            tooltip: tr('邀請開啟網站'),
            icon: Icon(Icons.qr_code_2, size: 21),
            onPressed: () => showWebsiteQrCode(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: Center(
              child: Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 650;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1120),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 10 : 28,
                    isMobile ? 10 : 22,
                    isMobile ? 10 : 28,
                    isMobile ? 10 : 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHomeTitle(isMobile),
                      SizedBox(height: isMobile ? 9 : 18),
                      DailyAnalysisStatusPanel(userName: userName),
                      SizedBox(height: isMobile ? 10 : 16),

                      _buildLineGroup(
                        context,
                        title: '一般棕化線',
                        subtitle: 'A線、B線、C線',
                        accent: Color(0xFF2F6FC4),
                        lines: [
                          _LineInfo('A線', '棕化水平生產線 A', true, Color(0xFF2F6FC4)),
                          _LineInfo('B線', '棕化水平生產線 B', true, Color(0xFF3B963D)),
                          _LineInfo('C線', '待開發', false, Color(0xFFE97816)),
                        ],
                        mergeLabel: 'AB合併化驗',
                        isMobile: isMobile,
                      ),

                      SizedBox(height: isMobile ? 12 : 18),

                      _buildLineGroup(
                        context,
                        title: 'VS棕化線',
                        subtitle: 'D線、E線、F線',
                        accent: Color(0xFF6B43A4),
                        lines: [
                          _LineInfo('D線', 'VS棕化線', true, Color(0xFF6B43A4)),
                          _LineInfo('E線', 'VS棕化線', true, Color(0xFF2C8D89)),
                          _LineInfo('F線', '待開發', false, Color(0xFFD93636)),
                        ],
                        mergeLabel: 'DE合併化驗',
                        isMobile: isMobile,
                      ),

                      SizedBox(height: isMobile ? 14 : 22),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.brown.shade300),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.science_outlined,
                                  size: isMobile ? 18 : 22,
                                  color: Color(0xFF6B3F22),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  tr('生產線相關功能'),
                                  style: TextStyle(
                                    fontSize: isMobile ? 17 : 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4B2714),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.brown.shade300),
                          ),
                        ],
                      ),

                      SizedBox(height: isMobile ? 8 : 12),

                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: isMobile ? 7 : 14,
                        mainAxisSpacing: isMobile ? 7 : 14,
                        childAspectRatio: isMobile ? 1.75 : 2.45,
                        children: [
                          _buildFeatureCard(
                            context,
                            title: '化驗結果',
                            subtitle: '查看、搜尋、修改歷史化驗結果',
                            icon: Icons.assignment_outlined,
                            accent: Color(0xFF2F6FB3),
                            enabled: true,
                            mobile: isMobile,
                            onTap: () => openRecords(context),
                          ),
                          _buildFeatureCard(
                            context,
                            title: '各線藥水建浴比例',
                            subtitle: '各線藥水建浴比例規劃',
                            icon: Icons.science_outlined,
                            accent: Color(0xFFE68A17),
                            enabled: true,
                            mobile: isMobile,
                            onTap: () => openBathRatio(context),
                          ),
                          _buildFeatureCard(
                            context,
                            title: '濾心及藥水更換頻率',
                            subtitle: '管理濾心與藥水更換頻率',
                            icon: Icons.filter_alt_outlined,
                            accent: Color(0xFF3B8F48),
                            enabled: false,
                            mobile: isMobile,
                          ),
                          _buildFeatureCard(
                            context,
                            title: '各項保養日期',
                            subtitle: '管理各項設備與製程保養日期',
                            icon: Icons.calendar_month_outlined,
                            accent: Color(0xFF7A4AA8),
                            enabled: false,
                            mobile: isMobile,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeTitle(bool mobile) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.brown.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                tr('生產線選擇'),
                style: TextStyle(
                  fontSize: mobile ? 24 : 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4B2714),
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.brown.shade300)),
          ],
        ),
        SizedBox(height: 2),
        Text(
          tr('請選擇生產線進行藥水分析'),
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: mobile ? 11 : 15,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: mobile ? 8 : 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr('選擇語言'),
              style: TextStyle(
                fontSize: mobile ? 12 : 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B3F22),
              ),
            ),
            SizedBox(width: 8),
            LanguageToggleButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildLineGroup(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color accent,
    required List<_LineInfo> lines,
    required String mergeLabel,
    required bool isMobile,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withOpacity(0.25)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 9 : 16,
          isMobile ? 10 : 14,
          isMobile ? 9 : 16,
          isMobile ? 10 : 14,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(title),
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.w900,
                          color: accent,
                        ),
                      ),
                      Text(
                        tr(subtitle),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: isMobile ? 7 : 12,
              mainAxisSpacing: isMobile ? 7 : 10,
              childAspectRatio: isMobile ? 2.35 : 2.8,
              children: [
                ...lines.map(
                  (line) => _buildStyledLineCard(
                    context,
                    line.name,
                    line.subtitle,
                    enabled: line.enabled,
                    accent: line.color,
                    letterColor: line.color,
                  ),
                ),
                _buildMergeCard(context, mergeLabel, accent, isMobile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledLineCard(
    BuildContext context,
    String lineName,
    String subtitle, {
    required bool enabled,
    required Color accent,
    required Color letterColor,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: accent.withOpacity(0.28)),
      ),
      child: InkWell(
        onTap: enabled
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AnalysisPage(lineName: lineName, userName: userName),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: letterColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  lineName.substring(0, 1),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(lineName),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: enabled ? accent : Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      tr(subtitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: enabled
                            ? Colors.grey.shade700
                            : Colors.orange.shade700,
                        fontWeight: enabled
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            enabled ? tr('進入化驗') : tr('待開發'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: enabled ? accent : Colors.grey,
                            ),
                          ),
                        ),
                        Icon(
                          enabled
                              ? Icons.arrow_forward_ios
                              : Icons.lock_outline,
                          size: 14,
                          color: enabled ? accent : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMergeCard(
    BuildContext context,
    String mergeLabel,
    Color accent,
    bool mobile,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: accent.withOpacity(0.30)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CombinedAnalysisPage(
                userName: userName,
                mergeType: mergeLabel,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 8 : 12,
            vertical: mobile ? 7 : 10,
          ),
          child: Row(
            children: [
              Container(
                width: mobile ? 40 : 48,
                height: mobile ? 40 : 48,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.compare_arrows,
                  size: mobile ? 22 : 27,
                  color: accent,
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(mergeLabel),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: mobile ? 12 : 17,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      tr('兩條線同時化驗'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: mobile ? 9 : 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required bool enabled,
    required bool mobile,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withOpacity(0.30)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 7 : 14,
            vertical: mobile ? 7 : 14,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: mobile ? 40 : 68,
                height: mobile ? 40 : 68,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: mobile ? 22 : 36, color: accent),
              ),
              SizedBox(height: mobile ? 5 : 10),
              Text(
                tr(title),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: mobile ? 12 : 20,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
              if (!mobile) ...[
                SizedBox(height: 6),
                Text(
                  tr(subtitle),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
              SizedBox(height: mobile ? 4 : 10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: mobile ? 9 : 20,
                  vertical: mobile ? 3 : 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent),
                ),
                child: Text(
                  tr(enabled ? '進入查看' : '待開發'),
                  style: TextStyle(
                    fontSize: mobile ? 9 : 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineInfo {
  final String name;
  final String subtitle;
  final bool enabled;
  final Color color;
  final String? mergeLabel;

  const _LineInfo(
    this.name,
    this.subtitle,
    this.enabled,
    this.color, {
    this.mergeLabel,
  });
}

class ChemicalSetting {
  final String name;
  final double? middle;
  final double factor;
  final bool direct;
  final double addPerPoint;
  final String unit;

  ChemicalSetting({
    required this.name,
    required this.middle,
    required this.factor,
    required this.direct,
    required this.addPerPoint,
    required this.unit,
  });
}

Map<String, ChemicalSetting> getSettings(String line) {
  final bool isA = line == 'A線';
  final bool isB = line == 'B線';
  final bool isVS = line == 'D線' || line == 'E線';

  if (isVS) {
    return {
      'acid_sulfuric': ChemicalSetting(
        name: '硫酸',
        middle: 25.0,
        factor: 0.702,
        direct: false,
        addPerPoint: 0,
        unit: 'L',
      ),
      'vs_alk': ChemicalSetting(
        name: 'ALK',
        middle: 12.0,
        factor: 0.5,
        direct: false,
        addPerPoint: 0,
        unit: 'L',
      ),
      'vs_activator': ChemicalSetting(
        name: 'Bondfilm Activator',
        middle: 2.0,
        factor: 1.0,
        direct: false,
        addPerPoint: 0,
        unit: 'L',
      ),
      'brown_hf1000': ChemicalSetting(
        name: 'HF1000',
        middle: 6.5,
        factor: 1.0,
        direct: false,
        addPerPoint: 0,
        unit: 'L',
      ),
      'brown_sulfuric': ChemicalSetting(
        name: '硫酸',
        middle: 12.5,
        factor: 0.702,
        direct: false,
        addPerPoint: 0,
        unit: 'L',
      ),
      'brown_h2o2': ChemicalSetting(
        name: '雙氧水',
        middle: 4.2,
        factor: 0.49,
        direct: false,
        addPerPoint: 0,
        unit: 'L',
      ),
      'brown_copper': ChemicalSetting(
        name: '銅離子',
        middle: null,
        factor: 3.177,
        direct: false,
        addPerPoint: 0,
        unit: '',
      ),
      'post_sulfuric': ChemicalSetting(
        name: '硫酸',
        middle: 10.0,
        factor: 0.702,
        direct: false,
        addPerPoint: 0,
        unit: 'L',
      ),
      'post_vs': ChemicalSetting(
        name: 'VS',
        middle: 10.0,
        factor: 1.0,
        direct: false,
        addPerPoint: 0,
        unit: 'L',
      ),
    };
  }

  return {
    'acid_sulfuric': ChemicalSetting(
      name: '硫酸',
      middle: 10.0,
      factor: 2.8,
      direct: false,
      addPerPoint: isA ? 1.0 : 0.5,
      unit: 'L',
    ),
    'acid_h2o2': ChemicalSetting(
      name: '雙氧水',
      middle: 0.5,
      factor: 0.47,
      direct: false,
      addPerPoint: 0.5,
      unit: 'L',
    ),
    'clean_hl2': ChemicalSetting(
      name: 'HL-II',
      middle: isA ? 7.0 : 7.0,
      factor: 0.52,
      direct: false,
      addPerPoint: isA ? 1.0 : 0.5,
      unit: 'L',
    ),
    'pre_h2o2': ChemicalSetting(
      name: '雙氧水',
      middle: isA ? 2.0 : 1.5,
      factor: 0.47,
      direct: false,
      addPerPoint: isA ? 1.0 : 0.5,
      unit: 'L',
    ),
    'pre_cbba': ChemicalSetting(
      name: 'CBBA-A',
      middle: isA ? 1.5 : 2.5,
      factor: 1.0,
      direct: true,
      addPerPoint: isA ? 1.0 : 0.5,
      unit: 'L',
    ),
    'brown_sulfuric': ChemicalSetting(
      name: '硫酸',
      middle: isA ? 5.6 : 5.4,
      factor: 0.56,
      direct: false,
      addPerPoint: 3.0,
      unit: 'L',
    ),
    'brown_h2o2': ChemicalSetting(
      name: '雙氧水',
      middle: isA ? 3.4 : 3.5,
      factor: 0.47,
      direct: false,
      addPerPoint: 1.5,
      unit: 'L',
    ),
    'brown_cbba': ChemicalSetting(
      name: 'CBBA-A',
      middle: isA ? 4.8 : 5.5,
      factor: 1.0,
      direct: true,
      addPerPoint: 1.5,
      unit: 'L',
    ),
    'brown_copper': ChemicalSetting(
      name: '銅離子',
      middle: null,
      factor: 3.177,
      direct: false,
      addPerPoint: 0,
      unit: '',
    ),
  };
}

double roundToTenth(double value) {
  return (value * 10).round() / 10;
}

String formatNumber(double value) {
  return value.toStringAsFixed(1);
}

// ============================================================
// 槽體積
// ============================================================

class TankInfo {
  final String name;
  final String description;
  final double volume;
  final List<String> keys;

  TankInfo({
    required this.name,
    required this.description,
    required this.volume,
    required this.keys,
  });
}

List<TankInfo> getTankInfo(String line) {
  final bool isA = line == 'A線';

  if (line == 'D線') {
    return [
      TankInfo(
        name: tr('第一槽｜酸洗槽'),
        description: tr('硫酸'),
        volume: 470,
        keys: const ['acid_sulfuric'],
      ),
      TankInfo(
        name: tr('第二槽｜鹼洗槽'),
        description: 'ALK',
        volume: 450,
        keys: const ['vs_alk'],
      ),
      TankInfo(
        name: tr('第三槽｜活化槽'),
        description: 'Bondfilm Activator',
        volume: 300,
        keys: const ['vs_activator'],
      ),
      TankInfo(
        name: tr('第四槽｜棕化槽'),
        description: tr('HF1000、硫酸、雙氧水、銅離子'),
        volume: 1350,
        keys: const [
          'brown_hf1000',
          'brown_sulfuric',
          'brown_h2o2',
          'brown_copper',
        ],
      ),
      TankInfo(
        name: tr('第五槽｜後浸槽'),
        description: tr('硫酸、VS'),
        volume: 445,
        keys: const ['post_sulfuric', 'post_vs'],
      ),
    ];
  }

  if (line == 'E線') {
    return [
      TankInfo(
        name: tr('第一槽｜酸洗槽'),
        description: tr('硫酸'),
        volume: 420,
        keys: const ['acid_sulfuric'],
      ),
      TankInfo(
        name: tr('第二槽｜鹼洗槽'),
        description: 'ALK',
        volume: 390,
        keys: const ['vs_alk'],
      ),
      TankInfo(
        name: tr('第三槽｜活化槽'),
        description: 'Bondfilm Activator',
        volume: 450,
        keys: const ['vs_activator'],
      ),
      TankInfo(
        name: tr('第四槽｜棕化槽'),
        description: tr('HF1000、硫酸、雙氧水、銅離子'),
        volume: 1200,
        keys: const [
          'brown_hf1000',
          'brown_sulfuric',
          'brown_h2o2',
          'brown_copper',
        ],
      ),
      TankInfo(
        name: tr('第五槽｜後浸槽'),
        description: tr('硫酸、VS'),
        volume: 580,
        keys: const ['post_sulfuric', 'post_vs'],
      ),
    ];
  }

  return [
    TankInfo(
      name: '第一槽｜酸洗槽',
      description: tr('硫酸、雙氧水'),
      volume: isA ? 500 : 246,
      keys: const ['acid_sulfuric', 'acid_h2o2'],
    ),
    TankInfo(
      name: '第二槽｜清潔槽',
      description: 'HL-II',
      volume: isA ? 800 : 582,
      keys: const ['clean_hl2'],
    ),
    TankInfo(
      name: '第三槽｜預浸槽',
      description: tr('雙氧水、CBBA-A'),
      volume: isA ? 700 : 440,
      keys: const ['pre_h2o2', 'pre_cbba'],
    ),
    TankInfo(
      name: '第四槽｜棕化槽',
      description: tr('硫酸、雙氧水、CBBA-A、銅離子'),
      volume: isA ? 1400 : 1560,
      keys: const [
        'brown_sulfuric',
        'brown_h2o2',
        'brown_cbba',
        'brown_copper',
      ],
    ),
  ];
}

// ============================================================
// 藥品所屬槽別
// ============================================================

String getTankName(String line, String key) {
  final tanks = getTankInfo(line);

  for (final tank in tanks) {
    if (tank.keys.contains(key)) {
      return tank.name;
    }
  }

  return '';
}

class AnalysisPage extends StatefulWidget {
  final String lineName;
  final String userName;

  AnalysisPage({super.key, required this.lineName, required this.userName});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final Map<String, TextEditingController> controllers = {};

  int _guidedStep = 0;
  bool _guidedMode = true;

  final TextEditingController beforeWeightController = TextEditingController();

  final TextEditingController afterWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final settings = getSettings(widget.lineName);

    for (final key in settings.keys) {
      controllers[key] = TextEditingController();
    }
  }

  double? parse(String value) {
    return double.tryParse(value.trim());
  }

  bool get _isVSLine => widget.lineName == 'D線' || widget.lineName == 'E線';

  double? concentration(String key, String value) {
    final setting = getSettings(widget.lineName)[key];

    if (setting == null) {
      return null;
    }

    final number = parse(value);

    if (number == null) {
      return null;
    }

    if (_isVSLine) {
      if (key == 'brown_copper') {
        return roundToTenth(number * 3.177);
      }

      if (key == 'brown_hf1000') {
        final copperInput = parse(controllers['brown_copper']?.text ?? '');
        if (copperInput == null) return null;
        final copperConcentration = copperInput * 3.177;
        final a = number / 0.544 * 6.5;
        final b = copperConcentration * 0.078;
        return roundToTenth(a - b);
      }

      if (key == 'post_vs') {
        return roundToTenth((number + 0.0067) / 0.1392 * 2.5);
      }

      if (key == 'vs_activator') {
        return roundToTenth(number / 0.538 * 2);
      }

      if (key == 'acid_sulfuric' ||
          key == 'brown_sulfuric' ||
          key == 'post_sulfuric') {
        return roundToTenth(number * 0.702);
      }

      if (key == 'brown_h2o2') {
        return roundToTenth(number * 0.49);
      }

      if (key == 'vs_alk') {
        return roundToTenth(number * 0.5);
      }
    }

    if (setting.direct) {
      return roundToTenth(number);
    }

    return roundToTenth(number * setting.factor);
  }

  double? addAmount(String key, String value) {
    final setting = getSettings(widget.lineName)[key];

    if (setting == null || setting.middle == null) {
      return null;
    }

    final current = concentration(key, value);

    if (current == null) {
      return null;
    }

    final middle = roundToTenth(setting.middle!);
    final actual = roundToTenth(current);

    if (actual >= middle) {
      return 0;
    }

    final deficit = roundToTenth(middle - actual);
    final steps = (deficit * 10).round();

    if (steps <= 0) {
      return 0;
    }

    if (_isVSLine) {
      final tank = getTankInfo(widget.lineName).firstWhere(
        (t) => t.keys.contains(key),
        orElse: () => TankInfo(name: '', description: '', volume: 0, keys: []),
      );

      final perPoint = tank.volume > 1000
          ? 1.5
          : tank.volume > 500
          ? 1.0
          : 0.5;

      return (steps * perPoint).roundToDouble();
    }

    if (setting.addPerPoint <= 0) {
      return null;
    }

    if (key == 'pre_cbba') {
      final addPerPoint = widget.lineName == 'A線' ? 1.0 : 0.5;
      return roundToTenth(steps * addPerPoint);
    }

    return roundToTenth(steps * setting.addPerPoint);
  }

  String displayAddAmount(String key, String value) {
    final setting = getSettings(widget.lineName)[key];

    if (setting == null || setting.middle == null) {
      return '-';
    }

    final amount = addAmount(key, value);

    if (amount == null) {
      return '-';
    }

    if (amount <= 0) {
      return tr('不用添加');
    }

    if (_isVSLine) {
      return '${amount.toInt()} ${setting.unit}';
    }

    return '${formatNumber(amount)} ${setting.unit}';
  }

  String displayConcentration(String key, String value) {
    final result = concentration(key, value);

    if (result == null) {
      return '-';
    }

    return formatNumber(result);
  }

  String displayMiddle(String key) {
    final setting = getSettings(widget.lineName)[key];

    if (setting == null) {
      return '-';
    }

    if (setting.middle == null) {
      return tr('無中值');
    }

    return formatNumber(roundToTenth(setting.middle!));
  }

  double? biteAmount() {
    final before = parse(beforeWeightController.text);
    final after = parse(afterWeightController.text);

    if (before == null || after == null) {
      return null;
    }

    if (widget.lineName == 'D線' || widget.lineName == 'E線') {
      return (before - after) * 555.56 / 100 * 40;
    }

    return (before - after) / 100 * 21910;
  }

  List<String> _guidedTitles() => [
    tr('咬食量'),
    ...getTankInfo(widget.lineName).map((tank) => tr(tank.name)),
    tr('結果總覽'),
  ];

  bool _stepComplete(int step) {
    if (step == 0) {
      final before = beforeWeightController.text.trim();
      final after = afterWeightController.text.trim();
      if (before.isEmpty && after.isEmpty) return true;
      return parse(before) != null &&
          parse(after) != null &&
          parse(before)! >= parse(after)! &&
          parse(before)! >= 0 &&
          parse(after)! >= 0;
    }
    final tanks = getTankInfo(widget.lineName);
    if (step >= 1 && step <= tanks.length) {
      return tanks[step - 1].keys.every(
        (key) => controllers[key]?.text.trim().isNotEmpty ?? false,
      );
    }
    return true;
  }

  void _showValidation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  bool _validateAllInputs() {
    final fields = <String>[...controllers.keys];
    for (final key in fields) {
      final value = controllers[key]?.text.trim() ?? '';
      if (value.isEmpty) continue;
      final n = parse(value);
      if (n == null) {
        _showValidation(
          '${tr('請確認數值')}：${tr(getSettings(widget.lineName)[key]?.name ?? key)}',
        );
        return false;
      }
      if (n < 0) {
        _showValidation(
          '${tr('輸入值不能為負數')}：${tr(getSettings(widget.lineName)[key]?.name ?? key)}',
        );
        return false;
      }
    }
    final before = beforeWeightController.text.trim();
    final after = afterWeightController.text.trim();
    if (before.isNotEmpty && (parse(before) == null || parse(before)! < 0)) {
      _showValidation(tr('請輸入有效數值'));
      return false;
    }
    if (after.isNotEmpty && (parse(after) == null || parse(after)! < 0)) {
      _showValidation(tr('請輸入有效數值'));
      return false;
    }
    if (parse(before) != null &&
        parse(after) != null &&
        parse(before)! < parse(after)!) {
      _showValidation('${tr('請確認數值')}：${tr('未棕化重量')} ≥ ${tr('已棕化重量')}');
      return false;
    }
    return true;
  }

  void _nextGuidedStep() {
    if (!_validateAllInputs()) return;
    if (!_stepComplete(_guidedStep)) {
      _showValidation(tr('請完成目前步驟後再繼續'));
      return;
    }
    final max = getTankInfo(widget.lineName).length + 1;
    if (_guidedStep < max) setState(() => _guidedStep++);
  }

  void _previousGuidedStep() {
    if (_guidedStep > 0) setState(() => _guidedStep--);
  }

  Widget _guidedHeader() {
    final titles = _guidedTitles();
    final max = titles.length - 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.route_outlined, color: Color(0xFF4B2714)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tr('化驗流程 2.0'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                ChoiceChip(
                  label: Text(tr('流程模式')),
                  selected: _guidedMode,
                  onSelected: (_) => setState(() => _guidedMode = true),
                ),
                const SizedBox(width: 5),
                ChoiceChip(
                  label: Text(tr('完整模式')),
                  selected: !_guidedMode,
                  onSelected: (_) => setState(() => _guidedMode = false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(titles.length, (i) {
                final active = i == _guidedStep;
                final done = i < _guidedStep;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: i == titles.length - 1 ? 0 : 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 3,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF6B3F22)
                          : done
                          ? Colors.green.withOpacity(.12)
                          : Colors.grey.withOpacity(.08),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          done
                              ? Icons.check_circle
                              : active
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 15,
                          color: active
                              ? Colors.white
                              : done
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: active ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${tr('目前步驟')}：${titles[_guidedStep]}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${_guidedStep + 1}/$max',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _guidedNavigation({required bool showSave}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _guidedStep == 0 ? null : _previousGuidedStep,
              icon: const Icon(Icons.arrow_back),
              label: Text(tr('上一步')),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: showSave
                ? ElevatedButton.icon(
                    onPressed: _confirmAndSaveRecord,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(tr('確認存檔')),
                  )
                : ElevatedButton.icon(
                    onPressed: _nextGuidedStep,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(tr('下一步')),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGuidedContent(List<TankInfo> tanks) {
    final max = tanks.length + 1;
    if (_guidedStep == 0)
      return [biteCard(), _guidedNavigation(showSave: false)];
    if (_guidedStep <= tanks.length) {
      final tank = tanks[_guidedStep - 1];
      return [
        tankCard(
          title: tank.name,
          description: tank.description,
          volume: tank.volume,
          keys: tank.keys,
        ),
        _guidedNavigation(showSave: false),
      ];
    }
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('結果總覽'),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              ...tanks.map((tank) {
                final complete = tank.keys.every(
                  (key) => controllers[key]?.text.trim().isNotEmpty ?? false,
                );
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    complete ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: complete ? Colors.green : Colors.orange,
                  ),
                  title: Text(
                    tr(tank.name),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(complete ? tr('化驗完成') : tr('尚未完成')),
                );
              }),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.water_drop_outlined),
                title: Text(tr('咬食量')),
                trailing: Text(
                  biteAmount() == null ? '-' : formatNumber(biteAmount()!),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
      _guidedNavigation(showSave: true),
    ];
  }

  Future<void> _confirmAndSaveRecord() async {
    if (!_validateAllInputs()) return;
    final settings = getSettings(widget.lineName);
    final incomplete = settings.entries
        .where((entry) => controllers[entry.key]?.text.trim().isEmpty ?? true)
        .map((entry) => entry.value.name)
        .toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('確認化驗存檔')),
        content: Text(
          incomplete.isEmpty
              ? tr('確認目前化驗結果並存檔嗎？')
              : '${tr('以下藥水尚未輸入：')}\n${incomplete.map(tr).join('、')}\n\n${tr('仍要存檔嗎？')}',
        ),
        actions: [
          LanguageToggleButton(),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('取消')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('確認存檔')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await saveRecord();
    }
  }

  Future<void> saveRecord() async {
    final settings = getSettings(widget.lineName);

    final chemicals = <String, dynamic>{};

    for (final entry in settings.entries) {
      final key = entry.key;

      final value = controllers[key]!.text.trim();

      final concentrationValue = concentration(key, value);

      final add = addAmount(key, value);

      chemicals[key] = {
        'input': value,
        'concentration': concentrationValue == null
            ? ''
            : formatNumber(concentrationValue),
        'addAmountValue': add,
        'addAmountNoNeed': add != null && add <= 0,
        'addAmount': add == null
            ? ''
            : add <= 0
            ? 'NO_ADD'
            : '${formatNumber(add)} ${entry.value.unit}',
        'tank': getTankName(widget.lineName, key),
      };
    }

    final bite = biteAmount();

    final record = <String, dynamic>{
      'line': widget.lineName,
      'user': widget.userName,
      'beforeWeight': beforeWeightController.text.trim(),
      'afterWeight': afterWeightController.text.trim(),
      'biteAmount': bite == null ? '' : formatNumber(bite),
      'chemicals': chemicals,
    };

    try {
      await FirebaseAnalysisManager.addRecord(record);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('化驗資料已儲存至雲端')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('雲端存檔失敗，請確認網路與 Firebase 權限')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget inputField(String key) {
    final setting = getSettings(widget.lineName)[key]!;

    final controller = controllers[key]!;

    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          labelText:
              (key == 'brown_hf1000' ||
                  key == 'brown_cbba' ||
                  key == 'post_vs' ||
                  key == 'vs_activator')
              ? '${tr(setting.name)}｜${tr('分析值')}'
              : '${tr(setting.name)}｜${tr('滴定值')}',
          hintText:
              (key == 'brown_hf1000' ||
                  key == 'brown_cbba' ||
                  key == 'post_vs' ||
                  key == 'vs_activator')
              ? tr('分析值')
              : tr('滴定值'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _resultBox(String title, String value) {
    Color? valueColor;

    if (title == tr('需添加量')) {
      if (value == tr('不用添加')) {
        valueColor = Colors.green;
      } else if (value != '-') {
        valueColor = Colors.red;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: Colors.grey)),
          SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 化驗步驟：A/B 共用；D/E 共用；合併化驗頁不使用
  // ============================================================

  List<String> _analysisSteps(String line, String key) {
    final isAB = line == 'A線' || line == 'B線';

    String step(String zh, String th) => KLFGlobalLanguage.isThai ? th : zh;

    if (isAB) {
      switch (key) {
        case 'acid_sulfuric':
        case 'brown_sulfuric':
          return [
            step('250 mL 錐形瓶', 'ขวดรูปกรวย 250 mL'),
            step('加水 100 mL', 'เติมน้ำ 100 mL'),
            step('精取 1 mL 槽液', 'ดูดสารละลายจากถัง 1 mL'),
            step('加入 2～3 滴 MO 指示劑', 'เติมสารชี้วัด MO 2～3 หยด'),
            step('以 1N-NaOH 滴定', 'ไทเทรตด้วย 1N-NaOH'),
            step('終點：呈紅色 → 淡橙棕色', 'จุดยุติ: สีแดง → สีส้มอมน้ำตาลอ่อน'),
          ];
        case 'acid_h2o2':
        case 'pre_h2o2':
        case 'brown_h2o2':
          return [
            step('250 mL 錐形瓶', 'ขวดรูปกรวย 250 mL'),
            step('加水 100 mL', 'เติมน้ำ 100 mL'),
            step('精取 1 mL 槽液', 'ดูดสารละลายจากถัง 1 mL'),
            step('加入 2～3 滴鐵指示劑', 'เติมสารชี้วัดเหล็ก 2～3 หยด'),
            step('以硫酸亞鐵滴定', 'ไทเทรตด้วยเฟอร์รัสซัลเฟต'),
            step('終點：橙紅色 → 淺藍色', 'จุดยุติ: สีส้มแดง → สีฟ้าอ่อน'),
          ];
        case 'clean_hl2':
          return [
            step('250 mL 錐形瓶', 'ขวดรูปกรวย 250 mL'),
            step('加水 100 mL', 'เติมน้ำ 100 mL'),
            step('精取 20 mL 槽液', 'ดูดสารละลายจากถัง 20 mL'),
            step('加入 2～3 滴 MMO', 'เติม MMO 2～3 หยด'),
            step('以 1N-H₂SO₄ 滴定', 'ไทเทรตด้วย 1N-H₂SO₄'),
            step('終點：綠棕色 → 紫色', 'จุดยุติ: สีเขียวอมน้ำตาล → สีม่วง'),
          ];
        case 'pre_cbba':
        case 'brown_cbba':
          return [
            step('100 mL 錐形瓶', 'ขวดรูปกรวย 100 mL'),
            step('加水 100 mL', 'เติมน้ำ 100 mL'),
            step('精取 0.2 mL 槽液', 'ดูดสารละลายจากถัง 0.2 mL'),
            step('搖拌約 10 秒', 'เขย่าหรือกวนประมาณ 10 วินาที'),
            step('使用光譜儀測濃度分析', 'วิเคราะห์ความเข้มข้นด้วยเครื่องสเปกโตรมิเตอร์'),
          ];
        case 'brown_copper':
          return [
            step('250 mL 錐形瓶', 'ขวดรูปกรวย 250 mL'),
            step('加水 100 mL', 'เติมน้ำ 100 mL'),
            step('精取 1 mL 槽液', 'ดูดสารละลายจากถัง 1 mL'),
            step(
              '加入 pH 9.5 緩衝液 40 mL',
              'เติมสารละลายบัฟเฟอร์ pH 9.5 ปริมาณ 40 mL',
            ),
            step('加入 2～3 滴 PAN 指示劑', 'เติมสารชี้วัด PAN 2～3 หยด'),
            step('以 EDTA 滴定', 'ไทเทรตด้วย EDTA'),
            step('終點：藍色 → 淺黃綠色', 'จุดยุติ: สีน้ำเงิน → สีเขียวอมเหลืองอ่อน'),
          ];
      }
    } else {
      switch (key) {
        case 'acid_sulfuric':
        case 'brown_sulfuric':
        case 'post_sulfuric':
          return [
            step('250 mL 錐形瓶', 'ขวดรูปกรวย 250 mL'),
            step('加水 100 mL', 'เติมน้ำ 100 mL'),
            step('精取 1 mL 槽液', 'ดูดสารละลายจากถัง 1 mL'),
            step('加入 5 滴 MO', 'เติม MO 5 หยด'),
            step('以 0.1N-NaOH 滴定', 'ไทเทรตด้วย 0.1N-NaOH'),
            step('終點：紅色 → 黃色', 'จุดยุติ: สีแดง → สีเหลือง'),
          ];
        case 'vs_alk':
          return [
            step('250 mL 錐形瓶', 'ขวดรูปกรวย 250 mL'),
            step('加水 100 mL', 'เติมน้ำ 100 mL'),
            step('精取 10 mL 槽液', 'ดูดสารละลายจากถัง 10 mL'),
            step('加入 3～5 滴 PP 指示劑', 'เติมสารชี้วัด PP 3～5 หยด'),
            step('加入 1M BaCl₂', 'เติม 1M BaCl₂'),
            step('以 0.5N-HCl 滴定', 'ไทเทรตด้วย 0.5N-HCl'),
            step('終點：紫色 → 透明', 'จุดยุติ: สีม่วง → ใส'),
          ];
        case 'vs_activator':
          return [
            step('100 mL 錐形瓶', 'ขวดรูปกรวย 100 mL'),
            step('加水 100 mL', 'เติมน้ำ 100 mL'),
            step('精取 1 mL 槽液', 'ดูดสารละลายจากถัง 1 mL'),
            step('攪拌 10 秒', 'กวน 10 วินาที'),
            step(
              '使用 UV 光譜儀 259 nm 波長分析',
              'วิเคราะห์ด้วยเครื่อง UV สเปกโตรมิเตอร์ที่ความยาวคลื่น 259 nm',
            ),
          ];
        case 'brown_hf1000':
          return [
            step('1000 mL 定量瓶', 'ขวดวัดปริมาตร 1000 mL'),
            step('精取 1 mL 槽液', 'ดูดสารละลายจากถัง 1 mL'),
            step('加水至 1000 mL', 'เติมน้ำจนถึง 1000 mL'),
            step('攪拌 10 秒', 'กวน 10 วินาที'),
            step(
              '使用 UV 光譜儀 259 nm 分析',
              'วิเคราะห์ด้วยเครื่อง UV สเปกโตรมิเตอร์ที่ 259 nm',
            ),
            step('並依 Cu²⁺ 結果進行 A／B 計算', 'คำนวณ A／B ตามผล Cu²⁺'),
          ];
        case 'brown_h2o2':
          return [
            step('250 mL 錐形瓶', 'ขวดรูปกรวย 250 mL'),
            step('加水 75 mL', 'เติมน้ำ 75 mL'),
            step('精取 1 mL 槽液', 'ดูดสารละลายจากถัง 1 mL'),
            step('加入 50% H₂SO₄ 5 mL', 'เติม 50% H₂SO₄ 5 mL'),
            step('加入 3～5 滴鐵指示劑', 'เติมสารชี้วัดเหล็ก 3～5 หยด'),
            step('以硫酸亞鐵滴定', 'ไทเทรตด้วยเฟอร์รัสซัลเฟต'),
            step('終點：黃紅色 → 藍綠色', 'จุดยุติ: สีเหลืองแดง → สีเขียวอมฟ้า'),
          ];
        case 'brown_copper':
          return [
            step('250 mL 錐形瓶', 'ขวดรูปกรวย 250 mL'),
            step('加水 100 mL', 'เติมน้ำ 100 mL'),
            step('精取 1 mL 槽液', 'ดูดสารละลายจากถัง 1 mL'),
            step('加入 2 小勺 pH 指示劑', 'เติมสารชี้วัด pH 2 ช้อนเล็ก'),
            step('以 0.1N EDTA 滴定', 'ไทเทรตด้วย 0.1N EDTA'),
            step('終點：黃色 → 紫色', 'จุดยุติ: สีเหลือง → สีม่วง'),
          ];
        case 'post_vs':
          return [
            step('100 mL 定量瓶', 'ขวดวัดปริมาตร 100 mL'),
            step('精取 4 mL 槽液', 'ดูดสารละลายจากถัง 4 mL'),
            step('加水至 100 mL', 'เติมน้ำจนถึง 100 mL'),
            step('攪拌 10 秒', 'กวน 10 วินาที'),
            step(
              '使用 UV 光譜儀 246 nm 波長分析',
              'วิเคราะห์ด้วยเครื่อง UV สเปกโตรมิเตอร์ที่ความยาวคลื่น 246 nm',
            ),
          ];
      }
    }
    return [
      step(
        '目前沒有設定此項目的化驗步驟。',
        'ยังไม่มีการตั้งค่าขั้นตอนการวิเคราะห์สำหรับรายการนี้',
      ),
    ];
  }

  List<String> _analysisFormulas(String line, String key) {
    final setting = getSettings(line)[key];
    if (setting == null) return [];

    String f(String zh, String th) => KLFGlobalLanguage.isThai ? th : zh;

    final formulas = <String>[];

    // 濃度計算：完全依照目前程式實際使用的計算公式。
    if (line == 'D線' || line == 'E線') {
      switch (key) {
        case 'brown_copper':
          formulas.add(
            f('濃度 = 分析值 × 3.177', 'ความเข้มข้น = ค่าการวิเคราะห์ × 3.177'),
          );
          break;
        case 'brown_hf1000':
          formulas.add(
            f('A = 分析值 ÷ 0.544 × 6.5', 'A = ค่าการวิเคราะห์ ÷ 0.544 × 6.5'),
          );
          formulas.add(f('B = 銅離子濃度 × 0.078', 'B = ความเข้มข้นทองแดง × 0.078'));
          formulas.add(f('HF1000 = A − B', 'HF1000 = A − B'));
          break;
        case 'post_vs':
          formulas.add(
            f(
              '濃度 = (分析值 + 0.0067) ÷ 0.1392 × 2.5',
              'ความเข้มข้น = (ค่าการวิเคราะห์ + 0.0067) ÷ 0.1392 × 2.5',
            ),
          );
          break;
        case 'vs_activator':
          formulas.add(
            f(
              '濃度 = 分析值 ÷ 0.538 × 2',
              'ความเข้มข้น = ค่าการวิเคราะห์ ÷ 0.538 × 2',
            ),
          );
          break;
        case 'acid_sulfuric':
        case 'brown_sulfuric':
        case 'post_sulfuric':
          formulas.add(
            f('濃度 = 分析值 × 0.702', 'ความเข้มข้น = ค่าการวิเคราะห์ × 0.702'),
          );
          break;
        case 'brown_h2o2':
          formulas.add(
            f('濃度 = 分析值 × 0.49', 'ความเข้มข้น = ค่าการวิเคราะห์ × 0.49'),
          );
          break;
        case 'vs_alk':
          formulas.add(
            f('濃度 = 分析值 × 0.5', 'ความเข้มข้น = ค่าการวิเคราะห์ × 0.5'),
          );
          break;
      }
    } else {
      if (setting.direct) {
        formulas.add(f('濃度 = 分析值', 'ความเข้มข้น = ค่าการวิเคราะห์'));
      } else {
        formulas.add(
          f(
            '濃度 = 分析值 × ${setting.factor}',
            'ความเข้มข้น = ค่าการวิเคราะห์ × ${setting.factor}',
          ),
        );
      }
    }

    // 需添加量公式：依照目前 _addAmount() 實際邏輯。
    if (setting.middle != null) {
      final middle = formatNumber(roundToTenth(setting.middle!));

      if (line == 'D線' || line == 'E線') {
        final tank = getTankInfo(line).firstWhere(
          (t) => t.keys.contains(key),
          orElse: () =>
              TankInfo(name: '', description: '', volume: 0, keys: const []),
        );

        final perPoint = tank.volume > 1000
            ? 1.5
            : tank.volume > 500
            ? 1.0
            : 0.5;

        formulas.add(
          f(
            '中值 = $middle；低於中值時，每 0.1 濃度添加 $perPoint ${setting.unit}',
            'ค่ากลาง = $middle; เมื่อความเข้มข้นต่ำกว่าค่ากลาง ทุก 0.1 เติม $perPoint ${setting.unit}',
          ),
        );
        formulas.add(
          f(
            '需添加量 = (中值 − 實際濃度) ÷ 0.1 × $perPoint ${setting.unit}',
            'ปริมาณที่ต้องเติม = (ค่ากลาง − ความเข้มข้นจริง) ÷ 0.1 × $perPoint ${setting.unit}',
          ),
        );
      } else {
        final perPoint = key == 'pre_cbba'
            ? (line == 'A線' ? 1.0 : 0.5)
            : setting.addPerPoint;

        formulas.add(
          f(
            '中值 = $middle；低於中值時，每 0.1 濃度添加 $perPoint ${setting.unit}',
            'ค่ากลาง = $middle; เมื่อความเข้มข้นต่ำกว่าค่ากลาง ทุก 0.1 เติม $perPoint ${setting.unit}',
          ),
        );
        formulas.add(
          f(
            '需添加量 = (中值 − 實際濃度) ÷ 0.1 × $perPoint ${setting.unit}',
            'ปริมาณที่ต้องเติม = (ค่ากลาง − ความเข้มข้นจริง) ÷ 0.1 × $perPoint ${setting.unit}',
          ),
        );
      }

      formulas.add(
        f('實際濃度 ≥ 中值 → 不用添加', 'ความเข้มข้นจริง ≥ ค่ากลาง → ไม่ต้องเติม'),
      );
    }

    return formulas;
  }

  void _showAnalysisSteps(String key) {
    final setting = getSettings(widget.lineName)[key];
    if (setting == null) return;
    final steps = _analysisSteps(widget.lineName, key);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.science_outlined, size: 22),
            const SizedBox(width: 7),
            Expanded(child: Text('${tr(setting.name)}｜${tr('化驗步驟')}')),
          ],
        ),
        content: SizedBox(
          width: 430,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('${isABLine(widget.lineName) ? 'A／B' : 'D／E'} 共用標準'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  steps.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE4DE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4B2714),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            steps[index],
                            style: const TextStyle(fontSize: 15, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),

                Text(
                  tr('計算公式'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),

                ..._analysisFormulas(widget.lineName, key).map(
                  (formula) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      formula,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('關閉')),
          ),
        ],
      ),
    );
  }

  bool isABLine(String line) => line == 'A線' || line == 'B線';

  Widget _aValueBox(String title, String value, {bool highlight = false}) {
    Color? valueColor;

    if (title == tr('需添加量')) {
      if (value == tr('不用添加')) {
        valueColor = Colors.green;
      } else if (value != '-') {
        valueColor = Colors.red;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFEDE4DE) : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? const Color(0xFFD8C1B2) : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: highlight ? const Color(0xFF5A3522) : Colors.grey.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aAnalysisRow(String key) {
    final setting = getSettings(widget.lineName)[key]!;
    final controller = controllers[key]!;
    final value = controller.text;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final nameAndButton = Row(
            children: [
              Expanded(
                child: Text(
                  tr(setting.name),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 7),
              _analysisStepButton(key),
            ],
          );

          final input = inputField(key);
          final middle = _aValueBox(
            tr('中值'),
            displayMiddle(key),
            highlight: true,
          );
          final concentrationBox = _aValueBox(
            tr('濃度'),
            displayConcentration(key, value),
          );
          final addBox = _aValueBox(tr('需添加量'), displayAddAmount(key, value));

          if (constraints.maxWidth < 500) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                nameAndButton,
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: input),
                    const SizedBox(width: 6),
                    Expanded(child: middle),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: concentrationBox),
                    const SizedBox(width: 6),
                    Expanded(child: addBox),
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 2, child: nameAndButton),
              const SizedBox(width: 7),
              Expanded(flex: 2, child: input),
              const SizedBox(width: 7),
              Expanded(child: middle),
              const SizedBox(width: 7),
              Expanded(child: concentrationBox),
              const SizedBox(width: 7),
              Expanded(child: addBox),
            ],
          );
        },
      ),
    );
  }

  Widget chemicalRow(String key) {
    // A/B/D/E 四條線統一使用目前測試確認的新版化驗排版。
    // 合併化驗頁不會呼叫 chemicalRow，因此不會加入化驗步驟按鈕。
    return _aAnalysisRow(key);
  }

  Widget _analysisStepButton(String key) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: () => _showAnalysisSteps(key),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8A5A44),
          foregroundColor: Colors.white,
          elevation: 1.5,
          shadowColor: Colors.black26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.science_outlined, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              tr('化驗步驟'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget tankCard({
    required String title,
    required String description,
    required double volume,
    required List<String> keys,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Builder(
                        builder: (_) {
                          final complete = keys.every(
                            (key) =>
                                controllers[key]?.text.trim().isNotEmpty ??
                                false,
                          );
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: complete
                                  ? Colors.green.withOpacity(0.10)
                                  : Colors.grey.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  complete
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 14,
                                  color: complete ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  complete ? tr('化驗完成') : tr('尚未完成'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: complete
                                        ? Colors.green
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFEDE4DE),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '${tr('槽體積：')}${formatNumber(volume)} L',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1),
            Text(tr(description), style: TextStyle(color: Colors.grey)),
            SizedBox(height: 4),
            ...keys.map((key) => chemicalRow(key)),
          ],
        ),
      ),
    );
  }

  Widget biteCard() {
    final bite = biteAmount();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('咬食量'),
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              tr('未棕化重量、已棕化重量由化驗人員輸入，系統自動計算。'),
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: beforeWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        labelText: tr('未棕化重量'),
                        suffixText: 'g',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: afterWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        labelText: tr('已棕化重量'),
                        suffixText: 'g',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Color(0xFFEDE4DE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr('咬食量'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    bite == null ? '-' : formatNumber(bite),
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Text(
              (widget.lineName == 'D線' || widget.lineName == 'E線')
                  ? '公式：(未棕化重量－已棕化重量) × 555.56 ÷ 100 × 40'
                  : '公式：(未棕化重量－已棕化重量) ÷ 100 × 21910',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tanks = getTankInfo(widget.lineName);

    return Scaffold(
      appBar: AppBar(
        title: Text('${tr(widget.lineName)}｜${tr('藥水化驗')}'),
        actions: [
          LanguageToggleButton(),
          IconButton(
            tooltip: tr('管理者'),
            icon: Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminLoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 20),
                      SizedBox(width: 7),
                      Text(
                        '${tr('化驗人員：')}${widget.userName}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 7),

              _guidedHeader(),

              if (_guidedMode && MediaQuery.of(context).size.width < 700)
                ..._buildGuidedContent(tanks)
              else ...[
                biteCard(),
                SizedBox(height: 7),
                ...tanks.asMap().entries.map((entry) {
                  final tank = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: tankCard(
                      title: tank.name,
                      description: tank.description,
                      volume: tank.volume,
                      keys: tank.keys,
                    ),
                  );
                }),
                SizedBox(height: 3),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _confirmAndSaveRecord,
                    icon: Icon(Icons.save_outlined),
                    label: Text(
                      tr('化驗完成並存檔'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 7),

              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecordsPage(userName: widget.userName),
                      ),
                    );
                  },
                  icon: Icon(Icons.folder_open),
                  label: Text(tr('查看化驗存檔')),
                ),
              ),

              SizedBox(height: 15),

              Center(
                child: Text(
                  '${tr(KLFConfig.appName)} ${KLFConfig.version}',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }

    beforeWeightController.dispose();
    afterWeightController.dispose();

    super.dispose();
  }
}

class SevenDayTrendCard extends StatelessWidget {
  final List<Map<String, dynamic>> records;
  const SevenDayTrendCard({super.key, required this.records});

  int _count(DateTime day) {
    return records.where((r) {
      final dt = DateTime.tryParse(r['time']?.toString() ?? '')?.toLocal();
      if (dt == null) return false;
      return dt.year == day.year && dt.month == day.month && dt.day == day.day;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(
      7,
      (i) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i)),
    );
    final counts = days.map(_count).toList();
    final maxCount = counts.fold<int>(1, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Color(0xFF2F6FB3)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tr('最近 7 天化驗趨勢'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${records.length}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final h = counts[i] == 0
                      ? 4.0
                      : 8 + 58 * counts[i] / maxCount;
                  final label = '${days[i].month}/${days[i].day}';
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${counts[i]}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            height: h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B3F22),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(label, style: const TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordsPage extends StatefulWidget {
  final String userName;

  RecordsPage({super.key, required this.userName});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List<Map<String, dynamic>> records = [];
  bool loading = true;
  String? loadError;
  final TextEditingController _searchController = TextEditingController();
  String _lineFilter = '全部';
  bool _adminMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // 先顯示本機資料，Firebase 永遠在背景更新，不阻塞進入頁面。
    records = LocalStorageHelper.getRecords();
    loading = false;
    loadError = null;

    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        // 不把整頁切成 loading；保留目前資料與操作。
        loadError = null;
      });
    }

    try {
      final cloudRecords = await FirebaseAnalysisManager.getRecords().timeout(
        const Duration(seconds: 8),
      );

      if (!mounted) return;

      LocalStorageHelper.saveRecords(cloudRecords);

      setState(() {
        records = cloudRecords;
        loading = false;
        loadError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        // 讀取失敗不能再誤顯示成「目前沒有雲端資料」。
        loadError = records.isEmpty ? tr('雲端化驗資料讀取失敗，請重新讀取') : null;
      });

      if (records.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr('Firebase 讀取失敗：')}${error.toString()}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  String formatDate(String value) {
    try {
      final date = DateTime.parse(value);

      String two(int n) => n.toString().padLeft(2, '0');

      return '${date.year}-'
          '${two(date.month)}-'
          '${two(date.day)} '
          '${two(date.hour)}:'
          '${two(date.minute)}';
    } catch (_) {
      return value;
    }
  }

  Future<bool> _enterAdminMode() async {
    final controller = TextEditingController();

    final verified = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('管理者登入')),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            Navigator.pop(context, controller.text == KLFConfig.adminPassword);
          },
          decoration: InputDecoration(
            labelText: tr('管理者密碼'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
          ),
        ),
        actions: [
          LanguageToggleButton(),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('取消')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                controller.text == KLFConfig.adminPassword,
              );
            },
            child: Text(tr('登入管理者')),
          ),
        ],
      ),
    );

    controller.dispose();

    if (verified == true) {
      if (!mounted) return true;
      setState(() => _adminMode = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('管理模式已開啟')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('管理者密碼錯誤')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return false;
  }

  void _exitAdminMode() {
    setState(() => _adminMode = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('管理模式已關閉')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteRecord(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('刪除存檔')),
        content: Text(tr('確定要永久刪除這筆化驗資料嗎？')),
        actions: [
          LanguageToggleButton(),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('取消')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('刪除')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseAnalysisManager.deleteRecord(id);

      if (!mounted) return;

      setState(() {
        records.removeWhere((record) => record['id']?.toString() == id);
      });
      LocalStorageHelper.saveRecords(records);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('化驗資料已刪除')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('刪除失敗，請確認網路連線')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openRecord(Map<String, dynamic> record) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecordViewPage(
          record: record,
          userName: widget.userName,
          onDeleted: _load,
          adminMode: _adminMode,
        ),
      ),
    );

    if (updated == true && mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('化驗存檔')),
        actions: [
          LanguageToggleButton(),
          IconButton(
            tooltip: tr('重新整理'),
            icon: Icon(Icons.refresh),
            onPressed: _load,
          ),
          if (_adminMode)
            IconButton(
              tooltip: tr('關閉管理模式'),
              icon: const Icon(Icons.lock_open),
              onPressed: _exitAdminMode,
            )
          else
            IconButton(
              tooltip: tr('管理者登入'),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: _enterAdminMode,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loadError ?? tr('目前沒有化驗存檔'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: Text(tr('重新讀取'))),
            ],
          ),
        ),
      );
    }

    final query = _searchController.text.trim().toLowerCase();

    final filtered = records.where((record) {
      final line =
          record['line']?.toString() ?? record['mergeType']?.toString() ?? '-';
      final mergeType = record['mergeType']?.toString() ?? '';
      final user = record['user']?.toString() ?? '';
      final time = formatDate(record['time']?.toString() ?? '');

      final lineMatches =
          _lineFilter == '全部' ||
          line == _lineFilter ||
          mergeType == _lineFilter;

      final searchText = '$line $mergeType $user $time'.toLowerCase();

      return lineMatches && (query.isEmpty || searchText.contains(query));
    }).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          if (_adminMode)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.10),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.green.withOpacity(0.30)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      tr('管理模式已開啟'),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(onPressed: _exitAdminMode, child: Text(tr('關閉'))),
                ],
              ),
            ),
          SevenDayTrendCard(records: records),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: tr('搜尋化驗紀錄'),
                      hintText: tr('搜尋線別、合併化驗、操作員或日期'),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final option in const [
                          '全部',
                          'A線',
                          'B線',
                          'C線',
                          'D線',
                          'E線',
                          'F線',
                          'AB合併化驗',
                          'DE合併化驗',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: ChoiceChip(
                              label: Text(tr(option)),
                              selected: _lineFilter == option,
                              onSelected: (_) =>
                                  setState(() => _lineFilter = option),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Text(
                  tr('沒有符合條件的化驗紀錄'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            ...filtered.map((record) {
              final line =
                  record['line']?.toString() ??
                  record['mergeType']?.toString() ??
                  '-';
              final user = record['user']?.toString() ?? '-';
              final time = formatDate(record['time']?.toString() ?? '');
              final bite =
                  record['biteAmount'] == null ||
                      record['biteAmount'].toString().isEmpty
                  ? '-'
                  : record['biteAmount'].toString();
              final combined = record['recordType']?.toString() == 'combined';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  leading: CircleAvatar(
                    child: Icon(
                      combined ? Icons.compare_arrows : Icons.science_outlined,
                    ),
                  ),
                  title: Text(
                    '${tr(line)}｜$time',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    combined
                        ? '${tr('合併化驗')}｜${tr('操作員')}：$user'
                        : '${tr('操作員')}：$user　${tr('咬食量')}：$bite',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_adminMode)
                        IconButton(
                          tooltip: tr('刪除'),
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              _deleteRecord(record['id']?.toString() ?? ''),
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _openRecord(record),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class RecordViewPage extends StatelessWidget {
  final Map<String, dynamic> record;
  final String userName;
  final Future<void> Function()? onDeleted;
  final bool adminMode;

  RecordViewPage({
    super.key,
    required this.record,
    required this.userName,
    this.onDeleted,
    this.adminMode = false,
  });

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);

      String two(int n) => n.toString().padLeft(2, '0');

      return '${date.year}-'
          '${two(date.month)}-'
          '${two(date.day)} '
          '${two(date.hour)}:'
          '${two(date.minute)}';
    } catch (_) {
      return value;
    }
  }

  List<String> _keysForTank(String line, String tankName) {
    final settings = getSettings(line);

    final keys = settings.keys.where((key) {
      final stored = (record['chemicals']?[key]?['tank'] ?? '').toString();

      if (stored.isNotEmpty) {
        return stored == tankName;
      }

      return getTankName(line, key) == tankName;
    }).toList();

    return keys;
  }

  String _tankVolume(String line, String tankName) {
    final tanks = getTankInfo(line);

    for (final tank in tanks) {
      if (tank.name == tankName) {
        return '${formatNumber(tank.volume)} L';
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (record['recordType']?.toString() == 'combined') {
      return _buildCombinedRecordPage(context);
    }

    final line = record['line']?.toString() ?? '';
    final user = record['user']?.toString() ?? '';
    final time = _formatDate(record['time']?.toString() ?? '');

    final bite =
        record['biteAmount'] == null || record['biteAmount'].toString().isEmpty
        ? '-'
        : record['biteAmount'].toString();

    final chemicals = Map<String, dynamic>.from(record['chemicals'] ?? {});

    final tanks = getTankInfo(line);

    return Scaffold(
      appBar: AppBar(
        title: Text('${tr(line)}｜${tr('化驗結果')}'),
        actions: [
          LanguageToggleButton(),
          IconButton(
            tooltip: tr('管理者'),
            icon: Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminLoginPage()),
              );
            },
          ),
          if (adminMode)
            IconButton(
              tooltip: tr('修改'),
              icon: Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordEditPage(
                      record: record,
                      userName: userName,
                      adminMode: true,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > 900
                ? 900.0
                : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _infoItem(tr('生產線'), line),
                            _infoItem(tr('操作員'), user),
                            _infoItem(tr('時間'), time),
                            _infoItem(tr('咬食量'), bite),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    ...tanks.map((tank) {
                      final keys = _keysForTank(line, tank.name);

                      if (keys.isEmpty) {
                        return SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEDE4DE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tr(tank.name),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${formatNumber(tank.volume)} L',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 3),

                                ...keys.map((key) {
                                  final setting = getSettings(line)[key]!;

                                  final data = Map<String, dynamic>.from(
                                    chemicals[key] ?? {},
                                  );

                                  final input = data['input']?.toString() ?? '';
                                  final concentration =
                                      data['concentration']?.toString() ?? '';
                                  final addAmount = displayStoredAddAmount(
                                    data['addAmount']?.toString() ?? '',
                                  );

                                  Color? addColor;

                                  if (addAmount == tr('不用添加')) {
                                    addColor = Colors.green;
                                  } else if (addAmount.isNotEmpty &&
                                      addAmount != '-') {
                                    addColor = Colors.red;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            tr(setting.name),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: _result(
                                            tr('輸入'),
                                            input.isEmpty ? '-' : input,
                                          ),
                                        ),
                                        Expanded(
                                          child: _result(
                                            tr('中值'),
                                            setting.middle == null
                                                ? tr('無中值')
                                                : formatNumber(setting.middle!),
                                          ),
                                        ),
                                        Expanded(
                                          child: _result(
                                            tr('濃度'),
                                            concentration.isEmpty
                                                ? '-'
                                                : concentration,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: _result(
                                            tr('需添加量'),
                                            addAmount.isEmpty ? '-' : addAmount,
                                            valueColor: addColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    SizedBox(height: 6),

                    if (adminMode)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: tr('刪除'),
                          icon: Icon(Icons.delete_outline),
                          onPressed: () async {
                            await _deleteWithAdmin(context);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCombinedRecordPage(BuildContext context) {
    return CombinedRecordViewPage(
      record: record,
      userName: userName,
      adminMode: adminMode,
    );
  }

  Widget _buildCombinedRecordPageLegacy(BuildContext context) {
    final mergeType =
        record['mergeType']?.toString() ?? record['line']?.toString() ?? '合併化驗';
    final leftLine =
        record['leftLine']?.toString() ?? (mergeType == 'AB合併化驗' ? 'A線' : 'D線');
    final rightLine =
        record['rightLine']?.toString() ??
        (mergeType == 'AB合併化驗' ? 'B線' : 'E線');
    final user = record['user']?.toString() ?? '-';
    final time = _formatDate(record['time']?.toString() ?? '');

    final allChemicals = Map<String, dynamic>.from(record['chemicals'] ?? {});
    final leftChemicals = Map<String, dynamic>.from(
      allChemicals[leftLine] ?? {},
    );
    final rightChemicals = Map<String, dynamic>.from(
      allChemicals[rightLine] ?? {},
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(mergeType)),
        actions: [
          LanguageToggleButton(),
          IconButton(
            tooltip: tr('管理者'),
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminLoginPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > 1000
                ? 1000.0
                : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _infoItem(tr('化驗類型'), tr(mergeType)),
                            _infoItem(tr('操作員'), user),
                            _infoItem(tr('時間'), time),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildCombinedSavedLine(
                            leftLine,
                            leftChemicals,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 700,
                          color: Colors.brown.shade200,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCombinedSavedLine(
                            rightLine,
                            rightChemicals,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: tr('刪除'),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await _deleteWithAdmin(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCombinedSavedLine(String line, Map<String, dynamic> chemicals) {
    final tanks = getTankInfo(line);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE4DE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              tr(line),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 6),
        ...tanks.map((tank) {
          final keys = getSettings(line).keys.where((key) {
            final data = Map<String, dynamic>.from(chemicals[key] ?? {});
            final storedTank = data['tank']?.toString() ?? '';
            return storedTank == tank.name;
          }).toList();

          if (keys.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE4DE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              tr(tank.name),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${formatNumber(tank.volume)} L',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    ...keys.map((key) {
                      final setting = getSettings(line)[key]!;
                      final data = Map<String, dynamic>.from(
                        chemicals[key] ?? {},
                      );

                      final input = data['input']?.toString() ?? '';
                      final concentration =
                          data['concentration']?.toString() ?? '';
                      final addAmount = displayStoredAddAmount(
                        data['addAmount']?.toString() ?? '',
                      );

                      Color? addColor;
                      if (addAmount == tr('不用添加')) {
                        addColor = Colors.green;
                      } else if (addAmount.isNotEmpty && addAmount != '-') {
                        addColor = Colors.red;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                tr(setting.name),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _result(
                                tr('輸入'),
                                input.isEmpty ? '-' : input,
                              ),
                            ),
                            Expanded(
                              child: _result(
                                tr('中值'),
                                setting.middle == null
                                    ? tr('無中值')
                                    : formatNumber(setting.middle!),
                              ),
                            ),
                            Expanded(
                              child: _result(
                                tr('濃度'),
                                concentration.isEmpty ? '-' : concentration,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _result(
                                tr('需添加量'),
                                addAmount.isEmpty ? '-' : addAmount,
                                valueColor: addColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _infoItem(String title, String value) {
    return SizedBox(
      width: 145,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 10)),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _result(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 9)),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWithAdmin(BuildContext context) async {
    final id = record['id']?.toString();

    if (id == null || id.isEmpty) {
      return;
    }

    if (!adminMode) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('請先開啟管理模式')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('刪除存檔')),
        content: Text(tr('確定要永久刪除這筆化驗資料嗎？')),
        actions: [
          LanguageToggleButton(),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('取消')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('刪除')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseAnalysisManager.deleteRecord(id);

      await onDeleted?.call();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('化驗資料已刪除')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('刪除失敗，請確認網路連線')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class CombinedRecordViewPage extends StatefulWidget {
  final Map<String, dynamic> record;
  final String userName;
  final bool adminMode;

  const CombinedRecordViewPage({
    super.key,
    required this.record,
    required this.userName,
    this.adminMode = false,
  });

  @override
  State<CombinedRecordViewPage> createState() => _CombinedRecordViewPageState();
}

class _CombinedRecordViewPageState extends State<CombinedRecordViewPage> {
  late String selectedLine;

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);
      String two(int n) => n.toString().padLeft(2, '0');
      return '${date.year}-${two(date.month)}-${two(date.day)} '
          '${two(date.hour)}:${two(date.minute)}';
    } catch (_) {
      return value;
    }
  }

  @override
  void initState() {
    super.initState();
    final mergeType =
        widget.record['mergeType']?.toString() ??
        widget.record['line']?.toString() ??
        '合併化驗';
    selectedLine = mergeType == 'AB合併化驗' ? 'A線' : 'D線';
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final mergeType =
        record['mergeType']?.toString() ?? record['line']?.toString() ?? '合併化驗';
    final leftLine =
        record['leftLine']?.toString() ?? (mergeType == 'AB合併化驗' ? 'A線' : 'D線');
    final rightLine =
        record['rightLine']?.toString() ??
        (mergeType == 'AB合併化驗' ? 'B線' : 'E線');

    // 防止舊資料沒有 left/right 欄位時選擇器失效。
    if (selectedLine != leftLine && selectedLine != rightLine) {
      selectedLine = leftLine;
    }

    final allChemicals = Map<String, dynamic>.from(record['chemicals'] ?? {});
    final selectedChemicals = Map<String, dynamic>.from(
      allChemicals[selectedLine] ?? {},
    );
    final user = record['user']?.toString() ?? '-';
    final time = _formatDate(record['time']?.toString() ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      appBar: AppBar(
        title: Text(tr(mergeType)),
        actions: [
          LanguageToggleButton(),
          if (widget.adminMode)
            IconButton(
              tooltip: tr('修改'),
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CombinedAnalysisPage(
                      userName: widget.userName,
                      mergeType: mergeType,
                      recordId: widget.record['id']?.toString(),
                      initialRecord: widget.record,
                      adminMode: true,
                    ),
                  ),
                );

                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
          IconButton(
            tooltip: tr('管理者'),
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminLoginPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > 900
                ? 900.0
                : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _infoItem(tr('化驗類型'), tr(mergeType)),
                                _infoItem(tr('操作員'), user),
                                _infoItem(tr('時間'), time),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 合併存檔只顯示一條線，避免手機畫面過度擁擠。
                            Row(
                              children: [
                                Expanded(
                                  child: _lineSelector(
                                    leftLine,
                                    selectedLine == leftLine,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _lineSelector(
                                    rightLine,
                                    selectedLine == rightLine,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildSelectedLine(selectedLine, selectedChemicals),

                    if (widget.adminMode)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: tr('刪除'),
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await _deleteWithAdmin(context);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _lineSelector(String line, bool selected) {
    final accent = line == 'A線'
        ? const Color(0xFF2F6FC4)
        : line == 'B線'
        ? const Color(0xFF3B963D)
        : line == 'D線'
        ? const Color(0xFF6B43A4)
        : const Color(0xFF2C8D89);

    return InkWell(
      onTap: () => setState(() => selectedLine = line),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accent : Colors.black12,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            tr(line),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: selected ? Colors.white : accent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedLine(String line, Map<String, dynamic> chemicals) {
    final tanks = getTankInfo(line);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE4DE),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            '${tr(line)}｜${tr('化驗結果')}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4B2714),
            ),
          ),
        ),
        const SizedBox(height: 6),
        ...tanks.map((tank) {
          final keys = getSettings(line).keys.where((key) {
            final data = Map<String, dynamic>.from(chemicals[key] ?? {});
            final storedTank = data['tank']?.toString() ?? '';
            return storedTank == tank.name ||
                (storedTank.isEmpty && getTankName(line, key) == tank.name);
          }).toList();

          if (keys.isEmpty) {
            return const SizedBox.shrink();
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 5),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE4DE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tr(tank.name),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${formatNumber(tank.volume)} L',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  ...keys.map((key) {
                    final setting = getSettings(line)[key]!;
                    final data = Map<String, dynamic>.from(
                      chemicals[key] ?? {},
                    );

                    final input = data['input']?.toString() ?? '';
                    final concentration =
                        data['concentration']?.toString() ?? '';
                    final addAmount = displayStoredAddAmount(
                      data['addAmount']?.toString() ?? '',
                    );

                    Color? addColor;
                    if (addAmount == tr('不用添加')) {
                      addColor = Colors.green;
                    } else if (addAmount.isNotEmpty && addAmount != '-') {
                      addColor = Colors.red;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              tr(setting.name),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _result(
                              tr('輸入'),
                              input.isEmpty ? '-' : input,
                            ),
                          ),
                          Expanded(
                            child: _result(
                              tr('中值'),
                              setting.middle == null
                                  ? tr('無中值')
                                  : formatNumber(setting.middle!),
                            ),
                          ),
                          Expanded(
                            child: _result(
                              tr('濃度'),
                              concentration.isEmpty ? '-' : concentration,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _result(
                              tr('需添加量'),
                              addAmount.isEmpty ? '-' : addAmount,
                              valueColor: addColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _infoItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          children: [
            TextSpan(
              text: '$title：',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _result(String title, String value, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 8, color: Colors.grey)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWithAdmin(BuildContext context) async {
    // 與原本存檔查看頁一致：先走管理者刪除流程。
    if (!widget.adminMode) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('請先開啟管理模式'))));
      return;
    }

    try {
      final id = widget.record['id']?.toString();
      if (id != null && id.isNotEmpty) {
        await FirebaseAnalysisManager.deleteRecord(id);
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('刪除失敗'))));
    }
  }
}

class RecordEditPage extends StatefulWidget {
  final Map<String, dynamic> record;
  final String userName;
  final bool adminMode;

  RecordEditPage({
    super.key,
    required this.record,
    required this.userName,
    this.adminMode = false,
  });

  @override
  State<RecordEditPage> createState() => _RecordEditPageState();
}

class _RecordEditPageState extends State<RecordEditPage> {
  late String lineName;

  final Map<String, TextEditingController> controllers = {};

  final TextEditingController beforeWeightController = TextEditingController();

  final TextEditingController afterWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();

    lineName = widget.record['line'].toString();

    final settings = getSettings(lineName);

    final chemicals = Map<String, dynamic>.from(
      widget.record['chemicals'] ?? {},
    );

    for (final key in settings.keys) {
      final input = chemicals[key]?['input']?.toString() ?? '';

      controllers[key] = TextEditingController(text: input);
    }

    beforeWeightController.text =
        widget.record['beforeWeight']?.toString() ?? '';

    afterWeightController.text = widget.record['afterWeight']?.toString() ?? '';
  }

  double? parse(String value) {
    return double.tryParse(value.trim());
  }

  double? concentration(String key, String value) {
    final setting = getSettings(lineName)[key];

    if (setting == null) {
      return null;
    }

    final number = parse(value);

    if (number == null) {
      return null;
    }

    if (setting.direct) {
      return roundToTenth(number);
    }

    return roundToTenth(number * setting.factor);
  }

  double? addAmount(String key, String value) {
    final setting = getSettings(lineName)[key];

    if (setting == null || setting.middle == null || setting.addPerPoint <= 0) {
      return null;
    }

    final current = concentration(key, value);

    if (current == null) {
      return null;
    }

    final middle = roundToTenth(setting.middle!);
    final actual = roundToTenth(current);

    if (actual >= middle) {
      return 0;
    }

    final deficit = roundToTenth(middle - actual);

    // ========================================================
    // 預浸槽 CBBA-A 特別處理
    // ========================================================

    if (key == 'pre_cbba') {
      final steps = (deficit * 10).round();

      if (steps <= 0) {
        return 0;
      }

      final addPerPoint = lineName == 'A線' ? 1.0 : 0.5;

      return roundToTenth(steps * addPerPoint);
    }

    final steps = (deficit * 10).round();

    if (steps <= 0) {
      return 0;
    }

    return roundToTenth(steps * setting.addPerPoint);
  }

  String formatNumber(double value) {
    return value.toStringAsFixed(1);
  }

  double? biteAmount() {
    final before = parse(beforeWeightController.text);

    final after = parse(afterWeightController.text);

    if (before == null || after == null) {
      return null;
    }

    if (lineName == 'D線' || lineName == 'E線') {
      return (before - after) * 555.56 / 100 * 40;
    }

    return (before - after) / 100 * 21910;
  }

  Future<void> save() async {
    if (!widget.adminMode) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr('只有管理者可以修改化驗紀錄'))));
      }
      return;
    }

    final settings = getSettings(lineName);

    final chemicals = <String, dynamic>{};

    for (final entry in settings.entries) {
      final key = entry.key;

      final input = controllers[key]!.text.trim();

      final concentrationValue = concentration(key, input);

      final add = addAmount(key, input);

      chemicals[key] = {
        'input': input,
        'concentration': concentrationValue == null
            ? ''
            : formatNumber(concentrationValue),
        'addAmountValue': add,
        'addAmountNoNeed': add != null && add <= 0,
        'addAmount': add == null
            ? ''
            : add <= 0
            ? 'NO_ADD'
            : '${formatNumber(add)} ${entry.value.unit}',
        'tank': getTankName(lineName, key),
      };
    }

    final before = parse(beforeWeightController.text);

    final after = parse(afterWeightController.text);

    final bite = before == null || after == null
        ? null
        : (lineName == 'D線' || lineName == 'E線')
        ? (before - after) * 555.56 / 100 * 40
        : (before - after) / 100 * 21910;

    final updated = Map<String, dynamic>.from(widget.record);

    updated['chemicals'] = chemicals;

    updated['beforeWeight'] = beforeWeightController.text.trim();

    updated['afterWeight'] = afterWeightController.text.trim();

    updated['biteAmount'] = bite == null ? '' : formatNumber(bite);

    // 修改既有紀錄時，永遠保留原本化驗人員名稱。
    final originalUser = widget.record['user']?.toString().trim();
    if (originalUser != null && originalUser.isNotEmpty) {
      updated['user'] = originalUser;
    }

    final id = widget.record['id']?.toString();

    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('找不到雲端存檔識別碼'))));
      return;
    }

    try {
      await FirebaseAnalysisManager.updateRecord(id, updated);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('修改已儲存至雲端'))));

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('雲端修改失敗，請稍後再試'))));
    }
  }

  Widget input(String key) {
    final setting = getSettings(lineName)[key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: '${tr(setting.name)}｜${tr('滴定值')}',
          hintText: tr('滴定值'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget resultPreview(String key) {
    final setting = getSettings(lineName)[key]!;

    final value = controllers[key]!.text;

    final concentrationValue = concentration(key, value);

    final add = addAmount(key, value);

    String addText;

    if (add == null) {
      addText = '-';
    } else if (add <= 0) {
      addText = tr('不用添加');
    } else {
      addText = '${formatNumber(add)} ${setting.unit}';
    }

    Color? addColor;

    if (addText == tr('不用添加')) {
      addColor = Colors.green;
    } else if (addText != '-') {
      addColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                tr(setting.name),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _editResult(
                tr('中值'),
                setting.middle == null
                    ? tr('無中值')
                    : formatNumber(setting.middle!),
              ),
            ),
            Expanded(
              child: _editResult(
                tr('濃度'),
                concentrationValue == null
                    ? '-'
                    : formatNumber(concentrationValue),
              ),
            ),
            Expanded(
              flex: 2,
              child: _editResult(tr('需添加量'), addText, valueColor: addColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editResult(String title, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey, fontSize: 11)),
        SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.adminMode) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('化驗結果'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              tr('只有管理者可以修改化驗紀錄'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    final settings = getSettings(lineName);

    final tanks = getTankInfo(lineName);

    return Scaffold(
      appBar: AppBar(title: Text('${tr(lineName)}｜${tr('修改化驗資料')}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Color(0xFFEDE4DE),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                tr('修改後會重新計算濃度、需添加量及咬食量'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(height: 12),

          TextField(
            controller: beforeWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: tr('未棕化重量'),
              suffixText: 'g',
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: 10),

          TextField(
            controller: afterWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: tr('已棕化重量'),
              suffixText: 'g',
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: 15),

          Card(
            color: Color(0xFFEDE4DE),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr('咬食量'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  Text(
                    biteAmount() == null ? '-' : formatNumber(biteAmount()!),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 15),

          ...tanks.map(
            (tank) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tr(tank.name),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${tr('槽體積：')}${formatNumber(tank.volume)} L',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                ...tank.keys
                    .where((key) => settings.containsKey(key))
                    .map(
                      (key) =>
                          Column(children: [input(key), resultPreview(key)]),
                    ),

                SizedBox(height: 8),
              ],
            ),
          ),

          SizedBox(height: 12),

          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: save,
              icon: Icon(Icons.save_outlined),
              label: Text(
                tr('儲存修改'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }

    beforeWeightController.dispose();
    afterWeightController.dispose();

    super.dispose();
  }
}
