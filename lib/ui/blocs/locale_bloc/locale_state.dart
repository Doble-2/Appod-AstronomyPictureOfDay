part of 'locale_bloc.dart';

sealed class LocaleState extends Equatable {
  final Language selectedLanguage;
  const LocaleState({Language? language})
      : selectedLanguage = language ?? Language.english;

  @override
  List<Object> get props => [selectedLanguage];
}

final class LocaleInitial extends LocaleState {}

final class LocaleChanged extends LocaleState {
  const LocaleChanged({super.language});
}