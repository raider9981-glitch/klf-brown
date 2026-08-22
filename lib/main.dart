// ============================================================
// KLF-棕化
// 版本：v1.2.3
//
// 本次版本修改內容：
// 1. 中文／泰文改為全系統語言切換
// 2. 語言切換後所有頁面同步切換
// 3. 登入頁中文／泰文
// 4. 管理者登入中文／泰文
// 5. 管理者設定中文／泰文
// 6. 首頁中文／泰文
// 7. A／B 線選擇中文／泰文
// 8. 化驗頁中文／泰文
// 9. 化驗結果中文／泰文
// 10. 化驗存檔中文／泰文
// 11. 修改化驗資料中文／泰文
// 12. QR Code 頁面中文／泰文
// 13. 所有按鈕、提示、錯誤訊息同步切換
// 14. 語言切換跨頁面維持
// 15. 保留原有化驗計算公式
// 16. 保留一頁式化驗結果
// 17. 化驗結果不顯示 A／B 線選項
// 18. 保留 Firebase Cloud Firestore
// 19. 保留授權手機共享化驗結果
// 20. 保留管理者、授權、QR Code
// 21. A 線槽體積：500 / 800 / 700 / 1400 L
// 22. B 線槽體積：246 / 582 / 440 / 1560 L
//
// ============================================================

import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KLFApp());
}

// ============================================================
// Firebase 授權管理
// ============================================================

class FirebaseUserManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = 'authorized_users';

  static Future<List<String>> getUsers() async {
    final snapshot = await _firestore
        .collection(collectionName)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => (doc.data()['name'] ?? '').toString().trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  static Future<bool> isAuthorized(String name) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) return false;

    final snapshot = await _firestore
        .collection(collectionName)
        .where('name', isEqualTo: cleanName)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  static Future<bool> addUser(String name) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) return false;

    if (await isAuthorized(cleanName)) return false;

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

// ============================================================
// Firebase 化驗資料
// ============================================================

class FirebaseAnalysisManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = 'analysis_records';

  static Future<String> addRecord(Map<String, dynamic> record) async {
    final doc = _firestore.collection(collectionName).doc();

    final data = Map<String, dynamic>.from(record);

    data.remove('id');
    data.remove('time');

    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await doc.set(data);

    return doc.id;
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

  static Stream<List<Map<String, dynamic>>> recordsStream() {
    return _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());

            data['id'] = doc.id;

            final timestamp = data['createdAt'];

            if (timestamp is Timestamp) {
              data['time'] = timestamp.toDate().toIso8601String();
            } else if (timestamp is DateTime) {
              data['time'] = timestamp.toIso8601String();
            } else {
              data['time'] = '';
            }

            final updated = data['updatedAt'];

            if (updated is Timestamp) {
              data['editedTime'] = updated.toDate().toIso8601String();
            }

            return data;
          }).toList();
        });
  }
}

// ============================================================
// 系統設定
// ============================================================

class KLFConfig {
  static const String appName = 'KLF-棕化';
  static const String version = 'v1.2.3';
  static const String adminPassword = '0';

  static const String websiteUrl =
      'https://raider9981-glitch.github.io/klf-brown/';

  static const String storageDeviceUser = 'klf_device_user';
  static const String storageLanguage = 'klf_language';
}

// ============================================================
// 本機 Storage
// ============================================================

class LocalStorageHelper {
  static String? get(String key) => html.window.localStorage[key];

  static void set(String key, String value) {
    html.window.localStorage[key] = value;
  }

  static void remove(String key) {
    html.window.localStorage.remove(key);
  }

  static String? getDeviceUser() {
    return get(KLFConfig.storageDeviceUser);
  }

  static void saveDeviceUser(String name) {
    set(KLFConfig.storageDeviceUser, name);
  }

  static void clearDeviceUser() {
    remove(KLFConfig.storageDeviceUser);
  }

  static KLFLanguage getLanguage() {
    return get(KLFConfig.storageLanguage) == 'thai'
        ? KLFLanguage.thai
        : KLFLanguage.chinese;
  }

  static void saveLanguage(KLFLanguage language) {
    set(
      KLFConfig.storageLanguage,
      language == KLFLanguage.thai ? 'thai' : 'chinese',
    );
  }
}

// ============================================================
// 全系統語言
// ============================================================

enum KLFLanguage { chinese, thai }

class KLFGlobalLanguage {
  static final ValueNotifier<KLFLanguage> notifier = ValueNotifier<KLFLanguage>(
    LocalStorageHelper.getLanguage(),
  );

  static KLFLanguage get current => notifier.value;

  static bool get isThai => current == KLFLanguage.thai;

  static void toggle() {
    notifier.value = isThai ? KLFLanguage.chinese : KLFLanguage.thai;

    LocalStorageHelper.saveLanguage(notifier.value);
  }

  static String t(String zh, String th) => isThai ? th : zh;
}

// ============================================================
// 語言文字
// ============================================================

class KLFText {
  static String languageButton() => KLFGlobalLanguage.t('ไทย', '中文');

  static String loginTitle() =>
      KLFGlobalLanguage.t('KLF-棕化', 'เข้าสู่ระบบ KLF-棕化');

  static String loginSubtitle() =>
      KLFGlobalLanguage.t('棕化藥水分析管理系統', 'ระบบจัดการวิเคราะห์น้ำยาเคมี');

  static String authorizedName() =>
      KLFGlobalLanguage.t('授權人員名稱', 'ชื่อผู้ได้รับอนุญาต');

  static String authorizedHint() =>
      KLFGlobalLanguage.t('請輸入已授權名稱', 'กรุณากรอกชื่อที่ได้รับอนุญาต');

  static String login() => KLFGlobalLanguage.t('登入', 'เข้าสู่ระบบ');

  static String firstLoginHint() => KLFGlobalLanguage.t(
    '首次登入需輸入已授權名稱登入',
    'การเข้าสู่ระบบครั้งแรกต้องใช้ชื่อที่ได้รับอนุญาต',
  );

  static String enterAuthorizedName() =>
      KLFGlobalLanguage.t('請輸入授權名稱', 'กรุณากรอกชื่อที่ได้รับอนุญาต');

  static String unauthorized() => KLFGlobalLanguage.t(
    '名稱未授權，無法登入',
    'ชื่อไม่ได้รับอนุญาต ไม่สามารถเข้าสู่ระบบได้',
  );

  static String firebaseError() => KLFGlobalLanguage.t(
    '無法連線 Firebase，請確認網路連線',
    'ไม่สามารถเชื่อมต่อ Firebase กรุณาตรวจสอบเครือข่าย',
  );

  static String adminLogin() =>
      KLFGlobalLanguage.t('管理者登入', 'เข้าสู่ระบบผู้ดูแล');

