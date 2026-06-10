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
      if (!mounted) return;
      final List lista = jsonDecode(response.body)[0];
      setState(() => _treinos = lista);
    } catch (e) {
      if (!mounted) return;
      _snack('Erro ao carregar treinos: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  final List<Map<String, dynamic>> _planos = [
    {'id': 1, 'nome': 'Plano Mensal'},
    {'id': 2, 'nome': 'Plano Trimestral'},
    {'id': 3, 'nome': 'Plano Semestral'},
    {'id': 4, 'nome': 'Plano Anual'},
  ];

  void _verInformacoes() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Minhas Informações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Nome', widget.usuario['nome']?.toString() ?? ''),
            _infoRow('E-mail', widget.usuario['email']?.toString() ?? ''),
            _infoRow('Telefone', widget.usuario['telefone']?.toString() ?? ''),
            _infoRow('CPF', widget.usuario['cpf']?.toString() ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _alterarDados() async {
    final nomeCtrl = TextEditingController(text: widget.usuario['nome']);
    final telefoneCtrl = TextEditingController(
      text: widget.usuario['telefone']?.toString() ?? '',
    );
    final emailCtrl = TextEditingController(
      text: widget.usuario['email']?.toString() ?? '',
    );
    int idPlanoSelecionado = widget.usuario['idPlano'] as int? ?? 1;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar Dados'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: telefoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: idPlanoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Plano',
                  border: OutlineInputBorder(),
                ),
                items: _planos
                    .map(
                      (p) => DropdownMenuItem<int>(
                        value: p['id'] as int,
                        child: Text(p['nome'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (v) => idPlanoSelecionado = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
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
                    'emailAluno': emailCtrl.text,
                    'senhaAluno': '',
                    'idPlanoFK': idPlanoSelecionado,
                  }),
                );
                if (!mounted) return;
                final dados = jsonDecode(response.body);
                _snack(dados['response']['mensagem']);
                if (dados['response']['codigo'] == 200) {
                  setState(() {
                    widget.usuario['nome'] = nomeCtrl.text;
                    widget.usuario['telefone'] = telefoneCtrl.text;
                    widget.usuario['email'] = emailCtrl.text;
                    widget.usuario['idPlano'] = idPlanoSelecionado;
                  });
                }
              } catch (e) {
                if (!mounted) return;
                _snack('Erro: $e');
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _alterarSenha() async {
    final senhaAtualCtrl = TextEditingController();
    final novaSenhaCtrl = TextEditingController();
    final confirmarCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: senhaAtualCtrl,
                decoration: const InputDecoration(
                  labelText: 'Senha atual',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: novaSenhaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmarCtrl,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nova senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (novaSenhaCtrl.text != confirmarCtrl.text) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('As senhas não coincidem.')),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                final response = await http.put(
                  Uri.parse('${Utils.ipServidor}/alterarSenhaAluno'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'idAluno': widget.usuario['id'],
                    'senhaAtual': senhaAtualCtrl.text,
                    'novaSenha': novaSenhaCtrl.text,
                  }),
                );
                if (!mounted) return;
                final dados = jsonDecode(response.body);
                _snack(dados['response']['mensagem']);
              } catch (e) {
                if (!mounted) return;
                _snack('Erro: $e');
              }
            },
            child: const Text('Alterar'),
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
        content: const Text(
          'Deseja realmente excluir sua conta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
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
        if (!mounted) return;
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
        if (!mounted) return;
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
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Minhas informações',
            onPressed: _verInformacoes,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Alterar dados',
            onPressed: _alterarDados,
          ),
          IconButton(
            icon: const Icon(Icons.lock),
            tooltip: 'Alterar senha',
            onPressed: _alterarSenha,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Excluir conta',
            onPressed: _excluirConta,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logoff,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _treinos.isEmpty
          ? const Center(child: Text('Nenhum treino cadastrado para você.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _treinos.length,
              itemBuilder: (context, index) {
                final treino = _treinos[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${treino['titulo']} - Prof. Responsável: ${treino['nomeProfessor'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(treino['descricao']),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
