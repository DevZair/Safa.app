import 'package:flutter/material.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_tile.dart';

Future<bool> showAdminSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required TextEditingController loginController,
  required TextEditingController passwordController,
  required ValueChanged<String> onLoginChanged,
  required ValueChanged<String> onPasswordChanged,
  required Future<bool> Function() onSubmit,
}) async {
  final theme = Theme.of(context);
  bool obscurePassword = true;
  bool isSubmitting = false;
  bool loginSuccess = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          top: 10,
        ),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  final navigator = Navigator.of(sheetContext);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.t('settings.section.admin'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.t('settings.admin.subtitle'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SettingsInputTile(
                        icon: Icons.admin_panel_settings_outlined,
                        iconColor: const Color(0xFFF25F5C),
                        title: l10n.t('settings.admin.login.title'),
                        controller: loginController,
                        hintText: l10n.t('settings.admin.login.hint'),
                        autofillHints: const [AutofillHints.username],
                        fillColor: const Color(0xFFF3F4F6),
                        borderColor: const Color(0xFFE1E4EA),
                        focusedBorderColor: const Color(0xFF8D6BFF),
                        cursorColor: const Color(0xFF7B6AF5),
                        selectionColor: const Color(0x337B6AF5),
                        selectionHandleColor: const Color(0xFF7B6AF5),
                        onChanged: onLoginChanged,
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Color(0xFFE5E7EB),
                      ),
                      SettingsInputTile(
                        icon: Icons.vpn_key_outlined,
                        iconColor: const Color(0xFF8D6BFF),
                        title: l10n.t('settings.admin.password.title'),
                        controller: passwordController,
                        hintText: l10n.t('settings.admin.password.hint'),
                        obscureText: obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        fillColor: const Color(0xFFF3F4F6),
                        borderColor: const Color(0xFFE1E4EA),
                        focusedBorderColor: const Color(0xFF8D6BFF),
                        cursorColor: const Color(0xFF7B6AF5),
                        selectionColor: const Color(0x337B6AF5),
                        selectionHandleColor: const Color(0xFF7B6AF5),
                        onChanged: onPasswordChanged,
                        suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () {
                            setModalState(
                              () => obscurePassword = !obscurePassword,
                            );
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF8D6BFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D6BFF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setModalState(() => isSubmitting = true);
                                  final success = await onSubmit();
                                  if (success && navigator.canPop()) {
                                    loginController.clear();
                                    passwordController.clear();
                                    loginSuccess = true;
                                    navigator.pop();
                                  }
                                  setModalState(() => isSubmitting = false);
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.t('settings.admin.submit'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
  return loginSuccess;
}
