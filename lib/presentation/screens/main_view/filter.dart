import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soom/presentation/components/appbar/app_bar.dart';
import 'package:soom/presentation/screens/main_view/bloc/home_cubit.dart';
import 'package:soom/style/color_manger.dart';

import '../../../style/text_style.dart';
import '../../components/product_item.dart';

class FilterResultScreen extends StatefulWidget {
  final HomeCubit homeCubit ;
  const FilterResultScreen({Key? key, required this.homeCubit}) : super(key: key);
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
      body: FutureBuilder(
          future: HomeCubit.get(context).getFilterResult(context),
      builder: (context , snapShot){
        if(snapShot.connectionState == ConnectionState.waiting ){
          return const Center(child: CircularProgressIndicator(),);
        }else{
          if(snapShot.hasError){
            if (kDebugMode) {
              print(snapShot.error.toString());
            }
            return const Center(child: Text("حدث خطأ ما يرجي المحاولة لاحقا ! "));
          }
          if(snapShot.hasData){
            return HomeCubit.get(context).filterResult.isEmpty ?   Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children:const [
                Icon(Icons.error_outline , size: 50, color: ColorManger.grey,) ,
                SizedBox(height: 16,),
                Text("لا توجد نتائج مطابقة ! " , style: AppTextStyles.mediumGrey,),
              ],
            ),) : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                physics:const BouncingScrollPhysics(),
                children: List.generate(HomeCubit.get(context).filterResult.length, (index)
                =>
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProductItem(
                        isFullWidth: true,
                        productModel: HomeCubit.get(context).filterResult[index],
                      ),
                    ),
                ),
              ),
            );
          }
          return const Text("لا توجد نتائج لعبارة بحثك ");


        }
      },
    ),
      ),
    );
  }
}
