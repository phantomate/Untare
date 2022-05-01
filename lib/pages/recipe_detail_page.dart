import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/components/bottomSheets/recipe_more_bottom_sheet_component.dart';
import 'package:tare/components/widgets/recipe_detail_ingredients_stateful_widget.dart';
import 'package:tare/components/recipes/recipe_image_component.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/services/api/api_recipe.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecipeBloc>(
        create: (BuildContext context) =>
            RecipeBloc(apiRecipe: ApiRecipe()),
        child: RecipeDetail(recipe: this.recipe)
    );
  }
}

class RecipeDetail extends StatefulWidget {
  final Recipe recipe;

  RecipeDetail({required this.recipe});

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  late RecipeBloc recipeBloc;
  late Recipe recipe;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    recipeBloc = BlocProvider.of<RecipeBloc>(context);
    recipeBloc.add(FetchRecipe(id: recipe.id!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
            return <Widget>[
              sliverWidget(context, hsbContext, recipe)
            ];
          },
          body: Container(
            margin: const EdgeInsets.only(top: 50),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: BlocConsumer<RecipeBloc, RecipeState>(
              listener: (context, state) {
                if (state is RecipeError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      duration: Duration(seconds: 8),
                    ),
                  );
                } else if (state is RecipeUnauthorized) {
                  Phoenix.rebirth(context);
                }
              },
              builder: (context, state) {
                if (state is RecipeLoading) {
                  return buildLoading();
                } else if (state is RecipeFetched) {
                  recipe = state.recipe;

                  return TabBarView(
                    children: [
                      RecipeDetailIngredientsWidget(recipe: recipe),
                      buildRecipeInstructions(recipe)
                    ],
                  );
                } else {
                  return Center(child: Text('Help'));
                }
              }
            ),
          ),
        ),
      )
    );
  }
}

Widget sliverWidget(BuildContext context, BuildContext hsbContext, Recipe recipe) {
  int recipeSumTime = (recipe.workingTime ?? 0) + (recipe.waitingTime ?? 0);

  return SliverOverlapAbsorber(
    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(hsbContext),
    sliver: MultiSliver(
      children: [
        SliverLayoutBuilder(
          builder: (BuildContext hsbContext, constraints) {
            final scrolled = constraints.scrollOffset > 0 && constraints.scrollOffset < 285;

            return SliverAppBar(
              leadingWidth: 50,
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: Colors.black87),
              leading: IconButton(
                iconSize: 30,
                padding: const EdgeInsets.all(0),
                onPressed: () => Navigator.pop(hsbContext),
                splashRadius: 20,
                icon: Icon(
                  Icons.chevron_left,
                ),
              ),
              title: Text(
                recipe.name,
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold
                ),
              ),
              actions: [
                IconButton(
                    tooltip: 'More',
                    splashRadius: 20,
                    onPressed: () {
                      recipeMoreBottomSheet(context, recipe);
                    },
                    icon: Icon(
                      Icons.more_vert_outlined,
                      color: Colors.black87,
                    )
                )
              ],
              elevation: (scrolled) ? 1.5 : 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              pinned: true,
            );
          },
        ),
        SliverList(
            delegate: SliverChildListDelegate(
                [
                  Container(
                    height: 250,
                    child: buildRecipeImage(recipe, BorderRadius.zero, 250),
                  ),
                  Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 2),
                            Text(
                              recipeSumTime.toString() + ' min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 2),
                            Text(
                              recipeSumTime.toString() + ' min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 2),
                            Text(
                              recipeSumTime.toString() + ' min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ]
            )
        ),
        SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(
            TabBar(
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Ingredients'),
                Tab(text: 'Instructions'),
              ],
            ),
          ),
          pinned: true,
        ),
      ],
    ),
  );
}

Widget buildRecipeInstructions(Recipe recipe) {
  if (recipe.steps!.first.instruction != null && recipe.steps!.first.instruction != '') {
    List<String> splitInstructions = recipe.steps!.first.instruction.split("\n\n");

    if (splitInstructions.length <= 2) {
      List<String> tmpSplitInstructions = splitInstructions;
      splitInstructions = [];
      for(int i = 0; i < tmpSplitInstructions.length; i++) {
        splitInstructions.addAll(tmpSplitInstructions[i].split("\n"));
      }
    }

    List<Widget> instructionSteps = [];

    for(int i = 0; i < splitInstructions.length; i++) {
      final splitInstruction = splitInstructions[i].replaceAll("\r", "");

      if (i < splitInstructions.length - 1) {
        instructionSteps.add(buildInstructionStep(i+1, splitInstruction));
      } else {
        instructionSteps.add(Container(
          padding: const EdgeInsets.only(top: 10),
          child: Text(splitInstruction, style: TextStyle(color: Colors.black45)),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(top: 10, right: 20, bottom: 0, left: 20),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: instructionSteps,
    );
  } else {
    return Center(child: Text('No instructions found'));
  }
}

Widget buildInstructionStep(int stepCount, String step) {
  return Container(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step $stepCount', style: TextStyle(color: Colors.black45)),
        SizedBox(height: 5),
        Text(step)
      ],
    ),
  );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {

    return new Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow:[
          BoxShadow(
              color: Colors.black12.withOpacity(0.45), //color of shadow
              spreadRadius: 0.2, //spread radius
              blurRadius: 0.7, // blur radius
              offset: Offset(0, 0.5)
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}