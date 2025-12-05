import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/AddCategory/add_edit_category_bloc.dart';
import 'package:simple/ModelClass/AddCategory/PostCategoryModel.dart';
import 'package:simple/ModelClass/AddCategory/addCategoryListModel.dart';
import 'package:simple/ModelClass/AddCategory/deleteCategoryModel.dart';
import 'package:simple/ModelClass/AddCategory/getSingleCategoryModel.dart';
import 'package:simple/ModelClass/AddCategory/putCategoryModel.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/image.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';

class CategoryList extends StatelessWidget {
  final GlobalKey<CategoryListViewState>? catKey;
  bool? hasRefreshedCategory;
  CategoryList({
    super.key,
    this.catKey,
    this.hasRefreshedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryListView(
        catKey: catKey, hasRefreshedCategory: hasRefreshedCategory);
  }
}

class CategoryListView extends StatefulWidget {
  final GlobalKey<CategoryListViewState>? catKey;
  bool? hasRefreshedCategory;
  CategoryListView({
    super.key,
    this.catKey,
    this.hasRefreshedCategory,
  });

  @override
  CategoryListViewState createState() => CategoryListViewState();
}

class CategoryListViewState extends State<CategoryListView> {
  GetLocationModel getLocationModel = GetLocationModel();
  PostCategoryModel postCategoryModel = PostCategoryModel();
  AddCategoryListModel addCategoryListModel = AddCategoryListModel();
  GetSingleCategoryModel getSingleCategoryModel = GetSingleCategoryModel();
  PutCategoryModel putCategoryModel = PutCategoryModel();
  DeleteCategoryModel deleteCategoryModel = DeleteCategoryModel();

  final TextEditingController categoryController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isAvailable = true;
  String? locationId;
  File? categoryImage;
  Uint8List? categoryImageBytes;
  String? pickedImageName;
  final ImagePicker picker = ImagePicker();
  int offset = 0;
  int currentPage = 0;
  int rowsPerPage = 5;
  int totalItems = 0;
  int totalPages = 1;
  final List<String> statusList = ["All", "Available", "Unavailable"];

  String? selectedStatus = "All";

  bool categoryLoad = false;
  bool saveLoad = false;
  bool editLoad = false;
  bool deleteLoad = false;

  bool stockLoad = false;
  bool catLoad = false;
  bool expenseShowLoad = false;
  bool isEdit = false;
  String? errorMessage;
  String? catId;
  String? apiImageUrl;

  void refreshCategory() {
    if (!mounted || !context.mounted) return;
    context.read<CategoryBloc>().add(StockInLocation());
    setState(() {
      stockLoad = true;
    });
  }

