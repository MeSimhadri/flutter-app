import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart';
import '../../../widgets/common/webview.dart';

class AddListingScreen extends StatefulWidget {
  @override
  _AddListingScreenState createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  bool isLoaded = false;
  bool isDone = false;
  String addListingUrl = '';
  late var authUrl;
  @override
  void initState() {
    super.initState();
    var user = Provider.of<UserModel>(context, listen: false).user!.id;
    addListingUrl =
        serverConfig['addListingUrl'] ?? '${serverConfig['url']}/add-listing';

    authUrl =
        '${serverConfig['url']}/wp-json/wp/v2/add-listing?id=$user&url=$addListingUrl';
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      appBar: AppBar(
        title: Text(S.of(context).addListing,
            style: const TextStyle(
              color: Colors.white,
            )),
      ),
      url: authUrl,
    );
  }
}
