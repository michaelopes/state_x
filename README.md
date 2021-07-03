# StateX

O StateX tem como fundamento principal a padronização da gerência de estado de maneira 
simples e centralizada em uma store de gerenciamento. Outra vantagem desse tipo de abordagem é o ganho de performance, pois os builders trabalham de maneira a qual atende um escopo específico evitando uma mudança em toda a árvore de widgets.

### Nada melhor que um exemplo para entender o funcionamento

```dart 
//Repositório mockado para exemplificação.
class Repository {
  Future<bool> authUser(String email, String passwold) async {
    await Future.delayed(Duration(seconds: 3));
    return true;
  }
}

//Dessa forma eu é criado um novo view model onde será centralizado do gerenciamento de estado da home
class HomeViewModel extends StateXStore {
  //Dessa maneira é criado um novo atributo a ter o estado gerenciado pelo StateX
  late final xEmail = StateX.of(this)("");
  late final xPassword = StateX.of(this)("");

  final repo = Repository();

  set email(String value) => xEmail.value = value;
  String get email => xEmail.value;

  set password(String value) => xPassword.value = value;
  String get password => xPassword.value;

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  void auth() async {
    //Aqui é informado que a view estará em loading
    setLoading(true);
    if (await repo.authUser(email, password)) {
      //Aqui é informado que a view que o loading pode ser revogado
      setLoading(false);
    } else {
      //Em caso de erro assim deve ser setado a exceção
      setError(Exception("Email or password is invalid"));
    }
  }
}

void main() {
  //Aqui observer para todos os estados da aplicação útil para gerenciamento de erros ou logs dos estados da aplicação
  StateXGlobalObserver.listen((type, state) => print(type));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StateX',
      theme: ThemeData(primarySwatch: Colors.blue, accentColor: Colors.white),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var viewModel = HomeViewModel();

  @override
  void initState() {
    //Aqui é adicionado um novo observer útil para gerenciamento de erros, contudo qualquer estado que seja mudado dentro da store passará por aqui
    viewModel.addObserver((type, state, _) => print(type));
    super.initState();
  }

  @override
  dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget _buildButton(bool inLoading) {
    Widget buttonChild = inLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
            ))
        : Text("Enter");
    return Container(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: viewModel.isValid ? viewModel.auth : null,
        child: buttonChild,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("StateX"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(21),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Login do usuário',
                  ),
                  TextField(
                    onChanged: (value) {
                      viewModel.email = value;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    onChanged: (value) {
                      viewModel.password = value;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  //Exemplo usando  scoped builder
                  StateXScopedBuilder(
                    //É informado qual a store que gerenciará as mudanças nesse escopo
                    store: viewModel,
                    //Parâmetro opcional. Especifica qual atributos irá escutar as mudanças de estado, caso não passe este atributo o scoped rebuildará a cada mudança da store
                    states: [viewModel.xEmail, viewModel.xPassword],
                    onLoading: () => _buildButton(true),
                    onState: () => _buildButton(false),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  //Exemplo usando state builder
                  StateXBuilder(
                    //É informado qual a store que gerenciará as mudanças nesse builder
                    store: viewModel,
                    //Parâmetro opcional. Especifica qual atributos irá escutar as mudanças de estado, caso não passe este atributo o scoped rebuildará a cada mudança da store
                    states: [viewModel.xEmail, viewModel.xPassword],
                    //Parâmetro informo que será rebuildado quando a store estiver loading
                    includeLoading: true,
                    builder: (context, snapshot) {
                      return _buildButton(
                          snapshot.type == StateXType.isLoading);
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

```
