import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/features/calendario/presentation/calendario_tab.dart';
import 'package:asistente_app/features/familiares/presentation/familiares_tab.dart';
import 'package:asistente_app/features/familiares/presentation/nuevo_familiar_page.dart';
import 'package:asistente_app/features/fichas/presentation/fichas_tab.dart';
import 'package:asistente_app/features/fichas/presentation/nueva_ficha_page.dart';
import 'package:asistente_app/features/inicio/presentation/hoy_tab.dart';
import 'package:asistente_app/features/notas/presentation/nota_page.dart';
import 'package:asistente_app/features/notas/presentation/notas_tab.dart';
import 'package:asistente_app/features/perfil/presentation/perfil_page.dart';
import 'package:asistente_app/features/recordatorios/presentation/nuevo_recordatorio_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Una sección de la barra inferior y su botón de agregar.
typedef _Seccion = ({
  String titulo,
  IconData icono,
  IconData iconoElegido,
  String agregar,
  Widget Function() nueva,
});

/// Pantalla principal con las secciones de la app.
class InicioPage extends ConsumerStatefulWidget {
  const InicioPage({super.key});

  @override
  ConsumerState<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends ConsumerState<InicioPage> {
  var _indice = 0;

  static final List<_Seccion> _secciones = [
    (
      titulo: 'Hoy',
      icono: Icons.today_outlined,
      iconoElegido: Icons.today,
      agregar: 'Recordatorio',
      nueva: NuevoRecordatorioPage.new,
    ),
    (
      titulo: 'Calendario',
      icono: Icons.calendar_month_outlined,
      iconoElegido: Icons.calendar_month,
      agregar: 'Recordatorio',
      nueva: NuevoRecordatorioPage.new,
    ),
    (
      titulo: 'Notas',
      icono: Icons.sticky_note_2_outlined,
      iconoElegido: Icons.sticky_note_2,
      agregar: 'Nota',
      nueva: NotaPage.new,
    ),
    (
      titulo: 'Fichas',
      icono: Icons.folder_outlined,
      iconoElegido: Icons.folder,
      agregar: 'Ficha',
      nueva: NuevaFichaPage.new,
    ),
    (
      titulo: 'Familia',
      icono: Icons.people_outline,
      iconoElegido: Icons.people,
      agregar: 'Familiar',
      nueva: NuevoFamiliarPage.new,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final seccion = _secciones[_indice];
    final avatar = ref.watch(datosProvider.select((d) => d.perfil?.avatar));
    return Scaffold(
      appBar: AppBar(
        title: Text(seccion.titulo),
        actions: [
          IconButton(
            key: const Key('boton-perfil'),
            tooltip: 'Mi perfil',
            icon: Text(avatar ?? '🙂', style: const TextStyle(fontSize: 24)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) => const PerfilPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _indice,
          children: const [
            HoyTab(),
            CalendarioTab(),
            NotasTab(),
            FichasTab(),
            FamiliaresTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('boton-agregar'),
        icon: const Icon(Icons.add),
        label: Text(seccion.agregar),
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (context) => seccion.nueva())),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) => setState(() => _indice = indice),
        destinations: [
          for (final s in _secciones)
            NavigationDestination(
              icon: Icon(s.icono),
              selectedIcon: Icon(s.iconoElegido),
              label: s.titulo,
            ),
        ],
      ),
    );
  }
}
