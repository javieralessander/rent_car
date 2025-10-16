import 'package:flutter/material.dart';

import '../../core/config/app_theme.dart';
import 'empty_state_widget.dart';

enum CollectionViewMode { list, grid }

class CollectionItemData {
  const CollectionItemData({
    required this.title,
    this.subtitle,
    this.badge,
    this.header,
    this.statusChip,
    this.details = const [],
    this.actions = const [],
    this.footerStatus,
  });

  final String title;
  final String? subtitle;
  final CollectionBadgeData? badge;
  final CollectionHeaderData? header;
  final CollectionStatusChip? statusChip;
  final List<CollectionDetailInfo> details;
  final List<CollectionActionData> actions;
  final CollectionFooterStatus? footerStatus;
}

class CollectionBadgeData {
  const CollectionBadgeData({
    this.text,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor = AppColors.white,
  }) : assert(
         text != null || icon != null,
         'badge requires either a text or an icon',
       );

  final String? text;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color foregroundColor;
}

class CollectionHeaderData {
  const CollectionHeaderData({
    this.title,
    this.subtitle,
    this.backgroundColor,
    this.leadingIcon,
  });

  final String? title;
  final String? subtitle;
  final Color? backgroundColor;
  final IconData? leadingIcon;
}

class CollectionStatusChip {
  const CollectionStatusChip({
    required this.label,
    this.backgroundColor,
    this.textColor = AppColors.primary,
  });

  final String label;
  final Color? backgroundColor;
  final Color textColor;
}

class CollectionDetailInfo {
  const CollectionDetailInfo({
    required this.value,
    this.label,
    this.icon,
    this.inlineValue,
    this.iconColor,
    this.iconBackground,
  });

  final String value;
  final String? label;
  final IconData? icon;
  final String? inlineValue;
  final Color? iconColor;
  final Color? iconBackground;
}

