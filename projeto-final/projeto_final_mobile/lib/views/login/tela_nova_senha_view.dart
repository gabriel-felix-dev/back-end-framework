import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/utils.dart';
import 'login_view.dart';

class TelaNovaSenhaView extends StatefulWidget {
  final String email;

  const TelaNovaSenhaView({super.key, required this.email});

  @override
  State<TelaNovaSenhaView> createState() => _TelaNovaSenhaViewState();
}

class _TelaNovaSenhaViewState extends State<TelaNovaSenhaView> {
  final _codigoController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _carregando = false;

  Future<void> _atualizarSenha() async {
    if (_novaSenhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }
    setState(() => _carregando = true);
    try {
      final response = await http.put(
        Uri.parse('${Utils.ipServidor}/atualizaSenha'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailUsuario': widget.email,
          'novaSenha': _novaSenhaController.text,
          'codigoRecuperacao': int.tryParse(_codigoController.text) ?? 0,
        }),
      );
      final dados = jsonDecode(response.body);
      final responseDados = dados['response'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseDados['mensagem'])),
      );
      if (responseDados['codigo'] == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
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
    _codigoController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Senha')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Informe o código recebido por e-mail e crie uma nova senha.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codigoController,
              decoration: const InputDecoration(
                labelText: 'Código de recuperação',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _novaSenhaController,
              decoration: const InputDecoration(
                labelText: 'Nova senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmarSenhaController,
              decoration: const InputDecoration(
                labelText: 'Confirmar nova senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_carregando)
              const CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _atualizarSenha,
                  child: const Text('Atualizar senha'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