  static String adminPassword() =>
      KLFGlobalLanguage.t('管理者密碼', 'รหัสผ่านผู้ดูแล');

  static String loginAdmin() =>
      KLFGlobalLanguage.t('登入管理者', 'เข้าสู่ระบบผู้ดูแล');

  static String wrongAdminPassword() =>
      KLFGlobalLanguage.t('管理者密碼錯誤', 'รหัสผ่านผู้ดูแลไม่ถูกต้อง');

  static String adminSettings() =>
      KLFGlobalLanguage.t('管理者設定', 'การตั้งค่าผู้ดูแล');

  static String addAuthorizedUser() =>
      KLFGlobalLanguage.t('新增授權人員', 'เพิ่มผู้ได้รับอนุญาต');

  static String addAuthorizedDescription() => KLFGlobalLanguage.t(
    '新增後會同步到 Firebase，其他手機也可以使用。',
    'เมื่อเพิ่มแล้วจะซิงค์กับ Firebase และโทรศัพท์เครื่องอื่นสามารถใช้งานได้',
  );

  static String authorizedUsers() =>
      KLFGlobalLanguage.t('已授權人員', 'รายชื่อผู้ได้รับอนุญาต');

  static String noAuthorizedUsers() =>
      KLFGlobalLanguage.t('目前尚未建立授權人員', 'ยังไม่มีรายชื่อผู้ได้รับอนุญาต');

  static String firebaseAuthorization() =>
      KLFGlobalLanguage.t('Firebase 雲端授權', 'การอนุญาตผ่าน Firebase');

  static String add() => KLFGlobalLanguage.t('新增', 'เพิ่ม');

  static String delete() => KLFGlobalLanguage.t('刪除', 'ลบ');

  static String cancel() => KLFGlobalLanguage.t('取消', 'ยกเลิก');

  static String confirm() => KLFGlobalLanguage.t('確認', 'ยืนยัน');

  static String refresh() => KLFGlobalLanguage.t('重新整理', 'รีเฟรช');

  static String clear() => KLFGlobalLanguage.t('清除', 'ล้าง');

  static String deviceLoginRecord() =>
      KLFGlobalLanguage.t('本設備登入記錄', 'ประวัติการเข้าสู่ระบบของอุปกรณ์นี้');

  static String noRecord() => KLFGlobalLanguage.t('目前沒有記錄', 'ไม่มีข้อมูล');

  static String cloudSource() =>
      KLFGlobalLanguage.t('化驗資料來源', 'แหล่งข้อมูลการวิเคราะห์');

  static String cloudShared() => KLFGlobalLanguage.t('雲端共享', 'แชร์บนคลาวด์');

  static String systemVersion() => KLFGlobalLanguage.t('系統版本', 'เวอร์ชันระบบ');

  static String homeTitle() => KLFGlobalLanguage.t('KLF-棕化', 'KLF-棕化');

  static String productionLine() =>
      KLFGlobalLanguage.t('棕化水平生產線', 'สายการผลิตบราวนิ่ง');

  static String chooseLine() => KLFGlobalLanguage.t(
    '請選擇需要進行藥水分析的生產線',
    'กรุณาเลือกสายการผลิตที่ต้องการวิเคราะห์น้ำยา',
  );

  static String lineA() => KLFGlobalLanguage.t('A線', 'สาย A');

  static String lineB() => KLFGlobalLanguage.t('B線', 'สาย B');

  static String lineASubtitle() =>
      KLFGlobalLanguage.t('棕化水平生產線 A', 'สายการผลิตบราวนิ่ง A');

  static String lineBSubtitle() =>
      KLFGlobalLanguage.t('棕化水平生產線 B', 'สายการผลิตบราวนิ่ง B');

  static String enterAnalysis() =>
      KLFGlobalLanguage.t('進入化驗', 'เข้าสู่การวิเคราะห์');

  static String records() => KLFGlobalLanguage.t('化驗存檔', 'ประวัติการวิเคราะห์');

  static String recordsDescription() => KLFGlobalLanguage.t(
    '查看所有手機共享的歷史化驗資料',
    'ดูข้อมูลการวิเคราะห์ย้อนหลังที่แชร์กับโทรศัพท์ทั้งหมด',
  );

  static String analysisCycle() =>
      KLFGlobalLanguage.t('化驗週期', 'รอบการวิเคราะห์');

  static String analysisCycleDescription() =>
      KLFGlobalLanguage.t('每 4 小時進行一次藥水分析', 'วิเคราะห์น้ำยาทุก 4 ชั่วโมง');

  static String admin() => KLFGlobalLanguage.t('管理者', 'ผู้ดูแล');

  static String qrInvite() => KLFGlobalLanguage.t('邀請開啟網站', 'เชิญเปิดเว็บไซต์');

  static String qrTitle() =>
      KLFGlobalLanguage.t('KLF-棕化網站 QR Code', 'QR Code เว็บไซต์ KLF-棕化');

  static String qrDescription() => KLFGlobalLanguage.t(
    '使用手機掃描 QR Code 即可開啟 KLF-棕化網站',
    'สแกน QR Code ด้วยโทรศัพท์เพื่อเปิดเว็บไซต์ KLF-棕化',
  );

  static String qrLoginHint() => KLFGlobalLanguage.t(
    '掃描後仍需使用已授權名稱登入',
    'หลังสแกนแล้วยังคงต้องเข้าสู่ระบบด้วยชื่อที่ได้รับอนุญาต',
  );

  static String close() => KLFGlobalLanguage.t('關閉', 'ปิด');

  static String analysisTitle(String line) =>
      KLFGlobalLanguage.t('$line｜藥水化驗', '$line｜วิเคราะห์น้ำยา');

  static String analyst(String name) =>
      KLFGlobalLanguage.t('化驗人員：$name', 'ผู้วิเคราะห์: $name');

  static String bite() => KLFGlobalLanguage.t('咬食量', 'ปริมาณการกัด');

  static String result() => KLFGlobalLanguage.t('化驗結果', 'ผลการวิเคราะห์');

  static String concentration() => KLFGlobalLanguage.t('濃度', 'ความเข้มข้น');

  static String input() => KLFGlobalLanguage.t('輸入', 'ค่าที่ป้อน');

  static String middle() => KLFGlobalLanguage.t('中值', 'ค่ากลาง');

  static String addAmount() => KLFGlobalLanguage.t('需添加量', 'ปริมาณที่ต้องเติม');

  static String noNeedAdd() => KLFGlobalLanguage.t('不用添加', 'ไม่ต้องเติม');

  static String titration() => KLFGlobalLanguage.t('滴定值', 'ค่าการไทเทรต');

  static String directConcentration() =>
      KLFGlobalLanguage.t('濃度', 'ความเข้มข้นโดยตรง');

