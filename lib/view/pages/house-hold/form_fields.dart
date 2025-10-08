import 'package:flutter/material.dart';

class FormFields {
  // Reusable dropdown widget
  static Widget buildDropdown({
    required BuildContext context,
    required String label,
    required List<Map<String, String>> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    String? hint,
    bool isFarmer = false,
    bool isRequired = false,
    String? errorText,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],

        Container(
          decoration: BoxDecoration(
            color: enabled
                ? (isDark ? Colors.grey[900] : Colors.grey[50])
                : (isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[200]),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null
                  ? Colors.red[400]!
                  : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
              width: errorText != null ? 1.5 : 1,
            ),
            boxShadow: [
              if (enabled && errorText == null)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              hint: Text(
                hint ?? 'Select an option',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              items: items.map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['code'],
                  enabled: enabled,
                  child: Text(
                    isFarmer && item['code'] != null
                        ? '${item['name']} (${item['code']})'
                        : item['name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 15,
                      color: enabled
                          ? (isDark ? Colors.white : Colors.grey[800])
                          : (isDark ? Colors.grey[500] : Colors.grey[500]),
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              menuMaxHeight: 300,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey[800],
                fontSize: 15,
              ),
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((Map<String, String> item) {
                  return Text(
                    isFarmer && item['code'] != null
                        ? '${item['name']} (${item['code']})'
                        : item['name'] ?? 'Unknown',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey[800],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                }).toList();
              },
            ),
          ),
        ),

        // Error text
        if (errorText != null && errorText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ] else
          const SizedBox(height: 4), // Keep consistent spacing
      ],
    );
  }

  // Reusable text field widget
  static Widget buildTextField({
    required BuildContext context,
    required String label,
    TextEditingController? controller,
    String? hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.black87,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
        ),
      ],
    );
  }

  // Reusable radio button group
  static Widget buildRadioGroup<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<MapEntry<T, String>> items,
    required ValueChanged<T?> onChanged,
    bool isRequired = false,
    bool wrap = false,
  }) {
    final List<Widget> radioItems = items.map<Widget>((item) {
      return _buildRadioItem<T>(
        context: context,
        value: item.key,
        groupValue: value,
        label: item.value,
        onChanged: onChanged,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.black87,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        wrap
            ? Wrap(
                spacing: 16,
                runSpacing: 8,
                children: radioItems,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: radioItems,
              ),
      ],
    );
  }

  static Widget _buildRadioItem<T>({
    required BuildContext context,
    required T value,
    required T? groupValue,
    required String label,
    required ValueChanged<T?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
