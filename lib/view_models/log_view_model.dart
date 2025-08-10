import 'package:flutter/material.dart';
import '../services/realtimedb_service.dart';

class LogViewModel extends ChangeNotifier {
  final RealtimeDBService _realtimeDBService = RealtimeDBService();
  final TextEditingController searchController = TextEditingController();

  List<Map<dynamic, dynamic>> _guestsList = [];
  List<Map<dynamic, dynamic>> _filteredGuestsList = [];
  String _selectedSortOption = 'Name';

  List<Map<dynamic, dynamic>> get filteredGuestsList => _filteredGuestsList;

  LogViewModel(String company) {
    fetchGuestList(company);
  }

  Future<void> fetchGuestList(String company) async {
    final snapshot = await _realtimeDBService.getGuestList(company);
    if (snapshot.value != null) {
      final guestsMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      _guestsList = guestsMap.values.toList().cast<Map<dynamic, dynamic>>();
      _filteredGuestsList = _guestsList.toList();
      sortGuests(_selectedSortOption);
      notifyListeners();
    }
  }

  void filterGuests(String query) {
    _filteredGuestsList = _guestsList
        .where((guest) =>
            guest['Name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            guest['Ticket ID']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void sortGuests(String sortOption) {
    _selectedSortOption = sortOption;
    switch (_selectedSortOption) {
      case 'Name':
        _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
        break;
      case 'TicketID':
        _filteredGuestsList
            .sort((a, b) => a['Ticket ID'].compareTo(b['Ticket ID']));
        break;
      case 'Hourly':
        _filteredGuestsList = _guestsList
            .where((guest) => guest['rateType'] == 'Hourly')
            .toList();
        break;
      case 'Overnight':
        _filteredGuestsList = _guestsList
            .where((guest) => guest['rateType'] == 'Overnight')
            .toList();
        break;
      case 'Time':
        _filteredGuestsList.sort((a, b) => a['time'].compareTo(b['time']));
        break;
      default:
        _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
    }
    notifyListeners();
  }

  void removeGuest(String company, String key) {
    _realtimeDBService.updateGuest(company, key, {'Status': 'Out'});
    fetchGuestList(company);
  }
}
