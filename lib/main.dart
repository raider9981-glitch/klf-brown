// ============================================================
// KLF-棕化
// 版本：v1.2.2
//
// 本次版本修改內容：
// 1. 化驗結果維持一頁式顯示
// 2. 化驗結果不顯示 A 線／B 線選項
// 3. 保留原有化驗計算公式
// 4. 登入頁新增中文／泰文切換
// 5. 化驗頁新增中文／泰文切換
// 6. 尚未登入時不預先顯示紅色錯誤訊息
// 7. 僅在輸入錯誤或按下登入後顯示錯誤
// 8. 新增 A／B 線各槽體積
// 9. A 線：酸洗 500 L、清潔 800 L、預浸 700 L、棕化 1400 L
// 10. B 線：酸洗 246 L、清潔 582 L、預浸 440 L、棕化 1560 L
// 11. 保留 Firebase Cloud Firestore
// 12. 保留授權手機共享化驗結果
// 13. 保留登入、Firebase 授權、管理者、QR Code
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

    if (cleanName.isEmpty) {
      return false;
    }

    final snapshot = await _firestore
        .collection(collectionName)
        .where('name', isEqualTo: cleanName)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  static Future<bool> addUser(String name) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return false;
    }

    final exists = await isAuthorized(cleanName);

    if (exists) {
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

// ============================================================
// Firebase 化驗資料管理
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

  static Future<Map<String, dynamic>?> getRecord(String id) async {
    final doc = await _firestore.collection(collectionName).doc(id).get();

    if (!doc.exists) {
      return null;
    }

    final data = Map<String, dynamic>.from(doc.data()!);

    data['id'] = doc.id;

    return data;
  }
}

// ============================================================
// 系統設定
// ============================================================

class KLFConfig {
  static const String appName = 'KLF-棕化';

  static const String version = 'v1.2.2';

  static const String adminPassword = '0';

  static const String websiteUrl =
      'https://raider9981-glitch.github.io/klf-brown/';

  static const String storageDeviceUser = 'klf_device_user';
}

// ============================================================
// 本機登入 Storage
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

  static void saveDeviceUser(String userName) {
    set(KLFConfig.storageDeviceUser, userName);
  }

  static void clearDeviceUser() {
    remove(KLFConfig.storageDeviceUser);
  }
}

// ============================================================
// 語言
// ============================================================

enum KLFLanguage { chinese, thai }

class KLFText {
  static bool isThai(KLFLanguage language) => language == KLFLanguage.thai;

  static String loginTitle(KLFLanguage language) =>
      isThai(language) ? 'เข้าสู่ระบบ KLF-棕化' : 'KLF-棕化';

  static String loginSubtitle(KLFLanguage language) =>
      isThai(language) ? 'ระบบจัดการวิเคราะห์น้ำยาเคมี' : '棕化藥水分析管理系統';

  static String authorizedName(KLFLanguage language) =>
      isThai(language) ? 'ชื่อผู้ได้รับอนุญาต' : '授權人員名稱';

  static String authorizedHint(KLFLanguage language) =>
      isThai(language) ? 'กรุณากรอกชื่อที่ได้รับอนุญาต' : '請輸入已授權名稱';

  static String login(KLFLanguage language) =>
      isThai(language) ? 'เข้าสู่ระบบ' : '登入';

  static String firstLoginHint(KLFLanguage language) => isThai(language)
      ? 'การเข้าสู่ระบบครั้งแรกต้องใช้ชื่อที่ได้รับอนุญาต'
      : '首次登入需輸入已授權名稱登入';

  static String enterAuthorizedName(KLFLanguage language) =>
      isThai(language) ? 'กรุณากรอกชื่อที่ได้รับอนุญาต' : '請輸入授權名稱';

  static String unauthorized(KLFLanguage language) => isThai(language)
      ? 'ชื่อไม่ได้รับอนุญาต ไม่สามารถเข้าสู่ระบบได้'
      : '名稱未授權，無法登入';

  static String firebaseError(KLFLanguage language) => isThai(language)
      ? 'ไม่สามารถเชื่อมต่อ Firebase กรุณาตรวจสอบเครือข่าย'
      : '無法連線 Firebase，請確認網路連線';

