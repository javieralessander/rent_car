import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? description;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconColor;
  final Color confirmButtonColor;
  final bool isDangerous;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.description,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.icon = Icons.help_outline,
    this.iconColor = AppColors.warning,
    this.confirmButtonColor = AppColors.primary,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        width: isMobile ? screenSize.width * 0.9 : 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Mensaje principal
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Descripción adicional (opcional)
            if (description != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grayLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: AppColors.grayLight),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Botón Confirmar
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDangerous ? AppColors.danger : confirmButtonColor,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Factory para crear un diálogo de eliminación con diseño predefinido
  static ConfirmationDialog delete({
    required String title,
    required String itemName,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String? additionalInfo,
  }) {
    return ConfirmationDialog(
      title: title,
      message: '¿Estás seguro de que deseas eliminar "$itemName"?',
      description: additionalInfo ?? 'Esta acción no se puede deshacer.',
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      icon: Icons.delete_outline,
      iconColor: AppColors.danger,
      isDangerous: true,
    );
  }

  /// Factory para crear un diálogo de confirmación genérico
  static ConfirmationDialog confirm({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String? description,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    IconData icon = Icons.help_outline,
    Color iconColor = AppColors.warning,
    bool isDangerous = false,
  }) {
    return ConfirmationDialog(
      title: title,
      message: message,
      description: description,
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      iconColor: iconColor,
      isDangerous: isDangerous,
    );
  }

  /// Función helper para mostrar el diálogo de eliminación
  static Future<void> showDeleteDialog({
    required BuildContext context,
    required String title,
    required String itemName,
    required VoidCallback onConfirm,
    String? additionalInfo,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog.delete(
        title: title,
        itemName: itemName,
        onConfirm: onConfirm,
        additionalInfo: additionalInfo,
      ),
    );
  }

  /// Función helper para mostrar el diálogo de confirmación genérico
  static Future<void> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? description,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    IconData icon = Icons.help_outline,
    Color iconColor = AppColors.warning,
    bool isDangerous = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog.confirm(
        title: title,
        message: message,
        onConfirm: onConfirm,
        description: description,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        isDangerous: isDangerous,
      ),
    );
  }
}