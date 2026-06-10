import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/utils.dart';
import 'cadastra_aluno_view.dart';
import 'cadastra_professor_view.dart';
import 'recupera_senha_view.dart';
import '../professor/home_professor_view.dart';
import '../aluno/home_aluno_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  Future<void> _loginProfessor() async {
    setState(() => _carregando = true);
    try {
      final response = await http.post(
        Uri.parse('${Utils.ipServidor}/loginProfessor'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailProfessor': _emailController.text,
          'senhaProfessor': _senhaController.text,
        }),
      );
      if (!mounted) return;
      final dados = jsonDecode(response.body);
      final responseDados = dados['response'];
      if (responseDados['codigo'] == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeProfessorView(usuario: Map<String, dynamic>.from(responseDados['usuario'])),
          ),
        );
      } else {
        _snack(responseDados['mensagem']);
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Erro de conexão: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _loginAluno() async {
    setState(() => _carregando = true);
    try {
      final response = await http.post(
        Uri.parse('${Utils.ipServidor}/loginAluno'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailAluno': _emailController.text,
          'senhaAluno': _senhaController.text,
        }),
      );
      if (!mounted) return;
      final dados = jsonDecode(response.body);
      final responseDados = dados['response'];
      if (responseDados['codigo'] == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeAlunoView(usuario: Map<String, dynamic>.from(responseDados['usuario'])),
          ),
        );
      } else {
        _snack(responseDados['mensagem']);
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Erro de conexão: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Text(
              'Aqua Core',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF4166A0)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_carregando)
              const CircularProgressIndicator()
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginProfessor,
                  child: const Text('Entrar como Professor'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginAluno,
                  child: const Text('Entrar como Aluno'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastraAlunoView()),
                  ),
                  child: const Text('Cadastrar como Aluno'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastraProfessorView()),
                  ),
                  child: const Text('Cadastrar como Professor'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecuperaSenhaView()),
                ),
                child: const Text('Esqueci minha senha'),
              ),
            ],
            const Spacer(flex: 1),
          ],
        ),
      ),
      ),
    );
  }
}
