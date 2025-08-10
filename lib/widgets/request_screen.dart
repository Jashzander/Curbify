import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curbify/widgets/timers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/request_view_model.dart';
import '../theme_provider.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestViewModel>(
      builder: (context, viewModel, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final darkMode = themeProvider.themeData.brightness == Brightness.dark;

        return Column(
          children: [
            const SizedBox(height: 20),
            _buildSectionHeader('Pending Requests', darkMode),
            _buildRequestList(viewModel, darkMode, true),
            const SizedBox(height: 20),
            _buildSectionHeader('Accepted Requests', darkMode),
            _buildRequestList(viewModel, darkMode, false),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool darkMode) {
    return Container(
      color: darkMode
          ? const Color.fromARGB(255, 52, 54, 66)
          : const Color.fromARGB(255, 236, 242, 242),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 80),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRequestList(
      RequestViewModel viewModel, bool darkMode, bool isPending) {
    return Expanded(
      flex: 1,
      child: StreamBuilder<QuerySnapshot>(
        stream: viewModel.messagesStream,
        builder: (context, messageSnapshot) {
          if (messageSnapshot.hasData) {
            viewModel.updateCars(messageSnapshot.data!.docs);
          }
          return StreamBuilder(
            stream: viewModel.getGuestListStream(''),
            builder: (context, guestSnapshot) {
              if (guestSnapshot.hasError) {
                return Text('Error: ${guestSnapshot.error}');
              }
              if (!guestSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final guestsData =
                  guestSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              final List<MapEntry<dynamic, dynamic>> listOfGuests = [];

              for (var guestEntry in viewModel.filteredGuestsList) {
                for (var entry in guestsData.entries) {
                  if (entry.value['Status'] != 'Out' &&
                      guestEntry['Ticket ID'] == entry.value['Ticket ID']) {
                    listOfGuests.add(entry);
                  }
                }
              }

              return ListView.builder(
                itemCount: listOfGuests.length,
                itemBuilder: (context, index) {
                  final dynamic key = listOfGuests[index].key;
                  final Map<dynamic, dynamic> guest = listOfGuests[index].value;
                  final bool validTicket = guest['Valid Ticket'];
                  final bool acceptedRequest = guest['Accepted Request'];
                  final bool pendingRequest = guest['Pending Request'];
                  final String phone = guest['Phone'].toString();

                  for (int i = 0; i < viewModel.cars.length; i++) {
                    if (phone == viewModel.cars[i] &&
                        validTicket &&
                        !acceptedRequest) {
                      viewModel.updatePendingRequest(
                          '', viewModel.sanitizeKey(key));
                      viewModel.cars[i] = '';
                      break;
                    }
                  }

                  if (isPending && pendingRequest && !acceptedRequest) {
                    return _buildPendingRequestCard(
                        context, viewModel, guest, key, phone, darkMode);
                  } else if (!isPending && acceptedRequest && !pendingRequest) {
                    return _buildAcceptedRequestCard(context, guest, darkMode);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPendingRequestCard(
      BuildContext context,
      RequestViewModel viewModel,
      Map<dynamic, dynamic> guest,
      dynamic key,
      String phone,
      bool darkMode) {
    viewModel.stopwatch.start();
    return Card(
      color: darkMode
          ? (viewModel.stopwatch.elapsed.inMinutes < 5
              ? Colors.green.shade900
              : (viewModel.stopwatch.elapsed.inMinutes < 10
                  ? Colors.orange.shade900
                  : Colors.red.shade900))
          : (viewModel.stopwatch.elapsed.inMinutes < 5
              ? Colors.green
              : (viewModel.stopwatch.elapsed.inMinutes < 10
                  ? Colors.orange
                  : Colors.red)),
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                    '${guest['Parking']} ${guest['Brand']} ${guest['Model']} ${guest['Color']} ${guest['License']}',
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
                  viewModel.acceptRequest(
                      '', viewModel.sanitizeKey(key), phone);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Accept"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedRequestCard(
      BuildContext context, Map<dynamic, dynamic> guest, bool darkMode) {
    return Card(
      color: darkMode
          ? const Color.fromARGB(44, 193, 196, 244)
          : const Color.fromARGB(255, 232, 232, 232),
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                    '${guest['Phone']} ${guest['Parking']} ${guest['Brand']} ${guest['Model']} ${guest['Color']} ${guest['License']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Timers(
                initialElapsedString: guest['Wait Time'].toString(),
              ),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  // handle done button
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
