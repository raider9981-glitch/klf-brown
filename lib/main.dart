// ============================================================
// KLF-棕化
// 版本：v1.1.9
//
// 本次版本修改內容：
// 1. 化驗頁手機版改為「一排一個化驗項目」
// 2. 每個化驗項目完整填滿手機寬度
// 3. 每個項目依序顯示：項目名稱／輸入框／中值／濃度／需添加量
// 4. 四個槽位全部改為由上往下排列，不再左右擠壓
// 5. 保留原本化驗計算公式
// 6. 保留原本化驗存檔功能
// 7. 保留原本化驗修改功能
// 8. 保留登入、Firebase、管理者、QR Code 功能
// 9. 桌面版功能與計算邏輯不變
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
  static const String version = 'v1.1.9';

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

double roundToTenth(double value) {
  return (value * 10).round() / 10;
}

String formatNumber(double value) {
  return value.toStringAsFixed(1);
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

  // ==========================================================
  // 化驗項目
  //
  // 手機版：
  //   項目名稱
  //   輸入框
  //   中值
  //   濃度
  //   需添加量
  //
  // 每一個項目一整排往下，不左右擠壓。
  // ==========================================================
  Widget chemicalRow(String key) {
    final setting = getSettings(widget.lineName)[key]!;

    final controller = controllers[key]!;

    final value = controller.text;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // --------------------------------------------------
            // 手機版：整個化驗項目由上往下排列
            // --------------------------------------------------
            if (constraints.maxWidth < 700) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    setting.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 輸入框：填滿手機寬度
                  inputField(key),

                  const SizedBox(height: 5),

                  // 中值
                  _resultBox('中值', displayMiddle(key)),

                  const SizedBox(height: 4),

                  // 濃度
                  _resultBox('濃度', displayConcentration(key, value)),

                  const SizedBox(height: 4),

                  // 需添加量
                  _resultBox('需添加量', displayAddAmount(key, value)),
                ],
              );
            }

            // --------------------------------------------------
            // 桌面版：維持原本橫向排列
            // --------------------------------------------------
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
                Expanded(
                  child: _resultBox('需添加量', displayAddAmount(key, value)),
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
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    return Scaffold(
      appBar: AppBar(title: Text('${widget.lineName}｜藥水化驗'), actions: const []),
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

              // 第一槽
              tankCard(
                title: '第一槽｜酸洗槽',
                description: '硫酸、雙氧水',
                keys: const ['acid_sulfuric', 'acid_h2o2'],
              ),

              const SizedBox(height: 7),

              // 第二槽
              tankCard(
                title: '第二槽｜清潔槽',
                description: 'HL-II',
                keys: const ['clean_hl2'],
              ),

              const SizedBox(height: 7),

              // 第三槽
              tankCard(
                title: '第三槽｜預浸槽',
                description: '雙氧水、CBBA-A',
                keys: const ['pre_h2o2', 'pre_cbba'],
              ),

              const SizedBox(height: 7),

              // 第四槽
              tankCard(
                title: '第四槽｜棕化槽',
                description: '硫酸、雙氧水、CBBA-A、銅離子',
                keys: const [
                  'brown_sulfuric',
                  'brown_h2o2',
                  'brown_cbba',
                  'brown_copper',
                ],
              ),

              const SizedBox(height: 10),

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
              onPressed: () {
                Navigator.pop(context);
              },
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
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('雲端刪除失敗，請稍後再試')),
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
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('化驗存檔')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(loadError!, textAlign: TextAlign.center),
              ),
            )
          : records.isEmpty
          ? const Center(
              child: Text('目前沒有化驗存檔', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];

                final line = record['line'] ?? '';

                final time = record['time'] ?? '';

                final user = record['user'] ?? '';

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
                          onPressed: () {
                            _requestAdminDelete(record['id']);
                          },
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                        child: _recordSummary(record),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _recordSummary(Map<String, dynamic> record) {
    final chemicals = Map<String, dynamic>.from(record['chemicals'] ?? {});

    final biteValue =
        record['biteAmount'] == null || record['biteAmount'].toString().isEmpty
        ? '-'
        : record['biteAmount'].toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Card(
          color: const Color(0xFFEDE4DE),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '咬食量',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  biteValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '化驗結果',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...chemicals.entries.map((entry) {
          final key = entry.key;

          final data = Map<String, dynamic>.from(entry.value ?? {});

          final setting = getSettings(record['line'].toString())[key];

          if (setting == null) {
            return const SizedBox();
          }

          final input = data['input']?.toString() ?? '';

          final concentration = data['concentration']?.toString() ?? '';

          final addAmount = data['addAmount']?.toString() ?? '';

          Color? addColor;

          if (addAmount == '不用添加') {
            addColor = Colors.green;
          } else if (addAmount.isNotEmpty && addAmount != '-') {
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
                    child: _smallResult('輸入', input.isEmpty ? '-' : input),
                  ),
                  Expanded(
                    child: _smallResult(
                      '中值',
                      setting.middle == null
                          ? '無中值'
                          : formatNumber(setting.middle!),
                    ),
                  ),
                  Expanded(
                    child: _smallResult(
                      '濃度',
                      concentration.isEmpty ? '-' : concentration,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _smallResult(
                      '需添加量',
                      addAmount.isEmpty ? '-' : addAmount,
                      valueColor: addColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _smallResult(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 3),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('找不到雲端存檔識別碼')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('雲端修改失敗，請稍後再試')),
      );
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
          ...settings.keys.map(
            (key) => Column(children: [input(key), resultPreview(key)]),
          ),
          const SizedBox(height: 20),
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
