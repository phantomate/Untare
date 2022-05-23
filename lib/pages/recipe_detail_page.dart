import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/components/bottom_sheets/recipe_more_bottom_sheet_component.dart';
import 'package:tare/components/widgets/recipe_detail_tabbar_widget.dart';
import 'package:tare/components/recipes/recipe_image_component.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/models/recipe.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final String? referer;

  RecipeDetailPage({required this.recipe, this.referer});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
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
        child: BlocConsumer<RecipeBloc, RecipeState>(
          listener: (context, state) {
            if (state is RecipeDeleted) {
              Navigator.pop(context);
            } else if (state is RecipeUpdated) {
              recipe = state.recipe;
            }
          },
          builder: (context, state) {
            if (state is RecipeFetched) {
              if (widget.recipe.id == state.recipe.id) {
                recipe = state.recipe;
              }
            }

            return NestedScrollView(
              headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
                return <Widget>[
                  sliverWidget(context, hsbContext, recipe, referer: widget.referer)
                ];
              },
              body: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: (state is RecipeLoading)
                    ? buildLoading()
                    : RecipeDetailTabBarWidget(recipe: recipe)
              ),
            );
          }
        )
      )
    );
  }
}

Widget sliverWidget(BuildContext context, BuildContext hsbContext, Recipe recipe, {String? referer}) {
  String? lastCooked;
  if (recipe.lastCooked != null) {
    DateTime tempDate = DateTime.parse(recipe.lastCooked!);
    lastCooked = DateFormat("dd.MM.yy").format(tempDate);
  }

  return SliverOverlapAbsorber(
    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(hsbContext),
    sliver: MultiSliver(
      children: [
        SliverLayoutBuilder(
          builder: (BuildContext hsbContext, constraints) {
            final scrolled = constraints.scrollOffset > 0 && constraints.scrollOffset < 290;

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
                    fontWeight: FontWeight.bold,
                    fontSize: 18
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
                    child: buildRecipeImage(recipe, BorderRadius.zero, 250, referer: referer),
                  ),
                  Container(
                    height: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (lastCooked != null) Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant_outlined,
                                  size: 13,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  lastCooked,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Last cooked',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey
                              ),
                            )
                          ],
                        ),
                        if (recipe.rating != null && recipe.rating! > 0) Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  recipe.rating.toString(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.star,
                                  size: 13,
                                  color: Colors.amberAccent,
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Rating',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey
                              ),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 13,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  recipe.workingTime.toString() + ' min',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Prep. time',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey
                              ),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.hourglass_bottom_outlined,
                                  size: 13,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  recipe.waitingTime.toString() + ' min',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Waiting time',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey
                              ),
                            )
                          ],
                        ),
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
                Tab(text: 'Directions'),
              ],
            ),
          ),
          pinned: true,
        ),
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