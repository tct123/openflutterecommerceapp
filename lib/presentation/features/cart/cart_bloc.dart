// Cart Screen Bloc
// Author: openflutterproject@gmail.com
// Date: 2020-02-06

import 'package:bloc/bloc.dart';
import 'package:openflutterecommerce/data/model/favorite_product.dart';
import 'package:openflutterecommerce/domain/usecases/cart/change_cart_item_quantity_use_case.dart';
import 'package:openflutterecommerce/domain/usecases/cart/get_cart_products_use_case.dart';
import 'package:openflutterecommerce/domain/usecases/cart/remove_product_from_cart_use_case.dart';
import 'package:openflutterecommerce/domain/usecases/favorites/add_to_favorites_use_case.dart';
import 'package:openflutterecommerce/domain/usecases/promos/get_promos_use_case.dart';
import 'package:openflutterecommerce/locator.dart';

import 'cart.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartProductsUseCase getCartProductsUseCase;
  final RemoveProductFromCartUseCase removeProductFromCartUseCase;
  final AddToFavoritesUseCase addToFavoritesUseCase;
  final GetPromosUseCase getPromosUseCase;
  final ChangeCartItemQuantityUseCase changeCartItemQuantityUseCase;

  CartBloc()
      : getCartProductsUseCase = sl(),
        removeProductFromCartUseCase = sl(),
        addToFavoritesUseCase = sl(),
        getPromosUseCase = sl(),
        changeCartItemQuantityUseCase = sl(),
        super(CartInitialState()) {
    // ChangeCartItemQuantityUseCase wird jetzt im Konstruktor initialisiert
  }

  Stream<CartState> mapEventToState(CartEvent event) async* {
    if (event is CartLoadedEvent) {
      if (state is CartInitialState) {
        final cartResults =
            await getCartProductsUseCase.execute(GetCartProductParams());
        var promos = await getPromosUseCase.execute(GetPromosParams());

        yield CartLoadedState(
          showPromoPopup: false,
          totalPrice: cartResults.totalPrice,
          calculatedPrice: cartResults.calculatedPrice,
          promos: promos.promos,
          appliedPromo: cartResults.appliedPromo,
          cartProducts: cartResults.cartItems,
        );
      }
      // Toter Code entfernt: Der folgende Block wurde gelöscht, da er keine Wirkung hatte
      // else if (state is CartLoadedState) {
      //   yield state;
      // }
    } else if (event is CartQuantityChangedEvent) {
      final currentState = this.state as CartLoadedState;
      yield CartLoadingState();

      if (event.newQuantity < 1) {
        await removeProductFromCartUseCase.execute(event.item);
      } else {
        await changeCartItemQuantityUseCase.execute(
          ChangeCartItemQuantityParams(
              item: event.item, quantity: event.newQuantity),
        );
      }

      final cartResults = await getCartProductsUseCase.execute(
        GetCartProductParams(appliedPromo: currentState.appliedPromo),
      );

      yield CartLoadedState(
        cartProducts: cartResults.cartItems,
        promos: currentState.promos,
        showPromoPopup: currentState.showPromoPopup,
        totalPrice:
            cartResults.cartItems.isEmpty ? 0.0 : cartResults.totalPrice,
        calculatedPrice: cartResults.calculatedPrice,
        appliedPromo: cartResults.appliedPromo,
      );
    } else if (event is CartRemoveFromCartEvent) {
      final currentState = this.state as CartLoadedState;
      yield CartLoadingState();

      await removeProductFromCartUseCase.execute(event.item);

      final cartResults = await getCartProductsUseCase.execute(
        GetCartProductParams(appliedPromo: currentState.appliedPromo),
      );

      yield CartLoadedState(
        cartProducts: cartResults.cartItems,
        promos: currentState.promos,
        showPromoPopup: currentState.showPromoPopup,
        totalPrice:
            cartResults.cartItems.isEmpty ? 0.0 : cartResults.totalPrice,
        calculatedPrice: cartResults.calculatedPrice,
        appliedPromo: cartResults.appliedPromo,
      );
    } else if (event is CartAddToFavsEvent) {
      await addToFavoritesUseCase.execute(
        FavoriteProduct(event.item.product, event.item.selectedAttributes),
      );
    } else if (event is CartPromoAppliedEvent) {
      final currentState = this.state as CartLoadedState;
      final cartResults = await getCartProductsUseCase.execute(
        GetCartProductParams(appliedPromo: event.promo),
      );

      yield currentState.copyWith(
        showPromoPopup: false,
        totalPrice: cartResults.totalPrice,
        calculatedPrice: cartResults.calculatedPrice,
        appliedPromo: event.promo,
      );
    } else if (event is CartPromoCodeAppliedEvent) {
      final currentState = this.state as CartLoadedState;
      yield currentState.copyWith(showPromoPopup: false);
    } else if (event is CartShowPopupEvent) {
      final currentState = this.state as CartLoadedState;
      yield currentState.copyWith(showPromoPopup: true);
    }
  }
}
