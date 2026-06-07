import 'package:dailyflow/data/models/expense.dart';
import 'package:dailyflow/features/expenses/widgets/expense_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ExpenseForm cannot submit with empty amount', (tester) async {
    Expense? saved;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseForm(
            onSave: (e) => saved = e,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(saved, isNull);
    expect(find.text('Required'), findsWidgets);
  });

  testWidgets('ExpenseForm submits with valid data', (tester) async {
    Expense? saved;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseForm(
            onSave: (e) => saved = e,
          ),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Lunch',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '450',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(saved, isNotNull);
    expect(saved!.amount, 450);
    expect(saved!.description, 'Lunch');
  });
}
