import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state.dart';
import 'ui.dart';

/// ===== ابزارها: ماشین‌حساب، قبض‌ها، چالش‌ها =====
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});
  @override
  Widget build(BuildContext c) => DefaultTabController(
        length: 3,
        child: Column(children: const [
          TabBar(tabs: [Tab(text: 'ماشین‌حساب'), Tab(text: 'قبض‌ها'), Tab(text: 'چالش‌ها')]),
          Expanded(child: TabBarView(children: [CalcTab(), BillsTab(), ChallengesTab()])),
        ]),
      );
}

class CalcTab extends StatefulWidget {
  const CalcTab({super.key});
  @override
  State<CalcTab> createState() => _CalcState();
}

class _CalcState extends State<CalcTab> {
  String sel = 'کولر آبی';
  double w = 250, h = 8;
  int q = 1;
  @override
  Widget build(BuildContext c) {
    final kwh = w * q * h * 30 / 1000;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DropdownButtonFormField<String>(
            value: sel,
            decoration: const InputDecoration(labelText: 'وسیله‌ی برقی'),
            items: [for (final e in presets.keys) DropdownMenuItem(value: e, child: Text(e))],
            onChanged: (v) => setState(() { sel = v!; w = presets[v]!; }),
          ),
          const SizedBox(height: 12),
          Text('توان: ${fa(w)} وات'),
          Slider(value: w, min: 5, max: 3000, onChanged: (v) => setState(() => w = v.roundToDouble())),
          Text('مدت استفاده: ${fa(h, d: 1)} ساعت در روز'),
          Slider(value: h, min: 0, max: 24, divisions: 48, onChanged: (v) => setState(() => h = v)),
          Row(children: [
            const Text('تعداد'),
            const Spacer(),
            IconButton(onPressed: q > 1 ? () => setState(() => q--) : null, icon: const Icon(Icons.remove_circle_outline)),
            Text(fa(q), style: const TextStyle(fontSize: 18)),
            IconButton(onPressed: () => setState(() => q++), icon: const Icon(Icons.add_circle_outline)),
          ]),
        ]),
      ),
      Glass(
        tint: kBlue.withOpacity(.1),
        child: Column(children: [
          Text('مصرف ماهانه: ${fa(kwh, d: 1)} کیلووات‌ساعت', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('هزینه‌ی تقریبی: ${fa(kwh * kRate)} تومان', style: const TextStyle(fontSize: 18, color: kBlue, fontWeight: FontWeight.bold)),
          Text('با نرخ نمونه‌ی ${fa(kRate)} تومان به ازای هر کیلووات‌ساعت', style: Theme.of(c).textTheme.bodySmall),
        ]),
      ),
    ]);
  }
}

class BillsTab extends StatefulWidget {
  const BillsTab({super.key});
  @override
  State<BillsTab> createState() => _BillsState();
}

class _BillsState extends State<BillsTab> {
  Future<void> upload(Bill b) async {
    final a = Scope.of(context);
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (f == null) return;
    a.update(() { b.receipt = f.path; b.status = 'در انتظار تأیید'; });
  }

  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    final col = {'پرداخت‌شده': kBlue, 'پرداخت‌نشده': kRed, 'در انتظار تأیید': kYellow};
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Padding(padding: EdgeInsets.only(bottom: 8), child: SourceTag()),
      for (final b in a.bills)
        Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold))),
              Chip(label: Text(b.status, style: const TextStyle(fontSize: 11)), side: BorderSide(color: col[b.status]!)),
            ]),
            Text('${fa(b.amount)} تومان'),
            if (b.receipt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(b.receipt!), height: 110, fit: BoxFit.cover)),
              ),
            const SizedBox(height: 8),
            Row(children: [
              if (b.status == 'پرداخت‌نشده')
                FilledButton(
                  onPressed: () => showDialog(
                    context: c,
                    builder: (_) => AlertDialog(
                      title: const Text('پرداخت از درگاه'),
                      content: const Text('درگاه بانکی هنوز متصل نیست. پرداخت فقط از طریق درگاه معتبر و با تأیید سمت سرور انجام می‌شود. تا آن زمان می‌توانید رسید ATM را بارگذاری کنید.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('بستن'))],
                    ),
                  ),
                  child: const Text('پرداخت'),
                ),
              const SizedBox(width: 8),
              if (b.status != 'پرداخت‌شده')
                OutlinedButton.icon(onPressed: () => upload(b), icon: const Icon(Icons.upload_file), label: const Text('بارگذاری رسید')),
            ]),
          ]),
        ),
    ]);
  }
}