  static String enterTitration() =>
      KLFGlobalLanguage.t('輸入滴定值', 'กรอกค่าการไทเทรต');

  static String enterConcentration() =>
      KLFGlobalLanguage.t('直接輸入濃度', 'กรอกความเข้มข้นโดยตรง');

  static String unbrownedWeight() =>
      KLFGlobalLanguage.t('未棕化重量', 'น้ำหนักก่อนบราวนิ่ง');

  static String brownedWeight() =>
      KLFGlobalLanguage.t('已棕化重量', 'น้ำหนักหลังบราวนิ่ง');

  static String biteDescription() => KLFGlobalLanguage.t(
    '未棕化重量、已棕化重量由化驗人員輸入，系統自動計算。',
    'กรอกน้ำหนักก่อนและหลังบราวนิ่ง ระบบจะคำนวณอัตโนมัติ',
  );

  static String biteFormula() => KLFGlobalLanguage.t(
    '公式：(未棕化重量－已棕化重量) ÷ 100 × 21910',
    'สูตร: (น้ำหนักก่อนบราวนิ่ง－น้ำหนักหลังบราวนิ่ง) ÷ 100 × 21910',
  );

  static String save() =>
      KLFGlobalLanguage.t('化驗完成並存檔', 'วิเคราะห์เสร็จและบันทึก');

  static String saving() =>
      KLFGlobalLanguage.t('雲端儲存中...', 'กำลังบันทึกบนคลาวด์...');

  static String savedSuccess() => KLFGlobalLanguage.t(
    '化驗資料已儲存至雲端，所有授權手機皆可查看',
    'บันทึกข้อมูลบนคลาวด์แล้ว โทรศัพท์ที่ได้รับอนุญาตทั้งหมดสามารถดูได้',
  );

  static String saveFailed() => KLFGlobalLanguage.t(
    '雲端存檔失敗，請確認 Firebase 連線與權限',
    'บันทึกบนคลาวด์ไม่สำเร็จ กรุณาตรวจสอบ Firebase',
  );

  static String firstTank() =>
      KLFGlobalLanguage.t('第一槽｜酸洗槽', 'ถังที่ 1｜ถังกรดล้าง');

  static String secondTank() =>
      KLFGlobalLanguage.t('第二槽｜清潔槽', 'ถังที่ 2｜ถังทำความสะอาด');

  static String thirdTank() =>
      KLFGlobalLanguage.t('第三槽｜預浸槽', 'ถังที่ 3｜ถังพรีดิป');

  static String fourthTank() =>
      KLFGlobalLanguage.t('第四槽｜棕化槽', 'ถังที่ 4｜ถังบราวนิ่ง');

  static String acidDescription() =>
      KLFGlobalLanguage.t('硫酸、雙氧水', 'กรดซัลฟิวริก, ไฮโดรเจนเปอร์ออกไซด์');

  static String cleanDescription() => KLFGlobalLanguage.t('HL-II', 'HL-II');

  static String preDescription() =>
      KLFGlobalLanguage.t('雙氧水、CBBA-A', 'ไฮโดรเจนเปอร์ออกไซด์, CBBA-A');

  static String brownDescription() => KLFGlobalLanguage.t(
    '硫酸、雙氧水、CBBA-A、銅離子',
    'กรดซัลฟิวริก, ไฮโดรเจนเปอร์ออกไซด์, CBBA-A, ทองแดง',
  );

  static String tankVolume() => KLFGlobalLanguage.t('槽體積', 'ปริมาตรถัง');

  static String editRecord() =>
      KLFGlobalLanguage.t('修改化驗資料', 'แก้ไขข้อมูลการวิเคราะห์');

  static String modifiedSync() => KLFGlobalLanguage.t(
    '修改後會重新計算濃度、需添加量及咬食量，並同步到所有手機。',
    'หลังแก้ไขระบบจะคำนวณความเข้มข้น ปริมาณเติม และปริมาณการกัดใหม่ และซิงค์กับโทรศัพท์ทั้งหมด',
  );

  static String saveEdit() => KLFGlobalLanguage.t('儲存修改', 'บันทึกการแก้ไข');

  static String cloudSaving() =>
      KLFGlobalLanguage.t('雲端儲存中...', 'กำลังบันทึกบนคลาวด์...');

  static String modifySuccess() => KLFGlobalLanguage.t(
    '修改已儲存至雲端，所有手機同步更新',
    'บันทึกการแก้ไขบนคลาวด์แล้ว โทรศัพท์ทั้งหมดได้รับการอัปเดต',
  );

  static String modifyFailed() => KLFGlobalLanguage.t(
    '修改失敗，請確認 Firebase 連線與權限',
    'แก้ไขไม่สำเร็จ กรุณาตรวจสอบ Firebase และสิทธิ์',
  );

  static String viewEdit() => KLFGlobalLanguage.t('查看／修改', 'ดู／แก้ไข');

  static String adminDelete() => KLFGlobalLanguage.t('管理者刪除', 'ลบโดยผู้ดูแล');

  static String adminVerification() =>
      KLFGlobalLanguage.t('管理者驗證', 'ยืนยันผู้ดูแล');

  static String deleteNeedAdmin() => KLFGlobalLanguage.t(
    '刪除化驗資料需要管理者權限。',
    'การลบข้อมูลการวิเคราะห์ต้องใช้สิทธิ์ผู้ดูแล',
  );

  static String deleteCloudTitle() =>
      KLFGlobalLanguage.t('刪除雲端存檔', 'ลบข้อมูลบนคลาวด์');

  static String deleteCloudContent() => KLFGlobalLanguage.t(
    '確定要永久刪除這筆化驗資料嗎？\n\n刪除後所有手機都會同步消失。',
    'ต้องการลบข้อมูลการวิเคราะห์นี้อย่างถาวรหรือไม่?\n\nหลังลบแล้วข้อมูลจะหายจากโทรศัพท์ทั้งหมด',
  );

  static String noAnalysisRecords() =>
      KLFGlobalLanguage.t('目前沒有化驗存檔', 'ยังไม่มีข้อมูลการวิเคราะห์');

  static String cloudSync() => KLFGlobalLanguage.t('雲端同步', 'ซิงค์บนคลาวด์');

  static String offline() => KLFGlobalLanguage.t('離線', 'ออฟไลน์');

  static String cloudReadFailed() => KLFGlobalLanguage.t(
    '無法讀取雲端化驗資料',
    'ไม่สามารถอ่านข้อมูลการวิเคราะห์บนคลาวด์',
  );

  static String cloudReadHint() => KLFGlobalLanguage.t(
    '請確認網路與 Firebase Firestore 權限設定。',
    'กรุณาตรวจสอบเครือข่ายและสิทธิ์ Firebase Firestore',
  );

  static String reconnect() => KLFGlobalLanguage.t('重新連線', 'เชื่อมต่อใหม่');

