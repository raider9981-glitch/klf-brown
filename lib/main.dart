// ============================================================
// KLF-棕化
// 版本：v1.1.2
//
// 本次版本修改內容：
// 1. 只有管理者可以刪除化驗資料
// 2. 一般化驗人員不可刪除化驗資料
// 3. 化驗結果完整顯示濃度及需添加量
// 4. 化驗結果完整顯示未棕化重量、已棕化重量、咬食量
// 5. 存檔資料查看時完整顯示所有化驗結果
// 6. 編輯存檔後重新計算濃度、添加量、咬食量
// 7. A線、B線中值維持分開設定
// 8. 所有濃度固定顯示小數點後1位
// 9. 添加量以濃度小數第1位為計算基準
// 10. 銅離子無中值，不計算添加量
// 11. CBBA-A直接輸入濃度
// 12. 保留瀏覽器 localStorage 存檔
//
// ============================================================

import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

void main() {
  runApp(const KLFApp());
}

// ============================================================
// 全域設定
// ============================================================

class KLFConfig {
  static const String appName = 'KLF-棕化';
  static const String version = 'v1.1.2';

  static const String adminPassword = '0';

  static const String storageAuthorizedUsers = 'klf_authorized_users';
  static const String storageDeviceUser = 'klf_device_user';
  static const String storageAnalysisRecords = 'klf_analysis_records';
}

// ============================================================
// 本機儲存
// ============================================================

class LocalStorageHelper {
  static String? get(String key) {
    return html.window.localStorage[key];
  }

  static void set(String key, String value) {
    html.window.localStorage[key] = value;
  }

  static void remove(String key) {
    html.window.localStorage.remove(key);
  }

  static List<String> getUsers() {
    final data = get(KLFConfig.storageAuthorizedUsers);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(data);

      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    return [];
  }

  static void saveUsers(List<String> users) {
    set(KLFConfig.storageAuthorizedUsers, jsonEncode(users));
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
// 啟動畫面
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

  void _checkDevice() {
    final deviceUser = LocalStorageHelper.getDeviceUser();

    if (deviceUser != null && deviceUser.trim().isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(userName: deviceUser)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
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

  void _login() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = '請輸入授權名稱';
      });
      return;
    }

    final users = LocalStorageHelper.getUsers();

