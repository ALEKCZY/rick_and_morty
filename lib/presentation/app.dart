import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:rick_and_morty_app/data/repositories/character_repository_impl.dart';
import 'package:rick_and_morty_app/presentation/bloc/character/character_cubit.dart';
import 'package:rick_and_morty_app/presentation/screens/favorites_screen.dart';
import 'package:rick_and_morty_app/presentation/screens/home_screen.dart';
import 'package:rick_and_morty_app/domain/entities/character.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => CharacterRepositoryImpl(
            dio: Dio(),
            charactersBox: Hive.box<Character>('characters'),
            favoritesBox: Hive.box<int>('favorites'),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CharacterCubit(
              RepositoryProvider.of<CharacterRepositoryImpl>(context),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Rick and Morty',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple.shade200,
              secondary: Colors.deepPurple.shade200,
            ),
          ),
          themeMode: ThemeMode.system,
          home: const _AppScaffold(),
        ),
      ),
    );
  }
}

class _AppScaffold extends StatefulWidget {
  const _AppScaffold();

  @override
  State<_AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<_AppScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Characters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}