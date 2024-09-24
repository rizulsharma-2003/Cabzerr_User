import 'package:bloc/bloc.dart';
import 'package:cablow_user/apiServices.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<SendLoginEvent>((event, emit) async {
      emit(LoginLoading());
      try{
        final res= await ApiServices().loginDriver(mobileNumber: event.mobileNo, name: event.name);
        if(res!=null){
          emit(LoginSuccess(res: res));
        }else{
          emit(LoginFailed());
        }
      }catch(e){
        emit(LoginFailed());
      }
    });
  }
}
