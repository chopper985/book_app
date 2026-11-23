// Package imports:
import 'package:material_ui/material_ui.dart';

class PlaceHolder extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxShape shape;
  const PlaceHolder({
    super.key,
    this.height,
    this.width,
    this.shape = BoxShape.rectangle,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
    );
  }
}
