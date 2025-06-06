import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'login_page.dart'; // or your signup page

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for slides
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = index == 2;
              });
            },
            children: [
              buildPage(
                imagePath: 'assets/images/login_signup/intro1.jpg',
                title: 'Welcome to REELORA',
                description: 'Stream top-rated and trending movies anywhere.',
              ),
              buildPage(
                imagePath: 'assets/images/login_signup/intro2.jpg',
                title: 'Unlimited Entertainment',
                description: 'No ads. No limits. Just endless entertainment.',
              ),
              buildPage(
                imagePath: 'assets/images/login_signup/intro3.jpg',
                title: 'Start Your Journey',
                description: 'Get started and enjoy your favorite content now!',
              ),
            ],
          ),

          // Bottom content: indicator + button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: const Color.fromARGB(255, 32, 115, 239),
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
                const SizedBox(height: 30),
                if (onLastPage)
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                            );
                          },
                          child: const Text(
                            'Get Started',
                            style: TextStyle(fontSize: 18, color: Colors.white70),
                          ),
                        )
                else
                  TextButton(
                    onPressed: () {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper for each page
  Widget buildPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

