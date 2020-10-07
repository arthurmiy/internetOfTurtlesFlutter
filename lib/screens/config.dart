import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:internetofturtles/scripts/sharedPrefFunctions.dart';

class ConfigurationPage extends StatefulWidget {
  static const String rout = '/config';
  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  int selected = 0;

  GlobalKey<AsyncLoaderState> _asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();

  reload() {
    _asyncLoaderState.currentState.reloadState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Configurações',
          ),
        ),
        body: AsyncLoader(
            key: _asyncLoaderState,
            initState: () async =>
                await retrieveDefaultScreen(DEFAULT_SCREEN_SP_ROUT),
            renderLoad: () => Center(child: CircularProgressIndicator()),
            renderError: ([error]) =>
                Center(child: Text("Erro ao carregar dados")),
            renderSuccess: ({data}) {
              selected = data as int;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Ao conectar ir para:',
                        style: Theme.of(context).textTheme.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    OutlineButton(
                      child: Text('Tela de dados'),
                      onPressed: (selected == 0)
                          ? null
                          : () {
                              setState(() {
                                selected = 0;
                                saveDefaultScreen(DEFAULT_SCREEN_SP_ROUT, 0);
                                reload();
                              });
                            },
                    ),
                    OutlineButton(
                      child: Text('Tela de gráficos'),
                      onPressed: (selected == 1)
                          ? null
                          : () {
                              setState(() {
                                selected = 1;
                                saveDefaultScreen(DEFAULT_SCREEN_SP_ROUT, 1);
                                reload();
                              });
                            },
                    ),
                    OutlineButton(
                      child: Text('Tela de orientação 3D'),
                      onPressed: (selected == 2)
                          ? null
                          : () {
                              setState(() {
                                selected = 2;
                                saveDefaultScreen(DEFAULT_SCREEN_SP_ROUT, 2);
                                reload();
                              });
                            },
                    ),
                    OutlineButton(
                      child: Text('Menu de seleção'),
                      onPressed: (selected == 3)
                          ? null
                          : () {
                              setState(() {
                                selected = 3;
                                saveDefaultScreen(DEFAULT_SCREEN_SP_ROUT, 3);
                                reload();
                              });
                            },
                    ),
                  ],
                ),
              );
            }));
  }
}
