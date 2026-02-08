// Product List Bloc
// Author: openflutterproject@gmail.com
// Date: 2020-02-06

import 'package:bloc/bloc.dart';
import 'package:openflutterecommerce/data/model/category.dart';
import 'package:openflutterecommerce/data/model/favorite_product.dart';
import 'package:openflutterecommerce/data/model/product.dart';
import 'package:openflutterecommerce/data/model/sort_rules.dart';
import 'package:openflutterecommerce/domain/usecases/favorites/add_to_favorites_use_case.dart';
import 'package:openflutterecommerce/domain/usecases/favorites/get_favorite_products_use_case.dart';
import 'package:openflutterecommerce/domain/usecases/favorites/remove_from_favorites_use_case.dart';
import 'package:openflutterecommerce/domain/usecases/products/find_products_by_filter_use_case.dart';
import 'package:openflutterecommerce/domain/usecases/products/products_by_filter_params.dart';
import 'package:openflutterecommerce/domain/usecases/products/products_by_filter_result.dart';
import 'package:openflutterecommerce/locator.dart';
import 'package:openflutterecommerce/presentation/features/products/products.dart';
import 'bloc_list_data.dart';

class ProductsBloc extends Bloc<ProductsListEvent, ProductsState> {
  final FindProductsByFilterUseCase findProductsByFilterUseCase;
  final GetFavoriteProductsUseCase getFavoriteProductsUseCase;
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;
  final AddToFavoritesUseCase addToFavoritesUseCase;
  final ProductCategory category;

  ProductsBloc({
    required this.category,
  })  : findProductsByFilterUseCase = sl(),
        getFavoriteProductsUseCase = sl(),
        removeFromFavoritesUseCase = sl(),
        addToFavoritesUseCase = sl(),
        super(ProductsInitial()) {
    on<ScreenLoadedEvent>(_onScreenLoaded);
    on<ProductsChangeViewEvent>(_onProductsChangeView);
    on<ProductChangeSortRulesEvent>(_onProductChangeSortRules);
    on<ProductChangeHashTagEvent>(_onProductChangeHashTag);
    on<ProductChangeFilterRulesEvent>(_onProductChangeFilterRules);
    on<ProductMakeFavoriteEvent>(_onProductMakeFavorite);
  }

  Future<void> _onScreenLoaded(
      ScreenLoadedEvent event, Emitter<ProductsState> emit) async {
    ProductListData data = await getInitialStateData(category);
    emit(ProductsListViewState(
      sortBy: SortRules(),
      data: data,
      filterRules: data.filterRules,
    ));
  }

  Future<void> _onProductsChangeView(
      ProductsChangeViewEvent event, Emitter<ProductsState> emit) async {
    if (state is ProductsListViewState) {
      emit((state as ProductsListViewState).getTiles());
    } else {
      emit((state as ProductsTileViewState).getList());
    }
  }

  Future<void> _onProductChangeSortRules(
      ProductChangeSortRulesEvent event, Emitter<ProductsState> emit) async {
    emit(state.getLoading());
    ProductsByFilterResult productResults =
        await findProductsByFilterUseCase.execute(ProductsByFilterParams(
      categoryId: category.id,
      filterRules: state.filterRules,
      sortBy: event.sortBy,
    ));
    final List<Product> filteredData = productResults.products;
    emit(state.copyWith(
      sortBy: event.sortBy,
      data: state.data?.copyWith(filteredData),
    ));
  }

  Future<void> _onProductChangeHashTag(
      ProductChangeHashTagEvent event, Emitter<ProductsState> emit) async {
    emit(state.getLoading());
    state.filterRules?.selectedHashTags[event.hashTag] = event.isSelected;
    ProductsByFilterResult productResults =
        await findProductsByFilterUseCase.execute(ProductsByFilterParams(
      categoryId: category.id,
      filterRules: state.filterRules,
      sortBy: state.sortBy,
    ));
    final List<Product> filteredData = productResults.products;
    emit(state.copyWith(
      data: state.data?.copyWith(filteredData),
      sortBy: state.sortBy,
    ));
  }

  Future<void> _onProductChangeFilterRules(
      ProductChangeFilterRulesEvent event, Emitter<ProductsState> emit) async {
    emit(state.getLoading());
    ProductsByFilterResult productResults =
        await findProductsByFilterUseCase.execute(ProductsByFilterParams(
      categoryId: category.id,
      filterRules: event.filterRules,
      sortBy: state.sortBy,
    ));
    final List<Product> filteredData = productResults.products;
    emit(state.copyWith(
      filterRules: event.filterRules,
      data: state.data?.copyWith(filteredData),
    ));
  }

  Future<void> _onProductMakeFavorite(
      ProductMakeFavoriteEvent event, Emitter<ProductsState> emit) async {
    if (event.isFavorite) {
      await addToFavoritesUseCase
          .execute(FavoriteProduct(event.product, event.favoriteAttributes!));
    } else {
      await removeFromFavoritesUseCase.execute(RemoveFromFavoritesParams(
          FavoriteProduct(event.product, event.favoriteAttributes!)));
    }
    final List<Product> data = state.data!.products;
    emit(state.copyWith(
      data: state.data!.copyWith(data.map((item) {
        if (event.product.id == item.id) {
          return item.favorite(event.isFavorite);
        } else {
          return item;
        }
      }).toList(growable: false)),
    ));
  }

  Future<ProductListData> getInitialStateData(ProductCategory category) async {
    ProductsByFilterResult productResults = await findProductsByFilterUseCase
        .execute(ProductsByFilterParams(categoryId: category.id));
    return ProductListData(
      productResults.products,
      category,
      productResults.filterRules,
    );
  }
}
