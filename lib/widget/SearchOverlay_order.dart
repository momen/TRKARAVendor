import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:trkar_vendor/model/orders_model.dart';
import 'package:trkar_vendor/model/products_model.dart';
import 'package:trkar_vendor/screens/Edit_product.dart';
import 'package:trkar_vendor/screens/orderdetails.dart';
import 'package:trkar_vendor/screens/productPage.dart';
import 'package:trkar_vendor/utils/Provider/provider.dart';
import 'package:trkar_vendor/utils/local/LanguageTranslated.dart';
import 'package:trkar_vendor/utils/navigator.dart';
import 'package:trkar_vendor/utils/service/API.dart';
import 'package:trkar_vendor/widget/products/product_item.dart';
import 'package:trkar_vendor/widget/stores/Order_item.dart';

import 'ResultOverlay.dart';

class SearchOverlay_Order extends StatefulWidget {
  String url;

  SearchOverlay_Order({this.url});

  @override
  State<StatefulWidget> createState() => SearchOverlay_OrderState();
}

class SearchOverlay_OrderState extends State<SearchOverlay_Order>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;
  List<Order> products = [];

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);
    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<Provider_control>(context);

    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: themeColor.getColor(),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            //Nav.route(context, FilterPage());
                          },
                          child: Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                            color: Colors.orange,
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              height: 50,
                              color: Colors.white,
                              child: TextFormField(
                                onChanged: (string) {
                                  if (string.length >= 1) {
                                    API(context).post(widget.url, {
                                      "search_index": string,
                                    }).then((value) {
                                      if (value != null) {
                                        if (value['status_code'] == 200) {
                                          setState(() {
                                            products =
                                                Orders_model.fromJson(value).data;
                                          });
                                        } else {
                                          // showDialog(
                                          //     context: context,
                                          //     builder: (_) => ResultOverlay(
                                          //         value['message']));
                                        }
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      products = [];
                                    });
                                  }
                                },
                              )
                              //   searchTextField =
                              //       AutoCompleteTextField<Product>(
                              //     key: key,
                              //     clearOnSubmit: false,
                              //     suggestions: products,
                              //     style: TextStyle(
                              //         color: Colors.black, fontSize: 16.0),
                              //     decoration: InputDecoration(
                              //         border: InputBorder.none,
                              //         hintText:getTransrlate(context, 'search'),
                              //         hintStyle: TextStyle(
                              //           fontSize: 13,
                              //           color: Color(0xFF5D6A78),
                              //           fontWeight: FontWeight.w400,
                              //         )),
                              //     itemFilter: (item, query) {
                              //       return item
                              //           .toString()
                              //           .toLowerCase()
                              //           .startsWith(query.toLowerCase());
                              //     },
                              //     itemSorter: (a, b) {
                              //       return a.name.compareTo(b.name);
                              //     },
                              //     itemSubmitted: (item) {
                              //       setState(() {
                              // //        searchTextField.textField.controller.text = item.toString();
                              //       });
                              //     },
                              //     textChanged: (string) {
                              //       if(string.length>=1){
                              //
                              //  API(context).post(widget.url, {
                              //           "search_index": string,
                              //         }).then((value) {
                              //           if (value != null) {
                              //             if (value['status_code'] == 200) {
                              //               setState(() {
                              //                 products = Products_model.fromJson(value).product;
                              //               });
                              //             } else {
                              //               showDialog(
                              //                   context: context,
                              //                   builder: (_) => ResultOverlay(
                              //                       value['message']));
                              //             }
                              //           }
                              //         });
                              //       }else{
                              //         setState(() {
                              //           products=[];
                              //         });
                              //       }
                              //     },
                              //     itemBuilder: (context, item) {
                              //       print(item);
                              //       // ui for the autocompelete row
                              //       return row(item);
                              //     },
                              //   ),
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.clear,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                ListView.builder(
                    itemCount: products == null && products.isEmpty
                        ? 0
                        : products.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: (){
                          Nav.route(
                              context,
                              Order_information(
                                orders: products,
                                orders_model: products[index],
                              ));
                        },
                        child: Container(
                          color: index.isOdd
                              ? Color(0xffF6F6F6)
                              : Colors.white,
                          child: Column(
                            children: [
                              OrderItem(
                                orders_model: products[index],
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
                                      ' ${getTransrlate(context, 'totalOrder')} : ${products[index].orderTotal} ${getTransrlate(context, 'Currency')} ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    products[index].need_approval==0
                                        ? Container(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            getTransrlate(context,
                                                'OrderState'),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            width: 80,
                                            padding:
                                            EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1)),
                                            child: Center(
                                              child: Text(
                                                '${products[index].orderStatus}',
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                        :products[index].orderStatus=='cancelled due to expiration'?Container(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            getTransrlate(context,
                                                'OrderState'),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            width: 80,
                                            padding:
                                            EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1)),
                                            child: Center(
                                              child: Text(
                                                '${products[index].orderStatus}',
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ): Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceAround,
                                      children: [
                                        FlatButton(
                                          padding: EdgeInsets.all(4),
                                          onPressed: () {
                                            API(context).post(
                                                'vendor/approve/orders',
                                                {
                                                  "status": "1",
                                                  "order_id": products[index].id
                                                }).then((value) {
                                              if (value != null) {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      ResultOverlay(value.containsKey('message') ? value['message'] : '${getTransrlate(context,'Done')}',),
                                                );
                                                Navigator.pop(context);
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .check_circle_outline,
                                                  color: Colors
                                                      .lightGreen),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'قبول',
                                                style: TextStyle(
                                                    color: Colors
                                                        .lightGreen,
                                                    fontSize: 15,
                                                    decoration:
                                                    TextDecoration
                                                        .underline,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        FlatButton(
                                          padding: EdgeInsets.all(4),
                                          onPressed: () {
                                            API(context).post(
                                                'vendor/cancel/order',
                                                {
                                                  "order_id":
                                                  products[
                                                  index]
                                                      .id
                                                }).then((value) {
                                              if (value != null) {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      ResultOverlay(
                                                        value.containsKey(
                                                            'message')
                                                            ? value[
                                                        'message']
                                                            : '${getTransrlate(context,'Done')}',
                                                      ),
                                                );
                                              }
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                  CupertinoIcons
                                                      .clear_circled,
                                                  size: 25,
                                                  color: Colors.red),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'رفض',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15,
                                                    decoration:
                                                    TextDecoration
                                                        .underline,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> Delete_Products(int id) async {
    API(context).Delete('products/$id').then((value) {
      if (value != null) {
        print(value.containsKey('errors'));
        showDialog(
          context: context,
          builder: (_) => ResultOverlay(
            value.containsKey('errors') ? value['errors'] : '${getTransrlate(context,'Done')}',
          ),
        );
      }
    });
  }



}
