// Demonte Walker and Nhung Nguyen CW3
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Pet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DigitalPetApp(),
    );
  }
}

class DigitalPetApp extends StatefulWidget {
  const DigitalPetApp({super.key});

  @override
  State<DigitalPetApp> createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  Timer? hungerTimer;
  Timer? winTimer;
  int winDuration = 0; // Duration in seconds for win condition
  TextEditingController _nameController = TextEditingController();
  bool _nameSet = false;

  // Variables to prevent multiple warnings
  bool _overfedWarningShown = false;
  bool _starvedWarningShown = false;
  bool _unhappyWarningShown = false;
  bool _goodJobShown = false;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
    _startWinTimer();
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      if (hungerLevel == 100) {
        // Pet is too hungry to play
        happinessLevel = (happinessLevel - 5).clamp(0, 100);
        _showStarvedWarning();
      } else {
        happinessLevel = (happinessLevel + 10).clamp(0, 100);
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
      }
      _resetWarningsIfNeeded();
      _checkHappinessWarning();
      _checkGoodJob();
      _checkGameOverCondition();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    setState(() {
      if (hungerLevel == 0) {
        // Pet is already full
        happinessLevel = (happinessLevel - 5).clamp(0, 100);
        _showOverfedWarning();
      } else {
        hungerLevel = (hungerLevel - 10).clamp(0, 100);
        happinessLevel = (happinessLevel + 5).clamp(0, 100);
      }
      _resetWarningsIfNeeded();
      _checkHappinessWarning();
      _checkGoodJob();
      _checkGameOverCondition();
    });
  }

  // Reset warning flags if conditions change
  void _resetWarningsIfNeeded() {
    if (hungerLevel != 0 && _overfedWarningShown) {
      _overfedWarningShown = false;
    }
    if (hungerLevel != 100 && _starvedWarningShown) {
      _starvedWarningShown = false;
    }
    if (happinessLevel > 10 && _unhappyWarningShown) {
      _unhappyWarningShown = false;
    }
  }

  // Start hunger timer
  void _startHungerTimer() {
    hungerTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      setState(() {
        if (hungerLevel == 0) {
          // Pet is overfed
          happinessLevel = (happinessLevel - 5).clamp(0, 100);
          hungerLevel = (hungerLevel + 5).clamp(0, 100); // Pet digests food over time
          _showOverfedWarning();
        } else {
          hungerLevel = (hungerLevel + 5).clamp(0, 100); // Pet gets hungrier over time
          _updateHappinessDueToHunger();
          if (hungerLevel == 100) {
            _showStarvedWarning();
          }
        }
        _resetWarningsIfNeeded();
        _checkHappinessWarning();
        _checkGameOverCondition();
      });
    });
  }

  // Update happiness based on hunger level
  void _updateHappinessDueToHunger() {
    if (hungerLevel >= 80) {
      happinessLevel = (happinessLevel - 5).clamp(0, 100);
    } else if (hungerLevel >= 60) {
      happinessLevel = (happinessLevel - 3).clamp(0, 100);
    } else if (hungerLevel >= 40) {
      happinessLevel = (happinessLevel - 2).clamp(0, 100);
    } else if (hungerLevel >= 20) {
      happinessLevel = (happinessLevel - 1).clamp(0, 100);
    }
    // No happiness decrease if hungerLevel < 20
  }

  // Start win timer
  void _startWinTimer() {
    winTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (happinessLevel > 80) {
        winDuration += 1;
        if (winDuration >= 180) { // 3 minutes
          _showWinDialog();
          winDuration = 0; // Reset winDuration for repeatable win condition
        }
      } else {
        winDuration = 0;
      }
      _resetWarningsIfNeeded();
      _checkHappinessWarning();
      _checkGoodJob();
      _checkGameOverCondition();
    });
  }

  // Check for game over condition
  void _checkGameOverCondition() {
    if ((hungerLevel == 100 && happinessLevel <= 10) ||
        (hungerLevel == 0 && happinessLevel <= 10) ||
        (hungerLevel == 0 && happinessLevel == 0) ||
        (hungerLevel == 100 && happinessLevel == 0)) {
      _showGameOverDialog();
    }
  }

  // Show overfed warning
  void _showOverfedWarning() {
    if (!_overfedWarningShown) {
      _overfedWarningShown = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: Text('$petName is overfed!'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Do not reset _overfedWarningShown here
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Show starved warning
  void _showStarvedWarning() {
    if (!_starvedWarningShown) {
      _starvedWarningShown = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: Text('$petName is starved!'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Do not reset _starvedWarningShown here
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Check for happiness warnings
  void _checkHappinessWarning() {
    if (happinessLevel <= 10 && happinessLevel > 0 && !_unhappyWarningShown) {
      _unhappyWarningShown = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: Text('$petName is very unhappy!'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Do not reset _unhappyWarningShown here
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Check for Good Job message
  void _checkGoodJob() {
    if (happinessLevel == 100 && !_goodJobShown) {
      _goodJobShown = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Good Job!'),
            content: const Text('Your pet is very happy!'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Do not reset _goodJobShown here
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Show game over dialog
  void _showGameOverDialog() {
    hungerTimer?.cancel();
    winTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissal by tapping outside or pressing back
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('$petName has left due to neglect.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  // Show win dialog
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Make the win dialog non-dismissible
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('You Win!'),
          content: Text(
              'Congrats! You\'re a great owner! $petName has been very happy for over 3 minutes.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
                // Continue the game with the same rules
              },
            ),
            ElevatedButton(
              child: const Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  // Reset game
  void _resetGame() {
    setState(() {
      happinessLevel = 50;
      hungerLevel = 50;
      winDuration = 0;
      _nameSet = false;
      _nameController.clear();
      _overfedWarningShown = false;
      _starvedWarningShown = false;
      _unhappyWarningShown = false;
      _goodJobShown = false;
    });
    _startHungerTimer();
    _startWinTimer();
  }

  // Get pet color based on happiness level
  Color _getPetColor() {
    if (happinessLevel > 70) {
      return Colors.green; // Happy
    } else if (happinessLevel >= 30) {
      return Colors.yellow; // Neutral
    } else {
      return Colors.red; // Unhappy
    }
  }

  // Get pet mood based on happiness level
  String _getPetMood() {
    if (happinessLevel > 70) {
      return 'Happy 😊';
    } else if (happinessLevel >= 30) {
      return 'Neutral 😐';
    } else {
      return 'Unhappy 😢';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_nameSet) {
      // Pet name customization screen
      return Scaffold(
        appBar: AppBar(
          title: const Text('Name Your Pet'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter a name for your pet:',
                  style: TextStyle(fontSize: 20.0),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Pet Name',
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      petName = _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'Your Pet';
                      _nameSet = true;
                    });
                  },
                  child: const Text('Confirm Name'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Main pet interaction screen
      return Scaffold(
        appBar: AppBar(
          title: const Text('Digital Pet'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Name: $petName',
                  style: const TextStyle(fontSize: 24.0),
                ),
                const SizedBox(height: 16.0),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _getPetColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getPetMood(),
                      style: const TextStyle(fontSize: 24.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Happiness Level: $happinessLevel',
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Hunger Level: $hungerLevel',
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _playWithPet,
                  child: const Text('Play with Your Pet'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _feedPet,
                  child: const Text('Feed Your Pet'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
