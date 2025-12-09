import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/AddProduct/add_edit_product_bloc.dart';
import 'package:simple/ModelClass/AddProduct/DeleteProductsModel.dart';
import 'package:simple/ModelClass/AddProduct/getAddProductListModel.dart';
import 'package:simple/ModelClass/AddProduct/getCategoryForAddProductModel.dart';
import 'package:simple/ModelClass/AddProduct/getSingleAddProductModel.dart';
import 'package:simple/ModelClass/AddProduct/postAddProductModel.dart';
import 'package:simple/ModelClass/AddProduct/putAddProductModel.dart';
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/image.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';

class ProductList extends StatelessWidget {
  final GlobalKey<ProductListViewState>? proKey;
  bool? hasRefreshedAddProduct;
  ProductList({
    super.key,
    this.proKey,
    this.hasRefreshedAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return ProductListView(
        proKey: proKey, hasRefreshedAddProduct: hasRefreshedAddProduct);
  }
}

class ProductListView extends StatefulWidget {
  final GlobalKey<ProductListViewState>? proKey;
  bool? hasRefreshedAddProduct;
  ProductListView({
    super.key,
    this.proKey,
    this.hasRefreshedAddProduct,
  });

  @override
  ProductListViewState createState() => ProductListViewState();
}

class ProductListViewState extends State<ProductListView> {
  GetLocationModel getLocationModel = GetLocationModel();
  GetCategoryForAddProductModel getCategoryForAddProductModel =
      GetCategoryForAddProductModel();
  PostAddProductModel postAddProductModel = PostAddProductModel();
  GetAddProductListModel getAddProductListModel = GetAddProductListModel();
  GetSingleAddProductModel getSingleAddProductModel =
      GetSingleAddProductModel();
  PutAddProductModel putAddProductModel = PutAddProductModel();
  DeleteProductsModel deleteProductModel = DeleteProductsModel();
  GetStockMaintanencesModel getStockMaintanencesModel =
      GetStockMaintanencesModel();
  final TextEditingController productController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController parcelPriceController = TextEditingController();
  final TextEditingController hdPriceController = TextEditingController();
  final TextEditingController acPriceController = TextEditingController();
  final TextEditingController swiggyPriceController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isAvailable = true;
  bool isStockTrack = false;
  bool isDailyStock = false;
  String? locationId;
  File? categoryImage;
  Uint8List? categoryImageBytes;
  String? pickedImageName;
  final ImagePicker picker = ImagePicker();
  int offset = 0;
  int currentPage = 0;
  int rowsPerPage = 10;
  int totalItems = 0;
  int totalPages = 1;
  final List<String> statusList = ["All", "Available", "Unavailable"];

  String? selectedStatus = "All";
  String? selectedCategory;
  String? selectedCategorySave;

  bool categoryLoad = false;
  bool saveLoad = false;
  bool editLoad = false;
  bool deleteLoad = false;
  bool stockDetailsLoad = false;
  bool stockLoad = false;
  bool proCatLoad = false;
  bool catLoad = false;
  bool expenseShowLoad = false;
  bool isEdit = false;
  String? errorMessage;
  String? catId;
  String? proId;
  String? catSaveId;
  String? apiImageUrl;

  void refreshAddProduct() {
    if (!mounted || !context.mounted) return;
    context.read<ProductBloc>().add(StockInLocation());
    context.read<ProductBloc>().add(StockDetails());
    setState(() {
      stockLoad = true;
      stockDetailsLoad = true;
    });
  }

