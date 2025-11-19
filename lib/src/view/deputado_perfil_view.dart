import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfilpublico/src/model/deputado.dart';

class DeputadoPerfilView extends StatefulWidget {
  final Deputado deputado;

  const DeputadoPerfilView({
    super.key,
    required this.deputado,
  });

  @override
  State<DeputadoPerfilView> createState() => _DeputadoPerfilViewState();
}

class _DeputadoPerfilViewState extends State<DeputadoPerfilView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Deputado'),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildInfoPage(),
          _buildCurriculoPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Informações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Currículos',
          ),
        ],
      ),
    );
  }

  // Página de informações do deputado
  Widget _buildInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.deputado.urlFoto,
                  height: 250,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      width: 200,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 80),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 250,
                      width: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nome e dados básicos
          Text(
            widget.deputado.nome,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.deputado.nomeParlamentar,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // Card com informações principais
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow('Partido', widget.deputado.partido),
                  const Divider(),
                  _buildInfoRow('Estado', widget.deputado.uf),
                  const Divider(),
                  _buildInfoRow('Condição', widget.deputado.condicao),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contato
          const Text(
            'Contato',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildContactRow(
                    Icons.email,
                    'Email',
                    widget.deputado.email,
                    onTap: () {
                      // Implementar envio de email
                    },
                  ),
                  const Divider(),
                  _buildContactRow(
                    Icons.phone,
                    'Telefone',
                    widget.deputado.fone,
                  ),
                  const Divider(),
                  _buildInfoRow('Gabinete', 'Sala ${widget.deputado.gabinete}'),
                  const Divider(),
                  _buildInfoRow('Anexo', 'Anexo ${widget.deputado.anexo}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Informações administrativas
          const Text(
            'Dados Administrativos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow('ID Parlamentar', '${widget.deputado.idParlamentar}'),
                  const Divider(),
                  _buildInfoRow('Matrícula', '${widget.deputado.matricula}'),
                  const Divider(),
                  _buildInfoRow('Cód. Orçamento', '${widget.deputado.codOrcamento}'),
                  const Divider(),
                  _buildInfoRow('ID Cadastro', '${widget.deputado.ideCadastro}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Página de currículos
  Widget _buildCurriculoPage() {
    final temCurriculos = widget.deputado.curriculoAcademico != null ||
        widget.deputado.curriculoPessoal != null ||
        widget.deputado.curriculoNegocio != null;

    if (!temCurriculos) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum currículo cadastrado',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.deputado.curriculoAcademico != null)
            _buildCurriculoCard(
              'Currículo Acadêmico',
              widget.deputado.curriculoAcademico!,
              Colors.blue,
            ),
          if (widget.deputado.curriculoPessoal != null) ...[
            const SizedBox(height: 16),
            _buildCurriculoCard(
              'Currículo Pessoal',
              widget.deputado.curriculoPessoal!,
              Colors.green,
            ),
          ],
          if (widget.deputado.curriculoNegocio != null) ...[
            const SizedBox(height: 16),
            _buildCurriculoCard(
              'Currículo Empresarial',
              widget.deputado.curriculoNegocio!,
              Colors.orange,
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget para exibir cada currículo
  Widget _buildCurriculoCard(String titulo, String conteudo, Color cor) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: cor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              conteudo,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para linha de informação
  Widget _buildInfoRow(String label, String value) {
    return GestureDetector(
      onLongPress: () => _copiarParaClipboard(value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.copy,
                  color: Colors.grey.shade300,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper para linha de contato com ícone
  Widget _buildContactRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _copiarParaClipboard(value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.copy,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _copiarParaClipboard(String texto) {
    try {
      Clipboard.setData(ClipboardData(text: texto)).then((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copiado: $texto'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao copiar'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      print('Erro ao copiar: $e');
    }
  }
}
