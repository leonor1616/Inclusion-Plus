import 'package:flutter/material.dart';

import '../../models/route_option_model.dart';
import '../../theme/app_styles.dart';
import '../buttons/bottom_sheet_toggle_button.dart';
import 'route_option_card.dart';

class RouteResultsBottomSheet extends StatelessWidget {
  final List<RouteOption> routes;
  final RouteOption? selectedRoute;
  final DraggableScrollableController? controller;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final void Function(RouteOption route) onRouteSelected;
  final void Function(RouteOption route) onRouteGoPressed;
  final void Function(RouteOption route) onRouteSavePressed;

  const RouteResultsBottomSheet({
    super.key,
    required this.routes,
    required this.selectedRoute,
    required this.isExpanded,
    required this.onToggleExpanded,
    this.controller,
    required this.onRouteSelected,
    required this.onRouteGoPressed,
    required this.onRouteSavePressed,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.42,
      minChildSize: 0.24,
      maxChildSize: 0.86,
      snap: true,
      snapSizes: const [0.24, 0.42, 0.86],
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            12,
            AppSpacing.screenMargin,
            0,
          ),
          decoration: const BoxDecoration(
            color: AppColors.Background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.Secondary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              BottomSheetToggleButton(
                isExpanded: isExpanded,
                collapsedText: 'Click to see route results',
                expandedText: 'Click to minimize route results',
                onTap: onToggleExpanded,
                leading: Text(
                  isLoading
                      ? 'Calculating route...'
                      : 'Showing ${routes.length} Route Results',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.BodyMedium.copyWith(
                    color: AppColors.Primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (errorMessage != null)
                      _RouteErrorState(
                        message: errorMessage!,
                        onRetry: onRetry,
                      )
                    else if (routes.isEmpty)
                      Text(
                        'No routes found',
                        style: AppTextStyles.Body.copyWith(
                          color: AppColors.PrimaryLighter,
                        ),
                      )
                    else
                      for (final route in routes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RouteOptionCard(
                            route: route,
                            isSelected: selectedRoute?.id == route.id,
                            onSelected: () => onRouteSelected(route),
                            onSavePressed: () => onRouteSavePressed(route),
                            onGoPressed: () => onRouteGoPressed(route),
                          ),
                        ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RouteErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _RouteErrorState({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.Body.copyWith(
            color: AppColors.Error,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ],
    );
  }
}