  void clearCategoryForm() {
    setState(() {
      categoryImage = null;
      categoryImageBytes = null;
      apiImageUrl = null;
      selectedCategory = null;
      selectedCategorySave = null;
      catId = null;
      catSaveId = null;
      basePriceController.clear();
      parcelPriceController.clear();
      acPriceController.clear();
      hdPriceController.clear();
      swiggyPriceController.clear();
      productController.clear();
      codeController.clear();
      isStockTrack = false;
      isDailyStock = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.hasRefreshedAddProduct == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          stockLoad = true;
          catLoad = true;
        });
        widget.proKey?.currentState?.refreshAddProduct();
      });
    } else {
      context.read<ProductBloc>().add(StockInLocation());
      context.read<ProductBloc>().add(StockDetails());
      setState(() {
        stockLoad = true;
        stockDetailsLoad = true;
      });
    }
  }

  void _refreshData() {
    setState(() {
      searchController.clear();
      selectedStatus = "All";
      stockLoad = true;
      selectedCategory = null;
      selectedCategorySave = null;
      catId = null;
      catSaveId = null;
      offset = 0;
      currentPage = 0;
      rowsPerPage = 5;
      totalItems = 0;
      totalPages = 1;
    });
    context.read<ProductBloc>().add(StockInLocation());
    context.read<ProductBloc>().add(StockDetails());
    bool? statusValue = selectedStatus == "All"
        ? null
        : (selectedStatus == "Available" ? true : false);
    context.read<ProductBloc>().add(AddProduct(searchController.text,
        locationId ?? "", statusValue, offset, rowsPerPage, catId ?? ""));
    widget.proKey?.currentState?.refreshAddProduct();
  }

  void _refreshEditData() {
    setState(() {
      isEdit = false;
      categoryImage = null;
      categoryImageBytes = null;
      apiImageUrl = null;
      selectedCategorySave = null;
      proId = null;
      basePriceController.clear();
      parcelPriceController.clear();
      acPriceController.clear();
      hdPriceController.clear();
      swiggyPriceController.clear();
      productController.clear();
      codeController.clear();
      isStockTrack = false;
      isDailyStock = false;
    });
    context.read<ProductBloc>().add(StockInLocation());
    context.read<ProductBloc>().add(StockDetails());
    widget.proKey?.currentState?.refreshAddProduct();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> pickCategoryImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      apiImageUrl = null;
      if (kIsWeb) {
        Uint8List bytes = await pickedFile.readAsBytes();
        setState(() {
          pickedImageName = pickedFile.name;
          categoryImageBytes = bytes;
          categoryImage = null;
        });
      } else {
        setState(() {
          pickedImageName = pickedFile.name;
          categoryImage = File(pickedFile.path);
          categoryImageBytes = null;
        });
      }
    }
  }

  void reloadCategory() {
    offset = currentPage * rowsPerPage;
    bool? statusValue = selectedStatus == "All"
        ? null
        : (selectedStatus == "Available" ? true : false);

    context.read<ProductBloc>().add(
          AddProduct(searchController.text, locationId ?? "", statusValue,
              offset, rowsPerPage, catId ?? ""),
        );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildPaginationBar() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ---- Rows Per Page Dropdown ----
          Text("Rows per page: "),
          DropdownButton<int>(
            value: rowsPerPage,
            items: [5, 10, 20, 50].map((e) {
              return DropdownMenuItem(value: e, child: Text("$e"));
            }).toList(),
            onChanged: (value) {
              setState(() {
                rowsPerPage = value!;
                currentPage = 0;
                offset = 0;
                totalPages = (totalItems / rowsPerPage).ceil();
              });

              reloadCategory();
            },
          ),

          const SizedBox(width: 20),

          // ---- Page X of Y ----
          Text("${currentPage + 1} of $totalPages"),

          // ---- Prev Button ----
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 0
                ? () {
                    setState(() {
                      currentPage--;
                      offset = currentPage * rowsPerPage;
                    });
                    reloadCategory();
                  }
                : null,
          ),

          // ---- Next Button ----
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1
                ? () {
                    setState(() {
                      currentPage++;
                      offset = currentPage * rowsPerPage;
                    });
                    reloadCategory();
                  }
                : null,
          ),
        ],
      );
    }

    Widget mainContainer() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isEdit ? "Edit Product" : "Add New Product",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (isEdit)
                    IconButton(
                      onPressed: () {
                        _refreshEditData();
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: appPrimaryColor,
                        size: 28,
                      ),
                      tooltip: 'Refresh Products',
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- Row 1 ----------------

              Row(
                children: [
                  getLocationModel.data?.locationName != null
                      ? Expanded(
                          child: TextFormField(
                            enabled: false,
                            initialValue: getLocationModel.data!.locationName!,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              labelStyle: TextStyle(color: appPrimaryColor),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: greyColor),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: greyColor),
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (getCategoryForAddProductModel.data?.any((item) =>
                                  item.name == selectedCategorySave) ??
                              false)
                          ? selectedCategorySave
                          : null,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: appPrimaryColor,
                          ),
                        ),
                      ),
                      items: getCategoryForAddProductModel.data?.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(
                            "${item.name}",
                            style: MyTextStyle.f14(
                              blackColor,
                              weight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategorySave = newValue;
                            final selectedItem = getCategoryForAddProductModel
                                .data
                                ?.firstWhere((item) => item.name == newValue);
                            catSaveId = selectedItem?.id.toString();
                            debugPrint("categoryId:$catId");
                          });
                        }
                      },
                      hint: Text(
                        '-- Select Category --',
                        style: MyTextStyle.f14(
                          blackColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ---------------- Row 2 ----------------
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: productController,
                      decoration: InputDecoration(
                        labelText: "Product Name *",
                        labelStyle: MyTextStyle.f14(greyColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: codeController,
                      decoration: InputDecoration(
                        labelText: "Short Code",
                        labelStyle: MyTextStyle.f14(greyColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              // ---------------- Row 3 ----------------
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: basePriceController,
                      decoration: InputDecoration(
                        labelText: "Base Price *",
                        labelStyle: MyTextStyle.f14(greyColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: parcelPriceController,
                      decoration: InputDecoration(
                        labelText: "Parcel Price *",
                        labelStyle: MyTextStyle.f14(greyColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: acPriceController,
                      decoration: InputDecoration(
                        labelText: "AC Price *",
                        labelStyle: MyTextStyle.f14(greyColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: hdPriceController,
                      decoration: InputDecoration(
                        labelText: "HD Price *",
                        labelStyle: MyTextStyle.f14(greyColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: swiggyPriceController,
                      decoration: InputDecoration(
                        labelText: "SWIGGY Price *",
                        labelStyle: MyTextStyle.f14(greyColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (categoryImage == null &&
                  categoryImageBytes == null &&
                  (apiImageUrl == null || apiImageUrl!.isEmpty))
                GestureDetector(
                  onTap: pickCategoryImage,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "UPLOAD IMAGE",
                      style: TextStyle(
                        color: appPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

// ---------------------- IMAGE FROM API ----------------------
              if (categoryImage == null &&
                  categoryImageBytes == null &&
                  apiImageUrl != null &&
                  apiImageUrl!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: Image.network(apiImageUrl!, fit: BoxFit.cover),
                  ),
                ),

                const SizedBox(height: 10),

                // CHANGE IMAGE
                Center(
                  child: GestureDetector(
                    onTap: pickCategoryImage,
                    child: const Text(
                      "CHANGE IMAGE",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        apiImageUrl = null;
                      });
                    },
                    child: const Text(
                      "REMOVE",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              if (categoryImage != null || categoryImageBytes != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: kIsWeb
                        ? Image.memory(categoryImageBytes!, fit: BoxFit.cover)
                        : Image.file(categoryImage!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: pickCategoryImage,
                    child: const Text(
                      "CHANGE IMAGE",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // REMOVE
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        categoryImage = null;
                        categoryImageBytes = null;
                      });
                    },
                    child: const Text(
                      "REMOVE",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              // ---------------- Row 4 ----------------
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: isAvailable,
                    onChanged: (value) {
                      setState(() {
                        isAvailable = value!;
                      });
                    },
                    activeColor: appPrimaryColor,
                  ),
                  const Text("Available in POS",
                      style: TextStyle(fontSize: 16)),
                  if (getStockMaintanencesModel.data?.stockMaintenance ==
                      true) ...[
                    Checkbox(
                      value: isStockTrack,
                      onChanged: (value) {
                        setState(() {
                          isStockTrack = value!;
                        });
                      },
                      activeColor: appPrimaryColor,
                    ),
                    const Text("Track Stock", style: TextStyle(fontSize: 16)),
                  ],
                  if (getStockMaintanencesModel.data?.stockMaintenance ==
                      true) ...[
                    Checkbox(
                      value: isDailyStock,
                      onChanged: (value) {
                        setState(() {
                          isDailyStock = value!;
                        });
                      },
                      activeColor: appPrimaryColor,
                    ),
                    const Text("Daily Stock Clear",
                        style: TextStyle(fontSize: 16)),
                  ]
                ],
              ),

              const SizedBox(height: 30),
              isEdit == true
                  ? Center(
                      child: editLoad
                          ? SpinKitCircle(color: appPrimaryColor, size: 30)
                          : ElevatedButton(
                              onPressed: () {
                                if (getLocationModel.data!.locationName ==
                                    null) {
                                  showToast("Location not found", context,
                                      color: false);
                                } else if (selectedCategorySave == null) {
                                  showToast("Select Category", context,
                                      color: false);
                                } else if (productController.text.isEmpty) {
                                  showToast("Enter product name", context,
                                      color: false);
                                } else if (basePriceController.text.isEmpty) {
                                  showToast("Enter Base Price", context,
                                      color: false);
                                } else if (parcelPriceController.text.isEmpty) {
                                  showToast("Enter Parcel Price", context,
                                      color: false);
                                } else if (acPriceController.text.isEmpty) {
                                  showToast("Enter AC Price", context,
                                      color: false);
                                } else if (hdPriceController.text.isEmpty) {
                                  showToast("Enter HD Price", context,
                                      color: false);
                                } else if (swiggyPriceController.text.isEmpty) {
                                  showToast("Enter Swiggy Price", context,
                                      color: false);
                                } else {
                                  setState(() {
                                    editLoad = true;
                                    context.read<ProductBloc>().add(
                                        UpdateProduct(
                                            proId.toString(),
                                            productController.text,
                                            codeController.text,
                                            basePriceController.text,
                                            parcelPriceController.text,
                                            acPriceController.text,
                                            hdPriceController.text,
                                            swiggyPriceController.text,
                                            isAvailable,
                                            false,
                                            catSaveId.toString(),
                                            locationId.toString(),
                                            isDailyStock,
                                            isStockTrack,
                                            pickedImageName.toString(),
                                            imageBytes: categoryImageBytes,
                                            imageFile: categoryImage));
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appPrimaryColor,
                                minimumSize: const Size(0, 50), // Height only
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Update Product",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                    )
                  : Center(
                      child: saveLoad
                          ? SpinKitCircle(color: appPrimaryColor, size: 30)
                          : ElevatedButton(
                              onPressed: () {
                                if (getLocationModel.data!.locationName ==
                                    null) {
                                  showToast("Location not found", context,
                                      color: false);
                                } else if (selectedCategorySave == null) {
                                  showToast("Select Category", context,
                                      color: false);
                                } else if (productController.text.isEmpty) {
                                  showToast("Enter product name", context,
                                      color: false);
                                } else if (basePriceController.text.isEmpty) {
                                  showToast("Enter Base Price", context,
                                      color: false);
                                } else if (parcelPriceController.text.isEmpty) {
                                  showToast("Enter Parcel Price", context,
                                      color: false);
                                } else if (acPriceController.text.isEmpty) {
                                  showToast("Enter AC Price", context,
                                      color: false);
                                } else if (hdPriceController.text.isEmpty) {
                                  showToast("Enter HD Price", context,
                                      color: false);
                                } else if (swiggyPriceController.text.isEmpty) {
                                  showToast("Enter Swiggy Price", context,
                                      color: false);
                                } else {
                                  setState(() {
                                    saveLoad = true;
                                    context.read<ProductBloc>().add(SaveProduct(
                                        productController.text,
                                        codeController.text,
                                        basePriceController.text,
                                        parcelPriceController.text,
                                        acPriceController.text,
                                        hdPriceController.text,
                                        swiggyPriceController.text,
                                        isAvailable,
                                        false,
                                        catSaveId.toString(),
                                        locationId.toString(),
                                        isDailyStock,
                                        isStockTrack,
                                        pickedImageName.toString(),
                                        imageBytes: categoryImageBytes,
                                        imageFile: categoryImage));
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appPrimaryColor,
                                minimumSize: const Size(0, 50), // Height only
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Add Product",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                    ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Products List",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Filters",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _refreshData();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        minimumSize: const Size(0, 40), // Height only
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )),
                    child: const Text(
                      "CLEAR FILTERS",
                      style: TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name...',
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        searchController
                          ..text = (value)
                          ..selection = TextSelection.collapsed(
                              offset: searchController.text.length);
                        setState(() {
                          bool? statusValue = selectedStatus == "All"
                              ? null
                              : (selectedStatus == "Available" ? true : false);
                          context.read<ProductBloc>().add(AddProduct(
                              searchController.text,
                              locationId ?? "",
                              statusValue,
                              offset,
                              rowsPerPage,
                              catId ?? ""));
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: statusList
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedStatus = v;
                          debugPrint("status:$selectedStatus");
                          bool? statusValue = selectedStatus == "All"
                              ? null
                              : (selectedStatus == "Available" ? true : false);
                          context.read<ProductBloc>().add(AddProduct(
                              searchController.text,
                              locationId ?? "",
                              statusValue,
                              offset,
                              rowsPerPage,
                              catId ?? ""));
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Select Status *",
                        labelStyle: TextStyle(color: appPrimaryColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (getCategoryForAddProductModel.data?.any(
                                  (item) => item.name == selectedCategory) ??
                              false)
                          ? selectedCategory
                          : null,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: appPrimaryColor,
                          ),
                        ),
                      ),
                      items: getCategoryForAddProductModel.data?.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(
                            "${item.name}",
                            style: MyTextStyle.f14(
                              blackColor,
                              weight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategory = newValue;
                            final selectedItem = getCategoryForAddProductModel
                                .data
                                ?.firstWhere((item) => item.name == newValue);
                            catId = selectedItem?.id.toString();
                            debugPrint("categoryId:$catId");
                            bool? statusValue = selectedStatus == "All"
                                ? null
                                : (selectedStatus == "Available"
                                    ? true
                                    : false);
                            context.read<ProductBloc>().add(AddProduct(
                                searchController.text,
                                locationId ?? "",
                                statusValue,
                                offset,
                                rowsPerPage,
                                catId ?? ""));
                          });
                        }
                      },
                      hint: Text(
                        '-- Select Category --',
                        style: MyTextStyle.f14(
                          blackColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              catLoad
                  ? Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1),
                      alignment: Alignment.center,
                      child: const SpinKitChasingDots(
                          color: appPrimaryColor, size: 30))
                  : getAddProductListModel.data == null ||
                          getAddProductListModel.data == [] ||
                          getAddProductListModel.data!.isEmpty
                      ? Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.1),
                          alignment: Alignment.center,
                          child: Text(
                            "No Products Found !!!",
                            style: MyTextStyle.f16(
                              greyColor,
                              weight: FontWeight.w500,
                            ),
                          ))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth;
                            double colImage = availableWidth * 0.08;
                            double colName = availableWidth * 0.08;
                            double colCode = availableWidth * 0.08;
                            double colCategory = availableWidth * 0.09;
                            double colBase = availableWidth * 0.08;
                            double colStock = availableWidth * 0.07;
                            double colDailyHeader = availableWidth * 0.08;
                            double colDaily = availableWidth * 0.07;
                            double colStatusHeader = availableWidth * 0.07;
                            double colStatus = availableWidth * 0.10;
                            double colActions = availableWidth * 0.10;
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: availableWidth,
                                  // Ensures table takes full width
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dataTableTheme: const DataTableThemeData(
                                      dataRowMinHeight: 50,
                                      dataRowMaxHeight: 50,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      DataTable(
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                                Colors.grey.shade200),
                                        dataRowHeight: 55,
                                        headingTextStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                        columnSpacing: availableWidth * 0.08,
                                        // columnSpacing: 50,
                                        columns: [
                                          DataColumn(
                                            label: SizedBox(
                                              width: colImage,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15),
                                                child: const Text("Image"),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colName,
                                              child: const Text("Name"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colCode,
                                              child: const Text("Code"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colCategory,
                                              child: const Text("Category"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colBase,
                                              child: const Text("Base Price"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colStock,
                                              child: const Text("Stock"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colDailyHeader,
                                              child: const Text("Daily Clear"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colStatusHeader,
                                              child: const Text("Status"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colActions,
                                              child: const Text("Actions"),
                                            ),
                                          ),
                                        ],
                                        rows: getAddProductListModel.data!
                                            .map((item) {
                                          return DataRow(
                                            cells: [
                                              DataCell(SizedBox(
                                                width: colImage,
                                                child: Center(
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                    backgroundImage: item
                                                                .image !=
                                                            null
                                                        ? NetworkImage(item
                                                            .image
                                                            .toString())
                                                        : AssetImage(Images.all)
                                                            as ImageProvider,
                                                    onBackgroundImageError:
                                                        (_, __) {
                                                      // fallback handled by backgroundImage
                                                    },
                                                  ),
                                                ),
                                              )),
                                              DataCell(
                                                SizedBox(
                                                  width: colName,
                                                  child: Text(
                                                    item.name ?? "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: colCode,
                                                  child: Text(
                                                    item.shortCode ?? "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: colCategory,
                                                  child: Text(
                                                    item.category?.name ?? "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: colBase,
                                                  child: Text(
                                                    item.basePrice
                                                            ?.toStringAsFixed(
                                                                2) ??
                                                        "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: colStock,
                                                  child: Container(
                                                    height: 20,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            item.isStock == true
                                                                ? greenColor
                                                                : greyColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Text(
                                                      item.isStock == true
                                                          ? "Yes"
                                                          : "No",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: colDaily,
                                                  child: Container(
                                                    height: 20,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            item.dailyStockClear ==
                                                                    true
                                                                ? greenColor
                                                                : greyColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Text(
                                                      item.dailyStockClear ==
                                                              true
                                                          ? "Yes"
                                                          : "No",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: colStatus,
                                                  child: Container(
                                                    height: 20,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color: item.isDefault ==
                                                                true
                                                            ? greenColor
                                                            : redColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Text(
                                                      item.isDefault == true
                                                          ? "Available"
                                                          : "Unavailable",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: colActions,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color:
                                                              appPrimaryColor,
                                                          size: 18,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            isEdit = true;
                                                            proId = item.id
                                                                .toString();
                                                            debugPrint(
                                                                "isEdit_$isEdit");
                                                          });
                                                          context
                                                              .read<
                                                                  ProductBloc>()
                                                              .add(ProductById(proId
                                                                  .toString()));
                                                        },
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: redColor,
                                                          size: 18,
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  ProductBloc>()
                                                              .add(DeleteProduct(item
                                                                  .id
                                                                  .toString()));
                                                        },
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                      buildPaginationBar(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
            ],
          ),
        ),
      );
    }

    return BlocBuilder<ProductBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetLocationModel) {
          getLocationModel = current;
          if (getLocationModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getLocationModel.success == true) {
            locationId = getLocationModel.data?.locationId;
            debugPrint("locationId:$locationId");
            debugPrint("locationId:$locationId");
            context
                .read<ProductBloc>()
                .add(AddCategoryForProduct(locationId ?? ""));
            bool? statusValue = selectedStatus == "All"
                ? null
                : (selectedStatus == "Available" ? true : false);
            context.read<ProductBloc>().add(AddProduct(
                searchController.text,
                locationId ?? "",
                statusValue,
                offset,
                rowsPerPage,
                catId ?? ""));
            setState(() {
              stockLoad = false;
              catLoad = true;
            });
          } else {
            debugPrint("${getLocationModel.data?.locationName}");
            setState(() {
              stockLoad = false;
            });
            showToast("No Location found", context, color: false);
          }
          return true;
        }
        if (current is PostAddProductModel) {
          postAddProductModel = current;
          if (postAddProductModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (postAddProductModel.success == true) {
            showToast("Product Added Successfully", context, color: true);
            bool? statusValue = selectedStatus == "All"
                ? null
                : (selectedStatus == "Available" ? true : false);
            context.read<ProductBloc>().add(AddProduct(
                searchController.text,
                locationId ?? "",
                statusValue,
                offset,
                rowsPerPage,
                catId ?? ""));
            Future.delayed(Duration(milliseconds: 100), () {
              clearCategoryForm();
            });
            setState(() {
              saveLoad = false;
            });
          } else {
            setState(() {
              saveLoad = false;
            });
          }
          return true;
        }
        if (current is GetAddProductListModel) {
          getAddProductListModel = current;
          if (getAddProductListModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getAddProductListModel.success == true) {
            setState(() {
              catLoad = false;
              totalItems = int.parse(
                  getAddProductListModel.totalCount.toString()); // API response
              totalPages = (totalItems / rowsPerPage).ceil();
            });
          } else {
            setState(() {
              catLoad = false;
            });
            showToast("No Products found", context, color: false);
          }
          return true;
        }
        if (current is GetSingleAddProductModel) {
          getSingleAddProductModel = current;
          if (getSingleAddProductModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getSingleAddProductModel.success == true) {
            setState(() {
              if (getSingleAddProductModel.data != null) {
                catSaveId =
                    getSingleAddProductModel.data!.category!.id.toString();
                selectedCategorySave =
                    getSingleAddProductModel.data!.category!.name.toString();
                productController.text =
                    getSingleAddProductModel.data!.name.toString();
                codeController.text =
                    getSingleAddProductModel.data!.shortCode.toString();
                basePriceController.text =
                    getSingleAddProductModel.data!.basePrice.toString();
                parcelPriceController.text =
                    getSingleAddProductModel.data!.parcelPrice.toString();
                acPriceController.text =
                    getSingleAddProductModel.data!.acPrice.toString();
                hdPriceController.text =
                    getSingleAddProductModel.data!.hdPrice.toString();
                swiggyPriceController.text =
                    getSingleAddProductModel.data!.swiggyPrice.toString();
                isAvailable = getSingleAddProductModel.data!.isDefault ?? false;
                apiImageUrl = getSingleAddProductModel.data!.image;
                isStockTrack = getSingleAddProductModel.data!.isStock ?? false;
                isDailyStock =
                    getSingleAddProductModel.data!.dailyStockClear ?? false;
              }
              expenseShowLoad = false;
            });
          } else {
            setState(() {
              expenseShowLoad = false;
            });
          }
          return true;
        }
        if (current is PutAddProductModel) {
          putAddProductModel = current;
          if (putAddProductModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (putAddProductModel.success == true) {
            _refreshEditData();
            bool? statusValue = selectedStatus == "All"
                ? null
                : (selectedStatus == "Available" ? true : false);
            context.read<ProductBloc>().add(AddProduct(
                searchController.text,
                locationId ?? "",
                statusValue,
                offset,
                rowsPerPage,
                catId ?? ""));
            Future.delayed(Duration(milliseconds: 100), () {
              clearCategoryForm();
            });
            setState(() {
              editLoad = false;
              showToast("Product Updated Successfully", context, color: true);
            });
          } else {
            setState(() {
              editLoad = false;
            });
          }
          return true;
        }
        if (current is DeleteProductsModel) {
          deleteProductModel = current;
          if (deleteProductModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (deleteProductModel.success == true) {
            setState(() {
              deleteLoad = false;
              catLoad = true;
              showToast("${deleteProductModel.message}", context, color: true);
            });
            bool? statusValue = selectedStatus == "All"
                ? null
                : (selectedStatus == "Available" ? true : false);
            context.read<ProductBloc>().add(AddProduct(
                searchController.text,
                locationId ?? "",
                statusValue,
                offset,
                rowsPerPage,
                catId ?? ""));
          } else if (deleteProductModel.errorResponse != null) {
            debugPrint(
                "deleteError:${deleteProductModel.errorResponse?.message}");
            showToast("${deleteProductModel.errorResponse?.message}", context,
                color: false);
            setState(() {
              deleteLoad = false;
            });
          }
          return true;
        }
        if (current is GetStockMaintanencesModel) {
          getStockMaintanencesModel = current;
          if (getStockMaintanencesModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getStockMaintanencesModel.success == true) {
            setState(() {
              stockDetailsLoad = false;
            });
          } else {
            setState(() {
              stockDetailsLoad = false;
            });
            showToast("No Stock found", context, color: false);
          }
          return true;
        }
        if (current is GetCategoryForAddProductModel) {
          getCategoryForAddProductModel = current;
          if (getCategoryForAddProductModel.errorResponse?.isUnauthorized ==
              true) {
            _handle401Error();
            return true;
          }
          if (getCategoryForAddProductModel.success == true) {
            setState(() {
              proCatLoad = false;
            });
          } else {
            setState(() {
              proCatLoad = false;
            });
            showToast("No Category found", context, color: false);
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
