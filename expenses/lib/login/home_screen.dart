import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  //const HomeScreen({super.key});
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de login'),
        backgroundColor: Colors.purple,
        actions: [
          //Botão de logoff APPBAR
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              //Ação de logoff
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //LOGO - centralizada

              // espaçamento entre LOGO e CAMPO DE USUARIO
              const SizedBox(height: 40),

              // CAMPO DE USUÁRIO
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  labelStyle: TextStyle(color: Colors.purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.purple,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),

              //Campo de senha
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(
                    color: Colors.purple,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(
                height: 40,
              ),

              //Botão de login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  //Validação de login
                  if (_usernameController.text == 'admin' &&
                      _passwordController.text == '1234') {
                    Navigator.restorablePushReplacementNamed(context, '/home');
                  } else {
                    // Exibe a mensagem campo vazio
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Credenciais inválidas')),
                    );
                  }
                },
                child: const Text(
                  "Entrar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              //Esqueceu a senha?
              TextButton(
                onPressed: () {
                  //Ação para recuperar a senha
                },
                child: const Text(
                  'Esqueceu a senha?',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
              const SizedBox(height: 20),

              // REGISTRAR NOVA CONTA
              TextButton(
                onPressed: () {
                  // Ação para registrar nova conta
                },
                child: const Text(
                  'Não tem uma conta? Registre-se',
                ),
              ),

              // Botão de logoff (Depois do login)
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  //Ação de logoff(voltar a tela de login)
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // cor de fundo do botão
                    foregroundColor: Colors.white, // cor do texto
                    padding: EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5),
                child: const Text(
                  'Sair',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
