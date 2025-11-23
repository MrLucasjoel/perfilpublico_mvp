import 'package:flutter/material.dart';
import 'package:perfilpublico/src/app/app_menu.dart';
import 'package:perfilpublico/src/model/deputado.dart';
import 'package:perfilpublico/src/services/deputado_service.dart';
import 'package:perfilpublico/src/view/deputado_perfil_view.dart';
import 'package:perfilpublico/src/view/registro_view.dart';
// Importa o novo widget de pesquisa
import 'package:perfilpublico/src/widget/search_bar_widget.dart'; 

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // 1. Controles de UI
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // 2. Estado dos Filtros
  String? _selectedPartido;
  String? _selectedEstado; // Mapeado para 'uf'
  String? _selectedCargo;
  String? _selectedCidade; 

  // 3. Opções de Filtro (Carregadas após obter os deputados)
  Set<String> _uniquePartidos = {};
  Set<String> _uniqueUFs = {};
  final Set<String> _uniqueCargos = {'Deputado Federal', 'Senador', 'Prefeito'};
  final Set<String> _uniqueCidades = {'São Paulo', 'Rio de Janeiro', 'Brasília'}; 

  // 4. Listas de Dados
  List<Deputado> _allDeputados = [];
  List<Deputado> _filteredDeputados = [];

  // 5. Estado de Carregamento/Busca
  bool _isSearching = false; 
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _carregarDeputados();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  // Carrega os dados da API
  void _carregarDeputados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800)); 

      final deputados = await DeputadoService.obterDeputados();
      
      setState(() {
        _allDeputados = deputados;
        _isLoading = false;
        
        // Extrai valores únicos para os filtros
        _uniquePartidos = deputados.map((d) => d.partido).toSet();
        _uniqueUFs = deputados.map((d) => d.uf).toSet();
        
        _applyFilters(); // Aplica filtros iniciais (todos os deputados)
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar deputados. Verifique sua conexão.';
        _isLoading = false;
      });
      print('Erro: $e');
    }
  }
  
  // 6. Lógica de Filtro Unificada
  void _applyFilters([String? partido, String? uf, String? cargo, String? cidade]) {
    // 6.1. Atualiza o estado interno com os novos filtros, se fornecidos
    if (partido != null || uf != null || cargo != null || cidade != null) {
      _selectedPartido = partido;
      _selectedEstado = uf;
      _selectedCargo = cargo;
      _selectedCidade = cidade;
    }
    
    final query = _controller.text.toLowerCase();
    
    // 6.2. Filtra pela query de busca no campo de texto
    List<Deputado> intermediateList = _allDeputados.where((dep) {
      bool matchesSearch = query.isEmpty || 
          dep.nome.toLowerCase().contains(query) ||
          dep.nomeParlamentar.toLowerCase().contains(query) ||
          dep.partido.toLowerCase().contains(query) ||
          dep.uf.toLowerCase().contains(query);
          
      return matchesSearch;
    }).toList();
    
    // 6.3. Aplica filtros selecionados (Dropdowns)
    _filteredDeputados = intermediateList.where((dep) {
      // Filtros baseados nos dados reais (partido e UF)
      bool matchesPartido = _selectedPartido == null || dep.partido == _selectedPartido;
      bool matchesEstado = _selectedEstado == null || dep.uf == _selectedEstado;
      
      // Filtros simulados (Cargo e Cidade - lógica simplificada)
      bool matchesCargo = _selectedCargo == null || (_selectedCargo == 'Deputado Federal'); 
      bool matchesCidade = _selectedCidade == null; 

      return matchesPartido && matchesEstado && matchesCargo && matchesCidade;
    }).toList();
    
    // 6.4. Atualiza o estado de busca ativa
    _isSearching = query.isNotEmpty || _isFilterActive();
  }

  // 7. Callbacks para o SearchBarWidget
  void _handleFilterApplied(String query, String? partido, String? uf, String? cargo, String? cidade) {
    setState(() {
      _controller.text = query;
      _applyFilters(partido, uf, cargo, cidade);
    });
  }

  void _handleSearchQueryChanged(String query) {
    setState(() {
      _applyFilters(); // Re-aplica filtros com o novo texto
    });
  }

  void _handleClear() {
    setState(() {
      _controller.clear();
      _selectedPartido = null;
      _selectedEstado = null;
      _selectedCargo = null;
      _selectedCidade = null;
      _applyFilters();
    });
    _focusNode.unfocus();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _applyFilters();
      });
    } else {
      setState(() {
        if (_controller.text.isEmpty) {
          _isSearching = _isFilterActive();
        }
      });
    }
  }
  
  // Verifica se há algum filtro ativo (Dropdowns)
  bool _isFilterActive() {
    return _selectedPartido != null || _selectedEstado != null || _selectedCargo != null || _selectedCidade != null;
  }

  void _navigateToRegistroPoliticos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroView()),
    );
  }

  void _shareApp() {
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulando compartilhamento do App...'))
     );
  }

  Widget _buildDeputadoTile(Deputado deputado) {
    // ... Código do ListTile (mantido o mesmo) ...
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(deputado.urlFoto),
          onBackgroundImageError: (exception, stackTrace) {},
          child: deputado.urlFoto.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(
          deputado.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deputado.nomeParlamentar,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    deputado.partido,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    deputado.uf,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeputadoPerfilView(deputado: deputado),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionFooter() {
    // ... Código do Footer (mantido o mesmo) ...
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1.0)),
      ),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey.shade800),
            onPressed: _carregarDeputados,
            tooltip: 'Recarregar Lista',
          ),
          
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.black),
            onPressed: _navigateToRegistroPoliticos,
            tooltip: 'Cadastrar Político',
          ),
          
          IconButton(
            icon: Icon(Icons.share, color: Colors.grey.shade800),
            onPressed: _shareApp,
            tooltip: 'Compartilhar Aplicativo',
          ),
          
          IconButton(
            icon: Icon(Icons.star_outline, color: Colors.grey.shade800),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Simulando acesso aos Favoritos...'))
               );
            },
            tooltip: 'Favoritos',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listToShow = _isSearching && (_controller.text.isNotEmpty || _isFilterActive()) ? _filteredDeputados : _allDeputados;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Público', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        // 8. Usa o novo SearchBarWidget
        bottom: SearchBarWidget(
          uniquePartidos: _uniquePartidos,
          uniqueUFs: _uniqueUFs,
          uniqueCargos: _uniqueCargos,
          uniqueCidades: _uniqueCidades,
          controller: _controller,
          focusNode: _focusNode,
          isFilterActive: _isFilterActive(),
          onFilterApplied: _handleFilterApplied,
          onSearchQueryChanged: _handleSearchQueryChanged,
          onClear: _handleClear,
        ),
      ),
      drawer: const AppMenu(),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _focusNode.unfocus();
              },
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _carregarDeputados,
                                child: const Text('Tentar Novamente'),
                              ),
                            ],
                          ),
                        )
                      : listToShow.isEmpty && !_isLoading
                          ? Center(
                               child: Text(
                                _isSearching 
                                  ? 'Nenhum resultado encontrado. Tente redefinir os filtros.'
                                  : 'Nenhum deputado carregado. Arraste para baixo para recarregar ou use o botão Atualizar.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: listToShow.length,
                              itemBuilder: (context, index) {
                                final deputado = listToShow[index];
                                return _buildDeputadoTile(deputado);
                              },
                            ),
            ),
          ),
          
          _buildActionFooter(),
        ],
      ),
    );
  }
}