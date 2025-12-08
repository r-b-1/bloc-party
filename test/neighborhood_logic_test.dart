import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Neighborhood list reordering logic', () {
    // Tests the core neighborhood reordering logic
    List<String> reorderNeighborhoods(List<String> currentList, String neighborhoodToMakeCurrent) {
      if (!currentList.contains(neighborhoodToMakeCurrent)) {
        return currentList;
      }
      
      final newList = [neighborhoodToMakeCurrent];
      for (final neighborhood in currentList) {
        if (neighborhood != neighborhoodToMakeCurrent) {
          newList.add(neighborhood);
        }
      }
      return newList;
    }

    final neighborhoods = ['neighborhood1', 'neighborhood2', 'neighborhood3'];
    
    final reordered = reorderNeighborhoods(neighborhoods, 'neighborhood2');
    
    expect(reordered[0], 'neighborhood2');
    expect(reordered[1], 'neighborhood1');
    expect(reordered[2], 'neighborhood3');
  });
}