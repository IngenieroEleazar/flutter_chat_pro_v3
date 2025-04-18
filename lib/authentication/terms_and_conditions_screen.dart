import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Términos y Condiciones"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TÉRMINOS Y CONDICIONES",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '''
1. OBJETO
La presente establece los términos y condiciones bajo los cuales la empresa B&V Moldea tu Futuro (en adelante, "la Empresa") presta servicios de enseñanza a domicilio y virtual a través de docentes calificados.

2. SERVICIO DE CLASES A DOMICILIO
Los docentes designados por la Empresa se trasladarán al domicilio del cliente para la realización de las clases según los horarios previamente coordinados con la Empresa.

3. PROHIBICIÓN DE CONTACTO DIRECTO ENTRE CLIENTE Y DOCENTE
El cliente no podrá solicitar directamente a los docentes la programación, reprogramación o cancelación de clases. Toda comunicación referida a la organización de las clases deberá realizarse únicamente a través del gerente de la Empresa.

Asimismo, está terminantemente prohibido que el cliente solicite o reciba el número de teléfono u otros datos de contacto del docente. Cualquier intento de comunicación directa fuera de los canales oficiales podrá dar lugar a la suspensión o cancelación del servicio.

En caso de que el cliente proporcione su número al docente o viceversa de manera encubierta y ocurra algún tipo de incidente delicado, la Empresa no se hará responsable de las consecuencias derivadas de dicha acción.

4. RESPONSABILIDAD Y COMPROMISOS
- La Empresa garantiza que los docentes cumplen con los requisitos académicos y profesionales necesarios para la enseñanza.
- Los clientes deben proporcionar un ambiente adecuado para la realización de las clases.
- En caso de cancelación de una clase, el cliente debe notificar con al menos 24 horas de anticipación a la Empresa.
- El incumplimiento de cualquiera de estas condiciones podrá derivar en la suspensión del servicio.

5. MODIFICACIONES A LOS TÉRMINOS Y CONDICIONES
La Empresa se reserva el derecho de modificar los presentes términos y condiciones en cualquier momento. Las modificaciones serán notificadas a los clientes con anticipación razonable.

6. ACEPTACIÓN DE LOS TÉRMINOS
El uso del servicio implica la aceptación plena y sin reservas de los presentes términos y condiciones por parte del cliente.

7. CONTACTO
Para cualquier consulta o coordinación relacionada con el servicio, el cliente deberá comunicarse directamente con la Empresa a través de los canales oficiales establecidos.

Lima, 05 de marzo de 2025
B&V Moldea tu Futuro
              ''',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Volver"),
            ),
          ],
        ),
      ),
    );
  }
}