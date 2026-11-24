import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const kBlue = Color(0xFF2463EB);
const kRed = Color(0xFFE5484D);
const kYellow = Color(0xFFF5C84C);
const kSilver = Color(0xFFF2F4F7);

const jMonths = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'];

/// تبدیل تاریخ میلادی به شمسی → [سال، ماه، روز]
List<int> toJalali(DateTime d) {
  const g = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  final gy2 = d.month > 2 ? d.year + 1 : d.year;
  var days = 355666 + (365 * d.year) + ((gy2 + 3) ~/ 4) - ((gy2 + 99) ~/ 100) + ((gy2 + 399) ~/ 400) + d.day + g[d.month - 1];
  var jy = -1595 + (33 * (days ~/ 12053));
  days %= 12053;
  jy += 4 * (days ~/ 1461);
  days %= 1461;
  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }
  final jm = days < 186 ? 1 + days ~/ 31 : 7 + (days - 186) ~/ 30;
  final jd = 1 + (days < 186 ? days % 31 : (days - 186) % 30);
  return [jy, jm, jd];
}

void push(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

class Bg extends StatelessWidget {
  final Widget child;
  const Bg({super.key, required this.child});
  @override
  Widget build(BuildContext c) => AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark(c)
                ? const [Color(0xFF0A1020), Color(0xFF12214A), Color(0xFF0A1020)]
                : const [Color(0xFFFFFFFF), Color(0xFFE8EEFB), kSilver],
          ),
        ),
        child: child,
      );
}

class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? tint;
  const Glass({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.tint});
  @override
  Widget build(BuildContext c) {
    final d = isDark(c);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: padding,
            decoration: BoxDecoration(
              color: tint ?? (d ? Colors.white.withOpacity(.07) : Colors.white),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: d ? Colors.white.withOpacity(.1) : const Color(0xFFE4E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(d ? .25 : .06), blurRadius: 18, offset: const Offset(0, 6))],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// صفحه‌ی داخلی با پس‌زمینه و نوار عنوان
class Frame extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  const Frame(this.title, {super.key, required this.child, this.actions});
  @override
  Widget build(BuildContext c) => Bg(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: Text(title), actions: actions),
          body: child,
        ),
      );
}

/// برچسب شفافیت داده: منبع، تاریخ، اعتبار
class SourceTag extends StatelessWidget {
  const SourceTag({super.key});
  @override
  Widget build(BuildContext c) => ActionChip(
        avatar: const Icon(Icons.science_outlined, size: 16, color: kRed),
        label: const Text('داده‌ی آزمایشی', style: TextStyle(fontSize: 11)),
        side: const BorderSide(color: kRed),
        onPressed: () => showDialog(
          context: c,
          builder: (_) => AlertDialog(
            title: const Text('منبع و اعتبار داده'),
            content: const Text('منبع: داده‌ی نمونه‌ی داخلی برنامه\nاعتبار: غیررسمی و نمایشی\n\nاین ارقام مصرف واقعی کاشان یا کنتور شما نیستند. پس از اتصال به API رسمی، منبع و تاریخ هر داده اینجا نمایش داده می‌شود.'),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('متوجه شدم'))],
          ),
        ),
      );
}

const _noTitles = AxisTitles(sideTitles: SideTitles(showTitles: false));

FlTitlesData _titles(List<String> l) => FlTitlesData(
      topTitles: _noTitles,
      rightTitles: _noTitles,
      leftTitles: _noTitles,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 26,
          getTitlesWidget: (x, m) {
            final i = x.toInt();
            if (i < 0 || i >= l.length) return const SizedBox();
            return Padding(padding: const EdgeInsets.only(top: 6), child: Text(l[i], style: const TextStyle(fontSize: 10)));
          },
        ),
      ),
    );

final _grid = FlGridData(
  drawVerticalLine: false,
  getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withOpacity(.18), strokeWidth: 1),
);

Widget lineChart(List<double> v, List<String> l, Color col) => LineChart(
      LineChartData(
        gridData: _grid,
        borderData: FlBorderData(show: false),
        titlesData: _titles(l),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < v.length; i++) FlSpot(i.toDouble(), v[i])],
            isCurved: true,
            barWidth: 3,
            color: col,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: col.withOpacity(.12)),
          ),
        ],
      ),
    );

Widget barChart(List<double> v, List<String> l, Color col) => BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: _grid,
        borderData: FlBorderData(show: false),
        titlesData: _titles(l),
        barGroups: [
          for (var i = 0; i < v.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: v[i],
                width: v.length > 8 ? 10 : 16,
                color: i == v.length - 1 ? kYellow : col,
                borderRadius: BorderRadius.circular(5),
              ),
            ]),
        ],
      ),
    );
