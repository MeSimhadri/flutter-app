import 'package:collection/collection.dart' show IterableExtension;
import 'package:country_pickers/country.dart' as picker_country;
import 'package:country_pickers/country_pickers.dart' as picker;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show Address, CartModel, Country, UserModel;
import '../../../services/index.dart';
import '../../../widgets/common/place_picker.dart';
import '../choose_address_screen.dart';

class ShippingAddress extends StatefulWidget {
  final Function? onNext;

  const ShippingAddress({this.onNext});

  @override
  _ShippingAddressState createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();

  final _lastNameNode = FocusNode();
  final _phoneNode = FocusNode();
  final _emailNode = FocusNode();
  final _cityNode = FocusNode();
  final _streetNode = FocusNode();
  final _blockNode = FocusNode();
  final _zipNode = FocusNode();
  final _stateNode = FocusNode();
  final _countryNode = FocusNode();
  final _apartmentNode = FocusNode();

  Address? address;
  List<Country>? countries = [];
  List<dynamic> states = [];

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    _blockController.dispose();
    _zipController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _apartmentController.dispose();

    _lastNameNode.dispose();
    _phoneNode.dispose();
    _emailNode.dispose();
    _cityNode.dispose();
    _streetNode.dispose();
    _blockNode.dispose();
    _zipNode.dispose();
    _stateNode.dispose();
    _countryNode.dispose();
    _apartmentNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        final addressValue =
            await Provider.of<CartModel>(context, listen: false).getAddress();
        // ignore: unnecessary_null_comparison
        if (addressValue != null) {
          setState(() {
            address = addressValue;
            _cityController.text = address?.city ?? '';
            _streetController.text = address?.street ?? '';
            _zipController.text = address?.zipCode ?? '';
            _stateController.text = address?.state ?? '';
            _blockController.text = address?.block ?? '';
            _apartmentController.text = address?.apartment ?? '';
          });
        } else {
          var user = Provider.of<UserModel>(context, listen: false).user;
          setState(() {
            address = Address(country: kPaymentConfig['DefaultCountryISOCode']);
            if (kPaymentConfig['DefaultStateISOCode'] != null) {
              address!.state = kPaymentConfig['DefaultStateISOCode'];
            }
            _countryController.text = address!.country!;
            _stateController.text = address!.state!;
            if (user != null) {
              address!.firstName = user.firstName;
              address!.lastName = user.lastName;
              address!.email = user.email;
            }
          });
        }
        countries = await Services().widget.loadCountries(context);
        var country = countries!.firstWhereOrNull((element) =>
            element.id == address!.country || element.code == address!.country);
        if (country == null) {
          if (countries!.isNotEmpty) {
            country = countries![0];
            address!.country = countries![0].code;
          } else {
            country = Country.fromConfig(address!.country, null, null, []);
          }
        } else {
          address!.country = country.code;
          address!.countryId = country.id;
        }
        _countryController.text = country.code!;
        if (mounted) {
          setState(() {});
        }
        states = await Services().widget.loadStates(country);
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> updateState(Address? address) async {
    setState(() {
      _cityController.text = address?.city ?? '';
      _streetController.text = address?.street ?? '';
      _zipController.text = address?.zipCode ?? '';
      _stateController.text = address?.state ?? '';
      _countryController.text = address?.country ?? '';
      this.address?.country = address?.country ?? '';
      _apartmentController.text = address?.apartment ?? '';
      _blockController.text = address?.block ?? '';
    });
  }

