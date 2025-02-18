import 'package:expenses/models/transaction.dart'; // Importa o modelo Transaction (transação) para ser usado nas transações financeiras.
import 'package:intl/intl.dart'; // Importa a biblioteca intl para formatação de datas.
import 'package:flutter/material.dart'; // Importa a biblioteca Material do Flutter para criação da interface.
import 'chart_bar.dart'; // Importa o widget ChartBar, que é utilizado para exibir as barras do gráfico.

class Chart extends StatelessWidget {
  final List<Transaction>
      recentTransaction; // Recebe a lista de transações recentes que será exibida no gráfico.

  const Chart(this.recentTransaction, {Key? key})
      : super(
            key:
                key); // Construtor que inicializa o widget com as transações recentes.

  // Calcula as transações agrupadas por dia da semana (últimos 7 dias).
  List<Map<String, Object>> get groupedTransactions {
    return List.generate(7, (index) {
      // Gera uma lista de 7 dias.
      final weekDay = DateTime.now().subtract(
        // Obtém o dia da semana para o índice atual (últimos 7 dias).
        Duration(days: index),
      );

      double totalSum =
          0.0; // Variável para armazenar o total das transações de um dia.

      // Itera sobre as transações e soma os valores que coincidem com o dia da semana atual.
      for (var i = 0; i < recentTransaction.length; i++) {
        bool sameDay = recentTransaction[i].date.day == weekDay.day;
        bool sameMonth = recentTransaction[i].date.month == weekDay.month;
        bool sameYear = recentTransaction[i].date.year == weekDay.year;

        if (sameDay && sameMonth && sameYear) {
          totalSum += recentTransaction[i]
              .value; // Soma o valor das transações que ocorreram no mesmo dia.
        }
      }

      return {
        // Retorna o dia e o total acumulado de transações desse dia.
        'day': DateFormat.E().format(
            weekDay)[0], // Formata o nome do dia da semana (primeira letra).
        'value': totalSum, // Valor total das transações do dia.
      };
    })
        .reversed
        .toList(); // Reverte a lista para exibir os dias em ordem cronológica.
  }

  // Calcula o valor total das transações da semana.
  double get _weekTotalValue {
    return groupedTransactions.fold(0.0, (sum, tr) {
      // Soma os valores das transações de todos os dias.
      return sum + (tr['value'] as double); // Acumula o valor total.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // Cria um cartão para exibir o gráfico.
      elevation: 6, // Define a elevação do cartão, criando um efeito de sombra.
      margin: const EdgeInsets.all(20), // Define a margem ao redor do cartão.
      child: Padding(
        // Adiciona preenchimento interno ao cartão.
        padding: const EdgeInsets.all(10),
        child: Row(
          // Cria uma linha para organizar as barras de gráfico.
          mainAxisAlignment: MainAxisAlignment
              .spaceAround, // Alinha as barras de forma uniforme na linha.
          children: groupedTransactions.map((tr) {
            // Itera sobre as transações agrupadas por dia.
            return Flexible(
              // Faz as barras flexíveis para que se ajustem ao espaço disponível.
              fit: FlexFit
                  .tight, // As barras vão preencher igualmente o espaço disponível.
              child: ChartBar(
                // Para cada transação, cria uma barra no gráfico.
                label: tr['day']
                    as String, // Define o rótulo da barra como o dia da semana.
                value: tr['value']
                    as double, // Define o valor total da barra para aquele dia.
                percentage: _weekTotalValue == 0
                    ? 0 // Se o total da semana for zero, evita divisão por zero.
                    : (tr['value'] as double) /
                        _weekTotalValue, // Calcula a porcentagem do valor daquele dia em relação ao total da semana.
              ),
            );
          }).toList(), // Converte o resultado em uma lista e cria as barras.
        ),
      ),
    );
  }
}
