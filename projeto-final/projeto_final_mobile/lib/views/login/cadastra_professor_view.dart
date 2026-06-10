import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/utils.dart';

class CadastraProfessorView extends StatefulWidget {
  const CadastraProfessorView({super.key});

  @override
  State<CadastraProfessorView> createState() => _CadastraProfessorViewState();
}

class _CadastraProfessorViewState extends State<CadastraProfessorView> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  Future<void> _cadastrar() async {
    setState(() => _carregando = true);
    try {
      final response = await http.post(
        Uri.parse('${Utils.ipServidor}/cadastrarProfessor'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomeProfessor': _nomeController.text,
          'cpfProfessor': _cpfController.text,
          'emailProfessor': _emailController.text,
          'telefoneProfessor': _telefoneController.text,
          'senhaProfessor': _senhaController.text,
        }),
      );
      if (!mounted) return;
      final dados = jsonDecode(response.body);
      final responseDados = dados['response'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseDados['mensagem'])),
      );
      if (responseDados['codigo'] == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Professor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cpfController,
              decoration: const InputDecoration(labelText: 'CPF', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefoneController,
              decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_carregando)
              const CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cadastrar,
                  child: const Text('Cadastrar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
