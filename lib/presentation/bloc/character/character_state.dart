import 'package:equatable/equatable.dart';
import 'package:rick_and_morty_app/domain/entities/character.dart';

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object> get props => [];
}

class CharacterInitial extends CharacterState {
  const CharacterInitial();
}

class CharacterLoading extends CharacterState {
  const CharacterLoading();
}

class CharacterLoaded extends CharacterState {
  final List<Character> characters;
  final bool hasReachedMax;

  const CharacterLoaded({
    required this.characters,
    this.hasReachedMax = false,
  });

  CharacterLoaded copyWith({
    List<Character>? characters,
    bool? hasReachedMax,
  }) {
    return CharacterLoaded(
      characters: characters ?? this.characters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [characters, hasReachedMax];
}

class CharacterError extends CharacterState {
  final String message;

  const CharacterError({required this.message});

  @override
  List<Object> get props => [message];
}