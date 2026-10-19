import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';

final class ZebraListItem extends StatelessWidget {
  const ZebraListItem({
    super.key,
    required this.index,
    required this.child,
    this.onTap,
  });

  final int index;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppTokens tokens = AppTokens.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color background = index.isEven
        ? scheme.surface
        : tokens.zebraSurface;
    return Card(
      color: background,
      margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

typedef ZebraCard = ZebraListItem;
typedef ZebraRow = ZebraListItem;
typedef ZebraTile = ZebraListItem;
