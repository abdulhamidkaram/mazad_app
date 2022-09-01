import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soom/constants/api_constants.dart';
import 'package:soom/data/api/dio_factory.dart';
import 'package:soom/models/product_model.dart';
import 'package:soom/presentation/components/toast.dart';
import 'package:soom/presentation/screens/main_view/favorite_screen/bloc/states.dart';

class FavoriteCubit extends Cubit<FavoriteStates>{
  FavoriteCubit() : super(InitialFavoriteState());

  static FavoriteCubit get(context)=>BlocProvider.of(context);
  bool isFinish = false ;
  bool isFirstBuild = true ;
  List favoritesItemsResponse = [];
  List<ProductForViewModel> favoritesItems = [];
  Future getFavorite (context )async{
    favoritesItemsResponse = [];
    emit(GetFavoriteLoading());
    DioFactory().getData(ApiEndPoint.myFavorite, {}).then((value){
      favoritesItemsResponse = value.data["result"]["items"];
      emit(GetFavoriteSuccess());
    }).catchError((error){
      if(kDebugMode){
        print(error.toString());
      }
      emit(GetFavoriteError());
      });
  }
  Future<List<ProductForViewModel>> getFavoriteForView (context)async {
    List<ProductForViewModel> _favoritesItems = [];
    emit(GetFavoriteForViewLoading());
    for(Map data in favoritesItemsResponse ){
      //TODO: FAVORITE FORM SERVER
      await  DioFactory().getData(ApiEndPoint.getAllProducts, {
        "NameFilter":data["productName"]
      }).then((value){

        Map<String , dynamic > dataProduct =  value.data["result"]["items"][0];
        //TODO: LAST PRICE
        ProductForViewModel productForViewModel = ProductForViewModel( "20", ProductModel.fromJson(dataProduct),  "12");
        productForViewModel.isFavorite = true ;
        _favoritesItems.add(productForViewModel);

        favoritesItems = _favoritesItems.reversed.toList();
        emit(GetFavoriteForViewSuccess());
        return _favoritesItems ;
      }).catchError((error){
        return favoritesItems ;
      });
    }
    emit(GetFavoriteForViewSuccess());
    return _favoritesItems ;
  }

 Future  deleteFavorite(ProductForViewModel productForViewModel , context ) async {
    emit(DeleteFavoriteForViewLoading());
    for(var fav in favoritesItemsResponse){
      if(fav["productName"] == productForViewModel.title ){
        await DioFactory().deleteData(ApiEndPoint.deleteFavorite, {
          "id" : fav["productFavorite"]["id"],
        }).then((value){
          if (kDebugMode) {
            print(value.toString());
          }
          emit(DeleteFavoriteForViewSuccess());
          getFavorite(context);
          getFavoriteForView(context);
        }).catchError((error){
          AppToasts.toastError("message", context);
          if (kDebugMode) {
            print(error.toString());
          }
          emit(DeleteFavoriteForViewError());
        });
      }
    }

  }

 Future  addTOFavorite(ProductForViewModel productForViewModel , context ) async {
       DioFactory().postData(ApiEndPoint.addToFavorite, {
         "userId" : 5 , //TODO USER ID
         "productId" : productForViewModel.productModel.product!.id.toString()
       }).then((value){
         getFavorite(context);
         getFavoriteForView(context);
         emit(AddFavoriteForViewSuccess());
       }).catchError((error){
         emit(AddFavoriteForViewError());
       });
  }

  changeFavoriteButton(ProductForViewModel productForViewModel ){

    emit(ChangeFavoriteButtonSuccess());
  }
 bool isFavorite (ProductForViewModel productForViewModel ){
   for (var fav in favoritesItemsResponse) {
     if (fav["productName"] == productForViewModel.title) {
       productForViewModel.isFavorite = true ;
       emit(ISFavorite());
       return true ;
     }else{
       emit(ISFavorite());
       return false ;
     }
   }
   emit(ISFavorite());
   return false ;
 }

}