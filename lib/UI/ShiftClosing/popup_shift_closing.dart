import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple/ModelClass/ShiftClosing/getShiftClosingModel.dart';
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/space.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/ShiftClosing/shift_closing_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class ThermalShiftClosingDialog extends StatefulWidget {
  final GetShiftClosingModel getShiftClosingModel;
  final GetStockMaintanencesModel getStockMaintanencesModel;
  final String upi;
  final String card;
  final String hd;
  final String cash;
  final String cashDifference;
  const ThermalShiftClosingDialog(
    this.getShiftClosingModel,
    this.getStockMaintanencesModel, {
    super.key,
    required this.upi,
    required this.card,
    required this.hd,
    required this.cash,
    required this.cashDifference,
  });

  @override
  State<ThermalShiftClosingDialog> createState() =>
      _ThermalShiftClosingDialogState();
}

class _ThermalShiftClosingDialogState extends State<ThermalShiftClosingDialog> {
  final GlobalKey shiftKey = GlobalKey();
  final TextEditingController ipLanController = TextEditingController();
  late SunmiPrinter sunmiPrinter;
  bool _isSunmiDevice = false;
  @override
  void initState() {
    // ipLanController.text = "192.168.1.123";
    super.initState();
    if (kIsWeb) {
      // Mock service for web
    } else if (Platform.isAndroid) {
      _checkIfSunmiDevice();
    }
  }

  Future<void> _checkIfSunmiDevice() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Check if manufacturer is SUNMI
      final isSunmi = androidInfo.manufacturer.toUpperCase().contains('SUNMI');

      setState(() => _isSunmiDevice = isSunmi);

      if (isSunmi) {
        debugPrint('✅ Running on Sunmi device: ${androidInfo.model}');
      } else {
        debugPrint(
          'ℹ️ Not a Sunmi device: ${androidInfo.manufacturer} ${androidInfo.model}',
        );
      }
    } catch (e) {
      setState(() => _isSunmiDevice = false);
      debugPrint('❌ Error checking device: $e');
    }
  }

  /// Sunmi printer
  Future<void> _printBillToSunmi(BuildContext context) async {
    if (!_isSunmiDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This device is not a Sunmi printer device"),
          backgroundColor: redColor,
        ),
      );
      return;
    }
    try {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: appPrimaryColor),
              SizedBox(height: 16),
              Text(
                "Printing to Sunmi device...",
                style: TextStyle(color: whiteColor),
              ),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await WidgetsBinding.instance.endOfFrame;

      Uint8List? imageBytes = await captureMonochromeShiftReport(shiftKey);

      if (imageBytes == null) {
        throw Exception("Image capture failed: normalReceiptKey returned null");
      }

      await SunmiPrinter.printImage(imageBytes);
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.cutPaper();

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bill printed successfully on Sunmi device!"),
          backgroundColor: greenColor,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sunmi print failed: $e"),
          backgroundColor: redColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    String businessName = widget.getStockMaintanencesModel.data?.name ?? '';
    String address =
        widget.getStockMaintanencesModel.data?.location?.address ?? '';
    String city = widget.getStockMaintanencesModel.data?.location?.city ?? '';
    String state = widget.getStockMaintanencesModel.data?.location?.state ?? '';
    String pinCode =
        widget.getStockMaintanencesModel.data?.location?.zipCode ?? '';
    final rawDate = widget.getShiftClosingModel.data?.filtersUsed?.date ?? "";
    final parsedDate = DateTime.tryParse(rawDate);

    String fromDate =
        parsedDate != null ? DateFormat('dd/MM/yyyy').format(parsedDate) : "";
    String phone = widget.getStockMaintanencesModel.data?.contactNumber ?? '';
    ipLanController.text =
        widget.getShiftClosingModel.data?.summary?.ipAddress.toString() ?? "";
    debugPrint("ipLan:${ipLanController.text}");
    String expUPI = widget.getShiftClosingModel.data!.summary!.paymentMethods!
            .expectedUpiAmount
            ?.toString() ??
        '';
    String expCard = widget.getShiftClosingModel.data!.summary!.paymentMethods!
            .expectedCardAmount
            ?.toString() ??
        '';
    String expHD = widget.getShiftClosingModel.data!.summary!.expectedHdAmount
            ?.toString() ??
        '';
    String expCash = widget.getShiftClosingModel.data!.summary!.paymentMethods!
            .expectedCashAmount
            ?.toString() ??
        '';
    String upi = widget.upi;
    String card = widget.card ?? '';
    String hd = widget.hd ?? '';
    String totalCash = widget
            .getShiftClosingModel.data!.summary!.paymentMethods!.totalcashAmount
            .toString() ??
        '';
    String cashInHand = widget.cash ?? '';
    String totalSales = widget
            .getShiftClosingModel.data!.summary!.totalSalesAmount
            .toString() ??
        '';
    String totalExpense = widget
            .getShiftClosingModel.data!.summary!.totalExpensesAmount
            .toString() ??
        '';
    String nonCashExpense = widget
            .getShiftClosingModel.data!.summary!.overallexpensesamt
            .toString() ??
        '';
    String cashDifference = widget.cashDifference ?? '';

    return widget.getShiftClosingModel.data == null ||
            widget.getStockMaintanencesModel.data == null
        ? Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1,
            ),
            alignment: Alignment.center,
            child: Text(
              "No Shift Closing found",
              style: MyTextStyle.f16(greyColor, weight: FontWeight.w500),
            ),
          )
        : Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: SingleChildScrollView(
                    child: Container(
                      width: size.width * 0.4,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                child: const Text(
                                  "Shift Closing",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Thermal Receipt Widget
                          RepaintBoundary(
                            key: shiftKey,
                            child: Center(
                              child: getShiftClosingReceiptWidget(
                                businessName: businessName,
                                tamilTagline: "",
                                address: address,
                                city: city,
                                state: state,
                                pinCode: pinCode,
                                phone: phone,
                                fromDate: fromDate,
                                expUPI: expUPI,
                                expCard: expCard,
                                expHD: expHD,
                                expCash: expCash,
                                card: card,
                                cashDifference: cashDifference,
                                upi: upi,
                                hd: hd,
                                totalCash: totalCash,
                                cashInHand: cashInHand,
                                totalSales: totalSales,
                                totalExpenses: totalExpense,
                                nonCashExpense: nonCashExpense,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Close Button
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          WidgetsBinding.instance.addPostFrameCallback((
                            _,
                          ) async {
                            await _printBillToSunmi(context);
                          });
                        },
                        icon: const Icon(Icons.print),
                        label: const Text("Print(Sunmi)"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          foregroundColor: whiteColor,
                        ),
                      ),
                      horizontalSpace(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label: const Text("CLOSE"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appPrimaryColor,
                          foregroundColor: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
