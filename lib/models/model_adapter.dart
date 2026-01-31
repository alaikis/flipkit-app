abstract class ModelAdapter {
  /// Initialize the adapter with provider-specific config (apiKey, model, path...)
  Future<void> init(Map<String, dynamic> config);

  /// Generate text (non-streaming)
  Future<String> generate(String prompt, {Map<String, dynamic>? params});

  /// Generate text as a stream (useful for UI incremental rendering)
  Stream<String> generateStream(String prompt, {Map<String, dynamic>? params});

  /// Produce embeddings
  Future<List<double>> embed(String text, {Map<String, dynamic>? params});

  /// Close resources
  Future<void> close();
}
