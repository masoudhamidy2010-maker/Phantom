import 'dart:math' as m;
import 'package:flutter/material.dart';
import 'more.dart';
import 'state.dart';
import 'ui.dart';

/// ===== خوشامدگویی و راهنمای تعاملی =====
class Onboarding extends StatefulWidget {
  const Onboarding({super.key});
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final pc = PageController();
  int i = 0;
  static const pages = [
    (Icons.bolt_rounded, 'انرژی کاشان', 'مصرف برق خود را ببینید، بسنجید و هوشمندانه مدیریت کنید.', kBlue),
    (Icons.insights_rounded, 'تحلیل و هشدار', 'روند مصرف، مقایسه با دوره‌های قبل و یادآوری قبض در یک جا.', kYellow),
    (Icons.map_rounded, 'نقشه و چالش‌ها', 'نقشه‌ی ایران در روز و شب و چالش‌های صرفه‌جویی برای شهر.', kRed),
  ];

  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    return Bg(
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: () => a.update(() => a.onboarded = true), child: const Text('رد کردن')),
            ),
            Expanded(
              child: PageView.builder(
                controller: pc,
                itemCount: pages.length,
                onPageChanged: (v) => setState(() => i = v),
                itemBuilder: (_, k) {
                  final p = pages[k];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      TweenAnimationBuilder<double>(
                        key: ValueKey(k),
                        tween: Tween(begin: .6, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (_, s, __) => Transform.scale(
                          scale: s,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(color: p.$4.withOpacity(.15), shape: BoxShape.circle),
                            child: Icon(p.$1, size: 72, color: p.$4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(p.$2, style: Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(p.$3, textAlign: TextAlign.center, style: Theme.of(c).textTheme.bodyLarge),
                    ]),
                  );
                },
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var k = 0; k < pages.length; k++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  width: k == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: k == i ? kBlue : Colors.grey.withOpacity(.4), borderRadius: BorderRadius.circular(8)),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: kBlue),
                onPressed: () => i == pages.length - 1
                    ? a.update(() => a.onboarded = true)
                    : pc.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut),
                child: Text(i == pages.length - 1 ? 'شروع کنید' : 'بعدی'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// ===== ورود، ثبت‌نام، بازیابی، مدیر =====
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int mode = 0; // 0 ورود، 1 ثبت‌نام، 2 مدیر، 3 بازیابی
  final uc = TextEditingController(), pc = TextEditingController();

  void go() {
    final a = Scope.of(context);
    final u = uc.text.trim(), p = pc.text;
    String? err;
    if (mode == 3) {
      err = a.users.containsKey(u)
          ? 'بازیابی رمز نیازمند سرور است؛ پس از اتصال به بک‌اند پیامک تأیید ارسال می‌شود.'
          : 'کاربری با این نام یافت نشد.';
    } else if (u.isEmpty || p.length < 4) {
      err = 'نام کاربری و رمز (حداقل ۴ کاراکتر) را وارد کنید.';
    } else if (mode == 2) {
      if (u == 'admin' && p == 'admin123') {
        a.update(() { a.signedIn = true; a.isAdmin = true; a.name = 'مدیر'; a.tab = 0; });
      } else {
        err = 'اطلاعات مدیر نادرست است.';
      }
    } else if (mode == 1) {
      if (a.users.containsKey(u)) {
        err = 'این نام کاربری قبلاً ثبت شده است.';
      } else {
        a.users[u] = p;
        a.update(() { a.signedIn = true; a.isAdmin = false; a.name = u; a.tab = 0; });
      }
    } else if (a.users[u] == p) {
      a.update(() { a.signedIn = true; a.isAdmin = false; a.name = u; a.tab = 0; });
    } else {
      err = 'نام کاربری یا رمز اشتباه است.';
    }
    if (err != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
  }

  @override
  Widget build(BuildContext c) {
    const labels = ['ورود', 'ثبت‌نام', 'مدیر', 'بازیابی'];
    return Bg(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Icon(Icons.bolt_rounded, size: 64, color: kYellow),
                Text('انرژی کاشان', style: Theme.of(c).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: kBlue)),
                const SizedBox(height: 20),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [for (var k = 0; k < 4; k++) ButtonSegment(value: k, label: Text(labels[k], style: const TextStyle(fontSize: 12)))],
                  selected: {mode},
                  onSelectionChanged: (s) => setState(() => mode = s.first),
                ),
                const SizedBox(height: 20),
                Glass(
                  child: Column(children: [
                    TextField(controller: uc, decoration: const InputDecoration(labelText: 'نام کاربری', prefixIcon: Icon(Icons.person_outline))),
                    if (mode != 3) ...[
                      const SizedBox(height: 12),
                      TextField(controller: pc, obscureText: true, decoration: const InputDecoration(labelText: 'رمز عبور', prefixIcon: Icon(Icons.lock_outline))),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: mode == 2 ? kRed : kBlue),
                      onPressed: go,
                      child: Text(mode == 3 ? 'بازیابی حساب' : labels[mode]),
                    ),
                  ]),
                ),
                Text(
                  mode == 2 ? 'نسخه‌ی آزمایشی: admin / admin123' : 'حساب آزمایشی: demo / 1234',
                  style: Theme.of(c).textTheme.bodySmall,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===== قالب اصلی و ناوبری =====
class Shell extends StatelessWidget {
  const Shell({super.key});
  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    const titles = ['انرژی کاشان', 'تحلیل مصرف', 'نقشه ایران', 'ابزارها', 'حساب و تنظیمات'];
    final pages = [
      a.isAdmin ? const AdminPage() : const Dashboard(),
      const AnalysisPage(),
      const MapPage(),
      const ToolsPage(),
      const MorePage(),
    ];
    return Bg(
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[a.tab]),
          actions: [
            IconButton(
              icon: Badge(
                isLabelVisible: a.notifOn && a.notifs.isNotEmpty,
                label: Text(fa(a.notifs.length)),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => showModalBottomSheet(context: c, builder: (_) => const NotifSheet()),
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (w, an) => FadeTransition(
            opacity: an,
            child: SlideTransition(position: Tween(begin: const Offset(0, .03), end: Offset.zero).animate(an), child: w),
          ),
          child: KeyedSubtree(key: ValueKey(a.tab), child: pages[a.tab]),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: a.tab,
          onDestinationSelected: (i) => a.update(() => a.tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'تحلیل'),
            NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'نقشه'),
            NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: 'ابزارها'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حساب'),
          ],
        ),
      ),
    );
  }
}

