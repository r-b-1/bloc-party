import 'package:flutter/material.dart';

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
    if (oldWidget.availableTags != widget.availableTags) {
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
    final colorScheme = Theme.of(context).colorScheme;

    // Sort and deduplicate tags, then filter based on search text
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
        // Search Section
        Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              return TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search items',
                  hintText: 'Type to search by name...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchChanged('');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  widget.onSearchChanged(value);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Tag Filter Section
        Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ExpansionTile(
            title: const Text('Filter by Tags'),
            leading: const Icon(Icons.filter_list),
            initiallyExpanded: _isTagFilterExpanded,
            onExpansionChanged: (bool expanded) {
              setState(() {
                _isTagFilterExpanded = expanded;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tag Search Field
                    TextField(
                      controller: _tagSearchController,
                      decoration: const InputDecoration(
                        labelText: 'Search tags',
                        hintText: 'Type to filter tags...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    // Filtered Tags
                    if (filteredTags.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No tags found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
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
                                widget.onTagsChanged(_selectedTags.toList());
                              });
                            },
                            selectedColor: colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: colorScheme.primary,
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    // Clear All and Count Row
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedTags.clear();
                              widget.onTagsChanged([]);
                            });
                          },
                          child: const Text('Clear All'),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedTags.length} selected',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
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
