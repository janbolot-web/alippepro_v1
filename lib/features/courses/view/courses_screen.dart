import 'package:alippepro_v1/features/courseDetail/courseDetail.dart';
import 'package:alippepro_v1/features/courses/widgets/shimmer_loader.dart';
import 'package:alippepro_v1/services/course_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CoursesScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final myCourse;
  const CoursesScreen({super.key, this.myCourse});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseService courseService = CourseService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> courses = [];
  bool isLoading = true;
  final colors = [
    const Color(0xff0241e9),
    const Color(0xff755ee9),
    const Color(0xff3c47a4),
    const Color(0xffda2fd3),
    const Color(0xff9b0850),
    const Color(0xff423407),
    const Color(0xffc5b442),
    const Color(0xff088273),
    const Color.fromARGB(132, 8, 130, 116),
    const Color(0xffBA0F43),
    const Color.fromARGB(107, 186, 15, 66),
  ];

  @override
  void initState() {
    super.initState();
    fetchAllCourses();
    _searchController.addListener(() {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(
              'Курстар',
              style: GoogleFonts.rubik(
                fontSize: 24,
                color: const Color(0xff1b434d),
                fontWeight: FontWeight.bold,
              ),
            ),
            floating: true,
            snap: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                ),
                child: Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    height: 20,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => searchCourse(),
                      style: const TextStyle(fontFamily: 'Montserrat'),
                      decoration: const InputDecoration(
                        hintText: 'Издөө...',
                        hintStyle: TextStyle(fontFamily: 'Montserrat'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilterButton(
                    text: 'Баары',
                    color: const Color(0xff1b434d),
                    icon: 'assets/img/category-2.png',
                  ),
                  FilterButton(
                    text: 'Менин курстарым',
                    color: Colors.white,
                    icon: 'assets/img/archive-tick.png',
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    1.8, // This sets the aspect ratio to be non-square
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (isLoading) {
                    return const ShimmerLoader();
                  }

                  return GestureDetector(
                    onTap: () {
                      Get.to(CourseDetailScreen(
                          idCourse: courses[index]['id'],
                          bgImage: courses[index]?['bgImage']));
                    },
                    child: CourseCard(
                      bg: courses[index]?['bgImage'] ??
                          'assets/img/bgSatuu.png',
                      text: courses[index]['title'],
                      color: colors[index % colors.length],
                    ),
                  );
                },
                childCount: isLoading ? 6 : courses.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAllCourses() async {
    courses = await courseService.getAllCourses(context);
    setState(() {
      isLoading = false;
    });
  }

  Future searchCourse() async {
    if (_searchController.text.isEmpty) {
      await fetchAllCourses();
      return;
    }
    courses = await courseService.searchCourse(
        context: context, key: _searchController.text);
    setState(() {});
  }
}

// ignore: must_be_immutable
class FilterButton extends StatelessWidget {
  final String text;
  Color color;
  final String icon;

  FilterButton(
      {super.key, required this.text, required this.icon, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Add filter functionality here
      },
      icon: Row(
        children: [
          Image.asset(
            icon,
            width: 30,
            height: 30,
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      label: Text(
        text,
        style: GoogleFonts.rubik(
          color: color == Colors.white ? const Color(0xff054E45) : Colors.white,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.only(left: 5, right: 15),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String text;
  final Color color;
  final String bg;

  const CourseCard(
      {super.key, required this.text,
      required this.color,
      this.bg = 'assets/img/bgSatuu.png'});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(image: NetworkImage('https://alippebucket.s3.eu-north-1.amazonaws.com/coursesBg.png'), fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          textAlign: TextAlign.end,
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