class NotifSheet extends StatelessWidget {
  const NotifSheet({super.key});
  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    return SafeArea(
      child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(16), children: [
        Row(children: [
          const Expanded(child: Text('اعلان‌ها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          if (a.notifs.isNotEmpty) TextButton(onPressed: () => a.update(() => a.notifs.clear()), child: const Text('پاک کردن')),
        ]),
        if (a.notifs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('اعلانی وجود ندارد.'))),
        for (final n in a.notifs) ListTile(leading: const Icon(Icons.notifications_active_outlined, color: kYellow), title: Text(n)),
      ]),
    );
  }
}

/// ===== داشبورد شخصی =====
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashState();
}

class _DashState extends State<Dashboard> {
  int range = 0;
  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    final j = toJalali(DateTime.now());
    final mi = j[1] - 1;
    final mk = monthKwh[mi];
    final yk = monthKwh.take(mi + 1).fold(0.0, (s, e) => s + e);
    Widget stat(String t, String v) => Expanded(
          child: Glass(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: Theme.of(c).textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(fa(v == 'm' ? mk * kRate : yk * kRate), style: Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: kBlue)),
              Text('تومان (برآورد)', style: Theme.of(c).textTheme.bodySmall),
            ]),
          ),
        );
    return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      Row(children: [
        const CircleAvatar(backgroundColor: kBlue, child: Icon(Icons.person, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('سلام، ${a.name}', style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('${fa(j[2])} ${jMonths[mi]} ${fa(j[0])}', style: Theme.of(c).textTheme.bodySmall),
          ]),
        ),
        const SourceTag(),
      ]),
      const SizedBox(height: 16),
      Glass(
        child: Row(children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: .72),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => SizedBox(
              width: 104,
              height: 104,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(value: 1, strokeWidth: 11, color: kBlue.withOpacity(.12)),
                CircularProgressIndicator(value: v, strokeWidth: 11, strokeCap: StrokeCap.round, color: kBlue),
                Text('${fa(v * 100)}٪', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('امتیاز بهینگی (نمونه)', style: Theme.of(c).textTheme.bodySmall),
              const SizedBox(height: 6),
              Text('${fa(mk)} کیلووات‌ساعت', style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('مصرف این ماه', style: Theme.of(c).textTheme.bodySmall),
            ]),
          ),
        ]),
      ),
      Row(children: [stat('هزینه ماه جاری', 'm'), const SizedBox(width: 12), stat('هزینه سال جاری', 'y')]),
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('روند مصرف برق', style: TextStyle(fontWeight: FontWeight.bold))),
            SegmentedButton<int>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [ButtonSegment(value: 0, label: Text('هفته')), ButtonSegment(value: 1, label: Text('سال'))],
              selected: {range},
              onSelectionChanged: (s) => setState(() => range = s.first),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: range == 0
                ? lineChart(weekKwh, weekLabels, kBlue)
                : lineChart(monthKwh, [for (var k = 1; k <= 12; k++) fa(k)], kBlue),
          ),
        ]),
      ),
      Glass(
        tint: kYellow.withOpacity(isDark(c) ? .16 : .25),
        child: Row(children: [
          const Icon(Icons.event_note_rounded, color: kYellow, size: 34),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('یادآوری پرداخت قبض', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('هر ماه، پیش از پایان مهلت قبض'),
            ]),
          ),
          FilledButton.tonal(
            onPressed: () {
              a.update(() => a.notifs.insert(0, 'یادآوری قبض برای این ماه تنظیم شد'));
              ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('یادآوری ثبت شد.')));
            },
            child: const Text('یادآوری کن'),
          ),
        ]),
      ),
      GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          for (final q in [
            (Icons.map_rounded, 'نقشه', () => a.update(() => a.tab = 2)),
            (Icons.receipt_long_rounded, 'قبض‌ها', () => a.update(() => a.tab = 3)),
            (Icons.bar_chart_rounded, 'تحلیل', () => a.update(() => a.tab = 1)),
            (Icons.school_rounded, 'آموزش', () => push(c, const LearnPage())),
          ])
            Glass(
              padding: EdgeInsets.zero,
              onTap: q.$3,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(q.$1, color: kBlue),
                const SizedBox(height: 4),
                Text(q.$2, style: const TextStyle(fontSize: 12)),
              ]),
            ),
        ],
      ),
    ]);
  }
}

