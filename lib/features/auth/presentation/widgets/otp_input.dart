import 'package:daftar_tech/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'error_text.dart';

/// مدخل رمز التأكيد المكوّن من أكثر من خانة.
///
/// يدعم:
/// - الانتقال التلقائي للخانة التالية بعد إدخال الرقم.
/// - الرجوع للخانة السابقة مع المسح.
/// - لصق الرمز كاملاً دفعة واحدة.
/// - الكتابة فوق خانة ممتلئة بدون الحاجة لمسحها يدوياً.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.length = 4,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.onCompleted,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final int length;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  int? _focusedIndex;
  final RegExp _nonDigits = RegExp(r'\D');

  @override
  void initState() {
    super.initState();
    for (final node in widget.focusNodes) {
      node.addListener(_onFocusChanged);
    }
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNodes != widget.focusNodes) {
      for (final node in oldWidget.focusNodes) {
        node.removeListener(_onFocusChanged);
      }
      for (final node in widget.focusNodes) {
        node.addListener(_onFocusChanged);
      }
    }
  }

  @override
  void dispose() {
    for (final node in widget.focusNodes) {
      node.removeListener(_onFocusChanged);
    }
    super.dispose();
  }

  void _onFocusChanged() {
    final index = widget.focusNodes.indexWhere((node) => node.hasFocus);
    final next = index < 0 ? null : index;
    if (next != _focusedIndex) {
      setState(() => _focusedIndex = next);
    }
  }

  String get _code => widget.controllers.map((c) => c.text).join();

  void _notify() {
    final code = _code;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _requestFocus(int index) {
    final target = index.clamp(0, widget.length - 1);
    widget.focusNodes[target].requestFocus();
  }

  /// تحديد محتوى الخانة بالكامل حتى يتم استبداله عند الكتابة.
  void _selectAll(int index) {
    final controller = widget.controllers[index];
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  void _handleChanged(String value, int index) {
    final digits = value.replaceAll(_nonDigits, '');

    // 1. المستخدم مسح محتوى الخانة → الرجوع للخانة السابقة
    if (digits.isEmpty) {
      if (index > 0) _requestFocus(index - 1);
      _notify();
      return;
    }

    // 2. لصق الرمز كاملاً (أو أطول من خانة واحدة)
    if (digits.length > 1) {
      if (digits.length >= widget.length) {
        for (int i = 0; i < widget.length; i++) {
          widget.controllers[i].text = digits.substring(i, i + 1);
        }
        _requestFocus(widget.length - 1);
      } else {
        // كتابة فوق خانة ممتلئة → نحتفظ بالرقم الجديد فقط
        widget.controllers[index].text = digits.substring(digits.length - 1);
        if (index < widget.length - 1) _requestFocus(index + 1);
      }
      _notify();
      return;
    }

    // 3. إدخال رقم واحد
    widget.controllers[index].text = digits;
    if (index < widget.length - 1) _requestFocus(index + 1);
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.controllers.length >= widget.length &&
          widget.focusNodes.length >= widget.length,
      'عدد المتحكمات وعقد التركيز لازم يكون >= عدد خانات الرمز',
    );

    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = (constraints.maxWidth - (widget.length - 1) * 12) /
                widget.length;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                widget.length,
                (index) => _buildBox(index, boxWidth, hasError),
              ),
            );
          },
        ),
        if (hasError) ErrorText(message: widget.errorText!),
      ],
    );
  }

  Widget _buildBox(int index, double width, bool hasError) {
    final isFocused = _focusedIndex == index;

    return Container(
      width: width,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.otpFieldFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasError
              ? AppColors.moneyOut
              : (isFocused ? AppColors.primary : Colors.transparent),
          width: hasError || isFocused ? 1.5 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: widget.controllers[index],
        focusNode: widget.focusNodes[index],
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textInputAction:
            index == widget.length - 1 ? TextInputAction.done : TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => _handleChanged(value, index),
        onTap: () => _selectAll(index),
        onSubmitted: (_) {
          if (index == widget.length - 1) {
            FocusScope.of(context).unfocus();
          }
        },
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryDark,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
