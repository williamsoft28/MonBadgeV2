import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../services/offline_service.dart';
import '../models/cours_model.dart';
import 'presence_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? rawValue = barcode.rawValue;

    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Le QR Code doit contenir un JSON : {"coursId": 123, "nom": "Algorithmique"}
      final Map<String, dynamic> data = jsonDecode(rawValue);
      
      if (!data.containsKey('coursId')) {
        throw Exception("Code invalide");
      }

      final int coursId = data['coursId'];

      // On vérifie si on trouve le cours dans la base locale (Offline)
      final db = OfflineService.getDB();
      final entities = await db.getAllCours();
      
      CoursModel? foundCours;
      for (var e in entities) {
        if (e.id == coursId) {
          foundCours = CoursModel(
            id: e.id,
            nom: e.nom,
            enseignantId: e.enseignantId,
            salle: e.salle,
            latitude: e.latitude,
            longitude: e.longitude,
            rayonMetres: e.rayonMetres,
            heureDebut: e.heureDebut,
            heureFin: e.heureFin,
            dateCours: e.dateCours,
            estArchive: e.estArchive,
            enseignantNom: e.enseignantNom,
            enseignantPrenom: e.enseignantPrenom,
            filiere: e.filiere,
            niveau: e.niveau,
          );
          break;
        }
      }

      if (foundCours == null) {
        if (mounted) {
          Helpers.showError(context, "Le cours n'a pas été trouvé dans votre cache local. Synchronisez d'abord.");
        }
      } else {
        if (mounted) {
          // On ferme le scanner
          Navigator.pop(context);
          // On redirige vers l'écran de présence en activant le mode QR Offline
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PresenceScreen(
                cours: foundCours!,
                isOfflineQR: true,
              ),
            ),
          );
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        Helpers.showError(context, "QR Code non reconnu ou mal formaté.");
      }
    }

    // Réactiver le scanner après un délai en cas d'erreur
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scanner le QR Code',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _processBarcode,
          ),
          // Interface par-dessus (Viseur)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accentGreen, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  "Placez le QR Code de l'enseignant\nau centre du cadre.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                if (_isProcessing)
                  const CircularProgressIndicator(color: AppTheme.accentGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
