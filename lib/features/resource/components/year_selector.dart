// lib/features/resource/components/year_selector.dart
import 'package:flutter/material.dart';

class YearSelector extends StatefulWidget {
  final Function(int) onYearSelected;

  const YearSelector({
    Key? key,
    required this.onYearSelected,
  }) : super(key: key);

  @override
  _YearSelectorState createState() => _YearSelectorState();
}

class _YearSelectorState extends State<YearSelector> {
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    return Container(
      height: 40, // 减小垂直占用高度
      color: Colors.grey[200], // 浅灰色背景
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: currentYear - 2002 + 1,
        itemBuilder: (context, index) {
          final year = currentYear - index;
          final isSelected = _selectedYear == year;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedYear = year;
              });
              widget.onYearSelected(year);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '$year',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
