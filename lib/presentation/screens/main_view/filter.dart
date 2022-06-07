import 'package:flutter/material.dart';
import 'package:soom/models/product_model.dart';
import 'package:soom/presentation/components/appbar/app_bar.dart';
import 'package:soom/presentation/components/product_item.dart';
import 'package:soom/presentation/screens/main_view/bloc/home_cubit.dart';
import 'package:soom/style/color_manger.dart';
import 'package:soom/style/text_style.dart';

class FilterResultScreen extends StatefulWidget {
 final  List<ProductModel> products ;
  const FilterResultScreen({Key? key, required this.products}) : super(key: key);
  @override
  State<FilterResultScreen> createState() => _FilterResultScreenState();
}
class _FilterResultScreenState extends State<FilterResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorManger.white,
        appBar:  AppBars.appBarGeneral(context , HomeCubit(), "نتائج مفلترة" , cartView: false , ),
        body:widget.products.isEmpty? Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children:const [
            Icon(Icons.error_outline , size: 50, color: ColorManger.grey,) ,
             SizedBox(height: 16,),
            Text("لا توجد نتائج" , style: AppTextStyles.mediumGrey,),
          ],
        ),)
            :
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            physics:const BouncingScrollPhysics(),
            children: List.generate(widget.products.length, (index)
            =>
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProductItem(
                      isFullWidth: true,
                      productModel: widget.products[index] ,
                  ),
                ),
            ),
          ),
        )
        ,
      ),
    );
  }
}
