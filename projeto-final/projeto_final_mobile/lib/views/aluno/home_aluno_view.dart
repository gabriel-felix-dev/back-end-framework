import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/utils.dart';
import '../login/login_view.dart';

class HomeAlunoView extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const HomeAlunoView({super.key, required this.usuario});

  @override
  State<HomeAlunoView> createState() => _HomeAlunoViewState();
}

class _HomeAlunoViewState extends State<HomeAlunoView> {
  List<dynamic> _treinos = [];
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _lerTreinos();
  }

  Future<void> _lerTreinos() async {
    setState(() => _carregando = true);
    try {
      final id = widget.usuario['id'];
      final response = await http.get(
        Uri.parse('${Utils.ipServidor}/lerTreinosAluno/$id'),
      );
      final List lista = jsonDecode(response.body)[0];
      setState(() => _treinos = lista);
    } catch (e) {
      _snack('Erro ao carregar treinos: $e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _alterarDados() async {
    final nomeCtrl = TextEditingController(text: widget.usuario['nome']);
    final telefoneCtrl = TextEditingController(text: widget.usuario['telefone']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar Dados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: telefoneCtrl,
              decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final response = await http.put(
                  Uri.parse('${Utils.ipServidor}/atualizarAluno'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'idAluno': widget.usuario['id'],
                    'nomeAluno': nomeCtrl.text,
                    'telefoneAluno': telefoneCtrl.text,
                  }),
                );
                final dados = jsonDecode(response.body);
                _snack(dados['response']['mensagem']);
                if (dados['response']['codigo'] == 200) {
                  setState(() {
                    widget.usuario['nome'] = nomeCtrl.text;
                    widget.usuario['telefone'] = telefoneCtrl.text;
                  });
                }
              } catch (e) {
                _snack('Erro: $e');
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirConta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text('Deseja realmente excluir sua conta? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Não')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        final response = await http.delete(
          Uri.parse('${Utils.ipServidor}/deletarAluno'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idAluno': widget.usuario['id']}),
        );
        final dados = jsonDecode(response.body);
        _snack(dados['response']['mensagem']);
        if (dados['response']['codigo'] == 200) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        }
      } catch (e) {
        _snack('Erro: $e');
      }
    }
  }

  void _logoff() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aluno ${widget.usuario['nome']}'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.person), tooltip: 'Alterar dados', onPressed: _alterarDados),
          IconButton(icon: const Icon(Icons.delete_forever), tooltip: 'Excluir conta', onPressed: _excluirConta),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Sair', onPressed: _logoff),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _treinos.isEmpty
              ? const Center(child: Text('Nenhum treino cadastrado para você.'))
              : ListView.builder(
                  itemCount: _treinos.length,
                  itemBuilder: (context, index) {
                    final treino = _treinos[index];
                    return ListTile(
                      title: Text(treino['titulo']),
                      subtitle: Text(treino['descricao']),
                    );
                  },
                ),
    );
  }
}