class CollectionFooterStatus {
  const CollectionFooterStatus({
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;
}

class CollectionActionData {
  const CollectionActionData({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = CollectionActionVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final CollectionActionVariant variant;
}

enum CollectionActionVariant { primary, secondary, outlined, ghost, danger }

class GenericCollectionView extends StatelessWidget {
  const GenericCollectionView({
    super.key,
    required this.title,
    required this.items,
    this.isLoading = false,
    this.viewMode = CollectionViewMode.list,
    this.onViewModeChanged,
    this.topRightWidget,
    this.onSearch,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.itemsPerPage = 5,
    this.onPageChanged,
    this.onItemsPerPageChanged,
    this.itemsPerPageOptions = const [6, 12, 24],
    this.emptyBuilder,
  });

  final String title;
  final List<CollectionItemData> items;
  final bool isLoading;
  final CollectionViewMode viewMode;
  final ValueChanged<CollectionViewMode>? onViewModeChanged;
  final Widget? topRightWidget;
  final void Function(String value)? onSearch;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;
  final List<int> itemsPerPageOptions;
  final Widget? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    // Responsive padding
    final horizontalPadding =
        isMobile
            ? 8.0
            : isTablet
            ? 16.0
            : 24.0;
    final verticalPadding = isMobile ? 8.0 : 16.0;

    // Responsive font sizes
    final titleFontSize =
        isMobile
            ? 16.0
            : isTablet
            ? 17.0
            : 18.0;
    final subtitleFontSize =
        isMobile
            ? 13.0
            : isTablet
            ? 13.0
            : 14.0;
    final detailFontSize =
        isMobile
            ? 13.0
            : isTablet
            ? 13.0
            : 14.0;
    final headerFontSize =
        isMobile
            ? 12.0
            : isTablet
            ? 12.0
            : 13.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: SingleChildScrollView(
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 12 : 16,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 650;

                    final viewToggle = _ViewModeToggle(
                      mode: viewMode,
                      onModeChanged: onViewModeChanged,
                    );

                    final searchField =
                        onSearch != null
                            ? Container(
                              width: 280,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                color: AppColors.light.withOpacity(0.5),
                                border: Border.all(
                                  color: AppColors.grayLight.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.gray,
                                    size: 20,
                                  ),
                                  hintText: 'Buscar...',
                                  hintStyle: TextStyle(
                                    color: AppColors.gray.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                onChanged: onSearch,
                              ),
                            )
                            : null;

                    final actionWidgets = <Widget>[
                      if (searchField != null) searchField,
                      if (onViewModeChanged != null) viewToggle,
                      if (topRightWidget != null)
                        SizedBox(height: 40, child: topRightWidget!),
                    ];

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: actionWidgets,
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                        ...actionWidgets
                            .map(
                              (widget) => Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: widget,
                              ),
                            )
                            .toList(),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.grayLight),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: LinearProgressIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.light,
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 12 : 16,
                  ),
                  child: _buildContent(
                    context,
                    titleFontSize: titleFontSize,
                    subtitleFontSize: subtitleFontSize,
                    detailFontSize: detailFontSize,
                    headerFontSize: headerFontSize,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required double titleFontSize,
    required double subtitleFontSize,
    required double detailFontSize,
    required double headerFontSize,
    required bool isMobile,
    required bool isTablet,
  }) {
    if (items.isEmpty) {
      return emptyBuilder ?? _getDefaultEmptyState();
    }

    switch (viewMode) {
      case CollectionViewMode.list:
        return Column(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CollectionListCard(
                  item: item,
                  titleFontSize: titleFontSize,
                  subtitleFontSize: subtitleFontSize,
                  detailFontSize: detailFontSize,
                ),
              ),
          ],
        );
      case CollectionViewMode.grid:
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int crossAxisCount = 1;
            if (width > 1400) {
              crossAxisCount = 3;
            } else if (width > 1024) {
              crossAxisCount = 3;
            } else if (width > 720) {
              crossAxisCount = 2;
            }

            return GridView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _CollectionGridCard(
                  item: item,
                  titleFontSize: titleFontSize,
                  subtitleFontSize: subtitleFontSize,
                  detailFontSize: detailFontSize,
                  headerFontSize: headerFontSize,
                );
              },
            );
          },
        );
    }
  }

  Widget _buildFooter(BuildContext context) {
    final showingStart =
        items.isEmpty ? 0 : ((currentPage - 1) * itemsPerPage) + 1;
    final showingEnd = (currentPage * itemsPerPage).clamp(0, totalItems);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 8 : 12,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          final paginationControls = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                onPressed:
                    currentPage > 1
                        ? () => onPageChanged?.call(currentPage - 1)
                        : null,
              ),
              ...List.generate(totalPages, (index) {
                final page = index + 1;
                final selected = page == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
                      backgroundColor: selected ? AppColors.light : null,
                      side: BorderSide(
                        color:
                            selected ? AppColors.primary : AppColors.grayLight,
                      ),
                    ),
                    onPressed: () => onPageChanged?.call(page),
                    child: Text(
                      '$page',
                      style: TextStyle(
                        color: selected ? AppColors.primary : AppColors.dark,
                      ),
                    ),
                  ),
                );
              }),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                onPressed:
                    currentPage < totalPages
                        ? () => onPageChanged?.call(currentPage + 1)
                        : null,
              ),
            ],
          );

          final itemsPerPageSelector = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Registros por página',
                style: TextStyle(color: AppColors.grayDark),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: itemsPerPageOptions.contains(itemsPerPage) ? itemsPerPage : itemsPerPageOptions.first,
                items:
                    itemsPerPageOptions
                        .map(
                          (value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) onItemsPerPageChanged?.call(value);
                },
              ),
            ],
          );

          final infoText = Text(
            'Mostrando registros ${items.isEmpty ? 0 : showingStart} - $showingEnd de $totalItems',
            style: const TextStyle(color: AppColors.grayDark),
          );

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoText,
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [paginationControls, itemsPerPageSelector],
                ),
              ],
            );
          }

          return Row(
            children: [
              infoText,
              const Spacer(),
              paginationControls,
              const SizedBox(width: 16),
              itemsPerPageSelector,
            ],
          );
        },
      ),
    );
  }

  Widget _getDefaultEmptyState() {
    // Determinar el tipo de entidad basado en el título
    final titleLower = title.toLowerCase();

    if (titleLower.contains('modelo')) {
      return EmptyStateConfig.forModels();
    } else if (titleLower.contains('vehículo') || titleLower.contains('vehiculo')) {
      return EmptyStateConfig.forVehicles();
    } else if (titleLower.contains('cliente')) {
      return EmptyStateConfig.forClients();
    } else if (titleLower.contains('renta')) {
      return EmptyStateConfig.forRentals();
    } else if (titleLower.contains('empleado')) {
      return EmptyStateConfig.forEmployees();
    } else if (titleLower.contains('marca')) {
      return EmptyStateConfig.forBrands();
    } else if (titleLower.contains('inspección') || titleLower.contains('inspeccion')) {
      return EmptyStateConfig.forInspections();
    } else if (titleLower.contains('tipo') && titleLower.contains('vehículo')) {
      return EmptyStateConfig.forVehicleTypes();
    } else if (titleLower.contains('combustible')) {
      return EmptyStateConfig.forFuelTypes();
    } else {
      // Estado vacío genérico
      return const EmptyStateWidget(
        icon: Icons.folder_open_outlined,
        title: 'No hay registros',
        description: 'No se encontraron registros para mostrar.\nPuede agregar nuevos elementos cuando esté listo.',
        backgroundColor: AppColors.info,
      );
    }
  }
}

