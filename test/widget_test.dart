// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/todo_page.dart';
import 'package:todo_app/notes_page.dart';

void main() {
  testWidgets('Ana sayfa testi', (WidgetTester tester) async {
    // Uygulamayı başlat
    await tester.pumpWidget(const MyApp());

    // Ana sayfada BottomNavigationBar'ın varlığını kontrol et
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // İlk sekmenin (TodoPage) aktif olduğunu kontrol et
    expect(find.byType(TodoPage), findsOneWidget);

    // İkinci sekmeye (NotesPage) geçiş yap
    await tester.tap(find.byIcon(Icons.note));
    await tester.pumpAndSettle();

    // İkinci sekmenin (NotesPage) aktif olduğunu kontrol et
    expect(find.byType(NotesPage), findsOneWidget);
  });

  testWidgets('TodoPage testi', (WidgetTester tester) async {
    // Uygulamayı başlat
    await tester.pumpWidget(const MaterialApp(home: TodoPage()));

    // TextField'ı bul ve bir değer gir
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Test yapılacak');
    await tester.pump();

    // Ekle butonuna tıkla
    final addButton = find.widgetWithText(ElevatedButton, 'Ekle');
    await tester.tap(addButton);
    await tester.pump();

    // Listede eklenen öğeyi kontrol et
    expect(find.text('Test yapılacak'), findsOneWidget);

    // Silme butonuna tıkla
    final deleteButton = find.byIcon(Icons.delete);
    await tester.tap(deleteButton);
    await tester.pump();

    // Listenin boş olduğunu kontrol et
    expect(find.text('Test yapılacak'), findsNothing);
  });

  testWidgets('NotesPage testi', (WidgetTester tester) async {
    // Uygulamayı başlat
    await tester.pumpWidget(const MaterialApp(home: NotesPage()));

    // TextField'ı bul ve bir değer gir
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Test notu');
    await tester.pump();

    // Ekle butonuna tıkla
    final addButton = find.widgetWithText(ElevatedButton, 'Ekle');
    await tester.tap(addButton);
    await tester.pump();

    // Listede eklenen öğeyi kontrol et
    expect(find.text('Test notu'), findsOneWidget);

    // Silme butonuna tıkla
    final deleteButton = find.byIcon(Icons.delete);
    await tester.tap(deleteButton);
    await tester.pump();

    // Listenin boş olduğunu kontrol et
    expect(find.text('Test notu'), findsNothing);
  });
}
