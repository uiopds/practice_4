/// Расчёт цены с учётом скидки
double calculateDiscountedPrice(double originalPrice, double discountPercent) {
  if (originalPrice < 0) {
    throw ArgumentError('Цена не может быть отрицательной');
  }
  if (discountPercent < 0 || discountPercent > 100) {
    throw ArgumentError('Скидка должна быть в диапазоне от 0 до 100%');
  }

  final discountAmount = originalPrice * (discountPercent / 100);
  return originalPrice - discountAmount;
}