import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management_app/core/utils/validators.dart';

void main() {
  test('valid email returns null', () => expect(Validators.email('a@b.com'), isNull));
  test('invalid email returns error', () => expect(Validators.email('bad'), isNotNull));
  test('password requires six chars', () => expect(Validators.password('123'), isNotNull));
  test('mobile accepts international format', () => expect(Validators.mobile('+919876543210'), isNull));
}
