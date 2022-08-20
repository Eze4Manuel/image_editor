
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';


class RotateWidget extends StatefulWidget {
  const RotateWidget({
    Key? key,
    this.onTap,
  }) : super(key: key);

  final ValueChanged<RotateOption>? onTap;

  @override
  _RotateWidgetState createState() => _RotateWidgetState();
}

class _RotateWidgetState extends State<RotateWidget> {
  int angle = 0;

  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.white,
      child: Column(
          children: <Widget>[
            Slider(
              onChanged: (double v) => setState(() => angle = v.toInt()),
              value: angle.toDouble(),
              min: 0,
              max: 180,
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _rotate,
                child: const Text('rotate'),
              ),
            ),
          ],
        ),
    );
  }

  void _rotate() {
    final RotateOption opt = RotateOption(angle);
    widget.onTap?.call(opt);
  }
}