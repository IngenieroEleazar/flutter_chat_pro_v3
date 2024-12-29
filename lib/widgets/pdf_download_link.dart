import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Widget para mostrar un enlace clickeable
class PDFDownloadLink extends StatelessWidget {
  final String pdfUrl;

  const PDFDownloadLink({Key? key, required this.pdfUrl}) : super(key: key);

  // Método para abrir el enlace cuando se hace clic
  Future<void> _launchURL() async {
    final Uri url = Uri.parse(pdfUrl);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());  // Abre el enlace
    } else {
      throw 'No se pudo abrir el enlace: $pdfUrl';  // Error si no se puede abrir
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL,  // Abre el enlace al hacer clic
      child: Text(
        'Haga clic para descargar el PDF',  // Texto del enlace
        style: TextStyle(
          color: Colors.blue,  // Color del enlace
          decoration: TextDecoration.underline,  // Subraya el enlace
        ),
      ),
    );
  }
}
