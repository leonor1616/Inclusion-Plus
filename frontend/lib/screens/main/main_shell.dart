import 'package:flutter/material.dart';

import '../../state/map_navigation_request.dart';
import '../../widgets/navbars/nav_items.dart';
import '../../widgets/navbars/navbar.dart';

import '../home/home.dart';
import '../map/map_screen.dart';
import '../community/community_screen.dart';
import '../ai/ask_ai_screen.dart';
import '../more/more_screen.dart';
import '../reports/report_issue_screen.dart';
import '../request_help/request_help_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;
  int _mapRequestCounter = 0;
  MapNavigationRequest? _mapRequest;

  void _selectTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  int _nextMapRequestId() {
    _mapRequestCounter += 1;
    return _mapRequestCounter;
  }

  void _openMap(MapNavigationRequest request) {
    setState(() {
      _mapRequest = request;
      selectedIndex = 1;
    });
  }

  void _openMapOverview() {
    _openMap(MapNavigationRequest.overview(_nextMapRequestId()));
  }

  void _openMapSearch({String? query}) {
    _openMap(
      MapNavigationRequest.search(_nextMapRequestId(), query: query),
    );
  }

  void _openUniversityOnMap() {
    _openMap(
      MapNavigationRequest.showPlace(
        _nextMapRequestId(),
        AppMapPlaces.university(),
      ),
    );
  }

  void _openDirectionsToUniversity() {
    _openMap(
      MapNavigationRequest.directionsToPlace(
        _nextMapRequestId(),
        AppMapPlaces.university(),
      ),
    );
  }

  void _openDirectionsToRoom() {
    _openMap(
      MapNavigationRequest.directionsToPlace(
        _nextMapRequestId(),
        AppMapPlaces.room1E08(),
      ),
    );
  }

  void _openElevatorOnMap() {
    _openMap(
      MapNavigationRequest.directionsToPlace(
        _nextMapRequestId(),
        AppMapPlaces.elevator1(),
      ),
    );
  }

  void _openEmergencyServicesOnMap() {
    _openMap(
      MapNavigationRequest.search(
        _nextMapRequestId(),
        query: 'emergency services near Iscte-IUL',
      ),
    );
  }

  void _openQuietLibraryRoute() {
    _openMap(
      MapNavigationRequest.directionsToPlace(
        _nextMapRequestId(),
        AppMapPlaces.library(),
      ),
    );
  }

  void _openReportIssue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
    );
  }

  void _openRequestHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestHelpScreen(
          onNavigateTab: (index) {
            Navigator.pop(context);
            _selectTab(index);
          },
          onOpenEmergencyMap: () {
            Navigator.pop(context);
            _openEmergencyServicesOnMap();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onPlanRoute: () => _openMapSearch(),
        onReportIssue: _openReportIssue,
        onRequestHelp: _openRequestHelp,
        onIndoorMap: _openUniversityOnMap,
        onElevatorMap: _openElevatorOnMap,
        onRoomGo: _openDirectionsToRoom,
        onSeeUniversity: _openDirectionsToUniversity,
      ),
      MapScreen(navigationRequest: _mapRequest),
      const CommunityScreen(),
      AskAiScreen(onOpenQuietRoute: _openQuietLibraryRoute),
      MoreScreen(
        onUniversityTap: _openUniversityOnMap,
        onFoodTap: () => _openMapSearch(query: 'food near Iscte-IUL'),
        onActivitiesTap: () => _openMapSearch(query: 'activities near Iscte-IUL'),
        onSearchTap: () => _openMapSearch(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: AppNavigationBar(
        currentIndex: selectedIndex,
        items: AppNavItems.items,
        onTap: (index) {
          if (index == 1) {
            _openMapOverview();
            return;
          }
          _selectTab(index);
        },
      ),
    );
  }
}
