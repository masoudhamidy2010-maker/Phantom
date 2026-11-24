import 'dart:async';
import 'package:flutter/material.dart';

/// ===== داده‌های نمونه (نمایشی؛ داده‌ی واقعی مصرف برق نیستند) =====
const kRate = 1850; // نرخ نمونه‌ی هر کیلووات‌ساعت (تومان)
const weekLabels = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
const weekKwh = [11.2, 10.5, 12.1, 10.8, 11.9, 13.4, 14.2];
const monthKwh = [230.0, 215, 245, 330, 470, 640, 730, 700, 360, 280, 225, 240];
const curMonth = 8; // آبان/آذر در داده‌ی نمونه
const shares = [
  ('سرمایش و گرمایش', 42),
  ('یخچال و فریزر', 18),
  ('روشنایی', 14),
  ('لوازم آشپزخانه', 12),
  ('سایر', 14),
];
const districts = [('مرکز', 48.0), ('فین', 21.0), ('قمصر', 14.0), ('نیاسر', 9.0), ('حومه', 17.0)];
const presets = {
  'کولر آبی': 250.0, 'کولر گازی': 1200.0, 'یخچال': 150.0, 'لامپ LED': 10.0,
  'تلویزیون': 100.0, 'لباسشویی': 500.0, 'بخاری برقی': 1500.0,
};
const challenges = [
  ('۱۰٪ کاهش در یک ماه', 'مصرف این ماه را ۱۰٪ زیر ماه قبل نگه دارید.', 0.6),
  ('لامپ‌های بی‌استفاده خاموش', 'یک هفته هیچ لامپ روشنی در اتاق خالی نماند.', 0.35),
  ('دوری از ساعت اوج', 'بین ساعت ۱۲ تا ۱۶ وسایل پرمصرف را روشن نکنید.', 0.8),
];
const lessons = {
  'کاهش مصرف انرژی': [
    'دمای کولر گازی را روی ۲۴ تا ۲۶ درجه تنظیم کنید.',
    'لامپ‌های رشته‌ای را با LED عوض کنید.',
    'وسایل را در حالت آماده‌به‌کار نگذارید و از چندراهی کلیددار استفاده کنید.',
  ],
  'نکات کاربردی صرفه‌جویی': [
    'در تابستان پنجره‌ها را در ساعات گرم روز ببندید و شب هوا را تهویه کنید.',
    'درِ یخچال را زیاد باز نگذارید و غذای گرم را داخل آن نگذارید.',
    'لباسشویی را با بار کامل و آب سرد روشن کنید.',
  ],
  'انرژی و محیط زیست': [
    'تولید برق از سوخت‌های فسیلی گازهای گلخانه‌ای تولید می‌کند.',
    'کاهش مصرف یعنی فشار کمتر بر شبکه و خاموشی کمتر.',
    'انرژی خورشیدی برای اقلیم آفتابیِ کاشان گزینه‌ی مناسبی است.',
  ],
};

String fa(num n, {int d = 0}) {
  final p = n.toStringAsFixed(d).split('.');
  final i = p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '٬');
  final s = p.length > 1 ? '$i٫${p[1]}' : i;
  const e = '0123456789', f = '۰۱۲۳۴۵۶۷۸۹';
  return s.split('').map((c) {
    final k = e.indexOf(c);
    return k < 0 ? c : f[k];
  }).join();
}

class Bill {
  String title, status;
  int amount;
  String? receipt;
  Bill(this.title, this.amount, this.status);
}

/// ===== وضعیت برنامه =====
class AppState extends ChangeNotifier {
  String themePref = 'auto'; // auto | light | dark
  Color seed = const Color(0xFF2463EB);
  double scale = 1.0;
  bool onboarded = false;
  final Map<String, bool> alerts = {'افزایش مصرف': true, 'موعد پرداخت قبض': true, 'قطعی برق': true, 'یادداشت روزانه': false};
  final List<Bill> bills = [
    Bill('قبض مهر (نمونه)', 412000, 'پرداخت‌شده'),
    Bill('قبض آبان (نمونه)', 387000, 'پرداخت‌نشده'),
  ];
  bool signedIn = false, isAdmin = false, notifOn = true;
  String name = '';
  int tab = 0;
  final Map<String, String> users = {'demo': '1234'}; // فقط نمایشی؛ به بک‌اند وصل کنید
  final Set<int> joined = {};
  final List<String> notifs = [
    'یادآوری: مهلت پرداخت قبض برق ماه جاری نزدیک است (نمونه)',
    'نکته: بین ساعت ۱۲ تا ۱۶ مصرف وسایل پرمصرف را کم کنید',
  ];
  late final Timer _t;

  AppState() {
    _t = Timer.periodic(const Duration(minutes: 1), (_) => notifyListeners());
  }

  /// در حالت خودکار، از ۱۸ تا ۶ صبح شب است.
  bool get dark {
    if (themePref == 'auto') {
      final h = DateTime.now().hour;
      return h < 6 || h >= 18;
    }
    return themePref == 'dark';
  }

  void update(VoidCallback f) {
    f();
    notifyListeners();
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }
}

class Scope extends InheritedNotifier<AppState> {
  const Scope({super.key, required AppState super.notifier, required super.child});
  static AppState of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<Scope>()!.notifier!;
}
