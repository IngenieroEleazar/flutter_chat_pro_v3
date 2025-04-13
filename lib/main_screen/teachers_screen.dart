import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Docentes'),
        centerTitle: true, // Esta es la línea clave que centra el título
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('docentes')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar docentes',
                          style: GoogleFonts.roboto(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay docentes registrados',
                          style: GoogleFonts.roboto(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.dividerColor,
                      ),
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data()! as Map<String, dynamic>;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            backgroundImage: data['foto'] != null
                                ? NetworkImage(data['foto'])
                                : null,
                            child: data['foto'] == null
                                ? Icon(
                              Icons.person_outline,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                                : null,
                          ),
                          title: Text(
                            data['nombre'] ?? 'Nombre no disponible',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            data['especialidad'] ?? 'Especialidad no disponible',
                            style: GoogleFonts.roboto(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles'),
        centerTitle: true, // También centrado aquí para consistencia
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    docenteData['nombre'] ?? 'Nombre no disponible',
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    docenteData['especialidad'] ?? 'Especialidad no disponible',
                    style: GoogleFonts.roboto(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Información académica',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                docenteData['grado_academico'] ?? 'No disponible',
                style: GoogleFonts.roboto(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Horario',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _buildHorarioMinimalista(context, docenteData['horario'] ?? {}),
            const SizedBox(height: 24),
            Text(
              'Descripción',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                docenteData['descripcion'] ?? 'Sin descripción',
                style: GoogleFonts.roboto(
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioMinimalista(BuildContext context, Map<String, dynamic> horario) {
    final theme = Theme.of(context);
    final dias = ['lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom'];
    final nombresDias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: dias.map((dia) {
          final disponible = horario[dia] ?? false;
          return Column(
            children: [
              Text(
                nombresDias[dias.indexOf(dia)],
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: disponible
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
                child: Icon(
                  disponible ? Icons.check : Icons.close,
                  size: 14,
                  color: disponible ? Colors.green : Colors.red,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}