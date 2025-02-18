import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

// Widget que exibe a lista de transações
class TransactionList extends StatelessWidget {
  final List<Transaction> transactions; // Lista de transações recebida
  final void Function(String) onRemove; // Função para remover uma transação

  // Construtor da classe TransactionList
  const TransactionList(this.transactions, this.onRemove, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty // Verifica se a lista está vazia
        ? Column(
            children: [
              const SizedBox(height: 20), // Espaçamento
              Text(
                'Nenhuma Transação Cadastrada!', // Mensagem de aviso
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20), // Espaçamento
              SizedBox(
                height: 200, // Altura da imagem
                child: Image.asset(
                  'assets/images/waiting.png', // Imagem padrão quando não há transações
                  fit: BoxFit.cover,
                ),
              ),
            ],
          )
        : ListView.builder(
            itemCount: transactions.length, // Número de itens na lista
            itemBuilder: (ctx, index) {
              final tr = transactions[index]; // Obtém a transação atual
              return Card(
                elevation: 5, // Sombra no card
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 5,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Colors.purple, // Cor de fundo do avatar
                      radius: 30, // Define o tamanho do círculo
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: FittedBox(
                          child: Text(
                            'R\$${tr.value}', // Exibe o valor da transação
                            style: const TextStyle(
                              color: Colors.white, // Cor do texto
                            ),
                          ),
                        ),
                      )),
                  title: Text(
                    tr.title, // Exibe o título da transação
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                  ),
                  subtitle: Text(
                    DateFormat('d MMM y')
                        .format(tr.date), // Exibe a data formatada
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete), // Ícone de lixeira
                    color: Theme.of(context).colorScheme.error, // Cor do ícone
                    onPressed: () => onRemove(
                        tr.id), // Chama a função para remover a transação
                  ),
                ),
              );
            },
          );
  }
}
