import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/utils.dart';
import 'tela_nova_senha_view.dart';

class RecuperaSenhaView extends StatefulWidget {
  const RecuperaSenhaView({super.key});

  @override
  State<RecuperaSenhaView> createState() => _RecuperaSenhaViewState();
}

class _RecuperaSenhaViewState extends State<RecuperaSenhaView> {
  final _emailController = TextEditingController();
  bool _carregando = false;

  Future<void> _enviarCodigo() async {
    setState(() => _carregando = true);
    try {
      final response = await http.post(
        Uri.parse('${Utils.ipServidor}/recuperaSenha'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailUsuario': _emailController.text}),
      );
      final dados = jsonDecode(response.body);
      final responseDados = dados['response'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseDados['mensagem'])),
      );
      if (responseDados['codigo'] == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TelaNovaSenhaView(email: _emailController.text),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Informe seu e-mail para receber o código de recuperação.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            if (_carregando)
              const CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enviarCodigo,
                  child: const Text('Enviar código'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
