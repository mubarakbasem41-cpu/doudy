/// يكتب المبلغ بالجنيه السوداني مع فواصل الآلاف: 4500 -> "4,500 ج.س"
String formatSdg(num value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '$buf ج.س';
}
