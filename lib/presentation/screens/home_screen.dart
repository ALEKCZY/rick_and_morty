import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rick_and_morty_app/presentation/bloc/character/character_cubit.dart';
import 'package:rick_and_morty_app/presentation/bloc/character/character_state.dart';
import 'package:rick_and_morty_app/presentation/widgets/character_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    context.read<CharacterCubit>().fetchCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rick and Morty Characters'),
      ),
      body: BlocConsumer<CharacterCubit, CharacterState>(
        listener: (context, state) {
          // Обрабатываем изменения состояния
        },
        builder: (context, state) {
          if (state is CharacterInitial || state is CharacterLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CharacterError) {
            return Center(child: Text(state.message));
          } else if (state is CharacterLoaded) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullUp: true,
              onRefresh: () async {
                await context.read<CharacterCubit>().fetchCharacters();
                _refreshController.refreshCompleted();
              },
              onLoading: () async {
                await context.read<CharacterCubit>().fetchCharacters();
                _refreshController.loadComplete();
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.characters.length,
                itemBuilder: (context, index) {
                  final character = state.characters[index];
                  return CharacterCard(
                    character: character,
                    isFavorite: context.read<CharacterCubit>().isFavorite(character.id),
                    onFavoriteTap: () {
                      context.read<CharacterCubit>().toggleFavorite(character.id);
                      // Принудительно обновляем состояние виджета
                      if (mounted) setState(() {});
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}