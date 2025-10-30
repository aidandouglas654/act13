import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';

class SuccessScreen extends StatefulWidget {
  final String userName;
  final int avatarIndex; // NEW
  final List<String> badges; // NEW

  const SuccessScreen({
    super.key,
    required this.userName,
    required this.avatarIndex,
    required this.badges,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // mirror avatar choices locally
    const _avatarIcons = <IconData>[
      Icons.rocket_launch,
      Icons.sports_basketball,
      Icons.pets,
      Icons.music_note,
      Icons.star,
    ];

    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.deepPurple,
                Colors.purple,
                Colors.blue,
                Colors.green,
                Colors.orange,
              ],
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar chosen
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.deepPurple[50],
                    child: Icon(
                      _avatarIcons[widget.avatarIndex % _avatarIcons.length],
                      color: Colors.deepPurple,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Celebration icon
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Personalized Welcome
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Welcome, ${widget.userName}! 🎉',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your adventure begins now!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  // Badges
                  if (widget.badges.isNotEmpty) ...[
                    const Text(
                      'Achievements unlocked:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: widget.badges.map((b) {
                        final (icon, color) = switch (b) {
                          'Strong Password Master' => (
                            Icons.lock,
                            Colors.green,
                          ),
                          'The Early Bird Special' => (
                            Icons.wb_sunny,
                            Colors.orange,
                          ),
                          'Profile Completer' => (Icons.task_alt, Colors.blue),
                          _ => (Icons.emoji_events, Colors.purple),
                        };
                        return Chip(
                          avatar: Icon(icon, color: Colors.white, size: 18),
                          label: Text(b),
                          backgroundColor: color,
                          labelStyle: const TextStyle(color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // More confetti
                  ElevatedButton(
                    onPressed: () => _confettiController.play(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'More Celebration!',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
