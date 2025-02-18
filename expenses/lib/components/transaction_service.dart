import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  var settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: '123456',
    db: 'expenses_app',
  );

  var conn = await MySqlConnection.connect(settings);

  final router = Router();

  // Rota de GET - buscar
  router.get('/get_transactions', (Request request) async {
    try {
      var results = await conn.query('SELECT * FROM transactions');
      var transactions = results.map((row) {
        return {
          'id': row[0],
          'title': row[1],
          'value': row[2],
          'date': row[3].toString(),
        };
      }).toList();

      return Response.ok(
        json.encode(transactions),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Erro ao buscar transações $e'}),
      );
    }
  });

  // Rota POST - add
  router.post('/add_transaction', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);

      await conn.query(
        'INSERT INTO transactions (title, value, date) VALUES (?,?,?)',
        [data['title'], data['value'], DateTime.parse(data['date'])],
      );

      return Response.ok(
          json.encode({'message': 'Transação adicionada com sucesso'}));
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Erro ao adicionar transação: $e'}),
      );
    }
  });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  await shelf_io.serve(handler, '0.0.0.0', 8080);
  print('Servidor rodando em http://localhost:8080');
}
