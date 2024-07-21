import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_architecture/core/common/cubits/app_user/app_user_cubit.dart';

import 'package:flutter_clean_architecture/core/theme/theme.dart';

import 'package:flutter_clean_architecture/featrures/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_clean_architecture/featrures/auth/presentation/screens/login_screen.dart';
import 'package:flutter_clean_architecture/featrures/blog/presentation/bloc/blog_bloc.dart';
import 'package:flutter_clean_architecture/init_dependences.dart';

import 'featrures/blog/presentation/screens/blog_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AppUserCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<BlogBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blog App',
      theme: AppTheme.darkThemeMode,
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) {
          return state is AppUserLoggedIn;
        },
        builder: (context, isLoggedIn) {
          if (isLoggedIn) {
            return const BlogScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