/// ===== تحلیل مصرف =====
class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});
  @override
  State<AnalysisPage> createState() => _AnalysisState();
}

class _AnalysisState extends State<AnalysisPage> {
  int r = 0;
  @override
  Widget build(BuildContext c) {
    final vals = [weekKwh, monthKwh, const [2650.0, 2800.0, 3100.0, 3250.0]][r];
    final labels = [
      weekLabels,
      [for (var k = 1; k <= 12; k++) fa(k)],
      ['۱۴۰۲', '۱۴۰۳', '۱۴۰۴', '۱۴۰۵'],
    ][r];
    final last = vals.last, prev = vals[vals.length - 2];
    final ch = (last - prev) / prev * 100;
    const pal = [kBlue, kYellow, kRed, Color(0xFF7B93C9), Color(0xFFB8C2D6)];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      Row(children: [const Expanded(child: SizedBox()), const SourceTag()]),
      SegmentedButton<int>(
        showSelectedIcon: false,
        segments: const [ButtonSegment(value: 0, label: Text('روزانه')), ButtonSegment(value: 1, label: Text('ماهانه')), ButtonSegment(value: 2, label: Text('سالانه'))],
        selected: {r},
        onSelectionChanged: (s) => setState(() => r = s.first),
      ),
      const SizedBox(height: 12),
      Glass(child: SizedBox(height: 200, child: barChart(vals, labels, kBlue))),
      Glass(
        child: Row(children: [
          Icon(ch > 0 ? Icons.trending_up : Icons.trending_down, color: ch > 0 ? kRed : kBlue, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${ch > 0 ? '+' : ''}${fa(ch, d: 1)}٪ نسبت به دوره‌ی قبل', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(ch > 0 ? 'مصرف افزایش یافته است؛ پیشنهادها را ببینید.' : 'مصرف کاهش یافته است؛ ادامه دهید.', style: Theme.of(c).textTheme.bodySmall),
            ]),
          ),
        ]),
      ),
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('سهم دستگاه‌ها (نمونه)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          for (var i = 0; i < shares.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                SizedBox(width: 110, child: Text(shares[i].$1, style: const TextStyle(fontSize: 12))),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(r),
                    tween: Tween(begin: 0, end: shares[i].$2 / 100),
                    duration: const Duration(milliseconds: 700),
                    builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 9, borderRadius: BorderRadius.circular(8), color: pal[i], backgroundColor: pal[i].withOpacity(.15)),
                  ),
                ),
                SizedBox(width: 40, child: Text('${fa(shares[i].$2)}٪', textAlign: TextAlign.end, style: const TextStyle(fontSize: 12))),
              ]),
            ),
        ]),
      ),
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('پیشنهاد متناسب با الگوی مصرف', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(ch > 0 ? '• دمای سرمایش/گرمایش را یک تا دو درجه تعدیل کنید.\n• وسایل پرمصرف را در ساعات کم‌باری استفاده کنید.' : '• روند خوبی دارید؛ چالش «۱۰٪ کاهش» را امتحان کنید.'),
        ]),
      ),
      Glass(
        child: Row(children: [
          const Icon(Icons.schedule, color: kYellow),
          const SizedBox(width: 12),
          Expanded(child: Text('ساعات اوج مصرف: داده‌ی ساعتی معتبری دریافت نشده است. پس از اتصال به کنتور یا منبع رسمی نمایش داده می‌شود.', style: Theme.of(c).textTheme.bodySmall)),
        ]),
      ),
    ]);
  }
}

