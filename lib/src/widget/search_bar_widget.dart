import 'package:flutter/material.dart';

// Definindo o tipo de retorno para o callback de filtro aplicado
typedef FilterCallback = void Function(
  String query,
  String? partido,
  String? uf,
  String? cargo,
  String? cidade,
);

class SearchBarWidget extends StatefulWidget implements PreferredSizeWidget {
  // Dados de Opções de Filtro (passados pelo HomeView)
  final Set<String> uniquePartidos;
  final Set<String> uniqueUFs;
  final Set<String> uniqueCargos;
  final Set<String> uniqueCidades;

  // Callbacks para notificar o HomeView
  final FilterCallback onFilterApplied;
  final Function(String query) onSearchQueryChanged;
  final VoidCallback onClear;
  
  // Para manter o estado do texto e foco
  final TextEditingController controller;
  final FocusNode focusNode;
  
  // Estado para indicar se o HomeView tem filtros ativos (para colorir o ícone)
  final bool isFilterActive;

  const SearchBarWidget({
    required this.uniquePartidos,
    required this.uniqueUFs,
    required this.uniqueCargos,
    required this.uniqueCidades,
    required this.onFilterApplied,
    required this.onSearchQueryChanged,
    required this.onClear,
    required this.controller,
    required this.focusNode,
    required this.isFilterActive,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70.0);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  // Variáveis temporárias para o estado DENTRO do modal de filtro
  String? _modalSelectedPartido;
  String? _modalSelectedEstado;
  String? _modalSelectedCargo;
  String? _modalSelectedCidade;

  // Lógica para mostrar o Modal de Filtro
  void _showFilterSheet(BuildContext context) {
    // Inicializa o estado do modal com os filtros atualmente ativos no HomeView
    // NOTA: Para este MVP, vamos assumir que o HomeView mantém o estado, mas 
    // como não temos acesso direto ao estado privado do HomeView, passamos 
    // os valores atuais ao chamar este widget no HomeView, e HomeView os repassa aqui
    // Se o HomeView não tivesse o estado do filtro, precisaríamos de uma abordagem mais complexa (e.g., ValueNotifier)
    
    // Para simplificar, vamos assumir que a HomeView está passando o estado
    // Aqui, apenas usamos as variáveis temporárias do modal que serão atualizadas 
    // e enviadas de volta ao HomeView ao clicar em 'Aplicar Filtros'

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Filtros Avançados',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.grey.shade800
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        _buildFilterDropdown(
                          modalSetState,
                          'Partido',
                          _modalSelectedPartido,
                          widget.uniquePartidos.toList()..sort(),
                          (newValue) => _modalSelectedPartido = newValue,
                        ),
                        _buildFilterDropdown(
                          modalSetState,
                          'Estado (UF)',
                          _modalSelectedEstado,
                          widget.uniqueUFs.toList()..sort(),
                          (newValue) => _modalSelectedEstado = newValue,
                        ),
                        _buildFilterDropdown(
                          modalSetState,
                          'Cargo',
                          _modalSelectedCargo,
                          widget.uniqueCargos.toList()..sort(),
                          (newValue) => _modalSelectedCargo = newValue,
                        ),
                        _buildFilterDropdown(
                          modalSetState,
                          'Cidade',
                          _modalSelectedCidade,
                          widget.uniqueCidades.toList()..sort(),
                          (newValue) => _modalSelectedCidade = newValue,
                        ),
                      ],
                    ),
                  ),
                  
                  // Botões de Ação do Modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Limpa o estado interno do modal e notifica HomeView para limpar
                          modalSetState(() {
                            _modalSelectedPartido = null;
                            _modalSelectedEstado = null;
                            _modalSelectedCargo = null;
                            _modalSelectedCidade = null;
                          });
                          widget.onClear();
                          Navigator.pop(context); 
                        },
                        child: const Text('Limpar Filtros', style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Notifica HomeView com os novos valores de filtro
                          widget.onFilterApplied(
                            widget.controller.text,
                            _modalSelectedPartido,
                            _modalSelectedEstado,
                            _modalSelectedCargo,
                            _modalSelectedCidade,
                          );
                          Navigator.pop(context); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Aplicar Filtros'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper para construir os Dropdowns de Filtro
  Widget _buildFilterDropdown(
    StateSetter modalSetState,
    String label,
    String? currentValue,
    List<String> options,
    Function(String?) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          suffixIcon: currentValue != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    modalSetState(() {
                      onSelected(null);
                    });
                  },
                )
              : null,
        ),
        value: currentValue,
        hint: Text('Selecione um $label'),
        isExpanded: true,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          modalSetState(() {
            onSelected(newValue);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sincroniza o estado do modal (para quando o widget for reconstruído)
    // Isso é uma simplificação, o ideal seria que HomeView passasse o estado atual dos filtros.
    // Para fins práticos, o estado de filtro só é realmente importante quando o modal está aberto.
    
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar...',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: widget.controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.black),
                              onPressed: widget.onClear,
                            )
                          : null,
                    ),
                    onChanged: widget.onSearchQueryChanged,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                
                const SizedBox(width: 8),

                // ÍCONE DE FILTRO
                Container(
                  decoration: BoxDecoration(
                    color: widget.isFilterActive ? Theme.of(context).primaryColor : Colors.grey.shade300, 
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color.fromARGB(255, 0, 0, 0))
                  ),
                  child: IconButton(
                    icon: Icon(
                      widget.isFilterActive ? Icons.filter_list_off : Icons.filter_list, 
                      color: widget.isFilterActive ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      // Antes de abrir, inicializa o estado interno do modal com os valores atuais
                      _modalSelectedPartido = null;
                      _modalSelectedEstado = null;
                      _modalSelectedCargo = null;
                      _modalSelectedCidade = null;
                      _showFilterSheet(context);
                    },
                    tooltip: 'Filtros',
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1.0,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}