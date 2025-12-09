import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/UI/Authentication/login_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLogout;
  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodCategoryBloc(),
      child: CustomAppBarView(
        selectedIndex: selectedIndex,
        onTabSelected: onTabSelected,
        onLogout: onLogout,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class CustomAppBarView extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLogout;
  const CustomAppBarView({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  CustomAppBarViewState createState() => CustomAppBarViewState();
}

class CustomAppBarViewState extends State<CustomAppBarView> {
  GetStockMaintanencesModel getStockMaintanencesModel =
      GetStockMaintanencesModel();
  bool stockLoad = false;
  @override
  void initState() {
    super.initState();
    context.read<FoodCategoryBloc>().add(StockDetails());
    setState(() {
      stockLoad = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Widget mainContainer() {
      return AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: appPrimaryColor),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Opens the drawer
              },
              tooltip: 'Menu',
            );
          },
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactMode = constraints.maxWidth < 600;
            return Row(
              children: [
                if (getStockMaintanencesModel.data?.name != null)
                  Flexible(
                    child: Text(
                      getStockMaintanencesModel.data!.name.toString(),
                      style: TextStyle(
                        fontSize: isCompactMode ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: appPrimaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          },
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.logout, color: appPrimaryColor),
              onPressed: widget.onLogout,
              tooltip: 'Logout',
            ),
          ),
        ],
      );
    }

    return BlocBuilder<FoodCategoryBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetStockMaintanencesModel) {
          getStockMaintanencesModel = current;
          if (getStockMaintanencesModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getStockMaintanencesModel.success == true) {
            setState(() {
              stockLoad = false;
            });
          } else {
            setState(() {
              stockLoad = false;
            });
            showToast("No Stock found", context, color: false);
          }
          return true;
        }
        return false;
      }),
      builder: (context, dynamic) {
        return mainContainer();
      },
    );
  }

  void _handle401Error() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("token");
    await sharedPreferences.clear();
    showToast("Session expired. Please login again.", context, color: false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