/// ===== نقشه‌ی ایران (روز و شب) =====
class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapState();
}

class _MapState extends State<MapPage> with SingleTickerProviderStateMixin {
  late final ac = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override
  void dispose() {
    ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final d = isDark(c);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 1.32,
          child: AnimatedBuilder(animation: ac, builder: (_, __) => CustomPaint(painter: IranPainter(d, ac.value))),
        ),
      ),
      const SizedBox(height: 12),
      Glass(
        child: Row(children: [
          const Icon(Icons.location_on, color: kRed),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('کاشان', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(d ? 'حالت شب: شهرها مانند چراغ‌های روشن دیده می‌شوند.' : 'حالت روز: نمایش با نور طبیعی.', style: Theme.of(c).textTheme.bodySmall),
            ]),
          ),
        ]),
      ),
      Text('نقشه‌ی شماتیک و ساده‌شده است و داده‌ی مصرف واقعی شهرها را نشان نمی‌دهد.', style: Theme.of(c).textTheme.bodySmall),
    ]);
  }
}

class IranPainter extends CustomPainter {
  final bool dark;
  final double t;
  IranPainter(this.dark, this.t);

  static const outline = [
    [44.0, 39.4], [45.5, 38.9], [47.5, 39.6], [48.9, 38.4], [49.5, 37.5], [51.0, 36.8], [53.9, 37.3], [54.7, 37.5],
    [56.0, 38.2], [57.3, 38.0], [59.3, 37.6], [60.5, 36.6], [61.2, 36.6], [60.8, 34.5], [60.5, 33.6], [60.9, 31.5],
    [61.8, 31.3], [61.6, 29.8], [63.2, 29.5], [62.4, 28.2], [61.6, 25.2], [57.3, 25.7], [56.7, 27.1], [54.5, 26.6],
    [52.5, 27.5], [51.0, 28.9], [50.1, 30.2], [48.9, 30.2], [48.0, 30.0], [47.7, 31.0], [46.1, 33.0], [45.4, 34.4],
    [45.9, 35.9], [44.8, 37.2], [44.2, 38.4],
  ];
  // طول، عرض، وزن روشنایی
  static const cities = [
    [51.4, 35.7, 3.0], [59.6, 36.3, 2.2], [51.7, 32.65, 2.0], [52.5, 29.6, 1.8], [46.3, 38.1, 1.8],
    [48.7, 31.3, 1.6], [57.1, 30.3, 1.2], [49.6, 37.3, 1.2], [56.3, 27.2, 1.0], [60.9, 29.5, 0.8],
    [54.4, 31.9, 1.0], [47.1, 34.3, 1.1], [51.45, 33.98, 1.4],
  ];

