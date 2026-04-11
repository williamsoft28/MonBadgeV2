import 'package:flutter/material.dart';

class Helpers {
  // Formater une date
  // 2024-03-28 → 28/03/2024
  static String formatDate(String date) {
    final parts = date.split('-');
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  // Formater une heure
  // 08:00:00 → 08h00
  static String formatHeure(String heure) {
    final parts = heure.split(':');
    return '${parts[0]}h${parts[1]}';
  }

  // Afficher un message d'erreur
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Afficher un message de succès
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}