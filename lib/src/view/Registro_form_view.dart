import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistroFormView extends StatefulWidget {
  final String? email;
  final String? verificationCode;
  const RegistroFormView({super.key, this.email, this.verificationCode});

  @override
  State<RegistroFormView> createState() => _RegistroFormViewState();
}

class _RegistroFormViewState extends State<RegistroFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _academic = TextEditingController();
  final TextEditingController _personal = TextEditingController();
  final TextEditingController _business = TextEditingController();

  bool _codeVerified = false;
  bool _submitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    _academic.dispose();
    _personal.dispose();
    _business.dispose();
    super.dispose();
  }

  void _verifyCode() {
    if (widget.verificationCode == null ||
        _codeController.text.trim() != widget.verificationCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código de verificação inválido')),
      );
      return;
    }

    setState(() {
      _codeVerified = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código verificado com sucesso!')),
    );
  }

  Future<void> _submit() async {
    if (!_codeVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifique o código primeiro')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final academicText = _academic.text.trim();
    final personalText = _personal.text.trim();
    final businessText = _business.text.trim();

    setState(() => _submitting = true);

    final supabase = Supabase.instance.client;
    final data = {
      'email': widget.email,
      'academic': academicText,
      'personal': personalText,
      'business': businessText,
    };

    try {
      debugPrint('Enviando para Supabase: $data');

      if (widget.email != null && widget.email!.isNotEmpty) {
        // upsert usando email como unique key (garanta que 'email' é unique no DB)
        final res = await supabase
            .from('profiles') // verifique se a tabela 'profiles' existe no schema 'public'
            .upsert([data], onConflict: 'email')
            .select();

        debugPrint('Resposta upsert: $res');

        if (res == null || (res is List && res.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar (resposta vazia)')),
          );
          setState(() => _submitting = false);
          return;
        }
      } else {
        // sem email -> inserir
        final res = await supabase.from('profiles').insert([data]).select();

        debugPrint('Resposta insert: $res');

        if (res == null || (res is List && res.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao inserir (resposta vazia)')),
          );
          setState(() => _submitting = false);
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro salvo com sucesso')),
      );

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on PostgrestException catch (e) {
      // Erro específico do Postgres/Supabase (ex: tabela não existe, RLS, etc)
      debugPrint('PostgrestException: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de banco: ${e.message}')),
      );
    } catch (e, st) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
      debugPrint('Supabase error: $e\n$st');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _validateNotEmpty(String? v) {
    if (v == null || v.trim().isEmpty) return 'Preencha este campo';
    if (v.trim().length > 500) return 'Máximo de 500 caracteres';
    return null;
  }

  Widget _buildRichTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _codeVerified && !_submitting,
          maxLines: 8,
          maxLength: 500,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Escreva até 500 caracteres',
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          validator: _codeVerified ? _validateNotEmpty : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Formulário de Cadastro',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                if (widget.email != null) ...[
                  Text('Cadastrando: ${widget.email}',
                      style: const TextStyle(fontSize: 8)),
                  const SizedBox(height: 32),
                ],
                if (!_codeVerified) ...[
                  const Text(
                    'Digite o código de verificação enviado por e-mail:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      hintText: 'Código de 6 dígitos',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _verifyCode,
                    child: const Text(
                      'Verificar código',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      '✓ Código verificado com sucesso',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                _buildRichTextField(
                  label: 'Currículo acadêmico / cursos (até 500 caracteres)',
                  controller: _academic,
                ),
                const SizedBox(height: 32),
                _buildRichTextField(
                  label: 'Currículo pessoal (até 500 caracteres)',
                  controller: _personal,
                ),
                const SizedBox(height: 32),
                _buildRichTextField(
                  label: 'Currículo empresarial (até 500 caracteres)',
                  controller: _business,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: (!_codeVerified || _submitting) ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}