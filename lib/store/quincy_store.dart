import 'package:flutter_bloc/flutter_bloc.dart';

class QuincyStore{
  String? _password;
  QuincyStore({
    password
  }) {
    _password = password;
  }
  void set password(v) {
    _password = v;
  }
  String? get password {
    return _password;
  }
}

class QuincyStoreCubit extends Cubit<QuincyStore>{
  QuincyStoreCubit(): super(QuincyStore());
  updatePwd(String v) {
    state.password = v;
  }
  
}