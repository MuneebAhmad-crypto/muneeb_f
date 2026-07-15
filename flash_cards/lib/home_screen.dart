import 'package:flutter/material.dart';
import 'flash_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool showAnswer = false;

  void flipCard() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  final List<FlashCard> cards = [
    FlashCard(
      question: "Who is the founder of Pakistan?",
      answer: "Muhammad Ali Jinnah",
    ),
    FlashCard(
      question: "What is the capital of Pakistan?",
      answer: "Islamabad",
    ),
    FlashCard(
      question: "Which planet is known as the Red Planet?",
      answer: "Mars",
    ),
  ];
  void nextCard() {
    if (currentIndex < cards.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
      });
    }
  }

  void previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = cards[currentIndex];

    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text(
          "GK Flash Cards",
          style: TextStyle(color: Colors.white),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              "Card ${currentIndex + 1} / ${cards.length}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: flipCard,

              child: Card(
                elevation: 8,

                child: Container(
                  height: 250,
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),

                  child: Text(
                    showAnswer ? currentCard.answer : currentCard.question,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                ElevatedButton(
                  onPressed: previousCard,
                  child: const Text("Previous"),
                ),

                ElevatedButton(onPressed: nextCard, child: const Text("Next")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
