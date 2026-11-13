import 'package:asistente_app/features/familiares/presentation/familiares_tab.dart';
import 'package:asistente_app/features/familiares/presentation/nuevo_familiar_page.dart';
import 'package:asistente_app/features/fichas/presentation/fichas_tab.dart';
import 'package:asistente_app/features/fichas/presentation/nueva_ficha_page.dart';
import 'package:asistente_app/features/inicio/presentation/hoy_tab.dart';
import 'package:asistente_app/features/perfil/presentation/perfil_tab.dart';
import 'package:asistente_app/features/recordatorios/presentation/nuevo_recordatorio_page.dart';
import 'package:flutter/material.dart';

/// Pantalla principal con las cuatro secciones de la app.
class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  var _indice = 0;

  static const _titulos = ['Hoy', 'Mis fichas', 'Familia', 'Mi perfil'];

  /// Botón de agregar de cada sección; el perfil no tiene.
  static const List<(String, Widget)?> _agregar = [
    ('Recordatorio', NuevoRecordatorioPage()),
    ('Ficha', NuevaFichaPage()),
    ('Familiar', NuevoFamiliarPage()),
    null,
  ];

  @override
  Widget build(BuildContext context) {
    final agregar = _agregar[_indice];
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indice])),
      body: SafeArea(
        child: IndexedStack(
          index: _indice,
          children: const [HoyTab(), FichasTab(), FamiliaresTab(), PerfilTab()],
        ),
      ),
      floatingActionButton: agregar == null
          ? null
          : FloatingActionButton.extended(
              key: const Key('boton-agregar'),
              icon: const Icon(Icons.add),
              label: Text(agregar.$1),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (context) => agregar.$2)),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) => setState(() => _indice = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Fichas',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Familia',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
