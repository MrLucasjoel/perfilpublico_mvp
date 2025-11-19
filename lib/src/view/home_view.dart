import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:perfilpublico/src/app/app_menu.dart';
import 'package:perfilpublico/src/model/deputado.dart';
import 'package:perfilpublico/src/services/ad_service.dart';
import 'package:perfilpublico/src/services/deputado_service.dart';
import 'package:perfilpublico/src/view/deputado_perfil_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  List<Deputado> _allDeputados = [];
  List<Deputado> _filteredDeputados = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _loadBannerAd();
    _carregarDeputados();
  }

  void _carregarDeputados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final deputados = await DeputadoService.obterDeputados();
      setState(() {
        _allDeputados = deputados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar deputados: $e';
        _isLoading = false;
      });
      print('Erro: $e');
    }
  }

  void _loadBannerAd() {
    _bannerAd = AdService().loadBannerAd();
    setState(() {
      _isBannerAdLoaded = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    AdService().disposeBannerAd();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _onSearchChanged(_controller.text);
      setState(() {
        _isSearching = true;
      });
    } else {
      setState(() {
        _isSearching = _controller.text.isNotEmpty;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredDeputados = [];
      } else {
        _filteredDeputados = _allDeputados
            .where((dep) =>
                dep.nome.toLowerCase().contains(value.toLowerCase()) ||
                dep.nomeParlamentar.toLowerCase().contains(value.toLowerCase()) ||
                dep.partido.toLowerCase().contains(value.toLowerCase()) ||
                dep.uf.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }

      if (value.isNotEmpty || _focusNode.hasFocus) {
        _isSearching = true;
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _controller.clear();
      _filteredDeputados = [];
      _isSearching = false;
      _focusNode.unfocus();
    });
  }

  PreferredSizeWidget _buildSearchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                filled: true,
                fillColor: const Color.fromARGB(255, 204, 204, 204),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Colors.grey,
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
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.black),
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

  // Widget para exibir cada deputado na lista
  Widget _buildDeputadoTile(Deputado deputado) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Público'),
        centerTitle: true,
        bottom: _buildSearchBar(),
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
                      : _isSearching
                          ? _filteredDeputados.isEmpty &&
                                  _controller.text.isNotEmpty
                              ? const Center(
                                  child: Text('Nenhum resultado encontrado.'),
                                )
                              : ListView.builder(
                                  itemCount: _filteredDeputados.length,
                                  itemBuilder: (context, index) {
                                    final deputado = _filteredDeputados[index];
                                    return _buildDeputadoTile(deputado);
                                  },
                                )
                          : const Center(
                              child: Text(
                                'Bem-vindo à tela inicial!',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
            ),
          ),
          // Banner Ad no rodapé
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              color: Colors.grey.shade200,
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          else
            Container(
              color: Colors.grey.shade300,
              height: 50,
              child: const Center(
                child: Text(
                  'Carregando anúncios...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}