  bool checkToSave() {
    final storage = LocalStorage('address');
    var _list = <Address>[];
    try {
      var data = storage.getItem('data');
      if (data != null) {
        for (var item in (data as List)) {
          final add = Address.fromLocalJson(item);
          _list.add(add);
        }
      }
      for (var local in _list) {
        if (local.city != _cityController.text) continue;
        if (local.street != _streetController.text) continue;
        if (local.zipCode != _zipController.text) continue;
        if (local.state != _stateController.text) continue;
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).yourAddressExistYourLocal),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    S.of(context).ok,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              ],
            );
          },
        );
        return false;
      }
    } catch (err) {
      printLog(err);
    }
    return true;
  }

  Future<void> saveDataToLocal() async {
    final storage = LocalStorage('address');
    var _list = <Address?>[];
    _list.add(address);
    try {
      final ready = await storage.ready;
      if (ready) {
        var data = storage.getItem('data');
        if (data != null) {
          var _data = data as List;
          for (var item in _data) {
            final add = Address.fromLocalJson(item);
            _list.add(add);
          }
        }
        await storage.setItem(
            'data',
            _list.map((item) {
              return item!.toJsonEncodable();
            }).toList());
        await showDialog(
            context: context,
            useRootNavigator: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(S.of(context).youHaveBeenSaveAddressYourLocal),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      S.of(context).ok,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              );
            });
      }
    } catch (err) {
      printLog(err);
    }
  }

  String? validateEmail(String value) {
    var valid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (valid) {
      return null;
    }
    return 'The E-mail Address must be a valid email address.';
  }

  @override
  Widget build(BuildContext context) {
    var countryName = S.of(context).country;
    if (_countryController.text.isNotEmpty) {
      try {
        countryName = picker.CountryPickerUtils.getCountryByIsoCode(
                _countryController.text)
            .name;
      } catch (e) {
        countryName = S.of(context).country;
      }
    }

    if (address == null) {
      return SizedBox(height: 100, child: kLoadingWidget(context));
    }
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          TextFormField(
            initialValue: address!.firstName,
            autofillHints: const [AutofillHints.givenName],
            decoration: InputDecoration(labelText: S.of(context).firstName),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (val) {
              return val!.isEmpty ? S.of(context).firstNameIsRequired : null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_lastNameNode),
            onSaved: (String? value) {
              address!.firstName = value;
            },
          ),
          TextFormField(
              initialValue: address!.lastName,
              autofillHints: const [AutofillHints.familyName],
              focusNode: _lastNameNode,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (val) {
                return val!.isEmpty ? S.of(context).lastNameIsRequired : null;
              },
              decoration: InputDecoration(labelText: S.of(context).lastName),
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneNode),
              onSaved: (String? value) {
                address!.lastName = value;
              }),
          TextFormField(
              initialValue: address!.phoneNumber,
              autofillHints: const [AutofillHints.telephoneNumber],
              focusNode: _phoneNode,
              decoration: InputDecoration(labelText: S.of(context).phoneNumber),
              textInputAction: TextInputAction.next,
              validator: (val) {
                return val!.isEmpty ? S.of(context).phoneIsRequired : null;
              },
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_emailNode),
              onSaved: (String? value) {
                address!.phoneNumber = value;
              }),
          TextFormField(
              initialValue: address!.email,
              autofillHints: const [AutofillHints.email],
              focusNode: _emailNode,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: S.of(context).email),
              textInputAction: TextInputAction.done,
              validator: (val) {
                if (val!.isEmpty) {
                  return S.of(context).emailIsRequired;
                }
                return validateEmail(val);
              },
              onSaved: (String? value) {
                address!.email = value;
              }),
          const SizedBox(height: 10.0),
          if (kPaymentConfig['allowSearchingAddress'])
            if (kGoogleAPIKey.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: ButtonTheme(
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          onPrimary: Theme.of(context).colorScheme.secondary,
                          primary: Theme.of(context).primaryColorLight,
                        ),
                        onPressed: () async {
                          var result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlacePicker(
                                kIsWeb
                                    ? kGoogleAPIKey['web']
                                    : isIos
                                        ? kGoogleAPIKey['ios']
                                        : kGoogleAPIKey['android'],
                              ),
                            ),
                          );

                          if (result != null) {
                            address!.country = result.country;
                            address!.street = result.street;
                            address!.state = result.addressState;
                            address!.city = result.city;
                            address!.zipCode = result.zip;
                            address!.mapUrl =
                                'https://maps.google.com/maps?q=${result.latLng.latitude},${result.latLng.longitude}&output=embed';

                            setState(() {
                              _cityController.text = result.city;
                              _stateController.text = result.addressState;
                              _streetController.text = result.street;
                              _zipController.text = result.zip;
                              _countryController.text = result.country;
                            });
                            final c = Country(
                                id: result.country, name: result.country);
                            states = await Services().widget.loadStates(c);
                            setState(() {});
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              CupertinoIcons.arrow_up_right_diamond,
                              size: 18,
                            ),
                            const SizedBox(width: 10.0),
                            Text(S.of(context).searchingAddress.toUpperCase()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 10),
          ButtonTheme(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                onPrimary: Theme.of(context).colorScheme.secondary,
                primary: Theme.of(context).primaryColorLight,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChooseAddressScreen(updateState),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    CupertinoIcons.person_crop_square,
                    size: 16,
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    S.of(context).selectAddress.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).country,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey),
          ),
          (countries!.length == 1)
              ? Text(
                  picker.CountryPickerUtils.getCountryByIsoCode(
                          countries![0].code!)
                      .name,
                  style: const TextStyle(fontSize: 18),
                )
              : GestureDetector(
                  onTap: _openCountryPickerDialog,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(countryName,
                                style: const TextStyle(fontSize: 17.0)),
                          ),
                          const Icon(Icons.arrow_drop_down)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: kGrey900,
                    )
                  ]),
                ),
          renderStateInput(),
          TextFormField(
            controller: _cityController,
            autofillHints: const [AutofillHints.addressCity],
            focusNode: _cityNode,
            validator: (val) {
              return val!.isEmpty ? S.of(context).cityIsRequired : null;
            },
            decoration: InputDecoration(labelText: S.of(context).city),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_apartmentNode),
            onSaved: (String? value) {
              address!.city = value;
            },
          ),
          TextFormField(
              controller: _apartmentController,
              focusNode: _apartmentNode,
              validator: (val) {
                return null;
              },
              decoration:
                  InputDecoration(labelText: S.of(context).streetNameApartment),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_blockNode),
              onSaved: (String? value) {
                address!.apartment = value;
              }),
          TextFormField(
              controller: _blockController,
              focusNode: _blockNode,
              validator: (val) {
                return null;
              },
              decoration:
                  InputDecoration(labelText: S.of(context).streetNameBlock),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_streetNode),
              onSaved: (String? value) {
                address!.block = value;
              }),
          TextFormField(
              controller: _streetController,
              autofillHints: const [AutofillHints.fullStreetAddress],
              focusNode: _streetNode,
              validator: (val) {
                return val!.isEmpty ? S.of(context).streetIsRequired : null;
              },
              decoration: InputDecoration(labelText: S.of(context).streetName),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_zipNode),
              onSaved: (String? value) {
                address!.street = value;
              }),
          TextFormField(
              controller: _zipController,
              autofillHints: const [AutofillHints.postalCode],
              focusNode: _zipNode,
              validator: (val) {
                return val!.isEmpty ? S.of(context).zipCodeIsRequired : null;
              },
              keyboardType:
                  (kPaymentConfig['EnableAlphanumericZipCode'] ?? false)
                      ? TextInputType.text
                      : TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: S.of(context).zipCode),
              onSaved: (String? value) {
                address!.zipCode = value;
              }),
          const SizedBox(height: 20),
          Row(children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                primary: Theme.of(context).primaryColorLight,
              ),
              onPressed: () {
                if (!checkToSave()) return;
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Provider.of<CartModel>(context, listen: false)
                      .setAddress(address);
                  saveDataToLocal();
                }
              },
              child: Text(
                S.of(context).saveAddress.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Container(width: 20),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  onPrimary: Colors.white,
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: _onNext,
                child: Text(
                    (kPaymentConfig['EnableShipping']
                            ? S.of(context).continueToShipping
                            : (kPaymentConfig['EnableReview'] ?? true)
                                ? S.of(context).continueToReview
                                : S.of(context).continueToPayment)
                        .toUpperCase(),
                    style: const TextStyle(fontSize: 12)),
              ),
            )
          ]),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }

  /// Load Shipping beforehand
  void _loadShipping({bool beforehand = true}) {
    Services().widget.loadShippingMethods(
        context, Provider.of<CartModel>(context, listen: false), beforehand);
  }

  /// on tap to Next Button
  void _onNext() {
    {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        Provider.of<CartModel>(context, listen: false).setAddress(address);
        _loadShipping(beforehand: false);
        widget.onNext!();
      }
    }
  }

  Widget renderStateInput() {
    if (states.isNotEmpty) {
      var items = <DropdownMenuItem>[];
      for (var item in states) {
        items.add(
          DropdownMenuItem(
            value: item.id,
            child: Text(item.name),
          ),
        );
      }
      String? value;

      Object? firstState = states.firstWhereOrNull(
          (o) => o.id.toString() == address!.state.toString());

      if (firstState != null) {
        value = address!.state;
      }

      return DropdownButton(
        items: items,
        value: value,
        onChanged: (dynamic val) {
          setState(() {
            address!.state = val;
          });
        },
        isExpanded: true,
        itemHeight: 70,
        hint: Text(S.of(context).stateProvince),
      );
    } else {
      return TextFormField(
        controller: _stateController,
        autofillHints: const [AutofillHints.addressState],
        validator: (val) {
          return val!.isEmpty ? S.of(context).streetIsRequired : null;
        },
        decoration: InputDecoration(labelText: S.of(context).stateProvince),
        onSaved: (String? value) {
          address!.state = value;
        },
      );
    }
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        useRootNavigator: false,
        builder: (contextBuilder) => countries!.isEmpty
            ? Theme(
                data: Theme.of(context).copyWith(primaryColor: Colors.pink),
                child: SizedBox(
                  height: 500,
                  child: picker.CountryPickerDialog(
                      titlePadding: const EdgeInsets.all(8.0),
                      contentPadding: const EdgeInsets.all(2.0),
                      searchCursorColor: Colors.pinkAccent,
                      searchInputDecoration:
                          const InputDecoration(hintText: 'Search...'),
                      isSearchable: true,
                      title: Text(S.of(context).country),
                      onValuePicked: (picker_country.Country country) async {
                        _countryController.text = country.isoCode;
                        address!.country = country.isoCode;
                        if (mounted) {
                          setState(() {});
                        }
                        final c =
                            Country(id: country.isoCode, name: country.name);
                        states = await Services().widget.loadStates(c);
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      itemBuilder: (country) {
                        return Row(
                          children: <Widget>[
                            picker.CountryPickerUtils.getDefaultFlagImage(
                                country),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Expanded(child: Text(country.name)),
                          ],
                        );
                      }),
                ),
              )
            : Dialog(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      countries!.length,
                      (index) {
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              _countryController.text = countries![index].code!;
                              address!.country = countries![index].id;
                              address!.countryId = countries![index].id;
                            });
                            Navigator.pop(contextBuilder);
                            states = await Services()
                                .widget
                                .loadStates(countries![index]);
                            setState(() {});
                          },
                          child: ListTile(
                            leading: countries![index].icon != null
                                ? SizedBox(
                                    height: 40,
                                    width: 60,
                                    child: Image.network(
                                      countries![index].icon!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (countries![index].code != null
                                    ? Image.asset(
                                        picker.CountryPickerUtils
                                            .getFlagImageAssetPath(
                                                countries![index].code!),
                                        height: 40,
                                        width: 60,
                                        fit: BoxFit.fill,
                                        package: 'country_pickers',
                                      )
                                    : const SizedBox(
                                        height: 40,
                                        width: 60,
                                        child: Icon(Icons.streetview),
                                      )),
                            title: Text(countries![index].name!),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
      );
}
