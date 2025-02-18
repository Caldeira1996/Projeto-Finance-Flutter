import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class ApiServices {
  final String baseUrl = 'http://10.0.2.2:8080'; // ajustar conforme ambiente

  Future<List<Transaction>> fetchTransactions() async {
    final response = await http.get(Uri.parse("$baseUrl/get_transactions"));

    if (response.statusCode == 200) {
      print(response.body); // inspeção de dados retornados pela API

      List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          "Falha ao carregar transações. Status: ${response.statusCode}");
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add_transaction"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(transaction.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao adicionar transação: ${response.body}");
    }
  }
}
