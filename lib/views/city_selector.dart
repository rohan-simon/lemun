import 'package:flutter/material.dart';
import 'package:lemun/helpers/scooter_checker.dart';
import 'package:lemun/models/city.dart';
import 'package:lemun/providers/scooter_provider.dart';
import 'package:provider/provider.dart';

class CitySelector extends StatelessWidget {
  CitySelector(BuildContext context, {super.key});

  // Creating map representations of each country.
  final Map<String, Cities> unitedStates = {
    'Chicago': Cities.chicago,
    'Cleveland': Cities.cleveland,
    'Colorado Springs': Cities.colorado_springs,
    'Detroit': Cities.detroit,
    'Grand Rapids': Cities.grand_rapids,
    'Louisville': Cities.louisville,
    'New York': Cities.new_york,
    'Norfolk': Cities.norfolk_va,
    'Oakland': Cities.oakland,
    'San Francisco': Cities.san_francisco,
    'San Jose': Cities.san_jose,
    'Seattle': Cities.seattle,
    'Washington D.C.': Cities.washington_dc,
  };
  final Map<String, Cities> germany = {
    'Hamburg': Cities.hamburg,
    'Oberhausen': Cities.oberhausen,
    'Reutlingen': Cities.reutlingen,
    'Solingen': Cities.solingen,
  };
  final Map<String, Cities> switzerland = {
    'Opfikon': Cities.opfikon,
    'Zug': Cities.zug,
  };
  final Map<String, Cities> france = {
    'Marseille': Cities.marseille,
    'Paris': Cities.paris,
  };
  final Map<String, Cities> canada =  {
    'Edmonton': Cities.edmonton,
    'Kelowna': Cities.kelowna,
  };
  final Map<String, Cities> israel =  {
    'Tel Aviv': Cities.tel_aviv,
  };
  final Map<String, Cities> norway =  {
    'Oslo': Cities.oslo,
  };
  final Map<String, Cities> italy =  {
    'Rome': Cities.rome,
    'Verona': Cities.verona,
  };
  final Map<String, Cities> belgium =  {
    'Antwerp': Cities.antwerp,
    'Brussels': Cities.brussels,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<ScooterProvider>(
      builder: (context, scooterProvider, unchangingChild) => ListView(
        scrollDirection: Axis.vertical,
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: const Text('Select City', style: TextStyle(fontSize: 20)),
          ),
          _buildCountry('United States', unitedStates, scooterProvider), // Building each country
          _buildCountry('Belgium', belgium, scooterProvider),
          _buildCountry('Canada', canada, scooterProvider),
          _buildCountry('France', france, scooterProvider),
          _buildCountry('Germany', germany, scooterProvider),
          _buildCountry('Israel', israel, scooterProvider),
          _buildCountry('Italy', italy, scooterProvider),
          _buildCountry('Norway', norway, scooterProvider),
          _buildCountry('Switzerland', switzerland, scooterProvider),
        ],
      ),
    );
  }

  // Builds a country's city selection from provided country name, map of cities, and provider.
  // Parameters:
  // - String country: name of the country
  // - Map<String, Cities> cities: map of cities in the country, with their Cities counterpart
  // - ScooterProvider provider: scooter provider
  Widget _buildCountry(String country, Map<String, Cities> cities, ScooterProvider provider) {
    return Column(
      children: [
        const Divider(color: Color.fromARGB(255, 213, 192, 74)),
        _buildHeader(country),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          padding: const EdgeInsets.all(10),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          crossAxisCount: 2,
          children: cities.entries.map((city) {
            return _buildCityButton(city.key, city.value, provider);
          }).toList()
        )
      ],
    );
  }

  /// Takes a country name and makes a heading out of it.
  /// paramaters:
  ///  - text: the country to build a header for
  Widget _buildHeader(String text) {
    return Semantics(
      button: false,
      label: 'country',
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),
          //const Divider()
        ]
      ),
    );
  }

  /// Makes a button to select the city the user wants the Lime api to pull from
  /// parameters:
  ///  - name: city name
  ///  - city: city to select
  ///  - provider: Scooter Provider to handle state
  Widget _buildCityButton(String name, Cities city, ScooterProvider provider) {
    bool selected = provider.city == city;

    return Center(
      child: ElevatedButton(
        onPressed: () {
          // update state
          provider.city = city;
          ScooterChecker sc = ScooterChecker(provider);
          sc.fetchLime();
        },
        style: ButtonStyle(
          backgroundColor: selected 
                ? const WidgetStatePropertyAll<Color>(Color.fromARGB(255, 255, 242, 175))
                : const WidgetStatePropertyAll<Color>(Colors.white),
          shadowColor: selected 
                ? const WidgetStatePropertyAll<Color>(Colors.white)
                : null
        ),
        child: Semantics(
          label: '${selected ? 'selected' : 'not selected'}, City: $name.',
          hint: 'Double tap to change city to $name',
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, 
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 13,), 
                      textAlign: TextAlign.center,
                    )
                  )
                )
              ]
            ),
          ),
        ),
      ),
    );
  }
}
