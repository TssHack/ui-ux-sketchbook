import 'package:flutter/material.dart';
import 'package:sketchbook/sketchbook.dart';

void main() => runApp(const CafeApp());

/// Breakpoints shared with the web builds.
const double kTablet = 600, kDesktop = 900;

class CafeApp extends StatelessWidget {
  const CafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caffee House',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: SketchColors.paper,
        colorScheme: ColorScheme.fromSeed(seedColor: SketchColors.caramel, surface: SketchColors.paper),
      ),
      // Persian content, right to left. Hand-lettered Latin stays LTR inside HandText.
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomePage(),
    );
  }
}

class Dish {
  const Dish(this.art, this.name, this.price);
  final String art, name;
  final int price;
}

const specials = [
  Dish('croissant', 'کروسان شکلاتی', 145000),
  Dish('cheesecake', 'چیزکیک لوتوس', 175000),
  Dish('burger', 'همبرگر مخصوص', 285000),
  Dish('pasta', 'پاستا آلفردو', 265000),
  Dish('hotchoc', 'هات‌چاکلت لوتوس', 125000),
];

String toman(int n) {
  const fa = '۰۱۲۳۴۵۶۷۸۹';
  final digits = n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '٬');
  return '${digits.split('').map((c) => int.tryParse(c) != null ? fa[int.parse(c)] : c).join()} تومان';
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _cart = 0;

  void _add(Dish d) {
    setState(() => _cart++);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${d.name} به سبد اضافه شد'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const _MenuSheet(),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _Header(wide: w >= kDesktop, cart: _cart)),
            SliverToBoxAdapter(child: _Hero(width: w)),
            SliverToBoxAdapter(child: _Categories(width: w)),
            SliverToBoxAdapter(child: _Specials(onAdd: _add, width: w)),
            const SliverToBoxAdapter(child: _Footer()),
          ]);
        },
      ),
    );
  }
}

/// Centred content column with the 16px side gutter.
class _Section extends StatelessWidget {
  const _Section({required this.child, this.vertical = 24});
  final Widget child;
  final double vertical;
  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: vertical), child: child),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.wide, required this.cart});
  final bool wide;
  final int cart;

  @override
  Widget build(BuildContext context) {
    const hand = TextStyle(fontSize: 22, color: SketchColors.ink);
    final badge = SketchBox(
      radius: 999,
      seed: 7,
      tint: SketchColors.band,
      edgeReach: const Offset(0.5, 0.5),
      background: SketchColors.paper2,
      child: SizedBox.square(
        dimension: wide ? 110 : 56,
        child: Center(child: HandText('Caffee House', seed: 3, style: TextStyle(fontSize: wide ? 22 : 11))),
      ),
    );
    final links = ['contact', 'coffee', 'food', 'About us', 'menu'];
    return SketchBox(
      edges: const {SketchEdge.bottom},
      tint: SketchColors.band,
      edgeReach: const Offset(0.5, 0.5),
      tintStrength: 0.7,
      background: Color.lerp(SketchColors.band, SketchColors.paper, 0.18),
      child: _Section(
        vertical: 8,
        child: Directionality(
          textDirection: TextDirection.ltr, // nav order as drawn in the sketch
          child: Row(children: [
            if (wide) ...[
              for (final l in links.take(3)) Expanded(child: Center(child: HandText(l, seed: l.length, style: hand))),
              badge,
              for (final l in links.skip(3)) Expanded(child: Center(child: HandText(l, seed: l.length, style: hand))),
            ] else ...[
              badge,
              const Spacer(),
            ],
            _IconButton(icon: Icons.shopping_cart_outlined, label: 'سبد خرید، $cart قلم', badge: cart, onTap: () {}),
            if (!wide) ...[
              const SizedBox(width: 8),
              Builder(
                builder: (context) => _IconButton(
                  icon: Icons.menu,
                  label: 'باز کردن منو',
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.label, required this.onTap, this.badge = 0});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(clipBehavior: Clip.none, children: [
            SketchBox(
              radius: 14,
              seed: icon.codePoint,
              background: SketchColors.paper2,
              child: SizedBox.square(dimension: 46, child: Icon(icon, color: SketchColors.ink)),
            ),
            if (badge > 0)
              Positioned(
                top: -6,
                left: -6,
                child: CircleAvatar(radius: 11, backgroundColor: SketchColors.ink, child: Text('$badge', style: const TextStyle(fontSize: 11, color: SketchColors.paper))),
              ),
          ]),
        ),
      );
}

class _MenuSheet extends StatelessWidget {
  const _MenuSheet();
  @override
  Widget build(BuildContext context) => Drawer(
        backgroundColor: SketchColors.paper,
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
            for (final (fa, en) in [('منو', 'menu'), ('درباره ما', 'About us'), ('غذا', 'food'), ('قهوه', 'coffee'), ('تماس', 'contact')])
              ListTile(
                title: Text(fa, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: HandText(en, style: const TextStyle(fontSize: 20, color: SketchColors.inkSoft)),
                onTap: () => Navigator.pop(context),
              ),
          ]),
        ),
      );
}

class _Hero extends StatefulWidget {
  const _Hero({required this.width});
  final double width;
  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  int _scene = 0;
  static const scenes = [
    ['iced', 'latte', 'choco'],
    ['cake', 'croissant', 'steam'],
    ['cupcake', 'cheesecake', 'iced'],
  ];

  @override
  Widget build(BuildContext context) {
    final wide = widget.width >= kDesktop;
    final copy = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        HandText('Delicious Coffee', seed: 3, style: TextStyle(fontSize: wide ? 58 : 40, color: SketchColors.ink)),
        const SizedBox(height: 6),
        const Text('قهوه‌ی تازه، کیک خانگی، حال خوب', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text(
          'یک کافه‌ی کوچک با دانه‌های تازه‌برشته و کروسانی که هر صبح از فر بیرون می‌آید. همین صفحه با پکیج فلاتر اسکیل ui-ux-sketchbook ساخته شده است.',
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: const TextStyle(color: SketchColors.inkSoft, height: 1.8),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _SketchButton(label: 'سفارش آنلاین', primary: true, onTap: () {}),
          _SketchButton(label: 'رزرو میز', onTap: () {}),
        ]),
      ],
    );
    final scene = scenes[_scene];
    final stage = Column(children: [
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(flex: 10, child: SketchDrawing.named(scene[0], key: ValueKey('a$_scene'), drawIn: true)),
          const SizedBox(width: 8),
          Expanded(flex: 23, child: SketchDrawing.named(scene[1], key: ValueKey('b$_scene'), drawIn: true)),
          const SizedBox(width: 8),
          Expanded(flex: 10, child: Transform.rotate(angle: 0.1, child: SketchDrawing.named(scene[2], key: ValueKey('c$_scene'), drawIn: true))),
        ]),
      ),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < scenes.length; i++)
          Semantics(
            button: true,
            selected: i == _scene,
            label: 'تصویر ${i + 1}',
            child: GestureDetector(
              onTap: () => setState(() => _scene = i),
              child: Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SketchColors.ink, width: 2),
                  color: i == _scene ? SketchColors.ink : null,
                ),
              ),
            ),
          ),
      ]),
    ]);

    return SketchBox(
      edges: const {SketchEdge.bottom},
      tint: SketchColors.sage,
      edgeReach: const Offset(0.22, 0.3),
      tintStrength: 1,
      background: SketchColors.sageWash,
      seed: 9,
      child: _Section(
        vertical: wide ? 56 : 28,
        child: wide
            ? Row(children: [Expanded(flex: 95, child: copy), const SizedBox(width: 36), Expanded(flex: 120, child: stage)])
            : Column(children: [copy, const SizedBox(height: 20), ConstrainedBox(constraints: const BoxConstraints(maxWidth: 540), child: stage)]),
      ),
    );
  }
}

