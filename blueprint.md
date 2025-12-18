
# Project Blueprint

## Overview

This document outlines the plan for creating a Flutter application with a focus on a modern, visually appealing design and a flexible theme system. The application will feature a simple UI with a theme toggle to switch between light and dark modes.

## Features

*   **Theme Management:** The application will use the `provider` package to manage the theme state, allowing users to switch between light and dark themes.
*   **Custom Fonts:** The `google_fonts` package will be used to incorporate custom fonts for a unique and polished look.
*   **Material Design 3:** The application will adhere to Material Design 3 principles, using `ColorScheme.fromSeed` to generate harmonious color palettes.
*   **Component Theming:** The theme will be customized for specific components like `AppBar` and `ElevatedButton` to ensure a consistent look and feel.

## Plan

1.  **Add Dependencies:** Add the `provider` and `google_fonts` packages to the `pubspec.yaml` file.
2.  **Create `lib/main.dart`:** Create the main application file with the following components:
    *   A `ThemeProvider` class to manage the theme state.
    *   A `MyApp` widget to build the `MaterialApp` with the light and dark themes.
    *   A `MyHomePage` widget to display the UI with a theme toggle.
3.  **Fix Android Configuration:** Run the necessary commands to fix the Android configuration issues.
4.  **Run the Application:** Run the application to ensure that it builds and runs correctly.
