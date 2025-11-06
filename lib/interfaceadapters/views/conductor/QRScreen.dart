/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart' as qr;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class QrScannerTab extends StatefulWidget {
  @override
  _QrScannerTabState createState() => _QrScannerTabState();
}

class _QrScannerTabState extends State<QrScannerTab> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  qr.QRViewController? controller;
  String? qrText;
  bool isSelecting = false;
  File? _image; 
  final BarcodeScanner barcodeScanner = BarcodeScanner(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner QR de trámites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _selectPdfFromGallery,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: qr.QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (qrText != null)
                  ? const Text('Código QR')
                  : const Text('Escanea un código QR'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(qr.QRViewController controller) {
    this.controller = controller;

    bool navigated = false;

    controller.scannedDataStream.listen((scanData) {
      if (!navigated) {
        setState(() {
          qrText = scanData.code;
        });

        if (qrText != null && qrText!.isNotEmpty) {
          navigated = true;
        print("funca");
        }
      }
    });
  }

  Future<void> _selectPdfFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) { 
      setState(() {
        _image = File(pickedFile.path);
      });

      await _processImage(); 
    }

  }

  Future<void> _processImage() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFilePath(_image!.path);
    final barcodes = await barcodeScanner.processImage(inputImage); 

    for (Barcode barcode in barcodes) {
      print('Found barcode: ${barcode.rawValue}');
      if(barcode.rawValue != null){
       print("funciona");
      }
    }
  }


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}*/