class ChallengesTab extends StatelessWidget {
  const ChallengesTab({super.key});
  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    return ListView(padding: const EdgeInsets.all(16), children: [
      for (var i = 0; i < challenges.length; i++)
        Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(challenges[i].$1, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(challenges[i].$2, style: Theme.of(c).textTheme.bodySmall),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: a.joined.contains(i) ? challenges[i].$3 : 0, minHeight: 8, borderRadius: BorderRadius.circular(8), color: kYellow, backgroundColor: kYellow.withOpacity(.2)),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => a.update(() {
                if (a.joined.add(i)) {
                  a.notifs.insert(0, 'به چالش «${challenges[i].$1}» پیوستید');
                } else {
                  a.joined.remove(i);
                }
              }),
              child: Text(a.joined.contains(i) ? 'انصراف' : 'پیوستن'),
            ),
          ]),
        ),
    ]);
  }
}

/// ===== حساب و تنظیمات =====
class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    Widget tile(IconData i, String t, Widget p) => Glass(padding: EdgeInsets.zero, child: ListTile(leading: Icon(i, color: kBlue), title: Text(t), trailing: const Icon(Icons.chevron_left), onTap: () => push(c, p)));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      Glass(
        child: Row(children: [
          const CircleAvatar(radius: 28, backgroundColor: kBlue, child: Icon(Icons.person, color: Colors.white, size: 30)),
          const SizedBox(width: 14),
          Text(a.name, style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (a.isAdmin) const Padding(padding: EdgeInsets.only(right: 8), child: Chip(label: Text('مدیر', style: TextStyle(fontSize: 11)))),
        ]),
      ),
      tile(Icons.speed, 'اشتراک و اطلاعات کنتور', const SubPage()),
      tile(Icons.school_outlined, 'آموزش و فرهنگ‌سازی', const LearnPage()),
      tile(Icons.edit_note, 'یادداشت‌ها و جست‌وجو', const NotesPage()),
      tile(Icons.notifications_active_outlined, 'هشدارهای هوشمند', const AlertsPage()),
      tile(Icons.support_agent, 'پشتیبانی و قطعی برق', const SupportPage()),
      tile(Icons.palette_outlined, 'شخصی‌سازی ظاهر', const ThemePage()),
      Glass(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.logout, color: kRed),
          title: const Text('خروج از حساب'),
          onTap: () => a.update(() { a.signedIn = false; a.isAdmin = false; a.tab = 0; }),
        ),
      ),
    ]);
  }
}

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});
  @override
  Widget build(BuildContext c) => Frame('آموزش و فرهنگ‌سازی', child: ListView(padding: const EdgeInsets.all(16), children: [
        for (final e in lessons.entries)
          Glass(
            padding: EdgeInsets.zero,
            child: ExpansionTile(
              shape: const Border(),
              leading: const Icon(Icons.lightbulb_outline, color: kYellow),
              title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [for (final t in e.value) ListTile(dense: true, leading: const Icon(Icons.check_circle, size: 18, color: kBlue), title: Text(t))],
            ),
          ),
      ]));
}

class SubPage extends StatefulWidget {
  const SubPage({super.key});
  @override
  State<SubPage> createState() => _SubState();
}

class _SubState extends State<SubPage> {
  final id = TextEditingController(), meter = TextEditingController();
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      id.text = p.getString('billId') ?? '';
      meter.text = p.getString('meter') ?? '';
    });
  }

  @override
  Widget build(BuildContext c) => Frame('اشتراک و کنتور', child: ListView(padding: const EdgeInsets.all(16), children: [
        Glass(
          child: Column(children: [
            TextField(controller: id, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'شناسه‌ی قبض')),
            const SizedBox(height: 12),
            TextField(controller: meter, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'شماره‌ی کنتور')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final p = await SharedPreferences.getInstance();
                await p.setString('billId', id.text);
                await p.setString('meter', meter.text);
                if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('روی دستگاه ذخیره شد.')));
              },
              child: const Text('ذخیره'),
            ),
          ]),
        ),
        Text('اطلاعات فقط روی همین دستگاه نگه داشته می‌شود و هنوز به سامانه‌ی رسمی وصل نیست.', style: Theme.of(c).textTheme.bodySmall),
      ]));
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesState();
}

