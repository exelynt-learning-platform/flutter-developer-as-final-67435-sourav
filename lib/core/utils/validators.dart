class Validators {
  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
    return valid ? null : 'Enter a valid email';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile is required';
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.trim())) {
      return 'Enter a valid mobile number';
    }
    return null;
  }
}