  static String deleteUserConfirm(String name) => KLFGlobalLanguage.t(
    '確定要刪除「$name」嗎？\n\n刪除後所有裝置都將無法再使用此名稱登入。',
    'ต้องการลบ "$name" หรือไม่?\n\nหลังลบแล้วอุปกรณ์ทั้งหมดจะไม่สามารถใช้ชื่อนี้เข้าสู่ระบบได้',
  );

  static String deleteUserTitle() =>
      KLFGlobalLanguage.t('刪除授權人員', 'ลบผู้ได้รับอนุญาต');

  static String addUserHint() =>
      KLFGlobalLanguage.t('例如：王小明', 'เช่น: Wang Xiaoming');

  static String userAdded(String name) =>
      KLFGlobalLanguage.t('已新增授權人員：$name', 'เพิ่มผู้ได้รับอนุญาตแล้ว: $name');

  static String userDeleted(String name) =>
      KLFGlobalLanguage.t('已刪除：$name', 'ลบแล้ว: $name');

  static String duplicateUser() =>
      KLFGlobalLanguage.t('這個名稱已經存在', 'ชื่อนี้มีอยู่แล้ว');

  static String noName() =>
      KLFGlobalLanguage.t('請輸入授權人員名稱', 'กรุณากรอกชื่อผู้ได้รับอนุญาต');

  static String firebaseUsersFailed() => KLFGlobalLanguage.t(
    '無法讀取 Firebase 授權名單',
    'ไม่สามารถอ่านรายชื่อผู้ได้รับอนุญาตจาก Firebase',
  );

  static String addFailed() => KLFGlobalLanguage.t(
    '新增失敗，請確認 Firebase 連線',
    'เพิ่มไม่สำเร็จ กรุณาตรวจสอบ Firebase',
  );

  static String deleteFailed() => KLFGlobalLanguage.t(
    '刪除失敗，請確認 Firebase 連線',
    'ลบไม่สำเร็จ กรุณาตรวจสอบ Firebase',
  );

  static String deviceCleared() => KLFGlobalLanguage.t(
    '本設備登入記錄已清除',
    'ล้างประวัติการเข้าสู่ระบบของอุปกรณ์นี้แล้ว',
  );

  static String userUpdated() => KLFGlobalLanguage.t(
    '已從雲端刪除，所有手機同步更新',
    'ลบจากคลาวด์แล้ว โทรศัพท์ทั้งหมดได้รับการอัปเดต',
  );

  static String recordDeleteFailed() => KLFGlobalLanguage.t(
    '刪除失敗，請確認 Firebase 權限',
    'ลบไม่สำเร็จ กรุณาตรวจสอบสิทธิ์ Firebase',
  );
}

// ============================================================
// App
// ============================================================

class KLFApp extends StatelessWidget {
  const KLFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KLFLanguage>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, __, ___) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: KLFConfig.appName,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6B3F22),
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F6F7),
          ),
          home: const StartupPage(),
        );
      },
    );
  }
}

// ============================================================
// 共用語言按鈕
// ============================================================

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: KLFGlobalLanguage.toggle,
      icon: const Icon(Icons.language, size: 18),
      label: Text(KLFText.languageButton()),
    );
  }
}

// ============================================================
// 啟動頁
// ============================================================

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

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

    if (deviceUser != null && deviceUser.trim().isNotEmpty) {
      try {
        final authorized = await FirebaseUserManager.isAuthorized(deviceUser);

        if (!mounted) return;

        if (authorized) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(userName: deviceUser)),
          );
          return;
        }
      } catch (_) {}

      LocalStorageHelper.clearDeviceUser();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// ============================================================