class _NotesState extends State<NotesPage> {
  List<String> notes = [];
  String q = '';
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) => setState(() => notes = p.getStringList('notes') ?? []));
  }

  Future<void> save() async => (await SharedPreferences.getInstance()).setStringList('notes', notes);

  void add() {
    final t = TextEditingController();
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('یادداشت جدید'),
        content: TextField(controller: t, maxLines: 3, autofocus: true),
        actions: [
          TextButton(
            onPressed: () {
              if (t.text.trim().isNotEmpty) { setState(() => notes.insert(0, t.text.trim())); save(); }
              Navigator.pop(d);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final shown = notes.where((n) => n.contains(q)).toList();
    return Frame('یادداشت‌ها', child: Stack(children: [
      ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 90), children: [
        TextField(onChanged: (v) => setState(() => q = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'جست‌وجو در یادداشت‌ها')),
        const SizedBox(height: 12),
        if (shown.isEmpty) const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('یادداشتی نیست. با دکمه‌ی + اولین یادداشت را بنویسید.'))),
        for (final n in shown)
          Glass(child: Row(children: [
            Expanded(child: Text(n)),
            IconButton(icon: const Icon(Icons.delete_outline, color: kRed), onPressed: () { setState(() => notes.remove(n)); save(); }),
          ])),
      ]),
      Positioned(bottom: 20, left: 20, child: FloatingActionButton(onPressed: add, child: const Icon(Icons.add))),
    ]));
  }
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});
  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    return Frame('هشدارهای هوشمند', child: ListView(padding: const EdgeInsets.all(16), children: [
      Glass(padding: EdgeInsets.zero, child: SwitchListTile(title: const Text('نمایش اعلان‌ها'), value: a.notifOn, onChanged: (v) => a.update(() => a.notifOn = v))),
      for (final k in a.alerts.keys)
        Glass(padding: EdgeInsets.zero, child: SwitchListTile(title: Text(k), value: a.alerts[k]!, onChanged: (v) => a.update(() => a.alerts[k] = v))),
    ]));
  }
}

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});
  @override
  State<SupportPage> createState() => _SupportState();
}

class _SupportState extends State<SupportPage> {
  String type = 'گزارش خرابی';
  final t = TextEditingController();
  final sent = <String>[];
  @override
  Widget build(BuildContext c) => Frame('پشتیبانی', child: ListView(padding: const EdgeInsets.all(16), children: [
        Glass(
          child: Column(children: [
            DropdownButtonFormField<String>(
              value: type,
              items: [for (final e in ['گزارش خرابی', 'قطعی برق', 'سؤال یا پیشنهاد']) DropdownMenuItem(value: e, child: Text(e))],
              onChanged: (v) => setState(() => type = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: t, maxLines: 4, decoration: const InputDecoration(labelText: 'توضیحات')),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                if (t.text.trim().isEmpty) return;
                setState(() => sent.insert(0, '$type: ${t.text.trim()}'));
                t.clear();
              },
              child: const Text('ثبت درخواست'),
            ),
          ]),
        ),
        for (final s in sent) Glass(child: Row(children: [const Icon(Icons.hourglass_top, color: kYellow), const SizedBox(width: 10), Expanded(child: Text('$s\n(ذخیره‌ی محلی؛ هنوز به سرور ارسال نمی‌شود)', style: Theme.of(c).textTheme.bodySmall))])),
        Glass(child: Row(children: [const Icon(Icons.power_off_outlined, color: kRed), const SizedBox(width: 10), Expanded(child: Text('اطلاعیه‌ی قطعی برق: منبع رسمی هنوز متصل نیست و اطلاعیه‌ای نمایش داده نمی‌شود.', style: Theme.of(c).textTheme.bodySmall))])),
      ]));
}

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});
  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    const colors = [kBlue, kRed, Color(0xFF16A34A), Color(0xFF7C3AED), Color(0xFFEA7A1E)];
    return Frame('شخصی‌سازی', child: ListView(padding: const EdgeInsets.all(16), children: [
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('تم', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [ButtonSegment(value: 'auto', label: Text('خودکار')), ButtonSegment(value: 'light', label: Text('روز')), ButtonSegment(value: 'dark', label: Text('شب'))],
            selected: {a.themePref},
            onSelectionChanged: (s) => a.update(() => a.themePref = s.first),
          ),
          const SizedBox(height: 16),
          const Text('رنگ اصلی', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 12, children: [
            for (final k in colors)
              GestureDetector(
                onTap: () => a.update(() => a.seed = k),
                child: CircleAvatar(backgroundColor: k, radius: 18, child: a.seed == k ? const Icon(Icons.check, color: Colors.white) : null),
              ),
          ]),
          const SizedBox(height: 16),
          Text('اندازه‌ی نوشته: ${fa(a.scale * 100)}٪', style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(value: a.scale, min: .85, max: 1.3, onChanged: (v) => a.update(() => a.scale = v)),
        ]),
      ),
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('پیش‌نمایش زنده', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [FilledButton(onPressed: () {}, child: const Text('دکمه')), const SizedBox(width: 8), Chip(label: const Text('برچسب')), const SizedBox(width: 8), const Icon(Icons.bolt, color: kYellow)]),
          const LinearProgressIndicator(value: .6),
        ]),
      ),
    ]));
  }
}

