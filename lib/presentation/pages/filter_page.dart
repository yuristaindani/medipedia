import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String section = 'Jenis Obat';
  final selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final choices = section == 'Jenis Obat'
        ? const ['Obat Bebas', 'Obat Resep']
        : const ['Tablet', 'Capsule', 'Cream'];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pilih Preferensi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.black))],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 154,
            child: Column(children: [
              _sectionButton('Jenis Obat'),
              _sectionButton('Bentuk Sediaan'),
            ]),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(7, 9, 7, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(section, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: choices.map((choice) => FilterChip(
                  label: Text(choice),
                  selected: selected.contains(choice),
                  onSelected: (value) => setState(() => value ? selected.add(choice) : selected.remove(choice)),
                  showCheckmark: false,
                  backgroundColor: const Color(0xFFE4E4E4),
                  selectedColor: AppColors.softBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  labelStyle: const TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.w500),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                )).toList()),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionButton(String title) => InkWell(
    onTap: () => setState(() => section = title),
    child: Container(
      height: 72,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: section == title ? const Color(0xFFF5F5F5) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFD5D5D5))),
      ),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ),
  );
}
