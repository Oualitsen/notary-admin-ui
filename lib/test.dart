import 'package:notary_model/model/range.dart';
import 'package:notary_admin/src/pages/formula/contract_function_input_widget.dart';

void main() {
  List<Range> reorderRangeList(List<Range> ranges) {
    if (ranges.isNotEmpty)
      ranges.sort(((a, b) => b.upperBound.compareTo(a.upperBound)));
    return ranges;
  }

  Range range1 = Range(
      lowerBound: 0, upperBound: 10, percentage: 1, percentageCheck: true);
  Range range2 = Range(
      lowerBound: 10, upperBound: 20, percentage: 1, percentageCheck: true);
  List<Range> ranges = [range1, range2];
  //ranges.sort(((a, b) => a.upperBound.compareTo(b.upperBound)));
  ranges[0].upperBound;
  print(reorderRangeList(ranges)[0].upperBound);
}
