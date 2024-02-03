class PortfolioJsonChunk implements Comparable<PortfolioJsonChunk> {
  const PortfolioJsonChunk({
    required this.index,
    required this.totalChunks,
    required this.chunk,
  });
  final int index;
  final int totalChunks;
  final String chunk;

  static var empty = const PortfolioJsonChunk(index: -1, totalChunks: 0, chunk: '');

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['index'] = index;
    data['totalChunks'] = totalChunks;
    data['chunk'] = chunk;
    return data;
  }

  PortfolioJsonChunk.fromJson(Map<String, dynamic> json)
      : index = json['index'],
        totalChunks = json['totalChunks'],
        chunk = json['chunk'];

  @override
  int compareTo(PortfolioJsonChunk other) {
    if (index < other.index) {
      return -1;
    } else if (index > other.index) {
      return 1;
    } else {
      return 0;
    }
  }
}
