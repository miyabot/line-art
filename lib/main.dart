import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(
  DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => Base(), // Wrap your app
  ),
);

class Base extends StatelessWidget {
  const Base({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
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


class LinePoint {
  final Offset offset;
  final Color color;
  LinePoint(this.offset, this.color);
}

class LineArtPage extends StatefulWidget {
  const LineArtPage({super.key});

  @override
  State<LineArtPage> createState() => _LineArtPageState();
}

class _LineArtPageState extends State<LineArtPage> with SingleTickerProviderStateMixin  {
  late final AnimationController _animationController;
  Trend _state = Trend.up;
  final List<LinePoint> _points = [];
  bool startFlg = false;

  double get _currentY {
    final lastPoint = _points.isEmpty ? Offset(0, 150) : _points.last.offset;
    final dx = _animationController.value * 300 - lastPoint.dx;
    return _state == Trend.up ? lastPoint.dy - dx : _state == Trend.down ? lastPoint.dy + dx : lastPoint.dy;
  }

  // create some values
Color pickerColor = Color(0xff443a49);
Color currentColor = Color(0xff443a49);

// ValueChanged<Color> callback
void changeColor(Color color) {
  setState(() => pickerColor = color);
}

  Widget _buildButton(IconData icon,Trend trend){
    return ElevatedButton(
            onPressed: (){
              if(!startFlg){
                startFlg = true;
                _state = trend;
                _animationController.forward();
              }
              else{
                setState(() {
                  _points.add(LinePoint(Offset(300 * _animationController.value, _currentY),currentColor));
                  _state = trend;
                });
              }
            }, 
            style:ElevatedButton.styleFrom(
              minimumSize: Size(100, 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // 任意の角丸さを指定
              ),
            ),
            child: Icon(icon,size: 50)
          );
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
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (_,__){
                //debugPrint('${_animationController.value}');
                return CustomPaint(
                  painter: MyCustomPainter(
                    progless: _animationController.value,
                    points: _points,
                    state: _state,
                    color: currentColor
                  ),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all()
                      ),
                      width: 300,
                      height: 300,
                  ),
                );
              }
              
            ),
          ),
          SizedBox(height: 16,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildButton(Icons.arrow_upward_outlined, Trend.up),
              _buildButton(Icons.arrow_downward_outlined, Trend.down),
              _buildButton(Icons.arrow_right_alt_outlined, Trend.flat),
            ],
          ),
          ElevatedButton(
            onPressed: (){
              showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                  title: const Text('Pick a color!'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: changeColor,
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text('Got it'),
                      onPressed: () {
                        setState(() => currentColor = pickerColor);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
                }
              );
            }, 
            child: Icon(Icons.color_lens)
          )
        ],
      )
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final double progless;
  final List<LinePoint> points;
  final Trend state;
  final Color color;
  MyCustomPainter({required this.progless,required this.points,required this.state,required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, 150);

    for (final point in points) {
      path.lineTo(point.offset.dx, point.offset.dy);
    }

    // 最後のタップ地点
    final lastPoint = points.isEmpty ? Offset(0, 150) : points.last.offset;
    
    // 進んだx距離
    final dx = progless * size.width - lastPoint.dx;
    
    // 現在の先端のy
    double currentY;
    if (state == Trend.up) {
      currentY = lastPoint.dy - dx; // 上に向かう
    } else if(state == Trend.down){
      currentY = lastPoint.dy + dx; // 下に向かう
    }
    else{
      currentY = lastPoint.dy;
    }

    path.lineTo(progless * size.width, currentY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}