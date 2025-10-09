import 'package:flutter/material.dart';

import '../../core/config/app_theme.dart';

class GenericDataTable<T> extends StatelessWidget {
  final List<T> items;
  final List<DataColumn> columns;
  final List<DataRow> Function(List<T> items) rowBuilder;
  final String title;
  final bool isLoading;
  final Widget? topRightWidget;
  final void Function(String)? onSearch;
  final int currentPage;
  final int totalPages;
  final void Function(int)? onPageChanged;
  final int totalItems;
  final int itemsPerPage;
  final void Function(int)? onItemsPerPageChanged;

  const GenericDataTable({
    super.key,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    required this.title,
    this.isLoading = false,
    this.topRightWidget,
    this.onSearch,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.itemsPerPage = 5,
    this.onPageChanged,
    this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 600;
                    return isSmall
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.dark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (onSearch != null)
                                  SizedBox(
                                    width: 220,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: AppColors.gray,
                                        ),
                                        hintText: 'Buscar...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.light,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 0,
                                              horizontal: 12,
                                            ),
                                      ),
                                      onChanged: onSearch,
                                    ),
                                  ),
                                if (topRightWidget != null)
                                  SizedBox(height: 40, child: topRightWidget!),
                              ],
                            ),
                          ],
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.dark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (onSearch != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: SizedBox(
                                  width: 220,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: AppColors.gray,
                                      ),
                                      hintText: 'Buscar...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.light,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 0,
                                            horizontal: 12,
                                          ),
                                    ),
                                    onChanged: onSearch,
                                  ),
                                ),
                              ),
                            if (topRightWidget != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: SizedBox(
                                  height: 40,
                                  child: topRightWidget!,
                                ),
                              ),
                          ],
                        );
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.grayLight),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: LinearProgressIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.light,
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 1200),
                    child: DataTable(
                      columnSpacing: 32,
                      headingRowColor: WidgetStateProperty.all(AppColors.light),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: AppColors.grayLight,
                          width: 1,
                        ),
                      ),
                      columns: columns,
                      rows: rowBuilder(items),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 500;
                    return isMobile
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mostrando registros ${(items.isEmpty) ? 0 : ((currentPage - 1) * itemsPerPage + 1)} - ${(currentPage * itemsPerPage).clamp(0, totalItems)} de $totalItems',
                              style: const TextStyle(color: AppColors.grayDark),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    color: AppColors.primary,
                                  ),
                                  onPressed:
                                      currentPage > 1
                                          ? () => onPageChanged?.call(
                                            currentPage - 1,
                                          )
                                          : null,
                                ),
                                ...List.generate(totalPages, (i) {
                                  final isSelected = currentPage == i + 1;
                                  return OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          isSelected ? AppColors.light : null,
                                      side: BorderSide(
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : AppColors.grayLight,
                                      ),
                                      minimumSize: const Size(36, 36),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () => onPageChanged?.call(i + 1),
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : AppColors.dark,
                                      ),
                                    ),
                                  );
                                }),
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.primary,
                                  ),
                                  onPressed:
                                      currentPage < totalPages
                                          ? () => onPageChanged?.call(
                                            currentPage + 1,
                                          )
                                          : null,
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Registros por página',
                                  style: TextStyle(color: AppColors.grayDark),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<int>(
                                  value: itemsPerPage,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 5,
                                      child: Text('5'),
                                    ),
                                    DropdownMenuItem(
                                      value: 10,
                                      child: Text('10'),
                                    ),
                                    DropdownMenuItem(
                                      value: 20,
                                      child: Text('20'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      onItemsPerPageChanged?.call(value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                        : Row(
                          children: [
                            Text(
                              'Mostrando registros ${(items.isEmpty) ? 0 : ((currentPage - 1) * itemsPerPage + 1)} - ${(currentPage * itemsPerPage).clamp(0, totalItems)} de $totalItems',
                              style: const TextStyle(color: AppColors.grayDark),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.primary,
                              ),
                              onPressed:
                                  currentPage > 1
                                      ? () =>
                                          onPageChanged?.call(currentPage - 1)
                                      : null,
                            ),
                            ...List.generate(totalPages, (i) {
                              final isSelected = currentPage == i + 1;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        isSelected ? AppColors.light : null,
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : AppColors.grayLight,
                                    ),
                                    minimumSize: const Size(36, 36),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () => onPageChanged?.call(i + 1),
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : AppColors.dark,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_right,
                                color: AppColors.primary,
                              ),
                              onPressed:
                                  currentPage < totalPages
                                      ? () =>
                                          onPageChanged?.call(currentPage + 1)
                                      : null,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Registros por página',
                              style: TextStyle(color: AppColors.grayDark),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: itemsPerPage,
                              items: const [
                                DropdownMenuItem(value: 5, child: Text('5')),
                                DropdownMenuItem(value: 10, child: Text('10')),
                                DropdownMenuItem(value: 20, child: Text('20')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  onItemsPerPageChanged?.call(value);
                                }
                              },
                            ),
                          ],
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
