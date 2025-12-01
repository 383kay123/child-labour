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
                : (isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors
                .grey[200]),
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
              items: items.map<DropdownMenuItem<String>>((
                  Map<String, String> item) {
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

  // Reusable radio button group with clear functionality
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
      return _buildClearableRadioItem<T>(
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

// Custom clearable radio item
  static Widget _buildClearableRadioItem<T>({
    required BuildContext context,
    required T value,
    required T? groupValue,
    required String label,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isSelected = groupValue == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? Colors.green.withOpacity(0.2)
            : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey.shade400,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Toggle: if already selected, clear; otherwise select
            if (isSelected) {
              onChanged(null);
            } else {
              onChanged(value);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Custom radio indicator
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? Colors.green : Colors.white,
                  ),
                  child: isSelected
                      ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                      : null,
                ),

                // Label
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? Colors.green.shade800
                          : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight
                          .normal,
                    ),
                  ),
                ),

                // Clear button when selected
                if (isSelected)
                  InkWell(
                    onTap: () => onChanged(null),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.clear,
                        size: 14,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable text field widget with local controller and listener
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
    bool enableInteractiveSelection = true,
    bool showError = false,
    String? initialValue,
    FocusNode? focusNode,
  }) {
    return _TextFieldWithController(
      label: label,
      controller: controller,
      hintText: hintText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      isRequired: isRequired,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      enableInteractiveSelection: enableInteractiveSelection,
      showError: showError,
initialValue: initialValue,
      focusNode: focusNode,
    );
  }
}

class _TextFieldWithController extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final bool enableInteractiveSelection;
  final bool showError;
  final String? initialValue;
  final FocusNode? focusNode;

  const _TextFieldWithController({
    required this.label,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.isRequired = false,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.enableInteractiveSelection = true,
    this.showError = false,
    this.initialValue,
    this.focusNode,
  });

  @override
  _TextFieldWithControllerState createState() => _TextFieldWithControllerState();
}

class _TextFieldWithControllerState extends State<_TextFieldWithController> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(_TextFieldWithController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleControllerChanged);
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_handleControllerChanged);
    }
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  void _handleControllerChanged() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    // Only dispose the controller if it was created locally
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              children: [
                if (widget.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          textDirection: TextDirection.ltr,
          cursorColor: isDark ? Colors.white : Colors.black87,
          cursorWidth: 2.0,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errorText != null || widget.showError
                    ? Colors.red
                    : (isDark ? Colors.grey[700]! : Colors.grey.shade400),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errorText != null || widget.showError
                    ? Colors.red
                    : (isDark ? Colors.grey[700]! : Colors.grey.shade400),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errorText != null || widget.showError
                    ? Colors.red
                    : theme.primaryColor,
                width: 2,
              ),
            ),
            errorText: _errorText,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            if (widget.validator != null) {
              setState(() {
                _errorText = widget.validator!(value);
              });
            }
            widget.onChanged?.call(value);
          },
        ),
      ],
    );
  }
}