class _CollectionListCard extends StatelessWidget {
  const _CollectionListCard({
    required this.item,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.detailFontSize,
  });

  final CollectionItemData item;
  final double titleFontSize;
  final double subtitleFontSize;
  final double detailFontSize;

  @override
  Widget build(BuildContext context) {
    final showHeader = item.header != null || item.statusChip != null;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) _ListCardHeader(item: item),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompactWidth = constraints.maxWidth < 360;
                final badgeSize = isCompactWidth ? 48.0 : 56.0;
                final gap = isCompactWidth ? 12.0 : 16.0;
                var localSubtitleFont =
                    subtitleFontSize - (isCompactWidth ? 1.0 : 0.0);
                if (localSubtitleFont < 11) localSubtitleFont = 11.0;
                var localTitleFont =
                    titleFontSize - (isCompactWidth ? 0.5 : 0.0);
                if (localTitleFont < 14) localTitleFont = 14.0;
                final hasActions = item.actions.isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.badge != null) ...[
                          _CollectionBadge(data: item.badge!, size: badgeSize),
                          SizedBox(width: gap),
                        ],
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, innerConstraints) {
                              final compactBreakpoint = 680.0;
                              final actionButtons =
                                  item.actions.map(_ActionButton.new).toList();
                              final rowButtons = <Widget>[
                                for (
                                  var i = 0;
                                  i < actionButtons.length;
                                  i++
                                ) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  actionButtons[i],
                                ],
                              ];

                              final textSection = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: localTitleFont,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.subtitle != null &&
                                      item.subtitle!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        item.subtitle!,
                                        style: TextStyle(
                                          color: AppColors.grayDark,
                                          fontSize: localSubtitleFont,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              );

                              final statusChipWidget =
                                  !showHeader && item.statusChip != null
                                      ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: _StatusChipWidget(
                                          chip: item.statusChip!,
                                        ),
                                      )
                                      : null;

                              if (innerConstraints.maxWidth <
                                  compactBreakpoint) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: textSection),
                                        if (statusChipWidget != null)
                                          statusChipWidget,
                                      ],
                                    ),
                                    if (hasActions) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: actionButtons,
                                      ),
                                    ],
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: textSection),
                                        if (statusChipWidget != null)
                                          statusChipWidget,
                                      ],
                                    ),
                                  ),
                                  if (hasActions) ...[
                                    SizedBox(width: gap),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: rowButtons,
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCardHeader extends StatelessWidget {
  const _ListCardHeader({required this.item});

  final CollectionItemData item;

  @override
  Widget build(BuildContext context) {
    final header = item.header;
    final hasTitle = header?.title != null && header!.title!.isNotEmpty;
    final hasSubtitle =
        header?.subtitle != null && header!.subtitle!.isNotEmpty;
    final hasLeadingIcon = header?.leadingIcon != null;
    final background =
        header?.backgroundColor ?? AppColors.primary.withOpacity(0.04);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        border: const Border(bottom: BorderSide(color: AppColors.grayLight)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final iconSize = isCompact ? 28.0 : 32.0;
          final iconInner = isCompact ? 16.0 : 18.0;
          final titleFont = isCompact ? 12.0 : 13.0;
          final subtitleFont = isCompact ? 13.0 : 14.0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasLeadingIcon) ...[
                Container(
                  height: iconSize,
                  width: iconSize,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    header!.leadingIcon,
                    size: iconInner,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (hasTitle || hasSubtitle)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasTitle)
                        Text(
                          header!.title!,
                          style: TextStyle(
                            color: AppColors.grayDark,
                            fontSize: titleFont,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (hasSubtitle) ...[
                        if (hasTitle) const SizedBox(height: 2),
                        Text(
                          header!.subtitle!,
                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: subtitleFont,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                )
              else
                const Spacer(),
              if (item.statusChip != null)
                _StatusChipWidget(chip: item.statusChip!),
            ],
          );
        },
      ),
    );
  }
}

