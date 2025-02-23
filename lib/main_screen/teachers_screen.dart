import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:http/http.dart' as http;

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Docentes',
          style: GoogleFonts.openSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('docentes')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Ocurrió un error al cargar los docentes'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No se encontraron docentes',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data()! as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherDetailScreen(
                                    docenteData: data,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: data['foto'] != null ? NetworkImage(data['foto']) : null,
                                    radius: 28,
                                    backgroundColor: Colors.grey[200],
                                    child: data['foto'] == null
                                        ? const Icon(
                                      Icons.person_outline,
                                      color: Colors.grey,
                                      size: 28,
                                    )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['nombre'] ?? 'Nombre no disponible',
                                          style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          data['especialidad'] ?? 'Especialidad no disponible',
                                          style: GoogleFonts.openSans(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Mostrar link del horario_excel
                                        data['horario_excel'] != null
                                            ? GestureDetector(
                                          onTap: () async {
                                            final url = Uri.parse(data['horario_excel']);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            } else {
                                              throw 'No se pudo abrir el enlace $url';
                                            }
                                          },
                                          child: Text(
                                            'Horario: Ver Excel',
                                            style: GoogleFonts.openSans(
                                              fontSize: 14,
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherDetailScreen extends StatelessWidget {
  final Map<String, dynamic> docenteData;

  const TeacherDetailScreen({super.key, required this.docenteData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del Docente',
          style: GoogleFonts.openSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera minimalista
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 45,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    docenteData['nombre'] ?? 'Nombre no disponible',
                    style: GoogleFonts.openSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    docenteData['especialidad'] ?? 'Especialidad no disponible',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Mostrar link del horario_excel
                  docenteData['horario_excel'] != null
                      ? GestureDetector(
                    onTap: () async {
                      final url = Uri.parse(docenteData['horario_excel']);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'No se pudo abrir el enlace $url';
                      }
                    },
                    child: Text(
                      'Horario: Ver Excel',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),

            // Espacio para el resto del contenido
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta de Grado Académico
                      _buildInfoCard(
                        title: 'Grado Académico',
                        content: docenteData['grado_academico'] ?? 'No disponible',
                      ),
                      const SizedBox(height: 16),

                      // Previsualización del contenido del Excel
                      Text(
                        'Previsualización del Horario:',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      docenteData['horario_excel'] != null
                          ? FutureBuilder<Widget>(
                        future: _buildExcelPreview(docenteData['horario_excel']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error al cargar el archivo Excel: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return snapshot.data!;
                          } else {
                            return const Text('No se pudo cargar la previsualización');
                          }
                        },
                      )
                          : const Text('No disponible'),

                      const SizedBox(height: 16),

                      // Bloque de descripción
                      Text(
                        'Descripción:',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          docenteData['descripcion'] ?? 'Sin descripción',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botón de contacto eliminado
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir tarjetas de información clave
  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir la previsualización del contenido del Excel
  Future<Widget> _buildExcelPreview(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final excel = excel_lib.Excel.decodeBytes(bytes);
        final sheet = excel.tables.keys.first;
        final table = excel.tables[sheet]!;
        final rows = table.rows.take(5).toList(); // Tomar las primeras 5 filas como previsualización

        if (rows.isEmpty) {
          throw 'El archivo Excel está vacío';
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: rows.first.map((cell) => DataColumn(label: Text(cell?.value.toString() ?? ''))).toList(),
            rows: rows.skip(1).map((row) {
              return DataRow(
                cells: row.map((cell) => DataCell(Text(cell?.value.toString() ?? ''))).toList(),
              );
            }).toList(),
          ),
        );
      } else {
        throw 'No se pudo cargar el archivo Excel';
      }
    } catch (e) {
      throw 'Error al cargar el archivo Excel: $e';
    }
  }
}