  Offset _p(double lo, double la, Size s) => Offset((lo - 43.5) / 20.5 * s.width, (40 - la) / 15.5 * s.height);

  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark ? const [Color(0xFF050B1A), Color(0xFF0E1B3D)] : const [Color(0xFFD6E6FF), Colors.white],
        ).createShader(r),
    );
    final path = Path();
    for (var i = 0; i < outline.length; i++) {
      final o = _p(outline[i][0], outline[i][1], s);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    path.close();
    if (dark) {
      final rnd = m.Random(7);
      for (var i = 0; i < 60; i++) {
        final tw = (m.sin(t * 6.283 + i) + 1) / 2;
        c.drawCircle(Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height * .9), rnd.nextDouble() * 1.1 + .3, Paint()..color = Colors.white.withOpacity(.2 + .5 * tw));
      }
    } else {
      c.drawShadow(path, const Color(0xFF2463EB), 10, true);
    }
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark ? const [Color(0xFF14224A), Color(0xFF0C1630)] : const [Colors.white, kSilver],
        ).createShader(r),
    );
    c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = dark ? const Color(0xFF3A4F85) : kBlue.withOpacity(.55));

    for (var k = 0; k < cities.length; k++) {
      final ct = cities[k];
      final o = _p(ct[0], ct[1], s);
      final w = ct[2];
      final rnd = m.Random(k + 11);
      if (dark) {
        final tw = .55 + .35 * m.sin(t * 6.283 + k);
        c.drawCircle(o, 9 + 4 * w, Paint()..color = kYellow.withOpacity(.35 * tw)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
        for (var i = 0; i < (w * 9).round(); i++) {
          final q = o + Offset((rnd.nextDouble() - .5) * (16 + 6 * w), (rnd.nextDouble() - .5) * (16 + 6 * w));
          c.drawCircle(q, .9 + rnd.nextDouble() * .8, Paint()..color = const Color(0xFFFFE9A8).withOpacity(.6 + .4 * tw));
        }
        c.drawCircle(o, 2 + w * .5, Paint()..color = const Color(0xFFFFF4CC));
      } else {
        for (var i = 0; i < (w * 5).round(); i++) {
          final q = o + Offset((rnd.nextDouble() - .5) * (14 + 5 * w), (rnd.nextDouble() - .5) * (14 + 5 * w));
          c.drawCircle(q, 1.1, Paint()..color = kBlue.withOpacity(.35));
        }
        c.drawCircle(o, 2.2 + w * .5, Paint()..color = kBlue);
      }
    }
    final k = _p(51.45, 33.98, s);
    c.drawCircle(k, 7 + 14 * t, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = kRed.withOpacity(1 - t));
    c.drawCircle(k, 4.5, Paint()..color = kRed);
    final tp = TextPainter(
      text: TextSpan(text: 'کاشان', style: TextStyle(color: dark ? Colors.white : kBlue, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(c, k + const Offset(10, -7));
  }

  @override
  bool shouldRepaint(IranPainter o) => true;
}
