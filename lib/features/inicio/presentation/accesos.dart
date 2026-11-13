import 'package:asistente_app/core/widgets/seccion_page.dart';
import 'package:asistente_app/features/familiares/presentation/familiares_tab.dart';
import 'package:asistente_app/features/familiares/presentation/nuevo_familiar_page.dart';
import 'package:asistente_app/features/fichas/presentation/fichas_tab.dart';
import 'package:asistente_app/features/fichas/presentation/nueva_ficha_page.dart';
import 'package:asistente_app/features/notas/presentation/nota_page.dart';
import 'package:asistente_app/features/notas/presentation/notas_tab.dart';
import 'package:asistente_app/features/perfil/presentation/perfil_page.dart';
import 'package:flutter/material.dart';

/// Los cuatro espacios personales que aparecen en Hoy y en Mi vida.
enum Acceso {
  familia('Familia', Icons.people_outline),
  fichas('Mis fichas', Icons.folder_open_outlined),
  notas('Notas', Icons.sticky_note_2_outlined),
  perfil('Mi perfil', Icons.person_outline);

  const Acceso(this.titulo, this.icono);

  final String titulo;
  final IconData icono;

  Widget pagina() => switch (this) {
    Acceso.familia => const SeccionPage(
      titulo: 'Familia',
      cuerpo: FamiliaresTab(),
      agregar: 'Familiar',
      nueva: NuevoFamiliarPage.new,
    ),
    Acceso.fichas => const SeccionPage(
      titulo: 'Mis fichas',
      cuerpo: FichasTab(),
      agregar: 'Ficha',
      nueva: NuevaFichaPage.new,
    ),
    Acceso.notas => const SeccionPage(
      titulo: 'Notas',
      cuerpo: NotasTab(),
      agregar: 'Nota',
      nueva: NotaPage.new,
    ),
    Acceso.perfil => const PerfilPage(),
  };

  void abrir(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (context) => pagina()));
}