  static String languageButton(KLFLanguage language) =>
      isThai(language) ? '中文' : 'ไทย';

  static String adminLogin(KLFLanguage language) =>
      isThai(language) ? 'เข้าสู่ระบบผู้ดูแล' : '管理者登入';

  static String analysisTitle(KLFLanguage language, String line) =>
      isThai(language) ? '$line｜วิเคราะห์น้ำยา' : '$line｜藥水化驗';

  static String analyst(KLFLanguage language, String name) =>
      isThai(language) ? 'ผู้วิเคราะห์: $name' : '化驗人員：$name';

  static String bite(KLFLanguage language) =>
      isThai(language) ? 'ปริมาณการกัด' : '咬食量';

  static String result(KLFLanguage language) =>
      isThai(language) ? 'ผลการวิเคราะห์' : '化驗結果';

  static String concentration(KLFLanguage language) =>
      isThai(language) ? 'ความเข้มข้น' : '濃度';

  static String input(KLFLanguage language) =>
      isThai(language) ? 'ค่าที่ป้อน' : '輸入';

  static String middle(KLFLanguage language) =>
      isThai(language) ? 'ค่ากลาง' : '中值';

  static String addAmount(KLFLanguage language) =>
      isThai(language) ? 'ปริมาณที่ต้องเติม' : '需添加量';

  static String noNeedAdd(KLFLanguage language) =>
      isThai(language) ? 'ไม่ต้องเติม' : '不用添加';

  static String titration(KLFLanguage language) =>
      isThai(language) ? 'ค่าการไทเทรต' : '滴定值';

  static String directConcentration(KLFLanguage language) =>
      isThai(language) ? 'ความเข้มข้นโดยตรง' : '濃度';

  static String enterTitration(KLFLanguage language) =>
      isThai(language) ? 'กรอกค่าการไทเทรต' : '輸入滴定值';

  static String enterConcentration(KLFLanguage language) =>
      isThai(language) ? 'กรอกความเข้มข้นโดยตรง' : '直接輸入濃度';

  static String unbrownedWeight(KLFLanguage language) =>
      isThai(language) ? 'น้ำหนักก่อนบราวนิ่ง' : '未棕化重量';

  static String brownedWeight(KLFLanguage language) =>
      isThai(language) ? 'น้ำหนักหลังบราวนิ่ง' : '已棕化重量';

  static String biteDescription(KLFLanguage language) => isThai(language)
      ? 'กรอกน้ำหนักก่อนและหลังบราวนิ่ง ระบบจะคำนวณอัตโนมัติ'
      : '未棕化重量、已棕化重量由化驗人員輸入，系統自動計算。';

  static String biteFormula(KLFLanguage language) => isThai(language)
      ? 'สูตร: (น้ำหนักก่อนบราวนิ่ง－น้ำหนักหลังบราวนิ่ง) ÷ 100 × 21910'
      : '公式：(未棕化重量－已棕化重量) ÷ 100 × 21910';

  static String save(KLFLanguage language) =>
      isThai(language) ? 'วิเคราะห์เสร็จและบันทึก' : '化驗完成並存檔';

  static String saving(KLFLanguage language) =>
      isThai(language) ? 'กำลังบันทึกบนคลาวด์...' : '雲端儲存中...';

  static String records(KLFLanguage language) =>
      isThai(language) ? 'ประวัติการวิเคราะห์' : '查看共享化驗存檔';

  static String firstTank(KLFLanguage language) =>
      isThai(language) ? 'ถังที่ 1｜ถังกรดล้าง' : '第一槽｜酸洗槽';

  static String secondTank(KLFLanguage language) =>
      isThai(language) ? 'ถังที่ 2｜ถังทำความสะอาด' : '第二槽｜清潔槽';

  static String thirdTank(KLFLanguage language) =>
      isThai(language) ? 'ถังที่ 3｜ถังพรีดิป' : '第三槽｜預浸槽';

