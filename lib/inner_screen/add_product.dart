import 'dart:io';
import 'package:admin_panel_grocery_app/screens/loading_manager.dart';
import 'package:admin_panel_grocery_app/services/utils.dart';
import 'package:admin_panel_grocery_app/widgets/buttons.dart';
import 'package:admin_panel_grocery_app/widgets/header.dart';
import 'package:admin_panel_grocery_app/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../controllers/MenuController.dart';
import '../services/global_method.dart';

class UploadProductForm extends StatefulWidget {
  static const routeName = '/UploadProductForm';

  const UploadProductForm({Key? key}) : super(key: key);

  @override
  State<UploadProductForm> createState() => _UploadProductFormState();
}

class _UploadProductFormState extends State<UploadProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _catValue = 'Vegetable';
  int _groupValue = 1;
  bool isPiece = false;
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);

  late final TextEditingController _titleController, _priceController;

  @override
  void initState() {
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  void _uploadForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    String? imageUrl;
    if (isValid) {
      _formKey.currentState!.save();
      if (_pickedImage == null) {
        GlobalMethods.errorDialog(
            subtitle: 'Please pick up an image', context: context);
        return;
      }
      final _uuid = const Uuid().v4();
      try {
        setState(() {
          _isLoading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child('userImages')
            .child('$_uuid.jpg');
        if (kIsWeb) {
          await ref.putData(webImage);
        } else {
          await ref.putFile(_pickedImage!);
        }
        imageUrl = await ref.getDownloadURL();
        // fb.StorageReference storageRef =
        //     fb.storage().ref().child('productsImages').child(_uuid + 'jpg');
        // final fb.UploadTaskSnapshot uploadTaskSnapshot =
        //     await storageRef.put(kIsWeb ? webImage : _pickedImage).future;
        // Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('products').doc(_uuid).set({
          'id': _uuid,
          'title': _titleController.text,
          'price': _priceController.text,
          'salePrice': 0.1,
          'imageUrl': imageUrl.toString(),
          'productCategoryName': _catValue,
          'isOnSale': false,
          'isPiece': isPiece,
          'createdAt': Timestamp.now(),
        });
        _clearForm();
        Fluttertoast.showToast(
          msg: "Product uploaded successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          // backgroundColor: ,
          // textColor: ,
          // fontSize: 16.0
        );
      } on FirebaseException catch (error) {
        GlobalMethods.errorDialog(
            subtitle: '${error.message}', context: context);
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        GlobalMethods.errorDialog(subtitle: '$error', context: context);
        setState(() {
          _isLoading = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    isPiece = false;
    _groupValue = 1;
    _priceController.clear();
    _titleController.clear();
    setState(() {
      _pickedImage = null;
      webImage = Uint8List(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Utils(context).color;
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final size = Utils(context).getScreenSize;
    var inputDecoration = InputDecoration(
      filled: true,
      fillColor: _scaffoldColor,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1.0),
      ),
    );

    return Scaffold(
      // key: context.read<MenuController>().getAddProductscaffoldKey,
      // drawer: SideMenu(),
      body: LoadingManager(
        isLoading: _isLoading,
        child:  SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Header(
                              fct: () {
                                context
                                    .read<MenuController>()
                                    .controlAddProductsMenu();
                              },
                              title: 'Add product',
                              showTexField: false),
                        ),
                        Container(
                          width: size.width > 650 ? 650 : size.width,
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.all(16.00),
                          margin: EdgeInsets.all(16.00),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextWidget(
                                  text: "Product Title",
                                  color: color,
                                  isTitle: true,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _titleController,
                                  key: ValueKey('Title'),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter Title";
                                    }
                                    return null;
                                  },
                                  decoration: inputDecoration,
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: FittedBox(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextWidget(
                                              text: "Price in \$",
                                              color: color,
                                              isTitle: true,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: 100,
                                              height: 50,
                                              child: TextFormField(
                                                controller: _priceController,
                                                key: ValueKey('Price \$'),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please is missed';
                                                  }
                                                  return null;
                                                },
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9.]'))
                                                ],
                                                decoration: inputDecoration,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextWidget(
                                              text: "Chose product Category",
                                              color: color,
                                              isTitle: true,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),

                                            ///drop dwon is here
                                            _categoryDropDown(),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextWidget(
                                              text: "Measure Unit",
                                              color: color,
                                              isTitle: true,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),

                                            /// radio button is here
                                            Row(
                                              children: [
                                                TextWidget(
                                                    text: "Kg",
                                                    color: color,
                                                    isTitle: true),
                                                Radio(
                                                  value: 1,
                                                  groupValue: _groupValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _groupValue = 1;
                                                      isPiece = false;
                                                    });
                                                  },
                                                  activeColor: Colors.green,
                                                ),
                                                TextWidget(
                                                    text: "Piece",
                                                    color: color,
                                                    isTitle: true),
                                                Radio(
                                                  value: 2,
                                                  groupValue: _groupValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _groupValue = 2;
                                                      isPiece = true;
                                                    });
                                                  },
                                                  activeColor: Colors.green,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),

                                    ///Upload Image Code is here
                                    Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                              height: size.width > 650
                                                  ? 350
                                                  : size.width * .45,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: _pickedImage == null
                                                  ? _dottedBorder(color: color)
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: kIsWeb
                                                          ? Image.memory(
                                                              webImage,
                                                              fit: BoxFit.fill,
                                                            )
                                                          : Image.file(
                                                              _pickedImage!,
                                                              fit: BoxFit.fill,
                                                            ),
                                                    )),
                                        )),
                                    Expanded(
                                      flex: 1,
                                      child: FittedBox(
                                        child: Column(
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _pickedImage = null;
                                                  webImage = Uint8List(8);
                                                });
                                              },
                                              child: TextWidget(
                                                  text: "Clear",
                                                  color: Colors.red),
                                            ),
                                            TextButton(
                                                onPressed: () {},
                                                child: Text(
                                                  'Update Image',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ))
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(18.00),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ButtonsWidget(
                                          onPressed: _clearForm,
                                          text: "Clear Form",
                                          icon: IconlyLight.dangerTriangle,
                                          backgroundColor: Colors.red.shade300),
                                      ButtonsWidget(
                                          onPressed: () {
                                            _uploadForm();
                                          },
                                          text: "Upload",
                                          icon: IconlyLight.upload,
                                          backgroundColor: Colors.blue),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))


    );
  }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        print("No image has been picked");
      }
    } else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          _pickedImage = File("a");
        });
      } else {
        print("No image has been picked");
      }
    } else {
      print("Something gone wrong");
    }
  }

  Widget _dottedBorder({required Color color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
          dashPattern: [6, 7],
          borderType: BorderType.RRect,
          radius: Radius.circular(12),
          color: color,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  IconlyLight.image2,
                  color: color,
                  size: 50,
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: () {
                      _pickImage();
                    },
                    child:
                        TextWidget(text: "Chose an image", color: Colors.blue))
              ],
            ),
          )),
    );
  }

  Widget _categoryDropDown() {
    final color = Utils(context).color;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          style: GoogleFonts.rubik(
            color: color,

            fontSize: 16,
          ),
          value: _catValue,
          onChanged: (value) {
            setState(() {
              _catValue = value!;
            });
            print(_catValue);
          },
          hint: Text('Select a category'),
          items: [
            DropdownMenuItem(
              child: Text(
                'Vegetables',
              ),
              value: 'Vegetable',
            ),
            DropdownMenuItem(
              child: Text(
                'Fruits',
              ),
              value: 'Fruit',
            ),
            DropdownMenuItem(
              child: Text(
                'Grains',
              ),
              value: 'Grain',
            ),
            DropdownMenuItem(
              child: Text(
                'Nuts',
              ),
              value: 'Nut',
            ),
            DropdownMenuItem(
              child: Text(
                'Herbs',
              ),
              value: 'Herb',
            ),
            DropdownMenuItem(
              child: Text(
                'Spices',
              ),
              value: 'Spice',
            )
          ],
        )),
      ),
    );
  }
}
