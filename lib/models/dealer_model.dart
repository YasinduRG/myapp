class Dealer {
  final String name;
  final String surname;
  final String accountCode;
  final String address;
  final String city;

  Dealer({
  required this.name,
  required this.surname,
  required this.accountCode,
  required this.address,
  required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
    'name': name,
    'accountCode': accountCode,
    'surname': surname,
    'address': address,
    'city': city,
    };
    }

                                                                                  
}
