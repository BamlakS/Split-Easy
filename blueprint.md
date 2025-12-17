# SplitEasy Blueprint

## Overview

SplitEasy is a Flutter mobile application designed to simplify expense tracking for roommates. It allows users to add expenses, specify how they are split, and view balances to see who owes whom. The app will be built with a clean, minimalist design and a user-friendly interface.

This document outlines the project's architecture, design guidelines, and feature implementation plan.

## Style, Design, and Features

### Version 1.0 (Initial Setup)

*   **State Management:** Provider for state management, using in-memory lists for local state.
*   **Data Model:** A simple `Expense` class to represent an expense.
*   **Design:**
    *   **Primary Color:** `#A7DBD8` (light teal)
    *   **Background Color:** `#F0F8F7` (very pale teal)
    *   **Accent Color:** `#E89A49` (soft orange)
    *   **Font:** PT Sans
*   **Home Screen:**
    *   App title "SplitEasy".
    *   Navigation buttons: "Add Expense", "View Expenses", "See Balances".
    *   Minimalist layout with the specified color scheme.

### Version 1.1 (Add Expense)

*   **Add Expense Screen:**
    *   Form for adding a new expense with fields for description, amount, who paid, date, and how to split the expense.
    *   Includes validation to ensure the split amounts equal the total expense amount.
    *   Saves the expense to the in-memory list and displays a success message.
*   **Split Equally Feature:**
    *   Adds a "Split Equally" button to the Add Expense screen.
    *   When clicked, the total expense amount is divided equally among the selected roommates.
    *   The calculated amounts are auto-filled into the corresponding fields, with any remainder added to the first person's share.

### Version 1.2 (View Expenses)

*   **View Expenses Screen:**
    *   Displays a list of all expenses, with the most recent first.
    *   Shows a message if no expenses have been added.
    *   Each expense is displayed on a card with a light shadow, showing the description, amount, who paid, date, and how the expense is split.

### Version 1.3 (See Balances)

*   **See Balances Screen:**
    *   Calculates the net balance for each roommate.
    *   Displays each roommate's balance on a separate card, indicating whether they owe money, are owed money, or are settled up.
    *   Uses colors and icons to clearly distinguish between a positive, negative, and zero balance.

## Current Plan

### Add "Split Equally" Feature

1.  **Update `add_expense_screen.dart`:** Add the "Split Equally" button to the UI.
2.  **Implement Logic:** Create the `_splitEqually` function to calculate and distribute the expense amount.
3.  **Test:** Verify that the feature works as expected.
