import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:trkar_vendor/model/tickets_model.dart';
import 'package:trkar_vendor/screens/ticketsdetails.dart';
import 'package:trkar_vendor/utils/Provider/provider.dart';
import 'package:trkar_vendor/utils/SerachLoading.dart';
import 'package:trkar_vendor/utils/local/LanguageTranslated.dart';
import 'package:trkar_vendor/utils/navigator.dart';
import 'package:trkar_vendor/utils/screen_size.dart';
import 'package:trkar_vendor/utils/service/API.dart';
import 'package:trkar_vendor/widget/ResultOverlay.dart';
import 'package:trkar_vendor/widget/Sort.dart';
import 'package:trkar_vendor/widget/hidden_menu.dart';
import 'package:trkar_vendor/widget/no_found_item.dart';
import 'package:trkar_vendor/widget/stores/Ticket_item.dart';

class Tickets extends StatefulWidget {
  @override
  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  List<Ticket> stores;
  final debouncer = Search(milliseconds: 1000);
  String url="all/tickets";
  int i = 2;
  
  ScrollController _scrollController = new ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        PerStore();
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
     drawer: HiddenMenu(),
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
              'assets/icons/tickets.svg',
              color: Colors.white,
              height: 25,
              width: 25,
            ),
            SizedBox(
              width: 10,
            ),
            Text(getTransrlate(context, 'ticket')),
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
      body: stores == null
          ? Container(
              height: ScreenUtil.getHeight(context) / 3,
              child: Center(
                  child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(themeColor.getColor()),
              )))
          : stores.isEmpty
              ? Center(
                  child:NotFoundItem(title: '${getTransrlate(context, 'nofoundtickit')}',),
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
                            Text('${stores.length} ${getTransrlate(context,'ticket')}'),
                            SizedBox(
                              width: 5,
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
                                    builder: (_) => Sortdialog())
                                    .then((val) {
                                  url='all/tickets?sort_type=${val??'ASC'}';
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
                        itemCount: stores.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: (){
                              Nav.route(context, tickets_information(orders_model: stores[index],));
                            },
                            child: Ticket_item(
                              ticket_model: stores[index],
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
    API(context).get('$url').then((value) {
      if (value != null) {
        setState(() {
           stores = Tickets_model.fromJson(value).data;
        });
      }
    });
  }
  Future<void> PerStore() async {
    API(context).get("$url${url.contains('?')?'&':'?'}page=${i++}").then((value) {
      if (value != null) {
        setState(() {
          stores.addAll(Tickets_model.fromJson(value).data);
        });
      }
    });
  }
  Widget row(Ticket productModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          productModel.title.toString(),
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(
          width: 10.0,
        ),
        Text(
          productModel.categoryName.toString(),
        ),
      ],
    );
  }
}