    if (users.contains(name)) {
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
                          onPressed: _login,
                          child: const Text(
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

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _users = LocalStorageHelper.getUsers();
    });
  }

  void _addUser() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('請輸入授權人員名稱');
      return;
    }

    if (_users.contains(name)) {
      _showMessage('這個名稱已經存在');
      return;
    }

    _users.add(name);

    LocalStorageHelper.saveUsers(_users);

    _nameController.clear();

    setState(() {});

    _showMessage('已新增授權人員：$name');
  }

  void _deleteUser(String name) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('刪除授權人員'),
          content: Text('確定要刪除「$name」嗎？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                _users.remove(name);

                LocalStorageHelper.saveUsers(_users);

                setState(() {});

                Navigator.pop(context);

                _showMessage('已刪除：$name');
              },
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
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
                              onPressed: _addUser,
                              icon: const Icon(Icons.add),
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
                      const Text(
                        '已授權人員',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (_users.isEmpty)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KLF-棕化',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
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

// ============================================================
// 化學設定
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

// ============================================================
// A線、B線設定
// ============================================================

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
      addPerPoint: isA ? 1.5 : 0.5,
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
// 數值工具
// ============================================================

double roundToTenth(double value) {
  return (value * 10).round() / 10;
}

String formatNumber(double value) {
  return value.toStringAsFixed(1);
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

  // ==========================================================
  // 濃度
  // ==========================================================

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

  // ==========================================================
  // 添加量
  // ==========================================================

  double? addAmount(String key, String value) {
    final setting = getSettings(widget.lineName)[key];

    if (setting == null) {
      return null;
    }

    if (setting.middle == null) {
      return null;
    }

    if (setting.addPerPoint <= 0) {
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

  // ==========================================================
  // 咬食量
  // ==========================================================

  double? biteAmount() {
    final before = parse(beforeWeightController.text);

    final after = parse(afterWeightController.text);

    if (before == null || after == null) {
      return null;
    }

    return (before - after) / 100 * 21910;
  }

  // ==========================================================
  // 存檔
  // ==========================================================

  void saveRecord() {
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
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'line': widget.lineName,
      'user': widget.userName,
      'time': DateTime.now().toIso8601String(),
      'beforeWeight': beforeWeightController.text.trim(),
      'afterWeight': afterWeightController.text.trim(),
      'biteAmount': bite == null ? '' : formatNumber(bite),
      'chemicals': chemicals,
    };

    final records = LocalStorageHelper.getRecords();

    records.insert(0, record);

    LocalStorageHelper.saveRecords(records);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('化驗資料已存檔'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // 輸入欄
  // ==========================================================

  Widget inputField(String key) {
    final setting = getSettings(widget.lineName)[key]!;

    final controller = controllers[key]!;

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: setting.direct
            ? '${setting.name}｜濃度'
            : '${setting.name}｜滴定值',
        hintText: setting.direct ? '直接輸入濃度' : '輸入滴定值',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ==========================================================
  // 結果框
  // ==========================================================

  Widget _resultBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 化學品列
  // ==========================================================

  Widget chemicalRow(String key) {
    final setting = getSettings(widget.lineName)[key]!;

    final controller = controllers[key]!;

    final value = controller.text;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                          setting.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(flex: 3, child: inputField(key)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _resultBox('中值', displayMiddle(key))),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _resultBox(
                          '濃度',
                          displayConcentration(key, value),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
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
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(flex: 3, child: inputField(key)),
                const SizedBox(width: 8),
                Expanded(child: _resultBox('中值', displayMiddle(key))),
                const SizedBox(width: 8),
                Expanded(
                  child: _resultBox('濃度', displayConcentration(key, value)),
                ),
                const SizedBox(width: 8),
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

  // ==========================================================
  // 槽位
  // ==========================================================

  Widget tankCard({
    required String title,
    required String description,
    required List<String> keys,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            ...keys.map((key) => chemicalRow(key)),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 咬食量區塊
  // ==========================================================

  Widget biteCard() {
    final bite = biteAmount();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '咬食量',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              '未棕化重量、已棕化重量由化驗人員輸入，系統自動計算。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: beforeWeightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: '未棕化重量',
                      suffixText: 'g',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: afterWeightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: '已棕化重量',
                      suffixText: 'g',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE4DE),
                borderRadius: BorderRadius.circular(10),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '公式：(未棕化重量－已棕化重量) ÷ 100 × 21910',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // Build
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.lineName}｜藥水化驗')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      const SizedBox(width: 10),
                      Text(
                        '化驗人員：${widget.userName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                color: const Color(0xFFEDE4DE),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    '顯示方式：滴定值 → 中值 → 濃度 → 需添加量',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              tankCard(
                title: '第一槽｜酸洗槽',
                description: '硫酸、雙氧水',
                keys: const ['acid_sulfuric', 'acid_h2o2'],
              ),

              const SizedBox(height: 12),

              tankCard(
                title: '第二槽｜清潔槽',
                description: 'HL-II',
                keys: const ['clean_hl2'],
              ),

              const SizedBox(height: 12),

              tankCard(
                title: '第三槽｜預浸槽',
                description: '雙氧水、CBBA-A',
                keys: const ['pre_h2o2', 'pre_cbba'],
              ),

              const SizedBox(height: 12),

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

              const SizedBox(height: 12),

              biteCard(),

              const SizedBox(height: 15),

              SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: saveRecord,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    '化驗完成並存檔',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 52,
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

              const SizedBox(height: 25),

              Center(
                child: Text(
                  '${KLFConfig.appName} ${KLFConfig.version}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
// 存檔列表
// ============================================================

class RecordsPage extends StatefulWidget {
  final String userName;

  const RecordsPage({super.key, required this.userName});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      records = LocalStorageHelper.getRecords();
    });
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

  // ==========================================================
  // 只有管理者可以刪除
  // ==========================================================

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

  void _deleteRecord(String id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('刪除存檔'),
          content: const Text('確定要永久刪除這筆化驗資料嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                records.removeWhere((record) => record['id'] == id);

                LocalStorageHelper.saveRecords(records);

                Navigator.pop(context);

                _load();
              },
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
  }

  void _openRecord(Map<String, dynamic> record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RecordEditPage(record: record, userName: widget.userName),
      ),
    ).then((_) {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('化驗存檔')),
      body: records.isEmpty
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

                final bite = record['biteAmount'] ?? '';

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

                        // ==================================================
                        // 刪除按鈕
                        // 只有通過管理者密碼才可以刪除
                        // ==================================================
                        IconButton(
                          tooltip: '管理者刪除',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _requestAdminDelete(record['id'].toString());
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

  // ==========================================================
  // 存檔結果完整顯示
  // ==========================================================

  Widget _recordSummary(Map<String, dynamic> record) {
    final chemicals = Map<String, dynamic>.from(record['chemicals'] ?? {});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
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
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 8),

        Card(
          color: const Color(0xFFEDE4DE),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '未棕化重量：${record['beforeWeight'] ?? '-'} g',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '已棕化重量：${record['afterWeight'] ?? '-'} g',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '咬食量：${record['biteAmount'] == null || record['biteAmount'].toString().isEmpty ? '-' : record['biteAmount']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallResult(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 存檔編輯
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

  // ==========================================================
  // 儲存修改
  // ==========================================================

  void save() {
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

    updated['editedTime'] = DateTime.now().toIso8601String();

    final records = LocalStorageHelper.getRecords();

    final index = records.indexWhere(
      (record) => record['id'] == widget.record['id'],
    );

    if (index >= 0) {
      records[index] = updated;
    }

    LocalStorageHelper.saveRecords(records);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('修改已儲存')));

    Navigator.pop(context);
  }

  // ==========================================================
  // 編輯輸入
  // ==========================================================

  Widget input(String key) {
    final setting = getSettings(lineName)[key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: setting.direct
              ? '${setting.name}｜濃度'
              : '${setting.name}｜滴定值',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // ==========================================================
  // 編輯結果預覽
  // ==========================================================

  Widget resultPreview(String key) {
    final setting = getSettings(lineName)[key]!;

    final value = controllers[key]!.text;

    final concentrationValue = concentration(key, value);

    final add = addAmount(key, value);

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
              child: _editResult(
                '需添加量',
                add == null
                    ? '-'
                    : add <= 0
                    ? '不用添加'
                    : '${formatNumber(add)} ${setting.unit}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editResult(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ==========================================================
  // Build
  // ==========================================================

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

          ...settings.keys.map(
            (key) => Column(children: [input(key), resultPreview(key)]),
          ),

          const SizedBox(height: 10),

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
