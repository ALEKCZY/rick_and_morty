import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final Dio dio;
  final Box<Character> charactersBox;
  final Box<int> favoritesBox;

  CharacterRepositoryImpl({
    required this.dio,
    required this.charactersBox,
    required this.favoritesBox,
  });

  @override
  Future<List<Character>> fetchCharacters(int page) async {
    try {
      final response = await dio.get(
        'https://rickandmortyapi.com/api/character',
        queryParameters: {'page': page},
      );

      final results = response.data['results'] as List;
      final characters = results.map((json) => Character.fromJson(json)).toList();

      // Cache characters
      await charactersBox.putAll({for (var c in characters) c.id: c});

      return characters;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        // Return cached data if offline
        return charactersBox.values.toList();
      }
      rethrow;
    }
  }

  @override
  List<Character> getFavorites() {
    return favoritesBox.values
        .map((id) => charactersBox.get(id))
        .whereType<Character>()
        .toList();
  }

  @override
  Future<void> toggleFavorite(int characterId) async {
    if (favoritesBox.containsKey(characterId)) {
      await favoritesBox.delete(characterId);
    } else {
      await favoritesBox.put(characterId, characterId);
    }
  }

  @override
  bool isFavorite(int characterId) {
    return favoritesBox.containsKey(characterId);
  }
}