class _CollectionGridCard extends StatelessWidget {
  const _CollectionGridCard({
    required this.item,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.detailFontSize,
    required this.headerFontSize,
  });

  final CollectionItemData item;
  final double titleFontSize;
  final double subtitleFontSize;
  final double detailFontSize;
  final double headerFontSize;

  @override
  Widget build(BuildContext context) {
    final showHeader = item.header != null || item.statusChip != null;
    final richDetails =
        item.details
            .where((detail) => detail.icon != null || detail.label != null)
            .toList();
    final inlineDetails =
        item.details
            .where((detail) => detail.icon == null && detail.label == null)
            .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(minHeight: 220),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              _CollectionCardHeader(
                item: item,
                titleFontSize: headerFontSize,
                subtitleFontSize: headerFontSize > 0 ? headerFontSize + 1 : null,
              ),
              const Divider(height: 1, color: AppColors.grayLight),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompactWidth = constraints.maxWidth < 340;
                    final isExtraCompact = constraints.maxWidth < 280;
                    final badgeSize =
                        isExtraCompact
                            ? 44.0
                            : isCompactWidth
                            ? 50.0
                            : 56.0;
                    final horizontalGap = isCompactWidth ? 12.0 : 16.0;
                    final subtitleSizeBase =
                        subtitleFontSize - (isCompactWidth ? 1.0 : 0.0);
                    final subtitleSize =
                        subtitleSizeBase < 11 ? 11.0 : subtitleSizeBase;
                    var titleSize = titleFontSize - (isCompactWidth ? 0.5 : 0.0);
                    if (titleSize < 14) titleSize = 14.0;
                    final showCompactDetails = isCompactWidth;
                    final compactDetailFont =
                        (detailFontSize - 1).clamp(11.0, detailFontSize).toDouble();

                    final chipDetails = <CollectionDetailInfo>[];
                    if (showCompactDetails) {
                      for (final detail in richDetails) {
                        chipDetails.add(detail);
                        if (chipDetails.length >= 6) break;
                      }
                      if (chipDetails.length < 6) {
                        for (final detail in inlineDetails) {
                          final value = (detail.inlineValue ?? detail.value).trim();
                          if (value.isEmpty) continue;
                          chipDetails.add(
                            CollectionDetailInfo(
                              value: value,
                              label: detail.label,
                              icon: detail.icon,
                              iconColor: detail.iconColor,
                              iconBackground: detail.iconBackground,
                            ),
                          );
                          if (chipDetails.length >= 6) break;
                        }
                      }
                    }

                    return Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.badge != null) ...[
                                _CollectionBadge(data: item.badge!, size: badgeSize),
                                SizedBox(width: horizontalGap),
                              ],
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: titleSize,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.dark,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item.subtitle != null &&
                                        item.subtitle!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          item.subtitle!,
                                          style: TextStyle(
                                            color: AppColors.grayDark,
                                            fontSize: subtitleSize,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        if (!showCompactDetails && richDetails.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: richDetails.take(3).map((detail) => _DetailRow(
                                detail: detail,
                                valueFontSize: detailFontSize,
                                labelFontSize: detailFontSize - 2,
                              )).toList(),
                            ),
                          ),
                        ],
                        if (showCompactDetails && chipDetails.isNotEmpty) ...[
                          SizedBox(height: isCompactWidth ? 8 : 10),
                          Flexible(
                            child: _DetailChipWrap(
                              details: chipDetails,
                              fontSize: compactDetailFont,
                            ),
                          ),
                        ],
                        if (!showCompactDetails && inlineDetails.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Flexible(
                            child: _InlineDetails(details: inlineDetails),
                          ),
                        ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (item.actions.isNotEmpty || item.footerStatus != null)
              const Divider(height: 1, color: AppColors.grayLight),
            if (item.actions.isNotEmpty || item.footerStatus != null)
              _CollectionCardFooter(
                item: item,
                compactPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CollectionCardHeader extends StatelessWidget {
  const _CollectionCardHeader({
    required this.item,
    this.titleFontSize,
    this.subtitleFontSize,
  });

  final CollectionItemData item;
  final double? titleFontSize;
  final double? subtitleFontSize;

  @override
  Widget build(BuildContext context) {
    final header = item.header;
    final background =
        header?.backgroundColor ?? AppColors.primary.withOpacity(0.06);
    final hasTitle = header?.title != null && header!.title!.isNotEmpty;
    final hasSubtitle =
        header?.subtitle != null && header!.subtitle!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header?.leadingIcon != null) ...[
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                header!.leadingIcon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child:
                hasTitle || hasSubtitle
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasTitle) ...[
                          Text(
                            header!.title!,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.grayDark,
                              fontSize: titleFontSize ?? 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (hasSubtitle)
                          Text(
                            header.subtitle!,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                              fontSize: subtitleFontSize ?? 15,
                            ),
                          ),
                      ],
                    )
                    : const SizedBox(),
          ),
          if (item.statusChip != null)
            _StatusChipWidget(chip: item.statusChip!),
        ],
      ),
    );
  }
}

