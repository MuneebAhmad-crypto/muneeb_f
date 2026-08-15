import 'package:flutter/material.dart';

void main() {
  runApp(const CourseCatalogApp());
}

class CourseCatalogApp extends StatelessWidget {
  const CourseCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const CourseCatalogScreen(),
    );
  }
}

class Course {
  final String title;
  final String instructor;
  final String price;
  final String rating;
  final String imageUrl;

  Course({
    required this.title,
    required this.instructor,
    required this.price,
    required this.rating,
    required this.imageUrl,
  });
}

class CourseCatalogScreen extends StatefulWidget {
  const CourseCatalogScreen({super.key});

  @override
  State<CourseCatalogScreen> createState() => _CourseCatalogScreenState();
}

class _CourseCatalogScreenState extends State<CourseCatalogScreen> {
  final List<Course> _allCourses = [
    Course(
      title: 'Master Flutter & Dart',
      instructor: 'Dr. Angela Yu',
      price: '\$49.99',
      rating: '4.9',
      imageUrl: 'https://picsum.photos/seed/flutter/320/180',
    ),
    Course(
      title: 'Python for Data Science',
      instructor: 'Jose Portilla',
      price: '\$39.99',
      rating: '4.8',
      imageUrl: 'https://picsum.photos/seed/python/320/180',
    ),
    Course(
      title: 'UI/UX Design Masterclass',
      instructor: 'Daniel Walter',
      price: '\$59.99',
      rating: '4.7',
      imageUrl: 'https://picsum.photos/seed/design/320/180',
    ),
    Course(
      title: 'Full-Stack Web Development',
      instructor: 'Colt Steele',
      price: '\$69.99',
      rating: '4.9',
      imageUrl: 'https://picsum.photos/seed/web/320/180',
    ),
  ];

  List<Course> _displayedCourses = [];

  @override
  void initState() {
    super.initState();
    _displayedCourses = _allCourses;
  }

  void _filterCourses(String query) {
    setState(() {
      _displayedCourses = _allCourses
          .where((course) =>
              course.title.toLowerCase().contains(query.toLowerCase()) ||
              course.instructor.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Discover Courses'),
            floating: true,
            pinned: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  onChanged: _filterCourses,
                  decoration: InputDecoration(
                    hintText: 'Search for courses or instructors',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_displayedCourses.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No courses found.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => CourseCard(course: _displayedCourses[index]),
                  childCount: _displayedCourses.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  course.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(178),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          course.rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.instructor,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        course.price,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Enroll Now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
