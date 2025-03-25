import 'package:bloc/bloc.dart';
import 'package:rick_and_morty_app/domain/entities/character.dart';
import 'package:rick_and_morty_app/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/presentation/bloc/character/character_state.dart';

class CharacterCubit extends Cubit<CharacterState> {
  final CharacterRepository repository;
  int page = 1;
  bool hasReachedMax = false;

  List<Character> getFavorites() {
    if (state is CharacterLoaded) {
      return (state as CharacterLoaded)
          .characters
          .where((character) => repository.isFavorite(character.id))
          .toList();
    }
    return [];
  }

  CharacterCubit(this.repository) : super(const CharacterInitial());

  Future<void> fetchCharacters() async {
    if (hasReachedMax) return;

    try {
      if (state is CharacterInitial) {
        emit(const CharacterLoading());
      }

      final characters = await repository.fetchCharacters(page);

      if (characters.isEmpty) {
        hasReachedMax = true;
        if (state is CharacterLoaded) {
          emit((state as CharacterLoaded).copyWith(hasReachedMax: true));
        }
      } else {
        page++;
        final currentCharacters = state is CharacterLoaded
            ? (state as CharacterLoaded).characters
            : <Character>[];
        emit(CharacterLoaded(
          characters: [...currentCharacters, ...characters],
          hasReachedMax: false,
        ));
      }
    } catch (e) {
      emit(CharacterError(message: e.toString()));
    }
  }

  Future<void> toggleFavorite(int characterId) async {
    await repository.toggleFavorite(characterId);
    // Эмитим новое состояние с обновленным списком избранных
    if (state is CharacterLoaded) {
      final currentState = state as CharacterLoaded;
      emit(currentState.copyWith(
        characters: currentState.characters,
        // Принудительно обновляем состояние
        hasReachedMax: !currentState.hasReachedMax,
      ));
    }
  }

  bool isFavorite(int characterId) {
    return repository.isFavorite(characterId);
  }
}