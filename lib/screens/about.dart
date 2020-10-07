import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  static const String rout = '/about';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Internet of Turtles',
              style: Theme.of(context).textTheme.title,
            ),
            //todo put image
            Text(
              'Bibliotecas usadas',
              style: Theme.of(context).textTheme.title,
            ),
            Text(
                '\nAqui estão as licenças dos softwares ou trechos de software utilizados para o desenvolvimento do app\n\n'),
            Expanded(
              child: StreamBuilder(
                stream: getFileData('assets/licenses.txt').asStream(),
                builder: (context, data) {
                  if (!data.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return SingleChildScrollView(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(data.data),
                    ));
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }
}
