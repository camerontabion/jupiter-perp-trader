import 'package:flutter/material.dart';
import 'package:jupiter_perp_trader_client/services/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  
  String _email = '';
  String _oneTimeCode = '';
  bool _isSubmittingEmail = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        await _authService.requestLogin(_email);
        setState(() {
          _isSubmittingEmail = false;
          _isLoading = false;
        });
        _emailController.clear();
        _formKey.currentState?.reset();
      } catch (e) {
        setState(() {
          _error = 'Failed to send login code. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitOneTimeCode() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        await _authService.login(_email, _oneTimeCode);
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
      } catch (e) {
        setState(() {
          _error = 'Invalid code. Please try again.';
          _isLoading = false;
          _codeController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          if (_isSubmittingEmail)
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'example@gmail.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onSaved: (value) {
                _email = value ?? '';
              },
            )
          else
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'One-Time Code',
                hintText: 'Enter the code sent to your email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the code';
                }
                return null;
              },
              onSaved: (value) {
                _oneTimeCode = value ?? '';
              },
            ),
          const SizedBox(height: 16),
          if (!_isLoading)
            ElevatedButton(
              onPressed: _isSubmittingEmail ? _submitEmail : _submitOneTimeCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isSubmittingEmail ? 'Send Code' : 'Login',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!_isSubmittingEmail)
            TextButton(
              onPressed: _isLoading ? null : () {
                setState(() {
                  _isSubmittingEmail = true;
                  _error = null;
                  _emailController.clear();
                  _codeController.clear();
                  _formKey.currentState?.reset();
                });
              },
              child: const Text('Use different email'),
            ),
        ],
      ),
    );
  }
}
