
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';
import 'package:image_size_getter/image_size_getter.dart';

class EditScreen extends StatefulWidget {
  String image;

  EditScreen({required this.image, Key? key}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  ImageProvider? provider;
  bool horizon = true;
  bool vertic = false;
  int angle = 1;
  int angleConstant = 90;
  @override
  void initState() {
     provider = AssetImage(widget.image);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple usage'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_backup_restore),
            onPressed: restore,
            tooltip: 'Restore image to default.',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (provider != null)
            AspectRatio(
              aspectRatio: 1,
              child: Image(
                image: provider!,
              ),
            ),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          child: const Text('Flip Horizontal'),
                           onPressed: () {
                             _flipHorizon(FlipOption(horizontal: horizon, vertical: vertic));
                           },
                        ),

                        ElevatedButton(
                          child: const Text('Flip Vertical'),
                          onPressed: () {
                            _flipVert(FlipOption(horizontal: vertic, vertical: horizon));
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          child: const Text('Rotate R 90'),
                          onPressed: () {
                            _rotate( RotateOption(angleConstant * angle!));
                            setState((){
                              angle = angle + 1;
                              if((angleConstant * angle) > 360) angle = 1;
                            });
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Rotate L 90'),
                          onPressed: () {
                            _rotate( RotateOption(360 - (angleConstant * angle!)));
                            setState((){
                              angle = angle + 1;
                              if((angleConstant * angle) > 360) angle = 1;
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void setProvider(ImageProvider? provider) {
    this.provider = provider;
    setState(() {});
  }

  void restore() {
    setProvider(AssetImage(widget.image));
  }

  Future<Uint8List> getAssetImage() async {
    final ByteData byteData = await rootBundle.load(widget.image!);
    return byteData.buffer.asUint8List();
  }

  Future<void> _flipHorizon(FlipOption flipOption) async {
    handleOption(<Option>[flipOption]);
    setState((){
      horizon = !horizon;
    });
  }

  Future<void> _flipVert(FlipOption flipOption) async {
    handleOption(<Option>[flipOption]);
    setState((){
      horizon = !horizon;
    });
 }

  Future<void> _clip(ClipOption clipOpt) async {
    handleOption(<Option>[clipOpt]);
  }

  Future<void> _rotate(RotateOption rotateOpt) async {
    handleOption(<Option>[rotateOpt]);
  }

  void _scale(Option value) {
    handleOption(<Option>[value]);
  }

  Future<void> handleOption(List<Option> options) async {
    final ImageEditorOption option = ImageEditorOption();
    for (int i = 0; i < options.length; i++) {
      final Option o = options[i];
      option.addOption(o);
    }

    option.outputFormat = const OutputFormat.png();

    final Uint8List assetImage = await getAssetImage();

    final srcSize = ImageSizeGetter.getSize(MemoryInput(assetImage));

    print(const JsonEncoder.withIndent('  ').convert(option.toJson()));
    final Uint8List? result = await ImageEditor.editImage(
      image: assetImage,
      imageEditorOption: option,
    );

    if (result == null) {
      setProvider(null);
      return;
    }

    final resultSize = ImageSizeGetter.getSize(MemoryInput(result));

    print('srcSize: $srcSize, resultSize: $resultSize');

    final MemoryImage img = MemoryImage(result);
    setProvider(img);
  }


}
