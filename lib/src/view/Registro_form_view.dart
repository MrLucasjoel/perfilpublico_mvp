import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _codeController.dispose();
    _academic.dispose();
    _personal.dispose();
    _business.dispose();
    super.dispose();
  }

  void _verifyCode() {
    if (_codeController.text.trim() != widget.verificationCode) {
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

  void _submit() {
    if (!_codeVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifique o código primeiro')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Aqui você pode enviar os dados para um backend.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro salvo com sucesso')),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  String? _validateNotEmpty(String? v) {
    if (v == null || v.trim().isEmpty) return 'Preencha este campo';
    if (v.trim().length > 500) return 'Máximo de 500 caracteres';
    return null;
  }

  Widget _buildRichTextField({
    required String label, 
    required TextEditingController controller,
      }) 
    {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _codeVerified,
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
        title: const Text('Formulário de Cadastro', 
          style: TextStyle(color: Colors.black
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              if (widget.email != null) ...[
                Text('Cadastrando: ${widget.email}', style: const TextStyle(fontSize: 8)),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: 'Código de 6 dígitos',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _verifyCode,
                  child: const Text('Verificar código', 
                    style: TextStyle(color: Colors.black,
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
                onPressed: _codeVerified ? _submit : null,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
