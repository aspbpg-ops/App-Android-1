import 'package:asistente_app/features/asistente/presentation/barra_asistente.dart';
import 'package:asistente_app/features/calendario/presentation/calendario_tab.dart';
import 'package:asistente_app/features/inicio/presentation/hoy_tab.dart';
import 'package:asistente_app/features/inicio/presentation/mi_vida_tab.dart';
import 'package:flutter/material.dart';

/// Pantalla principal: Hoy, Mi vida y Calendario, con la barra del
/// asistente siempre a la mano.
class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  var _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _indice,
                children: const [HoyTab(), MiVidaTab(), CalendarioTab()],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: BarraAsistente(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) => setState(() => _indice = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Mi vida',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
        ],
      ),
    );
  }
}
