import 'dart:async';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soom/data/api/dio_factory.dart';
import 'package:soom/data/cache/prefs.dart';
import 'package:soom/main.dart';
import 'package:soom/presentation/components/toast.dart';
import 'package:soom/presentation/screens/login/login.dart';
import 'package:soom/presentation/screens/login/register.dart';
import 'package:soom/presentation/screens/main_view/favorite_screen/bloc/cubit.dart';
import 'package:soom/presentation/screens/main_view/main_screen.dart';
import 'package:soom/presentation/screens/login/bloc/states.dart';
import 'package:soom/presentation/screens/login/confirm.dart';
import 'package:soom/repository/repository.dart';
import 'package:soom/repository/request_models.dart';
import 'package:soom/test1.dart';

import '../../../../constants/api_constants.dart';
import '../../main_view/bloc/home_cubit.dart';
import '../../main_view/my_auctions/bloc/my_auctions_cubit.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(InitState());

  static LoginCubit get(context) => BlocProvider.of(context);
  final Repository _repository = Repository();

  String errorMessage = '';
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var resetPasswordController1 = TextEditingController();
  var resetPasswordController2 = TextEditingController();
  var phone = TextEditingController();
  bool finsh = false;

  // ---------- isRemember ----------------|
  bool isRemember = false;

  changeIconRemember() {
    isRemember = !isRemember;
    emit(IsRememberState());
  }

  // ---------- show password  ----------------|
  bool isObscureText = true;

  showPassword() {
    isObscureText = !isObscureText;
    emit(ShowPassword());
  }

  bool isObscureText1 = true;

  showPassword1() {
    isObscureText1 = !isObscureText1;
    emit(ShowPassword());
  }

  bool isObscureText2 = true;

  showPassword2() {
    isObscureText2 = !isObscureText2;
    emit(ShowPassword());
  }

  // ---------- Password Validation ----------------|

  passwordValidation(value, bool isLogin) {
    if (value!.length > 5) {
      RegExp regex = RegExp(
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{5,}$');
      if (value!.isEmpty) {
        return 'ادخل كلمة المرور ';
      } else {
        if (!regex.hasMatch(value) && isLogin == false) {
          return ''' يجب ان تحتوي كلمة المرور علي : 
                                حروف كبيره وصغيرة [A-Z] وارقام ورموز  ''';
        }
      }
    } else {
      return "كلمة المرور قصيرة جدا ";
    }
  }

  // ---------- Email Validation ----------------|

  emailValidation(value) {
    if (value!.isNotEmpty) {
      final bool isValid = EmailValidator.validate(value!);
      if (!isValid) {
        return "البريد الالكتروني غير صالح";
      }
    } else {
      return "لايمكن ترك الحقل فارغا";
    }
  }

  // ---------- Login ----------------|
  Future<void> loginUser(
      LoginRequest loginRequest, BuildContext context) async {
    Dio _dio = Dio(BaseOptions(baseUrl: ApiBase.baseUrl, headers: {
      "Content-Type": "application/json",
      "Accept": "text/plain",
    }));
    _dio.post(ApiBase.baseUrl + ApiEndPoint.authentication, data:{
      "userNameOrEmailAddress": loginRequest.email,
      "password": loginRequest.password,
    }).then((value) async {
      token = value.data["result"]["accessToken"];
      refreshToken = value.data["result"]["refreshToken"];
      id = value.data["result"]["userId"].toString();
      SharedPreferences.getInstance().then((pref) async {
        pref.setString(PrefsKey.token, token).then((value) {});
        pref.setString(PrefsKey.refreshToken, token).then((value) {});
        await pref.setString(PrefsKey.userId, id);
        await pref.setBool(PrefsKey.isLogin, true);
      });
      await getHomeData(context);
      Navigator.pop(context);
      AppToasts.toastSuccess("تم تسجيل الدخول بنجاح ! ", context);
      Timer(const Duration(seconds: 1), () {
        Navigator.pop(context);
        HomeCubit.get(context).currentIndex = 0;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ));
      });
    }).catchError((err) {
      if (kDebugMode) {
        print(err);
      }
      Navigator.pop(context);
      AppToasts.toastError("حدث خطأ ما حاول لاحقا ! ", context);
    });
  }

