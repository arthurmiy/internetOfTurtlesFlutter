library flutter_3d_obj;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:internetofturtles/threed/utils.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart' as Math;

import 'model.dart';

class Object3D extends StatefulWidget {
  final Size size;
  final String path;
  final double zoom;
  bool ledOn;
  double angleX;
  double angleY;
  double angleZ;

  Object3D(this.angleX, this.angleY, this.angleZ, this.ledOn,
      {@required this.size, @required this.path, @required this.zoom});

  @override
  _Object3DState createState() => _Object3DState();
}

class _Object3DState extends State<Object3D> {
  double zoom = 0.0;

  Model model;

  /*
   *  Load the 3D  data from a file in our /assets folder.
   */
  void initState() {
    rootBundle.loadString(widget.path).then((value) {
      setState(() {
        model = Model();
        model.loadFromString(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double az, ax;
    ax = widget.angleX;
    az = widget.angleZ;

//    if (widget.angleX > 360)
//      ax = widget.angleX - 360;
//    else if (widget.angleX < 0) ax = 360 - widget.angleX.abs();
//
//    if (widget.angleZ > 360)
//      az = widget.angleZ - 360;
//    else if (widget.angleZ < 0) az = 360 - widget.angleZ.abs();
//
//    if (ax > 90) az = widget.angleZ - 180;

    print('x ${widget.angleX}');
    print('z ${widget.angleZ}');

    // print(widget.angleZ);

//    return CustomPaint(
//      painter: _ObjectPainter(widget.size, model, -widget.angleX + 90, 180,
//          widget.angleZ + 180, widget.zoom, widget.ledOn),
//      size: widget.size,
//    );

    return CustomPaint(
      painter: _ObjectPainter(widget.size, model, 180 - widget.angleX,
          -widget.angleZ + 270, 90, widget.zoom, widget.ledOn),
      size: widget.size,
    );
  }
}

/*
 *  To render our 3D model we'll need to implement the CustomPainter interface and
 *  handle drawing to the canvas ourselves.
 *  https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
 */
class _ObjectPainter extends CustomPainter {
  double _viewPortX = 10.0;
  double _viewPortY = 10.0;
  double _zoom = 0.0;

  Math.Vector3 camera;
  Math.Vector3 light;
  bool ledOn;

  double angleX;
  double angleY;
  double angleZ;

  Size size;

  List<Math.Vector3> verts;

  final Model model;

  _ObjectPainter(this.size, this.model, this.angleX, this.angleY, this.angleZ,
      this._zoom, this.ledOn) {
    camera = Math.Vector3(0.0, 0.0, 0.0);
    light = Math.Vector3(0.0, 0.0, 100.0);
    verts = List<Math.Vector3>();
    _viewPortX = (size.width / 2).toDouble() + 50;
    _viewPortY = (size.height / 2).toDouble() + 60;
  }

  /*
   *  We use a 4x4 matrix to perform our rotation, translation and scaling in
   *  a single pass.
   *  https://www.euclideanspace.com/maths/geometry/affine/matrix4x4/index.htm
   */
  Math.Vector3 _calcVertex(Math.Vector3 vertex) {
    var trans = Math.Matrix4.translationValues(_viewPortX, _viewPortY, 1);
    trans.scale(_zoom, -_zoom);
    trans.rotateX(Utils.degreeToRadian(angleX));
    trans.rotateY(Utils.degreeToRadian(angleY));
    trans.rotateZ(Utils.degreeToRadian(angleZ));
    return trans.transform3(vertex);
  }

  /*
   *  Calculate the lighting and paint the polygon on the canvas.
   */
  void _drawFace(Canvas canvas, List<int> face, Color color) {
    // Reference the rotated vertices
    var v1 = verts[face[0] - 1];
    var v2 = verts[face[1] - 1];
    var v3 = verts[face[2] - 1];

    // Calculate the surface normal
    var normalVector = Utils.normalVector3(v1, v2, v3);

    // Calculate the lighting
    Math.Vector3 normalizedLight = Math.Vector3.copy(light).normalized();
    var jnv = Math.Vector3.copy(normalVector).normalized();
    var normal = Utils.scalarMultiplication(jnv, normalizedLight);
    var brightness = normal.clamp(0.0, 1.0);

    var r = (brightness * color.red).toInt();
    var g = (brightness * color.green).toInt();
    var b = (brightness * color.blue).toInt();
    // Assign a lighting color
    if (color == _toRGBA(0.900000, 0.003432, 0.0014366)) {
      r = (color.red).toInt();
      g = (color.green).toInt();
      b = (color.blue).toInt();
    }
    var paint = Paint();
    paint.color = Color.fromARGB(255, r, g, b);
    paint.style = PaintingStyle.fill;

    // Paint the face
    var path = Path();
    path.moveTo(v1.x, v1.y);
    path.lineTo(v2.x, v2.y);
    path.lineTo(v3.x, v3.y);
    path.lineTo(v1.x, v1.y);
    path.close();
    canvas.drawPath(path, paint);
  }

  /*
   *  Override the paint method.  Rotate the verticies, sort and finally render
   *  our 3D model.
   */
  @override
  void paint(Canvas canvas, Size size) {
    // If we've not loaded the model then there's nothing to render
    if (model == null) {
      return;
    }

    // Rotate and translate the vertices
    verts = List<Math.Vector3>();
    for (int i = 0; i < model.verts.length; i++) {
      verts.add(_calcVertex(Math.Vector3.copy(model.verts[i])));
    }

    // Sort
    var sorted = List<Map<String, dynamic>>();
    for (var i = 0; i < model.faces.length; i++) {
      var face = model.faces[i];
      sorted.add({
        "index": i,
        "order": Utils.zIndex(
            verts[face[0] - 1], verts[face[1] - 1], verts[face[2] - 1])
      });
    }
    sorted.sort((Map a, Map b) => a["order"].compareTo(b["order"]));

    // Render
    for (int i = 0; i < sorted.length; i++) {
      var face = model.faces[sorted[i]["index"]];
      var color = model.colors[sorted[i]["index"]];
      if (color == _toRGBA(0.900000, 0.003432, 0.0014366)) {
        //pino
        if (!ledOn) {
          color = _toRGBA(1, 1, 1);
        }
      }
      _drawFace(canvas, face, color);
    }
  }

  /*
   *  We only want to repaint the canvas when the scene has changed.
   */
  @override
  bool shouldRepaint(_ObjectPainter old) {
    return true;
  }

  Color _toRGBA(double r, double g, double b) {
    return Color.fromRGBO(
        (r * 255).toInt(), (g * 255).toInt(), (b * 255).toInt(), 1);
  }
}
