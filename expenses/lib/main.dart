import 'package:expenses/bd/bd.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'components/transaction_form.dart';
import '/models/transaction.dart';
import 'components/transaction_list.dart';
import './components/chart.dart';
import 'login/login.dart';
import 'login/home_screen.dart';
import 'bd/bd.dart';
import 'package:http/http.dart';
//import 'package:sqflite/sql.dart' hide Transaction;

void main() => runApp(const ExpensesApp());

class ExpensesApp extends StatelessWidget {
  const ExpensesApp({Key? key}) : super(key: key);
  //final ThemeData tema = ThemeData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login', //Define a tela inicial para login
      routes: {
        '/login': (context) => Login(), //Tela de login
        '/home': (context) => MyHomePage(),
      },
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Quicksand',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          primary: Colors.purple,
          secondary: Colors.amber,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          labelLarge: TextStyle(
            // Botões
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];

  // Função para carregar as transações do banco de dados local
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  //Função para carregar as transações do banco de dados local
  void _loadTransactions() async {
    try {
      final transactions = await DatabaseHelper.instance.getTransactions();
      setState(() {
        _transactions.clear();
        _transactions.addAll(transactions);
      });
    } catch (e) {
      print('Erro ao carregar transações: $e');
    }
  }

  // void _loadApiTransactions() async {
  //   try {
  //     final apiTransactions = await _apiServices.fetchTransactions();
  //     // Atualiza localmente com os dados da API
  //     for (var transaction in apiTransactions) {
  //       await DatabaseHelper.instance.insertTransaction(transaction);
  //     }
  //     _loadTransactions(); // Recarrega do banco local
  //   } catch (e) {
  //     print('Erro ao carregar transações da API: $e');
  //   }
  // }

  // Função para filtrar as transações recentes
  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        const Duration(days: 7),
      )); // filtra transação dos últimos 7 dias
    }).toList();
  }

  // Função para adicionar transação
  void _addTransaction(String title, double value, DateTime date) async {
    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      value: value,
      date: date,
    );

    try {
      // primeiro salva localmente
      await DatabaseHelper.instance.insertTransaction(newTransaction);

      setState(() {
        _transactions.add(newTransaction);
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transação adicionada com sucesso!')),
      );
    } catch (e) {
      print('Erro ao salvar localmente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar transação: ${e.toString}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //Função para remover transação
  void _removeTransaction(String id) async {
    try {
      //Remove localmente do banco de dados
      await DatabaseHelper.instance.deleteTransaction(id);
      setState(() {
        _transactions.removeWhere((tr) => tr.id == id);
      });
    } catch (e) {
      print('Erro ao remover a transação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover transação!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Função para abrir o formulário de transação
  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('Despesas pessoais'),
      actions: [
        IconButton(
          onPressed: () => _openTransactionFormModal(context),
          icon: const Icon(Icons.add),
        ),
      ],
    );

    // Adicionando Media query
    final availableHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Nome de usuário'),
              accountEmail: Text('email@dominio.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.purple),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context); //Fecha o menu
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pop(context); //Fecha o menu
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, '/login'); // volta para o login
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: availableHeight * 0.23,
              child: Chart(_recentTransactions),
            ),
            SizedBox(
              height: availableHeight * 0.6,
              child: TransactionList(_transactions, _removeTransaction),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_shopping_cart_sharp),
        onPressed: () => _openTransactionFormModal(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
