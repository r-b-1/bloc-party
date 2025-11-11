import 'package:flutter/material.dart';
import 'package:blocparty/model/neighborhood_selection_model.dart';

// widget that allows the user to select their current neighborhood from a dropdown
class NeighborhoodSelectionWidget extends StatefulWidget {
  // callback for when neighborhood selection changes
  final VoidCallback? onNeighborhoodChanged;
  
  const NeighborhoodSelectionWidget({super.key, this.onNeighborhoodChanged});

  @override
  State<NeighborhoodSelectionWidget> createState() => _NeighborhoodSelectionWidgetState();
}

class _NeighborhoodSelectionWidgetState extends State<NeighborhoodSelectionWidget> {
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Neighborhood Selection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildNeighborhoodDropdown(),
          ],
        ),
      ),
    );
  }

  // Widget to build the neighborhood dropdown with loading and error states
  Widget _buildNeighborhoodDropdown() {
    if (_neighborhoodModel.isLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading neighborhoods...'),
        ],
      );
    }

    if (_neighborhoodModel.error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error: ${_neighborhoodModel.error}',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _neighborhoodModel.refresh(),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (_neighborhoodModel.userNeighborhoods.isEmpty) {
      return const Text(
        'No neighborhoods available. Please contact support.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return DropdownButtonFormField<String>(
      // Use the getter for current neighborhood (first element in list)
      value: _neighborhoodModel.currentNeighborhood,
      decoration: const InputDecoration(
        labelText: 'Select Neighborhood',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _neighborhoodModel.userNeighborhoods.map((neighborhood) {
        return DropdownMenuItem(
          value: neighborhood,
          child: Text(neighborhood),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null && newValue != _neighborhoodModel.currentNeighborhood) {
          _neighborhoodModel.setCurrentNeighborhood(newValue);
        }
      },
      isExpanded: true,
    );
  }
}