/// ===== پنل مدیر (نسخه‌ی محلی) =====
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminState();
}

class _AdminState extends State<AdminPage> {
  final ann = TextEditingController();
  @override
  Widget build(BuildContext c) {
    final a = Scope.of(c);
    final pending = a.bills.where((b) => b.status == 'در انتظار تأیید').toList();
    Widget stat(String t, String v, Color col) => Expanded(child: Glass(child: Column(children: [Text(fa(num.parse(v)), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: col)), Text(t, style: const TextStyle(fontSize: 11))])));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      Row(children: [const Expanded(child: Text('داشبورد مدیر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))), const SourceTag()]),
      const SizedBox(height: 8),
      Row(children: [stat('کاربران', '${a.users.length}', kBlue), const SizedBox(width: 8), stat('رسید در انتظار', '${pending.length}', kYellow), const SizedBox(width: 8), stat('قبض‌ها', '${a.bills.length}', kRed)]),
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('سهم مناطق از مصرف شهر (نمونه، ٪)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(height: 160, child: barChart([for (final d in districts) d.$2], [for (final d in districts) d.$1], kBlue)),
        ]),
      ),
      Glass(
        child: Column(children: [
          TextField(controller: ann, decoration: const InputDecoration(labelText: 'اطلاعیه‌ی جدید برای کاربران')),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              if (ann.text.trim().isEmpty) return;
              a.update(() => a.notifs.insert(0, 'اطلاعیه: ${ann.text.trim()}'));
              ann.clear();
              ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('اطلاعیه ثبت شد.')));
            },
            child: const Text('انتشار اطلاعیه'),
          ),
        ]),
      ),
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('بررسی رسیدها', style: TextStyle(fontWeight: FontWeight.bold)),
          if (pending.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('رسیدی در انتظار تأیید نیست.')),
          for (final b in pending)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(b.title),
              subtitle: Text('${fa(b.amount)} تومان'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.check_circle, color: kBlue), onPressed: () => a.update(() => b.status = 'پرداخت‌شده')),
                IconButton(icon: const Icon(Icons.cancel, color: kRed), onPressed: () => a.update(() { b.status = 'پرداخت‌نشده'; b.receipt = null; })),
              ]),
            ),
        ]),
      ),
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('کاربران ثبت‌شده', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final u in a.users.keys) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.person_outline), title: Text(u)),
          const Divider(),
          Text('مدیریت اشتراک‌ها، پرداخت‌ها، محتوای آموزشی، گزارش‌ها و سطح دسترسی کارشناسان پس از اتصال به بک‌اند فعال می‌شود.', style: Theme.of(c).textTheme.bodySmall),
        ]),
      ),
      OutlinedButton.icon(onPressed: () => a.update(() { a.signedIn = false; a.isAdmin = false; }), icon: const Icon(Icons.logout), label: const Text('خروج از پنل مدیر')),
    ]);
  }
}
