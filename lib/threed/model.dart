import 'dart:core';
import 'dart:ui';
import 'package:vector_math/vector_math.dart';

/*
 *  A very simple Wavefront .OBJ parser.
 *  https://en.wikipedia.org/wiki/Wavefront_.obj_file
 */
class Model {
  List<Vector3> verts;
  List<List<int>> faces;

  List<Color> colors;
  Map<String, Color> materials;

  /* 
   *  Converts normalised color values to a Color()
   */
  Color _toRGBA(double r, double g, double b) {
    return Color.fromRGBO(
        (r * 255).toInt(), (g * 255).toInt(), (b * 255).toInt(), 1);
  }

  Model() {
    verts = List<Vector3>();
    faces = List<List<int>>();
    colors = List<Color>();
    materials = {
//      "frontal": _toRGBA(0.848100, 0.607500, 1.000000),
//      "occipital": _toRGBA(1.000000, 0.572600, 0.392400),
//      "parietal": _toRGBA(0.379700, 0.830900, 1.000000),
//      "temporal": _toRGBA(1.000000, 0.930700, 0.468300),
//      "cerebellum": _toRGBA(0.506300, 1.000000, 0.598200),
//      "stem": _toRGBA(0.500000, 0.500000, 0.500000)
      "aiStandardSurface3SG.001": _toRGBA(0.069978, 0.023237, 0.014060),
      "aiStandardSurface2SG": _toRGBA(0.382369, 0.900000, 0.227184),
      "aiStandardSurface1SG": _toRGBA(0.382369, 0.900000, 0.227184),
      "aiStandardSurface3SG": _toRGBA(0.1294, 0.560784, 0.141176),

      "led": _toRGBA(0.900000, 0.003432, 0.0014366),
    };
  }

  /*
   *  Parses the object from a string.
   */
  void loadFromString(String string) {
    String material;
    List<String> lines = string.split("\n");
    lines.forEach((line) {
      // Parse a vertex
      if (line.startsWith("v ")) {
        var values = line.substring(2).split(" ");
        verts.add(Vector3(
          double.parse(values[0]),
          double.parse(values[1]),
          double.parse(values[2]),
        ));
      }
      // Parse a material reference
      else if (line.startsWith("usemtl ")) {
        material = line.substring(7);
      }
      // Parse a face
      else if (line.startsWith("f ")) {
        var values = line.substring(2).split(" ");
        faces.add(List.from([
          int.parse(values[0].split("/")[0]),
          int.parse(values[1].split("/")[0]),
          int.parse(values[2].split("/")[0]),
        ]));
        colors.add(materials[material]);
      }
    });
  }
}
