class ResourceLocationConfig {
  final String pathOrUrl;
  final Map<String, dynamic>? credentials; // e.g., {'username': 'user', 'password': 'pwd'} or {'apiKey': 'xyz'}

  ResourceLocationConfig({
    required this.pathOrUrl,
    this.credentials,
  });
}