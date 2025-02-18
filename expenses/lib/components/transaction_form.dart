import 'package:flutter/material.dart'; // Importa a biblioteca Material do Flutter, que contém widgets e temas para criar interfaces.
import 'package:intl/intl.dart'; // Importa a biblioteca intl para formatação de datas.

class TransactionForm extends StatefulWidget {
  final void Function(String, double, DateTime)
      onSubmit; // Declara um callback para o envio do formulário (recebe título, valor e data).

  TransactionForm(this.onSubmit, {Key? key})
      : super(key: key); // Construtor que inicializa o callback onSubmit.

  @override
  State<TransactionForm> createState() =>
      _TransactionFormState(); // Cria o estado do formulário (TransactionFormState).
}

class _TransactionFormState extends State<TransactionForm> {
  final _titleController =
      TextEditingController(); // Controlador para o campo de texto do título.
  final _valueController =
      TextEditingController(); // Controlador para o campo de texto do valor.
  DateTime? _selectedDate = DateTime
      .now(); // Variável para armazenar a data selecionada (inicialmente a data atual).

  _submitForm() {
    // Função que será chamada quando o formulário for enviado.
    final title =
        _titleController.text; // Obtém o título inserido no campo de texto.
    final value = double.tryParse(_valueController.text) ??
        0.0; // Tenta converter o valor inserido em double; se falhar, atribui 0.0.

    if (title.isEmpty || value <= 0 || _selectedDate == null) {
      // Verifica se os dados são válidos.
      return; // Se algum dado estiver inválido, retorna sem fazer nada.
    }

    widget.onSubmit(title, value,
        _selectedDate!); // Chama o callback onSubmit com os dados válidos.
  }

  _showDatePicker() {
    // Função para exibir o seletor de data.
    showDatePicker(
      context: context,
      initialDate:
          DateTime.now(), // A data inicial no seletor será a data atual.
      firstDate: DateTime(2019), // A primeira data que pode ser selecionada.
      lastDate: DateTime.now(), // A última data que pode ser selecionada.
    ).then((pickedDate) {
      // Quando uma data for selecionada...
      if (pickedDate == null) {
        // Se nenhuma data for selecionada...
        return; // Retorna sem fazer nada.
      }

      setState(() {
        // Atualiza o estado para refletir a nova data selecionada.
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Método build que retorna a interface do formulário.
    return Card(
      // Cria um card para conter o formulário.
      elevation: 5, // Define a elevação do card, criando um efeito de sombra.
      child: Padding(
        // Adiciona um preenchimento interno ao card.
        padding: const EdgeInsets.all(
            10), // Define o espaço interno de 10 pixels ao redor do conteúdo.
        child: Column(
          // Cria uma coluna para empilhar os widgets.
          children: <Widget>[
            TextField(
              // Campo de texto para o título da transação.
              controller:
                  _titleController, // Controlador para pegar o valor do campo.
              onSubmitted: (_) =>
                  _submitForm(), // Chama a função _submitForm ao pressionar enter.
              style: TextStyle(
                fontSize: 20, // Define o tamanho da fonte.
                fontFamily: 'OpenSans', // Define a família da fonte.
              ),
              decoration: InputDecoration(
                labelText: 'Título', // Define o texto do rótulo do campo.
              ),
            ),
            TextField(
              // Campo de texto para o valor da transação.
              controller:
                  _valueController, // Controlador para pegar o valor do campo.
              keyboardType: const TextInputType.numberWithOptions(
                  decimal:
                      true), // Define o tipo de teclado para valores numéricos.
              onSubmitted: (_) =>
                  _submitForm(), // Chama a função _submitForm ao pressionar enter.
              style: TextStyle(
                fontSize: 20, // Define o tamanho da fonte.
                fontFamily: 'OpenSans', // Define a família da fonte.
              ),
              decoration: const InputDecoration(
                labelText:
                    'Valor (R\$)', // Define o texto do rótulo para o campo de valor.
              ),
            ),
            SizedBox(
              // Cria um espaço de 70 pixels de altura para exibir a data selecionada.
              height: 70,
              child: Row(
                // Cria uma linha para exibir a data e o botão de selecionar data.
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Nenhuma data selecionada!' // Exibe uma mensagem se nenhuma data for selecionada.
                          : 'Data Selecionada: ${DateFormat('dd/MM/y').format(_selectedDate!)}', // Exibe a data formatada.
                    ),
                  ),
                  TextButton(
                    // Botão para abrir o seletor de data.
                    child: const Text(
                      'Selecionar Data', // Texto do botão.
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold, // Estilo do texto do botão.
                      ),
                    ),
                    onPressed:
                        _showDatePicker, // Chama a função para exibir o seletor de data.
                  )
                ],
              ),
            ),
            Row(
              // Cria uma linha para o botão de envio do formulário.
              mainAxisAlignment:
                  MainAxisAlignment.end, // Alinha o botão à direita.
              children: <Widget>[
                ElevatedButton(
                  // Botão para enviar a transação.
                  child: const Text(
                    'Nova Transação', // Texto do botão.
                    style: TextStyle(
                      color: Colors.white, // Cor do texto.
                      fontWeight: FontWeight.bold, // Estilo do texto.
                    ),
                  ),
                  onPressed:
                      _submitForm, // Chama a função _submitForm ao pressionar o botão.
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
