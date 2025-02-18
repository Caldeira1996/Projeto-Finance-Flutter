import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as cors;
import 'dart:convert' as convert;

Future<MySqlConnection> connectToDatabase() async {
  try {
    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'root',
        password: '123456',
        db: 'expenses_app',
      ),
    );
    print('Database Connected successfully.');
    return conn;
  } catch (e) {
    print('Database connection error: $e');
    rethrow;
  }
}

void main() async {
  final router = Router();
  final conn = await connectToDatabase();

  // Rota para buscar todas as transações
  router.get('/transactions', (Request request) async {
    try {
      final results =
          await conn.query('SELECT * FROM transactions ORDER BY date DESC');
      final List<Map<String, dynamic>> transactions = [];

      for (var row in results) {
        transactions.add({
          'id': row['id'],
          'title': row['title'],
          'value': row['value'],
          'date':
              row['date'].toString(), // Ajuste para o formato correto da data
        });
      }

      print('Transações recuperadas: ${transactions.length}');
      return Response.ok(
        json.encode({'transactions': transactions}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      print('Erro ao buscar transações: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Erro ao buscar transações: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  router.post('/add_transaction', (Request request) async {
    try {
      final payload = await request.readAsString();
      print('Payload recebido: $payload'); // Log do payload

      final data = jsonDecode(payload);

      if (data['title'] == null ||
          data['value'] == null ||
          data['date'] == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Todos os campos são obrigatórios'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final String title = data['title'].toString();
      final double value = double.parse(data['value'].toString());
      final String dateString = data['date'];

      // Convertendo a data para DateTime e ajustando para UTC
      DateTime dateTime = DateTime.parse(dateString).toUtc();

      if (title.isEmpty) {
        return Response.badRequest(
          body: json.encode({'error': 'O título não pode estar vazio'}),
          headers: {'content-type': 'application/json'},
        );
      }

      // Inserção no banco de dados
      await conn.query(
        'INSERT INTO transactions (title, value, date) VALUES (?, ?, ?)',
        [title, value, dateTime],
      );

      print('Transação inserida: $title, $value, $dateTime');

      return Response.ok(
        json.encode({
          'message': 'Transação adicionada com sucesso',
          'data': {
            'title': title,
            'value': value,
            'date': dateTime
                .toIso8601String(), // Formatando a data para uma string legível
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      print('Erro ao processar transação: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Erro ao adicionar transação: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // Configuração do CORS
  var handler = const Pipeline()
      .addMiddleware(cors.corsHeaders(headers: {
        'Access-Control-Allow-Origin': '*', // Permitir qualquer origem
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type',
      }))
      .addHandler(router);

  // Servir o servidor na porta 8080
  await shelf_io.serve(handler, 'localhost', 8080);
  print('Servidor rodando em http://localhost:8080');
}
