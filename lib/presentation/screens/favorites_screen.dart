import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/domain/entities/character.dart';
import 'package:rick_and_morty_app/presentation/bloc/character/character_cubit.dart';
import 'package:rick_and_morty_app/presentation/bloc/character/character_state.dart';
import 'package:rick_and_morty_app/presentation/widgets/character_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _sortBy = 'name';
  bool _ascending = true;
  late List<Character> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = context.read<CharacterCubit>().getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == _sortBy) {
                  _ascending = !_ascending;
                } else {
                  _sortBy = value;
                  _ascending = true;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('Sort by name'),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Text('Sort by status'),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<CharacterCubit, CharacterState>(
        listener: (context, state) {
          if (state is CharacterLoaded) {
            setState(() {
              _favorites = context.read<CharacterCubit>().getFavorites();
            });
          }
        },
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // Применяем сортировку
    _favorites.sort((a, b) {
      int result;
      switch (_sortBy) {
        case 'name':
          result = a.name.compareTo(b.name);
          break;
        case 'status':
          result = a.status.compareTo(b.status);
          break;
        default:
          result = a.name.compareTo(b.name);
      }
      return _ascending ? result : -result;
    });

    if (_favorites.isEmpty) {
      return const Center(child: Text('No favorites yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final character = _favorites[index];
        return CharacterCard(
          character: character,
          isFavorite: true,
          onFavoriteTap: () => context.read<CharacterCubit>().toggleFavorite(character.id),
        );
      },
    );
  }
}