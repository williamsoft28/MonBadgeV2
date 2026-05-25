void main() {
  try {
    final uri = Uri.parse(' https://example.com/api/auth/login');
    print('Host: ${uri.host}');
    print('Scheme: ${uri.scheme}');
    print('Full: $uri');
  } catch (e) {
    print('Error: $e');
  }
}
