import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/cubits/spaces_cubit.dart';
import 'package:untare/models/space.dart';
import 'package:untare/services/api/api_space.dart';
import 'package:untare/services/cache/cache_space_service.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

class SpacesPage extends StatefulWidget {
  const SpacesPage({super.key});

  @override
  SpacesPageState createState() => SpacesPageState();
}

class SpacesPageState extends State<SpacesPage> {
  SpacesCubit cubit = SpacesCubit(apiSpace: ApiSpace(), cacheSpaceService: CacheSpaceService());
  List<Space> spaces = [];

  @override
  void initState(){
    super.initState();
    cubit.fetchSpaces();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpacesCubit>(
        create: (context) => cubit,
        child:  BlocBuilder<SpacesCubit, List<Space>>(
        builder: (context, spaces) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.spaces),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 1.5,
            ),
            body: ListView.separated(
                itemBuilder: (context, index) => CheckboxListTile(
                  value: true,
                  onChanged: (bool? changed) {

                  },
                  activeColor: Theme.of(context).colorScheme.secondary,
                  title: Wrap(children: [Text(spaces[index].name)]),
                  subtitle: Wrap(direction: Axis.horizontal,children: [
                    Icon(Icons.restaurant_menu_outlined, size: 15, color: Theme.of(context).inputDecorationTheme.prefixIconColor),
                    const SizedBox(width: 2),
                    Text('${spaces[index].recipeCount} / ${(spaces[index].maxRecipes == 0) ? '∞' : spaces[index].maxRecipes.toString()}'),
                    const SizedBox(width: 15),
                    Icon(Icons.people_outline_outlined, size: 15, color: Theme.of(context).inputDecorationTheme.prefixIconColor),
                    const SizedBox(width: 2),
                    Text('${spaces[index].userCount} / ${(spaces[index].maxUsers == 0) ? '∞' : spaces[index].maxUsers.toString()}'),
                    const SizedBox(width: 15),
                    Icon(Icons.storage_outlined, size: 15, color: Theme.of(context).inputDecorationTheme.prefixIconColor),
                    const SizedBox(width: 2),
                    Text('${spaces[index].fileStorageCount} / ${(spaces[index].maxFileStorage == 0) ? '∞' : spaces[index].maxFileStorage.toString()}'),
                  ],),
                ),
                separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                ),
                itemCount: context.watch<SpacesCubit>().state.length
            ),
          );
        })
    );
  }
}