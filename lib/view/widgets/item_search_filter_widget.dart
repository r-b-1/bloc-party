import 'package:flutter/material.dart';

import 'package:blocparty/view/widgets/ui/tokens.dart';

class ItemSearchFilterWidget extends StatefulWidget {
  final List<String> availableTags;
  final Function(String) onSearchChanged;
  final Function(List<String>) onTagsChanged;
  final String? initialSearchText;
  final List<String>? initialSelectedTags;

  const ItemSearchFilterWidget({
    Key? key,
    required this.availableTags,
    required this.onSearchChanged,
    required this.onTagsChanged,
    this.initialSearchText,
    this.initialSelectedTags,
  }) : super(key: key);

  @override
  State<ItemSearchFilterWidget> createState() => _ItemSearchFilterWidgetState();
}

class _ItemSearchFilterWidgetState extends State<ItemSearchFilterWidget> {
  late TextEditingController _searchController;
  late TextEditingController _tagSearchController;
  Set<String> _selectedTags = {};
  bool _isTagFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.initialSearchText ?? '',
    );
    _tagSearchController = TextEditingController();
    if (widget.initialSelectedTags != null) {
      _selectedTags = widget.initialSelectedTags!.toSet();
    }
    if (widget.initialSearchText != null &&
        widget.initialSearchText!.isNotEmpty) {
      widget.onSearchChanged(widget.initialSearchText!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tagSearchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ItemSearchFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Identity comparison is not enough: models hand back a fresh List on
    // every call. Compare by contents so we only react to real changes.
    bool tagsChanged = oldWidget.availableTags.length !=
            widget.availableTags.length ||
        !oldWidget.availableTags.every(widget.availableTags.contains);
    if (tagsChanged) {
      final newSelectedTags = _selectedTags.intersection(
        widget.availableTags.toSet(),
      );
      if (newSelectedTags != _selectedTags) {
        setState(() {
          _selectedTags = newSelectedTags;
        });
        widget.onTagsChanged(_selectedTags.toList());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sort and deduplicate tags, then filter based on the tag search text
    final sortedDeduplicatedTags = widget.availableTags.toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final filteredTags = sortedDeduplicatedTags
        .where(
          (tag) => tag.toLowerCase().contains(
                _tagSearchController.text.toLowerCase(),
              ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search — plain and quiet, no card-in-card.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            return TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search drills, ladders, tables…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                widget.onSearchChanged(value);
              },
            );
          },
        ),
        const SizedBox(height: Spacing.sm),
        // Tag filter — progressive disclosure behind an unobtrusive toggle.
        TextButton.icon(
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 40),
            visualDensity: VisualDensity.compact,
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            setState(() {
              _isTagFilterExpanded = !_isTagFilterExpanded;
            });
          },
          icon: Icon(
            _isTagFilterExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.tune_rounded,
            size: 18,
          ),
          label: Text(
            _selectedTags.isEmpty
                ? 'Filter by tags'
                : 'Filter by tags (${_selectedTags.length} active)',
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutQuart,
          alignment: Alignment.topCenter,
          child: _isTagFilterExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: Spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (sortedDeduplicatedTags.length > 12) ...[
                        TextField(
                          controller: _tagSearchController,
                          decoration: const InputDecoration(
                            hintText: 'Find a tag…',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: Spacing.md),
                      ],
                      if (filteredTags.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Spacing.md),
                          child: Text(
                            'No tags found',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Wrap(
                          spacing: Spacing.sm,
                          runSpacing: Spacing.sm,
                          children: filteredTags.map((tagName) {
                            return FilterChip(
                              label: Text(tagName),
                              selected: _selectedTags.contains(tagName),
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.add(tagName);
                                  } else {
                                    _selectedTags.remove(tagName);
                                  }
                                  widget.onTagsChanged(
                                      _selectedTags.toList());
                                });
                              },
                            );
                          }).toList(),
                        ),
                      if (_selectedTags.isNotEmpty) ...[
                        const SizedBox(height: Spacing.md),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 36),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedTags.clear();
                                widget.onTagsChanged([]);
                              });
                            },
                            child: const Text('Clear all tags'),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