  static String fourthTank(KLFLanguage language) =>
      isThai(language) ? 'ถังที่ 4｜ถังบราวนิ่ง' : '第四槽｜棕化槽';

  static String acidDescription(KLFLanguage language) =>
      isThai(language) ? 'กรดซัลฟิวริก, ไฮโดรเจนเปอร์ออกไซด์' : '硫酸、雙氧水';

  static String cleanDescription(KLFLanguage language) =>
      isThai(language) ? 'HL-II' : 'HL-II';

  static String preDescription(KLFLanguage language) =>
      isThai(language) ? 'ไฮโดรเจนเปอร์ออกไซด์, CBBA-A' : '雙氧水、CBBA-A';

  static String brownDescription(KLFLanguage language) => isThai(language)
      ? 'กรดซัลฟิวริก, ไฮโดรเจนเปอร์ออกไซด์, CBBA-A, ทองแดง'
      : '硫酸、雙氧水、CBBA-A、銅離子';

  static String tankVolume(KLFLanguage language) =>
      isThai(language) ? 'ปริมาตรถัง' : '槽體積';

  static String liters(KLFLanguage language, double value) => isThai(language)
      ? '${formatNumber(value)} L'
      : '${formatNumber(value)} L';

  static String savedSuccess(KLFLanguage language) => isThai(language)
      ? 'บันทึกข้อมูลบนคลาวด์แล้ว โทรศัพท์ที่ได้รับอนุญาตทั้งหมดสามารถดูได้'
      : '化驗資料已儲存至雲端，所有授權手機皆可查看';

  static String saveFailed(KLFLanguage language) => isThai(language)
      ? 'บันทึกบนคลาวด์ไม่สำเร็จ กรุณาตรวจสอบ Firebase'
      : '雲端存檔失敗，請確認 Firebase 連線與權限';

  static String formatNumber(double value) => value.toStringAsFixed(1);
}

String formatNumber(double value) => value.toStringAsFixed(1);

// ============================================================
// App
// ============================================================

