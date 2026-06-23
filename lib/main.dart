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
  //flat,
  down
}

class LineArtPage extends StatefulWidget {
  const LineArtPage({super.key});

  @override
  State<LineArtPage> createState() => _LineArtPageState();
}

class _LineArtPageState extends State<LineArtPage> with SingleTickerProviderStateMixin  {
  late final AnimationController _animationController;
  Trend _state = Trend.up;
  final List<Offset> _points = [];
  bool startFlg = false;

  double get _currentY {
    final lastPoint = _points.isEmpty ? Offset(0, 100) : _points.last;
    final dx = _animationController.value * 200 - lastPoint.dx;
    return _state == Trend.up ? lastPoint.dy - dx : lastPoint.dy + dx;
  }
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
            if(!startFlg){
              startFlg = true;
              _animationController.forward();
            }
            else{
              setState(() {
                _points.add(Offset(200 * _animationController.value, _currentY));
                debugPrint('$_points');
                if(_state == Trend.up) {
                  _state = Trend.down;
                } else if(_state == Trend.down){
                  _state = Trend.up;
                }
              });
            }
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (_,__){
              //debugPrint('${_animationController.value}');
              return CustomPaint(
                painter: MyCustomPainter(
                  progless: _animationController.value,
                  points: _points,
                  state: _state,
                ),
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
  final List<Offset> points;
  final Trend state;
  MyCustomPainter({required this.progless,required this.points,required this.state});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, 100);

    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }

    // 最後のタップ地点
    final lastPoint = points.isEmpty ? Offset(0, 100) : points.last;
    
    // 進んだx距離
    final dx = progless * size.width - lastPoint.dx;
    
    // 現在の先端のy
    double currentY;
    if (state == Trend.up) {
      currentY = lastPoint.dy - dx; // 上に向かう
    } else {
      currentY = lastPoint.dy + dx; // 下に向かう
    }

    path.lineTo(progless * size.width, currentY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}