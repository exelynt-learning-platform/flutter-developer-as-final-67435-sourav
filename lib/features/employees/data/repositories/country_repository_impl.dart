import '../../domain/repositories/country_repository.dart';
import '../datasources/country_remote_data_source.dart';
class CountryRepositoryImpl implements CountryRepository { final CountryRemoteDataSource remote; CountryRepositoryImpl(this.remote); @override Future<List<String>> getCountries()=>remote.getCountries(); }
