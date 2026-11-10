import 'package:flutter_test/flutter_test.dart';
import 'package:exp9/main.dart';

void main() {
  testWidgets('FirestoreUpdateApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FirestoreUpdateApp());
    await tester.pumpAndSettle();

    expect(find.text('Firestore Data Update'), findsOneWidget);
    expect(find.text('Karthik Raja'), findsOneWidget);
  });
}
