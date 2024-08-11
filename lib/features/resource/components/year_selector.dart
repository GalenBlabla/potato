import 'package:flutter/material.dart';

class YearSelector extends StatefulWidget {
  final Function(int) onYearSelected; // 接受一个整数值，0 表示“全部”

  const YearSelector({
    Key? key,
    required this.onYearSelected,
  }) : super(key: key);

  @override
  _YearSelectorState createState() => _YearSelectorState();
}

class _YearSelectorState extends State<YearSelector> {
  int _selectedYear = 0; // 默认为 0 表示“全部”

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = [
      0,
      ...List.generate(currentYear - 2002 + 1, (index) => currentYear - index)
    ];

    return Container(
      height: 40, // 减小垂直占用高度
      color: Colors.grey[200], // 浅灰色背景
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final yearText = year == 0 ? '全部' : year.toString();
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
                yearText,
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
