import 'package:http/http.dart' as http;
import 'package:perfilpublico/src/model/deputado.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeputadoService {
  static const String _baseUrl = 'https://www.camara.leg.br/SitCamaraWS/Deputados.asmx';

  /// Busca todos os deputados da API
  static Future<List<Deputado>> obterDeputados() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ObterDeputados'),
      ).timeout(
        const Duration(seconds: 10),
      );
      

      if (response.statusCode == 200) {
        await prefs.setString('deputados_xml', response.body);
        return _parseDeputados(response.body);
      } else {
        throw Exception('Erro ao buscar deputados: ${response.statusCode}');
      }
    } catch (e) {
      String? storedXml = prefs.getString('deputados_xml');
      if (storedXml != null) {
        return _parseDeputados(storedXml);
      } else {
        throw Exception('Erro na conexão: $e');
      }
    }
  }

  /// Parse XML response da API
  static List<Deputado> _parseDeputados(String xmlBody) {
    final List<Deputado> deputados = [];

    // Extrai cada elemento <deputado> do XML
    final deputadoRegex = RegExp(r'<deputado>(.*?)</deputado>', dotAll: true);
    final matches = deputadoRegex.allMatches(xmlBody);

    for (final match in matches) {
      try {
        final deputadoXml = match.group(0) ?? '';
        final deputado = Deputado.fromXmlString(deputadoXml);
        deputados.add(deputado);
      } catch (e) {
        // Log erro ao parsear individual
        print('Erro ao parsear deputado: $e');
      }
    }

    return deputados;
  }

  /// Busca deputado por nome (busca local na lista)
  static Future<List<Deputado>> buscarPorNome(String nome) async {
    try {
      final todosDep = await obterDeputados();
      return todosDep
          .where((dep) =>
              dep.nome.toLowerCase().contains(nome.toLowerCase()) ||
              dep.nomeParlamentar.toLowerCase().contains(nome.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar por nome: $e');
    }
  }

  /// Busca deputado por UF
  static Future<List<Deputado>> buscarPorUF(String uf) async {
    try {
      final todosDep = await obterDeputados();
      return todosDep.where((dep) => dep.uf == uf.toUpperCase()).toList();
    } catch (e) {
      throw Exception('Erro ao buscar por UF: $e');
    }
  }

  /// Busca deputado por partido
  static Future<List<Deputado>> buscarPorPartido(String partido) async {
    try {
      final todosDep = await obterDeputados();
      return todosDep
          .where((dep) =>
              dep.partido.toLowerCase().contains(partido.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar por partido: $e');
    }
  }

  /// Busca deputado específico por ID de cadastro
  static Future<Deputado?> buscarPorId(int ideCadastro) async {
    try {
      final todosDep = await obterDeputados();
      return todosDep.firstWhere(
        (dep) => dep.ideCadastro == ideCadastro,
        orElse: () => throw Exception('Deputado não encontrado'),
      );
    } catch (e) {
      throw Exception('Erro ao buscar deputado por ID: $e');
    }
  }
}
