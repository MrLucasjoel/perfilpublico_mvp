import 'package:flutter/material.dart';
import 'package:perfilpublico/src/view/Registro_form_view.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _generatedCode;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendVerificationCode() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    
    // Gera um código aleatório (6 dígitos)
    final code = (100000 + (DateTime.now().millisecond % 900000)).toString();
    
    setState(() {
      _generatedCode = code;
    });

    // Aqui você chamaria uma API para enviar o código por e-mail
    // Por enquanto apenas simulamos mostrando o código na UI (para teste)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código enviado para $email\nCódigo para teste: $code'),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _accessForm() {
    if (_generatedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Envie o código de verificação primeiro')),
      );
      return;
    }

    final email = _emailController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroFormView(
          email: email,
          verificationCode: _generatedCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela de Cadastro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'e-mail publico (use o e-mail institucional da Câmara)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'ex: nome@camara.leg.br',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe um e-mail';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(v)) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sendVerificationCode,
                child: const Text('Enviar código de verificação'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Um código será enviado para o e-mail institucional informado.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              if (_generatedCode != null) ...[
                const Text(
                  'Código de verificação recebido?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _accessForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Acessar formulário de cadastro'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
