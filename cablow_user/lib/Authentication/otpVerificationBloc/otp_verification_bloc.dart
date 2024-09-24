import 'package:bloc/bloc.dart';
import 'package:cablow_user/apiServices.dart';
import 'package:meta/meta.dart';

part 'otp_verification_event.dart';
part 'otp_verification_state.dart';

class OtpVerificationBloc extends Bloc<OtpVerificationEvent, OtpVerificationState> {
  OtpVerificationBloc() : super(OtpVerificationInitial()) {
    on<VerifyOtpVerificationEvent>((event, emit) async {
      emit(OtpVerificationLoading());
      try{
        final res= await ApiServices().verifyOtpAuth(event.mobleNo.toString(), event.otp.toString());
        print(res.runtimeType);
        if(res is String){
          emit(OtpVerificationSuccess(res: res));
        }else if(res==0){
          emit(DocumentsNotSubmitted());
        }else if(res==1){
          emit(DocumentsNotApproved());
        }
        else{
          emit(OtpVerificationFailed());
        }
      }catch(e){
        print('otp verification bloc $e');
        emit(OtpVerificationFailed());
      }
    });
  }
}
