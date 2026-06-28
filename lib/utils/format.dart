/// Formats an amount as Ugandan Shillings, e.g. `UGX 45,000`.
/// UGX is conventionally shown without decimal places.
String fmtUgx(num amount) {
  final rounded = amount.round();
  final digits = rounded.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return 'UGX ${rounded < 0 ? '-' : ''}$buf';
}
