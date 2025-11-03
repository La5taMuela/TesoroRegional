import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'currency_service.dart';
import 'currency_input_formatter.dart';

class CurrencyTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final bool allowDecimals;
  final double? maxValue;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool autofocus;
  final InputDecoration? decoration;

  const CurrencyTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.allowDecimals = false,
    this.maxValue,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration ?? InputDecoration(
        labelText: labelText,
        hintText: hintText ?? 'Ej: 1.500.000',
        helperText: helperText,
        prefixIcon: prefixIcon,
        prefixText: '${CurrencyService.currencySymbol} ',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(
          allowDecimals: allowDecimals,
          maxValue: maxValue,
        ),
      ],
      validator: validator ?? _defaultValidator,
      onChanged: onChanged,
      autofocus: autofocus,
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un monto';
    }
    
    if (!CurrencyService.isValidAmount(value)) {
      return 'Ingresa un monto válido';
    }
    
    final amount = CurrencyService.parse(value);
    if (amount <= 0) {
      return 'El monto debe ser mayor a 0';
    }
    
    return null;
  }
}

class CurrencyText extends StatelessWidget {
  final double amount;
  final bool showSymbol;
  final TextStyle? style;
  final TextAlign? textAlign;

  const CurrencyText(
    this.amount, {
    super.key,
    this.showSymbol = true,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final text = showSymbol 
        ? CurrencyService.formatWithSymbol(amount)
        : CurrencyService.format(amount);
        
    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }
}

class CurrencyDisplay extends StatelessWidget {
  final double amount;
  final String? label;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showSymbol;

  const CurrencyDisplay({
    super.key,
    required this.amount,
    this.label,
    this.color,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.showSymbol = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: fontSize * 0.75,
              color: color?.withOpacity(0.7) ?? Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
        ],
        CurrencyText(
          amount,
          showSymbol: showSymbol,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
      ],
    );
  }
}
