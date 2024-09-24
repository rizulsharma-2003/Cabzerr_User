import 'package:bloc/bloc.dart';
import 'package:cablow_user/apiServices.dart';
import 'package:meta/meta.dart';

part 'ride_history_event.dart';
part 'ride_history_state.dart';

class RideHistoryBloc extends Bloc<RideHistoryEvent, RideHistoryState> {
  RideHistoryBloc() : super(RideHistoryInitial()) {
    on<FetchRideHistoryEvent>((event, emit) async {
      try{
        emit(RideHistoryLoading());
        final historyData= await ApiServices().getRideHistory();
        if(historyData!=null){
          emit(RideHistorySuccess(historyData: historyData));
        }else{
          emit(RideHistoryFailed());
        }
      } catch(e){
        emit(RideHistoryFailed());
      }
    });
  }
}
