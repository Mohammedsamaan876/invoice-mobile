class Formatters {
  Formatters._();

  static String formatCurrency(double amount, {String symbol = r'$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
