import '../entities/character.dart';

abstract class CharacterRepository {
  Future<List<Character>> fetchCharacters(int page);
  List<Character> getFavorites();
  Future<void> toggleFavorite(int characterId);
  bool isFavorite(int characterId);
}