// ---------- register ----------------|
  String privacyPolicy = "";

  Future getPrivacyPolicy() async {
    DioFactory(token).getData(ApiEndPoint.getSystemConf,
        {"KEYNameFilter": "privacyPolicy"}).then((value) {
      privacyPolicy = value.data["result"]["items"][0]["systemConfigration"]
          ["slideDescription"];
      emit(GetPrivacySuccess());
    }).catchError((err) {
      if (kDebugMode) {
        print(err.toString());
      }
      emit(GetPrivacyError());
    });
  }

  register(RegisterRequest registerRequest, context) async {
    emit(RegisterLoading());
    AppToasts.toastLoading(context);
    (await _repository.register(
      registerRequest,
      context,
    )).fold((error) {
      emit(RegisterError(error));
      emailController.text = "";
      phone.text =  "";
      passwordController.text = "" ;
      Navigator.pop(context);
      AppToasts.toastError(error.message, context);
      Timer(const Duration(seconds: 2), (){
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
      });
      emit(DialogShow());
    }, (registerSuccess) {
      var login = LoginRequest(
        email: registerRequest.email,
        password: registerRequest.password ,
      );
      loginUser(login, context).then((value) async  {
        HomeCubit.get(context).currentIndex = 0 ;
        MyAuctionsCubit.get(context).isEmpty = true ;
        MyAuctionsCubit.get(context).isEmptyLast = true ;
        Navigator.pop(context);
        AppToasts.toastSuccess("تم التسجيل بنجاح", context);
        Timer(const Duration(seconds: 2), (){
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ));
        });
      }).catchError((err) {
        if (kDebugMode) {
          print(err.toString());
        }
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
      });
      emit(DialogShow());
    });
  }

// ---------- reset password  ----------------|
// TODO: BLOC RESET PASSWORD

// ------------ confirm  -------------- |

  var confirmController1 = TextEditingController();
  var confirmController2 = TextEditingController();
  var confirmController3 = TextEditingController();
  var confirmController4 = TextEditingController();

  int focus = 1;

  String code = "";

  String serverCode = "1234";

  nextConformField(
      String value, int theFocus, TextEditingController controller, context) {
    focus = theFocus;
    if (kDebugMode) {
      print(code);
    }
    if (focus != 4) {
      FocusScope.of(context).nextFocus();
    } else {
      // LoginCubit.get(context).focus = 1;
    }
    emit(NextConfirm());
  }

  checkConfirmCode(context) {
    code = confirmController1.text +
        confirmController2.text +
        confirmController3.text +
        confirmController4.text;
    confirmController1.clear();
    confirmController2.clear();
    confirmController3.clear();
    confirmController4.clear();
    if (serverCode == code) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ));
    } else {
      emit(NextConfirm());
      code = "";
      AppToasts.toastError("لقد أدخلت رمزا خاطئا ", context);
      emit(NextConfirm());
    }

    //TODO: CONFIRM MOBILE
  }

  getConfirmCodeFormServer() {
    // TODO:SEND PHONE NUMBER TO CONFIRM
  }

//---------- log out  ----------------|

  logOut(context) {
    emit(LogOutLoading());
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(PrefsKey.isLogin, false);
      prefs.remove(PrefsKey.token);
      emailController.text = "";
      passwordController.text = "";
      token = "";
      MyAuctionsCubit.get(context).myBidsForView = [] ;
      FavoriteCubit.get(context).favoritesItemsForView = [] ;
      FavoriteCubit.get(context).favoritesItemsResponse = [] ;
      HomeCubit.get(context).currentIndex = 0 ;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ));
      emit(LogOutSuccess());
    });
  }
}
