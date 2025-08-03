import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService? authService;
  final bool useSimpleGoogleButton; // For tests

  const LoginScreen({Key? key, this.authService, this.useSimpleGoogleButton = false}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthService _authService;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLogin = true;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  Future<void> _handleEmailAuth() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await _authService.signInWithEmail(_email, _password);
      } else {
        await _authService.signUpWithEmail(_email, _password);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud, size: 48, color: Colors.blueAccent),
                    const SizedBox(height: 8),
                    Text(
                      'Weather App',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    widget.useSimpleGoogleButton
                        ? ElevatedButton(
                            child: Text('Sign in with Google'),
                            onPressed: () async {
                              setState(() => _loading = true);
                              try {
                                await _authService.signInWithGoogle();
                              } catch (e) {
                                setState(() {
                                  _error = e.toString().replaceFirst('Exception: ', '');
                                });
                              }
                              setState(() => _loading = false);
                            },
                          )
                        : SignInButton(
                            Buttons.Google,
                            text: "Sign in with Google",
                            onPressed: () async {
                              setState(() => _loading = true);
                              try {
                                await _authService.signInWithGoogle();
                              } catch (e) {
                                setState(() {
                                  _error = e.toString().replaceFirst('Exception: ', '');
                                });
                              }
                              setState(() => _loading = false);
                            },
                          ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('or'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (val) => _email = val,
                            validator: (val) =>
                                val != null && val.contains('@') ? null : 'Enter a valid email',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            onChanged: (val) => _password = val,
                            validator: (val) =>
                                val != null && val.length >= 6 ? null : 'Min 6 characters',
                          ),
                          const SizedBox(height: 16),
                          if (_error != null)
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(_isLogin ? 'Sign In' : 'Sign Up'),
                              onPressed: _loading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        await _handleEmailAuth();
                                      }
                                    },
                            ),
                          ),
                          TextButton(
                            child: Text(
                              _isLogin
                                  ? "Don't have an account? Sign Up"
                                  : "Already have an account? Sign In",
                              style: GoogleFonts.poppins(),
                            ),
                            onPressed: _loading
                                ? null
                                : () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                      _error = null;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}