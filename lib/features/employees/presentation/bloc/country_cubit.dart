import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/country_repository.dart';
class CountryState { final List<String> countries; final bool loading; const CountryState({this.countries=const [],this.loading=false}); }
class CountryCubit extends Cubit<CountryState> { final CountryRepository repository; CountryCubit(this.repository):super(const CountryState()); Future<void> load() async { emit(const CountryState(loading:true)); try { emit(CountryState(countries:await repository.getCountries())); } catch (_) { emit(const CountryState()); } } }