class KLFApp extends StatelessWidget {
  const KLFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: KLFConfig.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B3F22)),
        scaffoldBackgroundColor: const Color(0xFFF5F6F7),
      ),
      home: const StartupPage(),
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
      final authorized = await FirebaseUserManager.isAuthorized(deviceUser);

      if (!mounted) return;

      if (authorized) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(userName: deviceUser)),
        );

        return;
      }

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

  KLFLanguage _language = KLFLanguage.chinese;

  void _toggleLanguage() {
    setState(() {
      _language = KLFText.isThai(_language)
          ? KLFLanguage.chinese
          : KLFLanguage.thai;

      // 切換語言時清除錯誤訊息。
      _errorMessage = '';
    });
  }

  Future<void> _login() async {
    final name = _nameController.text.trim();

    // 尚未按登入以前不顯示任何錯誤。
    // 只有使用者實際嘗試登入才提醒。
    if (name.isEmpty) {
      setState(() {
        _errorMessage = KLFText.enterAuthorizedName(_language);
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
          _errorMessage = KLFText.unauthorized(_language);
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = KLFText.firebaseError(_language);
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
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = _language;

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
                        child: OutlinedButton.icon(
                          onPressed: _toggleLanguage,
                          icon: const Icon(Icons.language, size: 18),
                          label: Text(KLFText.languageButton(language)),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Icon(
                        Icons.science_outlined,
                        size: 70,
                        color: Color(0xFF6B3F22),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        KLFText.loginTitle(language),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        KLFText.loginSubtitle(language),
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
                          labelText: KLFText.authorizedName(language),
                          hintText: KLFText.authorizedHint(language),
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
                                  KLFText.login(language),
                                  style: const TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        KLFText.firstLoginHint(language),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),

                      // 只有按登入後發生錯誤才顯示。
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
                        onPressed: _openAdminLogin,
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        label: Text(KLFText.adminLogin(language)),
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
    final password = _passwordController.text;

    if (password == KLFConfig.adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } else {
      setState(() {
        _errorMessage = '管理者密碼錯誤';
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
      appBar: AppBar(title: const Text('管理者登入')),
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
                    const Text(
                      '管理者登入',
                      style: TextStyle(
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
                        labelText: '管理者密碼',
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
                        child: const Text('登入管理者'),
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

      _showMessage('無法讀取 Firebase 授權名單');
    }
  }

  Future<void> _addUser() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('請輸入授權人員名稱');
      return;
    }

    setState(() {
      _adding = true;
    });

    try {
      final added = await FirebaseUserManager.addUser(name);

      if (!mounted) return;

      if (!added) {
        _showMessage('這個名稱已經存在');
        return;
      }

      _nameController.clear();

      await _loadUsers();

      if (!mounted) return;

      _showMessage('已新增授權人員：$name');
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
          title: const Text('刪除授權人員'),
          content: Text(
            '確定要刪除「$name」嗎？\n\n'
            '刪除後所有裝置都將無法再使用此名稱登入。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('刪除'),
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

      _showMessage('已刪除：$name');
    } catch (_) {
      if (!mounted) return;

      _showMessage('刪除失敗，請確認 Firebase 連線');
    }
  }

  void _clearCurrentDevice() {
    LocalStorageHelper.clearDeviceUser();

    _showMessage('本設備登入記錄已清除');
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
        title: const Text('管理者設定'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            tooltip: '重新整理',
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
                      const Text(
                        '新增授權人員',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '新增後會同步到 Firebase，其他手機也可以使用。',
                        style: TextStyle(color: Colors.grey),
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
                                labelText: '授權人員名稱',
                                hintText: '例如：王小明',
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
                              label: const Text('新增'),
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
                          const Expanded(
                            child: Text(
                              '已授權人員',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_loading)
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (!_loading && _users.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              '目前尚未建立授權人員',
                              style: TextStyle(color: Colors.grey),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Firebase 雲端授權',
                            style: TextStyle(color: Colors.green),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _deleteUser(name);
                            },
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
                  title: const Text('本設備登入記錄'),
                  subtitle: Text(
                    LocalStorageHelper.getDeviceUser() ?? '目前沒有記錄',
                  ),
                  trailing: TextButton(
                    onPressed: _clearCurrentDevice,
                    child: const Text('清除'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_done, color: Colors.green),
                  title: const Text('化驗資料來源'),
                  subtitle: const Text('Firebase Cloud Firestore'),
                  trailing: const Text(
                    '雲端共享',
                    style: TextStyle(
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
                  title: const Text('系統版本'),
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
          title: const Row(
            children: [
              Icon(Icons.qr_code_2),
              SizedBox(width: 10),
              Text('KLF-棕化網站 QR Code'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '使用手機掃描 QR Code 即可開啟 KLF-棕化網站',
                  textAlign: TextAlign.center,
                ),
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
                const Text(
                  '掃描後仍需使用已授權名稱登入',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('關閉'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KLF-棕化',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: '管理者',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () => openAdmin(context),
          ),
          IconButton(
            tooltip: '邀請開啟網站',
            icon: const Icon(Icons.qr_code_2),
            onPressed: () => showWebsiteQrCode(context),
          ),
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
                const Text(
                  '棕化水平生產線',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '請選擇需要進行藥水分析的生產線',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 650) {
                      return Column(
                        children: [
                          _buildLineCard(context, 'A線', '棕化水平生產線 A'),
                          const SizedBox(height: 18),
                          _buildLineCard(context, 'B線', '棕化水平生產線 B'),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildLineCard(context, 'A線', '棕化水平生產線 A'),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildLineCard(context, 'B線', '棕化水平生產線 B'),
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
                    title: const Text(
                      '化驗存檔',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('查看所有手機共享的歷史化驗資料'),
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
                        const Icon(Icons.access_time, color: Color(0xFF6B3F22)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '化驗週期',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('每 4 小時進行一次藥水分析'),
                            ],
                          ),
                        ),
                        Text(
                          KLFConfig.version,
                          style: const TextStyle(color: Colors.grey),
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
  }

  Widget _buildLineCard(
    BuildContext context,
    String lineName,
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
                lineName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Text('進入化驗', style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(),
                  Icon(Icons.arrow_forward),
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
  final bool isA = line == 'A線';

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
// 數值處理
// ============================================================

double roundToTenth(double value) {
  return (value * 10).round() / 10;
}

// ============================================================
// 化驗結果固定順序
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
// 化驗頁面
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

  final TextEditingController beforeWeightController = TextEditingController();

  final TextEditingController afterWeightController = TextEditingController();

  bool _saving = false;

  KLFLanguage _language = KLFLanguage.chinese;

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

  double? concentration(String key, String value) {
    final setting = getSettings(widget.lineName)[key];

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
      return KLFText.noNeedAdd(_language);
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
      return _language == KLFLanguage.thai ? 'ไม่มีค่ากลาง' : '無中值';
    }

    return formatNumber(roundToTenth(setting.middle!));
  }

  double? biteAmount() {
    final before = parse(beforeWeightController.text);

    final after = parse(afterWeightController.text);

    if (before == null || after == null) {
      return null;
    }

    return (before - after) / 100 * 21910;
  }

  Future<void> saveRecord() async {
    if (_saving) {
      return;
    }

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

      final record = <String, dynamic>{
        'line': widget.lineName,
        'user': widget.userName,
        'beforeWeight': beforeWeightController.text.trim(),
        'afterWeight': afterWeightController.text.trim(),
        'biteAmount': bite == null ? '' : formatNumber(bite),
        'chemicals': chemicals,
      };

      await FirebaseAnalysisManager.addRecord(record);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(KLFText.savedSuccess(_language)),
          behavior: SnackBarBehavior.floating,
        ),
      );

      for (final controller in controllers.values) {
        controller.clear();
      }

      beforeWeightController.clear();
      afterWeightController.clear();

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(KLFText.saveFailed(_language)),
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

    final isThai = _language == KLFLanguage.thai;

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
          labelText: setting.direct
              ? '${setting.name}｜${KLFText.directConcentration(_language)}'
              : '${setting.name}｜${KLFText.titration(_language)}',
          hintText: setting.direct
              ? KLFText.enterConcentration(_language)
              : KLFText.enterTitration(_language),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _resultBox(String title, String value) {
    Color? valueColor;

    if (title == KLFText.addAmount(_language)) {
      if (value == KLFText.noNeedAdd(_language)) {
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
        mainAxisSize: MainAxisSize.min,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          setting.name,
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
                        child: _resultBox(
                          KLFText.middle(_language),
                          displayMiddle(key),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _resultBox(
                          KLFText.concentration(_language),
                          displayConcentration(key, value),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _resultBox(
                          KLFText.addAmount(_language),
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
                    setting.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(flex: 3, child: inputField(key)),
                const SizedBox(width: 5),
                Expanded(
                  child: _resultBox(
                    KLFText.middle(_language),
                    displayMiddle(key),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _resultBox(
                    KLFText.concentration(_language),
                    displayConcentration(key, value),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _resultBox(
                    KLFText.addAmount(_language),
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
                    title,
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
                    '${KLFText.tankVolume(_language)}：${formatNumber(volume)} L',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 7),
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
              KLFText.bite(_language),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              KLFText.biteDescription(_language),
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
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        labelText: KLFText.unbrownedWeight(_language),
                        suffixText: 'g',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        labelText: KLFText.brownedWeight(_language),
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
                      KLFText.bite(_language),
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
              KLFText.biteFormula(_language),
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLanguage() {
    setState(() {
      _language = KLFText.isThai(_language)
          ? KLFLanguage.chinese
          : KLFLanguage.thai;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = _language;

    return Scaffold(
      appBar: AppBar(
        title: Text(KLFText.analysisTitle(language, widget.lineName)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: _toggleLanguage,
                icon: const Icon(Icons.language, size: 18),
                label: Text(KLFText.languageButton(language)),
              ),
            ),
          ),
        ],
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
                        KLFText.analyst(language, widget.userName),
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
                title: KLFText.firstTank(language),
                description: KLFText.acidDescription(language),
                keys: const ['acid_sulfuric', 'acid_h2o2'],
                volumeKey: 'acid',
              ),
              const SizedBox(height: 7),
              tankCard(
                title: KLFText.secondTank(language),
                description: KLFText.cleanDescription(language),
                keys: const ['clean_hl2'],
                volumeKey: 'clean',
              ),
              const SizedBox(height: 7),
              tankCard(
                title: KLFText.thirdTank(language),
                description: KLFText.preDescription(language),
                keys: const ['pre_h2o2', 'pre_cbba'],
                volumeKey: 'pre',
              ),
              const SizedBox(height: 7),
              tankCard(
                title: KLFText.fourthTank(language),
                description: KLFText.brownDescription(language),
                keys: const [
                  'brown_sulfuric',
                  'brown_h2o2',
                  'brown_cbba',
                  'brown_copper',
                ],
                volumeKey: 'brown',
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
                    _saving ? KLFText.saving(language) : KLFText.save(language),
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
                        builder: (_) => RecordsPage(userName: widget.userName),
                      ),
                    );
                  },
                  icon: const Icon(Icons.folder_open),
                  label: Text(KLFText.records(language)),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  '${KLFConfig.appName} ${KLFConfig.version}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
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

// ============================================================
// 化驗存檔
// Firebase 即時共享
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

  void _requestAdminDelete(String id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('管理者驗證'),
          content: const Text('刪除化驗資料需要管理者權限。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                _showAdminPassword(id);
              },
              child: const Text('管理者驗證'),
            ),
          ],
        );
      },
    );
  }

  void _showAdminPassword(String id) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('管理者密碼'),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            onSubmitted: (_) {
              _verifyAdminDelete(controller.text, id);
            },
            decoration: const InputDecoration(
              labelText: '輸入管理者密碼',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                _verifyAdminDelete(controller.text, id);
              },
              child: const Text('確認'),
            ),
          ],
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }

  void _verifyAdminDelete(String password, String id) {
    if (password == KLFConfig.adminPassword) {
      Navigator.pop(context);
      _deleteRecord(id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('管理者密碼錯誤，無法刪除'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteRecord(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('刪除雲端存檔'),
        content: const Text(
          '確定要永久刪除這筆化驗資料嗎？\n\n'
          '刪除後所有手機都會同步消失。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await FirebaseAnalysisManager.deleteRecord(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已從雲端刪除，所有手機同步更新'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('刪除失敗，請確認 Firebase 權限'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('化驗存檔'),
        actions: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirebaseAnalysisManager.recordsStream(),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_done,
                      size: 18,
                      color: snapshot.hasError ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      snapshot.hasError ? '離線' : '雲端同步',
                      style: TextStyle(
                        fontSize: 12,
                        color: snapshot.hasError ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
                    const Icon(Icons.cloud_off, size: 60, color: Colors.red),
                    const SizedBox(height: 15),
                    const Text(
                      '無法讀取雲端化驗資料',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '請確認網路與 Firebase Firestore 權限設定。',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('重新連線'),
                    ),
                  ],
                ),
              ),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('目前沒有化驗存檔', style: TextStyle(color: Colors.grey)),
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
                    '$line｜${formatDate(time.toString())}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('化驗人員：$user'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: '查看／修改',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          _openRecord(record);
                        },
                      ),
                      IconButton(
                        tooltip: '管理者刪除',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: id.isEmpty
                            ? null
                            : () {
                                _requestAdminDelete(id);
                              },
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
  }

  Widget _recordSummary(Map<String, dynamic> record) {
    final chemicals = Map<String, dynamic>.from(record['chemicals'] ?? {});

    final line = record['line']?.toString() ?? '';

    final biteValue =
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
              const Expanded(
                child: Text(
                  '咬食量',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Text(
                biteValue,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '化驗結果',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        ...tankOrder.map((tank) {
          final title = tank['title'].toString();

          final description = tank['description'].toString();

          final keys = List<String>.from(tank['keys']);

          return _resultTank(
            line: line,
            title: title,
            description: description,
            keys: keys,
            chemicals: chemicals,
          );
        }),
      ],
    );
  }

  Widget _resultTank({
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
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  description,
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

              return _compactResultRow(line: line, key: key, data: data);
            }),
          ],
        ),
      ),
    );
  }

  Widget _compactResultRow({
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

    final addAmount = data['addAmount']?.toString() ?? '';

    if (key == 'brown_copper') {
      final inputNumber = double.tryParse(input.trim());

      if (inputNumber != null) {
        concentration = formatNumber(inputNumber * setting.factor);
      }
    }

    Color? addColor;

    if (addAmount == '不用添加') {
      addColor = Colors.green;
    } else if (addAmount.isNotEmpty && addAmount != '-') {
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
              setting.name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: _smallResult('輸入', input.isEmpty ? '-' : input),
          ),
          Expanded(
            flex: 2,
            child: _smallResult(
              '中值',
              setting.middle == null ? '無中值' : formatNumber(setting.middle!),
            ),
          ),
          Expanded(
            flex: 2,
            child: _smallResult(
              '濃度',
              concentration.isEmpty ? '-' : concentration,
            ),
          ),
          Expanded(
            flex: 3,
            child: _smallResult(
              '需添加量',
              addAmount.isEmpty ? '-' : addAmount,
              valueColor: addColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallResult(String title, String value, {Color? valueColor}) {
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

  final TextEditingController beforeWeightController = TextEditingController();

  final TextEditingController afterWeightController = TextEditingController();

  bool _saving = false;

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
    if (_saving) {
      return;
    }

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
        const SnackBar(
          content: Text('修改已儲存至雲端，所有手機同步更新'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('修改失敗，請確認 Firebase 連線與權限'),
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
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          labelText: setting.direct
              ? '${setting.name}｜濃度'
              : '${setting.name}｜滴定值',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
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
      addText = '不用添加';
    } else {
      addText = '${formatNumber(add)} ${setting.unit}';
    }

    Color? addColor;

    if (addText == '不用添加') {
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
            if (constraints.maxWidth < 600) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    setting.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _editResult(
                          '中值',
                          setting.middle == null
                              ? '無中值'
                              : formatNumber(setting.middle!),
                        ),
                      ),
                      Expanded(
                        child: _editResult(
                          '濃度',
                          concentrationValue == null
                              ? '-'
                              : formatNumber(concentrationValue),
                        ),
                      ),
                      Expanded(
                        child: _editResult(
                          '需添加量',
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
                    setting.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _editResult(
                    '中值',
                    setting.middle == null
                        ? '無中值'
                        : formatNumber(setting.middle!),
                  ),
                ),
                Expanded(
                  child: _editResult(
                    '濃度',
                    concentrationValue == null
                        ? '-'
                        : formatNumber(concentrationValue),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _editResult('需添加量', addText, valueColor: addColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _editResult(String title, String value, {Color? valueColor}) {
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

    return Scaffold(
      appBar: AppBar(title: Text('$lineName｜修改化驗資料')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFEDE4DE),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                '修改後會重新計算濃度、需添加量及咬食量，並同步到所有手機。',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: beforeWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              setState(() {});
            },
            decoration: const InputDecoration(
              isDense: true,
              labelText: '未棕化重量',
              suffixText: 'g',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: afterWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              setState(() {});
            },
            decoration: const InputDecoration(
              isDense: true,
              labelText: '已棕化重量',
              suffixText: 'g',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            color: const Color(0xFFEDE4DE),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '咬食量',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    biteAmount() == null ? '-' : formatNumber(biteAmount()!),
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
                _saving ? '雲端儲存中...' : '儲存修改',
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
// v1.2.2 完
//
// 本版本完成：
// 1. 化驗結果維持一頁式
// 2. 化驗結果不顯示 A/B 線選項
// 3. 保留原有化驗計算公式
// 4. 登入頁中文／泰文切換
// 5. 化驗頁中文／泰文切換
// 6. 登入前不顯示紅色錯誤
// 7. 輸入錯誤或按登入後才顯示錯誤
// 8. A 線槽體積：500 / 800 / 700 / 1400 L
// 9. B 線槽體積：246 / 582 / 440 / 1560 L
//
// ============================================================
