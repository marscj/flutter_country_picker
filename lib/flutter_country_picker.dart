import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'material_search.dart';

import 'country.dart';
export 'country.dart';

typedef Widget CountryBuilder(BuildContext context, Country country);

Future<Country> pickCountry(BuildContext context) {
  return Navigator.push(context, new MaterialPageRoute(
    builder: (_) {
      return new _CountryPickerPage();
    }
  ));
}

class CountryPicker extends StatefulWidget {
  CountryPicker({
    @required this.onChanged,
    @required this.country,
    this.builder,
    this.size = const Size(24.0, 24.0),
  });

  final ValueChanged<Country> onChanged;
  final CountryBuilder builder;
  final Country country;
  final Size size;

  @override
  State<CountryPicker> createState() => new _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {

  Widget get child => widget.country != null ? widget.builder != null ? widget.builder(context, widget.country) : _renderDefaultDisplay(widget.country) : new LimitedBox();

  @override
  Widget build(BuildContext context) { 
    // _country ??= Country.findByIsoCode(widget.initCode == null ? Localizations.localeOf(context).countryCode : widget.initCode);
    return new InkWell(
      child: new AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(child: child, opacity: animation);
        },
        child: child
      ),
      onTap: () => pickCountry(context).then((country){
        if (country != null) {
          widget.onChanged(country);
        }
      })
    );
  }

  _renderDefaultDisplay(Country displayCountry) {
    return Padding(
     padding: const EdgeInsetsDirectional.only(start: 4.0),
     child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Image.asset(
          displayCountry.asset,
          package: "flutter_country_picker",
          height: widget.size.height,
          width: widget.size.width,
          fit: BoxFit.fitWidth,
        ),
        new Icon(Icons.arrow_drop_down,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade700
              : Colors.white70),
      ],
    )); 
  }
}

class _CountryPickerPage extends StatefulWidget {
  const _CountryPickerPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CountryPickerPageState();
}

class _CountryPickerPageState extends State<_CountryPickerPage> {

  List<Country> _countries;

  Country country;

  @override
  void initState() {
    super.initState();

    _countries = Country.ALL;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new MaterialSearch<Country>(
        placeholder: 'Search',
        limit: _countries.length,
        results: _countries.map((Country country) => new MaterialSearchResult<Country>(
          value: country,
          builder: (_){
            return new ListTile(
              contentPadding: const EdgeInsets.all(2.0),
              leading: Image.asset(
                country.asset,
                package: "flutter_country_picker",
              ),
              title: new Text(country.name),
              trailing: new Text('+' + country.dialingCode),
            );
          },
        )).toList(),
        filter: (dynamic value, String criteria) {
          return value.toLowerCase().trim().contains(new RegExp(r'' + criteria.toLowerCase().trim() + ''));
        },
        onSelect: (dynamic value) => Navigator.of(context).pop(value),
        onSubmit: (String value) => Navigator.of(context).pop(value),
      ),
    );
  }
}
