import 'package:flutter/material.dart';

/// "Enregistrer & Imprimer" — disabled until at least one line exists,
/// shows a spinner while the invoice is being finalized and printed.
class SaveAndPrintButton extends StatelessWidget {
  const SaveAndPrintButton({
    super.key,
    required this.enabled,
    required this.isSaving,
    required this.onPressed,
  });

  final bool enabled;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.print),
        label: Text(isSaving ? 'Impression…' : 'Enregistrer & Imprimer'),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
