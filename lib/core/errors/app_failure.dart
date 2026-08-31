import 'package:equatable/equatable.dart';

class AppFailure extends Equatable {
  final String message;
  final Object? cause;

  const AppFailure(this.message, {this.cause});

  @override
  List<Object?> get props => [message, cause];
}
