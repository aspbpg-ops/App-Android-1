import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/widgets/confirmar.dart';
import 'package:asistente_app/features/notas/domain/nota.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Crear o editar una nota. Sin [nota] es una nueva.
class NotaPage extends ConsumerStatefulWidget {
  const NotaPage({
    this.nota,
    this.textoInicial = '',
    this.categoriaInicial,
    super.key,
  });

  final Nota? nota;

  /// Texto ya dictado o escrito en otro lado.
  final String textoInicial;
  final String? categoriaInicial;

  @override
  ConsumerState<NotaPage> createState() => _NotaPageState();
}

class _NotaPageState extends ConsumerState<NotaPage> {
  late final _texto = TextEditingController(
    text: widget.nota?.texto ?? widget.textoInicial,
  );
  late String _categoria =
      widget.nota?.categoria ?? widget.categoriaInicial ?? categoriasBase.first;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _nuevaCategoria() async {
    final control = TextEditingController();
    final nombre = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva categoría'),
        content: TextField(
          controller: control,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Ej. Gimnasio'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, control.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    control.dispose();
    if (nombre != null && nombre.isNotEmpty) {
      setState(() => _categoria = nombre);
    }
  }

  void _guardar() {
    final controller = ref.read(datosProvider.notifier);
    final nota = widget.nota;
    if (nota == null) {
      controller.agregarNota(texto: _texto.text, categoria: _categoria);
    } else {
      controller.editarNota(
        nota.copyWith(texto: _texto.text.trim(), categoria: _categoria),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = {...ref.watch(datosProvider).categorias, _categoria};
    final nota = widget.nota;
    return Scaffold(
      appBar: AppBar(
        title: Text(nota == null ? 'Nueva nota' : 'Nota'),
        actions: [
          if (nota != null)
            IconButton(
              tooltip: 'Borrar nota',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final borrar = await confirmarBorrado(
                  context,
                  titulo: '¿Borrar la nota?',
                  detalle: 'No se puede deshacer.',
                );
                if (!borrar || !context.mounted) return;
                ref.read(datosProvider.notifier).borrarNota(nota.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('campo-nota'),
              controller: _texto,
              autofocus: nota == null,
              minLines: 4,
              maxLines: 12,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: '¿Qué quieres apuntar?',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text('Categoría', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categorias)
                  ChoiceChip(
                    key: Key('categoria-$c'),
                    label: Text(c),
                    selected: c == _categoria,
                    onSelected: (_) => setState(() => _categoria = c),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Otra'),
                  onPressed: _nuevaCategoria,
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              key: const Key('boton-guardar-nota'),
              onPressed: _texto.text.trim().isEmpty ? null : _guardar,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
