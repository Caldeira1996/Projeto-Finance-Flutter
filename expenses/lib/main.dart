//import 'package:expenses/components/transaction_form.dart';
import 'package:expenses/api/api_services.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'components/transaction_form.dart';
import '/models/transaction.dart';
import 'components/transaction_list.dart';
import './components/chart.dart';
import 'login/login.dart';
import 'login/home_screen.dart';

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

  // Função para carregar as transações da API
  final ApiServices _apiServices = ApiServices(); // Chamando API

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    try {
      final transactions = await _apiServices.fetchTransactions();
      setState(() {
        _transactions.clear();
        _transactions.addAll(transactions);
      });
    } catch (e) {
      print('Erro ao carregar transações: $e');
    }
  }

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
      id: DateTime.now().millisecondsSinceEpoch.toString(), // garante ID unico
      title: title,
      value: value,
      date: date,
    );
    print('Enviando para API: ${newTransaction.toJson()}'); // DEBUG

    // VERIFICA SE A TRANSAÇÃO JÁ EXISTE NA LISTA PELO ID
    bool exists = _transactions.any((tr) => tr.id == newTransaction.id);
    if (exists) {
      print('Transação já existe, não será adicionada novamente.');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Esta transação já existe!')));
      return; // Evita duplicação
    }

    // Adiciona na lista local APÒS a verificação de duplicação
    setState(() {
      _transactions.add(newTransaction);
    });
    print('Adicionado localmente: ${newTransaction.toJson()}'); // DEBUG

    //Navigator.of(context).pop();

    try {
      await _apiServices
          .addTransaction(newTransaction); // chama api para add transação
      Navigator.of(context).pop(); //fecha o modal
    } catch (e) {
      //Se falhar, remove a transação da lista local e mostra a mensagem de erro
      setState(() {
        _transactions.remove(newTransaction);
      });
      print('Erro ao adicionar transação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar transação')),
      );
    }
  }

  //Função para remover transação
  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) {
        return tr.id == id;
      });
    });
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
