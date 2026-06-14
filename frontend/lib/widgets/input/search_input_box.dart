import 'dart:async';
import 'package:flutter/material.dart';

import '../../theme/app_styles.dart';

class SearchInputField<T> extends StatefulWidget {
  final String label;
  final String hintText;
  final Future<List<T>> Function(String query) onSearch;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onSelected;
  final int minCharacters;

  const SearchInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.onSearch,
    required this.itemLabel,
    required this.onSelected,
    this.minCharacters = 1,
  });

  @override
  State<SearchInputField<T>> createState() => _SearchInputFieldState<T>();
}

class _SearchInputFieldState<T> extends State<SearchInputField<T>> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  Timer? debounce;
  List<T> results = [];

  bool isLoading = false;
  bool showResults = false;
  String? errorMessage;

  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 300), () {
      _search(value);
    });
  }

  Future<void> _search(String query) async {
    final cleanQuery = query.trim();

    if (cleanQuery.length < widget.minCharacters) {
      setState(() {
        results = [];
        showResults = false;
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      showResults = true;
      errorMessage = null;
    });

    try {
      final data = await widget.onSearch(cleanQuery);

      if (!mounted) return;

      setState(() {
        results = data;
        showResults = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        results = [];
        errorMessage = e.toString();
        showResults = true;
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _selectItem(T item) {
    controller.text = widget.itemLabel(item);
    widget.onSelected(item);

    setState(() {
      showResults = false;
      results = [];
      errorMessage = null;
    });

    focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.BodyMedium,
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 60,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: _onChanged,
            style: AppTextStyles.Body,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.Body.copyWith(
                color: AppColors.PrimaryLighter,
              ),
              filled: true,
              fillColor: AppColors.Tertiary,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.Accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        if (showResults) ...[
          const SizedBox(height: 8),
          _buildDropdown(),
        ],
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 220,
      ),
      decoration: BoxDecoration(
        color: AppColors.White,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.Secondary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildDropdownContent(),
    );
  }

  Widget _buildDropdownContent() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Searching...',
          style: AppTextStyles.Body,
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          errorMessage!,
          style: AppTextStyles.Body.copyWith(
            color: AppColors.Error,
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No results found',
          style: AppTextStyles.Body.copyWith(
            color: AppColors.PrimaryLighter,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = results[index];
        final label = widget.itemLabel(item);

        return Semantics(
          button: true,
          label: 'Select $label',
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            title: Text(
              label,
              style: AppTextStyles.Body,
            ),
            onTap: () => _selectItem(item),
          ),
        );
      },
    );
  }
}