import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trkar_vendor/model/invoices.dart';
import 'package:trkar_vendor/model/orders_model.dart';
import 'package:trkar_vendor/screens/orderdetails.dart';
import 'package:trkar_vendor/utils/Provider/provider.dart';
import 'package:trkar_vendor/utils/SerachLoading.dart';
import 'package:trkar_vendor/utils/local/LanguageTranslated.dart';
import 'package:trkar_vendor/utils/navigator.dart';
import 'package:trkar_vendor/utils/screen_size.dart';
import 'package:trkar_vendor/utils/service/API.dart';
import 'package:trkar_vendor/widget/ResultOverlay.dart';
import 'package:trkar_vendor/widget/SearchOverlay.dart';
import 'package:trkar_vendor/widget/Sort.dart';
import 'package:trkar_vendor/widget/hidden_menu.dart';
import 'package:trkar_vendor/widget/no_found_item.dart';
import 'package:trkar_vendor/widget/stores/Invoice_item.dart';
import 'package:trkar_vendor/widget/stores/Order_item.dart';

import 'Invoicesdetails.dart';

class Invoices extends StatefulWidget {
  @override
  _InvoicesState createState() => _InvoicesState();
}

class _InvoicesState extends State<Invoices> {
  List<Invoice> invoices;
  String _character='ASC';

  final debouncer = Search(milliseconds: 1000);
  ScrollController _scrollController = new ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String url="show/invoices";
  int i = 2;
 
  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        pageFetch();
      }
    });
    getAllStore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<Provider_control>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/invoices.svg',
              color: Colors.white,
              height: 25,
              width: 25,
            ),
            SizedBox(
              width: 10,
            ),
            Text(getTransrlate(context, 'invoices')),
          ],
        ),
        actions: [
          // IconButton(
          //   icon: Icon(
          //     Icons.search,
          //     color: Colors.white,
          //   ),
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (_) => SearchOverlay(),
          //     );
          //   },
          // )
        ],
        backgroundColor: themeColor.getColor(),
      ),
      drawer: HiddenMenu(),
      body: invoices == null
          ? Container(
          height: ScreenUtil.getHeight(context) / 3,
          child: Center(
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(themeColor.getColor()),
              )))
          : invoices.isEmpty
          ? Center(
        child: NotFoundItem(title: '${getTransrlate(context, 'nofoundinvoices')}',),
      )
          : SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.black12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('${invoices.length} ${getTransrlate(context, 'invoice')}'),
                  SizedBox(
                    width: 100,
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     // showDialog(
                  //     //     context: context,
                  //     //     builder: (_) => Filterdialog());
                  //   },
                  //   child: Row(
                  //     children: [
                  //       Text('تصفية'),
                  //       Icon(
                  //         Icons.keyboard_arrow_down,
                  //         size: 20,
                  //       )
                  //     ],
                  //   ),
                  // ),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => Sortdialog()).then((val) {
                       setState(() {
                         _character=val;
                       });
                       url="show/invoices?sort_type=${val??'DESC'}";
                    getAllStore();
                      });
                    },
                    child: Row(
                      children: [
                        Text('${getTransrlate(context, 'Sort')}'),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            ListView.builder(
              itemCount: invoices.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Nav.route(
                        context,
                        Invoices_information(
                          orders: invoices,
                          orders_model: invoices[index],
                        ));
                  },
                  child: Container(
                    color: index.isOdd
                        ? Color(0xffF6F6F6)
                        : Colors.white,
                    child: Column(
                      children: [
                        InvoiceItem(
                          orders_model: invoices[index],
                          themeColor: themeColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 40, left: 16),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ' ${getTransrlate(context, 'totalOrder')} : ${invoices[index].invoiceTotal} ${getTransrlate(context, 'Currency')} ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AutoSizeText(
                                  invoices[index].createdAt==null?'': DateFormat('yyyy-MM-dd').format(DateTime.parse(invoices[index].createdAt)),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                minFontSize: 11,
                              ),

                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 1,
                          color: Colors.black12,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAllStore() async {
    i=2;
    API(context)
        .get(url)
        .then((value) {
      if (value != null) {
        setState(() {
          invoices = Invoices_model.fromJson(value).data;
        });
      }
    });
  }

  Color isPassed(String value) {
    switch (value) {
      case 'inprogress':
        return Colors.amber;
        break;
      case 'pending':
        return Colors.green;
        break;
      case 'cancelled due to expiration':
        return Colors.deepPurpleAccent;
        break;
      case '5':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.red;
        break;
      default:
        return Colors.blue;
    }
  }

  void pageFetch() {
    API(context)
        .get('${url}${url.contains("?")?'&':'?'}page=${i++}')
        .then((value) {
      setState(() {
        invoices.addAll(Invoices_model.fromJson(value).data);
      });
    });
  }

  Widget row(Order productModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          productModel.orderNumber.toString(),
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(
          width: 10.0,
        ),
        Text(
          productModel.orderTotal.toString(),
        ),
      ],
    );
  }
}
