class Deputado {
  final int ideCadastro;
  final int codOrcamento;
  final String condicao;
  final int matricula;
  final int idParlamentar;
  final String nome;
  final String nomeParlamentar;
  final String urlFoto;
  final String uf;
  final String partido;
  final int gabinete;
  final int anexo;
  final String fone;
  final String email;
  
  // Campos opcionais para dados cadastrados
  String? curriculoAcademico;
  String? curriculoPessoal;
  String? curriculoNegocio;

  Deputado({
    required this.ideCadastro,
    required this.codOrcamento,
    required this.condicao,
    required this.matricula,
    required this.idParlamentar,
    required this.nome,
    required this.nomeParlamentar,
    required this.urlFoto,
    required this.uf,
    required this.partido,
    required this.gabinete,
    required this.anexo,
    required this.fone,
    required this.email,
    this.curriculoAcademico,
    this.curriculoPessoal,
    this.curriculoNegocio,
  });

  // Factory para parsear XML da API
  factory Deputado.fromXmlString(String xmlString) {
    final ideCadastroMatch = RegExp(r'<ideCadastro>(\d+)</ideCadastro>').firstMatch(xmlString);
    final codOrcamentoMatch = RegExp(r'<codOrcamento>(\d+)</codOrcamento>').firstMatch(xmlString);
    final condicaoMatch = RegExp(r'<condicao>([^<]+)</condicao>').firstMatch(xmlString);
    final matriculaMatch = RegExp(r'<matricula>(\d+)</matricula>').firstMatch(xmlString);
    final idParlamentarMatch = RegExp(r'<idParlamentar>(\d+)</idParlamentar>').firstMatch(xmlString);
    final nomeMatch = RegExp(r'<nome>([^<]+)</nome>').firstMatch(xmlString);
    final nomeParlamentarMatch = RegExp(r'<nomeParlamentar>([^<]+)</nomeParlamentar>').firstMatch(xmlString);
    final urlFotoMatch = RegExp(r'<urlFoto>([^<]+)</urlFoto>').firstMatch(xmlString);
    final ufMatch = RegExp(r'<uf>([^<]+)</uf>').firstMatch(xmlString);
    final partidoMatch = RegExp(r'<partido>([^<]+)</partido>').firstMatch(xmlString);
    final gabineteMatch = RegExp(r'<gabinete>(\d+)</gabinete>').firstMatch(xmlString);
    final anexoMatch = RegExp(r'<anexo>(\d+)</anexo>').firstMatch(xmlString);
    final foneMatch = RegExp(r'<fone>([^<]+)</fone>').firstMatch(xmlString);
    final emailMatch = RegExp(r'<email>([^<]+)</email>').firstMatch(xmlString);

    return Deputado(
      ideCadastro: int.parse(ideCadastroMatch?.group(1) ?? '0'),
      codOrcamento: int.parse(codOrcamentoMatch?.group(1) ?? '0'),
      condicao: condicaoMatch?.group(1) ?? '',
      matricula: int.parse(matriculaMatch?.group(1) ?? '0'),
      idParlamentar: int.parse(idParlamentarMatch?.group(1) ?? '0'),
      nome: nomeMatch?.group(1) ?? '',
      nomeParlamentar: nomeParlamentarMatch?.group(1) ?? '',
      urlFoto: urlFotoMatch?.group(1) ?? '',
      uf: ufMatch?.group(1) ?? '',
      partido: partidoMatch?.group(1) ?? '',
      gabinete: int.parse(gabineteMatch?.group(1) ?? '0'),
      anexo: int.parse(anexoMatch?.group(1) ?? '0'),
      fone: foneMatch?.group(1) ?? '',
      email: emailMatch?.group(1) ?? '',
    );
  }

  // Converter para JSON para armazenamento local
  Map<String, dynamic> toJson() {
    return {
      'ideCadastro': ideCadastro,
      'codOrcamento': codOrcamento,
      'condicao': condicao,
      'matricula': matricula,
      'idParlamentar': idParlamentar,
      'nome': nome,
      'nomeParlamentar': nomeParlamentar,
      'urlFoto': urlFoto,
      'uf': uf,
      'partido': partido,
      'gabinete': gabinete,
      'anexo': anexo,
      'fone': fone,
      'email': email,
      'curriculoAcademico': curriculoAcademico,
      'curriculoPessoal': curriculoPessoal,
      'curriculoNegocio': curriculoNegocio,
    };
  }

  // Factory para criar a partir de JSON
  factory Deputado.fromJson(Map<String, dynamic> json) {
    return Deputado(
      ideCadastro: json['ideCadastro'] ?? 0,
      codOrcamento: json['codOrcamento'] ?? 0,
      condicao: json['condicao'] ?? '',
      matricula: json['matricula'] ?? 0,
      idParlamentar: json['idParlamentar'] ?? 0,
      nome: json['nome'] ?? '',
      nomeParlamentar: json['nomeParlamentar'] ?? '',
      urlFoto: json['urlFoto'] ?? '',
      uf: json['uf'] ?? '',
      partido: json['partido'] ?? '',
      gabinete: json['gabinete'] ?? 0,
      anexo: json['anexo'] ?? 0,
      fone: json['fone'] ?? '',
      email: json['email'] ?? '',
      curriculoAcademico: json['curriculoAcademico'],
      curriculoPessoal: json['curriculoPessoal'],
      curriculoNegocio: json['curriculoNegocio'],
    );
  }
}
