import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_editor/image_editor.dart';
import 'package:image_size_getter/image_size_getter.dart';

import 'edit_screen.dart';

const whitecolor = Colors.white;
const blackcolor = Colors.black;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final urlImages = [
    'assets/images/a.jpg',
    'assets/images/b.jpg',
    'assets/images/c.jpg',
    'assets/images/d.jpg',
  ];
  var transformedImages = [];

  Future<dynamic> getSizeOfImages() async {
    transformedImages = [];
    for (int i = 0; i < urlImages.length; i++) {
      final imageObject = {};

      await rootBundle.load(urlImages[i]).then((value) => {
            imageObject['path'] = urlImages[i],
            imageObject['size'] = value.lengthInBytes,
          });
      transformedImages.add(imageObject);
    }
  }

  Future<dynamic> sortImagesByIncreseSize() async {
    transformedImages.sort((a, b) => a['size'].compareTo(b['size']));
  }

  Future<dynamic> sortImagesByDecreseSize() async {
    transformedImages.sort((b, a) => a['size'].compareTo(b['size']));
  }
  Future<dynamic> sortImagesByNamesIncrease() async {
    transformedImages.sort((a, b) => a['path'].compareTo(b['path']));
  }
  Future<dynamic> sortImagesByNamesDecrease() async {
    transformedImages.sort((b, a) => a['path'].compareTo(b['path']));
  }

  @override
  void initState() {
    getSizeOfImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whitecolor,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: blackcolor),
        ),
        iconTheme: const IconThemeData(color: blackcolor),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Filter By"),
                    // content: const Text("This is my message."),
                    actions: [
                      TextButton(
                        child: Column(
                          children: const [
                            Text('Size +'),

                            Icon(Icons.text_increase),
                          ],
                        ),
                        onPressed: () {
                          sortImagesByIncreseSize()
                              .then((value) => setState(() {}));
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Column(
                          children: const [
                            Text('Size -'),
                            Icon(Icons.text_decrease),
                          ],
                        ),
                        onPressed: () {
                          sortImagesByDecreseSize()
                              .then((value) => setState(() {}));
                          Navigator.pop(context);
                        },
                      ),

                      TextButton(
                        child: Column(
                          children: const [
                            Text('Name +'),
                            Icon(Icons.text_increase, color: Colors.red),
                          ],
                        ),
                        onPressed: () {
                          sortImagesByNamesIncrease()
                              .then((value) => setState(() {}));
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Column(
                          children: const [
                            Text('Name -'),

                            Icon(Icons.text_decrease, color: Colors.redAccent),
                          ],
                        ),
                        onPressed: () {
                          sortImagesByNamesDecrease()
                              .then((value) => setState(() {}));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.more_vert),
            ),
          )
        ],
      ),
      // Body area
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: const BoxDecoration(
                    color: whitecolor,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      return RawMaterialButton(
                        child: InkWell(
                          child: Ink.image(
                            image: AssetImage(transformedImages[index]['path']),
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GalleryWidget(
                                        urlImages: urlImages,
                                        index: index,
                                      )));
                        },
                      );
                    },
                    itemCount: transformedImages.length,
                  )))
        ],
      )),
    );
  }
}





class GalleryWidget extends StatefulWidget {
  final PageController pageController;
  final List<String> urlImages;
  final int index;

  // ignore: use_key_in_widget_constructors
  GalleryWidget({
    required this.urlImages,
    this.index = 0,
  }) : pageController = PageController(initialPage: index);

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  int bottomIndex = 0;
  String? selectedImage = '';
  ImageProvider? provider = AssetImage('');
  var urlImage;

  @override
  void initState() {
    provider =  AssetImage(widget.urlImages[widget.index]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: PhotoViewGallery.builder(
              pageController: widget.pageController,
              itemCount: widget.urlImages.length,
              builder: (context, index) {
                urlImage = widget.urlImages[index];

                return PhotoViewGalleryPageOptions(
                  imageProvider: AssetImage(urlImage),
                );
              },

            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (e){
          setState((){
            bottomIndex = e;
            if(e == 0) Navigator.pop(context);
            // if(e == 1) _flip(FlipOption(horizontal: true, vertical: false));
            if(e == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditScreen(image: urlImage )));
            }

          });
        },
        currentIndex: bottomIndex,
        backgroundColor: Colors.white,
        iconSize: 30,
        selectedItemColor: Colors.black,
        unselectedIconTheme: const IconThemeData(color: Colors.black38,),
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.close), label: 'Exit'),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Edit',
          ),
        ],
      ),
    );
  }





showScaleModal(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200,
        color: Colors.amber,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Text('Scale Image'),

            ],
          ),
        ),
      );
    },
  );
}

showRotateModal(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200,
        color: Colors.amber,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Text('Rotate'),
            ],
          ),
        ),
      );
    },
  );
}


}