class _SummaryInfoPills extends StatelessWidget {
  const _SummaryInfoPills({required this.values, this.fontSize = 13});

  final List<String> values;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.light.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.grayDark,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _DetailChipWrap extends StatelessWidget {
  const _DetailChipWrap({required this.details, this.fontSize = 13});

  final List<CollectionDetailInfo> details;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) return const SizedBox.shrink();

    var labelFont = fontSize - 2;
    if (labelFont < 10) labelFont = 10.0;
    final iconSize = fontSize + 3;
    final iconDimension = iconSize + 10;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final detail in details)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.light.withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (detail.icon != null) ...[
                  Container(
                    height: iconDimension,
                    width: iconDimension,
                    decoration: BoxDecoration(
                      color:
                          detail.iconBackground ??
                          (detail.iconColor ?? AppColors.primary).withOpacity(
                            0.12,
                          ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      detail.icon,
                      size: iconSize,
                      color: detail.iconColor ?? AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (detail.label != null && detail.label!.isNotEmpty)
                        Text(
                          detail.label!,
                          style: TextStyle(
                            color: AppColors.grayDark,
                            fontSize: labelFont,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        detail.value,
                        style: TextStyle(
                          color: AppColors.dark,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CollectionCardFooter extends StatelessWidget {
  const _CollectionCardFooter({required this.item, this.compactPadding});

  final CollectionItemData item;
  final EdgeInsets? compactPadding;

  @override
  Widget build(BuildContext context) {
    final hasStatus = item.footerStatus != null;
    final hasActions = item.actions.isNotEmpty;
    if (!hasStatus && !hasActions) {
      return const SizedBox.shrink();
    }

    final padding =
        compactPadding ??
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    final statusWidget =
        hasStatus ? _FooterStatus(status: item.footerStatus!) : null;
    final actionButtons = [
      for (var i = 0; i < item.actions.length; i++) ...[
        if (i > 0) const SizedBox(width: 12),
        _ActionButton(item.actions[i]),
      ],
    ];

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 400;
          final isCompact = constraints.maxWidth < 520;

          if (isMobile) {
            // Stack vertically for very small screens
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (statusWidget != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: statusWidget,
                  ),
                if (statusWidget != null && hasActions)
                  const SizedBox(height: 10),
                if (hasActions)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actionButtons,
                    ),
                  ),
              ],
            );
          }

          if (isCompact) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (statusWidget != null)
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: statusWidget,
                    ),
                  ),
                if (statusWidget != null && hasActions)
                  const SizedBox(width: 12),
                if (hasActions)
                  Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actionButtons,
                      ),
                    ),
                  ),
              ],
            );
          }

          // Default (desktop/tablet) layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (statusWidget != null) statusWidget,
              if (statusWidget != null && hasActions) const Spacer(),
              if (statusWidget == null && hasActions) const Spacer(),
              if (hasActions)
                Row(mainAxisSize: MainAxisSize.min, children: actionButtons),
            ],
          );
        },
      ),
    );
  }
}

