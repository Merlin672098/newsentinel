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


// lib/interfaceadapters/views/conductor/qr_scanner_tab.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:newsentinel/constants/global_variables.dart';

class QrScannerTab extends StatefulWidget {
  const QrScannerTab({Key? key}) : super(key: key);

  @override
  _QrScannerTabState createState() => _QrScannerTabState();
}

class _QrScannerTabState extends State<QrScannerTab> {
  String? qrText;
  bool isProcessingImage = false;

  final ImagePicker _picker = ImagePicker();
  final mlkit.BarcodeScanner _barcodeScanner = mlkit.BarcodeScanner();

  final ms.MobileScannerController cameraController =
      ms.MobileScannerController(
    detectionSpeed: ms.DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _barcodeScanner.close();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.secondaryColor,
      appBar: AppBar(
        title: const Text('Escanear dispositivo (QR)'),
        backgroundColor: GlobalVariables.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Seleccionar imagen',
            onPressed: _selectImageFromGallery,
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Linterna',
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                ms.MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final barcode = capture.barcodes.first;
                    final String? code = barcode.rawValue;

                    if (code != null && code.isNotEmpty && mounted) {
                      setState(() => qrText = code);

                      cameraController.stop();

                      // ⭐⭐⭐ BACKEND DEBE HACER ESTO ⭐⭐⭐
                      // 1. VALIDAR QUE EL QR EXISTE EN LA BASE DE DATOS.
                      // 2. VERIFICAR QUE EL DISPOSITIVO ASOCIADO AL QR ESTÁ ACTIVO.
                      // 3. VALIDAR QUE EL CONDUCTOR TIENE PERMISOS PARA USAR ESTE DISPOSITIVO.
                      // 4. RESPONDER SI EL QR ES VÁLIDO, INVÁLIDO O EXPIRADO.
                      // 5. RETORNAR LOS DATOS DEL DISPOSITIVO (ID, placa, modelo, estado, etc.).
                      //
                      // DESPUÉS DE LA VALIDACIÓN, EL FRONT RECIBE EL CÓDIGO:
                      Navigator.of(context).pop(code);
                    }
                  },
                ),

                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Apunta al QR del dispositivo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Center(
              child: isProcessingImage
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          qrText != null
                              ? 'Leído: $qrText'
                              : 'O escoge una imagen con QR',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalVariables.primaryColor,
                            foregroundColor: GlobalVariables.secondaryColor,
                          ),
                          onPressed: qrText != null
                              ? () {
                                  // ⭐⭐⭐ BACKEND DEBE HACER EXACTAMENTE LO MISMO QUE ARRIBA ⭐⭐⭐
                                  //
                                  // AL PRESIONAR ESTE BOTÓN, SE VUELVE A ENVIAR EL QR AL BACKEND PARA VALIDAR:
                                  // 1. QUE EL QR ES REAL Y COINCIDE CON UN DISPOSITIVO REGISTRADO.
                                  // 2. QUE NO ESTÁ REPORTADO COMO DAÑADO O INACTIVO.
                                  // 3. QUE ESTE CONDUCTOR TIENE ACCESO A ESTE DISPOSITIVO.
                                  //
                                  // SI ESTÁ BIEN: RETORNAR OBJETO DEL DISPOSITIVO.
                                  // SI ESTÁ MAL: RETORNAR ERROR Y EL FRONT LO MOSTRARÁ.
                                  Navigator.of(context).pop(qrText);
                                }
                              : null,
                          child: const Text('Usar este código'),
                        )
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Procesar imagen con ML Kit (leer QR desde foto)
  ///
  /// ⭐⭐⭐ BACKEND DEBE HACER EXACTAMENTE LA MISMA VALIDACIÓN QUE EN EL ESCANEO EN VIVO ⭐⭐⭐
  ///
  Future<void> _selectImageFromGallery() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      isProcessingImage = true;
      qrText = null;
    });

    try {
      final inputImage = mlkit.InputImage.fromFilePath(picked.path);
      final List<mlkit.Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
        final code = barcodes.first.rawValue!;
        setState(() => qrText = code);

        // ⭐⭐⭐ BACKEND DEBE VALIDAR EL QR IGUAL QUE EN ESCANEO EN VIVO ⭐⭐⭐
        Navigator.of(context).pop(code);
      } else {
        setState(() => qrText = 'No se detectó QR en la imagen');
      }
    } catch (e) {
      setState(() => qrText = 'Error al procesar imagen: $e');
    } finally {
      setState(() => isProcessingImage = false);
    }
  }
}
