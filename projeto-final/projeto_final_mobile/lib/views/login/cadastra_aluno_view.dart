import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/utils.dart';

class CadastraAlunoView extends StatefulWidget {
  const CadastraAlunoView({super.key});

  @override
  State<CadastraAlunoView> createState() => _CadastraAlunoViewState();
}

class _CadastraAlunoViewState extends State<CadastraAlunoView> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  int _idPlanoSelecionado = 1;
  bool _carregando = false;

  final List<Map<String, dynamic>> _planos = [
    {'id': 1, 'nome': 'Plano Mensal'},
    {'id': 2, 'nome': 'Plano Trimestral'},
    {'id': 3, 'nome': 'Plano Semestral'},
    {'id': 4, 'nome': 'Plano Anual'},
  ];

  Future<void> _cadastrar() async {
    setState(() => _carregando = true);
    try {
      final response = await http.post(
        Uri.parse('${Utils.ipServidor}/cadastrarAluno'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomeAluno': _nomeController.text,
          'cpfAluno': _cpfController.text,
          'emailAluno': _emailController.text,
          'telefoneAluno': _telefoneController.text,
          'senhaAluno': _senhaController.text,
          'idPlanoFK': _idPlanoSelecionado,
        }),
      );
      final dados = jsonDecode(response.body);
      final responseDados = dados['response'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseDados['mensagem'])),
      );
      if (responseDados['codigo'] == 200) {
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Cadastro de Aluno')),
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
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _idPlanoSelecionado,
              decoration: const InputDecoration(labelText: 'Plano', border: OutlineInputBorder()),
              items: _planos.map((plano) {
                return DropdownMenuItem<int>(
                  value: plano['id'] as int,
                  child: Text(plano['nome'] as String),
                );
              }).toList(),
              onChanged: (value) => setState(() => _idPlanoSelecionado = value!),
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
