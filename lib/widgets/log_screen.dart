import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/log_view_model.dart';
import '../theme_provider.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LogViewModel>(
      builder: (context, viewModel, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final darkMode = themeProvider.themeData.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: darkMode
              ? const Color.fromARGB(255, 52, 54, 66)
              : const Color.fromARGB(255, 236, 242, 242),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(darkMode),
                const SizedBox(height: 10),
                _buildSearchBar(viewModel),
                const SizedBox(height: 20),
                _buildLogList(viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool darkMode) {
    return Container(
      color: darkMode
          ? const Color.fromARGB(255, 52, 54, 66)
          : const Color.fromARGB(255, 236, 242, 242),
      padding: const EdgeInsets.fromLTRB(170, 5, 170, 5),
      child: const Text(
        'Log',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchBar(LogViewModel viewModel) {
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: TextField(
                controller: viewModel.searchController,
                textAlignVertical: TextAlignVertical.bottom,
                decoration: InputDecoration(
                  hintText: 'Search by Name or Ticket ID',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: viewModel.filterGuests,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: PopupMenuButton(
              onSelected: viewModel.sortGuests,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Name',
                  child: Text('Sort by Name'),
                ),
                const PopupMenuItem<String>(
                  value: 'TicketID',
                  child: Text('Sort by Ticket ID'),
                ),
                const PopupMenuItem<String>(
                  value: 'Time',
                  child: Text('Sort by Time Created'),
                ),
                const PopupMenuItem<String>(
                  value: 'Hourly',
                  child: Text('Filter by Hourly'),
                ),
                const PopupMenuItem<String>(
                  value: 'Overnight',
                  child: Text('Filter by Overnight'),
                ),
              ],
              icon: const Icon(Icons.sort),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(LogViewModel viewModel) {
    final guests = viewModel.filteredGuestsList;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: guests.length,
      itemBuilder: (context, index) {
        final guest = guests[index];
        final bool isRoomBlank = guest['Room'] == 'BLANK';
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final bool darkMode =
            themeProvider.themeData.brightness == Brightness.dark;
        final Color cardColor = isRoomBlank
            ? (darkMode
                ? const Color.fromARGB(116, 239, 234, 85)
                : const Color.fromARGB(206, 239, 234, 85))
            : (darkMode
                ? const Color.fromARGB(44, 193, 196, 244)
                : const Color.fromARGB(255, 232, 232, 232));

        return Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${guest['Name']}',
                        style: const TextStyle(fontSize: 24),
                      ),
                      Text(
                        '${guest['Ticket ID']} ${guest['Room']} ${guest['License']} ${guest['Parking']} ${guest['Brand']} ${guest['Model']} ${guest['Color']} ${guest['Phone']} ${guest['Rate Type']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      // Remove guest
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 223, 69, 97),
                      minimumSize: const Size(100, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    child: const Text(
                      "Remove",
                      style: TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      // Edit guest
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 18, 185, 172),
                      minimumSize: const Size(100, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