class _CollectionBadge extends StatelessWidget {
  const _CollectionBadge({required this.data, this.size = 56});

  final CollectionBadgeData data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dimension = size.clamp(40.0, 64.0).toDouble();
    final iconSize = (dimension * 0.4).clamp(16.0, 24.0).toDouble();
    final textSize = (dimension * 0.36).clamp(16.0, 22.0).toDouble();

    return Container(
      height: dimension,
      width: dimension,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient:
            data.gradient ??
            LinearGradient(
              colors: [AppColors.primary, AppColors.info.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        color:
            data.gradient == null
                ? (data.backgroundColor ?? AppColors.primary)
                : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child:
            data.icon != null
                ? Icon(data.icon, color: data.foregroundColor, size: iconSize)
                : Text(
                  data.text ?? '',
                  style: TextStyle(
                    color: data.foregroundColor,
                    fontWeight: FontWeight.w700,
                    fontSize: textSize,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }
}

class _StatusChipWidget extends StatelessWidget {
  const _StatusChipWidget({required this.chip});

  final CollectionStatusChip chip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: chip.backgroundColor ?? AppColors.primary.withOpacity(0.12),
      ),
      child: Text(
        chip.label,
        style: TextStyle(
          color: chip.textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InlineDetails extends StatelessWidget {
  const _InlineDetails({required this.details});

  final List<CollectionDetailInfo> details;

  @override
  Widget build(BuildContext context) {
    final values =
        details
            .map((detail) => (detail.inlineValue ?? detail.value).trim())
            .where((value) => value.isNotEmpty)
            .toList();

    if (values.isEmpty) return const SizedBox.shrink();

    final bulletStyle = TextStyle(
      color: AppColors.gray.withOpacity(0.6),
      fontSize: 13,
    );

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) TextSpan(text: '  •  ', style: bulletStyle),
            TextSpan(
              text: values[i],
              style: const TextStyle(
                color: AppColors.grayDark,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.detail,
    this.valueFontSize = 14,
    this.labelFontSize = 12,
  });

  final CollectionDetailInfo detail;
  final double valueFontSize;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    final hasLabel = detail.label != null && detail.label!.isNotEmpty;
    final iconColor = detail.iconColor ?? AppColors.primary;
    final badgeColor = detail.iconBackground ?? iconColor.withOpacity(0.12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.icon != null) ...[
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(detail.icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasLabel)
                  Text(
                    detail.label!,
                    style: TextStyle(
                      color: AppColors.grayDark,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  detail.value,
                  style: TextStyle(
                    color: AppColors.dark,
                    fontWeight: FontWeight.w700,
                    fontSize: valueFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterStatus extends StatelessWidget {
  const _FooterStatus({required this.status});

  final CollectionFooterStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(status.icon ?? Icons.adjust, size: 16, color: status.color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            status.label,
            style: TextStyle(color: status.color, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.action);

  final CollectionActionData action;

  @override
  Widget build(BuildContext context) {
    final hasIcon = action.icon != null;

    switch (action.variant) {
      case CollectionActionVariant.primary:
        return hasIcon
            ? FilledButton.icon(
              onPressed: action.onPressed,
              icon: Icon(action.icon, size: 18),
              label: Text(action.label),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            )
            : FilledButton(
              onPressed: action.onPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text(action.label),
            );
      case CollectionActionVariant.secondary:
        return hasIcon
            ? FilledButton.icon(
              onPressed: action.onPressed,
              icon: Icon(action.icon, size: 18),
              label: Text(action.label),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
              ),
            )
            : FilledButton(
              onPressed: action.onPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
              ),
              child: Text(action.label),
            );
      case CollectionActionVariant.outlined:
        return hasIcon
            ? OutlinedButton.icon(
              onPressed: action.onPressed,
              icon: Icon(action.icon, size: 18, color: AppColors.dark),
              label: Text(action.label),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.grayLight),
                foregroundColor: AppColors.dark,
              ),
            )
            : OutlinedButton(
              onPressed: action.onPressed,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.grayLight),
                foregroundColor: AppColors.dark,
              ),
              child: Text(action.label),
            );
      case CollectionActionVariant.ghost:
        return hasIcon
            ? TextButton.icon(
              onPressed: action.onPressed,
              icon: Icon(action.icon, size: 18, color: AppColors.dark),
              label: Text(action.label),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.dark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                minimumSize: const Size(0, 40),
              ),
            )
            : TextButton(
              onPressed: action.onPressed,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.dark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                minimumSize: const Size(0, 40),
              ),
              child: Text(action.label),
            );
      case CollectionActionVariant.danger:
        return hasIcon
            ? TextButton.icon(
              onPressed: action.onPressed,
              icon: Icon(action.icon, size: 18, color: AppColors.danger),
              label: Text(action.label),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                minimumSize: const Size(0, 40),
              ),
            )
            : TextButton(
              onPressed: action.onPressed,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                minimumSize: const Size(0, 40),
              ),
              child: Text(action.label),
            );
    }
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({required this.mode, required this.onModeChanged});

  final CollectionViewMode mode;
  final ValueChanged<CollectionViewMode>? onModeChanged;

  @override
  Widget build(BuildContext context) {
    if (onModeChanged == null) return const SizedBox.shrink();

    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.light.withOpacity(0.5),
        border: Border.all(
          color: AppColors.grayLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeButton(
            icon: Icons.view_list_rounded,
            label: 'Lista',
            selected: mode == CollectionViewMode.list,
            onPressed: () => onModeChanged?.call(CollectionViewMode.list),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.grayLight.withOpacity(0.4),
            margin: const EdgeInsets.symmetric(horizontal: 2),
          ),
          _ViewModeButton(
            icon: Icons.grid_view_rounded,
            label: 'Grid',
            selected: mode == CollectionViewMode.grid,
            onPressed: () => onModeChanged?.call(CollectionViewMode.grid),
          ),
        ],
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          minimumSize: const Size(80, 36),
          foregroundColor: selected ? AppColors.white : AppColors.gray,
          backgroundColor: selected
              ? AppColors.primary
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: selected ? AppColors.white : AppColors.gray,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.white : AppColors.gray,
          ),
        ),
      ),
    );
  }
}
