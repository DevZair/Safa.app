import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_tile.dart';

Future<bool> showAdminSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required TextEditingController loginController,
  required TextEditingController passwordController,
  ValueChanged<String>? onLoginChanged,
  ValueChanged<String>? onPasswordChanged,
  required Future<bool> Function() onSubmit,
  String? sheetTitle,
  String? sheetSubtitle,
  String? loginLabel,
  String? loginHint,
  String? passwordLabel,
  String? passwordHint,
  String? submitLabel,
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
          left: 16.w,
          right: 16.w,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16.h,
          top: 10.h,
        ),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(32.r),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 22.h),
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
                          width: 44.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        sheetTitle ?? l10n.t('settings.section.admin'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        sheetSubtitle ?? l10n.t('settings.admin.subtitle'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SettingsInputTile(
                        icon: Icons.admin_panel_settings_outlined,
                        iconColor: const Color(0xFFF25F5C),
                        title:
                            loginLabel ?? l10n.t('settings.admin.login.title'),
                        controller: loginController,
                        hintText:
                            loginHint ?? l10n.t('settings.admin.login.hint'),
                        autofillHints: const [AutofillHints.username],
                        fillColor: const Color(0xFFF3F4F6),
                        borderColor: const Color(0xFFE1E4EA),
                        focusedBorderColor: const Color(0xFF8D6BFF),
                        cursorColor: const Color(0xFF7B6AF5),
                        selectionColor: const Color(0x337B6AF5),
                        selectionHandleColor: const Color(0xFF7B6AF5),
                        onChanged: onLoginChanged,
                      ),
                      Divider(
                        height: 1.h,
                        thickness: 0.8.w,
                        color: Color(0xFFE5E7EB),
                      ),
                      SettingsInputTile(
                        icon: Icons.vpn_key_outlined,
                        iconColor: const Color(0xFF8D6BFF),
                        title:
                            passwordLabel ??
                            l10n.t('settings.admin.password.title'),
                        controller: passwordController,
                        hintText:
                            passwordHint ??
                            l10n.t('settings.admin.password.hint'),
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
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D6BFF),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
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
                              ? SizedBox(
                                  height: 18.r,
                                  width: 18.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.w,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  submitLabel ??
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
