import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/components/recipes/recipe_image_component.dart';
import 'package:tare/components/widgets/recipe_upsert_steps_stateful_widget.dart';
import 'package:tare/models/recipe.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tare/models/step.dart';
import 'package:tare/pages/recipe_detail_page.dart';

class RecipeUpsertPage extends StatefulWidget {
  final Recipe? recipe;

  RecipeUpsertPage({this.recipe});

  @override
  _RecipeUpsertPageState createState() => _RecipeUpsertPageState();
}

class _RecipeUpsertPageState extends State<RecipeUpsertPage> {
  final formKey = GlobalKey<FormBuilderState>();
  Recipe? recipe;
  late RecipeBloc _recipeBloc;

  @override
  void initState() {
    super.initState();
    _recipeBloc = BlocProvider.of<RecipeBloc>(context);
    if (widget.recipe != null && widget.recipe!.steps.isEmpty) {
      _recipeBloc.add(FetchRecipe(id: widget.recipe!.id!));
    }
    recipe = widget.recipe;
  }

  // Rebuild recipe for upsert
  Recipe rebuildRecipe({List<StepModel>? steps}) {
    formKey.currentState!.save();
    Map<String, dynamic> formBuilderData = formKey.currentState!.value;

    // Create step copy with updated/created ingredient list
    List<StepModel> stepList = [];
    if (recipe != null) {
      stepList = steps ?? recipe!.steps;
    } else {
      stepList = steps ?? [];
    }

    // Update recipe name, if changed in form
    String name = (recipe != null) ? recipe!.name : '';
    if (formBuilderData.containsKey('name') && name != formBuilderData['name']) {
      name = formBuilderData['name'] ?? '';
    }

    // Update working time, if changed in form
    int? workingTime = (recipe != null) ? recipe!.workingTime : 0;
    if (formBuilderData.containsKey('workingTime') && workingTime != formBuilderData['workingTime']) {
      workingTime = (!["", null].contains(formBuilderData['workingTime'])) ? int.parse(formBuilderData['workingTime']) : 0;
    }

    // Update waiting time, if changed in form
    int? waitingTime = (recipe != null) ? recipe!.waitingTime : 0;
    if (formBuilderData.containsKey('waitingTime') && waitingTime != formBuilderData['waitingTime']) {
      waitingTime = (!["", null].contains(formBuilderData['waitingTime'])) ? int.parse(formBuilderData['waitingTime']) : 0;
    }

    // Update servings, if changed in form
    int? servings = (recipe != null) ? recipe!.servings : 1;
    if (formBuilderData.containsKey('servings') && servings != formBuilderData['servings']) {
      servings = (!["", null].contains(formBuilderData['servings'])) ? int.parse(formBuilderData['servings']) : 1;
    }

    if (recipe != null) {
      return recipe!.copyWith(name: name, workingTime: workingTime, waitingTime: waitingTime, servings: servings , steps: stepList);
    }
    return Recipe(name: name, workingTime: workingTime, waitingTime: waitingTime, servings: servings , steps: stepList, keywords: [], internal: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                leadingWidth: 50,
                titleSpacing: 0,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  iconSize: 30,
                  padding: const EdgeInsets.all(0),
                  onPressed: () => Navigator.pop(hsbContext),
                  splashRadius: 20,
                  icon: Icon(
                    Icons.chevron_left,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      formKey.currentState!.save();
                      if (formKey.currentState!.validate()) {
                        XFile? image;
                        if (formKey.currentState!.value['image'].first is XFile) {
                          image = formKey.currentState!.value['image'].first;
                        }

                        if (widget.recipe != null) {
                          _recipeBloc.add(UpdateRecipe(recipe: rebuildRecipe(), image: image));
                        } else {
                          _recipeBloc.add(CreateRecipe(recipe: rebuildRecipe(), image: image));
                        }
                      }
                    },
                    icon: Icon(Icons.save_outlined),
                    splashRadius: 20,
                  )
                ],
                title: Text(
                  (widget.recipe != null) ? 'Edit recipe' : 'Create recipe',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  ),
                ),
                elevation: 1.5,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                pinned: true,
              )
            ];
          },
          body: FormBuilder(
              key: formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.only(top: 15, bottom: 10),
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: FormBuilderImagePicker(
                              name: 'image',
                              initialValue: [
                                (recipe != null && recipe!.image != null && recipe!.image != '') ? buildRecipeImage(recipe!, BorderRadius.circular(12), 220) : null
                              ],
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none
                                  )
                              ),
                              maxImages: 1,
                              iconColor: Colors.grey[400],
                              previewWidth: 166,
                              previewHeight: 140,
                            )
                        ),
                      ),
                      Flexible(
                          child: Container(
                              padding: const EdgeInsets.only(right: 20),
                              child: Column(
                                children: [
                                  FormBuilderTextField(
                                    name: 'workingTime',
                                    initialValue: (recipe != null) ? recipe!.workingTime.toString() : null,
                                    decoration: InputDecoration(
                                      labelText: 'Prep Time',
                                      isDense: true,
                                      contentPadding: const EdgeInsets.all(10),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.numeric(),
                                      FormBuilderValidators.min(0)
                                    ]),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        fontSize: 15
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  FormBuilderTextField(
                                    name: 'waitingTime',
                                    initialValue: (recipe != null) ? recipe!.waitingTime.toString() : null,
                                    decoration: InputDecoration(
                                      labelText: 'Waiting time',
                                      isDense: true,
                                      contentPadding: const EdgeInsets.all(10),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.numeric(),
                                      FormBuilderValidators.min(0)
                                    ]),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        fontSize: 15
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  FormBuilderTextField(
                                    name: 'servings',
                                    initialValue: (recipe != null) ? recipe!.servings.toString() : null,
                                    decoration: InputDecoration(
                                      labelText: 'Servings',
                                      isDense: true,
                                      contentPadding: const EdgeInsets.all(10),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.numeric(),
                                      FormBuilderValidators.min(1)
                                    ]),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        fontSize: 15
                                    ),
                                  )
                                ],
                              )
                          )
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 15, right: 20, bottom: 10, left: 20),
                    child: FormBuilderTextField(
                      name: 'name',
                      initialValue: (recipe != null) ? recipe!.name : null,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.max(128),
                      ]),
                      style: TextStyle(
                          fontSize: 15
                      ),
                    ),
                  ),
                  BlocConsumer<RecipeBloc, RecipeState>(
                      listener: (context, state) {
                        if (state is RecipeUpdated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          recipe = state.recipe;

                          Navigator.pop(context);
                        } else if (state is RecipeCreated) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved'),
                              duration: Duration(seconds: 3),
                            ),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: state.recipe)),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is RecipeLoading) {
                          return buildLoading();
                        } else if (state is RecipeFetched) {
                          if (recipe != null) {
                            recipe = state.recipe;
                          }
                        }

                        return RecipeUpsertStepsWidget(recipe: recipe, rebuildRecipe: rebuildRecipe);
                      }
                  )
                ],
              )
          )
      )
    );
  }
}