// 登入
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
        _errorMessage = KLFText.enterAuthorizedName();
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final authorized = await FirebaseUserManager.isAuthorized(name);

      if (!mounted) return;

      if (authorized) {
        LocalStorageHelper.saveDeviceUser(name);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(userName: name)),
        );
      } else {
        setState(() {
          _errorMessage = KLFText.unauthorized();
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = KLFText.firebaseError();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KLFLanguage>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: const LanguageButton(),
                          ),
                          const SizedBox(height: 5),
                          const Icon(
                            Icons.science_outlined,
                            size: 70,
                            color: Color(0xFF6B3F22),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            KLFText.loginTitle(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            KLFText.loginSubtitle(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 35),
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(),
                            enabled: !_loading,
                            decoration: InputDecoration(
                              labelText: KLFText.authorizedName(),
                              hintText: KLFText.authorizedHint(),
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              child: _loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      KLFText.login(),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            KLFText.firstLoginHint(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 15),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 25),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminLoginPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.admin_panel_settings_outlined,
                            ),
                            label: Text(KLFText.adminLogin()),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            KLFConfig.version,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
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
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// ============================================================
// 管理者登入
// ============================================================

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  void _login() {
    if (_passwordController.text == KLFConfig.adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } else {
      setState(() {
        _errorMessage = KLFText.wrongAdminPassword();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KLFLanguage>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          appBar: AppBar(
            title: Text(KLFText.adminLogin()),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: LanguageButton(),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.admin_panel_settings, size: 65),
                        const SizedBox(height: 20),
                        Text(
                          KLFText.adminLogin(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: KLFText.adminPassword(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: Text(KLFText.loginAdmin()),
                          ),
                        ),
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 15),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

// ============================================================
// 管理者頁面
// ============================================================

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _nameController = TextEditingController();

  List<String> _users = [];

  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
    });

    try {
      final users = await FirebaseUserManager.getUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(KLFText.firebaseUsersFailed());
    }
  }

  Future<void> _addUser() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage(KLFText.noName());
      return;
    }

    setState(() {
      _adding = true;
    });

    try {
      final added = await FirebaseUserManager.addUser(name);

      if (!mounted) return;

      if (!added) {
        _showMessage(KLFText.duplicateUser());
        return;
      }

      _nameController.clear();

      await _loadUsers();

      if (!mounted) return;

      _showMessage(KLFText.userAdded(name));
    } catch (_) {
      if (!mounted) return;

      _showMessage(KLFText.addFailed());
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
          title: Text(KLFText.deleteUserTitle()),
          content: Text(KLFText.deleteUserConfirm(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(KLFText.cancel()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(KLFText.delete()),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseUserManager.deleteUser(name);

      if (!mounted) return;

      await _loadUsers();

      if (!mounted) return;

      _showMessage(KLFText.userDeleted(name));
    } catch (_) {
      if (!mounted) return;

      _showMessage(KLFText.deleteFailed());
    }
  }

  void _clearCurrentDevice() {
    LocalStorageHelper.clearDeviceUser();
    _showMessage(KLFText.deviceCleared());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KLFLanguage>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          appBar: AppBar(
            title: Text(KLFText.adminSettings()),
            actions: [
              const LanguageButton(),
              IconButton(
                tooltip: KLFText.refresh(),
                icon: const Icon(Icons.refresh),
                onPressed: _loading ? null : _loadUsers,
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            KLFText.addAuthorizedUser(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            KLFText.addAuthorizedDescription(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  enabled: !_adding,
                                  onSubmitted: (_) => _addUser(),
                                  decoration: InputDecoration(
                                    labelText: KLFText.authorizedName(),
                                    hintText: KLFText.addUserHint(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _adding ? null : _addUser,
                                  icon: _adding
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.add),
                                  label: Text(KLFText.add()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                                  KLFText.authorizedUsers(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_loading)
                                const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          if (!_loading && _users.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  KLFText.noAuthorizedUsers(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ..._users.map(
                            (name) => ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                KLFText.firebaseAuthorization(),
                                style: const TextStyle(color: Colors.green),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteUser(name),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.devices),
                      title: Text(KLFText.deviceLoginRecord()),
                      subtitle: Text(
                        LocalStorageHelper.getDeviceUser() ??
                            KLFText.noRecord(),
                      ),
                      trailing: TextButton(
                        onPressed: _clearCurrentDevice,
                        child: Text(KLFText.clear()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.cloud_done,
                        color: Colors.green,
                      ),
                      title: Text(KLFText.cloudSource()),
                      subtitle: const Text('Firebase Cloud Firestore'),
                      trailing: Text(
                        KLFText.cloudShared(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(KLFText.systemVersion()),
                      trailing: const Text(KLFConfig.version),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// ============================================================
// 首頁
// ============================================================

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  void showWebsiteQrCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.qr_code_2),
              const SizedBox(width: 10),
              Expanded(child: Text(KLFText.qrTitle())),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(KLFText.qrDescription(), textAlign: TextAlign.center),
                const SizedBox(height: 20),
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
                const SizedBox(height: 18),
                Text(
                  KLFText.qrLoginHint(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(KLFText.close()),
            ),
          ],
        );
      },
    );
  }

  void openAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KLFLanguage>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              KLFText.homeTitle(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: KLFText.admin(),
                icon: const Icon(Icons.admin_panel_settings_outlined),
                onPressed: () => openAdmin(context),
              ),
              IconButton(
                tooltip: KLFText.qrInvite(),
                icon: const Icon(Icons.qr_code_2),
                onPressed: () => showWebsiteQrCode(context),
              ),
              const LanguageButton(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  child: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  children: [
                    Text(
                      KLFText.productionLine(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      KLFText.chooseLine(),
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 650) {
                          return Column(
                            children: [
                              _buildLineCard(
                                context,
                                'A線',
                                KLFText.lineA(),
                                KLFText.lineASubtitle(),
                              ),
                              const SizedBox(height: 18),
                              _buildLineCard(
                                context,
                                'B線',
                                KLFText.lineB(),
                                KLFText.lineBSubtitle(),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _buildLineCard(
                                context,
                                'A線',
                                KLFText.lineA(),
                                KLFText.lineASubtitle(),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildLineCard(
                                context,
                                'B線',
                                KLFText.lineB(),
                                KLFText.lineBSubtitle(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.folder_open,
                          color: Color(0xFF6B3F22),
                        ),
                        title: Text(
                          KLFText.records(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(KLFText.recordsDescription()),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordsPage(userName: userName),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF6B3F22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    KLFText.analysisCycle(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(KLFText.analysisCycleDescription()),
                                ],
                              ),
                            ),
                            const Text(
                              KLFConfig.version,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLineCard(
    BuildContext context,
    String lineName,
    String title,
    String subtitle,
  ) {
    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AnalysisPage(lineName: lineName, userName: userName),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.water_drop_outlined,
                size: 48,
                color: Color(0xFF6B3F22),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    KLFText.enterAnalysis(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 化驗設定
// ============================================================

class ChemicalSetting {
  final String name;
  final double? middle;
  final double factor;
  final bool direct;
  final double addPerPoint;
  final String unit;

  const ChemicalSetting({
    required this.name,
    required this.middle,
    required this.factor,
    required this.direct,
    required this.addPerPoint,
    required this.unit,
  });
}

Map<String, ChemicalSetting> getSettings(String line) {
  final isA = line == 'A線';

  return {
    'acid_sulfuric': ChemicalSetting(
      name: '硫酸',
      middle: 10.0,
      factor: 2.8,
      direct: false,
      addPerPoint: isA ? 1.0 : 0.5,
      unit: 'L',
    ),
    'acid_h2o2': const ChemicalSetting(
      name: '雙氧水',
      middle: 0.5,
      factor: 0.47,
      direct: false,
      addPerPoint: 0.5,
      unit: 'L',
    ),
    'clean_hl2': ChemicalSetting(
      name: 'HL-II',
      middle: isA ? 7.0 : 3.7,
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
    'brown_copper': const ChemicalSetting(
      name: '銅離子',
      middle: null,
      factor: 3.177,
      direct: false,
      addPerPoint: 0,
      unit: '',
    ),
  };
}

// ============================================================
// 槽體積
// ============================================================

const Map<String, Map<String, double>> tankVolumes = {
  'A線': {'acid': 500, 'clean': 800, 'pre': 700, 'brown': 1400},
  'B線': {'acid': 246, 'clean': 582, 'pre': 440, 'brown': 1560},
};

double getTankVolume(String line, String tank) {
  return tankVolumes[line]?[tank] ?? 0;
}

// ============================================================
// 數值
// ============================================================

double roundToTenth(double value) {
  return (value * 10).round() / 10;
}

String formatNumber(double value) {
  return value.toStringAsFixed(1);
}

// ============================================================
// 化驗順序
// ============================================================

const List<String> analysisOrder = [
  'acid_sulfuric',
  'acid_h2o2',
  'clean_hl2',
  'pre_h2o2',
  'pre_cbba',
  'brown_sulfuric',
  'brown_h2o2',
  'brown_cbba',
  'brown_copper',
];

const List<Map<String, dynamic>> tankOrder = [
  {
    'title': '第一槽｜酸洗槽',
    'description': '硫酸、雙氧水',
    'keys': ['acid_sulfuric', 'acid_h2o2'],
    'volumeKey': 'acid',
  },
  {
    'title': '第二槽｜清潔槽',
    'description': 'HL-II',
    'keys': ['clean_hl2'],
    'volumeKey': 'clean',
  },
  {
    'title': '第三槽｜預浸槽',
    'description': '雙氧水、CBBA-A',
    'keys': ['pre_h2o2', 'pre_cbba'],
    'volumeKey': 'pre',
  },
  {
    'title': '第四槽｜棕化槽',
    'description': '硫酸、雙氧水、CBBA-A、銅離子',
    'keys': ['brown_sulfuric', 'brown_h2o2', 'brown_cbba', 'brown_copper'],
    'volumeKey': 'brown',
  },
];

// ============================================================
// 藥品泰文
// ============================================================

String chemicalName(String name) {
  if (!KLFGlobalLanguage.isThai) return name;

  switch (name) {
    case '硫酸':
      return 'กรดซัลฟิวริก';
    case '雙氧水':
      return 'ไฮโดรเจนเปอร์ออกไซด์';
    case '銅離子':
      return 'ทองแดง';
    case '棕化':
      return 'บราวนิ่ง';
    case '酸洗':
      return 'กรดล้าง';
    case '清潔':
      return 'ทำความสะอาด';
    case '預浸':
      return 'พรีดิป';
    case '棕化槽':
      return 'ถังบราวนิ่ง';
    case '酸洗槽':
      return 'ถังกรดล้าง';
    case '清潔槽':
      return 'ถังทำความสะอาด';
    case '預浸槽':
      return 'ถังพรีดิป';
    default:
      return name;
  }
}

String tankTitle(String title) {
  if (!KLFGlobalLanguage.isThai) return title;

  switch (title) {
    case '第一槽｜酸洗槽':
      return KLFText.firstTank();
    case '第二槽｜清潔槽':
      return KLFText.secondTank();
    case '第三槽｜預浸槽':
      return KLFText.thirdTank();
    case '第四槽｜棕化槽':
      return KLFText.fourthTank();
    default:
      return title;
  }
}

String tankDescription(String description) {
  if (!KLFGlobalLanguage.isThai) return description;

  switch (description) {
    case '硫酸、雙氧水':
      return KLFText.acidDescription();
    case 'HL-II':
      return KLFText.cleanDescription();
    case '雙氧水、CBBA-A':
      return KLFText.preDescription();
    case '硫酸、雙氧水、CBBA-A、銅離子':
      return KLFText.brownDescription();
    default:
      return description;
  }
}

// ============================================================
// 化驗頁
// ============================================================

class AnalysisPage extends StatefulWidget {
  final String lineName;
  final String userName;

  const AnalysisPage({
    super.key,
    required this.lineName,
    required this.userName,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final Map<String, TextEditingController> controllers = {};

  final beforeWeightController = TextEditingController();
  final afterWeightController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    for (final key in getSettings(widget.lineName).keys) {
      controllers[key] = TextEditingController();
    }
  }

  double? parse(String value) {
    return double.tryParse(value.trim());
  }

  double? concentration(String key, String value) {
    final setting = getSettings(widget.lineName)[key];

    if (setting == null) return null;

    final number = parse(value);

    if (number == null) return null;

    if (setting.direct) {
      return roundToTenth(number);
    }

    final calculated = number * setting.factor;

    if (key == 'brown_copper') {
      return calculated;
    }

    return roundToTenth(calculated);
  }

  double? addAmount(String key, String value) {
    final setting = getSettings(widget.lineName)[key];

    if (setting == null || setting.middle == null || setting.addPerPoint <= 0) {
      return null;
    }

    final current = concentration(key, value);

    if (current == null) return null;

    final middle = roundToTenth(setting.middle!);
    final actual = roundToTenth(current);

    if (actual >= middle) return 0;

    final deficit = roundToTenth(middle - actual);
    final steps = (deficit * 10).round();

    if (steps <= 0) return 0;

    return roundToTenth(steps * setting.addPerPoint);
  }

  double? biteAmount() {
    final before = parse(beforeWeightController.text);
    final after = parse(afterWeightController.text);

    if (before == null || after == null) return null;

    return (before - after) / 100 * 21910;
  }

  String displayConcentration(String key, String value) {
    final result = concentration(key, value);

    return result == null ? '-' : formatNumber(result);
  }

  String displayMiddle(String key) {
    final setting = getSettings(widget.lineName)[key];

    if (setting == null) return '-';

    if (setting.middle == null) {
      return KLFGlobalLanguage.t('無中值', 'ไม่มีค่ากลาง');
    }

    return formatNumber(roundToTenth(setting.middle!));
  }

  String displayAddAmount(String key, String value) {
    final setting = getSettings(widget.lineName)[key];

    if (setting == null || setting.middle == null) {
      return '-';
    }

    final amount = addAmount(key, value);

    if (amount == null) return '-';

    if (amount <= 0) {
      return KLFText.noNeedAdd();
    }

    return '${formatNumber(amount)} ${setting.unit}';
  }

  Future<void> saveRecord() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
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
          'addAmount': add == null
              ? ''
              : add <= 0
              ? '不用添加'
              : '${formatNumber(add)} ${entry.value.unit}',
        };
      }

      final bite = biteAmount();

      await FirebaseAnalysisManager.addRecord({
        'line': widget.lineName,
        'user': widget.userName,
        'beforeWeight': beforeWeightController.text.trim(),
        'afterWeight': afterWeightController.text.trim(),
        'biteAmount': bite == null ? '' : formatNumber(bite),
        'chemicals': chemicals,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(KLFText.savedSuccess()),
          behavior: SnackBarBehavior.floating,
        ),
      );

      for (final controller in controllers.values) {
        controller.clear();
      }

      beforeWeightController.clear();
      afterWeightController.clear();

      setState(() {});
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(KLFText.saveFailed()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
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
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          labelText: setting.direct
              ? '${chemicalName(setting.name)}｜${KLFText.directConcentration()}'
              : '${chemicalName(setting.name)}｜${KLFText.titration()}',
          hintText: setting.direct
              ? KLFText.enterConcentration()
              : KLFText.enterTitration(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget resultBox(String title, String value) {
    Color? valueColor;

    if (title == KLFText.addAmount()) {
      if (value == KLFText.noNeedAdd()) {
        valueColor = Colors.green;
      } else if (value != '-') {
        valueColor = Colors.red;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget chemicalRow(String key) {
    final setting = getSettings(widget.lineName)[key]!;
    final controller = controllers[key]!;
    final value = controller.text;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          chemicalName(setting.name),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(flex: 3, child: inputField(key)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: resultBox(KLFText.middle(), displayMiddle(key)),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: resultBox(
                          KLFText.concentration(),
                          displayConcentration(key, value),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: resultBox(
                          KLFText.addAmount(),
                          displayAddAmount(key, value),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    chemicalName(setting.name),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(flex: 3, child: inputField(key)),
                const SizedBox(width: 5),
                Expanded(
                  child: resultBox(KLFText.middle(), displayMiddle(key)),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: resultBox(
                    KLFText.concentration(),
                    displayConcentration(key, value),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: resultBox(
                    KLFText.addAmount(),
                    displayAddAmount(key, value),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget tankCard({
    required String title,
    required String description,
    required List<String> keys,
    required String volumeKey,
  }) {
    final volume = getTankVolume(widget.lineName, volumeKey);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    tankTitle(title),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE4DE),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '${KLFText.tankVolume()}：'
                    '${formatNumber(volume)} L',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              tankDescription(description),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 7),
            ...keys.map(chemicalRow),
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
              KLFText.bite(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              KLFText.biteDescription(),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
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
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: KLFText.unbrownedWeight(),
                        suffixText: 'g',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: afterWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: KLFText.brownedWeight(),
                        suffixText: 'g',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE4DE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      KLFText.bite(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    bite == null ? '-' : formatNumber(bite),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              KLFText.biteFormula(),
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KLFLanguage>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          appBar: AppBar(
            title: Text(KLFText.analysisTitle(widget.lineName)),
            actions: const [LanguageButton()],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
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
                          const Icon(Icons.person_outline, size: 20),
                          const SizedBox(width: 7),
                          Text(
                            KLFText.analyst(widget.userName),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  biteCard(),
                  const SizedBox(height: 7),
                  tankCard(
                    title: tankOrder[0]['title'],
                    description: tankOrder[0]['description'],
                    keys: List<String>.from(tankOrder[0]['keys']),
                    volumeKey: tankOrder[0]['volumeKey'],
                  ),
                  const SizedBox(height: 7),
                  tankCard(
                    title: tankOrder[1]['title'],
                    description: tankOrder[1]['description'],
                    keys: List<String>.from(tankOrder[1]['keys']),
                    volumeKey: tankOrder[1]['volumeKey'],
                  ),
                  const SizedBox(height: 7),
                  tankCard(
                    title: tankOrder[2]['title'],
                    description: tankOrder[2]['description'],
                    keys: List<String>.from(tankOrder[2]['keys']),
                    volumeKey: tankOrder[2]['volumeKey'],
                  ),
                  const SizedBox(height: 7),
                  tankCard(
                    title: tankOrder[3]['title'],
                    description: tankOrder[3]['description'],
                    keys: List<String>.from(tankOrder[3]['keys']),
                    volumeKey: tankOrder[3]['volumeKey'],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : saveRecord,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        _saving ? KLFText.saving() : KLFText.save(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecordsPage(userName: widget.userName),
                          ),
                        );
                      },
                      icon: const Icon(Icons.folder_open),
                      label: Text(KLFText.records()),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      '${KLFConfig.appName} '
                      '${KLFConfig.version}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

// ============================================================
// 化驗存檔
// ============================================================

class RecordsPage extends StatefulWidget {
  final String userName;

  const RecordsPage({super.key, required this.userName});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
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

  void _openRecord(Map<String, dynamic> record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RecordEditPage(record: record, userName: widget.userName),
      ),
    );
  }

  void _requestAdminDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(KLFText.adminVerification()),
        content: Text(KLFText.deleteNeedAdmin()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(KLFText.cancel()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAdminPassword(id);
            },
            child: Text(KLFText.adminLogin()),
          ),
        ],
      ),
    );
  }

  void _showAdminPassword(String id) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(KLFText.adminPassword()),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          onSubmitted: (_) {
            _verifyAdminDelete(controller.text, id);
          },
          decoration: InputDecoration(
            labelText: KLFText.adminPassword(),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(KLFText.cancel()),
          ),
          ElevatedButton(
            onPressed: () {
              _verifyAdminDelete(controller.text, id);
            },
            child: Text(KLFText.confirm()),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  void _verifyAdminDelete(String password, String id) {
    if (password == KLFConfig.adminPassword) {
      Navigator.pop(context);
      _deleteRecord(id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(KLFText.wrongAdminPassword()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteRecord(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(KLFText.deleteCloudTitle()),
        content: Text(KLFText.deleteCloudContent()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(KLFText.cancel()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(KLFText.delete()),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseAnalysisManager.deleteRecord(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(KLFText.userUpdated()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(KLFText.recordDeleteFailed()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KLFLanguage>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          appBar: AppBar(
            title: Text(KLFText.records()),
            actions: [
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirebaseAnalysisManager.recordsStream(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_done,
                          size: 18,
                          color: snapshot.hasError ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          snapshot.hasError
                              ? KLFText.offline()
                              : KLFText.cloudSync(),
                          style: TextStyle(
                            fontSize: 12,
                            color: snapshot.hasError
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const LanguageButton(),
            ],
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirebaseAnalysisManager.recordsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          KLFText.cloudReadFailed(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          KLFText.cloudReadHint(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: Text(KLFText.reconnect()),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final records = snapshot.data ?? [];

              if (records.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.folder_open,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        KLFText.noAnalysisRecords(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];

                  final line = record['line'] ?? '';

                  final time = record['time'] ?? '';

                  final user = record['user'] ?? '';

                  final id = record['id']?.toString() ?? '';

                  return Card(
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        child: Text(line.toString().replaceAll('線', '')),
                      ),
                      title: Text(
                        '$line｜'
                        '${formatDate(time.toString())}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(KLFText.analyst(user.toString())),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: KLFText.viewEdit(),
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openRecord(record),
                          ),
                          IconButton(
                            tooltip: KLFText.adminDelete(),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: id.isEmpty
                                ? null
                                : () => _requestAdminDelete(id),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                          child: _recordSummary(record),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _recordSummary(Map<String, dynamic> record) {
    final chemicals = Map<String, dynamic>.from(record['chemicals'] ?? {});

    final line = record['line']?.toString() ?? '';

    final bite =
        record['biteAmount'] == null || record['biteAmount'].toString().isEmpty
        ? '-'
        : record['biteAmount'].toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 7),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE4DE),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  KLFText.bite(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                bite,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          KLFText.result(),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        ...tankOrder.map(
          (tank) => resultTank(
            line: line,
            title: tank['title'].toString(),
            description: tank['description'].toString(),
            keys: List<String>.from(tank['keys']),
            chemicals: chemicals,
          ),
        ),
      ],
    );
  }

  Widget resultTank({
    required String line,
    required String title,
    required String description,
    required List<String> keys,
    required Map<String, dynamic> chemicals,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tankTitle(title),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  tankDescription(description),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...keys.map((key) {
              final raw = chemicals[key];

              final data = raw is Map
                  ? Map<String, dynamic>.from(raw)
                  : <String, dynamic>{};

              return compactResultRow(line: line, key: key, data: data);
            }),
          ],
        ),
      ),
    );
  }

  Widget compactResultRow({
    required String line,
    required String key,
    required Map<String, dynamic> data,
  }) {
    final setting = getSettings(line)[key];

    if (setting == null) {
      return const SizedBox();
    }

    final input = data['input']?.toString() ?? '';

    String concentration = data['concentration']?.toString() ?? '';

    final add = data['addAmount']?.toString() ?? '';

    if (key == 'brown_copper') {
      final n = double.tryParse(input.trim());

      if (n != null) {
        concentration = formatNumber(n * setting.factor);
      }
    }

    Color? addColor;

    if (add == '不用添加') {
      addColor = Colors.green;
    } else if (add.isNotEmpty && add != '-') {
      addColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              chemicalName(setting.name),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: smallResult(KLFText.input(), input.isEmpty ? '-' : input),
          ),
          Expanded(
            flex: 2,
            child: smallResult(
              KLFText.middle(),
              setting.middle == null
                  ? KLFGlobalLanguage.t('無中值', 'ไม่มีค่ากลาง')
                  : formatNumber(setting.middle!),
            ),
          ),
          Expanded(
            flex: 2,
            child: smallResult(
              KLFText.concentration(),
              concentration.isEmpty ? '-' : concentration,
            ),
          ),
          Expanded(
            flex: 3,
            child: smallResult(
              KLFText.addAmount(),
              add.isEmpty ? '-' : (add == '不用添加' ? KLFText.noNeedAdd() : add),
              valueColor: addColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget smallResult(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 8),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 修改化驗資料
// ============================================================

class RecordEditPage extends StatefulWidget {
  final Map<String, dynamic> record;
  final String userName;

  const RecordEditPage({
    super.key,
    required this.record,
    required this.userName,
  });

  @override
  State<RecordEditPage> createState() => _RecordEditPageState();
}

class _RecordEditPageState extends State<RecordEditPage> {
  late String lineName;

  final Map<String, TextEditingController> controllers = {};

  final beforeWeightController = TextEditingController();

  final afterWeightController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    lineName = widget.record['line'].toString();

    final chemicals = Map<String, dynamic>.from(
      widget.record['chemicals'] ?? {},
    );

    for (final key in getSettings(lineName).keys) {
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

    if (setting == null) return null;

    final number = parse(value);

    if (number == null) return null;

    if (setting.direct) {
      return roundToTenth(number);
    }

    final calculated = number * setting.factor;

    if (key == 'brown_copper') {
      return calculated;
    }

    return roundToTenth(calculated);
  }

  double? addAmount(String key, String value) {
    final setting = getSettings(lineName)[key];

    if (setting == null || setting.middle == null || setting.addPerPoint <= 0) {
      return null;
    }

    final current = concentration(key, value);

    if (current == null) return null;

    final middle = roundToTenth(setting.middle!);

    final actual = roundToTenth(current);

    if (actual >= middle) return 0;

    final deficit = roundToTenth(middle - actual);

    final steps = (deficit * 10).round();

    if (steps <= 0) return 0;

    return roundToTenth(steps * setting.addPerPoint);
  }

  double? biteAmount() {
    final before = parse(beforeWeightController.text);

    final after = parse(afterWeightController.text);

    if (before == null || after == null) {
      return null;
    }

    return (before - after) / 100 * 21910;
  }

  Future<void> save() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
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
          'addAmount': add == null
              ? ''
              : add <= 0
              ? '不用添加'
              : '${formatNumber(add)} ${entry.value.unit}',
        };
      }

      final bite = biteAmount();

      final updated = Map<String, dynamic>.from(widget.record);

      updated['line'] = lineName;
      updated['chemicals'] = chemicals;
      updated['beforeWeight'] = beforeWeightController.text.trim();
      updated['afterWeight'] = afterWeightController.text.trim();
      updated['biteAmount'] = bite == null ? '' : formatNumber(bite);

      final id = widget.record['id']?.toString();

      if (id == null || id.isEmpty) {
        throw Exception('缺少 Firebase 文件 ID');
      }

      await FirebaseAnalysisManager.updateRecord(id, updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(KLFText.modifySuccess()),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(KLFText.modifyFailed()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget input(String key) {
    final setting = getSettings(lineName)[key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          labelText: setting.direct
              ? '${chemicalName(setting.name)}｜'
                    '${KLFText.directConcentration()}'
              : '${chemicalName(setting.name)}｜'
                    '${KLFText.titration()}',
          border: const OutlineInputBorder(),
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
      addText = KLFText.noNeedAdd();
    } else {
      addText = '${formatNumber(add)} ${setting.unit}';
    }

    Color? addColor;

    if (addText == KLFText.noNeedAdd()) {
      addColor = Colors.green;
    } else if (addText != '-') {
      addColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final middleText = setting.middle == null
                ? KLFGlobalLanguage.t('無中值', 'ไม่มีค่ากลาง')
                : formatNumber(setting.middle!);

            final concentrationText = concentrationValue == null
                ? '-'
                : formatNumber(concentrationValue);

            if (constraints.maxWidth < 600) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chemicalName(setting.name),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: editResult(KLFText.middle(), middleText)),
                      Expanded(
                        child: editResult(
                          KLFText.concentration(),
                          concentrationText,
                        ),
                      ),
                      Expanded(
                        child: editResult(
                          KLFText.addAmount(),
                          addText,
                          valueColor: addColor,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    chemicalName(setting.name),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: editResult(KLFText.middle(), middleText)),
                Expanded(
                  child: editResult(KLFText.concentration(), concentrationText),
                ),
                Expanded(
                  flex: 2,
                  child: editResult(
                    KLFText.addAmount(),
                    addText,
                    valueColor: addColor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget editResult(String title, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = getSettings(lineName);

    return ValueListenableBuilder<KLFLanguage>(
      valueListenable: KLFGlobalLanguage.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          appBar: AppBar(
            title: Text('$lineName｜${KLFText.editRecord()}'),
            actions: const [LanguageButton()],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: const Color(0xFFEDE4DE),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    KLFText.modifiedSync(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: beforeWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: KLFText.unbrownedWeight(),
                  suffixText: 'g',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: afterWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: KLFText.brownedWeight(),
                  suffixText: 'g',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                color: const Color(0xFFEDE4DE),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          KLFText.bite(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Text(
                        biteAmount() == null
                            ? '-'
                            : formatNumber(biteAmount()!),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ...analysisOrder.map(
                (key) => Column(children: [input(key), resultPreview(key)]),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _saving ? KLFText.cloudSaving() : KLFText.saveEdit(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

// ============================================================
// v1.2.3 完
//
// 本版本重點：
// 1. 中文／泰文改為全系統語言
// 2. 語言設定使用瀏覽器 LocalStorage 保存
// 3. 切換語言後跨頁面維持
// 4. 登入／管理者／首頁／化驗／存檔／修改頁全部同步
// 5. 所有主要按鈕與提示同步翻譯
// 6. 保留原有計算公式
// 7. 保留 Firebase
// 8. 保留授權共享
// 9. 保留 QR Code
// 10. 保留一頁式化驗結果
// 11. 保留 A／B 線
// 12. 保留槽體積
//
// ============================================================
