import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/product_model.dart';
import '../product_details_screen.dart';

class DashboardLedgerTable extends StatefulWidget {
  const DashboardLedgerTable({
    super.key,
    required this.products,
    required this.searchController,
    required this.selectedCategory,
    required this.categories,
    required this.onSearchChanged,
    required this.onCategorySelected,
  });

  final List<ProductModel> products;
  final TextEditingController searchController;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;

  @override
  State<DashboardLedgerTable> createState() => _DashboardLedgerTableState();
}

class _DashboardLedgerTableState extends State<DashboardLedgerTable> {
  final Set<String> _selectedIds = {};

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(widget.products.map((p) => p.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelectRow(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = widget.products.isNotEmpty && _selectedIds.length == widget.products.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter & Category Controls Bar
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;

                final searchFilter = Container(
                  width: isNarrow ? double.infinity : 280,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: widget.searchController,
                    onChanged: widget.onSearchChanged,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Filter by project or owner...',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      prefixIcon: Icon(Icons.filter_list_rounded, size: 16, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                );

                final categorySort = PopupMenuButton<String>(
                  onSelected: widget.onCategorySelected,
                  itemBuilder: (ctx) => widget.categories
                      .map((cat) => PopupMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 12))))
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sort_rounded, size: 15, color: Color(0xFF6B7280)),
                        const SizedBox(width: 6),
                        Text(
                          'Category: ${widget.selectedCategory}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                        ),
                      ],
                    ),
                  ),
                );

                final countText = Text(
                  'Showing 1-${widget.products.length} of ${widget.products.length} results',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      searchFilter,
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [categorySort, countText],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    searchFilter,
                    const SizedBox(width: 12),
                    categorySort,
                    const Spacer(),
                    countText,
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Horizontal Scrollable Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 800),
              child: SizedBox(
                width: 960,
                child: Column(
                  children: [
                    // Column Headers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Checkbox(
                              value: allSelected,
                              onChanged: _toggleSelectAll,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              activeColor: const Color(0xFF1B1638),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            flex: 5,
                            child: Text(
                              'PROJECT NAME',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.8),
                            ),
                          ),
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'CATEGORY',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.8),
                            ),
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text(
                              'OWNER',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.8),
                            ),
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text(
                              'BUDGET ALLOCATION',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.8),
                            ),
                          ),
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'OPERATIONAL HEALTH',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.8),
                            ),
                          ),
                          const SizedBox(
                            width: 60,
                            child: Text(
                              'ACTIONS',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),

                    // Product Item Rows
                    ...widget.products.map((product) {
                      final isSelected = _selectedIds.contains(product.id);
                      final budgetPkr = (product.price * 280).toStringAsFixed(0);

                      return InkWell(
                        onTap: () {
                          context.pushNamed(
                            ProductDetailsScreen.routeName,
                            pathParameters: {'id': product.id},
                          );
                        },
                        child: Container(
                          color: isSelected ? const Color(0xFFF9FAFB) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleSelectRow(product.id),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  activeColor: const Color(0xFF1B1638),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Project Name & ID
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'ID: ${product.id}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              // Category Tag
                              Expanded(
                                flex: 3,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Text(
                                      product.category,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
                                    ),
                                  ),
                                ),
                              ),
                              // Owner Avatar
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFF1B1638),
                                      child: Text(
                                        product.name.isNotEmpty ? product.name[0].toUpperCase() : 'O',
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Lead Engineer', style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
                                  ],
                                ),
                              ),
                              // Budget
                              Expanded(
                                flex: 4,
                                child: Text(
                                  'PKR $budgetPkr',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                                ),
                              ),
                              // Operational Health Badge
                              Expanded(
                                flex: 3,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '• OPTIMAL',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                                    ),
                                  ),
                                ),
                              ),
                              // Action Arrow
                              const SizedBox(
                                width: 60,
                                child: Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Table Pagination Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Text('10 rows', style: TextStyle(fontSize: 11, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PageButton(label: '<', isEnabled: false, onTap: () {}),
                    const SizedBox(width: 4),
                    _PageButton(label: '1', isActive: true, onTap: () {}),
                    const SizedBox(width: 4),
                    _PageButton(label: '2', onTap: () {}),
                    const SizedBox(width: 4),
                    _PageButton(label: '3', onTap: () {}),
                    const SizedBox(width: 4),
                    const Text('...', style: TextStyle(color: Color(0xFF9CA3AF))),
                    const SizedBox(width: 4),
                    _PageButton(label: '24', onTap: () {}),
                    const SizedBox(width: 4),
                    _PageButton(label: '>', onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    this.isActive = false,
    this.isEnabled = true,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1B1638) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive
                ? Colors.white
                : (isEnabled ? const Color(0xFF374151) : const Color(0xFFD1D5DB)),
          ),
        ),
      ),
    );
  }
}