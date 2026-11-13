import 'package:asistente_app/app/theme.dart';
import 'package:asistente_app/core/widgets/seccion_page.dart';
import 'package:asistente_app/features/familiares/presentation/familiares_tab.dart';
import 'package:asistente_app/features/familiares/presentation/nuevo_familiar_page.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:asistente_app/features/fichas/presentation/fichas_tab.dart';
import 'package:asistente_app/features/fichas/presentation/nueva_ficha_page.dart';
import 'package:asistente_app/features/notas/presentation/nota_page.dart';
import 'package:asistente_app/features/notas/presentation/notas_tab.dart';
import 'package:asistente_app/features/perfil/presentation/perfil_page.dart';
import 'package:flutter/material.dart';

/// Los espacios personales. Los cuatro primeros aparecen también en Hoy.
enum Acceso {
  familia('Familia', imagen: 'familia'),
  auto('Mi auto', imagen: 'auto', tipos: {TipoFicha.auto}),
  mascotas('Mascotas', imagen: 'mascotas', tipos: {TipoFicha.mascota}),
  casa('Mi casa', imagen: 'casa', tipos: {TipoFicha.casa, TipoFicha.renta}),
  notas('Notas', icono: Icons.sticky_note_2_outlined),
  perfil('Mi perfil', icono: Icons.person_outline);

  const Acceso(this.titulo, {this.imagen, this.icono, this.tipos});

  final String titulo;

  /// Ícono dibujado (en `assets/iconos`), o [icono] de Material.
  final String? imagen;
  final IconData? icono;

  /// Tipos de ficha que muestra la sección, si es de fichas.
  final Set<TipoFicha>? tipos;

  static const List<Acceso> enHoy = [familia, auto, mascotas, casa];

  Widget pagina() {
    final tipos = this.tipos;
    if (tipos != null) {
      return SeccionPage(
        titulo: titulo,
        cuerpo: FichasTab(tipos: tipos),
        agregar: 'Agregar',
        nueva: () => NuevaFichaPage(
          tipoInicial: tipos.length == 1 ? tipos.single : null,
        ),
      );
    }
    return switch (this) {
      Acceso.familia => const SeccionPage(
        titulo: 'Familia',
        cuerpo: FamiliaresTab(),
        agregar: 'Familiar',
        nueva: NuevoFamiliarPage.new,
      ),
      Acceso.notas => const SeccionPage(
        titulo: 'Notas',
        cuerpo: NotasTab(),
        agregar: 'Nota',
        nueva: NotaPage.new,
      ),
      _ => const PerfilPage(),
    };
  }

  void abrir(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (context) => pagina()));
}

/// Dibuja el ícono de un acceso con el color del tema.
class IconoAcceso extends StatelessWidget {
  const IconoAcceso(this.acceso, {this.tamano = 28, super.key});

  final Acceso acceso;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final color = Paleta.de(context).acento;
    final imagen = acceso.imagen;
    if (imagen == null) return Icon(acceso.icono, color: color, size: tamano);
    return Image.asset(
      'assets/iconos/$imagen.png',
      width: tamano,
      height: tamano,
      color: color,
    );
  }
}
