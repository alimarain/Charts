import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chart_interaction.dart';

class ChartInteractionState {
  const ChartInteractionState({
    this.selectedItem,
  });

  final SelectedChartItem? selectedItem;

  bool isSelected(String chartId, int index) {
    return selectedItem != null &&
        selectedItem!.chartId == chartId &&
        selectedItem!.dataIndex == index;
  }

  ChartInteractionState copyWith({
    SelectedChartItem? selectedItem,
    bool clearSelection = false,
  }) {
    return ChartInteractionState(
      selectedItem: clearSelection ? null : (selectedItem ?? this.selectedItem),
    );
  }
}

final chartInteractionProvider =
    NotifierProvider<ChartInteractionNotifier, ChartInteractionState>(
  ChartInteractionNotifier.new,
);

class ChartInteractionNotifier extends Notifier<ChartInteractionState> {
  @override
  ChartInteractionState build() {
    return const ChartInteractionState();
  }

  void selectItem(SelectedChartItem item) {
    state = state.copyWith(selectedItem: item);
  }

  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }
}