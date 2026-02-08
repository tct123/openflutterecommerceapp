// Product list Bloc States
// Author: openflutterproject@gmail.com
// Date: 2020-02-06

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:openflutterecommerce/data/model/filter_rules.dart';
import 'package:openflutterecommerce/data/model/sort_rules.dart';
import 'bloc_list_data.dart';

@immutable
abstract class ProductsState extends Equatable {
  final ProductListData? data;
  final SortRules? sortBy;
  final FilterRules? filterRules;
  final String? error;

  const ProductsState({
    this.data,
    this.filterRules,
    this.sortBy,
    this.error,
  });

  ProductsState copyWith({
    ProductListData? data,
    SortRules? sortBy,
    FilterRules? filterRules,
    String? error,
  });

  ProductsState getLoading() {
    return copyWith(data: null, error: null);
  }

  bool get isProductsLoading => data == null;
  bool get isFilterRulesVisible => filterRules != null;
  bool get hasError => error != null;

  @override
  List<Object?> get props => [data, filterRules, sortBy, error];

  @override
  bool get stringify => true;
}

@immutable
class ProductsInitial extends ProductsState {
  const ProductsInitial() : super();

  @override
  ProductsState copyWith({
    ProductListData? data,
    SortRules? sortBy,
    FilterRules? filterRules,
    String? error,
  }) {
    return const ProductsInitial();
  }

  @override
  ProductsState getLoading() {
    return const ProductsInitial();
  }
}

@immutable
class ProductsListViewState extends ProductsState {
  const ProductsListViewState({
    ProductListData? data,
    SortRules? sortBy,
    FilterRules? filterRules,
    String? error,
  }) : super(
          data: data,
          sortBy: sortBy,
          filterRules: filterRules,
          error: error,
        );

  @override
  ProductsListViewState copyWith({
    ProductListData? data,
    SortRules? sortBy,
    FilterRules? filterRules,
    String? error,
  }) {
    return ProductsListViewState(
      data: data ?? this.data,
      filterRules: filterRules ?? this.filterRules,
      sortBy: sortBy ?? this.sortBy,
      error: error ?? this.error,
    );
  }

  @override
  ProductsState getLoading() {
    return copyWith(data: null, error: null);
  }

  ProductsTileViewState getTiles() {
    return ProductsTileViewState(
      data: data,
      sortBy: sortBy,
      filterRules: filterRules,
    );
  }
}

@immutable
class ProductsTileViewState extends ProductsState {
  const ProductsTileViewState({
    ProductListData? data,
    SortRules? sortBy,
    FilterRules? filterRules,
    String? error,
  }) : super(
          data: data,
          sortBy: sortBy,
          filterRules: filterRules,
          error: error,
        );

  @override
  ProductsTileViewState copyWith({
    ProductListData? data,
    SortRules? sortBy,
    FilterRules? filterRules,
    String? error,
  }) {
    return ProductsTileViewState(
      data: data ?? this.data,
      filterRules: filterRules ?? this.filterRules,
      sortBy: sortBy ?? this.sortBy,
      error: error ?? this.error,
    );
  }

  @override
  ProductsState getLoading() {
    return copyWith(data: null, error: null);
  }

  ProductsListViewState getList() {
    return ProductsListViewState(
      data: data,
      sortBy: sortBy,
      filterRules: filterRules,
    );
  }
}
