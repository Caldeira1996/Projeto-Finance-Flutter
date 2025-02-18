class Transaction {
  final String id;
  final String title;
  final double value;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
  });

  // fromJson para criar a transação a partir de um mapa (JSON)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String, // Pega o valor real do JSON
      title: json['title'] as String,
      value: (json['value'] as num).toDouble(), // Garante conversão para double
      date: DateTime.parse(json['date'] as String), // Converte para DateTime
    );
  }

  // Método para converter um objeto transaction para um mapa (para envio via HTTP)
  Map<String, dynamic> toJson() {
    return {
      'id': id, // id para gerar no app mobile
      'title': title,
      'value': value,
      'date': date.toIso8601String(),
    };
  }
}
