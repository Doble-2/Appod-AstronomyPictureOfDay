import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/utils/language.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(LocaleInitial()) {
    on<ChangeLanguage>(_onChangeLanguage);
  }

  _onChangeLanguage(ChangeLanguage event, Emitter<LocaleState> emit) {
    emit(LocaleChanged(language: event.selectedLanguage));
  }
}