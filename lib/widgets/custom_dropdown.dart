import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'section_title.dart'; // Import the SectionTitle widget

class CustomDropdown<T> extends StatelessWidget {
  final String title;
  final T value;
  final List<T> items;
  final void Function(T?) onChanged;

  const CustomDropdown({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title), // Use the SectionTitle widget
        Container(
          decoration: BoxDecoration(
            color: AppColors.textLight, // White background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.border),
            dropdownColor: AppColors.textLight,
            style: const TextStyle(color: AppColors.textDark, fontSize: 14),
            items:
                items.map((T itemValue) {
                  return DropdownMenuItem<T>(
                    value: itemValue,
                    child: Text(
                      itemValue.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
