import 'dart:async';
import 'package:flutter/material.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Avatar + progress/milestones
  int? _selectedAvatar;
  double _progress = 0.0;
  final Set<int> _hitMilestones = {};
  bool _pulse = false;

  @override
  void initState() {
    super.initState();
    // Live progress updates
    _nameController.addListener(_recomputeProgress);
    _emailController.addListener(_recomputeProgress);
    _dobController.addListener(_recomputeProgress);
    _passwordController.addListener(() {
      _recomputeProgress();
      setState(() {}); // live refresh for strength meter label/color
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Date Picker Function
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  // Password Stregnth Meter
  double get _passwordStrength {
    final t = _passwordController.text;
    if (t.isEmpty) return 0.0;
    int score = 0;
    if (t.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(t) && RegExp(r'[a-z]').hasMatch(t)) score++;
    if (RegExp(r'\d').hasMatch(t)) score++;
    if (RegExp(r'''[!@#\$%^&*(),.?":{}|<>_\-+=~`\\/\[\];']''').hasMatch(t))
      score++;
    return (score / 4).clamp(0.0, 1.0);
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s < 0.25) return Colors.red;
    if (s < 0.50) return Colors.orange;
    if (s < 0.75) return Colors.amber;
    return Colors.green;
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s < 0.25) return 'Very weak';
    if (s < 0.50) return 'Weak';
    if (s < 0.75) return 'Good';
    return 'Strong';
  }

  // Progress Tracker
  void _recomputeProgress() {
    final parts = <bool>[
      _nameController.text.trim().isNotEmpty,
      _emailController.text.trim().isNotEmpty,
      _dobController.text.trim().isNotEmpty,
      _passwordController.text.isNotEmpty,
      _selectedAvatar != null,
    ];
    final filled = parts.where((b) => b).length;
    final newProgress = filled / parts.length;

    if (newProgress != _progress) {
      final old = _progress;
      setState(() => _progress = newProgress);
      _checkMilestones(old, _progress);
    }
  }

  void _checkMilestones(double oldVal, double newVal) {
    const thresholds = [0.25, 0.50, 0.75, 1.00];
    for (final t in thresholds) {
      final key = (t * 100).round();
      if (!_hitMilestones.contains(key) && oldVal < t && newVal >= t) {
        _hitMilestones.add(key);
        _celebrate(key);
      }
    }
  }

  void _celebrate(int percent) {
    // quick pulse + snackbar
    setState(() => _pulse = true);
    Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _pulse = false);
    });

    final msg = switch (percent) {
      25 => 'Nice start — 25% complete!',
      50 => 'Halfway there — 50%!',
      75 => 'Almost done — 75%!',
      100 => 'Woohoo! 100% complete!',
      _ => 'Milestone hit!',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAvatar == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please choose an avatar')));
      return;
    }

    setState(() => _isLoading = true);

    // Build badges (simple logic)
    final strong = _passwordStrength >= 0.75;
    final early = DateTime.now().hour < 12; // before 12 PM
    final full = _progress >= 1.0;

    final badges = <String>[
      if (strong) 'Strong Password Master',
      if (early) 'The Early Bird Special',
      if (full) 'Profile Completer',
    ];

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            userName: _nameController.text,
            avatarIndex: _selectedAvatar!,
            badges: badges,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Local avatar list (keeps file simple)
    const _avatarIcons = <IconData>[
      Icons.rocket_launch,
      Icons.sports_basketball,
      Icons.pets,
      Icons.music_note,
      Icons.star,
    ];

    final percent = (_progress * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account 🎉'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Animated Form Header
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: Colors.deepPurple[800],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Complete your adventure profile!',
                              style: TextStyle(
                                color: Colors.deepPurple[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Adventure Progress Tracker
                    Row(
                      children: [
                        const Text(
                          'Signup Progress',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text('$percent%'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(Colors.red, Colors.green, _progress) ??
                              Colors.red,
                        ),
                        backgroundColor: Colors.black12,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Field
                    _buildTextField(
                      controller: _nameController,
                      label: 'Adventure Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'What should we call you on this adventure?';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'We need your email for adventure updates!';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Oops! That doesn\'t look like a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // DOB w/Calendar
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.deepPurple,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: _selectDate,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'When did your adventure begin?';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Field w/ Toggle
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Secret Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.deepPurple,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Every adventurer needs a secret password!';
                        }
                        if (value.length < 6) {
                          return 'Make it stronger! At least 6 characters';
                        }
                        return null;
                      },
                    ),

                    // Password Strength Meter
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              minHeight: 10,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _strengthColor,
                              ),
                              backgroundColor: Colors.black12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _strengthLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _strengthColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Avatar Selection
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose an Avatar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(_avatarIcons.length, (i) {
                        final selected = _selectedAvatar == i;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedAvatar = i);
                            _recomputeProgress();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? Colors.deepPurple
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: Colors.deepPurple.withOpacity(
                                          0.25,
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.deepPurple[50],
                              child: Icon(
                                _avatarIcons[i],
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 30),

                    // Submit Button w/ Loading Animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isLoading ? 60 : double.infinity,
                      height: 60,
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepPurple,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 5,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start My Adventure',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.rocket_launch,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tiny celebratory pulse icon (milestones)
          Positioned(
            right: 16,
            top: 12,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 450),
              scale: _pulse ? 1.4 : 1.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 450),
                opacity: _pulse ? 1 : 0.3,
                child: const Icon(
                  Icons.celebration,
                  size: 32,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}
