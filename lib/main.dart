// ============================================================
// KLF-棕化
// 版本：v1.2.3
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
// 13. 化驗畫面手機版改為緊湊表格式，減少垂直高度
// 14. 保留原本計算公式、槽體積、Firebase 與存檔功能
// 15. 化驗頁上方新增管理者按鈕
// 16. 強化主畫面 Web App 自動更新機制由 web/index.html 處理
// 17. 化驗存檔單筆資料改為獨立完整化驗結果頁
// 18. 獨立結果頁沿用化驗頁版型並填滿手機畫面
//
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
  runApp(const KLFApp());
}

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
    final snapshot = await _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;

      final createdAt = data['createdAt'];
      data['time'] = createdAt is Timestamp
          ? createdAt.toDate().toIso8601String()
          : '';

      return data;
    }).toList();
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
  static const String version = 'v1.2.3';

  static const String adminPassword = '0';

  static const String websiteUrl =
      'https://raider9981-glitch.github.io/klf-brown/';

  static const String storageDeviceUser = 'klf_device_user';
  static const String storageAnalysisRecords = 'klf_analysis_records';
}

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
    set(KLFConfig.storageAnalysisRecords, jsonEncode(records));
  }
}

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
        _errorMessage = '請輸入授權名稱';
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
          _errorMessage = '名稱未授權，無法登入';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = '無法連線 Firebase，請確認網路連線';
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
                      const Icon(
                        Icons.science_outlined,
                        size: 70,
                        color: Color(0xFF6B3F22),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'KLF-棕化',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '棕化藥水分析管理系統',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 35),
                      TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        enabled: !_loading,
                        decoration: InputDecoration(
                          labelText: '授權人員名稱',
                          hintText: '請輸入已授權名稱',
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
                              : const Text(
                                  '登入',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        '首次登入需輸入已授權名稱登入',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
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
                        onPressed: _openAdminLogin,
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        label: const Text('管理者登入'),
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
                  title: const Text('授權資料來源'),
                  subtitle: const Text('Firebase Cloud Firestore'),
                  trailing: const Text('雲端同步'),
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
              onPressed: () {
                Navigator.pop(context);
              },
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
            onPressed: () {
              openAdmin(context);
            },
          ),
          IconButton(
            tooltip: '邀請開啟網站',
            icon: const Icon(Icons.qr_code_2),
            onPressed: () {
              showWebsiteQrCode(context);
            },
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
                    final lines = [
                      ('A線', '棕化水平生產線 A', true),
                      ('B線', '棕化水平生產線 B', true),
                      ('C線', '待開發', false),
                      ('D線', '待開發', false),
                      ('E線', '待開發', false),
                    ];

                    if (constraints.maxWidth < 650) {
                      return Column(
                        children: [
                          for (int i = 0; i < lines.length; i++) ...[
                            _buildLineCard(
                              context,
                              lines[i].$1,
                              lines[i].$2,
                              enabled: lines[i].$3,
                            ),
                            if (i < lines.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      );
                    }

                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        for (final line in lines)
                          SizedBox(
                            width: (constraints.maxWidth - 40) / 3,
                            child: _buildLineCard(
                              context,
                              line.$1,
                              line.$2,
                              enabled: line.$3,
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
                    title: const Text(
                      '化驗存檔',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('查看、修改歷史化驗資料'),
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
    String subtitle, {
    bool enabled = true,
  }) {
    final isAvailable = enabled;

    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isAvailable
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isAvailable
                    ? Icons.water_drop_outlined
                    : Icons.construction_outlined,
                size: 44,
                color: isAvailable ? const Color(0xFF6B3F22) : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                lineName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: isAvailable ? Colors.grey : Colors.orange,
                  fontWeight: isAvailable ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    isAvailable ? '進入化驗' : '待開發',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? null : Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isAvailable ? Icons.arrow_forward : Icons.lock_outline,
                    color: isAvailable ? null : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

    // ========================================================
    // 預浸槽 CBBA-A
    //
    // A線：
    // 每 0.1 濃度差 = 添加 1.0 L
    //
    // B線：
    // 每 0.1 濃度差 = 添加 0.5 L
    //
    // 這裡保留獨立設定，避免與棕化槽 CBBA-A 混用。
    // ========================================================
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

  const TankInfo({
    required this.name,
    required this.description,
    required this.volume,
    required this.keys,
  });
}

List<TankInfo> getTankInfo(String line) {
  final bool isA = line == 'A線';

  return [
    TankInfo(
      name: '第一槽｜酸洗槽',
      description: '硫酸、雙氧水',
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
      description: '雙氧水、CBBA-A',
      volume: isA ? 700 : 440,
      keys: const ['pre_h2o2', 'pre_cbba'],
    ),
    TankInfo(
      name: '第四槽｜棕化槽',
      description: '硫酸、雙氧水、CBBA-A、銅離子',
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

    return roundToTenth(number * setting.factor);
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

    // ========================================================
    // 預浸槽 CBBA-A 特別處理
    //
    // A線：
    // 每差 0.1 = 1.0 L
    //
    // B線：
    // 每差 0.1 = 0.5 L
    // ========================================================

    if (key == 'pre_cbba') {
      final steps = (deficit * 10).round();

      if (steps <= 0) {
        return 0;
      }

      final addPerPoint = widget.lineName == 'A線' ? 1.0 : 0.5;

      return roundToTenth(steps * addPerPoint);
    }

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
      return '不用添加';
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
      return '無中值';
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
        const SnackBar(
          content: Text('化驗資料已儲存至雲端'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('雲端存檔失敗，請確認網路與 Firebase 權限'),
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
          labelText: setting.direct
              ? '${setting.name}｜濃度'
              : '${setting.name}｜滴定值',
          hintText: setting.direct ? '直接輸入濃度' : '輸入滴定值',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _resultBox(String title, String value) {
    Color? valueColor;

    if (title == '需添加量') {
      if (value == '不用添加') {
        valueColor = Colors.green;
      } else if (value != '-') {
        valueColor = Colors.red;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        setting.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 145, child: inputField(key)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _resultBox('中值', displayMiddle(key))),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _resultBox('濃度', displayConcentration(key, value)),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: _resultBox('需添加量', displayAddAmount(key, value)),
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
              Expanded(child: _resultBox('中值', displayMiddle(key))),
              const SizedBox(width: 5),
              Expanded(
                child: _resultBox('濃度', displayConcentration(key, value)),
              ),
              const SizedBox(width: 5),
              Expanded(child: _resultBox('需添加量', displayAddAmount(key, value))),
            ],
          );
        },
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
                    '槽體積：${formatNumber(volume)} L',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
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
            const Text(
              '咬食量',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            const Text(
              '未棕化重量、已棕化重量由化驗人員輸入，系統自動計算。',
              style: TextStyle(color: Colors.grey),
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
                        labelText: '未棕化重量',
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
                        labelText: '已棕化重量',
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
                  const Expanded(
                    child: Text(
                      '咬食量',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
            const Text(
              '公式：(未棕化重量－已棕化重量) ÷ 100 × 21910',
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
        title: Text('${widget.lineName}｜藥水化驗'),
        actions: [
          IconButton(
            tooltip: '管理者',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginPage()),
              );
            },
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
                        '化驗人員：${widget.userName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 7),

              biteCard(),

              const SizedBox(height: 7),

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

              const SizedBox(height: 3),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: saveRecord,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    '化驗完成並存檔',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                  label: const Text('查看化驗存檔'),
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

class RecordsPage extends StatefulWidget {
  final String userName;

  const RecordsPage({super.key, required this.userName});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List<Map<String, dynamic>> records = [];
  bool loading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      loadError = null;
    });

    try {
      final cloudRecords = await FirebaseAnalysisManager.getRecords();

      if (!mounted) return;

      setState(() {
        records = cloudRecords;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        loadError = '無法讀取雲端化驗資料，請確認網路與 Firebase 權限';
      });
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
            onSubmitted: (_) => _verifyAdminDelete(controller.text, id),
            decoration: const InputDecoration(
              labelText: '輸入管理者密碼',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => _verifyAdminDelete(controller.text, id),
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
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
        title: const Text('刪除存檔'),
        content: const Text('確定要永久刪除這筆化驗資料嗎？'),
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

    if (confirmed != true) return;

    try {
      await FirebaseAnalysisManager.deleteRecord(id);

      if (!mounted) return;

      setState(() {
        records.removeWhere((record) => record['id']?.toString() == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('化驗資料已刪除'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('刪除失敗，請確認網路連線'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openRecord(Map<String, dynamic> record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordViewPage(
          record: record,
          userName: widget.userName,
          onDeleted: _load,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('化驗存檔'),
        actions: [
          IconButton(
            tooltip: '重新整理',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
          IconButton(
            tooltip: '管理者',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginPage()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('重新讀取')),
            ],
          ),
        ),
      );
    }

    if (records.isEmpty) {
      return const Center(
        child: Text('目前沒有化驗存檔', style: TextStyle(fontSize: 18)),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: records.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final record = records[index];

          final line = record['line']?.toString() ?? '-';
          final user = record['user']?.toString() ?? '-';
          final time = formatDate(record['time']?.toString() ?? '');

          final bite =
              record['biteAmount'] == null ||
                  record['biteAmount'].toString().isEmpty
              ? '-'
              : record['biteAmount'].toString();

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const CircleAvatar(child: Icon(Icons.science_outlined)),
              title: Text(
                '$line｜$time',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('操作員：$user　咬食量：$bite'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openRecord(record),
            ),
          );
        },
      ),
    );
  }
}

class RecordViewPage extends StatelessWidget {
  final Map<String, dynamic> record;
  final String userName;
  final Future<void> Function()? onDeleted;

  const RecordViewPage({
    super.key,
    required this.record,
    required this.userName,
    this.onDeleted,
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
        title: Text('$line｜化驗結果'),
        actions: [
          IconButton(
            tooltip: '管理者',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginPage()),
              );
            },
          ),
          IconButton(
            tooltip: '修改',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RecordEditPage(record: record, userName: userName),
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
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 8,
                          children: [
                            _infoItem('生產線', line),
                            _infoItem('操作員', user),
                            _infoItem('時間', time),
                            _infoItem('咬食量', bite),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...tanks.map((tank) {
                      final keys = _keysForTank(line, tank.name);

                      if (keys.isEmpty) {
                        return const SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE4DE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tank.name,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${formatNumber(tank.volume)} L',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 7),

                                ...keys.map((key) {
                                  final setting = getSettings(line)[key]!;

                                  final data = Map<String, dynamic>.from(
                                    chemicals[key] ?? {},
                                  );

                                  final input = data['input']?.toString() ?? '';
                                  final concentration =
                                      data['concentration']?.toString() ?? '';
                                  final addAmount =
                                      data['addAmount']?.toString() ?? '';

                                  Color? addColor;

                                  if (addAmount == '不用添加') {
                                    addColor = Colors.green;
                                  } else if (addAmount.isNotEmpty &&
                                      addAmount != '-') {
                                    addColor = Colors.red;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 7,
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
                                            setting.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: _result(
                                            '輸入',
                                            input.isEmpty ? '-' : input,
                                          ),
                                        ),
                                        Expanded(
                                          child: _result(
                                            '中值',
                                            setting.middle == null
                                                ? '無中值'
                                                : formatNumber(setting.middle!),
                                          ),
                                        ),
                                        Expanded(
                                          child: _result(
                                            '濃度',
                                            concentration.isEmpty
                                                ? '-'
                                                : concentration,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: _result(
                                            '需添加量',
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

                    const SizedBox(height: 6),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF6B3F22),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('此頁為單筆化驗存檔的完整結果。')),
                            IconButton(
                              tooltip: '刪除',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await _deleteWithAdmin(context);
                              },
                            ),
                          ],
                        ),
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

  Widget _infoItem(String title, String value) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
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

    final verified = await showDialog<bool>(
      context: context,
      builder: (_) {
        final controller = TextEditingController();

        return AlertDialog(
          title: const Text('管理者驗證'),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '輸入管理者密碼',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text == KLFConfig.adminPassword,
                );
              },
              child: const Text('確認'),
            ),
          ],
        );
      },
    );

    if (verified != true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('管理者密碼錯誤，無法刪除'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('刪除存檔'),
        content: const Text('確定要永久刪除這筆化驗資料嗎？'),
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

    if (confirmed != true) return;

    try {
      await FirebaseAnalysisManager.deleteRecord(id);

      await onDeleted?.call();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('化驗資料已刪除'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('刪除失敗，請確認網路連線'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

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

    return (before - after) / 100 * 21910;
  }

  Future<void> save() async {
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
        'tank': getTankName(lineName, key),
      };
    }

    final before = parse(beforeWeightController.text);

    final after = parse(afterWeightController.text);

    final bite = before == null || after == null
        ? null
        : (before - after) / 100 * 21910;

    final updated = Map<String, dynamic>.from(widget.record);

    updated['chemicals'] = chemicals;

    updated['beforeWeight'] = beforeWeightController.text.trim();

    updated['afterWeight'] = afterWeightController.text.trim();

    updated['biteAmount'] = bite == null ? '' : formatNumber(bite);

    final id = widget.record['id']?.toString();

    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('找不到雲端存檔識別碼')));
      return;
    }

    try {
      await FirebaseAnalysisManager.updateRecord(id, updated);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('修改已儲存至雲端')));

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('雲端修改失敗，請稍後再試')));
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
          labelText: setting.direct
              ? '${setting.name}｜濃度'
              : '${setting.name}｜滴定值',
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
        child: Row(
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
                setting.middle == null ? '無中值' : formatNumber(setting.middle!),
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

    final tanks = getTankInfo(lineName);

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
                '修改後會重新計算濃度、需添加量及咬食量',
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
              labelText: '已棕化重量',
              suffixText: 'g',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            color: const Color(0xFFEDE4DE),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                            tank.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '槽體積：${formatNumber(tank.volume)} L',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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

                const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save_outlined),
              label: const Text(
                '儲存修改',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
