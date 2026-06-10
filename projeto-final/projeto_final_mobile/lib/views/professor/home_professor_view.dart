import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/utils.dart';
import '../login/login_view.dart';

class HomeProfessorView extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const HomeProfessorView({super.key, required this.usuario});

  @override
  State<HomeProfessorView> createState() => _HomeProfessorViewState();
}

class _HomeProfessorViewState extends State<HomeProfessorView> {
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
        Uri.parse('${Utils.ipServidor}/lerTreinosProfessor/$id'),
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

  Future<void> _criarTreino() async {
    final idAlunoCtrl = TextEditingController();
    final tituloCtrl = TextEditingController();
    final descricaoCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Treino'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idAlunoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Matrícula do Aluno (ID)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descricaoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
                final response = await http.post(
                  Uri.parse('${Utils.ipServidor}/cadastrarTreino'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'idAlunoFK': int.tryParse(idAlunoCtrl.text) ?? 0,
                    'titulo': tituloCtrl.text,
                    'descricao': descricaoCtrl.text,
                    'idProfessorFK': widget.usuario['id'],
                  }),
                );
                final dados = jsonDecode(response.body);
                _snack(dados['response']['mensagem']);
                if (dados['response']['codigo'] == 200) _lerTreinos();
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

  Future<void> _editarTreino(Map<String, dynamic> treino) async {
    final idAlunoCtrl = TextEditingController(
      text: treino['idAluno'].toString(),
    );
    final tituloCtrl = TextEditingController(text: treino['titulo']);
    final descricaoCtrl = TextEditingController(text: treino['descricao']);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Treino'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idAlunoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Matrícula do Aluno (ID)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descricaoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
                  Uri.parse('${Utils.ipServidor}/atualizarTreino'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'idTreino': treino['id'],
                    'idAlunoFK': int.tryParse(idAlunoCtrl.text) ?? 0,
                    'titulo': tituloCtrl.text,
                    'descricao': descricaoCtrl.text,
                    'idProfessorFK': widget.usuario['id'],
                  }),
                );
                final dados = jsonDecode(response.body);
                _snack(dados['response']['mensagem']);
                if (dados['response']['codigo'] == 200) _lerTreinos();
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

  Future<void> _excluirTreino(int idTreino) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Treino'),
        content: const Text('Deseja realmente excluir este treino?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        final response = await http.delete(
          Uri.parse('${Utils.ipServidor}/deletarTreino'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'idTreino': idTreino,
            'idProfessorFK': widget.usuario['id'],
          }),
        );
        final dados = jsonDecode(response.body);
        _snack(dados['response']['mensagem']);
        if (dados['response']['codigo'] == 200) _lerTreinos();
      } catch (e) {
        _snack('Erro: $e');
      }
    }
  }

  void _verInformacoes() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Minhas Informações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Nome',     widget.usuario['nome']?.toString()     ?? ''),
            _infoRow('E-mail',   widget.usuario['email']?.toString()    ?? ''),
            _infoRow('Telefone', widget.usuario['telefone']?.toString() ?? ''),
            _infoRow('CPF',      widget.usuario['cpf']?.toString()      ?? ''),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
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

  Future<void> _buscarAluno() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        title: Text('Buscar Aluno'),
        content: SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
      ),
    );

    List<dynamic> todosAlunos = [];
    try {
      final response = await http.get(Uri.parse('${Utils.ipServidor}/lerAlunos'));
      if (!mounted) return;
      Navigator.pop(context);
      todosAlunos = jsonDecode(response.body)[0];
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _snack('Erro ao carregar alunos: $e');
      return;
    }

    if (!mounted) return;

    List<dynamic> filtrados = [];
    final buscaCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Buscar Aluno'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: buscaCtrl,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Nome do aluno',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setStateDialog(() {
                          filtrados = todosAlunos
                              .where((a) => (a['nome'] as String)
                                  .toLowerCase()
                                  .contains(buscaCtrl.text.toLowerCase()))
                              .toList();
                        });
                      },
                      child: const Text('Buscar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                filtrados.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtrados.length,
                        itemBuilder: (_, i) {
                          final a = filtrados[i];
                          return ListTile(
                            leading: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Matr.', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                                CircleAvatar(radius: 16, child: Text('${a['id']}')),
                              ],
                            ),
                            title: Text(a['nome']),
                            subtitle: Text('${a['email']} • ${a['telefone'] ?? ''}'),
                          );
                        },
                      ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _alterarDados() async {
    final nomeCtrl     = TextEditingController(text: widget.usuario['nome']);
    final telefoneCtrl = TextEditingController(text: widget.usuario['telefone']?.toString() ?? '');
    final emailCtrl    = TextEditingController(text: widget.usuario['email']?.toString() ?? '');

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
                decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: telefoneCtrl,
                decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
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
                  Uri.parse('${Utils.ipServidor}/atualizarProfessor'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'idProfessor':       widget.usuario['id'],
                    'nomeProfessor':     nomeCtrl.text,
                    'telefoneProfessor': telefoneCtrl.text,
                    'emailProfessor':    emailCtrl.text,
                    'senhaProfessor':    '',
                  }),
                );
                if (!mounted) return;
                final dados = jsonDecode(response.body);
                _snack(dados['response']['mensagem']);
                if (dados['response']['codigo'] == 200) {
                  setState(() {
                    widget.usuario['nome']     = nomeCtrl.text;
                    widget.usuario['telefone'] = telefoneCtrl.text;
                    widget.usuario['email']    = emailCtrl.text;
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
    final senhaAtualCtrl   = TextEditingController();
    final novaSenhaCtrl    = TextEditingController();
    final confirmarCtrl    = TextEditingController();

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
                decoration: const InputDecoration(labelText: 'Senha atual', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: novaSenhaCtrl,
                decoration: const InputDecoration(labelText: 'Nova senha', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmarCtrl,
                decoration: const InputDecoration(labelText: 'Confirmar nova senha', border: OutlineInputBorder()),
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
                  Uri.parse('${Utils.ipServidor}/alterarSenhaProfessor'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'idProfessor': widget.usuario['id'],
                    'senhaAtual':  senhaAtualCtrl.text,
                    'novaSenha':   novaSenhaCtrl.text,
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

  Future<void> _verAlunos() async {
    showDialog(
      context: context,
      builder: (ctx) => const AlertDialog(
        title: Text('Lista de Alunos'),
        content: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      final response = await http.get(Uri.parse('${Utils.ipServidor}/lerAlunos'));
      if (!mounted) return;
      Navigator.pop(context);
      final List alunos = jsonDecode(response.body)[0];
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Lista de Alunos'),
          content: SizedBox(
            width: double.maxFinite,
            child: alunos.isEmpty
                ? const Text('Nenhum aluno cadastrado.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: alunos.length,
                    itemBuilder: (_, i) {
                      final a = alunos[i];
                      return ListTile(
                        leading: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Matr.', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                            CircleAvatar(radius: 16, child: Text('${a['id']}')),
                          ],
                        ),
                        title: Text(a['nome']),
                        subtitle: Text('${a['email']} • ${a['telefone'] ?? ''}'),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _snack('Erro ao carregar alunos: $e');
    }
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
          Uri.parse('${Utils.ipServidor}/deletarProfessor'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idProfessor': widget.usuario['id']}),
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
        title: Text('Prof. ${widget.usuario['nome']}'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Minhas informações',
            onPressed: _verInformacoes,
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Lista de alunos',
            onPressed: _verAlunos,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar aluno',
            onPressed: _buscarAluno,
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
          ? const Center(child: Text('Nenhum treino cadastrado.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _treinos.length,
              itemBuilder: (context, index) {
                final treino = _treinos[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      treino['titulo'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(treino['descricao']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _editarTreino(Map<String, dynamic>.from(treino)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _excluirTreino(treino['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _criarTreino,
        child: const Icon(Icons.add),
      ),
    );
  }
}
