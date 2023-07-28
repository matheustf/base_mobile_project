import 'package:flutter/material.dart';
import 'package:clickquartos_mobile/app/core/ui/extensions/theme_extension.dart';

class CuidapetDefaultButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double borderRadius;
  final Color? color;
  final Color? labelColor;
  final double labelSize;
  final double padding;
  final double width;
  final double height;

  const CuidapetDefaultButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.borderRadius = 10,
    this.color,
    this.labelColor,
    this.padding = 10,
    this.labelSize = 20,
    this.width =
        double.infinity, //tamanho maximo da tela, o pai segura o tamanho maximo
    this.height = 66,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          primary: color ?? context.primaryColor,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: labelSize,
            color: labelColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