  void clearCategoryForm() {
    setState(() {
      categoryImage = null;
      categoryImageBytes = null;
      apiImageUrl = null;
      categoryController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.hasRefreshedCategory == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          stockLoad = true;
          catLoad = true;
        });
        widget.catKey?.currentState?.refreshCategory();
      });
    } else {
      context.read<CategoryBloc>().add(StockInLocation());

      setState(() {
        stockLoad = true;
      });
    }
  }

  void _refreshData() {
    setState(() {
      searchController.clear();
      selectedStatus = "All";
      stockLoad = true;
      offset = 0;
      currentPage = 0;
      rowsPerPage = 5;
      totalItems = 0;
      totalPages = 1;
    });
    context.read<CategoryBloc>().add(StockInLocation());
    bool? statusValue = selectedStatus == "All"
        ? null
        : (selectedStatus == "Available" ? true : false);
    context.read<CategoryBloc>().add(AddCategory(searchController.text,
        locationId ?? "", statusValue, offset, rowsPerPage));
    widget.catKey?.currentState?.refreshCategory();
  }

  void _refreshEditData() {
    setState(() {
      isEdit = false;
      categoryImage = null;
      categoryImageBytes = null;
      apiImageUrl = null;
      categoryController.clear();
    });
    context.read<CategoryBloc>().add(StockInLocation());
    widget.catKey?.currentState?.refreshCategory();
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

    context.read<CategoryBloc>().add(
          AddCategory(searchController.text, locationId ?? "", statusValue,
              offset, rowsPerPage),
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
                    isEdit ? "Edit Category" : "Add New Category",
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
                      : SizedBox.shrink()
                ],
              ),

              const SizedBox(height: 15),

              // ---------------- Row 2 ----------------
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: "Category Name *",
                        labelStyle: MyTextStyle.f14(greyColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              // ---------------- Row 3 ----------------
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
                  const Text("Available", style: TextStyle(fontSize: 16)),
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
                                } else if (categoryController.text.isEmpty) {
                                  showToast("Enter category name", context,
                                      color: false);
                                } else {
                                  setState(() {
                                    editLoad = true;
                                    String finalImageName =
                                        pickedImageName ?? "";
                                    Uint8List? finalBytes = categoryImageBytes;
                                    File? finalFile = categoryImage;
                                    debugPrint("finalByte:$finalBytes");
                                    debugPrint("finalFile:$finalFile");
                                    debugPrint("apiImage:$apiImageUrl");
                                    if (finalBytes == null &&
                                        finalFile == null) {
                                      finalImageName = apiImageUrl ?? "";
                                    }
                                    context
                                        .read<CategoryBloc>()
                                        .add(UpdateCategory(
                                          catId.toString(),
                                          categoryController.text,
                                          isAvailable,
                                          locationId.toString(),
                                          finalImageName,
                                          imageBytes: finalBytes,
                                          imageFile: finalFile,
                                        ));
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
                                "Update Category",
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
                                } else if (categoryController.text.isEmpty) {
                                  showToast("Enter category name", context,
                                      color: false);
                                } else {
                                  setState(() {
                                    saveLoad = true;
                                    context.read<CategoryBloc>().add(
                                        SaveCategory(
                                            categoryController.text,
                                            isAvailable,
                                            locationId.toString(),
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
                                "SAVE",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                    ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Category List",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Filters",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
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
                          context.read<CategoryBloc>().add(AddCategory(
                              searchController.text,
                              locationId ?? "",
                              statusValue,
                              offset,
                              rowsPerPage));
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
                          context.read<CategoryBloc>().add(AddCategory(
                              searchController.text,
                              locationId ?? "",
                              statusValue,
                              offset,
                              rowsPerPage));
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
                  ElevatedButton(
                    onPressed: () {
                      _refreshData();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        minimumSize: const Size(0, 50), // Height only
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

              const SizedBox(height: 20),

              catLoad
                  ? Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1),
                      alignment: Alignment.center,
                      child: const SpinKitChasingDots(
                          color: appPrimaryColor, size: 30))
                  : addCategoryListModel.data == null ||
                          addCategoryListModel.data == [] ||
                          addCategoryListModel.data!.isEmpty
                      ? Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.1),
                          alignment: Alignment.center,
                          child: Text(
                            "No Category Today !!!",
                            style: MyTextStyle.f16(
                              greyColor,
                              weight: FontWeight.w500,
                            ),
                          ))
                      :
                      // LayoutBuilder(
                      //             builder: (context, constraints) {
                      //               final availableWidth = constraints.maxWidth;
                      //
                      //               // compute column widths once (tweak proportions to taste)
                      //               final double colImage =
                      //                   availableWidth * 0.08; // image (small)
                      //               final double colName =
                      //                   availableWidth * 0.24; // name (bigger)
                      //               final double colProducts =
                      //                   availableWidth * 0.18; // products badge
                      //               final double colStatus =
                      //                   availableWidth * 0.14; // status badge
                      //               final double colLocation =
                      //                   availableWidth * 0.18; // location
                      //               final double colActions =
                      //                   availableWidth * 0.12; // actions
                      //
                      //               return SingleChildScrollView(
                      //                 scrollDirection: Axis.horizontal,
                      //                 child: ConstrainedBox(
                      //                   // ensure table occupies at least the available width
                      //                   constraints:
                      //                       BoxConstraints(minWidth: availableWidth),
                      //                   child: Theme(
                      //                     data: Theme.of(context).copyWith(
                      //                       dataTableTheme: const DataTableThemeData(
                      //                         dataRowMinHeight: 56,
                      //                         dataRowMaxHeight: 56,
                      //                       ),
                      //                     ),
                      //                     child: Column(
                      //                       crossAxisAlignment:
                      //                           CrossAxisAlignment.stretch,
                      //                       children: [
                      //                         DataTable(
                      //                           headingRowColor:
                      //                               MaterialStateProperty.all(
                      //                                   Colors.grey.shade200),
                      //                           dataRowHeight: 64,
                      //                           headingTextStyle: const TextStyle(
                      //                             fontWeight: FontWeight.bold,
                      //                             color: Colors.black87,
                      //                             fontSize: 14,
                      //                           ),
                      //                           columnSpacing:
                      //                               16, // spacing between columns (visual)
                      //                           columns: [
                      //                             DataColumn(
                      //                               label: SizedBox(
                      //                                 width: colImage,
                      //                                 child: Padding(
                      //                                   padding: const EdgeInsets.only(
                      //                                       left: 8.0),
                      //                                   child: const Text("Image"),
                      //                                 ),
                      //                               ),
                      //                             ),
                      //                             DataColumn(
                      //                               label: SizedBox(
                      //                                 width: colName,
                      //                                 child: const Text("Name"),
                      //                               ),
                      //                             ),
                      //                             DataColumn(
                      //                               label: SizedBox(
                      //                                 width: colProducts,
                      //                                 child: const Text("Products"),
                      //                               ),
                      //                             ),
                      //                             DataColumn(
                      //                               label: SizedBox(
                      //                                 width: colStatus,
                      //                                 child: const Text("Status"),
                      //                               ),
                      //                             ),
                      //                             DataColumn(
                      //                               label: SizedBox(
                      //                                 width: colLocation,
                      //                                 child: const Text("Location"),
                      //                               ),
                      //                             ),
                      //                             DataColumn(
                      //                               label: SizedBox(
                      //                                 width: colActions,
                      //                                 child: const Text("Actions"),
                      //                               ),
                      //                             ),
                      //                           ],
                      //                           rows: addCategoryListModel.data!
                      //                               .map((item) {
                      //                             return DataRow(cells: [
                      //                               // Image cell: use same width as header
                      //                               DataCell(
                      //                                 SizedBox(
                      //                                   width: colImage,
                      //                                   child: Center(
                      //                                     child: CircleAvatar(
                      //                                       radius: (colImage / 2) -
                      //                                           8, // adjust radius
                      //                                       backgroundColor:
                      //                                           Colors.grey.shade200,
                      //                                       backgroundImage: item
                      //                                                   .image !=
                      //                                               null
                      //                                           ? NetworkImage(item
                      //                                               .image
                      //                                               .toString())
                      //                                           : AssetImage(Images.all)
                      //                                               as ImageProvider,
                      //                                     ),
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //
                      //                               // Name
                      //                               DataCell(
                      //                                 SizedBox(
                      //                                   width: colName,
                      //                                   child: Text(
                      //                                     item.name ?? "",
                      //                                     overflow:
                      //                                         TextOverflow.ellipsis,
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //
                      //                               // Products badge
                      //                               DataCell(
                      //                                 SizedBox(
                      //                                   width: colProducts,
                      //                                   child: Align(
                      //                                     alignment: Alignment.center,
                      //                                     child: Container(
                      //                                       padding: const EdgeInsets
                      //                                           .symmetric(
                      //                                           horizontal: 8,
                      //                                           vertical: 4),
                      //                                       decoration: BoxDecoration(
                      //                                         color:
                      //                                             item.productCount == 0
                      //                                                 ? greyColor200
                      //                                                 : greenColor,
                      //                                         borderRadius:
                      //                                             BorderRadius.circular(
                      //                                                 20),
                      //                                       ),
                      //                                       child: Text(
                      //                                         "${item.productCount == 0 ? "No" : item.productCount} Products",
                      //                                         overflow:
                      //                                             TextOverflow.ellipsis,
                      //                                       ),
                      //                                     ),
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //
                      //                               // Status badge
                      //                               DataCell(
                      //                                 SizedBox(
                      //                                   width: colStatus,
                      //                                   child: Align(
                      //                                     alignment: Alignment.center,
                      //                                     child: Container(
                      //                                       padding: const EdgeInsets
                      //                                           .symmetric(
                      //                                           horizontal: 12,
                      //                                           vertical: 6),
                      //                                       decoration: BoxDecoration(
                      //                                         color: item.statusText ==
                      //                                                 "Available"
                      //                                             ? greenColor
                      //                                             : redColor,
                      //                                         borderRadius:
                      //                                             BorderRadius.circular(
                      //                                                 20),
                      //                                       ),
                      //                                       child: Text(
                      //                                           item.statusText ?? ""),
                      //                                     ),
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //
                      //                               // Location
                      //                               DataCell(
                      //                                 SizedBox(
                      //                                   width: colLocation,
                      //                                   child: Text(
                      //                                     item.locationId?.name ?? "",
                      //                                     overflow:
                      //                                         TextOverflow.ellipsis,
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //
                      //                               // Actions
                      //                               DataCell(
                      //                                 SizedBox(
                      //                                   width: colActions,
                      //                                   child: Row(
                      //                                     mainAxisAlignment:
                      //                                         MainAxisAlignment.center,
                      //                                     children: [
                      //                                       IconButton(
                      //                                         icon: const Icon(
                      //                                           Icons.edit,
                      //                                           color: appPrimaryColor,
                      //                                           size: 18,
                      //                                         ),
                      //                                         onPressed: () {
                      //                                           setState(() {
                      //                                             isEdit = true;
                      //                                             catId = item.id
                      //                                                 .toString();
                      //                                           });
                      //                                           context
                      //                                               .read<
                      //                                                   CategoryBloc>()
                      //                                               .add(CategoryById(
                      //                                                   catId
                      //                                                       .toString()));
                      //                                         },
                      //                                         padding: EdgeInsets.zero,
                      //                                         constraints:
                      //                                             const BoxConstraints(),
                      //                                       ),
                      //                                       const SizedBox(width: 6),
                      //                                       IconButton(
                      //                                         icon: const Icon(
                      //                                           Icons.delete,
                      //                                           color: redColor,
                      //                                           size: 18,
                      //                                         ),
                      //                                         onPressed: () {},
                      //                                         padding: EdgeInsets.zero,
                      //                                         constraints:
                      //                                             const BoxConstraints(),
                      //                                       ),
                      //                                     ],
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //                             ]);
                      //                           }).toList(),
                      //                         ),
                      //
                      //                         // Pagination bar below DataTable
                      //                         buildPaginationBar(),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 ),
                      //               );
                      //             },
                      //           ),

                      LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate column widths based on available screen width
                            final availableWidth = constraints.maxWidth;
                            final availableHeight = constraints.maxHeight;
                            double colImage = availableWidth * 0.08;
                            double colName = availableWidth * 0.10;
                            double colProducts = availableWidth * 0.09;
                            double colStatus = availableWidth * 0.09;
                            double colLocation = availableWidth * 0.12;
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
                                              width: colProducts,
                                              child: const Text("Products"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colStatus,
                                              child: const Text("Status"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colLocation,
                                              child: const Text("Location"),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: colActions,
                                              child: const Text("Actions"),
                                            ),
                                          ),
                                        ],
                                        rows: addCategoryListModel.data!
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
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: colProducts,
                                                  child: Container(
                                                    height: 20,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            item.productCount ==
                                                                    0
                                                                ? greyColor200
                                                                : greenColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Text(
                                                      "${item.productCount == 0 ? "No" : item.productCount} Products",
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
                                                        color:
                                                            item.statusText ==
                                                                    "Available"
                                                                ? greenColor
                                                                : redColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Text(
                                                      item.statusText ?? "",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: colLocation,
                                                  child: Text(
                                                    item.locationId?.name ?? "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                            catId = item.id
                                                                .toString();
                                                            debugPrint(
                                                                "isEdit_$isEdit");
                                                          });
                                                          context
                                                              .read<
                                                                  CategoryBloc>()
                                                              .add(CategoryById(
                                                                  catId
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
                                                                  CategoryBloc>()
                                                              .add(DeleteCategory(item
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

    return BlocBuilder<CategoryBloc, dynamic>(
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
            bool? statusValue = selectedStatus == "All"
                ? null
                : (selectedStatus == "Available" ? true : false);
            context.read<CategoryBloc>().add(AddCategory(searchController.text,
                locationId ?? "", statusValue, offset, rowsPerPage));
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
        if (current is PostCategoryModel) {
          postCategoryModel = current;
          if (postCategoryModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (postCategoryModel.success == true) {
            showToast("Category Added Successfully", context, color: true);
            bool? statusValue = selectedStatus == "All"
                ? null
                : (selectedStatus == "Available" ? true : false);
            context.read<CategoryBloc>().add(AddCategory(searchController.text,
                locationId ?? "", statusValue, offset, rowsPerPage));
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
        if (current is AddCategoryListModel) {
          addCategoryListModel = current;
          if (addCategoryListModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (addCategoryListModel.success == true) {
            setState(() {
              catLoad = false;
              totalItems = int.parse(
                  addCategoryListModel.totalCount.toString()); // API response
              totalPages = (totalItems / rowsPerPage).ceil();
            });
          } else {
            setState(() {
              catLoad = false;
            });
            showToast("No Category found", context, color: false);
          }
          return true;
        }
        if (current is GetSingleCategoryModel) {
          getSingleCategoryModel = current;
          if (getSingleCategoryModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getSingleCategoryModel.success == true) {
            setState(() {
              if (getSingleCategoryModel.data != null) {
                categoryController.text =
                    getSingleCategoryModel.data!.name ?? "";
                isAvailable = getSingleCategoryModel.data!.isDefault ?? false;
                apiImageUrl = getSingleCategoryModel.data!.image;
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
        if (current is PutCategoryModel) {
          putCategoryModel = current;
          if (putCategoryModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (putCategoryModel.success == true) {
            showToast("Category Updated Successfully", context, color: true);
            _refreshEditData();
            bool? statusValue = selectedStatus == "All"
                ? null
                : (selectedStatus == "Available" ? true : false);
            context.read<CategoryBloc>().add(AddCategory(searchController.text,
                locationId ?? "", statusValue, offset, rowsPerPage));
            Future.delayed(Duration(milliseconds: 100), () {
              clearCategoryForm();
            });
            setState(() {
              editLoad = false;
            });
          } else {
            setState(() {
              editLoad = false;
            });
          }
          return true;
        }
        if (current is DeleteCategoryModel) {
          deleteCategoryModel = current;
          if (deleteCategoryModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (deleteCategoryModel.success == true) {
            setState(() {
              deleteLoad = false;
              catLoad = true;
              showToast("${deleteCategoryModel.message}", context, color: true);
            });
            bool? statusValue = selectedStatus == "All"
                ? null
                : (selectedStatus == "Available" ? true : false);
            context.read<CategoryBloc>().add(AddCategory(searchController.text,
                locationId ?? "", statusValue, offset, rowsPerPage));
          } else if (deleteCategoryModel.errorResponse != null) {
            showToast("${deleteCategoryModel.errorResponse?.message}", context,
                color: false);
            setState(() {
              deleteLoad = false;
            });
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
