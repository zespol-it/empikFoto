# Empik Foto - Kreator Fotoksiążki

## Opis projektu
Empik Foto to prosta aplikacja iOS, która umożliwia tworzenie kolaży z wybranych zdjęć. Użytkownik może wybrać do 6 zdjęć z galerii, podglądać je w formie siatki, a następnie zapisać wygenerowany kolaż do galerii.

## Funkcjonalności
- Wybór do 6 zdjęć z galerii.
- Podgląd wybranych zdjęć w formie siatki.
- Generowanie kolażu (układ 3x2) i zapis do galerii.
- Prosty, intuicyjny interfejs użytkownika.

## Diagram
```
┌─────────────────────────────────────────────┐
│                                             │
│  +---------------------------------------+  │
│  |           Kreator Fotoksiążki         |  │
│  +---------------------------------------+  │
│  |                                       |  │
│  |  +-------------------------------+    |  │
│  |  |      Wybierz zdjęcia         |    |  │
│  |  +-------------------------------+    |  │
│  |                                       |  │
│  |  +-------------------------------+    |  │
│  |  |      Podgląd kolażu          |    |  │
│  |  |  [Z1] [Z2] [Z3]              |    |  │
│  |  |  [Z4] [Z5] [Z6]              |    |  │
│  |  +-------------------------------+    |  │
│  |                                       |  │
│  |  +-------------------------------+    |  │
│  |  |      Zapisz kolaż            |    |  │
│  |  +-------------------------------+    |  │
│  |                                       |  │
│  +---------------------------------------+  │
│                                             │
└─────────────────────────────────────────────┘
```

## Technologie
- Swift, SwiftUI
- PhotosUI (do wyboru zdjęć)
- XCTest (testy jednostkowe)

## Wymagania
- Xcode 16.3 lub nowszy
- iOS 17.0 lub nowszy

## Instrukcja uruchomienia
1. Otwórz projekt w Xcode.
2. Wybierz symulator lub urządzenie docelowe.
3. Uruchom aplikację (⌘R).
4. Wybierz zdjęcia z galerii, podglądaj kolaż i zapisz go.

## Testy
Aby uruchomić testy, wybierz schemat testowy w Xcode i naciśnij ⌘U.

## Autor
Empik Foto Team 