class _SketchButton extends StatelessWidget {
  const _SketchButton({required this.label, required this.onTap, this.primary = false});
  final String label;
  final VoidCallback onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: SketchBox(
            radius: 14,
            seed: label.length,
            tint: primary ? SketchColors.caramelDark : null,
            edgeReach: const Offset(0.5, 0.5),
            tintStrength: 1,
            background: primary ? SketchColors.caramel.withValues(alpha: 0.7) : SketchColors.paper2,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      );
}

class _Categories extends StatelessWidget {
  const _Categories({required this.width});
  final double width;
  @override
  Widget build(BuildContext context) {
    final cats = [('fries', 'Food', 'غذا'), ('cupcake', 'Cake', 'کیک و دسر'), ('steam', 'Special', 'ویژه')];
    final narrow = width < kTablet;
    return _Section(
      child: Directionality(
        textDirection: TextDirection.ltr, // Food · Cake · Special, as drawn
        child: Row(children: [
          for (final (i, (art, en, fa)) in cats.indexed) ...[
            if (i > 0) SizedBox(width: narrow ? 10 : 24),
            Expanded(
              child: SketchBox(
                tint: SketchColors.caramel,
                seed: 21 + i * 13,
                background: SketchColors.paper2,
                padding: EdgeInsets.all(narrow ? 10 : 16),
                child: Column(children: [
                  SizedBox(height: narrow ? 58 : 110, child: SketchDrawing.named(art)),
                  HandText(en, seed: 5 + i * 3, style: TextStyle(fontSize: narrow ? 20 : 32)),
                  Text(fa, style: const TextStyle(fontSize: 12, color: SketchColors.inkSoft)),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Specials extends StatelessWidget {
  const _Specials({required this.onAdd, required this.width});
  final void Function(Dish) onAdd;
  final double width;
  @override
  Widget build(BuildContext context) {
    final cardW = width < kTablet ? (width * 0.72).clamp(200.0, 240.0) : 240.0;
    return _Section(
      child: SketchBox(
        tint: SketchColors.sage,
        edgeReach: const Offset(0.04, 0.2),
        tintStrength: 0.7,
        radius: 12,
        seed: 61,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(children: [
            const HandText('Special menu', seed: 17, style: TextStyle(fontSize: 36)),
            const Text('پیشنهادهای این هفته', style: TextStyle(fontWeight: FontWeight.w700, color: SketchColors.inkSoft)),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: specials.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final d = specials[i];
                  return SizedBox(
                    width: cardW,
                    child: SketchBox(
                      tint: const Color(0xFFC7C25E),
                      seed: 100 + i * 3,
                      background: const Color(0xFFF7F1DC),
                      padding: const EdgeInsets.all(12),
                      child: Column(children: [
                        Expanded(child: SketchDrawing.named(d.art, label: d.name)),
                        Text(d.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(toman(d.price), style: const TextStyle(color: SketchColors.inkSoft)),
                        const SizedBox(height: 8),
                        _SketchButton(label: '+ افزودن', primary: true, onTap: () => onAdd(d)),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) => SketchBox(
        edges: const {SketchEdge.top},
        tint: SketchColors.band,
        edgeReach: const Offset(0.5, 0.4),
        tintStrength: 0.75,
        background: Color.lerp(SketchColors.band, SketchColors.paper, 0.5),
        child: const _Section(
          child: Column(children: [
            HandText('Caffee House', seed: 41, style: TextStyle(fontSize: 30)),
            SizedBox(height: 6),
            Text('ساخته‌شده با پکیج فلاتر ui-ux-sketchbook', style: TextStyle(color: SketchColors.inkSoft)),
          ]),
        ),
      );
}
