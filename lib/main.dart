import 'package:flutter/material.dart';

void main() {
  runApp(const Base());
}

class Base extends StatelessWidget {
  const Base({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context)=>const LineArtPage()
            )
          );
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}

enum Trend{
  up,
  flat,
  down
}

class LineArtPage extends StatefulWidget {
  const LineArtPage({super.key});

  @override
  State<LineArtPage> createState() => _LineArtPageState();
}

class _LineArtPageState extends State<LineArtPage> with SingleTickerProviderStateMixin  {
  late final AnimationController _animationController;
  Trend _state = Trend.flat;
  final List<Offset> _points = [];
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
      value: 0.0, 
    );
    
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('線を引くよー')
      ),
      body:Center(
        child: GestureDetector(
          onTap: (){
            _animationController.forward();
            _points.add(Offset(200 * _animationController.value, 200 * _animationController.value));
            debugPrint('$_points');
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (_,__){
              //debugPrint('${_animationController.value}');
              return CustomPaint(
                painter: MyCustomPainter(progless: _animationController.value),
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all()
                    ),
                    width: 200,
                    height: 200,
                ),
              );
            }
            
          ),
        ),
      )
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final double progless;
  MyCustomPainter({required this.progless});
  @override
  void paint(Canvas canvas, Size size) {
    //debugPrint('progless: $progless');
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0;
    //debugPrint('${progless * size.width}');
    canvas.drawLine(Offset(0, 0), Offset(progless * size.width, size.height * progless), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}