import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/neighborhood_selection_model.dart';
import 'package:blocparty/view/widgets/ui/tokens.dart';

/// Compact neighborhood selector: a labeled dropdown with a link to manage
/// neighborhoods — no heavy card, no shouting buttons.
class NeighborhoodSelectionWidget extends StatefulWidget {
  // callback for when neighborhood selection changes
  final VoidCallback? onNeighborhoodChanged;

  const NeighborhoodSelectionWidget({super.key, this.onNeighborhoodChanged});

  @override
  State<NeighborhoodSelectionWidget> createState() =>
      _NeighborhoodSelectionWidgetState();
}

class _NeighborhoodSelectionWidgetState
    extends State<NeighborhoodSelectionWidget> {
  late NeighborhoodSelectionModel _neighborhoodModel;

  @override
  void initState() {
    super.initState();
    // Initialize the neighborhood model with callback
    _neighborhoodModel = NeighborhoodSelectionModel(
      onNeighborhoodChanged: widget.onNeighborhoodChanged,
    );
    _neighborhoodModel.addListener(_onModelChanged);
  }

  @override
  void dispose() {
    _neighborhoodModel.removeListener(_onModelChanged);
    super.dispose();
  }

  void _onModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Your neighborhood', style: theme.textTheme.labelSmall),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 32),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => context.push('/pick_neighborhood'),
                child: const Text('Manage'),
              ),
            ],
          ),
          _buildNeighborhoodDropdown(theme),
        ],
      ),
    );
  }

  // Widget to build the neighborhood dropdown with loading and error states
  Widget _buildNeighborhoodDropdown(ThemeData theme) {
    if (_neighborhoodModel.isLoading) {
      return Row(
        children: [
          SkeletonLine(width: 180, height: 20),
          const SizedBox(width: Spacing.md),
          Text(
            'Finding your neighbors…',
            style: theme.textTheme.bodySmall,
          ),
        ],
      );
    }

    if (_neighborhoodModel.error != null) {
      return Row(
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 18, color: theme.colorScheme.error),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              'Couldn’t load neighborhoods',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () => _neighborhoodModel.refresh(),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (_neighborhoodModel.userNeighborhoods.isEmpty) {
      return Text(
        'No neighborhoods yet — add one to start sharing.',
        style: theme.textTheme.bodyMedium,
      );
    }

    return DropdownButtonFormField<String>(
      // Use the getter for current neighborhood (first element in list)
      value: _neighborhoodModel.currentNeighborhood,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.md),
      ),
      items: _neighborhoodModel.userNeighborhoods.map((neighborhood) {
        return DropdownMenuItem(value: neighborhood, child: Text(neighborhood));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null &&
            newValue != _neighborhoodModel.currentNeighborhood) {
          _neighborhoodModel.setCurrentNeighborhood(newValue);
        }
      },
      isExpanded: true,
    );
  }
}
